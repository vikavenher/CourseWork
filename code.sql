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
 PRINT N'Помилка!!! Перевірте вхідні дані!'
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
 PRINT N'Помилка!!! Перевірте дані, що оновлюються!'
 FETCH NEXT FROM perform_Cursor INTO @PerformanceId, @Theme, @SpeakerId, @SectionId, @DateTimeStart, @Duration
 END
CLOSE perform_Cursor
DEALLOCATE perform_Cursor
END



INSERT INTO Building
("Name")
VALUES
(N'вул. Майорівка 12'),
(N'вул. Ювілейна 43'),
(N'вул. Мечникова 1')



INSERT INTO Place
("Name")
VALUES
(N'Великий конференц-зал'),
(N'Малий конференц-зал'),
(N'Великий тренінг-хол'),
(N'Малий тренінг-хол'),
(N'Комп''ютерні аудиторії'),
(N'Зал перемовин')


INSERT INTO Equipment
("Name", "Description")
VALUES
(N'Мікрофон', N'Прилад, що перетворює звукові коливання на коливання сили електричного струму'),
(N'Активна акустична система', N'Дана колонка підключається через Bluetooth до будь-якого пристрою, що підтримує цю технологію, за умови, що відстань між ними не перевищує 10 метрів.'),
(N'Гучномовець', N' пристрій для ефективного випромінювання звуку в навколишній простір, що конструктивно містить одну або декілька випромінюючих голівок'),
(N'Радіоприймач портативний', N'Портативний радіоприймач - це радіоприймач і портативна колонка. У приймача передбачено 3 радіоканали коротких та ультракоротких хвиль: FM, SW, AM.'),
(N'Вокальний процесор', NULL),
(N'Трансляційні підсилювачі', N'Трансляційний підсилювач в системах гучного зв''язку – це пристрій, який приймає вхідний сигнал низького рівня від мікрофонів і підсилює вихідний сигнал високого рівня до бажаної вихідної потужності')


INSERT INTO Leader
(Lastname, Firstname, Middlename)
VALUES
(N'Марценюк', N'Петро', N'Іванович'),
(N'Головаха', N'Михайло', N'Андрійович'),
(N'Воробей', N'Ярослав', N'Семенович'),
(N'Демедюк', N'Ігор', N'Андрійович'),
(N'Миколюк', N'Михайло', N'Віталійович'),
(N'Якимчук', N'Андрій', N'Ігорович'),
(N'Клочко', N'Іванна', N'Михайлівна')

INSERT INTO Speaker
(Lastname, Firstname, Middlename, Degree, Work, PostName, Biography)
VALUES
(N'Кравців', N'Валерій', N'Ігорович', N'Голова предметної комісії', N'КНУ ім. Тараса Шевченка', N'Науковий працівник', N'Наявність вищої освіту, за основним місцем роботи та відповідно до трудового договору (контракту) професійно займається науковою, науково-технічною, науково-організаційною або науково-педагогічною діяльністю та має відповідну кваліфікацію незалежно від наявності наукового ступеня або вченого звання, підтверджену результатами атестації'),
(N'Кириленко', N'Степан', N'Андрійович', N'Доктор наук', N'Epam Systems', N'Політолог', N'Фахівець, вивчає політику як особливу область життя людей, пов’язану з владними відносинами, і аналізує події політичного життя. Основна функція у роботі – громадська. Завдяки коментарям політолога громадяни чіткіше уявляють собі суть того, що відбувається в країні, отримують уявлення про політичні цінності та норми. У деяких випадках це сприяє пом’якшенню соціальної напруженості.'),
(N'Прокопчук', N'Василь', N'Михайлович', N'Кандидат наук', N'Globant', N'Філософ', N'Любомудр, шукач істини, мислитель. Спеціаліст з філософії, що займається філософією, розробляє питання світогляду й методології. Має певний досвід життя, розумно, помірковано і спокійно ставиться до всіх явищ у житті, до всіх життєвих труднощів та випробувань.'),
(N'Чміль', N'Йосип', N'Петрович', N'Завідувач відділення', N'ЛНУ ім. Івана Франка', N'Math expert', N'Фахівець, що займається розвитком математики')

INSERT INTO Conference
("Name", StartDateTime, EndDateTime, BuildingName)
VALUES
(N'Міжнародна конференція мікробіологія та її аспекти досліджень', '2022-05-30 14:00:00', '2022-05-30 18:00:00', N'вул. Ювілейна 43'),
(N'Міжнародна науково-технічна конференція', '2022-05-30 11:00:00', '2022-05-30 13:00:00', N'вул. Ювілейна 43'),
(N'Міжнародна практична конференція філософія', '2022-05-31 14:00:00', '2022-05-31 18:00:00', N'вул. Ювілейна 43'),
(N'Міжнародна конференція математичні методи у техніці', '2022-06-01 09:00:00', '2022-06-01 12:00:00', N'вул. Майорівка 12'),
(N'Міжнародна конференція політичної освіти', '2022-06-01 13:00:00', '2022-06-01 17:00:00', N'вул. Майорівка 12')


INSERT INTO Section
("Name", OrdinalNumber, ConferenceId, LeaderId, PlaceName)
VALUES
(N'Екологія мікроорганізмів', 111, 1, 1, N'Великий конференц-зал'),
(N'Цитологія мікроорганізмів', 112, 1, 3, N'Малий конференц-зал'),
(N'Інфокомунікації', 113, 2, 2, N'Комп''ютерні аудиторії'),
(N'Філософія Стародавньої Греції', 114, 3, 4, N'Малий тренінг-хол'),
(N'Філософія Стародавнього Риму', 115, 3, 2, N'Великий тренінг-хол'),
(N'Математичне моделювання', 116, 4, 5, N'Комп''ютерні аудиторії')


INSERT INTO Performance
(Theme, SpeakerId, SectionId, DateTimeStart, Duration)
VALUES
(N'Мікробіологічні дослідження екології мікроорганізмів та рослин', 1, 1, '2022-05-30 14:00:00', '01:00:00'),
(N'Цитологічні методи дослідження мікроорганізмів', 4, 2, '2022-05-30 14:00:00', '01:00:00'),
(N'Загальні поняття про інфокомунікації', 3, 3, '2022-05-30 16:00:00', '02:00:00'),
(N'Школа еліатів, класична філософія', 2, 4, '2022-05-31 14:00:00', '01:30:00'),
(N'Школа піфагорійців', 2, 5, '2022-05-31 16:00:00', '01:30:00'),
(N'Стоїцизм, скептицизм та епікуреїзм', 4, 5, '2022-05-31 13:00:00', '02:00:00')


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















