import 'dart:convert';

class HotelRoom {
  final String id;
  final String nombre;
  final String location;
  final String descripcion;
  final double precio;
  final double rating;
  final List<String> fotos;
  final List<String> servicios;

  const HotelRoom({
    required this.id,
    required this.nombre,
    required this.location,
    required this.descripcion,
    required this.precio,
    required this.rating,
    required this.fotos,
    required this.servicios,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'location': location,
        'descripcion': descripcion,
        'precio': precio,
        'rating': rating,
        'fotos': jsonEncode(fotos),
        'servicios': jsonEncode(servicios),
      };

  factory HotelRoom.fromMap(Map<String, dynamic> map) {
    final fotosValue = map['fotos'] as String?;
    final serviciosValue = map['servicios'] as String?;

    return HotelRoom(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      location: map['location'] as String,
      descripcion: map['descripcion'] as String,
      precio: (map['precio'] as num).toDouble(),
      rating: (map['rating'] as num).toDouble(),
      fotos: fotosValue == null
          ? []
          : List<String>.from(jsonDecode(fotosValue) as List<dynamic>),
      servicios: serviciosValue == null
          ? []
          : List<String>.from(jsonDecode(serviciosValue) as List<dynamic>),
    );
  }
}
