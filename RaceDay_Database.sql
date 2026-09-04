

IF DB_ID('RaceDayDB') IS NOT NULL
BEGIN
    ALTER DATABASE RaceDayDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RaceDayDB;
END


CREATE DATABASE RaceDayDB;


USE RaceDayDB;



CREATE TABLE Users (
    UserID          INT IDENTITY(1,1) PRIMARY KEY,
    Role            VARCHAR(20)   NOT NULL
                    CONSTRAINT CK_Users_Role CHECK (Role IN ('Organiser','Participant')),
    FirstName       VARCHAR(50)   NOT NULL,
    LastName        VARCHAR(50)   NOT NULL,
    Email           VARCHAR(100)  NOT NULL,
    PasswordHash    VARCHAR(255)  NOT NULL,
    PhoneNumber     VARCHAR(20)   NULL,
    CreatedAt       DATETIME      NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT (GETDATE()),
    CONSTRAINT UQ_Users_Email UNIQUE (Email)
);


/* =====================================================================
   2. EVENTS
   Each Event is created and managed by one Organiser (a User with
   Role = 'Organiser').
   ===================================================================== */
CREATE TABLE Events (
    EventID         INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserID     INT             NOT NULL,
    EventName       VARCHAR(100)    NOT NULL,
    Description     VARCHAR(500)    NULL,
    EventDate       DATE            NOT NULL,
    Location        VARCHAR(150)    NOT NULL,
    Distance        DECIMAL(6,2)    NULL,
    EventType       VARCHAR(20)     NOT NULL
                    CONSTRAINT CK_Events_EventType CHECK (EventType IN ('Running','Walking','Cycling')),
    CreatedAt       DATETIME        NOT NULL CONSTRAINT DF_Events_CreatedAt DEFAULT (GETDATE()),
    CONSTRAINT FK_Events_Organiser FOREIGN KEY (OrganiserID) REFERENCES Users(UserID)
);


/* =====================================================================
   3. CATEGORIES
   Each Category belongs to exactly one Event (e.g. 5km, 10km, 21km).
   ===================================================================== */
CREATE TABLE Categories (
    CategoryID      INT IDENTITY(1,1) PRIMARY KEY,
    EventID         INT             NOT NULL,
    CategoryName    VARCHAR(50)     NOT NULL,
    CategoryDistance DECIMAL(6,2)   NOT NULL,
    MaxParticipants INT             NOT NULL CONSTRAINT DF_Categories_Max DEFAULT (500),
    CONSTRAINT FK_Categories_Event FOREIGN KEY (EventID) REFERENCES Events(EventID)
);


/* =====================================================================
   4. ENROLMENTS
   Associative entity resolving the many-to-many relationship between
   Participants and Events (via a chosen Category).
   ===================================================================== */
CREATE TABLE Enrolments (
    EnrolmentID     INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantID   INT             NOT NULL,
    EventID         INT             NOT NULL,
    CategoryID      INT             NOT NULL,
    EnrolmentDate   DATETIME        NOT NULL CONSTRAINT DF_Enrolments_Date DEFAULT (GETDATE()),
    Status          VARCHAR(20)     NOT NULL
                    CONSTRAINT DF_Enrolments_Status DEFAULT ('Confirmed')
                    CONSTRAINT CK_Enrolments_Status CHECK (Status IN ('Pending','Confirmed','Cancelled')),
    CONSTRAINT FK_Enrolments_Participant FOREIGN KEY (ParticipantID) REFERENCES Users(UserID),
    CONSTRAINT FK_Enrolments_Event FOREIGN KEY (EventID) REFERENCES Events(EventID),
    CONSTRAINT FK_Enrolments_Category FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CONSTRAINT UQ_Enrolments_Participant_Event UNIQUE (ParticipantID, EventID)
);


/* =====================================================================
   5. RESULTS
   One Result per Enrolment, captured by an Organiser once the
   Participant has finished the race.
   ===================================================================== */
CREATE TABLE Results (
    ResultID              INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentID           INT         NOT NULL,
    FinishTime            TIME        NULL,
    FinishPosition         INT         NULL,
    CapturedByOrganiserID INT         NOT NULL,
    CapturedDate           DATETIME    NOT NULL CONSTRAINT DF_Results_CapturedDate DEFAULT (GETDATE()),
    CONSTRAINT FK_Results_Enrolment FOREIGN KEY (EnrolmentID) REFERENCES Enrolments(EnrolmentID),
    CONSTRAINT FK_Results_Organiser FOREIGN KEY (CapturedByOrganiserID) REFERENCES Users(UserID),
    CONSTRAINT UQ_Results_Enrolment UNIQUE (EnrolmentID)
);


