// lib/services/media_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/media_file.dart';

class MediaService extends ChangeNotifier {
  static const String _indexFileName = 'media_index.json';

  List<MediaFile> _files = [];
  bool _isLoading = false;

  List<MediaFile> get files => List.unmodifiable(_files);
  bool get isLoading => _isLoading;

  List<MediaFile> getByCategory(MediaCategory category) =>
      _files.where((f) => f.category == category).toList();

  List<MediaFile> getImages() =>
      _files.where((f) => f.type == MediaType.image).toList();

  List<MediaFile> getVideos() =>
      _files.where((f) => f.type == MediaType.video).toList();

  /// Directorio raíz donde se guardan los medios del hotel
  Future<Directory> get _mediaDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'hotel_media'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Subdirectorio por categoría
  Future<Directory> _categoryDir(MediaCategory category) async {
    final root = await _mediaDir;
    final dir = Directory(p.join(root.path, category.name));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Carga el índice de archivos desde disco
  Future<void> loadFiles() async {
    _isLoading = true;
    notifyListeners();
    try {
      final dir = await _mediaDir;
      final indexFile = File(p.join(dir.path, _indexFileName));
      if (await indexFile.exists()) {
        final content = await indexFile.readAsString();
        final List<dynamic> list = jsonDecode(content);
        _files = list
            .map((e) => MediaFile.fromMap(e as Map<String, dynamic>))
            .where((f) => f.exists)
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading media index: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Guarda el índice en disco
  Future<void> _saveIndex() async {
    final dir = await _mediaDir;
    final indexFile = File(p.join(dir.path, _indexFileName));
    await indexFile.writeAsString(jsonEncode(_files.map((f) => f.toMap()).toList()));
  }

  /// Agrega un archivo al índice (ya copiado a la carpeta destino)
  Future<MediaFile> addFile({
    required String sourcePath,
    required MediaType type,
    required MediaCategory category,
    required String title,
    String description = '',
    int? roomNumber,
  }) async {
    final catDir = await _categoryDir(category);
    final ext = p.extension(sourcePath);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final destPath = p.join(catDir.path, '$id$ext');

    // Copiar archivo a carpeta organizada
    await File(sourcePath).copy(destPath);

    final mediaFile = MediaFile(
      id: id,
      path: destPath,
      type: type,
      category: category,
      title: title,
      description: description,
      createdAt: DateTime.now(),
      roomNumber: roomNumber,
    );

    _files.insert(0, mediaFile);
    await _saveIndex();
    notifyListeners();
    return mediaFile;
  }

  /// Actualiza metadatos de un archivo
  Future<void> updateFile(String id, {
    String? title,
    String? description,
    MediaCategory? category,
    int? roomNumber,
  }) async {
    final idx = _files.indexWhere((f) => f.id == id);
    if (idx == -1) return;

    final updated = _files[idx].copyWith(
      title: title,
      description: description,
      category: category,
      roomNumber: roomNumber,
    );
    _files[idx] = updated;
    await _saveIndex();
    notifyListeners();
  }

  /// Elimina un archivo del disco y del índice
  Future<void> deleteFile(String id) async {
    final idx = _files.indexWhere((f) => f.id == id);
    if (idx == -1) return;

    final file = _files[idx];
    if (file.exists) {
      await file.file.delete();
    }
    _files.removeAt(idx);
    await _saveIndex();
    notifyListeners();
  }

  /// Tamaño total ocupado en bytes
  Future<int> getTotalSize() async {
    int total = 0;
    for (final f in _files) {
      if (f.exists) {
        total += await f.file.length();
      }
    }
    return total;
  }

  String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}