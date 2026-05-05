import 'package:flutter/material.dart';

import '../../data/hotel_model.dart';

/// PALETA DE COLORES 
class AppColors {
  static const Color gold = Color(0xFFD4AF37);
  static const Color charcoal = Color(0xFF1A1A1A);
  static const Color lightBg = Color(0xFFFAFAFA);
  static const Color textDark = Color(0xFF2C3E50);
  static const Color greyLight = Color(0xFFF0F4F8);
}

/// DATOS INICIALES (hoteles)
class AppData {
  static final List<HotelRoom> defaultRooms = [
    HotelRoom(
      id: '1',
      nombre: 'Suite Ocean View',
      location: 'Manta, Ecuador',
      descripcion: 'Una suite amplia con vista directa al mar y acabados premium.',
      precio: 180,
      rating: 4.9,
      fotos: const [],
      servicios: const ['WiFi', 'Piscina', 'Spa', 'Desayuno'],
    ),
    HotelRoom(
      id: '2',
      nombre: 'Loft Urbano',
      location: 'Quito, Ecuador',
      descripcion: 'Espacio moderno con diseño minimalista ideal para estadías cortas.',
      precio: 120,
      rating: 4.7,
      fotos: const [],
      servicios: const ['WiFi', 'Aire acondicionado', 'Gimnasio'],
    ),
    HotelRoom(
      id: '3',
      nombre: 'Penthouse Skyline',
      location: 'Guayaquil, Ecuador',
      descripcion: 'Vistas panorámicas, diseño elegante y máxima comodidad.',
      precio: 260,
      rating: 5.0,
      fotos: const [],
      servicios: const ['WiFi', 'Piscina', 'Restaurante', 'Servicio a la habitación'],
    ),
  ];
}

/// MAPEO DE ICONOS POR SERVICIO
class ServiceIcons {
  static IconData getIcon(String service) {
    final lower = service.toLowerCase();
    return switch (lower) {
      _ when lower.contains('wifi') => Icons.wifi,
      _ when lower.contains('aire') => Icons.ac_unit,
      _ when lower.contains('parking') => Icons.local_parking,
      _ when lower.contains('piscina') => Icons.pool,
      _ when lower.contains('spa') => Icons.spa,
      _ when lower.contains('desayuno') => Icons.free_breakfast,
      _ when lower.contains('gimnasio') => Icons.fitness_center,
      _ when lower.contains('restaurante') => Icons.restaurant,
      _ when lower.contains('servicio') => Icons.room_service,
      _ => Icons.check_circle_outline,
    };
  }
}

/// EXTENSIONES DE UTILIDAD
extension ColorExt on Color {
  Color withCustomOpacity(double opacity) => withOpacity(opacity);
}

extension ListExt<T> on List<T> {
  bool containsWhere(bool Function(T) test) => any(test);
  int findIndexWhere(bool Function(T) test) => indexWhere(test);
}
