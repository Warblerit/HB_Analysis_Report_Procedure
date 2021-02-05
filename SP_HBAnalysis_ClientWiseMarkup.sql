-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[SP_HBAnalysis_ClientWiseMarkup]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
DROP PROCEDURE [dbo].[SP_HBAnalysis_ClientWiseMarkup]
GO 
CREATE PROCEDURE [dbo].[SP_HBAnalysis_ClientWiseMarkup](@Action NVARCHAR(100),@Str NVARCHAR(100),@Id BIGINT)
--Exec [dbo].[SP_HBAnalysis_ClientWiseMarkup] @Action = '',@Str = '',@Id = 0;
AS
BEGIN
SET NOCOUNT ON
SET ANSI_WARNINGS OFF
IF @Action = ''
BEGIN
CREATE TABLE #TEMP1(BookingCode BIGINT,CheckInDt DATE,CheckOutDt DATE,Tariff DECIMAL(27,2),MarkUp DECIMAL(27,2),PropertyId BIGINT,MasterPropertyId BIGINT,
RoomCaptured BIGINT,BookingId BIGINT,CityId BIGINT,PropertyCategory NVARCHAR(100),ClientId BIGINT,MasterClientId BIGINT);
INSERT INTO #TEMP1
SELECT S.BookingCode,S.CheckInDt,S.CheckOutDt,SUM(S.Tariff),SUM(S.MarkUp),S.PropertyId,S.MasterPropertyId,RoomCaptured,S.BookingId,S.CityId,S.PropertyCategory,S.ClientId,
C.MasterClientId
FROM WRBHBBookingStatus S
LEFT OUTER JOIN WRBHBClientManagement C WITH(NOLOCK)ON C.Id = S.ClientId
WHERE S.Status != 'Canceled'
GROUP BY S.BookingCode,S.CheckInDt,S.CheckOutDt,S.Tariff,S.MarkUp,S.PropertyId,S.MasterPropertyId,RoomCaptured,S.BookingId,S.CityId,S.PropertyCategory,S.ClientId,
C.MasterClientId;
--
CREATE TABLE #TEMP2(BookingCode BIGINT,CalendarDate DATE,CheckInDt DATE,CheckOutDt DATE,Tariff DECIMAL(27,2),MarkUp DECIMAL(27,2),PropertyId BIGINT,
MasterPropertyId BIGINT,RoomCaptured BIGINT,BookingId BIGINT,CityId BIGINT,PropertyCategory NVARCHAR(100),ClientId BIGINT,asasd nvarchar(100),MasterClientId BIGINT);
INSERT INTO #TEMP2
SELECT S.BookingCode, C.calendarDate, S.CheckInDt, S.CheckOutDt, S.Tariff, ROUND(S.MarkUp / DATEDIFF(DAY,S.CheckInDt,S.CheckOutDt),0), S.PropertyId, S.MasterPropertyId,
S.RoomCaptured, S.BookingId, S.CityId, S.PropertyCategory, S.ClientId, SUBSTRING(DATENAME(MONTH,C.CalendarDate),1,3) + '-' + CAST(YEAR(C.CalendarDate) AS VARCHAR),
S.MasterClientId 
FROM #TEMP1 S
LEFT OUTER JOIN calendar.main C WITH(NOLOCK)ON C.calendarYear != 0
WHERE S.CheckInDt != S.CheckOutDt AND C.calendarDate BETWEEN S.CheckInDt AND DATEADD(DAY, -1, S.CheckOutDt);
--
INSERT INTO #TEMP2
SELECT S.BookingCode,S.CheckInDt,S.CheckInDt,S.CheckOutDt,S.Tariff,ROUND(S.MarkUp,0),S.PropertyId,S.MasterPropertyId,RoomCaptured,S.BookingId,S.CityId,S.PropertyCategory,
S.ClientId,SUBSTRING(DATENAME(MONTH,S.CheckInDt),1,3)+'-'+CAST(YEAR(S.CheckInDt) AS VARCHAR),S.MasterClientId FROM #TEMP1 S
WHERE S.CheckInDt = S.CheckOutDt;

DELETE #TEMP2 WHERE asasd NOT IN ('Apr-2017', 'May-2017', 'Jun-2017', 'Jul-2017', 'Aug-2017', 'Sep-2017', 'Oct-2017', 'Nov-2017', 'Dec-2017', 'Jan-2018', 'Feb-2018', 'Mar-2018',
'Apr-2018', 'May-2018', 'Jun-2018', 'Jul-2018', 'Aug-2018', 'Sep-2018', 'Oct-2018', 'Nov-2018', 'Dec-2018');

