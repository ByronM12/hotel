import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../data/sensor_model.dart';
import '../../services/database_service.dart';

class SensorProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  SensorReading? lastGps;
  SensorReading? lastAccel;
  SensorReading? lastGyro;

  bool isCapturingGps = false;
  bool isCapturingAccel = false;
  bool isCapturingGyro = false;

  String gpsStatus = 'Inactivo';
  String accelStatus = 'Inactivo';
  String gyroStatus = 'Inactivo';

  List<SensorReading> gpsHistory = [];
  List<SensorReading> accelHistory = [];
  List<SensorReading> gyroHistory = [];

  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  Timer? _gpsTimer;

  Future<void> startGps({String? hotelId, String nota = ''}) async {
    if (isCapturingGps) return;

    final permission = await _checkLocationPermission();
    if (!permission) {
      gpsStatus = 'Permiso denegado';
      notifyListeners();
      return;
    }

    isCapturingGps = true;
    gpsStatus = 'Obteniendo ubicación…';
    notifyListeners();

    await _captureGps(hotelId: hotelId, nota: nota);
    _gpsTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _captureGps(hotelId: hotelId, nota: nota);
    });
  }

  Future<void> stopGps() async {
    _gpsTimer?.cancel();
    _gpsTimer = null;
    isCapturingGps = false;
    gpsStatus = 'Detenido';
    notifyListeners();
  }

  Future<void> captureGpsOnce({String? hotelId, String nota = ''}) async {
    final permission = await _checkLocationPermission();
    if (!permission) {
      gpsStatus = 'Permiso denegado';
      notifyListeners();
      return;
    }

    gpsStatus = 'Capturando…';
    notifyListeners();
    await _captureGps(hotelId: hotelId, nota: nota);
  }

  Future<void> _captureGps({String? hotelId, String nota = ''}) async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final reading = SensorReading(
        type: SensorType.gps,
        x: pos.latitude,
        y: pos.longitude,
        z: pos.altitude,
        hotelId: hotelId,
        nota: nota,
        timestamp: DateTime.now(),
      );
      await _db.insertReading(reading);
      lastGps = reading;
      gpsStatus = 'Lat: ${pos.latitude.toStringAsFixed(5)}, '
          'Lng: ${pos.longitude.toStringAsFixed(5)}';
      await loadHistory(SensorType.gps);
    } catch (e) {
      gpsStatus = 'Error: $e';
      debugPrint('GPS error: $e');
    }
    notifyListeners();
  }

  void startAccelerometer({String? hotelId, String nota = ''}) {
    if (isCapturingAccel) return;
    isCapturingAccel = true;
    accelStatus = 'Capturando…';
    notifyListeners();

    var count = 0;
    _accelSub = accelerometerEvents.listen((event) async {
      count++;
      if (count % 5 == 0) {
        final reading = SensorReading(
          type: SensorType.accelerometer,
          x: event.x,
          y: event.y,
          z: event.z,
          hotelId: hotelId,
          nota: nota,
          timestamp: DateTime.now(),
        );
        await _db.insertReading(reading);
        lastAccel = reading;
        accelStatus = 'x:${event.x.toStringAsFixed(2)} '
            'y:${event.y.toStringAsFixed(2)} '
            'z:${event.z.toStringAsFixed(2)}';
        await loadHistory(SensorType.accelerometer);
        notifyListeners();
      } else {
        lastAccel = SensorReading(
          type: SensorType.accelerometer,
          x: event.x,
          y: event.y,
          z: event.z,
          timestamp: DateTime.now(),
        );
        accelStatus = 'x:${event.x.toStringAsFixed(2)} '
            'y:${event.y.toStringAsFixed(2)} '
            'z:${event.z.toStringAsFixed(2)}';
        notifyListeners();
      }
    });
  }

  Future<void> stopAccelerometer() async {
    await _accelSub?.cancel();
    _accelSub = null;
    isCapturingAccel = false;
    accelStatus = 'Detenido';
    notifyListeners();
  }

  void startGyroscope({String? hotelId, String nota = ''}) {
    if (isCapturingGyro) return;
    isCapturingGyro = true;
    gyroStatus = 'Capturando…';
    notifyListeners();

    var count = 0;
    _gyroSub = gyroscopeEvents.listen((event) async {
      count++;
      if (count % 5 == 0) {
        final reading = SensorReading(
          type: SensorType.gyroscope,
          x: event.x,
          y: event.y,
          z: event.z,
          hotelId: hotelId,
          nota: nota,
          timestamp: DateTime.now(),
        );
        await _db.insertReading(reading);
        lastGyro = reading;
        gyroStatus = 'x:${event.x.toStringAsFixed(2)} '
            'y:${event.y.toStringAsFixed(2)} '
            'z:${event.z.toStringAsFixed(2)}';
        await loadHistory(SensorType.gyroscope);
        notifyListeners();
      } else {
        lastGyro = SensorReading(
          type: SensorType.gyroscope,
          x: event.x,
          y: event.y,
          z: event.z,
          timestamp: DateTime.now(),
        );
        gyroStatus = 'x:${event.x.toStringAsFixed(2)} '
            'y:${event.y.toStringAsFixed(2)} '
            'z:${event.z.toStringAsFixed(2)}';
        notifyListeners();
      }
    });
  }

  Future<void> stopGyroscope() async {
    await _gyroSub?.cancel();
    _gyroSub = null;
    isCapturingGyro = false;
    gyroStatus = 'Detenido';
    notifyListeners();
  }

  Future<void> loadHistory(SensorType type) async {
    final data = await _db.fetchReadings(type: type, limit: 50);
    switch (type) {
      case SensorType.gps:
        gpsHistory = data;
        break;
      case SensorType.accelerometer:
        accelHistory = data;
        break;
      case SensorType.gyroscope:
        gyroHistory = data;
        break;
    }
  }

  Future<void> loadAllHistory() async {
    gpsHistory = await _db.fetchReadings(type: SensorType.gps, limit: 50);
    accelHistory = await _db.fetchReadings(type: SensorType.accelerometer, limit: 50);
    gyroHistory = await _db.fetchReadings(type: SensorType.gyroscope, limit: 50);
    notifyListeners();
  }

  Future<void> deleteReading(int id, SensorType type) async {
    await _db.deleteReading(id);
    await loadHistory(type);
    notifyListeners();
  }

  Future<void> clearAll(SensorType type) async {
    await _db.deleteAllReadings(type: type);
    await loadHistory(type);
    notifyListeners();
  }

  Future<bool> _checkLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  void stopAll() {
    stopGps();
    stopAccelerometer();
    stopGyroscope();
  }

  @override
  void dispose() {
    stopAll();
    super.dispose();
  }
}
