# Manual Técnico — EcoSpot

## 1. Arquitectura en capas (Layered Architecture)

| Capa | Carpeta | Responsabilidad |
|---|---|---|
| Presentación | `lib/pages/` | Widgets, navegación, estado de UI |
| Lógica/Servicios | `lib/services/` | Reglas de negocio (`AuthService`, `AccommodationRepository`) |
| Datos/Dominio | `lib/models/` | Entidades (`Accommodation`) |

Regla de dependencia: las páginas dependen de servicios; los servicios dependen de modelos. Nunca al revés. Esto permite cambiar la UI sin tocar la lógica, y cambiar el origen de datos sin tocar la UI.

## 2. Patrón Singleton — `AuthService`

```dart
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool isAuthenticated = false;
}
```

`factory` intercepta el `new`/llamada al constructor y siempre retorna `_instance`. Esto garantiza una única fuente de verdad del estado de sesión en toda la app, evitando inconsistencias (ej. una pantalla cree que el usuario está logueado y otra no).

## 3. Patrón Repository — `AccommodationRepository`

```dart
class AccommodationRepository {
  Future<List> search({String? destino, double? presupuestoMax}) async {
    // hoy: datos mock en memoria
    // mañana: misma firma, fuente Firebase/REST
  }
}
```

El repositorio actúa como capa de abstracción entre la UI y el origen de datos. Las páginas llaman `search(...)` sin saber si los datos vienen de una lista mock o de Firestore. Esto cumple el Principio de Inversión de Dependencias (SOLID) y permite migrar de mock a backend real sin reescribir pantallas.

## 4. Flujo de autenticación
Login → `AuthService.login()` valida credenciales → si es válido, setea `isAuthenticated = true` → redirige a Home.
Registro → valida dominio institucional (`@unimet.edu.ve` / `@correo.unimet.edu.ve`) → crea cuenta → autologin.

## 5. Flujo de búsqueda
Home → SearchPage → `AccommodationRepository.search(destino, presupuestoMax)` → filtra lista mock → UI muestra contador + lista o estado vacío.

## 6. Roadmap técnico
Sustituir el mock de `AccommodationRepository` por `FirebaseFirestore` implementando la misma interfaz pública — sin tocar las páginas.
