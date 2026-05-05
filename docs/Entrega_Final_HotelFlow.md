# HotelFlow - Entrega Final

**Asignatura:** Programación Móvil  
**Proyecto:** Aplicación de reservas hoteleras (HotelFlow)  
**Fecha:** 22 de abril de 2026  
**Estudiante:** Diego García

---

## 0. Diario de trabajo (registro de sesiones)

| Sesión | Fecha | Actividades realizadas | Evidencia de avance |
|---|---|---|---|
| 1 | 04/04/2026 | Definición de alcance: Home, Detail, Favorites, Profile. Levantamiento de requerimientos funcionales y visuales. | Lista de pantallas y objetivos de UX aprobados para implementación. |
| 2 | 04/04/2026 | Diseño visual premium: paleta, tipografía, jerarquía de información y navegación principal. | Tema global y lineamientos visuales aplicados a la app. |
| 3 | 04/04/2026 | Implementación de Favorites y Profile con navegación y estados básicos. | Pantallas funcionales conectadas al flujo principal. |
| 4 | 04/04/2026 | Refactor técnico: centralización de constantes y helpers, reducción de duplicación de código. | Estructura `core` reforzada (`app_constants.dart` y `ui_helpers.dart`). |
| 5 | 17/04/2026 | Documentación formal: análisis del ciclo de vida y justificación de diseño para entrega académica. | Documento de informe y guion de exposición. |
| 6 | 22/04/2026 | Implementación del ciclo de vida runtime con `AppLifecycleState` y validación en Chrome. | Mensajes verificados: `App iniciada` y `Bienvenido de nuevo`. |

**Resultado del diario:** se registran todas las sesiones relevantes con actividades, orden temporal y evidencia concreta de avance.

---

## 1. Pantallas diseñadas de la aplicación

La aplicación fue diseñada con una interfaz moderna y estilo premium, enfocada en claridad visual y facilidad de uso en móvil.

### 1.1 Pantalla Home
- Muestra el catálogo principal de hoteles en formato visual tipo carrusel vertical.
- Incluye navegación flotante para agregar hoteles, abrir favoritos y acceder al perfil.

**Captura:**

![Pantalla Home](img/home.png)

### 1.2 Pantalla Detail
- Presenta información completa del hotel seleccionado.
- Permite reservar y marcar/desmarcar como favorito.

**Captura:**

![Pantalla Detail](img/detail.png)

### 1.3 Pantalla Favorites
- Lista los hoteles guardados por el usuario.
- Incluye estado vacío y opción para eliminar elementos de favoritos.

**Captura:**

![Pantalla Favorites](img/favorites.png)

### 1.4 Pantalla Profile
- Muestra información del usuario, estadísticas y opciones de configuración.
- Incluye acciones de soporte y cierre de sesión.

**Captura:**

![Pantalla Profile](img/profile.png)

---

## 2. Descripción del ciclo de vida de la aplicación

En este proyecto se consideran dos enfoques de ciclo de vida: desarrollo del software y ejecución de la app.

### 2.1 Ciclo de vida de desarrollo (ingeniería de software)

#### a) Planificación y análisis de requerimientos
Se definieron funciones esenciales: explorar hoteles, ver detalles, guardar favoritos y gestionar perfil.

#### b) Diseño de interfaz y arquitectura
Se diseñó una experiencia visual consistente con estructura modular:
- `core` para constantes, tema y utilidades reutilizables.
- `presentation/screens` para pantallas.
- `presentation/widgets` para componentes visuales reutilizables.

#### c) Desarrollo
Se implementaron las pantallas principales y flujos de navegación, junto con refactorización para reducir duplicación de código.

#### d) Pruebas
Se validó navegación, estados vacíos, lógica de favoritos y comportamiento general de la interfaz.

#### e) Despliegue y mantenimiento
El proyecto queda preparado para mejoras continuas: persistencia de datos, autenticación, backend y optimizaciones en producción.

### 2.2 Ciclo de vida de ejecución (runtime) implementado
Se implementó en la pantalla principal el manejo de estados de ciclo de vida con `AppLifecycleState`:

- **Inicio de app:** se muestra mensaje `App iniciada`.
- **Regreso desde otra pestaña o app:** se muestra `Bienvenido de nuevo`.
- **Estados de segundo plano/cierre:** se detectan internamente; en web algunos mensajes no siempre son visibles por limitaciones del navegador.

Archivo de implementación:
- `lib/presentation/screens/home_screen.dart`

---

## 3. Breve justificación de decisiones de diseño

1. **Jerarquía visual clara**
Se priorizan nombre, ubicación, precio y rating para que el usuario tome decisiones rápidamente.

2. **Paleta elegante y consistente**
Se usa una línea visual premium (dorado + neutros) para transmitir calidad y coherencia entre pantallas.

3. **Componentes reutilizables**
Se centralizaron helpers y constantes para mantener una UI uniforme y facilitar mantenimiento.

4. **Navegación simple y directa**
Con pocos accesos principales (Home, Favoritos, Perfil) se reduce fricción en el uso.

5. **Feedback al usuario**
Se añadieron mensajes visuales y estados vacíos para mejorar comprensión de acciones y estado de la app.

---

## 4. Conclusión

La aplicación HotelFlow cumple con las pantallas solicitadas y evidencia un proceso completo de desarrollo.  
Además, integra manejo básico del ciclo de vida en ejecución, reforzando la calidad técnica y la experiencia del usuario.

---

## 5. Reflexión y aprendizaje

Durante el desarrollo se identificó que el diseño de interfaz no debe tratarse como un paso aislado, sino como una decisión transversal a todo el ciclo de vida.  
En planificación, una definición clara de requerimientos evitó implementar pantallas innecesarias. En diseño, la jerarquía visual (nombre, ubicación, precio, rating) mejoró la lectura rápida del usuario. En desarrollo, reutilizar componentes y constantes permitió mantener consistencia visual sin duplicar lógica.

En pruebas, se comprobó que la experiencia de usuario depende tanto del aspecto visual como de los estados de interacción (vacíos, favoritos, mensajes de feedback). Finalmente, con la implementación de `AppLifecycleState`, se entendió la diferencia entre el ciclo de vida de desarrollo y el ciclo de vida de ejecución, especialmente en entornos web donde algunos eventos no siempre son visibles.

**Aprendizaje principal:** una interfaz de calidad se logra combinando decisiones de UX, arquitectura limpia y validación continua, no solo “pantallas bonitas”.

---

## 6. Evidencia técnica (archivos principales)

- `lib/main.dart`
- `lib/core/app_theme.dart`
- `lib/core/app_constants.dart`
- `lib/core/ui_helpers.dart`
- `lib/presentation/screens/home_screen.dart`
- `lib/presentation/screens/detail_screen.dart`
- `lib/presentation/screens/favorites_screen.dart`
- `lib/presentation/screens/profile_screen.dart`
- `lib/presentation/widgets/room_card_luxury.dart`
- `lib/presentation/widgets/floating_navigation_bar.dart`

---

## 7. Verificación con rúbrica

### 7.1 Registro y cumplimiento del diario (2 puntos)
- Cumplido con sección **0. Diario de trabajo**.
- Contiene sesiones completas, ordenadas, con actividad y evidencia.

### 7.2 Avance del diseño y análisis (2 puntos)
- Cumplido en secciones **1** (pantallas) y **2** (ciclo de vida).
- Se evidencia evolución de interfaz + implementación técnica.

### 7.3 Reflexión y aprendizaje (1 punto)
- Cumplido en sección **5. Reflexión y aprendizaje**.
- Incluye decisiones tomadas, resultados y aprendizaje final.
