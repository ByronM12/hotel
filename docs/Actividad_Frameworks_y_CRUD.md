# Investigación de Frameworks y Prototipo CRUD

Asignatura: Programación Móvil  
Proyecto: HotelFlow  
Fecha: 22 de abril de 2026  
Estudiante: Diego García

---

## 1. Investigación de frameworks de desarrollo móvil

### 1.1 Flutter
Descripción:
Flutter es un framework de Google para construir aplicaciones móviles, web y escritorio desde una sola base de código usando Dart.

Características clave:
- Renderizado propio con alto control visual.
- Componentes modernos con Material Design.
- Hot Reload para iteraciones rápidas.
- Muy buena consistencia entre plataformas.

Ventajas:
- Alto rendimiento para UI complejas.
- Excelente experiencia de desarrollo.
- Fuerte ecosistema y documentación.

Desventajas:
- Tamaño de app inicial más alto que algunos enfoques híbridos.
- Requiere aprender Dart si no se conoce.

Tipos de app recomendadas:
- Apps de negocio con UI personalizada.
- Apps con animaciones y diseño avanzado.
- Prototipos rápidos que luego evolucionan a producción.

### 1.2 React Native
Descripción:
Framework de Meta para desarrollo móvil con JavaScript/TypeScript y React.

Características clave:
- Reutilización de lógica web en equipos JS.
- Amplio ecosistema de librerías.
- Integración con módulos nativos cuando se requiere.

Ventajas:
- Curva de adopción rápida para equipos React.
- Comunidad grande y madura.

Desventajas:
- Diferencias de comportamiento entre plataformas en algunos componentes.
- Dependencia de librerías de terceros para ciertos casos.

Tipos de app recomendadas:
- Apps de negocio y e-commerce.
- Equipos con experiencia previa en React.

### 1.3 Ionic
Descripción:
Framework híbrido basado en tecnologías web (HTML, CSS y JavaScript) con contenedor móvil.

Características clave:
- Enfoque web-first.
- Componentes UI listos para móvil.
- Integración con Capacitor para acceso a funciones nativas.

Ventajas:
- Muy rápido para equipos con experiencia web.
- Alta reutilización en aplicaciones web y móvil.

Desventajas:
- Rendimiento visual inferior en escenarios muy exigentes frente a Flutter o nativo.
- Experiencia de usuario puede sentirse más web en ciertos casos.

Tipos de app recomendadas:
- Apps internas empresariales.
- Formularios, paneles y flujos administrativos.

### 1.4 Comparación resumida

| Criterio | Flutter | React Native | Ionic |
|---|---|---|---|
| Lenguaje principal | Dart | JavaScript/TypeScript | JavaScript/TypeScript |
| Rendimiento UI | Alto | Medio-Alto | Medio |
| Curva para equipos web | Media | Baja | Muy baja |
| Consistencia visual multiplataforma | Alta | Media | Media |
| Ideal para | UI rica y escalable | Equipos React | Apps híbridas rápidas |

---

## 2. Framework seleccionado

Framework elegido: Flutter

Justificación de selección:
- Ya se cuenta con base funcional del proyecto HotelFlow en Flutter.
- Permite construir interfaz visual premium con alto control de diseño.
- Facilita la modularidad del código en capas claras (core, screens, widgets).
- Ofrece buen rendimiento y experiencia de usuario en móviles.

---

## 3. Desarrollo del prototipo CRUD

Se implementó un prototipo CRUD sobre datos simulados de hoteles.

Entidad gestionada:
- Hotel (id, nombre, ubicación, descripción, precio, rating, servicios)

Archivo principal de lógica CRUD:
- lib/presentation/screens/home_screen.dart

### 3.1 Crear registros (Create)
- Acción: botón agregar en la barra flotante.
- Flujo: abre formulario en modal y guarda un nuevo hotel.
- Resultado: el registro aparece inmediatamente en el carrusel.

### 3.2 Leer registros (Read)
- Acción: al abrir la app se muestran los hoteles cargados.
- Flujo: listado visual tipo carrusel vertical en Home.
- Resultado: el usuario puede explorar y abrir detalle por registro.

### 3.3 Actualizar registros (Update)
- Acción: menú de opciones en cada tarjeta de hotel, opción Editar.
- Flujo: abre el mismo formulario con datos precargados y permite actualizar.
- Resultado: el registro se reemplaza en pantalla con los nuevos valores.

### 3.4 Eliminar registros (Delete)
- Acción: menú de opciones en cada tarjeta de hotel, opción Eliminar.
- Flujo: elimina el registro seleccionado de la lista principal.
- Resultado: desaparece del carrusel y se actualizan favoritos relacionados.

---

## 4. Gestión de datos en el prototipo

Modelo de datos:
- lib/data/hotel_model.dart

Fuente de datos inicial:
- lib/core/app_constants.dart en AppData.defaultRooms

Manejo de estado:
- Estado local con StatefulWidget.
- Actualizaciones mediante setState para refresco inmediato de UI.

Observación:
- El prototipo usa datos simulados en memoria.
- Como mejora futura, se puede integrar persistencia local (por ejemplo SQLite o Hive) o backend en la nube.

---

## 5. Evidencia visual del CRUD

Agregar capturas en la carpeta docs/img con estos nombres:
- crud_create.png
- crud_read.png
- crud_update.png
- crud_delete.png

### 5.1 Evidencia Create
![Create](img/crud_create.png)

### 5.2 Evidencia Read
![Read](img/crud_read.png)

### 5.3 Evidencia Update
![Update](img/crud_update.png)

### 5.4 Evidencia Delete
![Delete](img/crud_delete.png)

---

## 6. Conclusión

La investigación permitió comparar frameworks y seleccionar Flutter con base en rendimiento, consistencia visual y capacidad de escalamiento del proyecto.  
El prototipo funcional implementa correctamente las cuatro operaciones CRUD sobre datos simulados, cumpliendo los objetivos de la actividad y aplicando buenas prácticas de organización de código y gestión de estado.

---

## 7. Archivos técnicos principales del proyecto

- lib/main.dart
- lib/core/app_theme.dart
- lib/core/app_constants.dart
- lib/core/ui_helpers.dart
- lib/data/hotel_model.dart
- lib/presentation/screens/home_screen.dart
- lib/presentation/screens/detail_screen.dart
- lib/presentation/screens/favorites_screen.dart
- lib/presentation/screens/profile_screen.dart
- lib/presentation/widgets/room_card_luxury.dart
- lib/presentation/widgets/floating_navigation_bar.dart
