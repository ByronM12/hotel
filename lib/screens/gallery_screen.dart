
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/media_file.dart';
import '../services/media_service.dart';
import 'media_detail_screen.dart';
import 'video_player_screen.dart';

class GalleryScreen extends StatefulWidget {
  final MediaCategory? initialCategory;
  const GalleryScreen({super.key, this.initialCategory});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  MediaCategory? _filterCategory;
  MediaType? _filterType;
  String _searchQuery = '';
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _filterCategory = widget.initialCategory;
    // Recargar archivos al abrir la galería para que estén actualizados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<MediaService>().loadFiles();
    });
  }

  List<MediaFile> _filteredFiles(List<MediaFile> all) {
    return all.where((f) {
      if (_filterCategory != null && f.category != _filterCategory) return false;
      if (_filterType != null && f.type != _filterType) return false;
      if (_searchQuery.isNotEmpty &&
          !f.title.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !f.description.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaService>(
      builder: (context, service, _) {
        final filtered = _filteredFiles(service.files);
        return Scaffold(
          backgroundColor: const Color(0xFFF5F0E8),
          appBar: AppBar(
            backgroundColor: const Color(0xFF2C1810),
            foregroundColor: Colors.white,
            title: Text(
              _filterCategory != null ? _filterCategory!.label.toUpperCase() : 'GALERÍA',
              style: const TextStyle(letterSpacing: 3, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
                onPressed: () => setState(() => _isGridView = !_isGridView),
              ),
            ],
          ),
          body: Column(
            children: [
              // Buscador
              Container(
                color: const Color(0xFF2C1810),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar archivos...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Chips de filtro
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      _Chip(
                        label: 'Todo',
                        isSelected: _filterType == null && _filterCategory == null,
                        onTap: () => setState(() { _filterType = null; _filterCategory = null; }),
                      ),
                      _Chip(
                        label: '📷 Fotos',
                        isSelected: _filterType == MediaType.image,
                        onTap: () => setState(() { _filterType = MediaType.image; _filterCategory = null; }),
                      ),
                      _Chip(
                        label: '🎥 Videos',
                        isSelected: _filterType == MediaType.video,
                        onTap: () => setState(() { _filterType = MediaType.video; _filterCategory = null; }),
                      ),
                      const SizedBox(width: 8),
                      Container(width: 1, height: 24, color: Colors.grey[300]),
                      const SizedBox(width: 8),
                      ...MediaCategory.values.map((cat) => _Chip(
                        label: _catLabel(cat),
                        isSelected: _filterCategory == cat,
                        onTap: () => setState(() {
                          _filterCategory = cat == _filterCategory ? null : cat;
                          _filterType = null;
                        }),
                      )),
                    ],
                  ),
                ),
              ),

              // Contador
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFFF5F0E8),
                child: Row(
                  children: [
                    Text('${filtered.length} archivo${filtered.length != 1 ? "s" : ""}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const Spacer(),
                    FutureBuilder<int>(
                      future: service.getTotalSize(),
                      builder: (ctx, snap) => Text(
                        snap.hasData ? service.formatSize(snap.data!) : '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: service.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? _buildEmpty()
                        : _isGridView
                            ? _buildGrid(filtered, service)
                            : _buildList(filtered, service),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _filterCategory != null
                ? 'No hay archivos en ${_filterCategory!.label}'
                : 'No hay archivos',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text('Captura fotos o videos con la cámara',
              style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildGrid(List<MediaFile> files, MediaService service) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4,
      ),
      itemCount: files.length,
      itemBuilder: (ctx, i) => _GridItem(
        file: files[i],
        onTap: () => _openFile(files[i]),
        onDelete: () => _confirmDelete(files[i], service),
      ),
    );
  }

  Widget _buildList(List<MediaFile> files, MediaService service) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: files.length,
      itemBuilder: (ctx, i) => _ListItem(
        file: files[i],
        onTap: () => _openFile(files[i]),
        onDelete: () => _confirmDelete(files[i], service),
      ),
    );
  }

  // ── FIX: abre reproductor de video para videos, detalle para fotos ──────
  void _openFile(MediaFile file) {
    if (file.type == MediaType.video) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => VideoPlayerScreen(file: file)));
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => MediaDetailScreen(file: file)));
    }
  }

  Future<void> _confirmDelete(MediaFile file, MediaService service) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar archivo'),
        content: Text('¿Eliminar "${file.title}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) await service.deleteFile(file.id);
  }

  String _catLabel(MediaCategory cat) {
    switch (cat) {
      case MediaCategory.habitacion:  return '🛏 Hab.';
      case MediaCategory.lobby:       return '🏨 Lobby';
      case MediaCategory.restaurante: return '🍽 Rest.';
      case MediaCategory.piscina:     return '🏊 Piscina';
      case MediaCategory.eventos:     return '🎉 Eventos';
      case MediaCategory.otro:        return '📁 Otro';
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B6914) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF8B6914) : Colors.grey[300]!),
        ),
        child: Text(label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          )),
      ),
    );
  }
}

class _GridItem extends StatelessWidget {
  final MediaFile file;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _GridItem({required this.file, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: file.type == MediaType.image
                ? Image.file(file.file, fit: BoxFit.cover)
                : Container(
                    color: Colors.grey[850],
                    child: const Center(
                      child: Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
                    ),
                  ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              child: Text(file.title,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ),
          if (file.type == MediaType.video)
            const Positioned(top: 4, right: 4,
              child: Icon(Icons.videocam, color: Colors.white, size: 16)),
        ],
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final MediaFile file;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _ListItem({required this.file, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: 60, height: 60,
            child: file.type == MediaType.image
                ? Image.file(file.file, fit: BoxFit.cover)
                : Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.videocam, color: Colors.white)),
          ),
        ),
        title: Text(file.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(file.categoryLabel, style: const TextStyle(fontSize: 11)),
            Text(fmt.format(file.createdAt), style: const TextStyle(fontSize: 11)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (file.type == MediaType.video)
              const Icon(Icons.play_circle_outline, color: Color(0xFF8B6914), size: 20),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
