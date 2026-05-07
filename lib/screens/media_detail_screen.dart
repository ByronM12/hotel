// lib/screens/media_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/media_file.dart';
import '../services/media_service.dart';

class MediaDetailScreen extends StatefulWidget {
  final MediaFile file;

  const MediaDetailScreen({super.key, required this.file});

  @override
  State<MediaDetailScreen> createState() => _MediaDetailScreenState();
}

class _MediaDetailScreenState extends State<MediaDetailScreen> {
  late MediaFile _file;
  bool _isEditing = false;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _roomController = TextEditingController();
  late MediaCategory _editCategory;

  @override
  void initState() {
    super.initState();
    _file = widget.file;
    _titleController.text = _file.title;
    _descController.text = _file.description;
    _roomController.text = _file.roomNumber?.toString() ?? '';
    _editCategory = _file.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final service = context.read<MediaService>();
    await service.updateFile(
      _file.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      category: _editCategory,
      roomNumber: int.tryParse(_roomController.text),
    );

    // Reload updated file
    final updated = service.files.firstWhere((f) => f.id == _file.id);
    setState(() {
      _file = updated;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Cambios guardados')),
    );
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar archivo'),
        content: Text('¿Deseas eliminar "${_file.title}" permanentemente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      await context.read<MediaService>().deleteFile(_file.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy • HH:mm');

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: CustomScrollView(
        slivers: [
          // App bar with image hero
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: const Color(0xFF2C1810),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(_isEditing ? Icons.close : Icons.edit),
                onPressed: () => setState(() => _isEditing = !_isEditing),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: _delete,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _file.type == MediaType.image
                  ? Hero(
                      tag: _file.id,
                      child: Image.file(_file.file, fit: BoxFit.cover),
                    )
                  : Container(
                      color: Colors.black,
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          size: 80,
                          color: Colors.white54,
                        ),
                      ),
                    ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F0E8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(24),
              child: _isEditing ? _buildEditForm() : _buildDetails(fmt),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(DateFormat fmt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type badge
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _file.type == MediaType.image
                    ? const Color(0xFF1565C0)
                    : const Color(0xFF880E4F),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _file.type == MediaType.image ? '📷 FOTO' : '🎥 VIDEO',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF8B6914),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _file.categoryLabel.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          _file.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C1810),
          ),
        ),

        if (_file.roomNumber != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.door_front_door, size: 16, color: Color(0xFF8B6914)),
              const SizedBox(width: 6),
              Text(
                'Habitación ${_file.roomNumber}',
                style: const TextStyle(color: Color(0xFF8B6914), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],

        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.access_time, size: 14, color: Colors.grey),
            const SizedBox(width: 6),
            Text(
              fmt.format(_file.createdAt),
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),

        if (_file.description.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          const Text(
            'Descripción',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(_file.description, style: const TextStyle(fontSize: 15, height: 1.5)),
        ],

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 12),
        const Text(
          'UBICACIÓN DEL ARCHIVO',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 1),
        ),
        const SizedBox(height: 6),
        Text(
          _file.path,
          style: TextStyle(fontSize: 11, color: Colors.grey[600], fontFamily: 'monospace'),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Editar archivo',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C1810)),
        ),
        const SizedBox(height: 20),

        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Título',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.title),
          ),
        ),
        const SizedBox(height: 12),

        DropdownButtonFormField<MediaCategory>(
          value: _editCategory,
          decoration: const InputDecoration(
            labelText: 'Categoría',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          items: MediaCategory.values.map((cat) {
            final labels = {
              MediaCategory.habitacion: '🛏 Habitación',
              MediaCategory.lobby: '🏨 Lobby',
              MediaCategory.restaurante: '🍽 Restaurante',
              MediaCategory.piscina: '🏊 Piscina',
              MediaCategory.eventos: '🎉 Eventos',
              MediaCategory.otro: '📁 Otro',
            };
            return DropdownMenuItem(value: cat, child: Text(labels[cat]!));
          }).toList(),
          onChanged: (v) => setState(() => _editCategory = v!),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _roomController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Número de habitación',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.door_front_door),
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _descController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Descripción',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Guardar cambios'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B6914),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _saveChanges,
          ),
        ),
      ],
    );
  }
}