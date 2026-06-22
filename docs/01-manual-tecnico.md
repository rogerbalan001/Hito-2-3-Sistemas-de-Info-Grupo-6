# Manual Técnico – EcoSpot (Hito 4: Transición)

## 1. Introducción
Propósito del documento y alcance de la versión Beta.

## 2. Alcance de la versión Beta
Funcionalidades incluidas / excluidas en esta entrega.

## 3. Arquitectura del sistema
### 3.1 Patrón arquitectónico
MVC + Repository sobre Flutter/Firebase.
### 3.2 Patrones de diseño aplicados
Singleton (servicios), Repository, Adapter (FanvilGateway).

## 4. Pila tecnológica (Stack)
Flutter 3.x, Firebase Auth/Firestore, PayPal JS SDK, Fanvil HTTP API.

## 5. Estructura del proyecto (lib/)
Mapeo de carpetas: pages, services, models, data, theme.

## 6. Módulos del sistema
### 6.1 Autenticación (Firebase Auth)
### 6.2 Catálogo y búsqueda de alojamientos
### 6.3 Reservas (ciclo: Solicitado → Aprobado → Pagado)
### 6.4 Pasarela de pago (PayPal Sandbox)
### 6.5 Acceso por QR e integración con hardware Fanvil

## 7. Modelo de datos (Cloud Firestore)
Colecciones: `reservas`, `alojamientos`, `usuarios`.

## 8. Integraciones externas
### 8.1 PayPal JS SDK (sandbox client-id)
### 8.2 Intercomunicador Fanvil (API HTTP local)

## 9. Seguridad
Reglas de Firestore, manejo de credenciales, validación de tokens QR.

## 10. Diagrama de paquetes
Ver `03-diagrama-paquetes.puml`.

## 11. Mantenimiento y soporte
Contacto del equipo, política de versiones.

## 12. Bibliografía
