# RaceDay Event Management System

## Project Description.
RaceDay is a web-based event management system for South African road running, walking and cycling events. It allows Organisers to create and manage events, and allows Participants to discover events, enter them, and track their own results and performance history over time.

This repository contains the **Part 1 (System Planning and Database)**  deliverables for PROG6212 PoE. Part 1 is a planning and  database submission — the API and MVC application have not been built yet; that work is planned here so it can be implemented consistently in Part 2 and Part 3.

## User Roles 

### Organiser
- Create, edit and delete events.
- Manage event categories.
- View event enrolments.
- Capture participant results.
- View information relating to the events they manage.

### Participant
- Create an account and log in.
- Browse available events.
- Enter an event and select a category.
- View their own enrolments.
- Track their own race results and performance history.

## Part 1 Deliverables
- **Entity Relationship Diagram (ERD)** — [`docs/RaceDay_ERD.pdf`](docs/RaceDay_ERD.pdf)
- **API Endpoint Plan** — [`docs/RaceDay_API_Endpoint_Plan.md`](docs/RaceDay_API_Endpoint_Plan.md)
- **SQL Database Script** — [`docs/RaceDay_Database.sql`](docs/RaceDay_Database.sql)

## Repository Structure
```
RaceDay Repository
|
|-- README.md
|
|-- docs
|   |-- RaceDay_ERD.pdf
|   |-- RaceDay_API_Endpoint_Plan.md
|   `-- RaceDay_Database.sql
|
`-- .github
    `-- workflows
        `-- part1-ci.yml
```
The `/docs` folder holds all Part 1 planning documents. The `.github/workflows` folder holds the GitHub Actions CI/CD workflow that validates the repository structure on every push.

## Database Design Summary
The database consists of six entities: **Users** (Organisers and Participants), **Events**, **Categories**, **Enrolments**, **Results** and **Payments**. `Enrolments` is the associative entity that resolves the many-to-many relationship between Participants and Events (via a chosen Category). `Results` and `Payments` each have a one-to-one relationship with `Enrolments`. Full details, attributes, primary keys, foreign keys and cardinality are shown in `docs/RaceDay_ERD.pdf`, and the SQL script matches this design exactly.

## Database Setup
1. Open **SQL Server Management Studio (SSMS)** and connect to a SQL Server instance.
2. Open `docs/RaceDay_Database.sql`.
3. Execute the entire script (it drops and recreates `RaceDayDB` from scratch, so it is safe to run repeatedly on a clean instance).
4. Confirm that all six tables were created under `RaceDayDB` with their primary keys, foreign keys and constraints.
5. Expand the tables and confirm the seed data loaded correctly (2 Organisers, 2 Participants, 3 Events, categories per event, and sample enrolments, results and payments).

## CI/CD
The `part1-ci.yml` GitHub Actions workflow runs on every push and pull request. It checks that the repository structure is correct for Part 1 by confirming that the `/docs` folder exists and that `RaceDay_ERD.pdf`, `RaceDay_API_Endpoint_Plan.md`, `RaceDay_Database.sql` and `README.md` are all present.

**Successful build screenshot:**

_(Insert your green build screenshot here once the workflow has run successfully on GitHub — Actions tab → latest run → screenshot.)_

## Video Demonstration
YouTube Link (Unlisted): `PASTE_YOUR_YOUTUBE_LINK_HERE`
