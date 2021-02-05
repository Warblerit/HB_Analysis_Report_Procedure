-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[SP_HBAnalysis_GuestCount_Report]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
DROP PROCEDURE [dbo].[SP_HBAnalysis_GuestCount_Report]
GO 
CREATE PROCEDURE [dbo].[SP_HBAnalysis_GuestCount_Report](@Action NVARCHAR(100),@Str NVARCHAR(100),@Id BIGINT)
--Exec [dbo].[SP_HBAnalysis_GuestCount_Report] @Action = '',@Str = '',@Id = 0;
AS
BEGIN
SET NOCOUNT ON
SET ANSI_WARNINGS OFF
IF @Action = ''
BEGIN
CREATE TABLE #TEMP1(BookingCode BIGINT,CheckInDt DATE,CheckOutDt DATE,Tariff DECIMAL(27,2),MarkUp DECIMAL(27,2),PropertyId BIGINT,MasterPropertyId BIGINT,
RoomCaptured BIGINT,BookingId BIGINT,CityId BIGINT,PropertyCategory NVARCHAR(100),ClientId BIGINT,MasterClientId BIGINT,GuestId BIGINT,GuestName NVARCHAR(100));
INSERT INTO #TEMP1
SELECT S.BookingCode,S.CheckInDt,S.CheckOutDt,SUM(S.Tariff),SUM(S.MarkUp),S.PropertyId,S.MasterPropertyId,RoomCaptured,S.BookingId,S.CityId,S.PropertyCategory,S.ClientId,
C.MasterClientId, S.GuestId, S.GuestName
FROM WRBHBBookingStatus S
LEFT OUTER JOIN WRBHBClientManagement C WITH(NOLOCK)ON C.Id = S.ClientId
WHERE S.Status != 'Canceled'
GROUP BY S.BookingCode,S.CheckInDt,S.CheckOutDt,S.Tariff,S.MarkUp,S.PropertyId,S.MasterPropertyId,RoomCaptured,S.BookingId,S.CityId,S.PropertyCategory,S.ClientId,
C.MasterClientId, S.GuestId, S.GuestName;
--
CREATE TABLE #TEMP2(BookingCode BIGINT,CalendarDate DATE,CheckInDt DATE,CheckOutDt DATE,Tariff DECIMAL(27,2),MarkUp DECIMAL(27,2),PropertyId BIGINT,
MasterPropertyId BIGINT,RoomCaptured BIGINT,BookingId BIGINT,CityId BIGINT,PropertyCategory NVARCHAR(100),ClientId BIGINT,asasd nvarchar(100),MasterClientId BIGINT,
GuestId BIGINT,GuestName NVARCHAR(100));
INSERT INTO #TEMP2
SELECT S.BookingCode, C.calendarDate, S.CheckInDt, S.CheckOutDt, S.Tariff, ROUND(S.MarkUp / DATEDIFF(DAY,S.CheckInDt,S.CheckOutDt),0), S.PropertyId, S.MasterPropertyId,
S.RoomCaptured, S.BookingId, S.CityId, S.PropertyCategory, S.ClientId, SUBSTRING(DATENAME(MONTH,C.CalendarDate),1,3) + '-' + CAST(YEAR(C.CalendarDate) AS VARCHAR),
S.MasterClientId,S.GuestId,S.GuestName 
FROM #TEMP1 S
LEFT OUTER JOIN calendar.main C WITH(NOLOCK)ON C.calendarYear != 0
WHERE S.CheckInDt != S.CheckOutDt AND C.calendarDate BETWEEN S.CheckInDt AND DATEADD(DAY, -1, S.CheckOutDt);
--
INSERT INTO #TEMP2
SELECT S.BookingCode,S.CheckInDt,S.CheckInDt,S.CheckOutDt,S.Tariff,ROUND(S.MarkUp,0),S.PropertyId,S.MasterPropertyId,RoomCaptured,S.BookingId,S.CityId,S.PropertyCategory,
S.ClientId,SUBSTRING(DATENAME(MONTH,S.CheckInDt),1,3)+'-'+CAST(YEAR(S.CheckInDt) as varchar),S.MasterClientId,S.GuestId,S.GuestName FROM #TEMP1 S
WHERE S.CheckInDt = S.CheckOutDt;
--
CREATE TABLE #FY2014_15(BookingId BIGINT, GuestId BIGINT, GuestName NVARCHAR(100), FY NVARCHAR(100));
INSERT INTO #FY2014_15
SELECT BookingId, GuestId, GuestName, 'FY 2014 - 2015' FROM #TEMP2
WHERE asasd IN ('Apr-2014', 'May-2014', 'Jun-2014', 'Jul-2014', 'Aug-2014', 'Sep-2014', 'Oct-2014', 'Nov-2014', 'Dec-2014', 'Jan-2015', 'Feb-2015', 'Mar-2015')
GROUP BY BookingId, GuestId, GuestName;
--
CREATE TABLE #FY2014_2015(GuestId BIGINT, GuestCnt INT, GuestName NVARCHAR(100), FY NVARCHAR(100));
INSERT INTO #FY2014_2015
SELECT GuestId, COUNT(GuestId) AS Cnt, LTRIM(GuestName) AS GuestName, FY FROM #FY2014_15
GROUP BY GuestId, GuestName, FY ORDER BY COUNT(GuestId) DESC;
--
CREATE TABLE #FY2015_16(BookingId BIGINT, GuestId BIGINT, GuestName NVARCHAR(100), FY NVARCHAR(100));
INSERT INTO #FY2015_16
SELECT BookingId, GuestId, GuestName, 'FY 2015 - 2016' FROM #TEMP2
WHERE asasd IN ('Apr-2015', 'May-2015', 'Jun-2015', 'Jul-2015', 'Aug-2015', 'Sep-2015', 'Oct-2015', 'Nov-2015', 'Dec-2015', 'Jan-2016', 'Feb-2016', 'Mar-2016')
GROUP BY BookingId, GuestId, GuestName;
--
CREATE TABLE #FY2015_2016(GuestId BIGINT, GuestCnt INT, GuestName NVARCHAR(100), FY NVARCHAR(100));
INSERT INTO #FY2015_2016
SELECT GuestId, COUNT(GuestId) AS Cnt, LTRIM(GuestName) AS GuestName, FY FROM #FY2015_16
GROUP BY GuestId, GuestName, FY ORDER BY COUNT(GuestId) DESC;
--
CREATE TABLE #FY2016_17(BookingId BIGINT, GuestId BIGINT, GuestName NVARCHAR(100), FY NVARCHAR(100));
INSERT INTO #FY2016_17
SELECT BookingId, GuestId, GuestName, 'FY 2016 - 2017' FROM #TEMP2
WHERE asasd IN ('Apr-2016', 'May-2016', 'Jun-2016', 'Jul-2016', 'Aug-2016', 'Sep-2016', 'Oct-2016', 'Nov-2016', 'Dec-2016', 'Jan-2017', 'Feb-2017', 'Mar-2017')
GROUP BY BookingId, GuestId, GuestName;
--
CREATE TABLE #FY2016_2017(GuestId BIGINT, GuestCnt INT, GuestName NVARCHAR(100), FY NVARCHAR(100));
INSERT INTO #FY2016_2017
SELECT GuestId, COUNT(GuestId) AS Cnt, LTRIM(GuestName) AS GuestName, FY FROM #FY2016_17
GROUP BY GuestId, GuestName, FY ORDER BY COUNT(GuestId) DESC;

