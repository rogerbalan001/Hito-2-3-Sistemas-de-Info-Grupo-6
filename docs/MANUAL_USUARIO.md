# Manual de Usuario — EcoSpot

**EcoSpot** es una plataforma de turismo *low-cost* y sostenible para la comunidad
de la Universidad Metropolitana. Permite buscar alojamientos económicos (posadas,
campings, etc.), solicitar reservas, pagarlas en línea y dejar reseñas.

> Acceso web (PWA): se abre desde el navegador y puede **instalarse** en el móvil
> sin pasar por una tienda de aplicaciones. También existe un **APK Android**.

---

## 1. Acceso y cuentas

### Iniciar sesión
1. Abre la aplicación.
2. Ingresa tu **correo institucional** y tu contraseña.
3. Pulsa **Iniciar sesión**.

### Registrarse
1. En la pantalla de login, pulsa **Crear cuenta**.
2. El correo debe terminar en `@unimet.edu.ve` o `@correo.unimet.edu.ve`.
3. La contraseña debe tener al menos 6 caracteres.

### Cuentas de prueba
| Rol | Correo | Contraseña |
|-----|--------|-----------|
| Viajero (demo) | `demo@unimet.edu.ve` | `123456` |
| Administrador | `admin@unimet.edu.ve` | `admin123` |

El **modo administrador** no se activa desde la interfaz: está restringido por
backend a correos autorizados. Si tu cuenta no está en la lista, no verás las
pestañas administrativas (Operadores, Dashboard, Administración).

---

## 2. Buscar alojamientos

1. Entra a la pestaña **Buscar**.
2. Escribe un destino o nombre en la barra de búsqueda.
3. Pulsa **Filtros** para ajustar el **presupuesto máximo por noche** con el
   deslizador.
4. El contador muestra cuántos resultados hay. Toca una tarjeta para ver el
   **detalle** (fotos, capacidad, transporte, reglas y descripción).

---

## 3. Reservar y pagar

El ciclo de una reserva tiene cuatro estados:

**Solicitado → Aprobado → Pagado → Disfrutado**

1. Desde la búsqueda, el detalle de un alojamiento o un paquete, pulsa
   **Reservar**. La reserva se crea en estado **Solicitado** y verás una
   notificación de confirmación.
2. Un **administrador** revisa la solicitud y la **Aprueba**.
3. En la pestaña **Reservas**, cuando tu solicitud aparece como **Aprobado**,
   se habilita el botón **Pagar**.
4. Pulsa **Pagar** para abrir la pasarela de **PayPal** (modo *sandbox*, sin
   cobro real). Puedes pagar con cuenta PayPal o con **tarjeta**.
5. Al confirmarse el pago, la reserva pasa a **Pagado**.

> Pago de prueba: usa una cuenta de comprador *sandbox* de PayPal. No se cobra
> dinero real.

---

## 4. Mis Reservas

La pestaña **Reservas** lista tus solicitudes con un color por estado:
- 🟡 **Solicitado** — esperando aprobación del administrador.
- 🔵 **Aprobado** — listo para pagar (aparece el botón **Pagar**).
- 🟢 **Pagado** — pago confirmado.
- 🟢 **Disfrutado** — estadía completada.
- 🔴 **Cancelado** — reserva cancelada.

---

## 5. Comunidad y reseñas

En la pestaña **Comunidad** puedes ver y dejar reseñas. El sistema destaca si el
**precio reportado coincide** con la realidad, para ayudar a otros viajeros.

---

## 6. Paquetes turísticos

La pestaña **Paquetes** muestra experiencias completas a precio cerrado. El flujo
de reserva y pago es el mismo (Solicitado → Aprobado → Pagar).

---

## 7. Instalar la PWA en el móvil

- **Android (Chrome):** menú ⋮ → *Agregar a la pantalla principal* / *Instalar app*.
- **iOS (Safari):** botón *Compartir* → *Agregar a inicio*.

La app quedará como un ícono más en tu teléfono y se abrirá a pantalla completa.

---

## 8. Funciones de administrador

Las cuentas autorizadas ven pestañas adicionales:
- **Dashboard:** métricas en vivo (ingresos, total de reservas) desde la base de datos.
- **Administración:**
  - *Hospedajes:* editar y eliminar alojamientos.
  - *Reservas:* aprobar, marcar como pagada/disfrutada o cancelar (menú ⋮).
  - Tablas de mantenimiento (tipos de reserva, paquetes, transporte, regiones, reseñas).
