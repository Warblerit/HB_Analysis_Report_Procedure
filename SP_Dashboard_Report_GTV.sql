ALTER PROCEDURE [dbo].[SP_Dashboard_Report_GTV](
@Action NVARCHAR(100),
@Dt NVARCHAR(100),
@Str NVARCHAR(100),
@Id BIGINT)
/*
Exec [dbo].[SP_Dashboard_Report_GTV] @Action = '', @Dt = '01/09/2019', @Str = 'Sep-2019', @Id = 0;
*/
AS
BEGIN
SET NOCOUNT ON
SET ANSI_WARNINGS OFF
IF @Action = ''
BEGIN

DECLARE @From_Dt DATE = CONVERT(DATE, @Dt, 103);
DECLARE @To_Dt DATE = DATEADD(DAY, -1, DATEADD(MONTH, 1, @From_Dt));

CREATE TABLE #BookingId(BookingId BIGINT);
INSERT INTO #BookingId
SELECT BookingId FROM WRBHBBookingStatus S
WHERE
S.Status != 'Canceled' AND
S.PropertyCategory IN ('External', 'C P P') AND
(S.CheckInDt BETWEEN @From_Dt AND @To_Dt OR
S.CheckOutDt BETWEEN @From_Dt AND @To_Dt OR
(S.CheckInDt BETWEEN @From_Dt AND @To_Dt AND S.CheckOutDt BETWEEN @From_Dt AND @To_Dt) OR
(S.CheckInDt <= @From_Dt AND S.CheckOutDt >= @To_Dt))
GROUP BY
S.BookingId;

CREATE TABLE #Dashboard_TEMP1(BookingCode BIGINT,CheckInDt DATE,CheckOutDt DATE,Tariff DECIMAL(27,2),MarkUp DECIMAL(27,2),PropertyId BIGINT,MasterPropertyId BIGINT,
RoomCaptured BIGINT,BookingId BIGINT,CityId BIGINT,PropertyCategory NVARCHAR(100),ClientId BIGINT,MasterClientId BIGINT,BookedDt VARCHAR(100));
INSERT INTO #Dashboard_TEMP1
SELECT S.BookingCode,S.CheckInDt,S.CheckOutDt,SUM(S.Tariff),SUM(S.MarkUp),S.PropertyId,S.MasterPropertyId,RoomCaptured,S.BookingId,S.CityId,S.PropertyCategory,S.ClientId,
C.MasterClientId, SUBSTRING(DATENAME(MONTH, S.BookingDate), 1, 3) + '-' + CAST(YEAR(S.BookingDate) AS VARCHAR)
FROM WRBHBBookingStatus S
LEFT OUTER JOIN WRBHBClientManagement C WITH(NOLOCK)ON C.Id = S.ClientId
WHERE
S.Status != 'Canceled' AND
S.BookingId IN (SELECT BookingId FROM #BookingId)
GROUP BY
S.BookingCode,S.CheckInDt,S.CheckOutDt,S.Tariff,S.MarkUp,S.PropertyId,S.MasterPropertyId,RoomCaptured,S.BookingId,S.CityId,S.PropertyCategory,S.ClientId,
C.MasterClientId, S.BookingDate;

CREATE TABLE #Dashboard_TEMP2(BookingCode BIGINT,CalendarDate DATE,CheckInDt DATE,CheckOutDt DATE,Tariff DECIMAL(27,2),MarkUp DECIMAL(27,2),PropertyId BIGINT,
MasterPropertyId BIGINT,RoomCaptured BIGINT,BookingId BIGINT,CityId BIGINT,PropertyCategory NVARCHAR(100),ClientId BIGINT,asasd nvarchar(100),MasterClientId BIGINT);
INSERT INTO #Dashboard_TEMP2
SELECT S.BookingCode, C.calendarDate, S.CheckInDt, S.CheckOutDt, S.Tariff, ROUND(S.MarkUp / DATEDIFF(DAY,S.CheckInDt,S.CheckOutDt),0), S.PropertyId, S.MasterPropertyId,
S.RoomCaptured, S.BookingId, S.CityId, S.PropertyCategory, S.ClientId, SUBSTRING(DATENAME(MONTH,C.CalendarDate),1,3) + '-' + CAST(YEAR(C.CalendarDate) AS VARCHAR),
S.MasterClientId 
FROM #Dashboard_TEMP1 S
LEFT OUTER JOIN calendar.main C WITH(NOLOCK)ON C.calendarYear != 0
WHERE S.CheckInDt != S.CheckOutDt AND C.calendarDate BETWEEN S.CheckInDt AND DATEADD(DAY, -1, S.CheckOutDt);

