// lib/src/models/photo_description.dart

class PhotoDescription {
  final String description;

  PhotoDescription({required this.description});

  factory PhotoDescription.fromJson(Map<String, dynamic> json) {
    return PhotoDescription(
      description: json['description'] ?? 'No description provided.',
    );
  }
}
