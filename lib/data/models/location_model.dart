class LocationModel {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? speed;
  final DateTime timestamp;
  final String? hotelId; // hotel más cercano detectado (opcional)

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.speed,
    required this.timestamp,
    this.hotelId,
  });

  /// Convierte a Map para guardar en Firebase Realtime Database
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'speed': speed,
      'timestamp': timestamp.toIso8601String(),
      'hotelId': hotelId,
    };
  }

  /// Crea desde snapshot de Firebase
  factory LocationModel.fromMap(Map<dynamic, dynamic> map) {
    return LocationModel(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      accuracy: map['accuracy'] != null
          ? (map['accuracy'] as num).toDouble()
          : null,
      speed: map['speed'] != null ? (map['speed'] as num).toDouble() : null,
      timestamp: DateTime.parse(map['timestamp'] as String),
      hotelId: map['hotelId'] as String?,
    );
  }

  LocationModel copyWith({
    double? latitude,
    double? longitude,
    double? accuracy,
    double? speed,
    DateTime? timestamp,
    String? hotelId,
  }) {
    return LocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      speed: speed ?? this.speed,
      timestamp: timestamp ?? this.timestamp,
      hotelId: hotelId ?? this.hotelId,
    );
  }

  @override
  String toString() =>
      'LocationModel(lat: $latitude, lng: $longitude, ts: $timestamp)';
}
