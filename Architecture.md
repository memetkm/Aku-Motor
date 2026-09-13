Build a simple full-stack web application named **Aku Motor**.

Purpose:
Help motorcycle owners track when parts must be replaced and understand what happens if those parts are ignored. The application stores motorcycle data, part status, service history, usage profiles, and educational content, then shows reminders plus part status on a dashboard.

Use this stack:

- Frontend: React + TypeScript + Vite + Tailwind CSS
- Backend: Node.js + TypeScript + Express
- Database: MySQL
- ORM: Prisma
- API style: REST API
- Use Docker Compose for MySQL
- Use `.env.example` for the database URL

Code rules:

- Do not add comments unless truly necessary.
- Use PascalCase for all classes, types, interfaces, enums, React components, database models, API DTOs, and JSON property names.
- Local variables may use camelCase.
- Keep code lines below 150 characters where practical.
- Use a clean and simple folder structure.
- Do not add authentication in this first version. Assume one owner uses the application.

Main entities:

1. Motor

   * Id
   * Brand
   * Model
   * Year
   * CurrentKilometer
   * CreatedAt
   * UpdatedAt

2. Part

   * Id
   * MotorId
   * PartType
   * LastReplacedAt
   * LastReplacedKilometer
   * IntervalKilometer
   * IntervalMonth
   * Status
   * CreatedAt
   * UpdatedAt

3. ServiceHistory

   * Id
   * MotorId
   * PartId
   * PartType
   * ReplacedAt
   * ReplacedKilometer
   * Cost
   * Notes
   * CreatedAt

4. UsageProfile

   * Id
   * MotorId
   * KilometerPerDay
   * Terrain
   * DrivingStyle
   * OftenPassenger
   * OftenRain
   * CreatedAt
   * UpdatedAt

5. PartEducation

   * Id
   * PartType
   * MotorBrand
   * MotorModel
   * ConsequenceLight
   * ConsequenceMedium
   * ConsequenceFatal
   * CostNow
   * CostLater
   * CreatedAt

Database rules:

* A ServiceHistory must be unique by `MotorId`, `PartId`, and `ReplacedAt`.
* Never delete existing service history data.
* Never replace existing service history records.
* When a new service history is inserted, update the related Part with the new `LastReplacedAt`, `LastReplacedKilometer`, and `Status`.
* Update `UpdatedAt` on Motor whenever Part, ServiceHistory, or UsageProfile data changes.
* Use Prisma migrations and seed one example motor, five parts, three service histories, one usage profile, and five part education entries.

Backend features:

1. CRUD Motor

   * Create, list, detail, update, delete motor.

2. CRUD Part

   * Create, list, detail, update, delete part inside a motor.
   * Compute `Status` automatically from `LastReplacedKilometer`, `CurrentKilometer`, `IntervalKilometer`, `LastReplacedAt`, `IntervalMonth`, and the related UsageProfile.

3. CRUD Service History

   * Record part replacement history.
   * After creation, update the related Part status.

4. Usage Profile

   * Store how the motorcycle is used: kilometer per day, terrain, driving style, often carrying a passenger, often riding in rain.

5. Reminder and Status API

   * Endpoint to fetch the status of all parts in a motor.
   * Recompute status whenever data changes.
   * Return a result containing:

     * PartId
     * PartType
     * Status
     * RemainingKilometer
     * RemainingDays
     * ConsequenceSummary
     * CostNow
     * CostLater
     * Message

6. Education API

   * Endpoint to fetch educational content per `PartType` and motor model.
   * Fall back to generic content when the motor model is not found.

7. Dashboard API

   * Return a motor summary:

     * TotalParts
     * SafeParts
     * WarningParts
     * UrgentParts
     * TotalServiceHistory
     * LastServiceAt
   * Return the list of part statuses:

     * PartId
     * PartType
     * Status
     * RemainingKilometer
     * RemainingDays
     * ConsequenceSummary
   * Status rules:

     * `SAFE`: remaining kilometer and remaining days are still far
     * `WARNING`: remaining kilometer or remaining days is close to the limit
     * `URGENT`: remaining kilometer or remaining days has passed or is very close

