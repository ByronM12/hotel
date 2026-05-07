// lib/models/media_file.dart

import 'dart:io';

enum MediaType { image, video }

enum MediaCategory {
  habitacion,
  lobby,
  restaurante,
  piscina,
  eventos,
  otro,
}

class MediaFile {
  final String id;
  final String path;
  final MediaType type;
  final MediaCategory category;
  final String title;
  final String description;
  final DateTime createdAt;
  final int? roomNumber;

  MediaFile({
    required this.id,
    required this.path,
    required this.type,
    required this.category,
    required this.title,
    this.description = '',
    required this.createdAt,
    this.roomNumber,
  });

  File get file => File(path);
  bool get exists => File(path).existsSync();

  String get categoryLabel {
    switch (category) {
      case MediaCategory.habitacion:
        return 'Habitación';
      case MediaCategory.lobby:
        return 'Lobby';
      case MediaCategory.restaurante:
        return 'Restaurante';
      case MediaCategory.piscina:
        return 'Piscina';
      case MediaCategory.eventos:
        return 'Eventos';
      case MediaCategory.otro:
        return 'Otro';
    }
  }

  String get typeLabel => type == MediaType.image ? 'Imagen' : 'Video';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'type': type.index,
      'category': category.index,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'roomNumber': roomNumber,
    };
  }

  factory MediaFile.fromMap(Map<String, dynamic> map) {
    return MediaFile(
      id: map['id'],
      path: map['path'],
      type: MediaType.values[map['type']],
      category: MediaCategory.values[map['category']],
      title: map['title'],
      description: map['description'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      roomNumber: map['roomNumber'],
    );
  }

  MediaFile copyWith({
    String? title,
    String? description,
    MediaCategory? category,
    int? roomNumber,
  }) {
    return MediaFile(
      id: id,
      path: path,
      type: type,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      roomNumber: roomNumber ?? this.roomNumber,
    );
  }
}