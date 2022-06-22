CREATE DATABASE ConferenceDb

USE ConferenceDb

CREATE TABLE Building
(
	"Name" NVARCHAR(100) PRIMARY KEY
)


CREATE TABLE Place
(
	"Name" NVARCHAR(100) PRIMARY KEY
)

CREATE TABLE Equipment
(
	EquipmentId INT PRIMARY KEY IDENTITY(1, 1),
	"Name" NVARCHAR(100),
	"Description" NVARCHAR(2000)
)


CREATE TABLE Leader
(
	LeaderId INT PRIMARY KEY IDENTITY(1, 1),
	Lastname NVARCHAR(50) NOT NULL,
	Firstname NVARCHAR(50) NOT NULL, 
	Middlename NVARCHAR(50)
)

CREATE TABLE Speaker
(
	SpeakerId INT PRIMARY KEY IDENTITY(1, 1),
	Lastname NVARCHAR(50) NOT NULL,
	Firstname NVARCHAR(50) NOT NULL, 
	Middlename NVARCHAR(50),
	Degree NVARCHAR(100),
	Work NVARCHAR(100),
	PostName NVARCHAR(100),
	Biography NVARCHAR(4000)
)

CREATE TABLE Conference
(
	ConferenceId INT PRIMARY KEY IDENTITY(1,1),
	"Name" NVARCHAR(100) NOT NULL,
	StartDateTime DATETIME,
	EndDateTime DATETIME,
	BuildingName NVARCHAR(100) FOREIGN KEY REFERENCES Building("Name")
)

CREATE TABLE Section
(
	SectionId INT PRIMARY KEY IDENTITY(1,1),
	"Name" NVARCHAR(100) NOT NULL,
	OrdinalNumber INT,
	LeaderId INT FOREIGN KEY REFERENCES Leader(LeaderId),
	ConferenceId INT FOREIGN KEY REFERENCES Conference(ConferenceId),
	PlaceName NVARCHAR(100) FOREIGN KEY REFERENCES Place("Name")
)

CREATE TABLE Performance
(
	PerformanceId INT PRIMARY KEY IDENTITY(1,1),
	Theme NVARCHAR(100) NOT NULL,
	SpeakerId INT FOREIGN KEY REFERENCES Speaker(SpeakerId),
	SectionId INT FOREIGN KEY REFERENCES Section(SectionId),
	DateTimeStart DATETIME,
	Duration TIME
)



CREATE TABLE PerformanceEquipment
(
	PerformanceId INT,
	EquipmentId INT,
	PRIMARY KEY (PerformanceId, EquipmentId),
	FOREIGN KEY (PerformanceId) REFERENCES Performance(PerformanceId),
	FOREIGN KEY (EquipmentId) REFERENCES Equipment(EquipmentId)
)



CREATE TRIGGER SpeakerDateLimitInsert
ON Performance
INSTEAD OF INSERT
AS
BEGIN
DECLARE @Cnt INT;
DECLARE @Theme NVARCHAR(100);
DECLARE @SpeakerId INT;
DECLARE @SectionId INT;
DECLARE @DateTimeStart DATETIME;
DECLARE @Duration TIME;
DECLARE perform_Cursor CURSOR FAST_FORWARD 
FOR 
SELECT Theme, SpeakerId, SectionId, DateTimeStart, Duration FROM inserted	
 OPEN perform_Cursor 
 FETCH NEXT FROM perform_Cursor INTO @Theme, @SpeakerId, @SectionId, @DateTimeStart, @Duration
 WHILE @@FETCH_STATUS = 0 
 BEGIN 
 SELECT @Cnt = COUNT(*) FROM Performance
 WHERE CONVERT(DATE, DateTimeStart) = CONVERT(DATE, @DateTimeStart)
 AND SectionId = @SectionId AND SpeakerId = @SpeakerId
 IF NOT EXISTS(SELECT * FROM Performance WHERE 
 ((@DateTimeStart BETWEEN DateTimeStart AND (DateTimeStart+CAST(Duration AS DATETIME)))
 OR 
 ((@DateTimeStart+CAST(@Duration AS DATETIME)) BETWEEN DateTimeStart AND (DateTimeStart+CAST(Duration AS DATETIME))))
 AND SectionId=@SectionId) AND @Cnt=0
 BEGIN
	INSERT INTO Performance
	(Theme, SpeakerId, SectionId, DateTimeStart, Duration)
	VALUES
	(@Theme, @SpeakerId, @SectionId, @DateTimeStart, @Duration)
 END
 ELSE
 PRINT N'�������!!! �������� ����� ���!'
 FETCH NEXT FROM perform_Cursor INTO @Theme, @SpeakerId, @SectionId, @DateTimeStart, @Duration
 END
