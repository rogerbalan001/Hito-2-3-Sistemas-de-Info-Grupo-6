# Manual de Instalación – EcoSpot

## 1. Requisitos previos
Flutter SDK >=3.0.0, Dart >=3.0.0, cuenta Firebase, cuenta PayPal Developer (Sandbox).

## 2. Clonar el repositorio
git clone https://github.com/rogerbalan001/Hito-2-3-Sistemas-de-Info-Grupo-6.git

## 3. Instalación del entorno Flutter
flutter pub get

## 4. Configuración de Firebase
flutterfire configure (genera firebase_options.dart)

## 5. Configuración de credenciales de PayPal Sandbox
Reemplazar `sandboxClientId` en `lib/services/paypal_service.dart`.

## 6. Configuración del hardware Fanvil
IP del dispositivo en red local, API key, puerto del intercomunicador.

## 7. Ejecución en ambiente local
flutter run -d chrome

## 8. Compilación de la versión Beta
flutter build web --release

## 9. Despliegue (GitHub Pages / Firebase Hosting)
Ver `.github/workflows/deploy.yml`.

## 10. Verificación post-instalación
Checklist: login, búsqueda, reserva, pago, apertura QR.

## 11. Solución de problemas comunes (Troubleshooting)
