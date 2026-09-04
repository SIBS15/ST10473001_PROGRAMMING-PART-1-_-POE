# RaceDay API Endpoint Plan

**PROG6212 - PoE Part 1 - Section B**
This document plans every endpoint the RaceDay Web API will expose in Part 2. No code has been written yet — this is the design that Part 2 must match.

**Role values:** `None` (public), `Any` (any authenticated user), `Organiser`, `Participant`

---

## 1. Authentication

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/auth/register | Creates a new RaceDay account as either an Organiser or a Participant. | None | `{ firstName, lastName, email, password, role }` | 201 Created – new user record; 400 Bad Request – invalid/missing fields; 409 Conflict – email already registered |
| POST | /api/auth/login | Authenticates a user and returns a JWT access token containing their role. | None | `{ email, password }` | 200 OK – token and user summary; 401 Unauthorized – invalid credentials |

## 2. User Profile

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/users/me | Returns the profile of the currently logged-in user. | Any | None | 200 OK – user profile; 401 Unauthorized |
| PUT | /api/users/me | Updates the profile details of the currently logged-in user. | Any | `{ firstName, lastName, phoneNumber }` | 200 OK – updated profile; 400 Bad Request; 401 Unauthorized |

## 3. Events

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/events | Returns a list of all published RaceDay events. | None | None | 200 OK – array of events |
| GET | /api/events/{id} | Returns the details of a specific RaceDay event using the supplied event ID. | None | None | 200 OK – event details; 404 Not Found |
| POST | /api/events | Creates a new RaceDay event owned by the logged-in Organiser. | Organiser | `{ eventName, description, eventDate, location, distance, eventType }` | 201 Created – new event; 400 Bad Request; 401 Unauthorized; 403 Forbidden |
| PUT | /api/events/{id} | Updates an existing event that belongs to the logged-in Organiser. | Organiser | `{ eventName, description, eventDate, location, distance, eventType }` | 200 OK – updated event; 400 Bad Request; 403 Forbidden; 404 Not Found |
| DELETE | /api/events/{id} | Deletes an event that belongs to the logged-in Organiser. | Organiser | None | 204 No Content; 403 Forbidden; 404 Not Found |

## 4. Categories

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/events/{eventId}/categories | Returns all categories available for a specific event. | None | None | 200 OK – array of categories; 404 Not Found |
| POST | /api/events/{eventId}/categories | Creates a new category (e.g. 5km, 10km) for an event the Organiser owns. | Organiser | `{ categoryName, categoryDistance, maxParticipants }` | 201 Created – new category; 400 Bad Request; 403 Forbidden; 404 Not Found |
| PUT | /api/categories/{id} | Updates an existing category belonging to the Organiser's event. | Organiser | `{ categoryName, categoryDistance, maxParticipants }` | 200 OK – updated category; 400 Bad Request; 403 Forbidden; 404 Not Found |
| DELETE | /api/categories/{id} | Deletes a category, provided no participants are enrolled in it. | Organiser | None | 204 No Content; 403 Forbidden; 404 Not Found; 409 Conflict – category has active enrolments |

## 5. Event Enrolments

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/enrolments | Enrols the logged-in Participant into an event under a chosen category. | Participant | `{ eventId, categoryId }` | 201 Created – new enrolment; 400 Bad Request; 401 Unauthorized; 404 Not Found; 409 Conflict – already enrolled |
| GET | /api/enrolments/me | Returns all enrolments belonging to the logged-in Participant. | Participant | None | 200 OK – array of enrolments; 401 Unauthorized |
| GET | /api/events/{eventId}/enrolments | Returns all enrolments for an event owned by the logged-in Organiser. | Organiser | None | 200 OK – array of enrolments; 403 Forbidden; 404 Not Found |
| DELETE | /api/enrolments/{id} | Cancels an enrolment belonging to the logged-in Participant. | Participant | None | 204 No Content; 403 Forbidden; 404 Not Found |

## 6. Results

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/enrolments/{enrolmentId}/results | Captures the finish time and finishing position for a Participant's enrolment. | Organiser | `{ finishTime, finishPosition }` | 201 Created – new result; 400 Bad Request; 403 Forbidden; 404 Not Found; 409 Conflict – result already captured |
| PUT | /api/results/{id} | Corrects a previously captured result. | Organiser | `{ finishTime, finishPosition }` | 200 OK – updated result; 400 Bad Request; 403 Forbidden; 404 Not Found |
| GET | /api/results/me | Returns the logged-in Participant's own race results and performance history. | Participant | None | 200 OK – array of results; 401 Unauthorized |
| GET | /api/events/{eventId}/results | Returns all captured results for an event, for the owning Organiser. | Organiser | None | 200 OK – array of results; 403 Forbidden; 404 Not Found |

---

### Design notes

- All routes are prefixed with `/api/` and use plural resource names for consistency.
- `POST` is reserved for creating new records, `PUT` for full updates, `GET` for retrieval and `DELETE` for removal — no endpoint mixes methods.
- Ownership checks (an Organiser can only modify their own events, categories and results; a Participant can only view/cancel their own enrolments and results) are enforced at the API layer using the JWT role/user claim, returning `403 Forbidden` where relevant.
- This plan matches `RaceDay_ERD.pdf` and `RaceDay_Database.sql` exactly: every resource above maps directly to a table in the database script (Users, Events, Categories, Enrolments, Results). Payments endpoints have been deliberately left out of this Part 1 plan since Payments is a supporting table for the SQL design and is not part of the required Part 1 functional scope — this will be revisited if required in Part 2.
