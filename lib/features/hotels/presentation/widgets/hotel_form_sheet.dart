import 'package:flutter/material.dart';

import '../../../../core/app_constants.dart';
import '../logic/hotel_form_logic.dart';

Future<void> showHotelFormSheet({
  required BuildContext context,
  required GlobalKey<FormState> formKey,
  required Map<String, TextEditingController> controllers,
  required bool isEditing,
  required VoidCallback onSubmit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0D5DD),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  isEditing ? 'Editar hotel' : 'Agregar hotel',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  isEditing
                      ? 'Actualiza los datos del hotel seleccionado.'
                      : 'Completa los datos y aparecera en el carrusel.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                _buildFormField(controllers: controllers, keyName: 'nombre', label: 'Nombre del hotel'),
                const SizedBox(height: 12),
                _buildFormField(controllers: controllers, keyName: 'ubicacion', label: 'Ubicacion'),
                const SizedBox(height: 12),
                _buildFormField(
                  controllers: controllers,
                  keyName: 'descripcion',
                  label: 'Descripcion',
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildFormField(
                        controllers: controllers,
                        keyName: 'precio',
                        label: 'Precio',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFormField(
                        controllers: controllers,
                        keyName: 'rating',
                        label: 'Rating 0-5',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFormField(
                  controllers: controllers,
                  keyName: 'servicios',
                  label: 'Servicios (WiFi, Piscina...)',
                  hintText: 'Separados por coma',
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(isEditing ? 'Actualizar hotel' : 'Guardar hotel'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildFormField({
  required Map<String, TextEditingController> controllers,
  required String keyName,
  required String label,
  String? hintText,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextFormField(
    controller: controllers[keyName],
    keyboardType: keyboardType,
    maxLines: maxLines,
    decoration: InputDecoration(labelText: label, hintText: hintText),
    validator: (value) => HotelFormLogic.validateField(keyName, value),
  );
}
