# ChargeShare — Community EV Charging Platform

ChargeShare is a student demonstration project using Flutter Web, Java 21, Spring Boot 3.4.3, Spring Data JPA and a file-based H2 database.

## Run on Windows

### 1. Start the backend
Open PowerShell in `C:\ChargeShare\backend` and run:

```powershell
mvn spring-boot:run
```

The API listens on `http://localhost:8080`. Keep this terminal open.

### 2. Start the Flutter web app
Open a second PowerShell window:

```powershell
cd C:\ChargeShare\frontend
flutter pub get
flutter run -d edge --dart-define=API_BASE_URL=http://localhost:8080/api
```

## Demo accounts

Select the matching role on the login page:

| Role | Email | Password |
|---|---|---|
| Admin | `admin@chargeshare.demo` | `Admin123!` |
| Host | `host@chargeshare.demo` | `Host123!` |
| EV user | `user@chargeshare.demo` | `User123!` |

These credentials are for a local classroom demonstration only. Change them before any public deployment. Admin accounts cannot self-register; users and hosts can register from the login page.

## Role features

- **Admin:** platform overview, all locations, user/host account suspension, booking overview, demo payment records, and location management.
- **Host:** availability toggle, view bookings for assigned locations, accept/reject pending requests, cancel relevant bookings, and view earnings/payment records.
- **EV user:** search/filter charging locations, request a booking, modify/cancel their own booking, and make an in-app simulated payment after host acceptance.

The backend checks bearer-session tokens and role/ownership permissions for protected API operations. The in-app payment is a **simulation**; it does not charge real money and does not integrate with a payment provider.

## API outline

- `POST /api/auth/login`, `POST /api/auth/register`, `POST /api/auth/logout`
- `GET /api/locations`, `POST/PUT/DELETE /api/locations`
- `GET/POST /api/bookings`, `PUT /api/bookings/{id}`, `PATCH /api/bookings/{id}/accept|reject|cancel`
- `GET /api/payments`, `POST /api/payments/booking/{id}/demo`
- `GET /api/admin/users`, `PATCH /api/admin/users/{id}/enabled`, `GET /api/admin/summary`

## Notes

- Sessions are held in backend memory and expire when the backend restarts; sign in again after restart.
- H2 stores application data in `backend/data/chargeshare-db`.
- This is a classroom/demo implementation, not a production security or payment system.
