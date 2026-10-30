@echo off
setlocal
where mvn >nul 2>nul
if errorlevel 1 (
  echo Maven is not installed or is not on PATH.
  echo Install Apache Maven 3.9+ or use an IDE with Maven support, then rerun this command.
  exit /b 1
)
call mvn %*
exit /b %ERRORLEVEL%
