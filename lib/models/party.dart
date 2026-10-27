import 'package:flutter/material.dart';

enum PartyBloc { coalition, opposition, undecided }

class Party {
  final String id;
  final String ballotLetter;
  final String name;
  final String platform;
  final String website;
  final String platformUrl;
  final String candidatesPdfUrl;
  final String idiUrl;
  final String logoUrl;
  final List<String> keyFigures;
  final PartyBloc bloc;
  final Color color;

  const Party({required this.id, required this.ballotLetter, required this.name, required this.platform, required this.website, this.platformUrl = '', this.candidatesPdfUrl = '', this.idiUrl = '', this.logoUrl = '', required this.keyFigures, required this.bloc, required this.color});

  String get localAssetLogo => 'assets/logos/$id.png';

  factory Party.fromMap(String id, Map<dynamic, dynamic> map) {
    return Party(id: id, ballotLetter: map['ballotLetter']?.toString() ?? '', name: map['name']?.toString() ?? id, platform: map['platform']?.toString() ?? '', website: map['website']?.toString() ?? '', platformUrl: map['platformUrl']?.toString() ?? '', candidatesPdfUrl: map['candidatesPdfUrl']?.toString() ?? '', idiUrl: map['idiUrl']?.toString() ?? '', logoUrl: map['logoUrl']?.toString() ?? '', keyFigures: (map['keyFigures'] as List?)?.map((e) => e.toString()).toList() ?? const [], bloc: _parseBloc(map['bloc']?.toString()), color: _parseColor(map['color']?.toString()));
  }

  static PartyBloc _parseBloc(String? blocStr) {
    if (blocStr == 'coalition') return PartyBloc.coalition;
    if (blocStr == 'opposition') return PartyBloc.opposition;
    return PartyBloc.undecided;
  }

  static Color _parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return const Color(0xFF1E88E5);
    final hexCode = colorStr.replaceAll('#', '');
    if (hexCode.length == 6) {
      return Color(int.parse('FF$hexCode', radix: 16));
    } else if (hexCode.length == 8) {
      return Color(int.parse(hexCode, radix: 16));
    }
    return const Color(0xFF1E88E5);
  }

  Map<String, dynamic> toMap() {
    return {'ballotLetter': ballotLetter, 'name': name, 'platform': platform, 'website': website, 'platformUrl': platformUrl, 'candidatesPdfUrl': candidatesPdfUrl, 'idiUrl': idiUrl, 'logoUrl': logoUrl, 'keyFigures': keyFigures, 'bloc': bloc == PartyBloc.coalition ? 'coalition' : (bloc == PartyBloc.opposition ? 'opposition' : 'undecided'), 'color': '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}'};
  }
}
