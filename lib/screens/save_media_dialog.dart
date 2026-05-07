// lib/screens/save_media_dialog.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/media_file.dart';
import '../services/media_service.dart';

class SaveMediaDialog extends StatefulWidget {
  final String filePath;
  final MediaType type;

  const SaveMediaDialog({
    super.key,
    required this.filePath,
    required this.type,
  });

  @override
  State<SaveMediaDialog> createState() => _SaveMediaDialogState();
}

class _SaveMediaDialogState extends State<SaveMediaDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _roomController = TextEditingController();
  MediaCategory _selectedCategory = MediaCategory.habitacion;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un título')),
      );
      return;
    }

    setState(() => _saving = true);
    final service = context.read<MediaService>();

    await service.addFile(
      sourcePath: widget.filePath,
      type: widget.type,
      category: _selectedCategory,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      roomNumber: int.tryParse(_roomController.text),
    );

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.type == MediaType.image ? Icons.image : Icons.videocam,
                  color: const Color(0xFF8B6914),
                ),
                const SizedBox(width: 8),
                Text(
                  'Guardar ${widget.type == MediaType.image ? "Foto" : "Video"}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Preview thumbnail
            if (widget.type == MediaType.image)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(widget.filePath),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 16),

            // Title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                hintText: 'Ej: Habitación 101 - Cama',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 12),

            // Category
            DropdownButtonFormField<MediaCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: MediaCategory.values.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(_categoryLabel(cat)),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 12),

            // Room number (optional)
            TextField(
              controller: _roomController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Número de habitación (opcional)',
                hintText: 'Ej: 101',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.door_front_door),
              ),
            ),
            const SizedBox(height: 12),

            // Description
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _saving ? null : () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B6914),
                      foregroundColor: Colors.white,
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(MediaCategory cat) {
    switch (cat) {
      case MediaCategory.habitacion: return '🛏 Habitación';
      case MediaCategory.lobby: return '🏨 Lobby';
      case MediaCategory.restaurante: return '🍽 Restaurante';
      case MediaCategory.piscina: return '🏊 Piscina';
      case MediaCategory.eventos: return '🎉 Eventos';
      case MediaCategory.otro: return '📁 Otro';
    }
  }
}