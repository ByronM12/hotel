import 'package:flutter/material.dart';

import '../../core/app_constants.dart';
import '../../core/ui_helpers.dart';
import '../../data/hotel_model.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({
    super.key,
    required this.favorites,
    required this.onFavoritesChanged,
  });

  final List<HotelRoom> favorites;
  final Function(HotelRoom) onFavoritesChanged;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late List<HotelRoom> _localFavorites;

  @override
  void initState() {
    super.initState();
    _localFavorites = List.from(widget.favorites);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _removeFavorite(HotelRoom room) {
    setState(() {
      _localFavorites.removeWhere((r) => r.id == room.id);
    });
    widget.onFavoritesChanged(room);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${room.nombre} removido de favoritos'),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Mis Favoritos',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 28,
                fontFamily: 'Montserrat',
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
          color: AppColors.textDark,
        ),
      ),
      body: _localFavorites.isEmpty
          ? buildEmptyState(
              title: 'Sin favoritos aún',
              subtitle: 'Agrega hoteles a tu lista de favoritos',
              icon: Icons.favorite_border_rounded,
              buttonText: 'Explorar Hoteles',
              onButtonPressed: () => Navigator.pop(context),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 100),
              itemCount: _localFavorites.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _FavoriteCard(
                  room: _localFavorites[index],
                  index: index,
                  onRemove: _removeFavorite,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(room: _localFavorites[index]),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.room,
    required this.index,
    required this.onRemove,
    required this.onTap,
  });

  final HotelRoom room;
  final int index;
  final Function(HotelRoom) onRemove;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const gradients = [
      [Color(0xFFF5F1ED), Color(0xFFE8DED5)],
      [Color(0xFFF0F4F8), Color(0xFFE0E8F0)],
      [Color(0xFFF5EFF5), Color(0xFFE8DDE8)],
    ];

    final gradient = gradients[index % 3];

    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Material(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: gradient,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.apartment_rounded,
                            color: Colors.grey[400],
                            size: 48,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              room.nombre,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on_rounded,
                                    size: 12, color: Colors.grey[500]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    room.location,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '\$${room.precio.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: AppColors.gold,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                    Text(
                                      'por noche',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.star_rounded,
                                        size: 14, color: Colors.grey[500]),
                                    const SizedBox(width: 4),
                                    Text(
                                      room.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: AppColors.textDark,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onRemove(room),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.gold,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