CLOSE perform_Cursor
DEALLOCATE perform_Cursor
END



CREATE TRIGGER SpeakerDateLimitUpdate
ON Performance
INSTEAD OF UPDATE
AS
BEGIN
DECLARE @Cnt INT;
DECLARE @PerformanceId INT;
DECLARE @Theme NVARCHAR(100);
DECLARE @SpeakerId INT;
DECLARE @SectionId INT;
DECLARE @DateTimeStart DATETIME;
DECLARE @Duration TIME;
DECLARE perform_Cursor CURSOR FAST_FORWARD 
FOR 
SELECT PerformanceId, Theme, SpeakerId, SectionId, DateTimeStart, Duration FROM inserted	
 OPEN perform_Cursor 
 FETCH NEXT FROM perform_Cursor INTO @PerformanceId, @Theme, @SpeakerId, @SectionId, @DateTimeStart, @Duration
 WHILE @@FETCH_STATUS = 0 
 BEGIN 
 SELECT @Cnt = COUNT(*) FROM Performance
 WHERE CONVERT(DATE, DateTimeStart) = CONVERT(DATE, @DateTimeStart)
 AND SectionId = @SectionId AND SpeakerId = @SpeakerId
 IF NOT EXISTS(SELECT * FROM Performance WHERE 
 ((@DateTimeStart BETWEEN DateTimeStart AND (DateTimeStart+CAST(Duration AS DATETIME)))
 OR 
 ((@DateTimeStart+CAST(@Duration AS DATETIME)) BETWEEN DateTimeStart AND (DateTimeStart+CAST(Duration AS DATETIME))))
 AND SectionId=@SectionId) AND @Cnt=0
 BEGIN
	UPDATE Performance
	SET Theme = @Theme, SpeakerId = @SpeakerId, SectionId = @SectionId,
	DateTimeStart = @DateTimeStart, Duration = @Duration
	WHERE PerformanceId = @PerformanceId
 END
 ELSE
 PRINT N'�������!!! �������� ���, �� �����������!'
 FETCH NEXT FROM perform_Cursor INTO @PerformanceId, @Theme, @SpeakerId, @SectionId, @DateTimeStart, @Duration
 END
CLOSE perform_Cursor
DEALLOCATE perform_Cursor
END



INSERT INTO Building
("Name")
VALUES
(N'���. �������� 12'),
(N'���. ������� 43'),
(N'���. ��������� 1')



INSERT INTO Place
("Name")
VALUES
(N'������� ���������-���'),
(N'����� ���������-���'),
(N'������� ������-���'),
(N'����� ������-���'),
(N'����''����� �������'),
(N'��� ���������')


INSERT INTO Equipment
("Name", "Description")
VALUES
(N'̳������', N'������, �� ���������� ������ ��������� �� ��������� ���� ������������ ������'),
(N'������� ��������� �������', N'���� ������� ����������� ����� Bluetooth �� ����-����� ��������, �� ������� �� ���������, �� �����, �� ������� �� ���� �� �������� 10 �����.'),
(N'�����������', N' ������� ��� ����������� ������������� ����� � ���������� ������, �� ������������� ������ ���� ��� ������� ������������ ������'),
(N'����������� �����������', N'����������� ����������� - �� ����������� � ���������� �������. � �������� ����������� 3 ���������� �������� �� �������������� �����: FM, SW, AM.'),
(N'��������� ��������', NULL),
(N'����������� ����������', N'������������� ��������� � �������� ������� ��''���� � �� �������, ���� ������ ������� ������ �������� ���� �� �������� � ������� �������� ������ �������� ���� �� ������ ������� ���������')


INSERT INTO Leader
(Lastname, Firstname, Middlename)
VALUES
(N'��������', N'�����', N'��������'),
(N'��������', N'�������', N'���������'),
(N'�������', N'�������', N'���������'),
(N'�������', N'����', N'���������'),
(N'�������', N'�������', N'³��������'),
(N'�������', N'�����', N'��������'),
(N'������', N'������', N'���������')

