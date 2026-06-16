# EcoSpot 🌿

Plataforma web de **turismo low-cost y sostenible**. Proyecto académico de Sistemas de Información (Hitos 2 y 3) — Universidad Metropolitana, **Equipo 6**.

## Equipo
Roger Balan · Juan Blanco · Iker Solar · Sebastián Velásquez · Alejandro Coll · Miguel Greco

## Cuenta de demostración
Para probar el inicio de sesión sin registrarse:
- **Correo:** `demo@unimet.edu.ve`
- **Contraseña:** `123456`
  
## Cuenta de administrador
Para probar el inicio de sesión con admin:
- **Correo:** `admin@unimet.edu.ve`
- **Contraseña:** `admin123`

(También puedes crear una cuenta nueva; el correo debe terminar en `@unimet.edu.ve` o `@correo.unimet.edu.ve`.)

## Funcionalidades implementadas
- **Login** con validación de credenciales.
- **Registro** con validación de correo institucional y contraseña; crea la cuenta y entra al inicio.
- **Inicio (Home)** con acceso a la búsqueda.
- **Búsqueda con filtrado real**: por destino (texto) y por presupuesto máximo (slider). Muestra contador de resultados y estado vacío.
- **Solicitud de reserva** con estado "Solicitado".

## Arquitectura y patrones de diseño
- **Patrón Arquitectónico:** arquitectura **en capas** (Layered):
  - `lib/*.dart` (páginas) → capa de **Presentación** (UI).
  - `lib/services/` → capa de **Lógica/Servicios** (`AuthService`, `AccommodationRepository`).
  - `lib/models/` → capa de **Datos/Dominio** (`Accommodation`).
- **Patrón de Diseño 1 — Singleton:** `AuthService` mantiene una única instancia con el estado de sesión compartido en toda la app.
- **Patrón de Diseño 2 — Repository:** `AccommodationRepository` abstrae el origen de datos; hoy es mock en memoria y mañana puede ser Firebase sin cambiar las pantallas.
