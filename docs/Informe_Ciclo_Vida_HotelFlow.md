# Informe: Análisis del Ciclo de Vida de la Aplicación HotelFlow

**Asignatura:** Programación Móvil  
**Proyecto:** HotelFlow (Aplicación de reservas de hoteles)  
**Fecha:** 17 de abril de 2026  
**Estudiante:** Diego García

---

## 1. Introducción
Este documento presenta el análisis del ciclo de vida de desarrollo de la aplicación **HotelFlow**, enfocada en la visualización de hoteles, detalles de hospedaje, favoritos y gestión básica de perfil de usuario.  
Además, se explica cómo cada fase del ciclo de vida se relaciona con el diseño de interfaz (UI), y se justifican las decisiones visuales y de experiencia de usuario aplicadas.

---

## 2. Pantallas diseñadas de la aplicación
A continuación se listan las pantallas principales implementadas en el proyecto:

1. **Pantalla de inicio (Home):** exploración de hoteles con diseño tipo carrusel premium.
2. **Pantalla de detalle (Detail):** información completa del hotel, precio, servicios y acción de reserva/favorito.
3. **Pantalla de favoritos (Favorites):** listado de hoteles guardados por el usuario.
4. **Pantalla de perfil (Profile):** datos del usuario, estadísticas y opciones de configuración.

### Evidencia visual (capturas)
Inserta tus capturas en la carpeta `docs/img` con estos nombres para que se vean aquí al exportar:

- `home.png`
- `detail.png`
- `favorites.png`
- `profile.png`

![Pantalla Home](img/home.png)

![Pantalla Detail](img/detail.png)

![Pantalla Favorites](img/favorites.png)

![Pantalla Profile](img/profile.png)

---

## 3. Análisis del ciclo de vida de la aplicación

### 3.1 Planificación y análisis de requerimientos
En esta fase se definieron las necesidades principales del usuario final y del negocio:

- Buscar alojamientos de forma visual y rápida.
- Ver información clara de cada hotel.
- Guardar hoteles favoritos.
- Tener un perfil con opciones básicas de configuración.

**Relación con la interfaz:**
Desde esta fase se estableció que la UI debía ser limpia, intuitiva y orientada a decisiones rápidas. Por eso se priorizaron componentes visuales directos (tarjetas, íconos, botones de acción destacados y jerarquía tipográfica clara).

### 3.2 Diseño de la interfaz y arquitectura
Se diseñó una experiencia visual con estilo premium para diferenciar el producto y mejorar percepción de calidad:

- Paleta elegante (dorado, neutros y contrastes suaves).
- Tipografía consistente (Montserrat) para identidad visual.
- Navegación simple con acceso a Home, Favoritos y Perfil.
- Estructura modular del código (`core`, `presentation/screens`, `presentation/widgets`).

**Relación con la interfaz:**
El diseño UI se tradujo en componentes reutilizables, uso de constantes visuales y separación entre lógica compartida y widgets de presentación. Esto asegura consistencia visual y facilita mantenimiento.

### 3.3 Desarrollo
En la implementación se construyeron las pantallas y funcionalidades planeadas:

- Home con tarjetas visuales de hoteles.
- Detail con información ampliada y botones de acción.
- Favorites funcional con eliminación y navegación al detalle.
- Profile con estadísticas y preferencias.

También se aplicó refactorización para mejorar calidad:

- Centralización de estilos y valores comunes en `core/app_constants.dart`.
- Reutilización de componentes UI en `core/ui_helpers.dart`.
- Reducción de código duplicado en pantallas.

**Relación con la interfaz:**
Durante desarrollo, el objetivo no solo fue “que funcione”, sino mantener coherencia visual entre pantallas. Cada mejora técnica impactó positivamente en uniformidad, legibilidad y escalabilidad del diseño.

### 3.4 Pruebas
Se realizaron verificaciones funcionales y de consistencia visual:

- Navegación entre pantallas.
- Funcionamiento de favoritos (agregar/quitar).
- Correcta visualización de estados vacíos.
- Validación estática del código con análisis del proyecto.

**Relación con la interfaz:**
Las pruebas de UI confirmaron que los componentes se comportan correctamente en distintos flujos y que el diseño mantiene claridad para el usuario en cada acción.

### 3.5 Despliegue y mantenimiento
Aunque el proyecto está en etapa académica/prototipo, la fase de despliegue considera:

- Preparación para distribución en Android/iOS.
- Ajustes de rendimiento y corrección de errores detectados.
- Evolución futura (persistencia de datos, autenticación real, reservas en backend).

**Relación con la interfaz:**
En mantenimiento, la UI debe adaptarse según retroalimentación. Gracias a la arquitectura modular, es posible mejorar pantallas sin romper consistencia global.

---

## 4. Justificación breve de decisiones de diseño

1. **Estética premium:** se eligió una identidad visual elegante para transmitir confianza y calidad en una app de hotelería.
2. **Jerarquía visual clara:** títulos, subtítulos, precio y rating se diferenciaron por peso tipográfico y color para escaneo rápido.
3. **Navegación simple:** pocas secciones clave para reducir fricción en uso móvil.
4. **Componentes reutilizables:** permite mantener una UI homogénea y simplifica cambios globales de estilo.
5. **Estados vacíos y feedback visual:** mejoran experiencia del usuario cuando no hay datos (por ejemplo, lista de favoritos vacía).

---

## 5. Conclusiones
El ciclo de vida aplicado permitió construir una aplicación funcional y visualmente coherente, alineando decisiones técnicas con objetivos de experiencia de usuario.  
Cada fase (planificación, diseño, desarrollo, pruebas y mantenimiento) influyó directamente en la interfaz, demostrando que una buena UI no depende solo de lo visual, sino de un proceso completo y ordenado de ingeniería de software.

---

## 6. Referencias internas del proyecto
- `lib/main.dart`
- `lib/core/app_theme.dart`
- `lib/core/app_constants.dart`
- `lib/core/ui_helpers.dart`
- `lib/presentation/screens/home_screen.dart`
- `lib/presentation/screens/detail_screen.dart`
- `lib/presentation/screens/favorites_screen.dart`
- `lib/presentation/screens/profile_screen.dart`

