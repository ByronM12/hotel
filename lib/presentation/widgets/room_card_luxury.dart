import 'package:flutter/material.dart';

import '../../data/hotel_model.dart';

class RoomCardLuxury extends StatefulWidget {
  const RoomCardLuxury({
    super.key,
    required this.room,
    required this.topAmenities,
    this.height = 220,
    this.isActive = false,
    this.onTap,
  });

  final HotelRoom room;
  final List<String> topAmenities;
  final double height;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  State<RoomCardLuxury> createState() => _RoomCardLuxuryState();
}

class _RoomCardLuxuryState extends State<RoomCardLuxury>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(RoomCardLuxury oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _scaleController.forward();
      } else {
        _scaleController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Paleta de gradientes SUTILES (fondo claro + overlay suave)
    final List<List<Color>> luxePalette = [
      [const Color(0xFFF5F1ED), const Color(0xFFE8DED5)], // Beige/Taupe
      [const Color(0xFFF0F4F8), const Color(0xFFE0E8F0)], // Azul claro
      [const Color(0xFFF5EFF5), const Color(0xFFE8DDE8)], // Mauve claro
    ];
    
    final int seed = int.tryParse(widget.room.id) ?? 0;
    final List<Color> bgColors = luxePalette[seed % luxePalette.length];

    return ScaleTransition(
      scale: Tween<double>(begin: 1, end: 1.04).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(widget.isActive ? 0.12 : 0.06),
              blurRadius: widget.isActive ? 28 : 16,
              offset: Offset(0, widget.isActive ? 12 : 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: widget.onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: widget.height,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // HERO IMAGE (edge-to-edge con gradiente sutil)
                    Hero(
                      tag: 'room-image-${widget.room.id}',
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: bgColors,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.apartment_rounded,
                            color: Colors.grey[300],
                            size: 80,
                          ),
                        ),
                      ),
                    ),
                    
                    // SUBTLE OVERLAY (solo en base para info)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 140,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.12),
                              Colors.black.withOpacity(0.32),
                            ],
                            stops: const [0, 0.6, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // RATING BADGE (superior-izquierda, neumórfica elegiante)
                    Positioned(
                      left: 16,
                      top: 16,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 240),
                        scale: widget.isActive ? 1.08 : 1.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.96),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Color(0xFFD4AF37), // Gold accent
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.room.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Color(0xFF2C3E50),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // LAYOUT INFORMACIÓN FLOTANTE
                    // Nombre (izquierda) + Precio/Rating (derecha)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // NOMBRE y UBICACIÓN (lado izquierdo)
                          Expanded(
                            child: AnimatedSlide(
                              duration: const Duration(milliseconds: 240),
                              offset: widget.isActive
                                  ? Offset.zero
                                  : const Offset(-0.02, 0.02),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.room.nombre,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Montserrat',
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on_rounded,
                                        color: Colors.white.withOpacity(0.85),
                                        size: 13,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          widget.room.location,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white
                                                .withOpacity(0.85),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // PRECIO EN BADGE DORADO (lado derecho)
                          AnimatedSlide(
                            duration: const Duration(milliseconds: 240),
                            offset: widget.isActive
                                ? Offset.zero
                                : const Offset(0.02, 0.02),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4AF37),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '\$${widget.room.precio.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'por noche',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Montserrat',
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
    );
  }
}
