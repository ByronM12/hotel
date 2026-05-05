# Estructura de Proyecto Propuesta (Flutter CRUD)

Esta propuesta mejora la organización actual tipo `Entity/Provider/Screen/Service/Widget` separando por **feature** (módulo funcional) y por **capa** (data, domain, presentation).

## 1. Estructura sugerida

```text
lib/
  app/
    app.dart
    routes.dart
    dependency_injection.dart

  core/
    constants/
      app_colors.dart
      app_strings.dart
    errors/
      failures.dart
    network/
      api_client.dart
    utils/
      validators.dart
      formatters.dart

  shared/
    widgets/
      app_button.dart
      app_input.dart
      app_loading.dart

  features/
    clientes/
      data/
        datasources/
          cliente_local_datasource.dart
        models/
          cliente_model.dart
        repositories/
          cliente_repository_impl.dart
      domain/
        entities/
          cliente.dart
        repositories/
          cliente_repository.dart
        usecases/
          create_cliente.dart
          get_clientes.dart
          update_cliente.dart
          delete_cliente.dart
      presentation/
        providers/
          cliente_provider.dart
        screens/
          clientes_page.dart
          cliente_form_page.dart
        widgets/
          cliente_card.dart

  main.dart
```

## 2. Por qué es mejor

1. Escala mejor cuando agregues más módulos (productos, reservas, pagos, etc.).
2. Evita mezclar UI con lógica de datos.
3. Hace más fácil testear cada capa por separado.
4. Mantiene el CRUD ordenado y legible para evaluación académica.

## 3. Equivalencia con tu estructura actual

- `Entity/Cliente.dart` -> `features/clientes/domain/entities/cliente.dart`
- `Service/ClienteService.dart` -> `features/clientes/data/datasources/cliente_local_datasource.dart`
- `Provider/ClienteProvider.dart` -> `features/clientes/presentation/providers/cliente_provider.dart`
- `Screen/PageCliente.dart` -> `features/clientes/presentation/screens/clientes_page.dart`
- `Screen/ClienteForm.dart` -> `features/clientes/presentation/screens/cliente_form_page.dart`
- `Widget/*` ->
  - Si es de clientes: `features/clientes/presentation/widgets/`
  - Si es global: `shared/widgets/`

## 4. Reglas prácticas

1. `features/*/presentation` solo maneja interfaz y estado visual.
2. `features/*/domain` no depende de Flutter.
3. `features/*/data` conoce API/DB/local storage.
4. `core` contiene piezas transversales reutilizables.
5. `shared/widgets` solo para componentes realmente globales.

## 5. Aplicación al CRUD

- **Create**: use case `create_cliente.dart`
- **Read**: use case `get_clientes.dart`
- **Update**: use case `update_cliente.dart`
- **Delete**: use case `delete_cliente.dart`

El `cliente_provider.dart` coordina estos casos de uso y actualiza la UI.

## 6. Plan de migración recomendado (sin romper todo)

1. Crear `features/clientes/` y mover pantallas primero.
2. Mover `Provider` a `presentation/providers`.
3. Crear `data/models` y migrar `Entity` a `domain/entities`.
4. Separar `Service` en `data/datasources` y `data/repositories`.
5. Ajustar imports y probar en cada paso.
