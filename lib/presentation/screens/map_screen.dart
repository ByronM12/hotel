//
// Pantalla de mapa con:
//  - Visualización OpenStreetMap (flutter_map, sin API key)
//  - Ubicación actual del usuario con marcador animado
//  - Marcadores de hoteles del catálogo
//  - Historial de ruta como polilínea
//  - Panel de información con coordenadas y estado en tiempo real
//  - Sincronización con Firebase Realtime Database

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/app_constants.dart';
import '../providers/map_provider.dart';
import '../../data/models/location_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Animación de pulso para el marcador de usuario
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Iniciar rastreo tras primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ─── Centrar mapa en ubicación actual ──────────────────────────────────

  void _centerOnUser(LocationModel location) {
    _mapController.move(
      LatLng(location.latitude, location.longitude),
      15.0,
    );
  }

  // ─── Build principal ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: Consumer<MapProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              // 1. Mapa principal
              _buildMap(provider),

              // 2. Header luxury superpuesto
              _buildHeader(context),

              // 3. Panel inferior de información
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildInfoPanel(provider),
              ),

              // 4. Botones flotantes
              Positioned(
                right: 16,
                bottom: 220,
                child: _buildFloatingButtons(provider),
              ),

              // 5. Estado de carga / permisos
              if (provider.status == TrackingStatus.requesting)
                _buildLoadingOverlay(),
              if (provider.status == TrackingStatus.permissionDenied)
                _buildPermissionDenied(provider),
            ],
          );
        },
      ),
    );
  }

  // ─── MAPA ─────────────────────────────────────────────────────────────────

  Widget _buildMap(MapProvider provider) {
    final location = provider.currentLocation;
    final LatLng center = location != null
        ? LatLng(location.latitude, location.longitude)
        : const LatLng(-2.9001, -79.0059); // Cuenca, Ecuador por defecto

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 14.0,
        onMapReady: provider.setMapReady,
      ),
      children: [
        // Capa base OpenStreetMap (gratuita, sin API key)
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.hotel',
        ),

        // Polilínea del historial de movimiento
        if (provider.showHistory && provider.locationHistory.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(
                points: provider.locationHistory
                    .map((l) => LatLng(l.latitude, l.longitude))
                    .toList(),
                color: AppColors.gold.withValues(alpha: 0.8),
                strokeWidth: 3.5,
              ),
            ],
          ),

        // Marcadores de hoteles del catálogo
        MarkerLayer(markers: _buildHotelMarkers()),

        // Marcador del usuario
        if (location != null)
          MarkerLayer(
            markers: [_buildUserMarker(location)],
          ),
      ],
    );
  }

  // Marcador animado del usuario
  Marker _buildUserMarker(LocationModel location) {
    return Marker(
      point: LatLng(location.latitude, location.longitude),
      width: 60,
      height: 60,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Anillo de pulso
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold.withValues(alpha: 0.25),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                ),
              ),
              // Punto central
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Marcadores de hoteles
  List<Marker> _buildHotelMarkers() {
    return AppData.defaultHotels.map((hotel) {
      return Marker(
        point: LatLng(hotel.latitude, hotel.longitude),
        width: 48,
        height: 56,
        child: GestureDetector(
          onTap: () => _showHotelInfo(hotel),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.darkCharcoal,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.hotel_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              // Punta del pin
              Container(
                width: 2,
                height: 8,
                color: AppColors.darkCharcoal,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _showHotelInfo(HotelLocation hotel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.darkCharcoal,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.hotel_rounded, color: AppColors.gold),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hotel.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                  Text(hotel.address,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.6), fontSize: 13)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '★ ${hotel.rating}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── HEADER ───────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mapa en tiempo real',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Text(
                      'Hoteles Cercanos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Indicador de sincronización Firebase
                Consumer<MapProvider>(
                  builder: (_, provider, __) => _buildSyncBadge(provider),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSyncBadge(MapProvider provider) {
    final isTracking = provider.isTracking;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isTracking
            ? Colors.green.withOpacity(0.9)
            : Colors.orange.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isTracking ? Colors.white : Colors.white70,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isTracking ? 'LIVE' : 'OFF',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ─── PANEL INFERIOR ───────────────────────────────────────────────────────

  Widget _buildInfoPanel(MapProvider provider) {
    final location = provider.currentLocation;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCharcoal,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Coordenadas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildCoordCard(
                  'LATITUD',
                  location != null
                      ? location.latitude.toStringAsFixed(6)
                      : '---',
                  Icons.my_location_rounded,
                ),
                const SizedBox(width: 12),
                _buildCoordCard(
                  'LONGITUD',
                  location != null
                      ? location.longitude.toStringAsFixed(6)
                      : '---',
                  Icons.explore_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Stats secundarias
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildStatChip(
                  Icons.radar_rounded,
                  location?.accuracy != null
                      ? '±${location!.accuracy!.toStringAsFixed(0)}m'
                      : '---',
                  'Precisión',
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  Icons.speed_rounded,
                  location?.speed != null
                      ? '${(location!.speed! * 3.6).toStringAsFixed(1)} km/h'
                      : '---',
                  'Velocidad',
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  Icons.update_rounded,
                  '${provider.updateCount}',
                  'Actualizaciones',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Última actualización
          if (location != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 14, color: AppColors.gold),
                  const SizedBox(width: 6),
                  Text(
                    'Última actualización: ${DateFormat('HH:mm:ss').format(location.timestamp)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  // Estado Firebase
                  Row(
                    children: [
                      const Icon(Icons.cloud_done_rounded,
                          size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'Firebase sync',
                        style: TextStyle(
                          color: Colors.green.withOpacity(0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCoordCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.gold),
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                        letterSpacing: 1)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: AppColors.gold),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4), fontSize: 9)),
          ],
        ),
      ),
    );
  }

  // ─── BOTONES FLOTANTES ────────────────────────────────────────────────────

  Widget _buildFloatingButtons(MapProvider provider) {
    return Column(
      children: [
        // Centrar en usuario
        _fabButton(
          icon: Icons.my_location_rounded,
          color: AppColors.gold,
          onTap: () {
            if (provider.currentLocation != null) {
              _centerOnUser(provider.currentLocation!);
            }
          },
        ),
        const SizedBox(height: 10),
        // Toggle historial de ruta
        _fabButton(
          icon: provider.showHistory
              ? Icons.route_rounded
              : Icons.timeline_rounded,
          color: provider.showHistory
              ? AppColors.gold
              : Colors.white.withOpacity(0.8),
          onTap: provider.toggleHistory,
          tooltip: 'Ver ruta',
        ),
        const SizedBox(height: 10),
        // Pausar / reanudar rastreo
        _fabButton(
          icon: provider.isTracking
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          color: provider.isTracking ? Colors.redAccent : Colors.greenAccent,
          onTap: () {
            if (provider.isTracking) {
              provider.stopTracking();
            } else {
              provider.restartTracking();
            }
          },
        ),
      ],
    );
  }

  Widget _fabButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.darkCharcoal,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  // ─── OVERLAY CARGA ────────────────────────────────────────────────────────

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.darkCharcoal,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.gold),
              const SizedBox(height: 16),
              const Text('Obteniendo ubicación...',
                  style: TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionDenied(MapProvider provider) {
    return Container(
      color: AppColors.darkCharcoal.withOpacity(0.95),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_off_rounded, color: AppColors.gold, size: 64),
              const SizedBox(height: 20),
              const Text(
                'Permisos de ubicación\nrequeridos',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                'Para mostrar hoteles cercanos y rastrear tu posición, activa los permisos de ubicación en Ajustes.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: provider.restartTracking,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
