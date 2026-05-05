class HotelFormLogic {
  HotelFormLogic._();

  static String? validateField(String key, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Requerido';
    }

    if (key == 'precio' && double.tryParse(value) == null) {
      return 'Numero valido';
    }

    if (key == 'rating') {
      final rating = double.tryParse(value);
      if (rating == null || rating < 0 || rating > 5) {
        return '0-5';
      }
    }

    return null;
  }

  static List<String> parseServices(String raw) {
    return raw
        .split(',')
        .map((service) => service.trim())
        .where((service) => service.isNotEmpty)
        .toList();
  }
}
