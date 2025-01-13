import 'package:hive/hive.dart';

part 'photo.g.dart';

@HiveType(typeId: 0)
class Photo {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String? description;
  
  @HiveField(2)
  final String? altDescription;
  
  @HiveField(3)
  final Map<String, String> urls;
  
  @HiveField(4)
  final Map<String, String> links;
  
  @HiveField(5)
  final String? color;
  
  @HiveField(6)
  final int? likes;
  
  @HiveField(7)
  final PhotoUser user;

  @HiveField(8)
  final DateTime? updatedAt;

  Photo({
    required this.id,
    this.description,
    this.altDescription,
    required this.urls,
    required this.links,
    this.color,
    this.likes,
    required this.user,
    this.updatedAt,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as String,
      description: json['description'] as String?,
      altDescription: json['alt_description'] as String?,
      urls: Map<String, String>.from(json['urls'] as Map),
      links: Map<String, String>.from(json['links'] as Map),
      color: json['color'] as String?,
      likes: json['likes'] as int?,
      user: PhotoUser.fromJson(json['user'] as Map<String, dynamic>),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }
}

@HiveType(typeId: 1)
class PhotoUser {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String username;
  
  @HiveField(2)
  final String name;
  
  @HiveField(3)
  final Map<String, String>? profileImage;

  PhotoUser({
    required this.id,
    required this.username,
    required this.name,
    this.profileImage,
  });

  factory PhotoUser.fromJson(Map<String, dynamic> json) {
    return PhotoUser(
      id: json['id'] as String,
      username: json['username'] as String,
      name: json['name'] as String,
      profileImage: json['profile_image'] != null
          ? Map<String, String>.from(json['profile_image'] as Map)
          : null,
    );
  }
} 