CREATE TABLE #FY2017_18(BookingId BIGINT, GuestId BIGINT, GuestName NVARCHAR(100), FY NVARCHAR(100));
INSERT INTO #FY2017_18
SELECT BookingId, GuestId, GuestName, 'FY 2017 - 2018' FROM #TEMP2
WHERE asasd IN ('Apr-2017', 'May-2017', 'Jun-2017', 'Jul-2017', 'Aug-2017', 'Sep-2017', 'Oct-2017', 'Nov-2017', 'Dec-2017', 'Jan-2018', 'Feb-2018')
GROUP BY BookingId, GuestId, GuestName;
--
CREATE TABLE #FY2017_2018(GuestId BIGINT, GuestCnt INT, GuestName NVARCHAR(100), FY NVARCHAR(100));
INSERT INTO #FY2017_2018
SELECT GuestId, COUNT(GuestId) AS Cnt, LTRIM(GuestName) AS GuestName, FY FROM #FY2017_18
GROUP BY GuestId, GuestName, FY ORDER BY COUNT(GuestId) DESC;
-- GUEST COUNT REPORT SHEET 1
SELECT * FROM #FY2014_2015;

SELECT * FROM #FY2015_2016;

SELECT * FROM #FY2016_2017;

SELECT * FROM #FY2017_2018;
--
CREATE TABLE #FY(GuestId BIGINT, GuestName NVARCHAR(100), FY NVARCHAR(100));
INSERT INTO #FY
SELECT GuestId, GuestName, FY FROM #FY2014_2015 GROUP BY GuestId, GuestName, FY;
--
INSERT INTO #FY
SELECT GuestId, GuestName, FY FROM #FY2015_2016 GROUP BY GuestId, GuestName, FY;
--
INSERT INTO #FY
SELECT GuestId, GuestName, FY FROM #FY2016_2017 GROUP BY GuestId, GuestName, FY;
--
INSERT INTO #FY
SELECT GuestId, GuestName, FY FROM #FY2017_2018 GROUP BY GuestId, GuestName, FY;
-- GUEST COUNT REPORT SHEET 2
SELECT COUNT(GuestId), GuestId, GuestName FROM #FY GROUP BY GuestId, GuestName HAVING COUNT(GuestId) > 1 ORDER BY COUNT(GuestId) DESC, GuestName ASC;

