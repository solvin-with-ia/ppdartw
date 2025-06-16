# Planning Poker POC

## Descripción
Este proyecto es una Prueba de Concepto (POC) desarrollada en Dart/Flutter que recrea la dinámica de Planning Poker, demostrando el poder de la programación reactiva y la arquitectura limpia en Flutter, aplicando principios SOLID y el patrón BLoC. Utiliza como base el paquete [jocaagura_domain](https://pub.dev/packages/jocaagura_domain) y está diseñado para ser fácilmente escalable y mantenible.

- **Arquitectura limpia**: Separación clara de responsabilidades mediante capas (Services, Gateway, Repository, Usecases, Bloc, UI, AppManager, Views/Pages, Widgets).
- **Programación reactiva**: Uso intensivo del patrón BLoC y streams para la gestión de estado y eventos.
- **Dependencias externas**: jocaagura_domain, text_responsive.

## Características
- Estimación colaborativa de tareas usando Planning Poker.
- UI moderna y responsiva, alineada al diseño de Figma.
- Ejemplo de integración de arquitectura limpia y principios SOLID en Flutter.
- Soporte multiplataforma, incluyendo Windows.

## Recursos
- **Figma (UI/UX)**: [Planning Poker Figma](https://www.figma.com/design/ZUtgyUkS89DaW47qEW28i5/Planning-Poker?node-id=60-661&p=f&t=yUDZIYkaKOVI83W5-0)
- **Google Classroom**: [Classroom Link](https://classroom.google.com/c/NTg5MDI5NDM2MTkx/m/NTg5MDI5NDM5Njg3/details)

## Prerrequisitos y Comienzo Rápido

1. Tener instalado Flutter (>=3.8.0) y Dart SDK.
2. Clonar este repositorio:
   ```sh
   git clone https://github.com/solvin-with-ia/ppdartw.git
   cd ppdartw
   ```
3. Instalar dependencias:
   ```sh
   flutter pub get
   ```
4. Ejecutar en Windows:
   ```sh
   flutter run -d windows
   ```

## Estructura del Proyecto
```
lib/
  ├─ services/
  ├─ gateway/
  ├─ repository/
  ├─ usecases/
  ├─ bloc/
  ├─ ui/
  ├─ app_manager/
  ├─ views/
  └─ widgets/
```

## Uso de jocaagura_domain
Ejemplo básico de uso de un modelo:
```dart
import 'package:jocaagura_domain/user_model.dart';

void main() {
  var user = UserModel(
    id: '001',
    displayName: 'Juan Perez',
    photoUrl: 'https://example.com/photo.jpg',
    email: 'juan.perez@example.com',
    jwt: {'token': 'abcd1234'},
  );
  print(user);
}
```

## Contribuciones
Para contribuir, por favor abre un issue o pull request. Para reportar problemas con los modelos de dominio, visita el repositorio de [jocaagura_domain](https://github.com/grupo-jocaagura/jocaagura_domain).

---

Proyecto educativo para la materia de arquitectura de software, ejemplo de integración de patrones modernos en Flutter.
