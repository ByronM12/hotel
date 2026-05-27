import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/location_model.dart';

/// Servicio de ubicación en Firebase con modo degradado.
/// Si Firebase no está configurado, todas las operaciones son no-ops silenciosos.
class FirebaseLocationService {
  final String userId;
  final bool available;

  FirebaseLocationService({
    required this.userId,
    this.available = true,
  });

  static const String _basePath = 'user_locations';

  DatabaseReference? get _userRef {
    if (!available) return null;
    try {
      return FirebaseDatabase.instance.ref('$_basePath/$userId');
    } catch (e) {
      debugPrint('FirebaseLocationService: $e');
      return null;
    }
  }

  Future<void> updateCurrentLocation(LocationModel location) async {
    final ref = _userRef;
    if (ref == null) return;
    try {
      await ref.child('current').set(location.toMap());
    } catch (e) {
      debugPrint('Firebase updateCurrentLocation: $e');
    }
  }

  Future<void> pushLocationHistory(LocationModel location) async {
    final ref = _userRef;
    if (ref == null) return;
    try {
      await ref.child('history').push().set(location.toMap());
    } catch (e) {
      debugPrint('Firebase pushLocationHistory: $e');
    }
  }

  Stream<LocationModel?> watchCurrentLocation() {
    final ref = _userRef;
    if (ref == null) return const Stream.empty();
    return ref.child('current').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return null;
      try {
        return LocationModel.fromMap(data as Map<dynamic, dynamic>);
      } catch (_) {
        return null;
      }
    });
  }

  Stream<List<LocationModel>> watchLocationHistory({int limit = 50}) {
    final ref = _userRef;
    if (ref == null) return Stream.value([]);
    return ref.child('history').limitToLast(limit).onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return <LocationModel>[];
      try {
        final map = data as Map<dynamic, dynamic>;
        return map.values
            .map((v) => LocationModel.fromMap(v as Map<dynamic, dynamic>))
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      } catch (_) {
        return <LocationModel>[];
      }
    });
  }

  Future<void> clearHistory() async {
    final ref = _userRef;
    if (ref == null) return;
    try {
      await ref.child('history').remove();
    } catch (e) {
      debugPrint('Firebase clearHistory: $e');
    }
  }
}
