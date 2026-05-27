import 'package:flutter/material.dart';

import '../../../../data/hotel_model.dart';
import '../../data/services/hotel_service.dart';

class HotelProvider extends ChangeNotifier {
  HotelProvider({required HotelService service}) : _service = service;

  final HotelService _service;

  List<HotelRoom> _rooms = [];
  Set<String> _favoriteIds = {};

  List<HotelRoom> get rooms => List.unmodifiable(_rooms);
  List<HotelRoom> get favorites =>
      _rooms.where((room) => _favoriteIds.contains(room.id)).toList();

  Future<void> initialize() async {
    _rooms = await _service.fetchHotels();
    _favoriteIds = await _service.fetchFavoriteIds();
    notifyListeners();
  }

  bool isFavorite(String roomId) => _favoriteIds.contains(roomId);

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
    notifyListeners();
  }

  Future<HotelRoom> deleteHotel(int index) async {
    final removed = await _service.deleteHotel(index);
    _rooms = await _service.fetchHotels();
    if (_favoriteIds.remove(removed.id)) {
      await _service.removeFavorite(removed.id);
    }
    notifyListeners();
    return removed;
  }

  Future<void> toggleFavorite(HotelRoom room) async {
    if (_favoriteIds.contains(room.id)) {
      _favoriteIds.remove(room.id);
      await _service.removeFavorite(room.id);
    } else {
      _favoriteIds.add(room.id);
      await _service.addFavorite(room.id);
    }
    notifyListeners();
  }
}
