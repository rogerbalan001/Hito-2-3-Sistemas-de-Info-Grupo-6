# EcoSpot 🌿

Plataforma **web y móvil (PWA + Android)** de **turismo low-cost y sostenible**. Proyecto académico de Sistemas de Información — Universidad Metropolitana, **Equipo 6**. Desarrollado con la metodología **OpenUP** (Concepción → Elaboración → Construcción → **Transición / Fase 4**).

🌐 **Producción (GitHub Pages):** https://rogerbalan001.github.io/Hito-2-3-Sistemas-de-Info-Grupo-6/

## Documentación
- 📘 [Manual de Usuario](docs/MANUAL_USUARIO.md)
- 🛠️ [Manual Técnico](docs/MANUAL_TECNICO.md)
- ⚙️ [Guía de Instalación y Compilación](docs/INSTALACION.md)
- 🧪 [Plan de Pruebas](docs/PLAN_DE_PRUEBAS.md)

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
- **Login / Registro** con validación de correo institucional (`@unimet.edu.ve` o `@correo.unimet.edu.ve`) vía Firebase Auth.
- **Búsqueda con filtrado real** por destino (texto) y presupuesto máximo (slider), leyendo el catálogo desde Firestore.
- **Detalle de alojamiento** con fotos, capacidad, transporte y reglas.
- **Ciclo de reservas:** Solicitado → Aprobado (admin) → Pagado → Disfrutado.
- **Pasarela de pago PayPal** (sandbox), habilitada solo tras la aprobación del administrador.
- **Paquetes turísticos** y **Comunidad / reseñas** con verificación de precio.
- **Dashboard** administrativo con métricas en vivo desde Firestore.
- **Panel de Administración:** gestión de hospedajes (editar/eliminar) y de reservas (aprobar/cancelar).
- **PWA instalable** y **APK Android** (compilado por CI).

## Despliegue y compilación
- **Web/PWA:** se compila y publica automáticamente en GitHub Pages en cada push a `main` (`.github/workflows/deploy.yml`).
- **APK Android:** se compila en cada push a `main` y queda como artefacto descargable (`.github/workflows/build-apk.yml` → pestaña **Actions**).
- Detalles en la [Guía de Instalación](docs/INSTALACION.md).

## Arquitectura y patrones de diseño
- **Patrón Arquitectónico:** arquitectura **en capas** (Layered):
  - `lib/*.dart` (páginas) → capa de **Presentación** (UI).
  - `lib/services/` → capa de **Lógica/Servicios** (`AuthService`, `AccommodationRepository`).
  - `lib/models/` → capa de **Datos/Dominio** (`Accommodation`).
- **Patrón de Diseño 1 — Singleton:** `AuthService` mantiene una única instancia con el estado de sesión compartido en toda la app.
- **Patrón de Diseño 2 — Repository:** `AccommodationRepository` abstrae el origen de datos; hoy es mock en memoria y mañana puede ser Firebase sin cambiar las pantallas.
