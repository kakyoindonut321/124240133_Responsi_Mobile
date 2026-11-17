class GameModel {
  // id
  // title
  // thumbnail
  // description
  // genre
  // platform
  // publisher
  // developer
  // release_date
  // screenshots[id, image]
  final int id;
  final String title;
  final String? thumbnail;
  final String description;
  final String genre;
  final String platform;
  final String publisher;
  final String developer;
  final String release_date;
  final Map<int, String> screenshots;

  GameModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.description,
    required this.genre,
    required this.platform,
    required this.publisher,
    required this.developer,
    required this.release_date,
    required this.screenshots,
  });

  // Dari JSON API TVMaze -> objek GameModel
  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'],
      title: json['title'] ?? '-',
      thumbnail: json['thumbnail']?['medium'],
      description: _stripHtml(json['description'] ?? ''),
      genre: json['genre'] ?? '-',
      platform: json['platform'] ?? '-',
      publisher: json['publisher'] ?? '-',
      developer: json['developer'] ?? '-',
      release_date: json['release_date'] ?? '-',
      screenshots: Map<int, String>.from(json['screenshots'] ?? []),
    );
  }

  // Dari Map Hive -> objek GameModel
  factory GameModel.fromMap(Map map) {
    return GameModel(
      id: map['id'],
      title: map['title'],
      thumbnail: map['thumbnail'],
      description: map['description'],
      genre: map['genre'],
      platform: map['platform'],
      publisher: map['publisher'],
      developer: map['developer'],
      release_date: map['release_date'],
      screenshots: Map<int, String>.from(map['screenshots']),
    );
  }

  // Objek -> Map, supaya bisa disimpan di Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
      'description': description,
      'genre': genre,
      'platform': platform,
      'publisher': publisher,
      'developer': developer,
      'release_date': release_date,
      'screenshots': screenshots,
    };
  }

  // Summary dari API berisi tag HTML (<p>, <b>), kita bersihkan
  static String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}
