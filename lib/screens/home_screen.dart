// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/media_service.dart';
import '../models/media_file.dart';
import 'camera_screen.dart';
import 'gallery_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF2C1810),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2C1810),
                      Color(0xFF8B6914),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                        ),
                        child: const Icon(Icons.hotel, size: 48, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'HOTEL MANAGEMENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                      const Text(
                        'Sistema de Medios',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  Consumer<MediaService>(
                    builder: (ctx, service, _) {
                      final images = service.getImages().length;
                      final videos = service.getVideos().length;
                      return Row(
                        children: [
                          _StatCard(
                            label: 'Fotos',
                            value: '$images',
                            icon: Icons.camera_alt,
                            color: const Color(0xFF1565C0),
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            label: 'Videos',
                            value: '$videos',
                            icon: Icons.videocam,
                            color: const Color(0xFF880E4F),
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            label: 'Total',
                            value: '${images + videos}',
                            icon: Icons.folder,
                            color: const Color(0xFF2E7D32),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // Main actions
                  const Text(
                    'ACCIONES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.camera_alt,
                          label: 'Capturar\nFoto',
                          color: const Color(0xFF2C1810),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CameraScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.videocam,
                          label: 'Grabar\nVideo',
                          color: const Color(0xFF8B6914),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CameraScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.photo_library,
                          label: 'Ver\nGalería',
                          color: const Color(0xFF2E7D32),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const GalleryScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Categories quick access
                  const Text(
                    'POR CATEGORÍA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Consumer<MediaService>(
                    builder: (ctx, service, _) {
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.1,
                        children: MediaCategory.values.map((cat) {
                          final count = service.getByCategory(cat).length;
                          return _CategoryCard(
                            category: cat,
                            count: count,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GalleryScreen(initialCategory: cat),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Recent media preview
                  Consumer<MediaService>(
                    builder: (ctx, service, _) {
                      final recent = service.files.take(5).toList();
                      if (recent.isEmpty) return const SizedBox();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'RECIENTES',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  letterSpacing: 2,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const GalleryScreen()),
                                ),
                                child: const Text('Ver todos'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 100,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: recent.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (ctx, i) {
                                final f = recent[i];
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    width: 100,
                                    child: f.type == MediaType.image
                                        ? Image.file(f.file, fit: BoxFit.cover)
                                        : Container(
                                            color: Colors.grey[800],
                                            child: const Center(
                                              child: Icon(Icons.videocam, color: Colors.white, size: 32),
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final MediaCategory category;
  final int count;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final labels = {
      MediaCategory.habitacion: ('🛏', 'Habitación'),
      MediaCategory.lobby: ('🏨', 'Lobby'),
      MediaCategory.restaurante: ('🍽', 'Restaurante'),
      MediaCategory.piscina: ('🏊', 'Piscina'),
      MediaCategory.eventos: ('🎉', 'Eventos'),
      MediaCategory.otro: ('📁', 'Otro'),
    };
    final (emoji, name) = labels[category]!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            Text(name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text('$count archivos', style: const TextStyle(fontSize: 9, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