Frontend pages:

1. Dashboard

   * Motor selector.
   * Summary cards: total parts, safe parts, warning parts, urgent parts, total service history, last service date.
   * Table showing each part: part name, status, remaining kilometer, remaining days, short consequence.
   * Button: `Lihat Detail` on each part.
   * Dashboard reads only from the MySQL database when opened. It must not call any external API automatically.

2. Motor Management

   * List motors.
   * Form to create and edit motors (brand, model, year, current kilometer).
   * Button to open the motor dashboard.

3. Part Management

   * List parts in the selected motor.
   * Form to add and edit parts (type, last replaced date, last replaced kilometer, interval kilometer, interval month).
   * Show part status with a colored badge.

4. Service History Management

   * List service history per motor.
   * Form to add service history (part, date, kilometer, cost, notes).
   * After saving, the related part status is updated automatically.

5. Usage Profile

   * Form to edit usage: kilometer per day, terrain, driving style, often carrying a passenger, often riding in rain.
   * Changes affect part status computation.

6. Part Education Detail

   * Show part information.
   * Show consequences if ignored in three levels: light, medium, fatal.
   * Show cost now versus cost later.
   * Button: `Sudah Diganti` to open the service history form.

UI requirements:

* Use Indonesian language for all labels, buttons, messages, and validation.
* Create a clean, responsive owner dashboard.
* Use simple tables, cards, badges, forms, confirmation dialog before delete, and empty states.
* Use status badge colors:

  * Safe: green
  * Warning: orange
  * Urgent: red
* Do not add charts in the first version.

Required API routes:

* `GET /api/motors`
* `POST /api/motors`
* `GET /api/motors/:Id`
* `PUT /api/motors/:Id`
* `DELETE /api/motors/:Id`
* `GET /api/motors/:MotorId/parts`
* `POST /api/motors/:MotorId/parts`
* `PUT /api/parts/:Id`
* `DELETE /api/parts/:Id`
* `GET /api/motors/:MotorId/service-history`
* `POST /api/motors/:MotorId/service-history`
* `GET /api/motors/:MotorId/usage-profile`
* `PUT /api/motors/:MotorId/usage-profile`
* `GET /api/motors/:MotorId/dashboard`
* `GET /api/parts/:Id/education`
* `GET /api/part-education`

Deliverables:

* Complete frontend and backend source code.
* Prisma schema, migration, and seed data.
* Docker Compose file for MySQL.
* `.env.example`.
* README with installation, database migration, seed, frontend/backend startup, Docker usage, and environment configuration.
* Ensure the application builds successfully and all basic CRUD plus part status computation work.

Project structure:

* Use a TypeScript monorepo with npm workspaces.
* Structure:

```text
aku-motor/
  apps/
    web/
    api/
  packages/
    shared/
```

Shared package requirements:

* Create `packages/shared` as `@aku-motor/shared`.
* Store all shared domain models, enums, API response types, and shared constants here.
* Both `apps/web` and `apps/api` must import shared types from this package.
* Do not duplicate domain model definitions between frontend and backend.

Example shared files:

```text
packages/shared/src/
  models/
    Motor.ts
    Part.ts
    ServiceHistory.ts
    UsageProfile.ts
    PartEducation.ts
  enums/
    PartType.ts
    PartStatus.ts
    Terrain.ts
    DrivingStyle.ts
  dto/
    MotorDashboardResponse.ts
    PartStatusResponse.ts
    EducationResponse.ts
  index.ts
```

Model rules:

* Define shared TypeScript interfaces or types only once in `packages/shared`.
* Example: `Motor`, `Part`, `ServiceHistory`, `PartType`, and `PartStatus` must be imported by both frontend and backend from `@aku-motor/shared`.
* Prisma models remain in the backend because they are database-specific.
* The backend maps Prisma entities to shared API models before returning responses.
* The frontend must not import Prisma types.
* Configure TypeScript paths, workspace dependencies, build scripts, and development scripts correctly so all packages compile successfully.
