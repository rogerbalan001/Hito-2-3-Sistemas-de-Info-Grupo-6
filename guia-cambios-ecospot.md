# Guía de cambios — EcoSpot

Resumen de todo lo corregido y agregado durante esta sesión de depuración, organizado por cambio solicitado.

---

## Cambio 1 — Inicio público sin sesión

**Problema:** al abrir el link, la app siempre mostraba una pantalla de bienvenida (`LandingPage`) en vez del contenido real, y solo se podía ver "Inicio" después de iniciar sesión. Tampoco había forma de bloquear reservas sin sesión, ni de diferenciar lo que ve un Viajero de lo que ve un Administrador.

### Archivos nuevos
- **`lib/utils/auth_guard.dart`** — función `requireLogin(context)` reutilizable. Si no hay sesión activa, muestra un aviso y redirige a `/login`; si hay sesión, deja continuar la acción. Se usa antes de cualquier reserva.

### Archivos modificados
- **`lib/auth_gate.dart`** — ya no decide entre `LandingPage`/`MainShell` según la sesión. Ahora siempre entrega `MainShell`, que internamente decide qué mostrar (Inicio es público).
- **`lib/main_shell.dart`** — el `_UserMenu` (esquina superior derecha) ahora es condicional:
  - **Sin sesión:** botón "Iniciar Sesión" que lleva a `/login`.
  - **Con sesión:** el menú de siempre (avatar + Mi Perfil + Cerrar Sesión). Al cerrar sesión, vuelve al mismo shell (`/home`) en vez de a una landing aparte.
- **`lib/inicio_page.dart`** — el botón **"Registrar mi Servicio"** ahora solo se muestra si `Session.isAdmin.value` es `true` (cuenta Administrador). Un Viajero (con o sin sesión) no lo ve.
- **`lib/accommodation_details_page.dart`, `lib/search_page.dart`, `lib/packages_page.dart`** — cada función `_reservar(...)` ahora empieza con `requireLogin(context, accion: 'reservar')`; sin sesión, no se puede reservar.

### Resultado
Cualquiera puede ver alojamientos, paquetes y la pestaña Inicio sin loguearse. Reservar y "Registrar mi Servicio" quedan protegidos.

---

## Cambio 2 — Perfil, fotos, datos tipo Airbnb y reserva con más datos

Este cambio agrupó **cinco** mejoras relacionadas.

### 2.1 — Bloquear edición de perfil sin usuario
- **`lib/profile_page.dart`** — agrega una guardia: si `AuthService().currentUser == null`, en vez del formulario se muestra un aviso "Debes iniciar sesión..." con botón a `/login`. (El punto de entrada normal —"Mi Perfil" en el menú— ya estaba oculto sin sesión desde el Cambio 1; esto es una segunda capa de protección.)

### 2.2 — Fotos múltiples al publicar un alojamiento (máx. 10)
- **`lib/services/image_upload_service.dart`** *(nuevo)* — selecciona imágenes (`image_picker`) y las sube a Firebase Storage (`firebase_storage`), devolviendo las URLs.
- **`lib/add_accommodation_page.dart`** — agrega una galería de miniaturas con botón "+" para elegir fotos (respeta el límite de 10) y botón "×" para quitarlas antes de publicar. Al guardar, sube las fotos primero y luego crea el alojamiento con las URLs.
- **`lib/models/accommodation.dart`** — nuevo campo `imageUrls` (lista de fotos) y getter `allImages` (galería completa, compatible con los datos mock que solo tienen `imageUrl`).
- **`lib/services/accommodation_service.dart`** — `agregarAlojamiento`/`actualizarAlojamiento` ahora aceptan `imageUrls`.
- **`lib/accommodation_details_page.dart`** — la foto única se reemplazó por un widget `_Galeria` (PageView deslizable + puntos indicadores) cuando hay más de una foto.

### 2.3 — Perfil de usuario extendido
- **`lib/services/profile_service.dart`** — `guardarPerfil`/`obtenerPerfil` ahora manejan: `fotoUrl`, `direccion`, `genero`, `ocupacion`, `fechaNacimiento`, `biografia` (todos opcionales, no se sobreescriben si no se envían).
- **`lib/profile_page.dart`** — el avatar es tocable para elegir/cambiar foto de perfil (sube a Storage al guardar); se agregaron campos de Dirección, Ocupación, Género (dropdown), Fecha de nacimiento (selector de fecha) y Biografía.

