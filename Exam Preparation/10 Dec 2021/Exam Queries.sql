--Model Definition
CREATE TABLE Passengers
(
Id INT PRIMARY KEY IDENTITY,
FullName VARCHAR(100) UNIQUE NOT NULL,
Email VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Pilots
(
Id INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(30) UNIQUE NOT NULL,
LastName VARCHAR(30) UNIQUE NOT NULL,
Age TINYINT CHECK(Age BETWEEN 21 AND 62) NOT NULL,
Rating FLOAT CHECK(Rating BETWEEN 0.0 AND 10.0)
)

CREATE TABLE AircraftTypes
(
Id INT PRIMARY KEY IDENTITY,
TypeName VARCHAR(30) UNIQUE NOT NULL
)

CREATE TABLE Aircraft
(
Id INT PRIMARY KEY IDENTITY,
Manufacturer VARCHAR(25) NOT NULL,
Model VARCHAR(30) NOT NULL,
[Year] INT NOT NULL,
FlightHours INT,
Condition CHAR(1) NOT NULL,
TypeId INT FOREIGN KEY REFERENCES AircraftTypes(Id) NOT NULL
)

CREATE TABLE PilotsAircraft
(
AircraftId INT FOREIGN KEY REFERENCES Aircraft(Id),
PilotId INT FOREIGN KEY REFERENCES Pilots(Id),
PRIMARY KEY (AircraftId, PilotId)
)

CREATE TABLE Airports
(
Id INT PRIMARY KEY IDENTITY,
AirportName VARCHAR(70) UNIQUE NOT NULL,
Country VARCHAR(100) UNIQUE NOT NULL
)

CREATE TABLE FlightDestinations
(
Id INT PRIMARY KEY IDENTITY,
AirportId INT FOREIGN KEY REFERENCES Airports(Id) NOT NULL,
[Start] DATETIME NOT NULL,
AircraftId INT FOREIGN KEY REFERENCES Aircraft(Id) NOT NULL,
PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL,
TicketPrice DECIMAL(18, 2) DEFAULT 15 NOT NULL
)

--Insert
INSERT INTO Passengers (FullName, Email)
SELECT 
	CONCAT(FirstName, ' ', LastName),
	CONCAT(FirstName, LastName, '@gmail.com')
FROM Pilots 
	WHERE Id BETWEEN 5 AND 15

--Update
UPDATE Aircraft
	SET Condition = 'A'
WHERE Condition IN ('C', 'B') AND (FlightHours IS NULL OR FlightHours <= 100) AND [Year] >= 2013

--Delete
DELETE Passengers
	WHERE LEN([FullName]) <= 10

--Problem 5
SELECT Manufacturer, 
	Model, 
	FlightHours, 
	Condition 
FROM Aircraft 
	ORDER BY FlightHours DESC

--Problem 6
SELECT
	pl.FirstName,
	pl.LastName,
	a.Manufacturer,
	a.Model,
	a.FlightHours
FROM Pilots AS pl
	INNER JOIN PilotsAircraft AS pa ON pl.Id = pa.PilotId
	INNER JOIN Aircraft AS a ON a.Id = pa.AircraftId
WHERE a.FlightHours < 304
	ORDER BY a.FlightHours DESC, pl.FirstName

--Problem 7
SELECT TOP 20
	fd.Id,
	fd.[Start],
	p.FullName,
	ap.AirportName,
	fd.TicketPrice
FROM Airports AS ap
	INNER JOIN FlightDestinations AS fd ON ap.Id = fd.AirportId
	INNER JOIN Passengers AS p ON fd.PassengerId = p.Id
WHERE DAY(fd.[Start]) % 2 = 0
	ORDER BY fd.TicketPrice DESC, ap.AirportName

--Problem 8
SELECT
	a.Id, 
	a.Manufacturer,
	a.FlightHours,
	COUNT(fd.Id) AS FlightDestinationsCount,
	ROUND(AVG(fd.TicketPrice), 2) AS AvgPrice
FROM Aircraft AS a
	 JOIN FlightDestinations AS fd ON a.Id = fd.AircraftId
GROUP BY a.Id, a.Manufacturer, a.FlightHours
	HAVING COUNT(fd.Id) >= 2
ORDER BY FlightDestinationsCount DESC, a.Id

--Problem 9
SELECT
	p.FullName,
	COUNT(a.Id) AS CountOfAircraft,
	SUM(fd.TicketPrice) AS TotalPayed
FROM Passengers AS p
	INNER JOIN FlightDestinations AS fd ON fd.PassengerId = p.Id
	INNER JOIN Aircraft AS a ON a.Id = fd.AircraftId
		WHERE SUBSTRING(p.FullName, 2, 1) = 'a'
GROUP BY p.FullName
	HAVING COUNT(a.Id) > 1
	ORDER BY p.FullName

--Problem 10
SELECT
	a.AirportName,
	fd.[Start] AS DayTime,
	fd.TicketPrice,
	p.FullName,
	ac.Manufacturer,
	ac.Model
FROM FlightDestinations AS fd
	JOIN Airports AS a ON a.Id = fd.AirportId
	JOIN Passengers AS p ON fd.PassengerId = p.Id
	JOIN Aircraft AS ac ON ac.Id = fd.AircraftId
WHERE DATEPART(HOUR, fd.[Start])BETWEEN 6 AND 20 
	AND fd.TicketPrice >= 2500
ORDER BY ac.Model

--Problem 11
CREATE FUNCTION udf_FlightDestinationsByEmail(@email VARCHAR(50))
RETURNS INT
AS BEGIN
	RETURN(SELECT
		COUNT(p.Id)
	FROM Passengers AS p
			JOIN FlightDestinations AS fd ON p.Id = fd.PassengerId
		WHERE p.Email = @email)

END

--Problem 12
CREATE PROC usp_SearchByAirportName(@airportName VARCHAR(70))
AS
BEGIN
	SELECT
		ap.AirportName,
		p.FullName,
		CASE WHEN fd.TicketPrice <= 400 THEN 'Low'
			WHEN fd.TicketPrice BETWEEN 401 AND 1500 THEN 'Medium'
			ELSE 'High' END AS LevelOfTickerPrice,
		ac.Manufacturer,
		ac.Condition,
		ay.TypeName
	FROM Aircraft AS ar
		JOIN FlightDestinations AS fd ON ar.Id = fd.AircraftId
		JOIN Airports AS ap ON fd.AirportId = ap.Id
		JOIN Passengers AS p ON p.Id = fd.PassengerId
		JOIN Aircraft AS ac ON fd.AircraftId = ac.Id
		JOIN AircraftTypes AS ay ON ac.TypeId = ay.Id
	WHERE ap.AirportName = @airportName
		ORDER BY ac.Manufacturer, p.FullName

END

