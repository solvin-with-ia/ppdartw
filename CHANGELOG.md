## 0.9.0

- Refactor completo de NameAndRoleModal: ahora es 100% stateless y reactivo, sin estado local.
- Unificación de todos los inputs de texto usando CustomInputWidget en todo el proyecto.
- Eliminación de todos los TextField directos y lógica duplicada de inputs.
- Modal y flujo de creación de partida ahora usan solo el estado del bloc (sin duplicidad).
- Fix de overflow visual y modal completamente responsive.
- Selección de rol totalmente reactiva y sin errores visuales.
- Limpieza de imports y código muerto.

## 0.8.0

- Nueva infraestructura BlocModal para mostrar modales y notificaciones globales de forma reactiva y desacoplada.
- Integración de BackdropWidget para overlays visuales y notificaciones.
- ProjectViewsWidget ahora soporta modales globales.
- Nuevos tests unitarios para BlocModal y cobertura de AppStateManager con BlocModal.

## 0.7.0

- Fix visual: Se corrigió un overflow horizontal en LogoHorizontalWidget usando Expanded para el texto, mejorando la robustez visual en todas las resoluciones.
- Mejoras menores de layout y consistencia visual.

## 0.6.0

- BlocGame ahora consume BlocSession para asignar automáticamente el usuario logueado como admin de la partida.
- Refactor de GameModel.empty para garantizar null safety y evitar errores en tests/unitarios.
- Tests unitarios robustos para BlocGame, incluyendo flujo de creación y actualización de partida.
- Fix de inicialización de admin en GameModel y eliminación de posibles nulos.

## 0.5.0

- Migración definitiva de todos los BLoCs a `lib/blocs` (removido domains/blocs).
- Limpieza y corrección de imports en toda la base de código.
- Fix de tests unitarios y cobertura para robustez y consistencia.

## 0.4.0

- Refactor de LoadingWidget y ProjectViewsWidget a /ui/widgets para mejor modularidad y extensibilidad.
- Nuevo BackdropWidget para overlays reutilizables (loading, notificaciones, etc.).
- BlocLoading ahora incluye clearMsg() y isLoading para mayor control y consultas.
- Test unitario robusto para BlocLoading.
- Integración con text_responsive en LoadingWidget.
- Limpieza y organización de archivos legacy en /views.

## 0.3.0

- Integración de BlocNavigator para navegación reactiva centralizada usando EnumViews.
- Nuevo widget ProjectViewsWidget que reacciona al stream de navegación y muestra la vista correspondiente.
- AppStateManager ahora expone blocNavigator y permite acceso global a la navegación y sesión.
- Refactor de main.dart para usar navegación reactiva y desacoplada.
- Pruebas unitarias completas para AppStateManager y navegación.

## 0.2.0

- Integración global de BlocSession en AppStateManager (estado de sesión disponible en toda la app).
- Nuevos tests unitarios para BlocSession y AppStateManager.
- Refactor y stubs para SessionRepository en pruebas.
- Mejoras de arquitectura y cobertura de tests.

## 0.1.0

- Migración de fakes a gateways *Impl* para Game, Cards y Session.
- Refactor de repositorios para uso explícito de gateways impl.
- Cobertura total de tests unitarios para gateways y repositorios, ajustados a nueva arquitectura.
- Manejo robusto de sesión y errores con Either: userStream ahora emite Right(null) al cerrar sesión.
- Limpieza de imports y mejoras menores de tipado en tests.

## 0.0.8

- Se agregan las clases abstractas y fakes para GameGateway, CardsGateway y SessionGateway.
- Implementaciones fake integradas con los servicios simulados.
- Tests unitarios completos para cada gateway (guardar, leer, streams, login/logout, etc.).

## 0.0.7

- Se agrega la abstracción ServiceSession para gestión de sesión/autenticación de usuario.
- Implementación de FakeServiceSession usando BlocGeneral para simular login/logout y stream de usuario autenticado.
- Tests unitarios completos para FakeServiceSession: stream reactivo, login simulado y signOut.

## 0.0.6

- Implementación de FakeServiceWsDatabase en infraestructura, usando BlocGeneral de jocaagura_domain para simular streams y almacenamiento en memoria.
- Tests unitarios completos para FakeServiceWsDatabase: guardado, lectura, streams de documento y colección, y múltiples documentos.

## 0.0.5

- Refactor y robustecimiento de los modelos de dominio (CardModel, VoteModel, GameModel):
  - Homogeneización y null-safety en serialización/deserialización.
  - Corrección de la conversión de listas de historias (stories) en GameModel.
  - Utilización de utilitarios genéricos para listas de modelos.
- Tests unitarios completos para modelos y utilidades, cubriendo escenarios y estados posibles del juego.
- Mejoras en la comparación de modelos en tests para evitar falsos negativos.

## 0.0.4

- Corrección en la declaración de assets en pubspec.yaml para Flutter.
- El tema morado personalizado ahora se aplica correctamente en toda la app.

## 0.0.3

- Se agregó ProjectorWidget para diseño responsive.
- Nuevo utilitario DeviceType y DeviceDesign en shared/device_utils.dart.
- EnumViews creado para gestionar las vistas principales.
- Nueva vista SplashView como pantalla de inicio, muestra el tipo de dispositivo proyectado.

## 0.0.2

- Corrección de dependencias: se añadió correctamente flutter en pubspec.yaml.
- Mejoras en la gestión de estado y temas (BlocTheme y AppStateManager).
- Refactor y limpieza de código en main.dart y bloc_theme.dart.

## 0.0.1

- Estructura inicial del proyecto Planning Poker POC en Dart/Flutter.
- Implementación de arquitectura limpia y principios SOLID usando patrón BLoC.
- Soporte multiplataforma, incluyendo Windows.
- Integración del paquete jocaagura_domain y text_responsive.
- Actualización y personalización del README.md con enlaces a Figma y Classroom.
- Configuración de .gitignore estándar para Flutter.
