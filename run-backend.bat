@echo off
setlocal
cd /d "%~dp0backend"
echo ========================================
echo ChargeShare - Java Spring Boot Backend
echo ========================================
where java >nul 2>nul || (echo ERROR: Java is not installed or not on PATH. Install JDK 21. & pause & exit /b 1)
where mvn >nul 2>nul
if not errorlevel 1 (
  mvn spring-boot:run
  goto done
)
if exist "C:\Tools\apache-maven-3.9.16-bin\apache-maven-3.9.16\bin\mvn.cmd" (
  call "C:\Tools\apache-maven-3.9.16-bin\apache-maven-3.9.16\bin\mvn.cmd" spring-boot:run
  goto done
)
echo ERROR: Maven was not found on PATH or at the expected C:\Tools path.
pause
exit /b 1
:done
pause