INSERT INTO #Dashboard_TEMP2
SELECT S.BookingCode,S.CheckInDt,S.CheckInDt,S.CheckOutDt,S.Tariff,ROUND(S.MarkUp,0),S.PropertyId,S.MasterPropertyId,RoomCaptured,S.BookingId,S.CityId,S.PropertyCategory,
S.ClientId,SUBSTRING(DATENAME(MONTH,S.CheckInDt),1,3)+'-'+CAST(YEAR(S.CheckInDt) AS VARCHAR),S.MasterClientId FROM #Dashboard_TEMP1 S
WHERE S.CheckInDt = S.CheckOutDt;

CREATE TABLE #Dashboard_TEMP3(BookingCode BIGINT,CalendarDate DATE,CheckInDt DATE,CheckOutDt DATE,Tariff DECIMAL(27,2),MarkUp DECIMAL(27,2),PropertyId BIGINT,
MasterPropertyId BIGINT,RoomCaptured BIGINT,BookingId BIGINT,CityId BIGINT,PropertyCategory NVARCHAR(100),ClientId BIGINT,asasd nvarchar(100),MasterClientId BIGINT);

INSERT INTO #Dashboard_TEMP3
SELECT BookingCode, CalendarDate, CheckInDt, CheckOutDt, Tariff, MarkUp, PropertyId, MasterPropertyId, RoomCaptured, BookingId, CityId, PropertyCategory, ClientId,
asasd, MasterClientId
FROM #Dashboard_TEMP2
WHERE asasd IN (@Str);

CREATE TABLE #Dashboard_GTV_WithOutMarkup(MasterClientId BIGINT, RoomNightCount INT, GTV DECIMAL(27,2));
INSERT INTO #Dashboard_GTV_WithOutMarkup
SELECT MasterClientId, COUNT(CalendarDate), SUM(Tariff)
FROM #Dashboard_TEMP3
WHERE MarkUp = 0
GROUP BY MasterClientId;

CREATE TABLE #Dashboard_GTV_WithMarkup(MasterClientId BIGINT, RoomNightCount INT, GTV DECIMAL(27,2));
INSERT INTO #Dashboard_GTV_WithMarkup
SELECT MasterClientId, COUNT(CalendarDate), SUM(Tariff)
FROM #Dashboard_TEMP3
WHERE MarkUp != 0
GROUP BY MasterClientId;

CREATE TABLE #ClientDtls(MasterClientId BIGINT, MasterClientName NVARCHAR(100));
INSERT INTO #ClientDtls
SELECT G.MasterClientId, M.ClientName FROM #Dashboard_TEMP3 G
LEFT OUTER JOIN WRBHBMasterClientManagement M WITH(NOLOCK)ON G.MasterClientId = M.Id
WHERE M.ClientName <> ''
GROUP BY G.MasterClientId, M.ClientName;

SELECT C.MasterClientName, ISNULL(G2.RoomNightCount, 0) AS WithMarkup_RoomNightCount, ISNULL(G1.RoomNightCount, 0) AS WithOutMarkup_RoomNightCount,
ISNULL(G2.GTV, 0) AS WithMarkup_GTV, ISNULL(G1.GTV, 0) AS WithOutMarkup_GTV
FROM #ClientDtls C
LEFT OUTER JOIN #Dashboard_GTV_WithOutMarkup G1 ON C.MasterClientId = G1.MasterClientId
LEFT OUTER JOIN #Dashboard_GTV_WithMarkup G2 ON C.MasterClientId = G2.MasterClientId
ORDER BY C.MasterClientName;

END
END