### 2.4 — Datos del alojamiento estilo Airbnb/TuInmueble
- **`lib/models/accommodation.dart`** — nuevos campos `bedrooms` (habitaciones), `bathrooms` (baños), `beds` (camas).
- **`lib/add_accommodation_page.dart`** — tres campos numéricos (Habitaciones/Baños/Camas) y una sección de **amenidades** seleccionables con chips: Wifi, Aire acondicionado, Agua caliente, Cocina equipada, Estacionamiento, Piscina, Lavadora, TV, Desayuno incluido, Se permiten mascotas.
- **`lib/accommodation_details_page.dart`** — muestra esos datos como chips junto a precio/capacidad; las amenidades ya se mostraban como lista, ahora se llenan con lo que elige el operador.

### 2.5 — Más datos al reservar + redirección automática
- **`lib/widgets/reservation_extras_sheet.dart`** *(nuevo)* — hoja modal que, tras elegir las fechas, pide **método de pago** (dropdown) y **cantidad de personas** (contador, limitado a la capacidad del alojamiento si se conoce).
- **`lib/services/reservation_service.dart`** — `crearReserva` ahora acepta `cantidadPersonas`.
- **`lib/accommodation_details_page.dart`, `lib/search_page.dart`, `lib/packages_page.dart`** — al confirmar la reserva (fechas + método de pago + personas), la app navega automáticamente a la pestaña **"Mis Reservas"** (`MainShell(initialIndex: 3)`), reemplazando toda la pila de navegación para que funcione sin importar desde dónde se reservó.
- **`lib/my_reservations_page.dart`** — cada tarjeta de reserva ahora muestra también la cantidad de personas y el método de pago elegidos.

### Dependencias nuevas (`pubspec.yaml`)
```yaml
firebase_storage: ^12.3.0
image_picker: ^1.1.2
```

---

## Pendientes antes de probar en producción

1. **Habilitar Firebase Storage** en la consola de Firebase del proyecto (Build → Storage → Comenzar). Sin esto, la subida de fotos (perfil y alojamientos) fallará.
2. **Correr `flutter pub get`** para descargar las dos dependencias nuevas.
3. **Reglas de seguridad de Storage**: por defecto Firebase Storage exige reglas explícitas; como mínimo, permite lectura pública y escritura solo a usuarios autenticados, por ejemplo:
   ```
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /{allPaths=**} {
         allow read: if true;
         allow write: if request.auth != null;
       }
     }
   }
   ```
4. **Subir los cambios** (commit + push a `main`) para que el workflow de GitHub Actions compile y despliegue.

---

## Mapa completo de archivos tocados

| Archivo | Tipo | Cambio 1 | Cambio 2 |
|---|---|---|---|
| `pubspec.yaml` | modificado | | ✅ |
| `lib/auth_gate.dart` | modificado | ✅ | |
| `lib/main_shell.dart` | modificado | ✅ | |
| `lib/inicio_page.dart` | modificado | ✅ | |
| `lib/utils/auth_guard.dart` | **nuevo** | ✅ | |
| `lib/accommodation_details_page.dart` | modificado | ✅ | ✅ |
| `lib/search_page.dart` | modificado | ✅ | ✅ |
| `lib/packages_page.dart` | modificado | ✅ | ✅ |
| `lib/profile_page.dart` | modificado | | ✅ |
| `lib/services/profile_service.dart` | modificado | | ✅ |
| `lib/services/image_upload_service.dart` | **nuevo** | | ✅ |
| `lib/models/accommodation.dart` | modificado | | ✅ |
| `lib/services/accommodation_service.dart` | modificado | | ✅ |
| `lib/add_accommodation_page.dart` | modificado | | ✅ |
| `lib/widgets/reservation_extras_sheet.dart` | **nuevo** | | ✅ |
| `lib/services/reservation_service.dart` | modificado | | ✅ |
| `lib/my_reservations_page.dart` | modificado | | ✅ |
