class Photo {
  final String id;
  final String? description;
  final String? alt_description;
  final Map<String, String> urls;
  final Map<String, String> links;
  final PhotoUser user;

  Photo({
    required this.id,
    this.description,
    this.alt_description,
    required this.urls,
    required this.links,
    required this.user,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as String,
      description: json['description'] as String?,
      alt_description: json['alt_description'] as String?,
      urls: Map<String, String>.from(json['urls'] as Map),
      links: Map<String, String>.from(json['links'] as Map),
      user: PhotoUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class PhotoUser {
  final String username;
  final String name;

  PhotoUser({
    required this.username,
    required this.name,
  });

  factory PhotoUser.fromJson(Map<String, dynamic> json) {
    return PhotoUser(
      username: json['username'] as String,
      name: json['name'] as String,
    );
  }
} 