-- GUEST COUNT REPORT SHEET 3

-- BOOKING COUNT
CREATE TABLE #BookCnt(BookingId BIGINT, FY NVARCHAR(100));
INSERT INTO #BookCnt
SELECT BookingId, '2014 - 2015' FROM WRBHBBookingStatus
WHERE Status != 'Canceled' AND BookingDate BETWEEN '2014-04-01' AND '2015-03-31';
--
INSERT INTO #BookCnt
SELECT BookingId, '2015 - 2016' FROM WRBHBBookingStatus
WHERE Status != 'Canceled' AND BookingDate BETWEEN '2015-04-01' AND '2016-03-31';
--
INSERT INTO #BookCnt
SELECT BookingId, '2016 - 2017' FROM WRBHBBookingStatus
WHERE Status != 'Canceled' AND BookingDate BETWEEN '2016-04-01' AND '2017-03-31';
--
INSERT INTO #BookCnt
SELECT BookingId, '2017 - 2018' FROM WRBHBBookingStatus
WHERE Status != 'Canceled' AND BookingDate BETWEEN '2017-04-01' AND '2018-03-31';
--
SELECT COUNT(BookingId), FY FROM #BookCnt GROUP BY FY ORDER BY FY;
--
CREATE TABLE #RecmdCnt(Id BIGINT, FY NVARCHAR(100));
--
INSERT INTO #RecmdCnt
SELECT Id, '2014 - 2015' FROM WRBHBBooking
WHERE TrackingNo != 0 AND Status != 'PtyConfirm' AND CONVERT(DATE, CreatedDate, 103) BETWEEN '2014-04-01' AND '2015-03-31';
--
INSERT INTO #RecmdCnt
SELECT Id, '2015 - 2016' FROM WRBHBBooking
WHERE TrackingNo != 0 AND Status != 'PtyConfirm' AND CONVERT(DATE, CreatedDate, 103) BETWEEN '2015-04-01' AND '2016-03-31';
--
INSERT INTO #RecmdCnt
SELECT Id, '2016 - 2017' FROM WRBHBBooking
WHERE TrackingNo != 0 AND Status != 'PtyConfirm' AND CONVERT(DATE, CreatedDate, 103) BETWEEN '2016-04-01' AND '2017-03-31';
--
INSERT INTO #RecmdCnt
SELECT Id, '2017 - 2018' FROM WRBHBBooking
WHERE TrackingNo != 0 AND Status != 'PtyConfirm' AND CONVERT(DATE, CreatedDate, 103) BETWEEN '2017-04-01' AND '2018-03-31';
--
SELECT COUNT(Id), FY FROM #RecmdCnt GROUP BY FY ORDER BY FY;
END
END