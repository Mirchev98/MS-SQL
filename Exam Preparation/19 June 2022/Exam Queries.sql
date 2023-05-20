--Model Definition
CREATE TABLE Owners
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR (50) NOT NULL,
PhoneNumber VARCHAR (15) NOT NULL,
[Address] VARCHAR (50)
)

CREATE TABLE AnimalTypes
(
Id INT PRIMARY KEY IDENTITY,
AnimalType VARCHAR (30) NOT NULL
)

CREATE TABLE Cages
(
Id INT PRIMARY KEY IDENTITY,
AnimalTypeId INT FOREIGN KEY REFERENCES AnimalTypes(Id) NOT NULL
)

CREATE TABLE Animals
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(30) NOT NULL,
BirthDate DATE NOT NULL,
OwnerId INT FOREIGN KEY REFERENCES Owners(Id),
AnimalTypeId INT FOREIGN KEY REFERENCES AnimalTypes(Id) NOT NULL
)

CREATE TABLE AnimalsCages
(
CageId INT FOREIGN KEY REFERENCES Cages(Id),
AnimalId INT FOREIGN KEY REFERENCES Animals(Id),
PRIMARY KEY (CageId, AnimalId)
)

CREATE TABLE VolunteersDepartments
(
Id INT PRIMARY KEY IDENTITY,
DepartmentName VARCHAR(30) NOT NULL
)

CREATE TABLE Volunteers
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
PhoneNumber VARCHAR(15) NOT NULL,
[Address] VARCHAR(50),
AnimalId INT FOREIGN KEY REFERENCES Animals(Id),
DepartmentId INT FOREIGN KEY REFERENCES VolunteersDepartments(Id) NOT NULL
)

-- Insert
INSERT INTO Volunteers ([Name], PhoneNumber, [Address], AnimalId, DepartmentId)
	VALUES
		('Anita Kostova', '0896365412', 'Sofia, 5 Rosa str.', 15, 1),
		('Dimitur Stoev', '0877564223', NULL, 42, 4),
		('Kalina Evtimova',	'0896321112', 'Silistra, 21 Breza str.', 9,	7),
		('Stoyan Tomov', '0898564100', 'Montana, 1 Bor str.', 18, 8),
		('Boryana Mileva', '0888112233', NULL, 31, 5)

INSERT INTO Animals ([Name], BirthDate, OwnerId, AnimalTypeId)
	VALUES
		('Giraffe', '2018-09-21', 21, 1),
		('Harpy Eagle', '2015-04-17', 15, 3),
		('Hamadryas Baboon', '2017-11-02', NULL, 1),
		('Tuatara', '2021-06-30', 2, 4)


--Update
UPDATE Animals
	SET OwnerId = (SELECT Id FROM Owners WHERE [Name] = 'Kaloqn Stoqnov')
WHERE OwnerId IS NULL

--Delete
DELETE Volunteers
	WHERE DepartmentId = 
	(SELECT Id FROM VolunteersDepartments 
	WHERE DepartmentName = 'Education program assistant')

DELETE FROM VolunteersDepartments 
	WHERE DepartmentName = 'Education program assistant'


--Problem 5 Volunteers
SELECT 
	[Name],
	PhoneNumber,
	[Address],
	AnimalId,
	DepartmentId
FROM Volunteers
	ORDER BY [Name], AnimalId, DepartmentId

--Problem 6 Animals Data
SELECT
	[Name],
	ay.AnimalType,
	FORMAT(a.BirthDate, 'dd.MM.yyyy') AS BirthDate
FROM Animals AS a
	JOIN AnimalTypes AS ay ON a.AnimalTypeId = ay.Id
ORDER BY [Name]

--Problem 7 Owners And Their Animals
SELECT TOP 5
	o.[Name] AS [Owner],
	COUNT(a.OwnerId) AS CountOfAnimals
FROM Owners AS o
	LEFT JOIN Animals AS a ON o.Id = a.OwnerId
GROUP BY o.[Name]
	ORDER BY CountOfAnimals DESC, [Owner]

--Problem 8 
SELECT
	CONCAT(o.[Name],'-',a.[Name]) AS OwnersAnimals,
	o.PhoneNumber,
	ac.CageId
FROM Owners AS o
	LEFT JOIN Animals AS a ON a.OwnerId = o.Id
	JOIN AnimalsCages AS ac ON ac.AnimalId = a.Id
	JOIN Cages AS c ON c.Id = ac.CageId
		WHERE a.AnimalTypeId = (SELECT Id FROM AnimalTypes WHERE AnimalType = 'Mammals')
ORDER BY o.[Name], a.[Name] DESC

--Problem 9 
SELECT 
	[Name],
	PhoneNumber,
	SUBSTRING([Address], CHARINDEX(',', [Address]) + 2, LEN([Address])) AS [Address]
FROM Volunteers 
	WHERE CHARINDEX('Sofia', [Address]) > 0 AND Volunteers.DepartmentId = (SELECT Id FROM VolunteersDepartments WHERE DepartmentName = 'Education program assistant')
	ORDER BY [Name]

--Problem 10
SELECT
	a.[Name],
	YEAR(a.BirthDate) AS BirthYear,
	ay.AnimalType
FROM Animals AS a
	JOIN AnimalTypes AS ay ON  a.AnimalTypeId = ay.Id
WHERE DATEDIFF(YEAR, BirthDate, '01/01/2022') < 5 AND a.AnimalTypeId <> (SELECT Id FROM AnimalTypes WHERE AnimalTypes.AnimalType = 'Birds')
AND a.OwnerId IS NULL
	ORDER BY a.[Name]

--Problem 11
CREATE FUNCTION udf_GetVolunteersCountFromADepartment (@VolunteersDepartment VARCHAR(50))
RETURNS INT
AS
BEGIN
	RETURN (SELECT
		COUNT(Id)
	FROM Volunteers
		WHERE Volunteers.DepartmentId = 
		(SELECT ID FROM VolunteersDepartments 
			WHERE VolunteersDepartments.DepartmentName = @VolunteersDepartment))
END

--Problem 12
CREATE PROC usp_AnimalsWithOwnersOrNot(@AnimalName VARCHAR(50))
AS
BEGIN
	SELECT
		a.[Name],
		ISNULL(o.[Name], 'For adoption') AS OwnersName
	FROM Animals AS a
		LEFT JOIN Owners AS o ON a.OwnerId = o.Id
		WHERE a.[Name] = @AnimalName
END
