# Guía de Instalación y Compilación — EcoSpot

## 1. Requisitos previos

- **Flutter SDK** (canal *stable*) y **Dart** incluido. Verifica con `flutter doctor`.
- **Git**.
- Para Android: **JDK 17** y el **Android SDK** (Android Studio o command-line tools).
- Una cuenta de **Firebase** (el proyecto ya viene configurado: `ecospot-app-450f6`).

## 2. Clonar el repositorio

```bash
git clone https://github.com/rogerbalan001/Hito-2-3-Sistemas-de-Info-Grupo-6.git
cd Hito-2-3-Sistemas-de-Info-Grupo-6
flutter pub get
```

## 3. Ejecutar en desarrollo

### Web (navegador)
```bash
flutter run -d chrome
```

### Android (emulador o dispositivo)
```bash
flutter run -d <id-del-dispositivo>
```

## 4. Compilar para producción

### a) Web / PWA
```bash
flutter build web --release --base-href "/Hito-2-3-Sistemas-de-Info-Grupo-6/"
```
El resultado queda en `build/web/`. El CI lo publica automáticamente en
**GitHub Pages** (rama `gh-pages`) en cada push a `main`.

### b) APK Android
```bash
flutter build apk --release
```
El APK queda en `build/app/outputs/flutter-apk/app-release.apk`.
También se genera automáticamente como **artefacto** en cada push a `main`
(workflow *Compilar APK Android* → pestaña **Actions** → descarga
`ecospot-android-apk`).

> Nota: el build de release usa la *debug key* por defecto (apto para pruebas y
> demostración). Para publicar en Play Store habría que configurar una firma propia.

## 5. Instalar el APK en un teléfono

1. Descarga `app-release.apk` desde Actions (o cópialo por USB).
2. En el teléfono, habilita **Instalar apps de orígenes desconocidos**.
3. Abre el archivo y confirma la instalación.

## 6. Despliegue (hosting)

El despliegue es **automático** vía GitHub Actions (`deploy.yml`) a GitHub Pages.
No requiere pasos manuales: basta con hacer `push` a `main`.

URL de producción: `https://rogerbalan001.github.io/Hito-2-3-Sistemas-de-Info-Grupo-6/`

## 7. Reconfigurar Firebase (opcional)

Si se usa otro proyecto Firebase:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
Esto regenera `lib/firebase_options.dart` y `android/app/google-services.json`.
