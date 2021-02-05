CREATE TABLE #TEMP1(BookingCode BIGINT,CheckInDt DATE,CheckOutDt DATE,Tariff DECIMAL(27,2),MarkUp DECIMAL(27,2),PropertyId BIGINT,MasterPropertyId BIGINT,
RoomCaptured BIGINT,BookingId BIGINT,CityId BIGINT,PropertyCategory NVARCHAR(100),ClientId BIGINT,MasterClientId BIGINT,BookedDt VARCHAR(100));
INSERT INTO #TEMP1
SELECT S.BookingCode,S.CheckInDt,S.CheckOutDt,SUM(S.Tariff),SUM(S.MarkUp),S.PropertyId,S.MasterPropertyId,RoomCaptured,S.BookingId,S.CityId,S.PropertyCategory,S.ClientId,
C.MasterClientId, SUBSTRING(DATENAME(MONTH, S.BookingDate), 1, 3) + '-' + CAST(YEAR(S.BookingDate) AS VARCHAR)
FROM WRBHBBookingStatus S
LEFT OUTER JOIN WRBHBClientManagement C WITH(NOLOCK)ON C.Id = S.ClientId
WHERE S.Status != 'Canceled' AND S.PropertyCategory NOT IN ('G H')
GROUP BY S.BookingCode,S.CheckInDt,S.CheckOutDt,S.Tariff,S.MarkUp,S.PropertyId,S.MasterPropertyId,RoomCaptured,S.BookingId,S.CityId,S.PropertyCategory,S.ClientId,
C.MasterClientId, S.BookingDate;

CREATE TABLE #TEMP2(BookingCode BIGINT,CalendarDate DATE,CheckInDt DATE,CheckOutDt DATE,Tariff DECIMAL(27,2),MarkUp DECIMAL(27,2),PropertyId BIGINT,
MasterPropertyId BIGINT,RoomCaptured BIGINT,BookingId BIGINT,CityId BIGINT,PropertyCategory NVARCHAR(100),ClientId BIGINT,asasd nvarchar(100),MasterClientId BIGINT);
INSERT INTO #TEMP2
SELECT S.BookingCode, C.calendarDate, S.CheckInDt, S.CheckOutDt, S.Tariff, ROUND(S.MarkUp / DATEDIFF(DAY,S.CheckInDt,S.CheckOutDt),0), S.PropertyId, S.MasterPropertyId,
S.RoomCaptured, S.BookingId, S.CityId, S.PropertyCategory, S.ClientId, SUBSTRING(DATENAME(MONTH,C.CalendarDate),1,3) + '-' + CAST(YEAR(C.CalendarDate) AS VARCHAR),
S.MasterClientId 
FROM #TEMP1 S
LEFT OUTER JOIN calendar.main C WITH(NOLOCK)ON C.calendarYear != 0
WHERE S.CheckInDt != S.CheckOutDt AND C.calendarDate BETWEEN S.CheckInDt AND DATEADD(DAY, -1, S.CheckOutDt);

INSERT INTO #TEMP2
SELECT S.BookingCode,S.CheckInDt,S.CheckInDt,S.CheckOutDt,S.Tariff,ROUND(S.MarkUp,0),S.PropertyId,S.MasterPropertyId,RoomCaptured,S.BookingId,S.CityId,S.PropertyCategory,
S.ClientId,SUBSTRING(DATENAME(MONTH,S.CheckInDt),1,3)+'-'+CAST(YEAR(S.CheckInDt) AS VARCHAR),S.MasterClientId FROM #TEMP1 S
WHERE S.CheckInDt = S.CheckOutDt;

DELETE #TEMP2 WHERE asasd NOT IN ('Apr-2018', 'May-2018', 'Jun-2018', 'Jul-2018', 'Aug-2018', 'Sep-2018', 'Oct-2018', 'Nov-2018', 'Dec-2018', 'Jan-2019', 'Feb-2019', 'Mar-2019');

/* Booking Count Start */

CREATE TABLE #Temp_Booking(MasterClientId BIGINT, BookingId BIGINT);
INSERT INTO #Temp_Booking
SELECT T.MasterClientId, T.BookingId FROM #TEMP2 T
GROUP BY T.MasterClientId, T.BookingId;

CREATE TABLE #BookingCount(BookingCount INT, MasterClientId BIGINT);
INSERT INTO #BookingCount
SELECT COUNT(BookingId), MasterClientId FROM #Temp_Booking GROUP BY MasterClientId;

/* Booking Count End */

CREATE TABLE #BookingGTV(MasterClientId BIGINT, RoomNightCount INT, GTV DECIMAL(27, 2));
INSERT INTO #BookingGTV
SELECT T.MasterClientId, COUNT(T.CalendarDate), SUM(T.Tariff)
FROM #TEMP2 T
GROUP BY T.MasterClientId;

