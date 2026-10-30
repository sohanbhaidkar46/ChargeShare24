@echo off
setlocal
cd /d "%~dp0frontend"
echo ========================================
echo ChargeShare - Flutter Frontend (Edge)
echo ========================================
where flutter >nul 2>nul || (echo ERROR: Flutter is not installed or not on PATH. Install Flutter SDK and reopen this terminal. & pause & exit /b 1)
flutter pub get
if errorlevel 1 (echo ERROR: Flutter dependencies could not be downloaded. Check internet and pubspec.yaml. & pause & exit /b 1)
flutter run -d edge --dart-define=API_BASE_URL=http://localhost:8080/api
pause
