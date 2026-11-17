class GameModel {
  final int id;
  final String title;
  final String? thumbnail;
  final String short_description;
  final String description;
  final String genre;
  final String platform;
  final String publisher;
  final String developer;
  final String release_date;

  final List<String> screenshots;
  final Map<String, dynamic> minimum_system_requirements;

  GameModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.short_description,
    required this.description,
    required this.genre,
    required this.platform,
    required this.publisher,
    required this.developer,
    required this.release_date,
    required this.screenshots,
    required this.minimum_system_requirements,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '-',
      thumbnail: json['thumbnail']?.toString(),
      short_description: json['short_description']?.toString() ?? '-',
      description: _stripHtml(json['description']?.toString() ?? ''),
      genre: json['genre']?.toString() ?? '-',
      platform: json['platform']?.toString() ?? '-',
      publisher: json['publisher']?.toString() ?? '-',
      developer: json['developer']?.toString() ?? '-',
      release_date: json['release_date']?.toString() ?? '-',
      screenshots: _parseScreenshots(json['screenshots']),
      minimum_system_requirements: _parseRequirements(
        json['minimum_system_requirements'],
      ),
    );
  }

  factory GameModel.fromMap(Map map) {
    return GameModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      title: map['title']?.toString() ?? '-',
      thumbnail: map['thumbnail']?.toString(),
      short_description: map['short_description']?.toString() ?? '-',
      description: map['description']?.toString() ?? '',
      genre: map['genre']?.toString() ?? '-',
      platform: map['platform']?.toString() ?? '-',
      publisher: map['publisher']?.toString() ?? '-',
      developer: map['developer']?.toString() ?? '-',
      release_date: map['release_date']?.toString() ?? '-',
      screenshots: _parseScreenshots(map['screenshots']),
      minimum_system_requirements: _parseRequirements(
        map['minimum_system_requirements'],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
      'short_description': short_description,
      'description': description,
      'genre': genre,
      'platform': platform,
      'publisher': publisher,
      'developer': developer,
      'release_date': release_date,
      'screenshots': screenshots,
      'minimum_system_requirements': minimum_system_requirements,
    };
  }

  // Screenshots: bisa berupa List<Map{id,image}> atau List<String>.
  // Endpoint /games tidak mengirim field ini, jadi hasilnya list kosong.
  static List<String> _parseScreenshots(dynamic raw) {
    final List<String> result = [];

    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          final image = item['image'];
          if (image is String) result.add(image);
        } else if (item is String) {
          result.add(item);
        }
      }
    }

    return result;
  }

  // Minimum system requirements: hanya valid jika berupa Map.
  static Map<String, dynamic> _parseRequirements(dynamic raw) {
    final Map<String, dynamic> result = {};

    if (raw is Map) {
      raw.forEach((key, value) {
        result[key.toString()] = value;
      });
    }

    return result;
  }

  static String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}