/* =====================================================================
   6. PAYMENTS
   One Payment per Enrolment, recording the entry fee transaction.
   ===================================================================== */
CREATE TABLE Payments (
    PaymentID       INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentID     INT             NOT NULL,
    Amount          DECIMAL(8,2)    NOT NULL,
    PaymentDate     DATETIME        NOT NULL CONSTRAINT DF_Payments_Date DEFAULT (GETDATE()),
    PaymentMethod   VARCHAR(20)     NOT NULL
                    CONSTRAINT CK_Payments_Method CHECK (PaymentMethod IN ('Card','EFT','InstantEFT')),
    PaymentStatus   VARCHAR(20)     NOT NULL
                    CONSTRAINT DF_Payments_Status DEFAULT ('Paid')
                    CONSTRAINT CK_Payments_Status CHECK (PaymentStatus IN ('Pending','Paid','Refunded')),
    CONSTRAINT FK_Payments_Enrolment FOREIGN KEY (EnrolmentID) REFERENCES Enrolments(EnrolmentID),
    CONSTRAINT UQ_Payments_Enrolment UNIQUE (EnrolmentID)
);



/* =====================================================================
   SEED DATA
   ===================================================================== */

-- 2 Organisers + 2 Participants (Users)
INSERT INTO Users (Role, FirstName, LastName, Email, PasswordHash, PhoneNumber) VALUES
('Organiser',  'Thandeka', 'Nkosi',    'thandeka.nkosi@raceday.co.za', 'hashed_pw_001', '0821234567'),
('Organiser',  'Pieter',   'van Wyk',  'pieter.vanwyk@raceday.co.za',  'hashed_pw_002', '0837654321'),
('Participant','Lindiwe',  'Mokoena',  'lindiwe.mokoena@gmail.com',    'hashed_pw_003', '0731122334'),
('Participant','Johan',    'Botha',    'johan.botha@gmail.com',        'hashed_pw_004', '0845566778');


-- 3 Events (created by the two Organisers)
INSERT INTO Events (OrganiserID, EventName, Description, EventDate, Location, Distance, EventType) VALUES
(1, 'Gqeberha Bay Marathon',      'Coastal marathon along the Gqeberha beachfront.', '2026-10-04', 'Gqeberha, Eastern Cape', 42.2, 'Running'),
(1, 'Nelson Mandela Bay Fun Walk','Family-friendly fun walk supporting local charities.', '2026-09-20', 'Humewood, Gqeberha', 5.0, 'Walking'),
(2, 'Cape Winelands Cycle Tour',  'Scenic cycling tour through the Cape Winelands.', '2026-11-08', 'Stellenbosch, Western Cape', 94.7, 'Cycling');


-- Categories for each Event
INSERT INTO Categories (EventID, CategoryName, CategoryDistance, MaxParticipants) VALUES
(1, 'Full Marathon', 42.2, 1000),
(1, 'Half Marathon', 21.1, 1500),
(2, '5km Fun Walk',  5.0,  2000),
(2, '10km Fun Walk', 10.0, 1000),
(3, '94.7km Challenge', 94.7, 800),
(3, '50km Amateur',     50.0, 1200);


-- Sample Enrolments (Participants entering Events with a chosen Category)
INSERT INTO Enrolments (ParticipantID, EventID, CategoryID, Status) VALUES
(3, 1, 2, 'Confirmed'),  -- Lindiwe enters the Half Marathon
(4, 1, 1, 'Confirmed'),  -- Johan enters the Full Marathon
(3, 2, 3, 'Confirmed'),  -- Lindiwe enters the 5km Fun Walk
(4, 3, 6, 'Confirmed');  -- Johan enters the 50km Cycle Challenge


-- Sample Results (only for Events that have already taken place, for illustration)
INSERT INTO Results (EnrolmentID, FinishTime, FinishPosition, CapturedByOrganiserID) VALUES
(3, '00:28:14', 12, 1); -- Lindiwe's 5km Fun Walk result, captured by Organiser Thandeka

-- Sample Payments for every Enrolment
INSERT INTO Payments (EnrolmentID, Amount, PaymentMethod, PaymentStatus) VALUES
(1, 350.00, 'Card',       'Paid'),
(2, 450.00, 'EFT',        'Paid'),
(3, 120.00, 'InstantEFT', 'Paid'),
(4, 900.00, 'Card',       'Paid');


