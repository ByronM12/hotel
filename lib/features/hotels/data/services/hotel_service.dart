import '../../../../data/hotel_model.dart';
import '../../../../services/database_service.dart';

class HotelService {
  final DatabaseService _db = DatabaseService.instance;

  Future<List<HotelRoom>> fetchHotels() async {
    return _db.fetchHotels();
  }

  Future<HotelRoom> createHotel({
    required String nombre,
    required String location,
    required String descripcion,
    required double precio,
    required double rating,
    required List<String> servicios,
  }) async {
    final room = HotelRoom(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombre,
      location: location,
      descripcion: descripcion,
      precio: precio,
      rating: rating,
      fotos: const [],
      servicios: servicios,
    );
    await _db.insertHotel(room);
    return room;
  }

  Future<HotelRoom> updateHotel({required int index, required HotelRoom room}) async {
    await _db.updateHotel(room);
    return room;
  }

  Future<HotelRoom> deleteHotel(int index) async {
    final rooms = await fetchHotels();
    final removed = rooms[index];
    await _db.deleteHotel(removed.id);
    return removed;
  }

  Future<Set<String>> fetchFavoriteIds() => _db.fetchFavoriteIds();
  Future<void> addFavorite(String hotelId) => _db.addFavorite(hotelId);
  Future<void> removeFavorite(String hotelId) => _db.removeFavorite(hotelId);
}
