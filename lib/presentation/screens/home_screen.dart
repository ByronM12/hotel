import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_constants.dart';
import '../../features/hotels/data/services/hotel_service.dart';
import '../../features/hotels/presentation/controllers/home_lifecycle_controller.dart';
import '../../features/hotels/presentation/logic/hotel_form_logic.dart';
import '../../features/hotels/presentation/providers/hotel_provider.dart';
import '../../features/hotels/presentation/widgets/hotel_form_sheet.dart';
import '../../features/sensors/sensor_provider.dart';
import '../../features/sensors/sensor_screen.dart';
import '../../screens/gallery_screen.dart';
import 'map_screen.dart';
import 'detail_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import '../widgets/room_card_luxury.dart';
import '../widgets/floating_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final PageController _pageController;
  late final HotelProvider _hotelProvider;
  late final HomeLifecycleController _lifecycleController;
  double _currentPage = 0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  
  final Map<String, TextEditingController> _formControllers = {
    'nombre': TextEditingController(),
    'ubicacion': TextEditingController(),
    'descripcion': TextEditingController(),
    'precio': TextEditingController(),
    'rating': TextEditingController(),
    'servicios': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _hotelProvider = HotelProvider(service: HotelService())
      ..addListener(_onHotelsChanged)
      ..initialize();

    _lifecycleController = HomeLifecycleController(onMessage: _showLifecycleMessage)
      ..attach();

    _pageController = PageController(viewportFraction: 0.88)
      ..addListener(() {
        if (mounted) setState(() => _currentPage = _pageController.page ?? 0);
      });

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _lifecycleController.notifyAppStarted());
  }

  void _onHotelsChanged() {
    if (mounted) setState(() {});
  }

  void _showLifecycleMessage(String text) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          duration: const Duration(milliseconds: 1000),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  void dispose() {
    _lifecycleController.detach();
    _hotelProvider
      ..removeListener(_onHotelsChanged)
      ..dispose();
    _pageController.dispose();
    for (var controller in _formControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _showHotelSheet({int? editingIndex}) async {
    final rooms = _hotelProvider.rooms;
    final bool isEditing = editingIndex != null;

    if (isEditing) {
      final room = rooms[editingIndex];
      _formControllers['nombre']!.text = room.nombre;
      _formControllers['ubicacion']!.text = room.location;
      _formControllers['descripcion']!.text = room.descripcion;
      _formControllers['precio']!.text = room.precio.toStringAsFixed(0);
      _formControllers['rating']!.text = room.rating.toStringAsFixed(1);
      _formControllers['servicios']!.text = room.servicios.join(', ');
    } else {
      for (var controller in _formControllers.values) {
        controller.clear();
      }
    }

    await showHotelFormSheet(
      context: context,
      formKey: _formKey,
      controllers: _formControllers,
      isEditing: isEditing,
      onSubmit: () => _saveHotel(editingIndex: editingIndex),
    );
  }

  Future<void> _saveHotel({int? editingIndex}) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final services =
        HotelFormLogic.parseServices(_formControllers['servicios']!.text);

    if (editingIndex == null) {
      await _hotelProvider.createHotel(
        nombre: _formControllers['nombre']!.text.trim(),
        location: _formControllers['ubicacion']!.text.trim(),
        descripcion: _formControllers['descripcion']!.text.trim(),
        precio: double.parse(_formControllers['precio']!.text.trim()),
        rating: double.parse(_formControllers['rating']!.text.trim()),
        servicios: services,
      );
    } else {
      await _hotelProvider.updateHotel(
        index: editingIndex,
        nombre: _formControllers['nombre']!.text.trim(),
        location: _formControllers['ubicacion']!.text.trim(),
        descripcion: _formControllers['descripcion']!.text.trim(),
        precio: double.parse(_formControllers['precio']!.text.trim()),
        rating: double.parse(_formControllers['rating']!.text.trim()),
        servicios: services,
      );
    }

    if (context.mounted) {
      Navigator.pop(context);
    }
    _showLifecycleMessage(editingIndex == null
        ? 'Hotel creado correctamente'
        : 'Hotel actualizado correctamente');
  }

  Future<void> _deleteHotel(int index) async {
    final removedRoom = await _hotelProvider.deleteHotel(index);

    _showLifecycleMessage('Hotel eliminado: ${removedRoom.nombre}');
  }

  void _openSensors() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => SensorProvider(),
          child: const SensorScreen(),
        ),
      ),
    );
  }

  void _openMedia() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GalleryScreen()),
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      children: [
        Expanded(
          child: _HeaderActionButton(
            label: 'Sensores',
            icon: Icons.sensors,
            onTap: _openSensors,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _HeaderActionButton(
            label: 'Medios',
            icon: Icons.photo_library,
            onTap: _openMedia,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _HeaderActionButton(
            label: 'Mapa',
            icon: Icons.map_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MapScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 900;
    final double padding = isWide ? 26 : 14;
    final rooms = _hotelProvider.rooms;
    final favorites = _hotelProvider.favorites;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(padding, 24, padding, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Descubre alojamientos',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Exclusivos',
                          style: Theme.of(context).textTheme.displayLarge),
                      const SizedBox(height: 16),
                      Container(
                        width: 48,
                        height: 3,
                        color: AppColors.gold,
                      ),
                      const SizedBox(height: 16),
                      _buildHeaderActions(),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: rooms.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.hotel_outlined,
                                  size: 60, color: Colors.grey[350]),
                              const SizedBox(height: 12),
                              Text(
                                'No hay hoteles aún',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Usa el botón + para crear tu primer registro.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        )
                      : PageView.builder(
                          controller: _pageController,
                          scrollDirection: Axis.vertical,
                          itemCount: rooms.length,
                          itemBuilder: (context, index) {
                            final room = rooms[index];
                            final isActive = (_currentPage - index).abs() < 0.5;
                            return Padding(
                              padding: EdgeInsets.fromLTRB(
                                padding,
                                6,
                                padding,
                                90,
                              ),
                              child: Stack(
                                children: [
                                  RoomCardLuxury(
                                    room: room,
                                    topAmenities: room.servicios.take(2).toList(),
                                    isActive: isActive,
                                    height: double.infinity,
                                    onTap: () {
                                      final isFav = _hotelProvider.isFavorite(room.id);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DetailScreen(
                                            room: room,
                                            isFavorite: isFav,
                                            onFavoriteToggle: _hotelProvider.toggleFavorite,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  Positioned(
                                    top: 14,
                                    right: 14,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.92),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert_rounded,
                                            color: AppColors.textDark),
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            _showHotelSheet(editingIndex: index);
                                          } else if (value == 'delete') {
                                            _deleteHotel(index);
                                          }
                                        },
                                        itemBuilder: (context) => const [
                                          PopupMenuItem<String>(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit_rounded,
                                                    size: 18),
                                                SizedBox(width: 8),
                                                Text('Editar'),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete_rounded,
                                                    size: 18,
                                                    color: Colors.red),
                                                SizedBox(width: 8),
                                                Text('Eliminar'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Center(
                    child: Wrap(
                      spacing: 6,
                      children: List.generate(rooms.length, (index) {
                        final active = (_currentPage - index).abs() < 0.5;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          width: active ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: active ? AppColors.gold : Colors.grey[300],
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          FloatingNavigationBar(
            onAddPressed: _showHotelSheet,
            onFavoritesPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FavoritesScreen(
                  favorites: favorites,
                  onFavoritesChanged: _hotelProvider.toggleFavorite,
                ),
              ),
            ),
            onProfilePressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkCharcoal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
    );
  }
}
