class Photo {
  final String id;
  final String url;
  final String description;
  final String userName;

  Photo({
    required this.id,
    required this.url,
    required this.description,
    required this.userName,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    // TODO: Implement JSON parsing
    return Photo(
      id: '',
      url: '',
      description: '',
      userName: '',
    );
  }
} 