# Manual de Instalación — EcoSpot

## Requisitos previos
- Flutter SDK (canal stable) instalado y en el PATH
- Google Chrome instalado
- Git

Verificar instalación:
```bash
flutter doctor
```

## 1. Clonar el repositorio
```bash
git clone https://github.com/Isolar03/Hito-2-3-Sistemas-de-Info-Grupo-6.git
cd Hito-2-3-Sistemas-de-Info-Grupo-6
```

## 2. Instalar dependencias
```bash
flutter pub get
```

## 3. Ejecutar en modo desarrollo (web)
```bash
flutter run -d chrome
```
Esto compila en modo debug y abre la app en una pestaña de Chrome con hot reload activo.

## 4. Compilar para producción web
```bash
flutter build web --release
```
El resultado queda en `build/web/`, listo para desplegar en cualquier hosting estático (Firebase Hosting, Netlify, GitHub Pages).

## 5. Servir el build de producción localmente (opcional)
```bash
cd build/web
python3 -m http.server 8080
```
Abrir `http://localhost:8080` en el navegador.

## Solución de problemas comunes
- **"No supported devices found"**: ejecutar `flutter config --enable-web` y reiniciar el editor.
- **Errores de dependencias**: borrar `pubspec.lock` y volver a correr `flutter pub get`.
