--Model Definition
CREATE TABLE Categories
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Addresses
(
Id INT PRIMARY KEY IDENTITY,
StreetName NVARCHAR(100)  NOT NULL,
StreetNumber INT NOT NULL,
Town VARCHAR(30) NOT NULL,
Country VARCHAR(50) NOT NULL,
ZIP INT NOT NULL
)

CREATE TABLE Publishers
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(30) UNIQUE NOT NULL,
AddressId INT FOREIGN KEY REFERENCES Addresses(Id) NOT NULL,
Website NVARCHAR(40),
Phone NVARCHAR(20)
)

CREATE TABLE PlayersRanges
(
Id INT PRIMARY KEY IDENTITY,
PlayersMin INT NOT NULL,
PlayersMax INT NOT NULL
)

CREATE TABLE Boardgames
(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(30) NOT NULL,
YearPublished INT NOT NULL,
Rating DECIMAL(18,2) NOT NULL,
CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
PublisherId INT FOREIGN KEY REFERENCES Publishers(Id) NOT NULL,
PlayersRangeId INT FOREIGN KEY REFERENCES PlayersRanges(Id) NOT NULL
)

CREATE TABLE Creators
(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(30) NOT NULL,
LastName NVARCHAR(30) NOT NULL,
Email NVARCHAR(30) NOT NULL
)

CREATE TABLE CreatorsBoardgames
(
CreatorId INT FOREIGN KEY REFERENCES Creators(Id),
BoardgameId INT FOREIGN KEY REFERENCES Boardgames(Id),
PRIMARY KEY(CreatorId, BoardgameId)
)

--Insert
INSERT INTO Boardgames([Name], YearPublished, Rating, CategoryId, PublisherId, PlayersRangeId)
VALUES
('Deep Blue', 2019, 5.67, 1, 15, 7),
('Paris', 2016, 9.78, 7, 1, 5),
('Catan: Starfarers', 2021, 9.87, 7, 13, 6),
('Bleeding Kansas',	2020, 3.25, 3, 7, 4),
('One Small Step', 2019, 5.75, 5, 9, 2)

INSERT INTO Publishers([Name], AddressId, Website, Phone)
VALUES
('Agman Games', 5, 'www.agmangames.com', '+16546135542'),
('Amethyst Games', 7, 'www.amethystgames.com', '+15558889992'),
('BattleBooks', 13, 'www.battlebooks.com', '+12345678907')

--Update
UPDATE PlayersRanges
SET PlayersMax += 1
	WHERE PlayersMin = 2 AND PlayersMax = 2

UPDATE Boardgames
	SET [Name] = CONCAT([Name], 'V2')
WHERE YearPublished >= 2020

--Delete
DELETE FROM CreatorsBoardgames WHERE BoardgameId IN (1,16,31,47)
DELETE FROM Boardgames WHERE PublisherId IN (1,16)
DELETE FROM Publishers WHERE AddressId IN (5)
DELETE FROM Addresses WHERE SUBSTRING(Town, 1, 1) = 'L'

--Problem 5
SELECT
	[Name],
	Rating
FROM Boardgames
	ORDER BY YearPublished, [Name] DESC

--Problem 6
SELECT
	b.Id,
	b.[Name],
	YearPublished,
	c.[Name]
FROM Boardgames AS b
	JOIN Categories AS c ON c.Id = b.CategoryId
	WHERE c.[Name] IN ('Strategy Games', 'Wargames')
	ORDER BY YearPublished DESC

--Problem 7
SELECT
	Id,
	CONCAT(FirstName, ' ', LastName) AS CreatorName,
	Email
FROM Creators AS c
	LEFT JOIN CreatorsBoardgames  AS cb ON c.Id = cb.CreatorId
	WHERE cb.BoardgameId IS NULL

--Problem 8
SELECT TOP 5
	b.[Name],
	b.Rating,
	c.[Name]
FROM Boardgames AS b
	JOIN Categories AS c ON c.Id = b.CategoryId
	JOIN PlayersRanges AS pr ON b.PlayersRangeId = pr.Id
	WHERE (b.Rating > 7 AND CHARINDEX('a', b.[Name]) > 0) OR (b.Rating > 7.5 AND pr.PlayersMin >= 2 AND pr.PlayersMax <= 5)
	ORDER BY b.[Name], b.Rating DESC

--Problem 9
SELECT
	CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
	c.Email,
	MAX(b.Rating) AS Rating
FROM Creators AS c
	JOIN CreatorsBoardgames AS cb ON cb.CreatorId = c.Id
	JOIN Boardgames AS b ON b.Id = cb.BoardgameId
WHERE c.Email LIKE ('%.com')
GROUP BY CONCAT(c.FirstName, ' ', c.LastName), c.Email
	ORDER BY FullName

--Problem 10
SELECT
	c.LastName,
	CEILING(AVG(b.Rating)) AS AverageRating,
	p.[Name]
FROM Creators AS c
	JOIN CreatorsBoardgames AS cb ON cb.CreatorId = c.Id
	JOIN Boardgames AS b ON b.Id = cb.BoardgameId
	JOIN Publishers AS p ON b.PublisherId = p.Id
WHERE p.[Name] = 'Stonemaier Games'
	GROUP BY c.LastName, p.[Name]
ORDER BY AVG(b.Rating) DESC

--Problem 11
CREATE FUNCTION udf_CreatorWithBoardgames(@name NVARCHAR(30))
RETURNS INT
AS
BEGIN
	RETURN (
	SELECT
		COUNT(b.Id)
	FROM Creators AS c
		LEFT JOIN CreatorsBoardgames AS cb ON cb.CreatorId = c.Id
		LEFT JOIN Boardgames AS b ON b.Id = cb.BoardgameId
		WHERE c.FirstName = @name
	GROUP BY c.FirstName
			)
END

--Problem 12
CREATE PROC usp_SearchByCategory(@category VARCHAR(50))
AS
BEGIN
	SELECT
		b.[Name],
		b.YearPublished,
		b.Rating,
		c.[Name],
		p.[Name],
		CONCAT(pr.PlayersMin, ' people') AS MinPlayers,
		CONCAT(pr.PlayersMax, ' people') AS MaxPlayers
	FROM Boardgames AS b
		JOIN Categories AS c ON c.Id = b.CategoryId
		JOIN PlayersRanges AS pr ON b.PlayersRangeId = pr.Id
		JOIN Publishers AS p ON b.PublisherId = p.Id
		WHERE c.[Name] = @category
	ORDER BY p.[Name], b.YearPublished
END