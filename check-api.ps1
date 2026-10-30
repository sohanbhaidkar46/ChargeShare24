$ErrorActionPreference = 'Stop'
$base = 'http://localhost:8080/api'
Write-Host 'Checking ChargeShare role-based API...' -ForegroundColor Cyan
try {
  $loginBody = @{ email = 'admin@chargeshare.demo'; password = 'Admin123!'; role = 'ADMIN' } | ConvertTo-Json
  $login = Invoke-RestMethod -Method Post -Uri "$base/auth/login" -ContentType 'application/json' -Body $loginBody
  $headers = @{ Authorization = "Bearer $($login.token)" }
  $locations = Invoke-RestMethod -Uri "$base/locations" -Headers $headers
  Write-Host "Login OK as $($login.role)." -ForegroundColor Green
  Write-Host "Locations endpoint OK: $($locations.Count) location(s) returned." -ForegroundColor Green
  $bookings = Invoke-RestMethod -Uri "$base/bookings" -Headers $headers
  Write-Host "Bookings endpoint OK: $($bookings.Count) booking(s) returned." -ForegroundColor Green
  $summary = Invoke-RestMethod -Uri "$base/admin/summary" -Headers $headers
  Write-Host "Admin summary OK: $($summary.users) account(s), $($summary.locations) location(s)." -ForegroundColor Green
  Write-Host 'API smoke check passed.' -ForegroundColor Green
} catch {
  Write-Host 'API check failed. Make sure the updated backend is running on port 8080.' -ForegroundColor Red
  Write-Host $_.Exception.Message
  exit 1
}
