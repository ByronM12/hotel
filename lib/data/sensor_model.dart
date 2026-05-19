import 'dart:math' as math;

enum SensorType { gps, accelerometer, gyroscope }

extension SensorTypeInfo on SensorType {
  String get label {
    switch (this) {
      case SensorType.gps:
        return 'GPS';
      case SensorType.accelerometer:
        return 'Acelerómetro';
      case SensorType.gyroscope:
        return 'Giroscopio';
    }
  }

  String get icon {
    switch (this) {
      case SensorType.gps:
        return '📍';
      case SensorType.accelerometer:
        return '📐';
      case SensorType.gyroscope:
        return '🔄';
    }
  }
}

class SensorReading {
  final int? id;
  final SensorType type;
  final double x;
  final double y;
  final double z;
  final String? hotelId;
  final String nota;
  final DateTime timestamp;

  const SensorReading({
    this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.z,
    this.hotelId,
    this.nota = '',
    required this.timestamp,
  });

  double get latitud => x;
  double get longitud => y;
  double get altitud => z;

  double get magnitud {
    final value = x * x + y * y + z * z;
    return value <= 0 ? 0 : math.sqrt(value);
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'type': type.index,
        'x': x,
        'y': y,
        'z': z,
        'hotel_id': hotelId,
        'nota': nota,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SensorReading.fromMap(Map<String, dynamic> map) => SensorReading(
        id: map['id'] as int?,
        type: SensorType.values[map['type'] as int],
        x: (map['x'] as num).toDouble(),
        y: (map['y'] as num).toDouble(),
        z: (map['z'] as num).toDouble(),
        hotelId: map['hotel_id'] as String?,
        nota: (map['nota'] as String?) ?? '',
        timestamp: DateTime.parse(map['timestamp'] as String),
      );

  SensorReading copyWith({String? nota, String? hotelId}) {
    return SensorReading(
      id: id,
      type: type,
      x: x,
      y: y,
      z: z,
      hotelId: hotelId ?? this.hotelId,
      nota: nota ?? this.nota,
      timestamp: timestamp,
    );
  }
}
