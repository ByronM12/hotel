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
}
