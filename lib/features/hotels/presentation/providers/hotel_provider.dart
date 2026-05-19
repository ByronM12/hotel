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

  Future<void> initialize() async {
    _rooms = await _service.fetchHotels();
    notifyListeners();
  }

  bool isFavorite(String roomId) => _favorites.any((room) => room.id == roomId);

  Future<void> createHotel({
    required String nombre,
    required String location,
    required String descripcion,
    required double precio,
    required double rating,
    required List<String> servicios,
  }) async {
    await _service.createHotel(
      nombre: nombre,
      location: location,
      descripcion: descripcion,
      precio: precio,
      rating: rating,
      servicios: servicios,
    );

    _rooms = await _service.fetchHotels();
    notifyListeners();
  }

  Future<void> updateHotel({
    required int index,
    required String nombre,
    required String location,
    required String descripcion,
    required double precio,
    required double rating,
    required List<String> servicios,
  }) async {
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

    await _service.updateHotel(index: index, room: updated);
    _rooms = await _service.fetchHotels();

    final favoriteIndex = _favorites.indexWhere((room) => room.id == updated.id);
    if (favoriteIndex != -1) {
      _favorites[favoriteIndex] = updated;
    }

    notifyListeners();
  }

  Future<HotelRoom> deleteHotel(int index) async {
    final removed = await _service.deleteHotel(index);
    _rooms = await _service.fetchHotels();
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
