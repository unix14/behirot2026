import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase_options.dart';
import '../models/admin_stats.dart';
import '../models/party.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._internal();
  FirebaseService._internal();

  FirebaseAuth? _auth;
  FirebaseDatabase? _database;
  SharedPreferences? _prefs;

  String? _userId;
  bool _isInitialized = false;

  String? get userId => _userId;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      _prefs = await SharedPreferences.getInstance();
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      _auth = FirebaseAuth.instance;
      _database = FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: 'https://bhirot2026-default-rtdb.firebaseio.com');
      _isInitialized = true;
    } catch (e) {
      debugPrint('Firebase.initializeApp warning: $e');
    }
    await _authenticateUser();
  }

  Future<void> _authenticateUser() async {
    _prefs ??= await SharedPreferences.getInstance();
    if (_auth != null) {
      try {
        UserCredential cred;
        if (_auth!.currentUser != null) {
          cred = await _auth!.signInAnonymously();
          _userId = cred.user?.uid ?? _auth!.currentUser!.uid;
        } else {
          cred = await _auth!.signInAnonymously();
          _userId = cred.user?.uid;
        }
      } catch (e) {
        debugPrint('Firebase anonymous auth exception: $e. Falling back to persistent client UUID.');
      }
    }

    if (_userId == null || _userId!.isEmpty) {
      String? localUuid = _prefs!.getString('voter_client_uuid');
      if (localUuid == null) {
        localUuid = 'voter_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (DateTime.now().microsecond % 9000))}';
        await _prefs!.setString('voter_client_uuid', localUuid);
      }
      _userId = localUuid;
    }
  }

  Future<bool> hasUserVoted() async {
    _prefs ??= await SharedPreferences.getInstance();

    if (_database != null && _userId != null) {
      try {
        final snap = await _database!.ref('voters/$_userId').get().timeout(const Duration(milliseconds: 2500));
        if (snap.exists && (snap.child('hasVoted').value == true)) {
          await _prefs!.setBool('has_voted', true);
          return true;
        } else {
          // RTDB is source of truth: if no record in RTDB, user can vote!
          await _prefs!.setBool('has_voted', false);
          return false;
        }
      } catch (e) {
        debugPrint('Error checking voter status in RTDB: $e');
      }
    }
    return _prefs!.getBool('has_voted') ?? false;
  }

  Stream<Map<String, dynamic>> configStream() {
    if (_database == null) return const Stream.empty();
    return _database!.ref('config').onValue.map((event) {
      final val = event.snapshot.value;
      if (val is Map) {
        return Map<String, dynamic>.from(val);
      }
      return <String, dynamic>{};
    });
  }

  Stream<Map<String, Party>> partiesStream() {
    if (_database == null) return const Stream.empty();
    return _database!.ref('parties').onValue.map((event) {
      final val = event.snapshot.value;
      final Map<String, Party> result = {};
      if (val is Map) {
        for (final entry in val.entries) {
          if (entry.value is Map) {
            result[entry.key.toString()] = Party.fromMap(entry.key.toString(), entry.value as Map);
          }
        }
      }
      return result;
    });
  }

  Stream<Map<String, int>> votesAggregateStream() {
    if (_database == null) return const Stream.empty();
    return _database!.ref('votes_aggregate').onValue.map((event) {
      final val = event.snapshot.value;
      final Map<String, int> result = {};
      if (val is Map) {
        for (final entry in val.entries) {
          final count = int.tryParse(entry.value.toString()) ?? 0;
          result[entry.key.toString()] = count;
        }
      }
      return result;
    });
  }

  Future<bool> submitVote(String partyId) async {
    _prefs ??= await SharedPreferences.getInstance();
    final bool alreadyVoted = await hasUserVoted();
    if (alreadyVoted) {
      return false;
    }

    if (_database != null && _userId != null) {
      try {
        final Map<String, Object?> updates = {};
        updates['votes_aggregate/$partyId'] = ServerValue.increment(1);
        updates['voters/$_userId'] = {'hasVoted': true, 'votedAt': ServerValue.timestamp, 'partyId': partyId};
        await _database!.ref().update(updates);
      } catch (e) {
        debugPrint('RTDB atomic update error: $e');
        try {
          await _database!.ref('votes_aggregate/$partyId').set(ServerValue.increment(1));
          await _database!.ref('voters/$_userId').set({'hasVoted': true, 'votedAt': ServerValue.timestamp, 'partyId': partyId});
        } catch (innerError) {
          debugPrint('RTDB fallback write error: $innerError');
        }
      }
    }

    await _prefs!.setBool('has_voted', true);
    await _prefs!.setString('last_voted_party', partyId);
    await _prefs!.setString('voted_at', DateTime.now().toIso8601String());
    return true;
  }

  Future<AdminStats> fetchDetailedVoteStats() async {
    int totalVotes = 0;
    int realCount = 0;
    int simCount = 0;
    final Map<String, int> partyVotes = {};
    final Map<String, int> partyRealVotes = {};
    final Map<String, int> partySimulatedVotes = {};

    // 1. Fetch votes_aggregate via HTTP REST (fast & reliable across web without websocket wait)
    try {
      final aggRes = await http.get(Uri.parse('https://bhirot2026-default-rtdb.firebaseio.com/votes_aggregate.json')).timeout(const Duration(seconds: 4));
      if (aggRes.statusCode == 200 && aggRes.body.isNotEmpty && aggRes.body != 'null') {
        final dynamic decoded = jsonDecode(aggRes.body);
        if (decoded is Map) {
          for (final entry in decoded.entries) {
            final count = int.tryParse(entry.value.toString()) ?? 0;
            partyVotes[entry.key.toString()] = count;
            totalVotes += count;
          }
        }
      }
    } catch (e) {
      debugPrint('HTTP votes_aggregate fetch error: $e');
    }

    // Fallback for votes_aggregate via RTDB SDK if HTTP failed
    if (partyVotes.isEmpty && _database != null) {
      try {
        final aggSnap = await _database!.ref('votes_aggregate').get().timeout(const Duration(seconds: 3));
        if (aggSnap.exists && aggSnap.value is Map) {
          final aggMap = Map<String, dynamic>.from(aggSnap.value as Map);
          for (final entry in aggMap.entries) {
            final count = int.tryParse(entry.value.toString()) ?? 0;
            partyVotes[entry.key.toString()] = count;
            totalVotes += count;
          }
        }
      } catch (e) {
        debugPrint('RTDB votes_aggregate fallback error: $e');
      }
    }

    // 2. Fetch voters via HTTP REST for real vs simulated breakdown
    try {
      final votersRes = await http.get(Uri.parse('https://bhirot2026-default-rtdb.firebaseio.com/voters.json')).timeout(const Duration(seconds: 4));
      if (votersRes.statusCode == 200 && votersRes.body.isNotEmpty && votersRes.body != 'null') {
        final dynamic decoded = jsonDecode(votersRes.body);
        if (decoded is Map) {
          for (final v in decoded.values) {
            if (v is Map) {
              final isSim = v['sim'] == true;
              final partyId = v['partyId']?.toString();
              final count = (v['count'] is int) ? (v['count'] as int) : 1;
              if (isSim) {
                simCount += count;
                if (partyId != null) {
                  partySimulatedVotes[partyId] = (partySimulatedVotes[partyId] ?? 0) + count;
                }
              } else {
                realCount += count;
                if (partyId != null) {
                  partyRealVotes[partyId] = (partyRealVotes[partyId] ?? 0) + count;
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('HTTP voters fetch error: $e');
    }

    // Fallback for voters via RTDB SDK if HTTP failed
    if (realCount == 0 && simCount == 0 && _database != null) {
      try {
        final votersSnap = await _database!.ref('voters').get().timeout(const Duration(seconds: 3));
        if (votersSnap.exists && votersSnap.value is Map) {
          final votersMap = Map<String, dynamic>.from(votersSnap.value as Map);
          for (final v in votersMap.values) {
            if (v is Map) {
              final isSim = v['sim'] == true;
              final partyId = v['partyId']?.toString();
              final count = (v['count'] is int) ? (v['count'] as int) : 1;
              if (isSim) {
                simCount += count;
                if (partyId != null) {
                  partySimulatedVotes[partyId] = (partySimulatedVotes[partyId] ?? 0) + count;
                }
              } else {
                realCount += count;
                if (partyId != null) {
                  partyRealVotes[partyId] = (partyRealVotes[partyId] ?? 0) + count;
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint('RTDB voters fallback error: $e');
      }
    }

    final int unrecordedSim = (totalVotes > (realCount + simCount)) ? (totalVotes - (realCount + simCount)) : 0;
    simCount += unrecordedSim;
    for (final partyId in partyVotes.keys) {
      final total = partyVotes[partyId] ?? 0;
      final real = partyRealVotes[partyId] ?? 0;
      partySimulatedVotes[partyId] = (total >= real) ? (total - real) : 0;
    }

    return AdminStats(
      totalAggregateVotes: totalVotes,
      realVotesCount: realCount,
      simulatedVotesCount: simCount,
      partyVotes: partyVotes,
      partyRealVotes: partyRealVotes,
      partySimulatedVotes: partySimulatedVotes,
    );
  }

  Future<bool> castBatchVotes({required String partyId, required int count, required bool isSimulated}) async {
    if (count <= 0) return false;
    await initialize();
    if (_database == null) return false;
    try {
      final Map<String, Object?> updates = {};
      updates['votes_aggregate/$partyId'] = ServerValue.increment(count);
      final batchKey = 'batch_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (DateTime.now().microsecond % 9000))}';
      updates['voters/$batchKey'] = {'hasVoted': true, 'partyId': partyId, 'count': count, 'sim': isSimulated, 'votedAt': ServerValue.timestamp};
      await _database!.ref().update(updates);
      return true;
    } catch (e) {
      debugPrint('castBatchVotes error: $e');
      try {
        await _database!.ref('votes_aggregate/$partyId').set(ServerValue.increment(count));
        final batchKey = 'batch_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (DateTime.now().microsecond % 9000))}';
        await _database!.ref('voters/$batchKey').set({'hasVoted': true, 'partyId': partyId, 'count': count, 'sim': isSimulated, 'votedAt': ServerValue.timestamp});
        return true;
      } catch (innerError) {
        debugPrint('castBatchVotes fallback error: $innerError');
        return false;
      }
    }
  }

  Future<void> resetLocalVoterStatus() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove('has_voted');
    await _prefs!.remove('last_voted_party');
    await _prefs!.remove('voted_at');
    if (_database != null && _userId != null) {
      try {
        await _database!.ref('voters/$_userId').remove();
      } catch (e) {
        debugPrint('resetLocalVoterStatus RTDB remove warning: $e');
      }
    }
  }
}
