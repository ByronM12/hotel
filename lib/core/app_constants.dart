// Versión actualizada con coordenadas de hoteles para el mapa

import 'package:flutter/material.dart';
import '../data/hotel_model.dart';

// ─── COLORES LUXURY ─────────────────────────────────────────────────────────

class AppColors {
  static const Color gold = Color(0xFFD4AF37);
  static const Color darkCharcoal = Color(0xFF1A1A1A);
  static const Color lightBg = Color(0xFFFAFAFA);
  static const Color textDark = Color(0xFF2C3E50);
  static const Color textMuted = Color(0xFF8A9BB0);
}

// ─── MODELO DE HOTEL CON UBICACIÓN ──────────────────────────────────────────

class HotelLocation {
  final String id;
  final String name;
  final String address;
  final double rating;
  final double latitude;
  final double longitude;
  final String priceRange;
  final List<String> services;

  const HotelLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.latitude,
    required this.longitude,
    required this.priceRange,
    required this.services,
  });
}

// ─── DATOS DE LA APP ─────────────────────────────────────────────────────────

class AppData {
  /// Hoteles con coordenadas reales en Cuenca, Ecuador
  static const List<HotelLocation> defaultHotels = [
    HotelLocation(
      id: 'h1',
      name: 'Hotel Oro Verde',
      address: 'Av. Ordóñez Lazo, Cuenca',
      rating: 4.8,
      latitude: -2.8968,
      longitude: -79.0234,
      priceRange: '\$\$\$',
      services: ['WiFi', 'Piscina', 'Spa', 'Restaurante'],
    ),
    HotelLocation(
      id: 'h2',
      name: 'Crespo Hotel',
      address: 'Calle Larga 7-93, Cuenca',
      rating: 4.5,
      latitude: -2.8975,
      longitude: -79.0033,
      priceRange: '\$\$',
      services: ['WiFi', 'Bar', 'Terraza'],
    ),
    HotelLocation(
      id: 'h3',
      name: 'Hotel Santa Lucía',
      address: 'Antonio Borrero 8-44, Cuenca',
      rating: 4.7,
      latitude: -2.8985,
      longitude: -79.0045,
      priceRange: '\$\$\$',
      services: ['WiFi', 'Restaurante', 'Sala de reuniones'],
    ),
    HotelLocation(
      id: 'h4',
      name: 'Mansión Alcázar',
      address: 'Bolívar 12-55, Cuenca',
      rating: 4.9,
      latitude: -2.8995,
      longitude: -79.0060,
      priceRange: '\$\$\$\$',
      services: ['WiFi', 'Spa', 'Restaurante gourmet', 'Jardín'],
    ),
    HotelLocation(
      id: 'h5',
      name: 'Hotel El Dorado',
      address: 'Gran Colombia 7-87, Cuenca',
      rating: 4.3,
      latitude: -2.8955,
      longitude: -79.0050,
      priceRange: '\$\$',
      services: ['WiFi', 'Desayuno', 'Parqueadero'],
    ),
  ];

  /// Compat: lista de `HotelRoom` usada por el servicio de BD local
  static List<HotelRoom> get defaultRooms => defaultHotels.map((h) {
        return HotelRoom(
          id: h.id,
          nombre: h.name,
          location: h.address,
          descripcion: '${h.name} - ${h.address}',
          precio: 80.0 + (h.rating - 4.0) * 20.0,
          rating: h.rating,
          fotos: [],
          servicios: h.services,
        );
      }).toList();
}

// ─── ICONOS DE SERVICIOS ─────────────────────────────────────────────────────

class ServiceIcons {
  static IconData forService(String service) {
    switch (service.toLowerCase()) {
      case 'wifi':
        return Icons.wifi_rounded;
      case 'piscina':
        return Icons.pool_rounded;
      case 'spa':
        return Icons.spa_rounded;
      case 'restaurante':
      case 'restaurante gourmet':
        return Icons.restaurant_rounded;
      case 'bar':
        return Icons.local_bar_rounded;
      case 'terraza':
        return Icons.deck_rounded;
      case 'desayuno':
        return Icons.free_breakfast_rounded;
      case 'parqueadero':
        return Icons.local_parking_rounded;
      case 'sala de reuniones':
        return Icons.meeting_room_rounded;
      case 'jardín':
        return Icons.park_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  // Alias para compatibilidad con llamadas anteriores
  static IconData getIcon(String service) => forService(service);
}
