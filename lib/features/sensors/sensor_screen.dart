import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/sensor_model.dart';
import 'sensor_provider.dart';

class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});

  @override
  State<SensorScreen> createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SensorProvider>().loadAllHistory();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        title: const Text(
          'SENSORES',
          style: TextStyle(
            letterSpacing: 3,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: const Color(0xFFD4AF37),
          labelColor: const Color(0xFFD4AF37),
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.location_on), text: 'GPS'),
            Tab(icon: Icon(Icons.speed), text: 'Aceleróm.'),
            Tab(icon: Icon(Icons.rotate_right), text: 'Giroscopio'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _GpsTab(),
          _MotionTab(type: SensorType.accelerometer),
          _MotionTab(type: SensorType.gyroscope),
        ],
      ),
    );
  }
}

class _GpsTab extends StatelessWidget {
  const _GpsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorProvider>(
      builder: (context, prov, _) {
        final last = prov.lastGps;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StatusCard(
              icon: Icons.location_on,
              color: const Color(0xFF1565C0),
              title: 'GPS — Ubicación actual',
              status: prov.gpsStatus,
              isActive: prov.isCapturingGps,
              child: last == null
                  ? const Text('Sin datos aún',
                      style: TextStyle(color: Colors.grey))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DataRow('Latitud', '${last.latitud.toStringAsFixed(6)}°'),
                        _DataRow('Longitud', '${last.longitud.toStringAsFixed(6)}°'),
                        _DataRow('Altitud', '${last.altitud.toStringAsFixed(1)} m'),
                        _DataRow('Hora',
                            DateFormat('HH:mm:ss').format(last.timestamp)),
                      ],
                    ),
              actions: Row(
                children: [
                  Expanded(
                    child: _SensorButton(
                      label: prov.isCapturingGps ? 'Detener' : 'Iniciar seguimiento',
                      icon: prov.isCapturingGps
                          ? Icons.stop_circle_outlined
                          : Icons.play_circle_outline,
                      isActive: prov.isCapturingGps,
                      onTap: () => prov.isCapturingGps ? prov.stopGps() : prov.startGps(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SensorButton(
                      label: 'Captura única',
                      icon: Icons.my_location,
                      isActive: false,
                      onTap: () => prov.captureGpsOnce(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _HistoryCard(
              title: 'Historial GPS',
              readings: prov.gpsHistory,
              type: SensorType.gps,
              onDelete: (id) => prov.deleteReading(id, SensorType.gps),
              onClear: () => _confirmClear(context, prov, SensorType.gps),
              rowBuilder: (r) =>
                  '${r.latitud.toStringAsFixed(5)}, ${r.longitud.toStringAsFixed(5)} | ${r.altitud.toStringAsFixed(0)} m',
            ),
          ],
        );
      },
    );
  }
}

class _MotionTab extends StatelessWidget {
  final SensorType type;

  const _MotionTab({required this.type});

  bool get isAccel => type == SensorType.accelerometer;

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorProvider>(
      builder: (context, prov, _) {
        final last = isAccel ? prov.lastAccel : prov.lastGyro;
        final isCapt = isAccel ? prov.isCapturingAccel : prov.isCapturingGyro;
        final status = isAccel ? prov.accelStatus : prov.gyroStatus;
        final history = isAccel ? prov.accelHistory : prov.gyroHistory;
        final color = isAccel ? const Color(0xFF880E4F) : const Color(0xFF2E7D32);
        final unit = isAccel ? 'm/s²' : 'rad/s';

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StatusCard(
              icon: isAccel ? Icons.speed : Icons.rotate_right,
              color: color,
              title: '${type.label} — Tiempo real',
              status: status,
              isActive: isCapt,
              child: last == null
                  ? const Text('Sin datos aún',
                      style: TextStyle(color: Colors.grey))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DataRow('X', '${last.x.toStringAsFixed(3)} $unit'),
                        _DataRow('Y', '${last.y.toStringAsFixed(3)} $unit'),
                        _DataRow('Z', '${last.z.toStringAsFixed(3)} $unit'),
                        _DataRow('Magnitud',
                            '${last.magnitud.toStringAsFixed(3)} $unit'),
                      ],
                    ),
              actions: _SensorButton(
                label: isCapt ? 'Detener captura' : 'Iniciar captura',
                icon: isCapt ? Icons.stop_circle_outlined : Icons.play_circle_outline,
                isActive: isCapt,
                onTap: () {
                  if (isCapt) {
                    if (isAccel) {
                      prov.stopAccelerometer();
                    } else {
                      prov.stopGyroscope();
                    }
                  } else {
                    if (isAccel) {
                      prov.startAccelerometer();
                    } else {
                      prov.startGyroscope();
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            if (history.isNotEmpty) _ChartCard(readings: history, color: color),
            const SizedBox(height: 16),
            _HistoryCard(
              title: 'Historial ${type.label}',
              readings: history,
              type: type,
              onDelete: (id) => prov.deleteReading(id, type),
              onClear: () => _confirmClear(context, prov, type),
              rowBuilder: (r) =>
                  'x:${r.x.toStringAsFixed(2)} y:${r.y.toStringAsFixed(2)} z:${r.z.toStringAsFixed(2)} $unit',
            ),
          ],
        );
      },
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String status;
  final bool isActive;
  final Widget child;
  final Widget actions;

  const _StatusCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.status,
    required this.isActive,
    required this.child,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive ? Colors.green : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              status,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            child,
            const SizedBox(height: 14),
            actions,
          ],
        ),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;

  const _DataRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SensorButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _SensorButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.red[700] : const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final List<SensorReading> readings;
  final Color color;

  const _ChartCard({required this.readings, required this.color});

  @override
  Widget build(BuildContext context) {
    final data = readings.reversed.take(20).toList();
    if (data.isEmpty) return const SizedBox();

    final spots = List.generate(data.length, (i) {
      return FlSpot(i.toDouble(), double.parse(data[i].magnitud.toStringAsFixed(2)));
    });

    final maxY = spots.fold<double>(0, (prev, spot) => spot.y > prev ? spot.y : prev);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Magnitud — últimas lecturas',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY * 1.3,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, _) => Text(
                          value.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 2.5,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String title;
  final List<SensorReading> readings;
  final SensorType type;
  final void Function(int id) onDelete;
  final VoidCallback onClear;
  final String Function(SensorReading) rowBuilder;

  const _HistoryCard({
    required this.title,
    required this.readings,
    required this.type,
    required this.onDelete,
    required this.onClear,
    required this.rowBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                Text('${readings.length} registros',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                if (readings.isNotEmpty)
                  TextButton(
                    onPressed: onClear,
                    child: const Text('Limpiar',
                        style: TextStyle(color: Colors.red, fontSize: 12)),
                  ),
              ],
            ),
            if (readings.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text('Sin registros guardados',
                      style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: readings.length > 10 ? 10 : readings.length,
                separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5),
                itemBuilder: (ctx, i) {
                  final r = readings[i];
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    leading: Text(type.icon, style: const TextStyle(fontSize: 20)),
                    title: Text(rowBuilder(r), style: const TextStyle(fontSize: 12)),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy HH:mm:ss').format(r.timestamp),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                      onPressed: () => onDelete(r.id!),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmClear(
    BuildContext context, SensorProvider prov, SensorType type) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Limpiar historial de ${type.label}'),
      content: const Text('¿Eliminar todos los registros guardados?'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
  if (ok == true) prov.clearAll(type);
}
