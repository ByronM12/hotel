import 'package:flutter/material.dart';

import '../../../../data/hotel_model.dart';
import '../../data/services/hotel_service.dart';

class HotelProvider extends ChangeNotifier {
  HotelProvider({required HotelService service}) : _service = service;

  final HotelService _service;

  List<HotelRoom> _rooms = [];
  final List<HotelRoom> _favorites = [];

  List<HotelRoom> get rooms => List.unmodifiable(_rooms);
  List<HotelRoom> get favorites => List.unmodifiable(_favorites);

  void initialize() {
    _rooms = _service.fetchHotels();
    notifyListeners();
  }

  bool isFavorite(String roomId) => _favorites.any((room) => room.id == roomId);

  void createHotel({
    required String nombre,
    required String location,
    required String descripcion,
    required double precio,
    required double rating,
    required List<String> servicios,
  }) {
    _service.createHotel(
      nombre: nombre,
      location: location,
      descripcion: descripcion,
      precio: precio,
      rating: rating,
      servicios: servicios,
    );

    _rooms = _service.fetchHotels();
    notifyListeners();
  }

  void updateHotel({
    required int index,
    required String nombre,
    required String location,
    required String descripcion,
    required double precio,
    required double rating,
    required List<String> servicios,
  }) {
    final current = _rooms[index];
    final updated = HotelRoom(
      id: current.id,
      nombre: nombre,
      location: location,
      descripcion: descripcion,
      precio: precio,
      rating: rating,
      fotos: current.fotos,
      servicios: servicios,
    );

    _service.updateHotel(index: index, room: updated);
    _rooms = _service.fetchHotels();

    final favoriteIndex = _favorites.indexWhere((room) => room.id == updated.id);
    if (favoriteIndex != -1) {
      _favorites[favoriteIndex] = updated;
    }

    notifyListeners();
  }

  HotelRoom deleteHotel(int index) {
    final removed = _service.deleteHotel(index);
    _rooms = _service.fetchHotels();
    _favorites.removeWhere((room) => room.id == removed.id);
    notifyListeners();
    return removed;
  }

  void toggleFavorite(HotelRoom room) {
    final existingIndex = _favorites.indexWhere((item) => item.id == room.id);
    if (existingIndex != -1) {
      _favorites.removeAt(existingIndex);
    } else {
      _favorites.add(room);
    }
    notifyListeners();
  }
}
