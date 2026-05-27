import 'package:firebase_database/firebase_database.dart';
import '../models/location_model.dart';

class FirebaseLocationService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  // Ruta en la base de datos: /user_locations/{userId}/
  static const String _basePath = 'user_locations';

  // ID de sesión del usuario (en producción usar Firebase Auth UID)
  final String userId;

  FirebaseLocationService({required this.userId});

  DatabaseReference get _userRef => _db.ref('$_basePath/$userId');

  // ─── Guardar ubicación actual ─────────────────────────────────────────

  /// Sube la ubicación actual a Firebase (sobrescribe la anterior).
  Future<void> updateCurrentLocation(LocationModel location) async {
    try {
      await _userRef.child('current').set(location.toMap());
    } catch (e) {
      // En modo sin conexión Firebase guarda en caché local automáticamente
    }
  }

  /// Guarda un punto del historial de movimiento.
  Future<void> pushLocationHistory(LocationModel location) async {
    try {
      await _userRef.child('history').push().set(location.toMap());
    } catch (e) {
      // Firebase maneja la persistencia offline automáticamente
    }
  }

  // ─── Escuchar cambios en tiempo real ─────────────────────────────────

  /// Stream que escucha la ubicación actual en tiempo real desde Firebase.
  Stream<LocationModel?> watchCurrentLocation() {
    return _userRef.child('current').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return null;
      return LocationModel.fromMap(data as Map<dynamic, dynamic>);
    });
  }

  /// Escucha el historial de ubicaciones (últimas N entradas).
  Stream<List<LocationModel>> watchLocationHistory({int limit = 50}) {
    return _userRef
        .child('history')
        .limitToLast(limit)
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];

      final map = data as Map<dynamic, dynamic>;
      return map.values
          .map((v) => LocationModel.fromMap(v as Map<dynamic, dynamic>))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });
  }

  // ─── Limpiar datos ────────────────────────────────────────────────────

  Future<void> clearHistory() async {
    await _userRef.child('history').remove();
  }
}
