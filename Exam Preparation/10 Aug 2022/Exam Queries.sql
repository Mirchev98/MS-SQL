--Model Definition
CREATE TABLE Categories
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Locations
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
Municipality VARCHAR(50),
Province VARCHAR(50)
)

CREATE TABLE Sites
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(100) NOT NULL,
LocationId INT FOREIGN KEY REFERENCES Locations(Id) NOT NULL,
CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
Establishment VARCHAR(15)
)

CREATE TABLE Tourists
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
Age INT CHECK (Age BETWEEN 0 AND 120) NOT NULL,
PhoneNumber VARCHAR(20) NOT NULL,
Nationality VARCHAR(30) NOT NULL,
Reward VARCHAR (20)
)

CREATE TABLE SitesTourists
(
TouristId INT FOREIGN KEY REFERENCES Tourists(Id),
SiteId INT FOREIGN KEY REFERENCES Sites(Id),
PRIMARY KEY(TouristId, SiteId)
)

CREATE TABLE BonusPrizes
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE TouristsBonusPrizes
(
TouristId INT FOREIGN KEY REFERENCES Tourists (Id),
BonusPrizeId INT FOREIGN KEY REFERENCES BonusPrizes(Id),
PRIMARY KEY(TouristId, BonusPrizeId)
)

--Insert
INSERT INTO Tourists ([Name], Age, PhoneNumber, Nationality, Reward)
VALUES
('Borislava Kazakova', 52, '+359896354244', 'Bulgaria', NULL),
('Peter Bosh', 48, '+447911844141', 'UK', NULL),
('Martin Smith', 29, '+353863818592', 'Ireland', 'Bronze badge'),
('Svilen Dobrev', 49, '+359986584786', 'Bulgaria', 'Silver badge'),
('Kremena Popova', 38, '+359893298604', 'Bulgaria', NULL)

INSERT INTO Sites ([Name], LocationId, CategoryId, Establishment)
VALUES
('Ustra fortress', 90, 7, 'X'),
('Karlanovo Pyramids', 65, 7, NULL),
('The Tomb of Tsar Sevt', 63, 8, 'V BC'),
('Sinite Kamani Natural Park', 17, 1, NULL),
('St. Petka of Bulgaria – Rupite', 92, 6, '1994')

--Update
UPDATE Sites
SET Establishment = 'not defined'
	WHERE Establishment IS NULL

--Delete
DELETE TouristsBonusPrizes WHERE BonusPrizeId = (SELECT Id FROM BonusPrizes WHERE [Name] = 'Sleeping bag')

DELETE BonusPrizes WHERE [Name] = 'Sleeping bag'

--Problem 5
SELECT
	[Name],
	Age,
	PhoneNumber,
	Nationality
FROM Tourists
	ORDER BY Nationality, Age DESC, [Name]

--Problem 6
SELECT 
	s.[Name] AS Site,
	l.[Name] AS Location,
	s.Establishment,
	c.[Name]
FROM Sites AS s
	INNER JOIN Locations AS l ON s.LocationId = l.Id
	INNER JOIN Categories AS c ON s.CategoryId = c.Id
		ORDER BY c.[Name] DESC, l.[Name], s.[Name]

--Problem 7
SELECT 
	l.Province,
	l.Municipality,
	l.[Name] AS [Location],
	COUNT(s.[Name]) AS CountOfSites
FROM Locations AS l 
		INNER JOIN Sites AS s ON l.Id = s.LocationId
	WHERE Province = 'Sofia'
	GROUP BY l.Province, l.Municipality, l.[Name]
ORDER BY CountOfSites DESC, [Location]

--Problem 8
SELECT 
	s.[Name] AS [Site],
	l.[Name] AS [Location],
	l.Municipality,
	l.Province,
	s.Establishment
FROM Sites AS s
	JOIN Locations AS l ON s.LocationId = l.Id
WHERE LEFT(l.[Name], 1) NOT IN ('B', 'M', 'D') 
	AND CHARINDEX('BC', Establishment) > 0
ORDER BY [Site]

--Problem 9
SELECT 
	t.[Name],
	t.Age,
	t.PhoneNumber,
	t.Nationality,
	ISNULL(bp.[Name], '(no bonus prize)') AS Reward
FROM Tourists AS t
	LEFT JOIN TouristsBonusPrizes AS tp ON t.Id = tp.TouristId
	LEFT JOIN BonusPrizes AS bp ON tp.BonusPrizeId = bp.Id
ORDER BY t.[Name]

--Problem 10
SELECT DISTINCT
	SUBSTRING(t.[Name], CHARINDEX(' ', t.[Name]), LEN(t.[Name])) AS LastName,
	t.Nationality,
	t.Age,
	t.PhoneNumber
FROM Tourists AS t
	LEFT JOIN SitesTourists AS st ON t.Id = st.TouristId
	LEFT JOIN Sites AS s ON st.SiteId = s.Id
	JOIN Categories AS c ON s.CategoryId = c.Id
WHERE c.[Name] = 'History and archaeology'
	ORDER BY LastName

--Problem 11
CREATE FUNCTION udf_GetTouristsCountOnATouristSite(@Site VARCHAR(100))
RETURNS INT
AS
BEGIN
	RETURN 
	(SELECT
		COUNT(Id)
	FROM (
	SELECT 
		t.Id
	FROM Sites AS s
		JOIN SitesTourists AS st ON s.Id = st.SiteId
		JOIN Tourists AS t ON st.TouristId = t.Id
	WHERE s.[Name] = @Site
		) AS SubQ
		)
END

--Problem 12
CREATE PROC usp_AnnualRewardLottery(@TouristName VARCHAR(50))
AS
BEGIN
IF(SELECT COUNT(t.Id)
	FROM Tourists AS t 
		INNER JOIN SitesTourists AS st ON t.Id = st.TouristId
	WHERE t.[Name] = @TouristName) >= 100
	BEGIN
		UPDATE Tourists 
		SET Reward = 'Gold badge'
	END
ELSE IF(SELECT COUNT(t.Id)
	FROM Tourists AS t 
		INNER JOIN SitesTourists AS st ON t.Id = st.TouristId
	WHERE t.[Name] = @TouristName) >= 50
		BEGIN
			UPDATE Tourists
			SET Reward = 'Silver badge'
		END
ELSE IF (SELECT COUNT(t.Id)
	FROM Tourists AS t 
		INNER JOIN SitesTourists AS st ON t.Id = st.TouristId
	WHERE t.[Name] = @TouristName) >= 25
	BEGIN
		UPDATE Tourists
		SET Reward = 'Bronze badge'
	END

SELECT [Name], Reward FROM Tourists WHERE [Name] = @TouristName
END

