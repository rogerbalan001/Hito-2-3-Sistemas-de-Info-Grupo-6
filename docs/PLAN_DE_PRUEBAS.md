# Plan de Pruebas — EcoSpot (Fase 4 / Hito 4)

## 1. Objetivo

Validar que las funcionalidades construidas en las fases anteriores operan
correctamente de extremo a extremo antes del despliegue final, y detectar
errores de funcionalidad, integración y usabilidad.

## 2. Alcance

Se prueban: autenticación, búsqueda y filtrado, detalle de alojamiento, ciclo de
reservas (Solicitado → Aprobado → Pagado), pago con PayPal sandbox, panel de
administración, dashboard, diseño responsivo y la PWA.

## 3. Estrategia

- **Pruebas unitarias / de widget** automatizadas con `flutter test`
  (`test/widget_test.dart`).
- **Pruebas manuales** (funcionales y exploratorias) sobre el build web y el APK.
- **Pruebas de responsividad** en móvil, tablet y escritorio.

Ejecutar las pruebas automatizadas:
```bash
flutter test
```

## 4. Casos de prueba

| ID | Caso | Pasos | Resultado esperado |
|----|------|-------|--------------------|
| CP-01 | Login válido | Ingresar `demo@unimet.edu.ve` / `123456` | Entra al inicio |
| CP-02 | Login inválido | Contraseña incorrecta | Mensaje "Correo o contraseña incorrectos" |
| CP-03 | Registro dominio válido | Correo `@unimet.edu.ve` o `@correo.unimet.edu.ve` | Cuenta creada, entra al inicio |
| CP-04 | Registro dominio inválido | Correo `@gmail.com` | Rechaza el registro |
| CP-05 | Restricción admin | Login con cuenta no-admin | No se muestran pestañas administrativas |
| CP-06 | Acceso admin | Login `admin@unimet.edu.ve` | Aparecen Dashboard y Administración |
| CP-07 | Búsqueda por texto | Escribir un destino | Lista filtrada + contador correcto |
| CP-08 | Filtro por presupuesto | Mover el slider | Solo resultados ≤ presupuesto |
| CP-09 | Catálogo desde Firestore | Abrir Buscar/Inicio | Se muestran los alojamientos sembrados |
| CP-10 | Detalle de alojamiento | Tocar una tarjeta | Fotos, capacidad, transporte y reglas |
| CP-11 | Solicitar reserva | Pulsar Reservar | Reserva en estado **Solicitado** + notificación |
| CP-12 | Aprobar reserva (admin) | Administración → Reservas → Aprobar | Estado pasa a **Aprobado** |
| CP-13 | Botón Pagar | Reservas, reserva Aprobada | Aparece botón **Pagar** |
| CP-14 | Pago PayPal | Pagar con cuenta sandbox | Reserva pasa a **Pagado** |
| CP-15 | Pago con tarjeta | Elegir "Tarjeta" en PayPal | El formulario se ve completo (sin recortes) |
| CP-16 | Admin: editar alojamiento | Administración → Hospedajes → Editar | Cambios persisten en Firestore |
| CP-17 | Admin: eliminar alojamiento | Administración → Hospedajes → Eliminar | Desaparece de la lista |
| CP-18 | Dashboard en vivo | Abrir Dashboard | KPIs de ingresos/reservas reales |
| CP-19 | Reseñas | Comunidad | Se listan reseñas y marca de precio verificado |
| CP-20 | Responsividad | Redimensionar / móvil | Layout se adapta (1–3 columnas) |
| CP-21 | PWA instalable | Chrome móvil → Instalar | Se agrega a la pantalla de inicio |
| CP-22 | APK Android | Instalar `app-release.apk` | La app abre y autentica |

## 5. Pruebas no funcionales

| Tipo | Criterio |
|------|----------|
| Rendimiento | Carga inicial fluida; imágenes con *placeholder* mientras cargan |
| Responsividad | Correcto en móvil (≤640), tablet (≤1000) y escritorio |
| Seguridad | Sesión gestionada por Firebase Auth; admin restringido por backend |
| Disponibilidad | Funciona como PWA offline-shell e instalable |

## 6. Registro de defectos corregidos (Fase 4)

| Defecto | Estado |
|---------|--------|
| Tarjetas de búsqueda en blanco (altura cero por `IntrinsicHeight`) | ✅ Corregido |
| Formulario de tarjeta de PayPal se desbordaba fuera de pantalla | ✅ Corregido |
| Catálogo no leía publicaciones reales de Firestore | ✅ Corregido |
| Pago ocurría sin aprobación del administrador | ✅ Corregido (flujo Solicitado→Aprobado→Pagado) |

## 7. Criterio de aceptación

Todos los casos CP-01 a CP-22 en estado *Aprobado* y sin defectos abiertos de
severidad alta. Cumplido esto, se procede al despliegue final.