INSERT INTO Speaker
(Lastname, Firstname, Middlename, Degree, Work, PostName, Biography)
VALUES
(N'�������', N'������', N'��������', N'������ ��������� ����', N'��� ��. ������ ��������', N'�������� ���������', N'�������� ���� �����, �� �������� ����� ������ �� �������� �� ��������� �������� (���������) ��������� ��������� ��������, �������-��������, �������-������������� ��� �������-����������� �������� �� �� �������� ����������� ��������� �� �������� ��������� ������� ��� ������� ������, ����������� ������������ ���������'),
(N'���������', N'������', N'���������', N'������ ����', N'Epam Systems', N'��������', N'��������, ����� ������� �� �������� ������� ����� �����, �������� � �������� ����������, � ������ ��䳿 ���������� �����. ������� ������� � ����� � ����������. ������� ���������� ��������� ��������� ������ �������� ��� ���� ����, �� ���������� � ����, ��������� �������� ��� ������� ������� �� �����. � ������ �������� �� ������ ���������� ��������� �����������.'),
(N'���������', N'������', N'����������', N'�������� ����', N'Globant', N'Գ�����', N'��������, ����� ������, ���������. ��������� � ���������, �� ��������� ����������, ��������� ������� ��������� � ��������㳿. �� ������ ����� �����, �������, ���������� � ������� ��������� �� ��� ���� � ����, �� ��� ������� ��������� �� �����������.'),
(N'����', N'�����', N'��������', N'�������� ��������', N'��� ��. ����� ������', N'Math expert', N'��������, �� ��������� ��������� ����������')

INSERT INTO Conference
("Name", StartDateTime, EndDateTime, BuildingName)
VALUES
(N'̳�������� ����������� ���������� �� �� ������� ���������', '2022-05-30 14:00:00', '2022-05-30 18:00:00', N'���. ������� 43'),
(N'̳�������� �������-������� �����������', '2022-05-30 11:00:00', '2022-05-30 13:00:00', N'���. ������� 43'),
(N'̳�������� ��������� ����������� ���������', '2022-05-31 14:00:00', '2022-05-31 18:00:00', N'���. ������� 43'),
(N'̳�������� ����������� ���������� ������ � ������', '2022-06-01 09:00:00', '2022-06-01 12:00:00', N'���. �������� 12'),
(N'̳�������� ����������� �������� �����', '2022-06-01 13:00:00', '2022-06-01 17:00:00', N'���. �������� 12')


INSERT INTO Section
("Name", OrdinalNumber, ConferenceId, LeaderId, PlaceName)
VALUES
(N'������� ������������', 111, 1, 1, N'������� ���������-���'),
(N'�������� ������������', 112, 1, 3, N'����� ���������-���'),
(N'��������������', 113, 2, 2, N'����''����� �������'),
(N'Գ������� ����������� ������', 114, 3, 4, N'����� ������-���'),
(N'Գ������� ������������� ����', 115, 3, 2, N'������� ������-���'),
(N'����������� �����������', 116, 4, 5, N'����''����� �������')


INSERT INTO Performance
(Theme, SpeakerId, SectionId, DateTimeStart, Duration)
VALUES
(N'̳���������� ���������� �����㳿 ������������ �� ������', 1, 1, '2022-05-30 14:00:00', '01:00:00'),
(N'��������� ������ ���������� ������������', 4, 2, '2022-05-30 14:00:00', '01:00:00'),
(N'������� ������� ��� ��������������', 3, 3, '2022-05-30 16:00:00', '02:00:00'),
(N'����� �����, �������� ���������', 2, 4, '2022-05-31 14:00:00', '01:30:00'),
(N'����� ����������', 2, 5, '2022-05-31 16:00:00', '01:30:00'),
(N'�������, ���������� �� ��������', 4, 5, '2022-05-31 13:00:00', '02:00:00')


INSERT INTO PerformanceEquipment
(PerformanceId, EquipmentId)
VALUES
(1, 1),
(1, 2),
(1, 4),
(1, 6),
(2, 1),
(2, 3),
(3, 1),
(3, 5),
(3, 6),
(4, 1),
(4, 2),
(4, 3),
(5, 3),
(5, 6),
(6, 1),
(6, 2),
(6, 4)


SELECT * FROM Building
SELECT * FROM Conference
SELECT * FROM Equipment
SELECT * FROM Performance
SELECT * FROM PerformanceEquipment
SELECT * FROM Place
SELECT * FROM Section
SELECT * FROM Speaker















