import '../../../../core/app_constants.dart';
import '../../../../data/hotel_model.dart';

class HotelService {
  final List<HotelRoom> _hotels = List.from(AppData.defaultRooms);

  List<HotelRoom> fetchHotels() => List.from(_hotels);

  HotelRoom createHotel({
    required String nombre,
    required String location,
    required String descripcion,
    required double precio,
    required double rating,
    required List<String> servicios,
  }) {
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

    _hotels.insert(0, room);
    return room;
  }

  HotelRoom updateHotel({required int index, required HotelRoom room}) {
    _hotels[index] = room;
    return room;
  }

  HotelRoom deleteHotel(int index) => _hotels.removeAt(index);
}
