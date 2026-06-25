# Manual Técnico — EcoSpot

Documentación técnica de la plataforma EcoSpot (turismo low-cost). Proyecto
académico de Sistemas de Información — Universidad Metropolitana, Equipo 6.

---

## 1. Stack tecnológico

| Capa | Tecnología |
|------|-----------|
| Frontend | Flutter (web + Android), Dart |
| Backend | Firebase: Authentication + Cloud Firestore |
| Pagos | PayPal JavaScript SDK (sandbox) |
| Hosting | GitHub Pages (build web automático por CI) |
| Móvil | PWA instalable + APK Android (artefacto de CI) |
| Control de versiones | Git + GitHub |

---

## 2. Arquitectura

Arquitectura **en capas (Layered)**:

```
lib/
├── *.dart                → Presentación (páginas/UI)
│   ├── login_page.dart, register_page.dart, main_shell.dart
│   ├── inicio_page.dart, search_page.dart, accommodation_details_page.dart
│   ├── packages_page.dart, my_reservations_page.dart, payment_page.dart
│   ├── community_page.dart, dashboard_page.dart, admin_page.dart, ...
├── services/             → Lógica / acceso a datos (Repository + Singleton)
│   ├── auth_service.dart            (Firebase Auth + allowlist admin)
│   ├── accommodation_repository.dart (catálogo en tiempo real)
│   ├── accommodation_service.dart    (alta/edición/borrado)
│   ├── reservation_service.dart      (ciclo de vida de reservas)
│   ├── dashboard_service.dart        (métricas agregadas)
│   ├── seed_service.dart             (carga inicial idempotente)
│   ├── paypal_service.dart           (carga del SDK de PayPal)
│   ├── profile_service.dart, session.dart
├── models/               → Dominio (Accommodation, ...)
├── data/                 → Datos de ejemplo (mock_data.dart)
└── theme/                → Estilos (app_theme.dart, AppColors, EcoSpotLogo)
```

### Patrones de diseño
- **Singleton:** los servicios (`AuthService`, `ReservationService`, etc.) exponen
  una única instancia compartida (`factory ... => _instance`).
- **Repository:** las pantallas solo conocen métodos del repositorio
  (`watchAll`, `search`, `crearReserva`...) sin saber que detrás hay Firestore.

---

## 3. Modelo de datos (Cloud Firestore)

### Colección `accommodations`
| Campo | Tipo | Notas |
|-------|------|-------|
| nombre | string | |
| destino | string | ubicación |
| region | string | |
| tipo | string | Posada, Camping, ... |
| precioPorNoche | number | |
| capacidad | number | |
| descripcion | string | |
| rating, reviewCount | number | |
| transport, amenities | array | |
| available | bool | |

### Colección `reservas`
| Campo | Tipo | Notas |
|-------|------|-------|
| usuarioId / usuarioEmail | string | dueño |
| alojamiento / ubicacion | string | |
| precioPorNoche | number | |
| estado | string | `Solicitado` → `Aprobado` → `Pagado` → `Disfrutado` / `Cancelado` |
| metodoPago / referenciaPago | string | datos del pago PayPal |
| fecha / fechaPago | timestamp | |

### Colección `usuarios`
Perfil extendido (nombre, teléfono, rol) con el `uid` como id de documento.

---

## 4. Autenticación y seguridad

- **Firebase Authentication** (email/contraseña). El correo se normaliza a
  minúsculas y debe pertenecer a los dominios institucionales.
- **Control de administrador cableado:** `AuthService.adminEmails` es una lista
  fija en el backend del cliente. El modo admin **no** se activa desde la UI;
  `isCurrentUserAdmin` decide qué pestañas se muestran.

---

## 5. Flujo de reservas y pagos

1. `ReservationService.crearReserva(...)` → estado `Solicitado`.
2. Admin: `actualizarEstado(id, 'Aprobado')` desde el panel.
3. Viajero: botón **Pagar** (solo si `Aprobado`) → `PaymentPage`.
4. PayPal Sandbox confirma la captura → `registrarPago(id)` deja la reserva en
   `Pagado` con `metodoPago` y `referenciaPago`.

`PaymentPage` usa interoperabilidad moderna con JS (`dart:js_interop` +
`package:web`) para montar los botones de PayPal en un `HtmlElementView`.

---

## 6. Integración continua (CI/CD)

`.github/workflows/`:
- **deploy.yml** — compila `flutter build web --release` y publica en GitHub
  Pages (rama `gh-pages`) en cada push a `main`.
- **build-apk.yml** — compila `flutter build apk --release` y sube el `.apk`
  como artefacto descargable.

---

## 7. Configuración de Firebase

- `lib/firebase_options.dart` — generado por FlutterFire (web + android).
- `android/app/google-services.json` — credenciales Android.
- Proyecto Firebase: `ecospot-app-450f6`.
- `minSdk = 23` (requerido por `firebase_auth`).

Consulta **INSTALACION.md** para levantar el entorno y compilar.