CREATE TABLE #MasterClient_Temp1(Cnt INT, MonthofBooking NVARCHAR(100), MasterClientId BIGINT);
INSERT INTO #MasterClient_Temp1
SELECT COUNT(CalendarDate), asasd, MasterClientId FROM #TEMP2
GROUP BY asasd, MasterClientId;
--
SELECT   MasterClientId, 
		 [Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
		 [Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019]
INTO #MasterClient_Temp2
FROM #MasterClient_Temp1
PIVOT
(
       SUM(Cnt)
       FOR MonthofBooking IN 
	   ([Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
		[Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019])
) AS P;
--
CREATE TABLE #MasterClient_Temp3(MasterClientId BIGINT,
[Apr-2017] INT, [May-2017] INT, [Jun-2017] INT, [Jul-2017] INT, [Aug-2017] INT, [Sep-2017] INT, [Oct-2017] INT, [Nov-2017] INT, [Dec-2017] INT,
[Jan-2018] INT, [Feb-2018] INT, [Mar-2018] INT,
[Apr-2018] INT, [May-2018] INT, [Jun-2018] INT, [Jul-2018] INT, [Aug-2018] INT, [Sep-2018] INT, [Oct-2018] INT, [Nov-2018] INT, [Dec-2018] INT,
[Jan-2019] INT, [Feb-2019] INT, [Mar-2019] INT);
--
INSERT INTO #MasterClient_Temp3
SELECT MasterClientId,
ISNULL([Apr-2017],0), ISNULL([May-2017],0), ISNULL([Jun-2017],0), ISNULL([Jul-2017],0), ISNULL([Aug-2017],0), ISNULL([Sep-2017],0), ISNULL([Oct-2017],0), 
ISNULL([Nov-2017],0), ISNULL([Dec-2017],0), ISNULL([Jan-2018],0), ISNULL([Feb-2018],0), ISNULL([Mar-2018],0),
ISNULL([Apr-2018],0), ISNULL([May-2018],0), ISNULL([Jun-2018],0), ISNULL([Jul-2018],0), ISNULL([Aug-2018],0), ISNULL([Sep-2018],0), ISNULL([Oct-2018],0), 
ISNULL([Nov-2018],0), ISNULL([Dec-2018],0), ISNULL([Jan-2019],0), ISNULL([Feb-2019],0), ISNULL([Mar-2019],0)
FROM #MasterClient_Temp2

--SELECT * FROM #MasterClient_Temp3;

-- MARKUP

CREATE TABLE #MasterClient_Temp4(MonthofBooking NVARCHAR(100), MasterClientId BIGINT, MarkUp DECIMAL(27, 2));
INSERT INTO #MasterClient_Temp4
SELECT asasd, MasterClientId, SUM(MarkUp) FROM #TEMP2 WHERE  PropertyCategory IN ('External','C P P')
GROUP BY asasd, MasterClientId;

SELECT   MasterClientId,
         [Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
		 [Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019]
INTO #MasterClient_Temp5
FROM #MasterClient_Temp4
PIVOT
(
       SUM(MarkUp)
       FOR MonthofBooking IN 
	   ([Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
		[Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019])
) AS P1;
--
CREATE TABLE #MasterClient_Temp6(MasterClientId BIGINT,
[Apr-2017] DECIMAL(27, 2), [May-2017] DECIMAL(27, 2), [Jun-2017] DECIMAL(27, 2), [Jul-2017] DECIMAL(27, 2), [Aug-2017] DECIMAL(27, 2), [Sep-2017] DECIMAL(27, 2),
[Oct-2017] DECIMAL(27, 2), [Nov-2017] DECIMAL(27, 2), [Dec-2017] DECIMAL(27, 2), [Jan-2018] DECIMAL(27, 2), [Feb-2018] DECIMAL(27, 2), [Mar-2018] DECIMAL(27, 2),
[Apr-2018] DECIMAL(27, 2), [May-2018] DECIMAL(27, 2), [Jun-2018] DECIMAL(27, 2), [Jul-2018] DECIMAL(27, 2), [Aug-2018] DECIMAL(27, 2), [Sep-2018] DECIMAL(27, 2),
[Oct-2018] DECIMAL(27, 2), [Nov-2018] DECIMAL(27, 2), [Dec-2018] DECIMAL(27, 2), [Jan-2019] DECIMAL(27, 2), [Feb-2019] DECIMAL(27, 2), [Mar-2019] DECIMAL(27, 2));
--
INSERT INTO #MasterClient_Temp6
SELECT MasterClientId,
ROUND(ISNULL([Apr-2017], 0) * 0.00001, 2), ROUND(ISNULL([May-2017], 0) * 0.00001, 2), ROUND(ISNULL([Jun-2017], 0) * 0.00001, 2), ROUND(ISNULL([Jul-2017], 0) * 0.00001, 2),
ROUND(ISNULL([Aug-2017], 0) * 0.00001, 2), ROUND(ISNULL([Sep-2017], 0) * 0.00001, 2), ROUND(ISNULL([Oct-2017], 0) * 0.00001, 2), ROUND(ISNULL([Nov-2017], 0) * 0.00001, 2),
ROUND(ISNULL([Dec-2017], 0) * 0.00001, 2), ROUND(ISNULL([Jan-2018], 0) * 0.00001, 2), ROUND(ISNULL([Feb-2018], 0) * 0.00001, 2), ROUND(ISNULL([Mar-2018], 0) * 0.00001, 2),
ROUND(ISNULL([Apr-2018], 0) * 0.00001, 2), ROUND(ISNULL([May-2018], 0) * 0.00001, 2), ROUND(ISNULL([Jun-2018], 0) * 0.00001, 2), ROUND(ISNULL([Jul-2018], 0) * 0.00001, 2),
ROUND(ISNULL([Aug-2018], 0) * 0.00001, 2), ROUND(ISNULL([Sep-2018], 0) * 0.00001, 2), ROUND(ISNULL([Oct-2018], 0) * 0.00001, 2), ROUND(ISNULL([Nov-2018], 0) * 0.00001, 2),
ROUND(ISNULL([Dec-2018], 0) * 0.00001, 2), ROUND(ISNULL([Jan-2019], 0) * 0.00001, 2), ROUND(ISNULL([Feb-2019], 0) * 0.00001, 2), ROUND(ISNULL([Mar-2019], 0) * 0.00001, 2)
FROM #MasterClient_Temp5;

--SELECT * FROM #MasterClient_Temp6;

--SELECT  COUNT(*) FROM #MasterClient_Temp3 WHERE [Dec-2018] != 0;
--SELECT  COUNT(*) FROM #MasterClient_Temp6 WHERE [Dec-2018] != 0;

SELECT C.ClientName, R.MasterClientId, M.MasterClientId,
R.[Dec-2018] AS RN_Dec_18, ISNULL(M.[Dec-2018], 0) AS M_Dec_18, R.[Nov-2018] AS RN_Nov_18, ISNULL(M.[Nov-2018], 0) AS M_Nov_18,
R.[Oct-2018] AS RN_Oct_18, ISNULL(M.[Oct-2018], 0) AS M_Oct_18, R.[Sep-2018] AS RN_Sep_18, ISNULL(M.[Sep-2018], 0) AS M_Sep_18,
R.[Aug-2018] AS RN_Aug_18, ISNULL(M.[Aug-2018], 0) AS M_Aug_18, R.[Jul-2018] AS RN_Jul_18, ISNULL(M.[Jul-2018], 0) AS M_Jul_18,
R.[Jun-2018] AS RN_Jun_18, ISNULL(M.[Jun-2018], 0) AS M_Jun_18, R.[May-2018] AS RN_May_18, ISNULL(M.[May-2018], 0) AS M_May_18,
R.[Apr-2018] AS RN_Apr_18, ISNULL(M.[Apr-2018], 0) AS M_Apr_18, R.[Mar-2018] AS RN_Mar_18, ISNULL(M.[Mar-2018], 0) AS M_Mar_18,
R.[Feb-2018] AS RN_Feb_18, ISNULL(M.[Feb-2018], 0) AS M_Feb_18, R.[Jan-2018] AS RN_Jan_18, ISNULL(M.[Jan-2018], 0) AS M_Jan_18,
R.[Dec-2017] AS RN_Dec_17, ISNULL(M.[Dec-2017], 0) AS M_Dec_17, R.[Nov-2017] AS RN_Nov_17, ISNULL(M.[Nov-2017], 0) AS M_Nov_17,
R.[Oct-2017] AS RN_Oct_17, ISNULL(M.[Oct-2017], 0) AS M_Oct_17, R.[Sep-2017] AS RN_Sep_17, ISNULL(M.[Sep-2017], 0) AS M_Sep_17,
R.[Aug-2017] AS RN_Aug_17, ISNULL(M.[Aug-2017], 0) AS M_Aug_17, R.[Jul-2017] AS RN_Jul_17, ISNULL(M.[Jul-2017], 0) AS M_Jul_17,
R.[Jun-2017] AS RN_Jun_17, ISNULL(M.[Jun-2017], 0) AS M_Jun_17, R.[May-2017] AS RN_May_17, ISNULL(M.[May-2017], 0) AS M_May_17,
R.[Apr-2017] AS RN_Apr_17, ISNULL(M.[Apr-2017], 0) AS M_Apr_17
FROM #MasterClient_Temp3 R
LEFT OUTER JOIN #MasterClient_Temp6 M WITH(NOLOCK)ON R.MasterClientId = M.MasterClientId
LEFT OUTER JOIN  WRBHBMasterClientManagement C WITH(NOLOCK)ON R.MasterClientId = C.Id
WHERE R.MasterClientId = C.Id --AND (R.[Dec-2018] != 0 OR ISNULL(M.[Dec-2018], 0) != 0)
ORDER BY R.[Dec-2018] DESC, ISNULL(M.[Dec-2018], 0) DESC;

END
END