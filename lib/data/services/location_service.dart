import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../models/location_model.dart';

class LocationService {
  // Configuración de precisión alta para rastreo de usuario
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10, // actualizar cada 10 metros de movimiento
  );

  StreamSubscription<Position>? _positionSubscription;
  final StreamController<LocationModel> _locationController =
      StreamController<LocationModel>.broadcast();

  Stream<LocationModel> get locationStream => _locationController.stream;

  // ─── Permisos ────────────────────────────────────────────────────────────

  /// Verifica y solicita permisos de ubicación.
  /// Retorna true si se tienen permisos suficientes.
  Future<bool> checkAndRequestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false; // GPS apagado en el dispositivo
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false; // El usuario negó permanentemente
    }

    return true;
  }

  // ─── Ubicación única ─────────────────────────────────────────────────────

  /// Obtiene la posición actual una sola vez.
  Future<LocationModel?> getCurrentLocation() async {
    final hasPermission = await checkAndRequestPermissions();
    if (!hasPermission) return null;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      );
      return _positionToModel(position);
    } catch (e) {
      return null;
    }
  }

  // ─── Stream en tiempo real ───────────────────────────────────────────────

  /// Inicia el rastreo de ubicación en tiempo real.
  Future<bool> startTracking() async {
    final hasPermission = await checkAndRequestPermissions();
    if (!hasPermission) return false;

    _positionSubscription?.cancel();

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: _locationSettings)
            .listen(
      (Position position) {
        final model = _positionToModel(position);
        if (!_locationController.isClosed) {
          _locationController.add(model);
        }
      },
      onError: (error) {
        // silenciosamente ignorar errores de stream
      },
    );

    return true;
  }

  /// Detiene el rastreo de ubicación.
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  // ─── Utilidades ──────────────────────────────────────────────────────────

  LocationModel _positionToModel(Position position) {
    return LocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      speed: position.speed,
      timestamp: position.timestamp,
    );
  }

  /// Calcula distancia en metros entre dos puntos.
  double distanceBetween(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  void dispose() {
    stopTracking();
    _locationController.close();
  }
}