CREATE TABLE #Output(MasterClientName NVARCHAR(100), BookingCount INT, RoomNightCount INT, GTV DECIMAL(27, 2), MasterClientId BIGINT);
INSERT INTO #Output
SELECT C.ClientName, B.BookingCount, G.RoomNightCount, G.GTV, C.Id FROM #BookingGTV G
LEFT OUTER JOIN #BookingCount B ON G.MasterClientId = B.MasterClientId
LEFT OUTER JOIN WRBHBMasterClientManagement C ON G.MasterClientId = C.Id
WHERE C.ClientName IS NOT NULL
ORDER BY C.ClientName;

SELECT * FROM #Output ORDER BY MasterClientName;

CREATE TABLE #T2345(BookingCode BIGINT,CalendarDate DATE,CheckInDt DATE,CheckOutDt DATE,Tariff DECIMAL(27,2),MarkUp DECIMAL(27,2),PropertyId BIGINT,
MasterPropertyId BIGINT,RoomCaptured BIGINT,BookingId BIGINT,CityId BIGINT,PropertyCategory NVARCHAR(100),ClientId BIGINT,asasd nvarchar(100),MasterClientId BIGINT);
INSERT INTO #T2345
SELECT S.BookingCode, C.calendarDate, S.CheckInDt, S.CheckOutDt, S.Tariff, ROUND(S.MarkUp / DATEDIFF(DAY,S.CheckInDt,S.CheckOutDt),0), S.PropertyId, S.MasterPropertyId,
S.RoomCaptured, S.BookingId, S.CityId, S.PropertyCategory, S.ClientId, SUBSTRING(DATENAME(MONTH,C.CalendarDate),1,3) + '-' + CAST(YEAR(C.CalendarDate) AS VARCHAR),
S.MasterClientId 
FROM #TEMP1 S
LEFT OUTER JOIN calendar.main C WITH(NOLOCK)ON C.calendarYear != 0
WHERE S.CheckInDt != S.CheckOutDt AND C.calendarDate BETWEEN S.CheckInDt AND DATEADD(DAY, -1, S.CheckOutDt);

INSERT INTO #T2345
SELECT S.BookingCode,S.CheckInDt,S.CheckInDt,S.CheckOutDt,S.Tariff,ROUND(S.MarkUp,0),S.PropertyId,S.MasterPropertyId,RoomCaptured,S.BookingId,S.CityId,S.PropertyCategory,
S.ClientId,SUBSTRING(DATENAME(MONTH,S.CheckInDt),1,3)+'-'+CAST(YEAR(S.CheckInDt) AS VARCHAR),S.MasterClientId FROM #TEMP1 S
WHERE S.CheckInDt = S.CheckOutDt;

DELETE #T2345 WHERE asasd NOT IN ('Apr-2019', 'May-2019');

/* Booking Count Start */

CREATE TABLE #Temp_Booking1(MasterClientId BIGINT, BookingId BIGINT);
INSERT INTO #Temp_Booking1
SELECT T.MasterClientId, T.BookingId FROM #T2345 T
GROUP BY T.MasterClientId, T.BookingId;

CREATE TABLE #BookingCount1(BookingCount INT, MasterClientId BIGINT);
INSERT INTO #BookingCount1
SELECT COUNT(BookingId), MasterClientId FROM #Temp_Booking1 GROUP BY MasterClientId;

/* Booking Count End */

CREATE TABLE #BookingGTV1(MasterClientId BIGINT, RoomNightCount INT, GTV DECIMAL(27, 2));
INSERT INTO #BookingGTV1
SELECT T.MasterClientId, COUNT(T.CalendarDate), SUM(T.Tariff)
FROM #T2345 T
GROUP BY T.MasterClientId;

CREATE TABLE #Output1(BookingCount INT, RoomNightCount INT, GTV DECIMAL(27, 2), MasterClientId BIGINT);
INSERT INTO #Output1
SELECT B.BookingCount, G.RoomNightCount, G.GTV, G.MasterClientId FROM #BookingGTV1 G
LEFT OUTER JOIN #BookingCount1 B ON G.MasterClientId = B.MasterClientId;

SELECT O.MasterClientName, O.BookingCount, O.RoomNightCount, O.GTV,
ISNULL(O1.BookingCount, 0) AS BookingCount, ISNULL(O1.RoomNightCount, 0) AS RoomNightCount, ISNULL(O1.GTV, 0) AS GTV,
O.MasterClientId, O1.MasterClientId
FROM #Output O
LEFT OUTER JOIN #Output1 O1 ON O.MasterClientId = O1.MasterClientId
ORDER BY O.MasterClientName;