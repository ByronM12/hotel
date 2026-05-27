import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/location_model.dart';
import '../../data/services/location_service.dart';
import '../../data/services/firebase_location_service.dart';

enum TrackingStatus { idle, requesting, tracking, error, permissionDenied }

class MapProvider extends ChangeNotifier {
  final LocationService _locationService;
  final FirebaseLocationService _firebaseService;

  MapProvider({
    required LocationService locationService,
    required FirebaseLocationService firebaseService,
  })  : _locationService = locationService,
        _firebaseService = firebaseService;

  // ─── Estado ──────────────────────────────────────────────────────────────

  TrackingStatus _status = TrackingStatus.idle;
  TrackingStatus get status => _status;

  LocationModel? _currentLocation;
  LocationModel? get currentLocation => _currentLocation;

  List<LocationModel> _locationHistory = [];
  List<LocationModel> get locationHistory => _locationHistory;

  bool _showHistory = false;
  bool get showHistory => _showHistory;

  bool _isMapReady = false;
  bool get isMapReady => _isMapReady;

  int _updateCount = 0;
  int get updateCount => _updateCount;

  StreamSubscription<LocationModel>? _locationSub;
  StreamSubscription<List<LocationModel>>? _historySub;

  // ─── Acciones ────────────────────────────────────────────────────────────

  /// Inicializa el provider: pide permisos y empieza rastreo.
  Future<void> initialize() async {
    _setStatus(TrackingStatus.requesting);

    final started = await _locationService.startTracking();

    if (!started) {
      _setStatus(TrackingStatus.permissionDenied);
      return;
    }

    // Obtener posición inicial
    final initial = await _locationService.getCurrentLocation();
    if (initial != null) {
      _currentLocation = initial;
      await _firebaseService.updateCurrentLocation(initial);
      notifyListeners();
    }

    // Escuchar stream de posición
    _locationSub = _locationService.locationStream.listen((location) async {
      _currentLocation = location;
      _updateCount++;

      // Sincronizar con Firebase
      await _firebaseService.updateCurrentLocation(location);
      await _firebaseService.pushLocationHistory(location);

      notifyListeners();
    });

    // Escuchar historial desde Firebase
    _historySub =
        _firebaseService.watchLocationHistory().listen((history) {
      _locationHistory = history;
      notifyListeners();
    });

    _setStatus(TrackingStatus.tracking);
  }

  void setMapReady() {
    _isMapReady = true;
    notifyListeners();
  }

  void toggleHistory() {
    _showHistory = !_showHistory;
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _firebaseService.clearHistory();
    _locationHistory = [];
    notifyListeners();
  }

  Future<void> stopTracking() async {
    _locationService.stopTracking();
    _locationSub?.cancel();
    _historySub?.cancel();
    _setStatus(TrackingStatus.idle);
  }

  Future<void> restartTracking() async {
    await stopTracking();
    await initialize();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  void _setStatus(TrackingStatus status) {
    _status = status;
    notifyListeners();
  }

  String get statusLabel {
    switch (_status) {
      case TrackingStatus.idle:
        return 'Inactivo';
      case TrackingStatus.requesting:
        return 'Solicitando permisos...';
      case TrackingStatus.tracking:
        return 'Rastreando en tiempo real';
      case TrackingStatus.error:
        return 'Error de GPS';
      case TrackingStatus.permissionDenied:
        return 'Permisos denegados';
    }
  }

  bool get isTracking => _status == TrackingStatus.tracking;

  @override
  void dispose() {
    _locationSub?.cancel();
    _historySub?.cancel();
    _locationService.dispose();
    super.dispose();
  }
}
