-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[SP_HBAnalysis_Jun2018]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
DROP PROCEDURE [dbo].[SP_HBAnalysis_Jun2018]
GO 
CREATE PROCEDURE [dbo].[SP_HBAnalysis_Jun2018](@Action NVARCHAR(100),@Str NVARCHAR(100),@Id BIGINT)
--Exec [dbo].[SP_HBAnalysis_Jun2018] @Action = '',@Str = '',@Id = 0;
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

----- Daily Tracking Report Start -----

CREATE TABLE #dsadasd(MasterPropertyId BIGINT, PropertyCategory NVARCHAR(100), cnt INT, MonthofBooking NVARCHAR(100), Tariff DECIMAL(27,2),MarkUp DECIMAL(27,2),
MasterClientId BIGINT);
INSERT INTO #dsadasd(MasterPropertyId,PropertyCategory,cnt,MonthofBooking,Tariff,MarkUp,MasterClientId)
SELECT MasterPropertyId,PropertyCategory,COUNT(CalendarDate),asasd,SUM(Tariff),SUM(MarkUp),MasterClientId FROM #TEMP2 
GROUP BY MasterPropertyId,PropertyCategory,asasd,MasterClientId;
--
SELECT   MasterPropertyId,PropertyCategory,MasterClientId, 
         [Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
		 [Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
		 [Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
		 [Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
		 [Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019]
INTO #output
FROM #dsadasd
PIVOT
(
       SUM(Cnt)
       FOR MonthofBooking IN 
	   ([Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
		[Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
		[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
		[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
		[Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019])
) AS P;
--
CREATE TABLE #TEMPDAILYREPORTCOUNT(MasterPropertyId BIGINT,PropertyCategory NVARCHAR(100),MasterClientId BIGINT,
[Apr-2014] INT, [May-2014] INT, [Jun-2014] INT, [Jul-2014] INT, [Aug-2014] INT, [Sep-2014] INT, [Oct-2014] INT, [Nov-2014] INT, [Dec-2014] INT, 
[Jan-2015] INT, [Feb-2015] INT, [Mar-2015] INT,
[Apr-2015] INT, [May-2015] INT, [Jun-2015] INT, [Jul-2015] INT, [Aug-2015] INT, [Sep-2015] INT, [Oct-2015] INT, [Nov-2015] INT, [Dec-2015] INT, 
[Jan-2016] INT, [Feb-2016] INT, [Mar-2016] INT, 
[Apr-2016] INT, [May-2016] INT, [Jun-2016] INT, [Jul-2016] INT, [Aug-2016] INT, [Sep-2016] INT, [Oct-2016] INT, [Nov-2016] INT, [Dec-2016] INT, 
[Jan-2017] INT, [Feb-2017] INT, [Mar-2017] INT, 
[Apr-2017] INT, [May-2017] INT, [Jun-2017] INT, [Jul-2017] INT, [Aug-2017] INT, [Sep-2017] INT, [Oct-2017] INT, [Nov-2017] INT, [Dec-2017] INT,
[Jan-2018] INT, [Feb-2018] INT, [Mar-2018] INT,
[Apr-2018] INT, [May-2018] INT, [Jun-2018] INT, [Jul-2018] INT, [Aug-2018] INT, [Sep-2018] INT, [Oct-2018] INT, [Nov-2018] INT, [Dec-2018] INT,
[Jan-2019] INT, [Feb-2019] INT, [Mar-2019] INT);
--
INSERT INTO #TEMPDAILYREPORTCOUNT
SELECT MasterPropertyId,PropertyCategory,MasterClientId,
ISNULL([Apr-2014],0), ISNULL([May-2014],0), ISNULL([Jun-2014],0), ISNULL([Jul-2014],0), ISNULL([Aug-2014],0), ISNULL([Sep-2014],0), ISNULL([Oct-2014],0), 
ISNULL([Nov-2014],0), ISNULL([Dec-2014],0), ISNULL([Jan-2015],0), ISNULL([Feb-2015],0), ISNULL([Mar-2015],0), 
ISNULL([Apr-2015],0), ISNULL([May-2015],0), ISNULL([Jun-2015],0), ISNULL([Jul-2015],0), ISNULL([Aug-2015],0), ISNULL([Sep-2015],0), ISNULL([Oct-2015],0), 
ISNULL([Nov-2015],0), ISNULL([Dec-2015],0), ISNULL([Jan-2016],0), ISNULL([Feb-2016],0), ISNULL([Mar-2016],0), 
ISNULL([Apr-2016],0), ISNULL([May-2016],0), ISNULL([Jun-2016],0), ISNULL([Jul-2016],0), ISNULL([Aug-2016],0), ISNULL([Sep-2016],0), ISNULL([Oct-2016],0), 
ISNULL([Nov-2016],0), ISNULL([Dec-2016],0), ISNULL([Jan-2017],0), ISNULL([Feb-2017],0), ISNULL([Mar-2017],0), 
ISNULL([Apr-2017],0), ISNULL([May-2017],0), ISNULL([Jun-2017],0), ISNULL([Jul-2017],0), ISNULL([Aug-2017],0), ISNULL([Sep-2017],0), ISNULL([Oct-2017],0), 
ISNULL([Nov-2017],0), ISNULL([Dec-2017],0), ISNULL([Jan-2018],0), ISNULL([Feb-2018],0), ISNULL([Mar-2018],0),
ISNULL([Apr-2018],0), ISNULL([May-2018],0), ISNULL([Jun-2018],0), ISNULL([Jul-2018],0), ISNULL([Aug-2018],0), ISNULL([Sep-2018],0), ISNULL([Oct-2018],0), 
ISNULL([Nov-2018],0), ISNULL([Dec-2018],0), ISNULL([Jan-2019],0), ISNULL([Feb-2019],0), ISNULL([Mar-2019],0)  FROM #output;

-- master property wise room nights

CREATE TABLE #TDRNew(MasterPropertyId BIGINT,
[Apr-2014] INT, [May-2014] INT, [Jun-2014] INT, [Jul-2014] INT, [Aug-2014] INT, [Sep-2014] INT, [Oct-2014] INT, [Nov-2014] INT, [Dec-2014] INT, 
[Jan-2015] INT, [Feb-2015] INT, [Mar-2015] INT,
[Apr-2015] INT, [May-2015] INT, [Jun-2015] INT, [Jul-2015] INT, [Aug-2015] INT, [Sep-2015] INT, [Oct-2015] INT, [Nov-2015] INT, [Dec-2015] INT, 
[Jan-2016] INT, [Feb-2016] INT, [Mar-2016] INT, 
[Apr-2016] INT, [May-2016] INT, [Jun-2016] INT, [Jul-2016] INT, [Aug-2016] INT, [Sep-2016] INT, [Oct-2016] INT, [Nov-2016] INT, [Dec-2016] INT, 
[Jan-2017] INT, [Feb-2017] INT, [Mar-2017] INT, 
[Apr-2017] INT, [May-2017] INT, [Jun-2017] INT, [Jul-2017] INT, [Aug-2017] INT, [Sep-2017] INT, [Oct-2017] INT, [Nov-2017] INT, [Dec-2017] INT,
[Jan-2018] INT, [Feb-2018] INT, [Mar-2018] INT,
[Apr-2018] INT, [May-2018] INT, [Jun-2018] INT, [Jul-2018] INT, [Aug-2018] INT, [Sep-2018] INT, [Oct-2018] INT, [Nov-2018] INT, [Dec-2018] INT,
[Jan-2019] INT, [Feb-2019] INT, [Mar-2019] INT, Id BIGINT IDENTITY(1,1));
--
INSERT INTO #TDRNew
SELECT MasterPropertyId,
SUM([Apr-2014]), SUM([May-2014]), SUM([Jun-2014]), SUM([Jul-2014]), SUM([Aug-2014]), SUM([Sep-2014]), SUM([Oct-2014]), SUM([Nov-2014]), SUM([Dec-2014]), 
SUM([Jan-2015]), SUM([Feb-2015]), SUM([Mar-2015]),
SUM([Apr-2015]), SUM([May-2015]), SUM([Jun-2015]), SUM([Jul-2015]), SUM([Aug-2015]), SUM([Sep-2015]), SUM([Oct-2015]), SUM([Nov-2015]), SUM([Dec-2015]), 
SUM([Jan-2016]), SUM([Feb-2016]), SUM([Mar-2016]), 
SUM([Apr-2016]), SUM([May-2016]), SUM([Jun-2016]), SUM([Jul-2016]), SUM([Aug-2016]), SUM([Sep-2016]), SUM([Oct-2016]), SUM([Nov-2016]), SUM([Dec-2016]), 
SUM([Jan-2017]), SUM([Feb-2017]), SUM([Mar-2017]), 
SUM([Apr-2017]), SUM([May-2017]), SUM([Jun-2017]), SUM([Jul-2017]), SUM([Aug-2017]), SUM([Sep-2017]), SUM([Oct-2017]), SUM([Nov-2017]), SUM([Dec-2017]), 
SUM([Jan-2018]), SUM([Feb-2018]), SUM([Mar-2018]),
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019])
FROM #TEMPDAILYREPORTCOUNT T
WHERE PropertyCategory IN ('External','C P P') AND MasterPropertyId NOT IN (1,0)
GROUP BY MasterPropertyId
ORDER BY SUM([Jun-2018]) DESC;
--
CREATE TABLE #TDR(MasterPropertyName NVARCHAR(100), MasterPropertyId BIGINT, Flg INT,
[Apr-2014] INT, [May-2014] INT, [Jun-2014] INT, [Jul-2014] INT, [Aug-2014] INT, [Sep-2014] INT, [Oct-2014] INT, [Nov-2014] INT, [Dec-2014] INT, 
[Jan-2015] INT, [Feb-2015] INT, [Mar-2015] INT,
[Apr-2015] INT, [May-2015] INT, [Jun-2015] INT, [Jul-2015] INT, [Aug-2015] INT, [Sep-2015] INT, [Oct-2015] INT, [Nov-2015] INT, [Dec-2015] INT, 
[Jan-2016] INT, [Feb-2016] INT, [Mar-2016] INT, 
[Apr-2016] INT, [May-2016] INT, [Jun-2016] INT, [Jul-2016] INT, [Aug-2016] INT, [Sep-2016] INT, [Oct-2016] INT, [Nov-2016] INT, [Dec-2016] INT, 
[Jan-2017] INT, [Feb-2017] INT, [Mar-2017] INT, 
[Apr-2017] INT, [May-2017] INT, [Jun-2017] INT, [Jul-2017] INT, [Aug-2017] INT, [Sep-2017] INT, [Oct-2017] INT, [Nov-2017] INT, [Dec-2017] INT,
[Jan-2018] INT, [Feb-2018] INT, [Mar-2018] INT,
[Apr-2018] INT, [May-2018] INT, [Jun-2018] INT, [Jul-2018] INT, [Aug-2018] INT, [Sep-2018] INT, [Oct-2018] INT, [Nov-2018] INT, [Dec-2018] INT,
[Jan-2019] INT, [Feb-2019] INT, [Mar-2019] INT);
--
INSERT INTO #TDR
SELECT TOP 20 P.MasterPropertyName, T.MasterPropertyId, 1,
[Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
[Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
[Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019]
FROM #TDRNew T
LEFT OUTER JOIN WRBHBMasterProperty P ON P.Id = T.MasterPropertyId
ORDER BY T.Id;
--
INSERT INTO #TDR
SELECT 'Other than Top 20 Property', 0, 2,
SUM([Apr-2014]), SUM([May-2014]), SUM([Jun-2014]), SUM([Jul-2014]), SUM([Aug-2014]), SUM([Sep-2014]), SUM([Oct-2014]), SUM([Nov-2014]), SUM([Dec-2014]), 
SUM([Jan-2015]), SUM([Feb-2015]), SUM([Mar-2015]),
SUM([Apr-2015]), SUM([May-2015]), SUM([Jun-2015]), SUM([Jul-2015]), SUM([Aug-2015]), SUM([Sep-2015]), SUM([Oct-2015]), SUM([Nov-2015]), SUM([Dec-2015]), 
SUM([Jan-2016]), SUM([Feb-2016]), SUM([Mar-2016]), 
SUM([Apr-2016]), SUM([May-2016]), SUM([Jun-2016]), SUM([Jul-2016]), SUM([Aug-2016]), SUM([Sep-2016]), SUM([Oct-2016]), SUM([Nov-2016]), SUM([Dec-2016]), 
SUM([Jan-2017]), SUM([Feb-2017]), SUM([Mar-2017]), 
SUM([Apr-2017]), SUM([May-2017]), SUM([Jun-2017]), SUM([Jul-2017]), SUM([Aug-2017]), SUM([Sep-2017]), SUM([Oct-2017]), SUM([Nov-2017]), SUM([Dec-2017]), 
SUM([Jan-2018]), SUM([Feb-2018]), SUM([Mar-2018]),
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019])
FROM #TDRNew T
WHERE T.Id > 20;
--
INSERT INTO #TDR
SELECT 'Total', 0, 3,
SUM([Apr-2014]), SUM([May-2014]), SUM([Jun-2014]), SUM([Jul-2014]), SUM([Aug-2014]), SUM([Sep-2014]), SUM([Oct-2014]), SUM([Nov-2014]), SUM([Dec-2014]), 
SUM([Jan-2015]), SUM([Feb-2015]), SUM([Mar-2015]),
SUM([Apr-2015]), SUM([May-2015]), SUM([Jun-2015]), SUM([Jul-2015]), SUM([Aug-2015]), SUM([Sep-2015]), SUM([Oct-2015]), SUM([Nov-2015]), SUM([Dec-2015]), 
SUM([Jan-2016]), SUM([Feb-2016]), SUM([Mar-2016]), 
SUM([Apr-2016]), SUM([May-2016]), SUM([Jun-2016]), SUM([Jul-2016]), SUM([Aug-2016]), SUM([Sep-2016]), SUM([Oct-2016]), SUM([Nov-2016]), SUM([Dec-2016]), 
SUM([Jan-2017]), SUM([Feb-2017]), SUM([Mar-2017]), 
SUM([Apr-2017]), SUM([May-2017]), SUM([Jun-2017]), SUM([Jul-2017]), SUM([Aug-2017]), SUM([Sep-2017]), SUM([Oct-2017]), SUM([Nov-2017]), SUM([Dec-2017]), 
SUM([Jan-2018]), SUM([Feb-2018]), SUM([Mar-2018]),
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019])
FROM #TDR;

-- TABLE 1 & 2

/*
SELECT 'Property ( Hotel Chain ) - Room Nights ( Booking Month )                                                                  Value in No"s' AS Title;
SELECT MasterPropertyName AS PropertyName,
[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], 
[Jan-2017], [Feb-2017], [Mar-2017], [Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], 
[Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018] 
FROM #TDR T;
*/

-- client wise room nights

CREATE TABLE #TDRClient(MasterClientName NVARCHAR(100), MasterClientId BIGINT, Flg INT,
[Apr-2014] INT, [May-2014] INT, [Jun-2014] INT, [Jul-2014] INT, [Aug-2014] INT, [Sep-2014] INT, [Oct-2014] INT, [Nov-2014] INT, [Dec-2014] INT, 
[Jan-2015] INT, [Feb-2015] INT, [Mar-2015] INT,
[Apr-2015] INT, [May-2015] INT, [Jun-2015] INT, [Jul-2015] INT, [Aug-2015] INT, [Sep-2015] INT, [Oct-2015] INT, [Nov-2015] INT, [Dec-2015] INT, 
[Jan-2016] INT, [Feb-2016] INT, [Mar-2016] INT, 
[Apr-2016] INT, [May-2016] INT, [Jun-2016] INT, [Jul-2016] INT, [Aug-2016] INT, [Sep-2016] INT, [Oct-2016] INT, [Nov-2016] INT, [Dec-2016] INT, 
[Jan-2017] INT, [Feb-2017] INT, [Mar-2017] INT, 
[Apr-2017] INT, [May-2017] INT, [Jun-2017] INT, [Jul-2017] INT, [Aug-2017] INT, [Sep-2017] INT, [Oct-2017] INT, [Nov-2017] INT, [Dec-2017] INT,
[Jan-2018] INT, [Feb-2018] INT, [Mar-2018] INT,
[Apr-2018] INT, [May-2018] INT, [Jun-2018] INT, [Jul-2018] INT, [Aug-2018] INT, [Sep-2018] INT, [Oct-2018] INT, [Nov-2018] INT, [Dec-2018] INT,
[Jan-2019] INT, [Feb-2019] INT, [Mar-2019] INT);
--
INSERT INTO #TDRClient
SELECT C.ClientName,T.MasterClientId, 1,
SUM([Apr-2014]), SUM([May-2014]), SUM([Jun-2014]), SUM([Jul-2014]), SUM([Aug-2014]), SUM([Sep-2014]), SUM([Oct-2014]), SUM([Nov-2014]), SUM([Dec-2014]), 
SUM([Jan-2015]), SUM([Feb-2015]), SUM([Mar-2015]),
SUM([Apr-2015]), SUM([May-2015]), SUM([Jun-2015]), SUM([Jul-2015]), SUM([Aug-2015]), SUM([Sep-2015]), SUM([Oct-2015]), SUM([Nov-2015]), SUM([Dec-2015]), 
SUM([Jan-2016]), SUM([Feb-2016]), SUM([Mar-2016]), 
SUM([Apr-2016]), SUM([May-2016]), SUM([Jun-2016]), SUM([Jul-2016]), SUM([Aug-2016]), SUM([Sep-2016]), SUM([Oct-2016]), SUM([Nov-2016]), SUM([Dec-2016]), 
SUM([Jan-2017]), SUM([Feb-2017]), SUM([Mar-2017]), 
SUM([Apr-2017]), SUM([May-2017]), SUM([Jun-2017]), SUM([Jul-2017]), SUM([Aug-2017]), SUM([Sep-2017]), SUM([Oct-2017]), SUM([Nov-2017]), SUM([Dec-2017]), 
SUM([Jan-2018]), SUM([Feb-2018]), SUM([Mar-2018]),
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019])
FROM #TEMPDAILYREPORTCOUNT T
LEFT OUTER JOIN WRBHBMasterClientManagement C ON C.Id = T.MasterClientId
WHERE T.MasterClientId IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1) AND PropertyCategory IN ('External','C P P')
GROUP BY C.ClientName, T.MasterClientId;
--
INSERT INTO #TDRClient
SELECT 'Other Clients', 0, 2,
SUM([Apr-2014]), SUM([May-2014]), SUM([Jun-2014]), SUM([Jul-2014]), SUM([Aug-2014]), SUM([Sep-2014]), SUM([Oct-2014]), SUM([Nov-2014]), SUM([Dec-2014]), 
SUM([Jan-2015]), SUM([Feb-2015]), SUM([Mar-2015]),
SUM([Apr-2015]), SUM([May-2015]), SUM([Jun-2015]), SUM([Jul-2015]), SUM([Aug-2015]), SUM([Sep-2015]), SUM([Oct-2015]), SUM([Nov-2015]), SUM([Dec-2015]), 
SUM([Jan-2016]), SUM([Feb-2016]), SUM([Mar-2016]), 
SUM([Apr-2016]), SUM([May-2016]), SUM([Jun-2016]), SUM([Jul-2016]), SUM([Aug-2016]), SUM([Sep-2016]), SUM([Oct-2016]), SUM([Nov-2016]), SUM([Dec-2016]), 
SUM([Jan-2017]), SUM([Feb-2017]), SUM([Mar-2017]), 
SUM([Apr-2017]), SUM([May-2017]), SUM([Jun-2017]), SUM([Jul-2017]), SUM([Aug-2017]), SUM([Sep-2017]), SUM([Oct-2017]), SUM([Nov-2017]), SUM([Dec-2017]), 
SUM([Jan-2018]), SUM([Feb-2018]), SUM([Mar-2018]),
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019])
FROM #TEMPDAILYREPORTCOUNT T
WHERE T.MasterClientId NOT IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1) AND PropertyCategory IN ('External','C P P');
--
INSERT INTO #TDRClient
SELECT 'Total', 0, 3,
SUM([Apr-2014]), SUM([May-2014]), SUM([Jun-2014]), SUM([Jul-2014]), SUM([Aug-2014]), SUM([Sep-2014]), SUM([Oct-2014]), SUM([Nov-2014]), SUM([Dec-2014]), 
SUM([Jan-2015]), SUM([Feb-2015]), SUM([Mar-2015]),
SUM([Apr-2015]), SUM([May-2015]), SUM([Jun-2015]), SUM([Jul-2015]), SUM([Aug-2015]), SUM([Sep-2015]), SUM([Oct-2015]), SUM([Nov-2015]), SUM([Dec-2015]), 
SUM([Jan-2016]), SUM([Feb-2016]), SUM([Mar-2016]), 
SUM([Apr-2016]), SUM([May-2016]), SUM([Jun-2016]), SUM([Jul-2016]), SUM([Aug-2016]), SUM([Sep-2016]), SUM([Oct-2016]), SUM([Nov-2016]), SUM([Dec-2016]), 
SUM([Jan-2017]), SUM([Feb-2017]), SUM([Mar-2017]), 
SUM([Apr-2017]), SUM([May-2017]), SUM([Jun-2017]), SUM([Jul-2017]), SUM([Aug-2017]), SUM([Sep-2017]), SUM([Oct-2017]), SUM([Nov-2017]), SUM([Dec-2017]), 
SUM([Jan-2018]), SUM([Feb-2018]), SUM([Mar-2018]),
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019])
FROM #TDRClient;

-- TABLE 3 & 4

/*
SELECT 'Top 20 Clients - Room Nights                                                                                                       Value in No"s' AS Title;
SELECT MasterClientName AS TopClients,
[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017], 
[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018]  
FROM #TDRClient T;
*/

-- property category room nights

CREATE TABLE #TDRCatgy(PropertyCategory nvarchar(100), Flg INT, 
[Apr-2014] INT, [May-2014] INT, [Jun-2014] INT, [Jul-2014] INT, [Aug-2014] INT, [Sep-2014] INT, [Oct-2014] INT, [Nov-2014] INT, [Dec-2014] INT, 
[Jan-2015] INT, [Feb-2015] INT, [Mar-2015] INT,
[Apr-2015] INT, [May-2015] INT, [Jun-2015] INT, [Jul-2015] INT, [Aug-2015] INT, [Sep-2015] INT, [Oct-2015] INT, [Nov-2015] INT, [Dec-2015] INT, 
[Jan-2016] INT, [Feb-2016] INT, [Mar-2016] INT, 
[Apr-2016] INT, [May-2016] INT, [Jun-2016] INT, [Jul-2016] INT, [Aug-2016] INT, [Sep-2016] INT, [Oct-2016] INT, [Nov-2016] INT, [Dec-2016] INT, 
[Jan-2017] INT, [Feb-2017] INT, [Mar-2017] INT, 
[Apr-2017] INT, [May-2017] INT, [Jun-2017] INT, [Jul-2017] INT, [Aug-2017] INT, [Sep-2017] INT, [Oct-2017] INT, [Nov-2017] INT, [Dec-2017] INT,
[Jan-2018] INT, [Feb-2018] INT, [Mar-2018] INT,
[Apr-2018] INT, [May-2018] INT, [Jun-2018] INT, [Jul-2018] INT, [Aug-2018] INT, [Sep-2018] INT, [Oct-2018] INT, [Nov-2018] INT, [Dec-2018] INT,
[Jan-2019] INT, [Feb-2019] INT, [Mar-2019] INT);
--
INSERT INTO #TDRCatgy
SELECT PropertyCategory, 1,
SUM([Apr-2014]), SUM([May-2014]), SUM([Jun-2014]), SUM([Jul-2014]), SUM([Aug-2014]), SUM([Sep-2014]), SUM([Oct-2014]), SUM([Nov-2014]), SUM([Dec-2014]), 
SUM([Jan-2015]), SUM([Feb-2015]), SUM([Mar-2015]),
SUM([Apr-2015]), SUM([May-2015]), SUM([Jun-2015]), SUM([Jul-2015]), SUM([Aug-2015]), SUM([Sep-2015]), SUM([Oct-2015]), SUM([Nov-2015]), SUM([Dec-2015]), 
SUM([Jan-2016]), SUM([Feb-2016]), SUM([Mar-2016]), 
SUM([Apr-2016]), SUM([May-2016]), SUM([Jun-2016]), SUM([Jul-2016]), SUM([Aug-2016]), SUM([Sep-2016]), SUM([Oct-2016]), SUM([Nov-2016]), SUM([Dec-2016]), 
SUM([Jan-2017]), SUM([Feb-2017]), SUM([Mar-2017]), 
SUM([Apr-2017]), SUM([May-2017]), SUM([Jun-2017]), SUM([Jul-2017]), SUM([Aug-2017]), SUM([Sep-2017]), SUM([Oct-2017]), SUM([Nov-2017]), SUM([Dec-2017]), 
SUM([Jan-2018]), SUM([Feb-2018]), SUM([Mar-2018]),
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019]) 
FROM #TEMPDAILYREPORTCOUNT
WHERE PropertyCategory NOT IN ('Dedicated')
GROUP BY PropertyCategory
ORDER BY PropertyCategory;
--
INSERT INTO #TDRCatgy
SELECT 'Total', 2,
SUM([Apr-2014]), SUM([May-2014]), SUM([Jun-2014]), SUM([Jul-2014]), SUM([Aug-2014]), SUM([Sep-2014]), SUM([Oct-2014]), SUM([Nov-2014]), SUM([Dec-2014]), 
SUM([Jan-2015]), SUM([Feb-2015]), SUM([Mar-2015]),
SUM([Apr-2015]), SUM([May-2015]), SUM([Jun-2015]), SUM([Jul-2015]), SUM([Aug-2015]), SUM([Sep-2015]), SUM([Oct-2015]), SUM([Nov-2015]), SUM([Dec-2015]), 
SUM([Jan-2016]), SUM([Feb-2016]), SUM([Mar-2016]), 
SUM([Apr-2016]), SUM([May-2016]), SUM([Jun-2016]), SUM([Jul-2016]), SUM([Aug-2016]), SUM([Sep-2016]), SUM([Oct-2016]), SUM([Nov-2016]), SUM([Dec-2016]), 
SUM([Jan-2017]), SUM([Feb-2017]), SUM([Mar-2017]), 
SUM([Apr-2017]), SUM([May-2017]), SUM([Jun-2017]), SUM([Jul-2017]), SUM([Aug-2017]), SUM([Sep-2017]), SUM([Oct-2017]), SUM([Nov-2017]), SUM([Dec-2017]), 
SUM([Jan-2018]), SUM([Feb-2018]), SUM([Mar-2018]),
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019])
FROM #TDRCatgy;

-- TABLE 5 & 6

/*
SELECT 'Room Nights by Property Category                                                                                                  Value in Nos' AS Title;
SELECT PropertyCategory,
[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017], 
[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018]  
FROM #TDRCatgy;
*/

-- MARKUP

create table #dsadasd1(PropertyCategory nvarchar(100),cnt int,MonthofBooking nvarchar(100),Tariff DECIMAL(27,2),MarkUp DECIMAL(27,2),MasterClientId BIGINT);
insert into #dsadasd1(PropertyCategory,cnt,MonthofBooking,Tariff,MarkUp,MasterClientId)
select PropertyCategory,COUNT(CalendarDate),asasd,SUM(Tariff),SUM(MarkUp),MasterClientId from #TEMP2
WHERE  PropertyCategory IN ('External','C P P')
group by PropertyCategory,asasd,MasterClientId;
--
SELECT   PropertyCategory,MasterClientId,
         [Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
		 [Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
		 [Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
		 [Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
		 [Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019]
INTO #output1
FROM #dsadasd1
PIVOT
(
       SUM(MarkUp)
       FOR MonthofBooking IN 
	   ([Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
		 [Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
		 [Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
		 [Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
		 [Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019])
) AS P1;
--
CREATE TABLE #TEMPMARKUP(PropertyCategory NVARCHAR(100),MasterClientId BIGINT,
[Apr-2014] INT, [May-2014] INT, [Jun-2014] INT, [Jul-2014] INT, [Aug-2014] INT, [Sep-2014] INT, [Oct-2014] INT, [Nov-2014] INT, [Dec-2014] INT, 
[Jan-2015] INT, [Feb-2015] INT, [Mar-2015] INT,
[Apr-2015] INT, [May-2015] INT, [Jun-2015] INT, [Jul-2015] INT, [Aug-2015] INT, [Sep-2015] INT, [Oct-2015] INT, [Nov-2015] INT, [Dec-2015] INT, 
[Jan-2016] INT, [Feb-2016] INT, [Mar-2016] INT, 
[Apr-2016] INT, [May-2016] INT, [Jun-2016] INT, [Jul-2016] INT, [Aug-2016] INT, [Sep-2016] INT, [Oct-2016] INT, [Nov-2016] INT, [Dec-2016] INT, 
[Jan-2017] INT, [Feb-2017] INT, [Mar-2017] INT, 
[Apr-2017] INT, [May-2017] INT, [Jun-2017] INT, [Jul-2017] INT, [Aug-2017] INT, [Sep-2017] INT, [Oct-2017] INT, [Nov-2017] INT, [Dec-2017] INT,
[Jan-2018] INT, [Feb-2018] INT, [Mar-2018] INT,
[Apr-2018] INT, [May-2018] INT, [Jun-2018] INT, [Jul-2018] INT, [Aug-2018] INT, [Sep-2018] INT, [Oct-2018] INT, [Nov-2018] INT, [Dec-2018] INT,
[Jan-2019] INT, [Feb-2019] INT, [Mar-2019] INT);
--
INSERT INTO #TEMPMARKUP
select PropertyCategory,MasterClientId,
ISNULL([Apr-2014],0), ISNULL([May-2014],0), ISNULL([Jun-2014],0), ISNULL([Jul-2014],0), ISNULL([Aug-2014],0), ISNULL([Sep-2014],0), ISNULL([Oct-2014],0), 
ISNULL([Nov-2014],0), ISNULL([Dec-2014],0), ISNULL([Jan-2015],0), ISNULL([Feb-2015],0), ISNULL([Mar-2015],0), 
ISNULL([Apr-2015],0), ISNULL([May-2015],0), ISNULL([Jun-2015],0), ISNULL([Jul-2015],0), ISNULL([Aug-2015],0), ISNULL([Sep-2015],0), ISNULL([Oct-2015],0), 
ISNULL([Nov-2015],0), ISNULL([Dec-2015],0), ISNULL([Jan-2016],0), ISNULL([Feb-2016],0), ISNULL([Mar-2016],0), 
ISNULL([Apr-2016],0), ISNULL([May-2016],0), ISNULL([Jun-2016],0), ISNULL([Jul-2016],0), ISNULL([Aug-2016],0), ISNULL([Sep-2016],0), ISNULL([Oct-2016],0), 
ISNULL([Nov-2016],0), ISNULL([Dec-2016],0), ISNULL([Jan-2017],0), ISNULL([Feb-2017],0), ISNULL([Mar-2017],0), 
ISNULL([Apr-2017],0), ISNULL([May-2017],0), ISNULL([Jun-2017],0), ISNULL([Jul-2017],0), ISNULL([Aug-2017],0), ISNULL([Sep-2017],0), ISNULL([Oct-2017],0), 
ISNULL([Nov-2017],0), ISNULL([Dec-2017],0), ISNULL([Jan-2018],0), ISNULL([Feb-2018],0), ISNULL([Mar-2018],0),
ISNULL([Apr-2018],0), ISNULL([May-2018],0), ISNULL([Jun-2018],0), ISNULL([Jul-2018],0), ISNULL([Aug-2018],0), ISNULL([Sep-2018],0), ISNULL([Oct-2018],0), 
ISNULL([Nov-2018],0), ISNULL([Dec-2018],0), ISNULL([Jan-2019],0), ISNULL([Feb-2019],0), ISNULL([Mar-2019],0)  from #output1;

-- MARGIN FOR EXP & CPP

CREATE TABLE #TDRMARKUP_Category(PropertyCategory NVARCHAR(100),
[Apr-2014] INT, [May-2014] INT, [Jun-2014] INT, [Jul-2014] INT, [Aug-2014] INT, [Sep-2014] INT, [Oct-2014] INT, [Nov-2014] INT, [Dec-2014] INT, 
[Jan-2015] INT, [Feb-2015] INT, [Mar-2015] INT,
[Apr-2015] INT, [May-2015] INT, [Jun-2015] INT, [Jul-2015] INT, [Aug-2015] INT, [Sep-2015] INT, [Oct-2015] INT, [Nov-2015] INT, [Dec-2015] INT, 
[Jan-2016] INT, [Feb-2016] INT, [Mar-2016] INT, 
[Apr-2016] INT, [May-2016] INT, [Jun-2016] INT, [Jul-2016] INT, [Aug-2016] INT, [Sep-2016] INT, [Oct-2016] INT, [Nov-2016] INT, [Dec-2016] INT, 
[Jan-2017] INT, [Feb-2017] INT, [Mar-2017] INT, 
[Apr-2017] INT, [May-2017] INT, [Jun-2017] INT, [Jul-2017] INT, [Aug-2017] INT, [Sep-2017] INT, [Oct-2017] INT, [Nov-2017] INT, [Dec-2017] INT,
[Jan-2018] INT, [Feb-2018] INT, [Mar-2018] INT,
[Apr-2018] INT, [May-2018] INT, [Jun-2018] INT, [Jul-2018] INT, [Aug-2018] INT, [Sep-2018] INT, [Oct-2018] INT, [Nov-2018] INT, [Dec-2018] INT,
[Jan-2019] INT, [Feb-2019] INT, [Mar-2019] INT);
--
INSERT INTO #TDRMARKUP_Category
SELECT PropertyCategory,
SUM([Apr-2014]), SUM([May-2014]), SUM([Jun-2014]), SUM([Jul-2014]), SUM([Aug-2014]), SUM([Sep-2014]), SUM([Oct-2014]), SUM([Nov-2014]), SUM([Dec-2014]), 
SUM([Jan-2015]), SUM([Feb-2015]), SUM([Mar-2015]),
SUM([Apr-2015]), SUM([May-2015]), SUM([Jun-2015]), SUM([Jul-2015]), SUM([Aug-2015]), SUM([Sep-2015]), SUM([Oct-2015]), SUM([Nov-2015]), SUM([Dec-2015]), 
SUM([Jan-2016]), SUM([Feb-2016]), SUM([Mar-2016]), 
SUM([Apr-2016]), SUM([May-2016]), SUM([Jun-2016]), SUM([Jul-2016]), SUM([Aug-2016]), SUM([Sep-2016]), SUM([Oct-2016]), SUM([Nov-2016]), SUM([Dec-2016]), 
SUM([Jan-2017]), SUM([Feb-2017]), SUM([Mar-2017]), 
SUM([Apr-2017]), SUM([May-2017]), SUM([Jun-2017]), SUM([Jul-2017]), SUM([Aug-2017]), SUM([Sep-2017]), SUM([Oct-2017]), SUM([Nov-2017]), SUM([Dec-2017]), 
SUM([Jan-2018]), SUM([Feb-2018]), SUM([Mar-2018]),
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019]) 
FROM #TEMPMARKUP
GROUP BY PropertyCategory
ORDER BY PropertyCategory;
--
CREATE TABLE #TDRMARKUP_Category_New(PropertyCategory NVARCHAR(100), Flg INT,
[Apr-2014] DECIMAL(27,2), [May-2014] DECIMAL(27,2), [Jun-2014] DECIMAL(27,2), [Jul-2014] DECIMAL(27,2), [Aug-2014] DECIMAL(27,2), [Sep-2014] DECIMAL(27,2), 
[Oct-2014] DECIMAL(27,2), [Nov-2014] DECIMAL(27,2), [Dec-2014] DECIMAL(27,2), [Jan-2015] DECIMAL(27,2), [Feb-2015] DECIMAL(27,2), [Mar-2015] DECIMAL(27,2),
[Apr-2015] DECIMAL(27,2), [May-2015] DECIMAL(27,2), [Jun-2015] DECIMAL(27,2), [Jul-2015] DECIMAL(27,2), [Aug-2015] DECIMAL(27,2), [Sep-2015] DECIMAL(27,2), 
[Oct-2015] DECIMAL(27,2), [Nov-2015] DECIMAL(27,2), [Dec-2015] DECIMAL(27,2), [Jan-2016] DECIMAL(27,2), [Feb-2016] DECIMAL(27,2), [Mar-2016] DECIMAL(27,2), 
[Apr-2016] DECIMAL(27,2), [May-2016] DECIMAL(27,2), [Jun-2016] DECIMAL(27,2), [Jul-2016] DECIMAL(27,2), [Aug-2016] DECIMAL(27,2), [Sep-2016] DECIMAL(27,2), 
[Oct-2016] DECIMAL(27,2), [Nov-2016] DECIMAL(27,2), [Dec-2016] DECIMAL(27,2), [Jan-2017] DECIMAL(27,2), [Feb-2017] DECIMAL(27,2), [Mar-2017] DECIMAL(27,2), 
[Apr-2017] DECIMAL(27,2), [May-2017] DECIMAL(27,2), [Jun-2017] DECIMAL(27,2), [Jul-2017] DECIMAL(27,2), [Aug-2017] DECIMAL(27,2), [Sep-2017] DECIMAL(27,2), 
[Oct-2017] DECIMAL(27,2), [Nov-2017] DECIMAL(27,2), [Dec-2017] DECIMAL(27,2), [Jan-2018] DECIMAL(27,2), [Feb-2018] DECIMAL(27,2), [Mar-2018] DECIMAL(27,2),
[Apr-2018] DECIMAL(27,2), [May-2018] DECIMAL(27,2), [Jun-2018] DECIMAL(27,2), [Jul-2018] DECIMAL(27,2), [Aug-2018] DECIMAL(27,2), [Sep-2018] DECIMAL(27,2), 
[Oct-2018] DECIMAL(27,2), [Nov-2018] DECIMAL(27,2), [Dec-2018] DECIMAL(27,2), [Jan-2019] DECIMAL(27,2), [Feb-2019] DECIMAL(27,2), [Mar-2019] DECIMAL(27,2));
--
INSERT INTO #TDRMARKUP_Category_New
SELECT PropertyCategory, 1,
ROUND([Apr-2014] * 0.00001, 2), ROUND([May-2014] * 0.00001, 2), ROUND([Jun-2014] * 0.00001, 2), ROUND([Jul-2014] * 0.00001, 2), ROUND([Aug-2014] * 0.00001, 2),
ROUND([Sep-2014] * 0.00001, 2), ROUND([Oct-2014] * 0.00001, 2), ROUND([Nov-2014] * 0.00001, 2), ROUND([Dec-2014] * 0.00001, 2), ROUND([Jan-2015] * 0.00001, 2),
ROUND([Feb-2015] * 0.00001, 2), ROUND([Mar-2015] * 0.00001, 2),
ROUND([Apr-2015] * 0.00001, 2), ROUND([May-2015] * 0.00001, 2), ROUND([Jun-2015] * 0.00001, 2), ROUND([Jul-2015] * 0.00001, 2), ROUND([Aug-2015] * 0.00001, 2),
ROUND([Sep-2015] * 0.00001, 2), ROUND([Oct-2015] * 0.00001, 2), ROUND([Nov-2015] * 0.00001, 2), ROUND([Dec-2015] * 0.00001, 2), ROUND([Jan-2016] * 0.00001, 2),
ROUND([Feb-2016] * 0.00001, 2), ROUND([Mar-2016] * 0.00001, 2),
ROUND([Apr-2016] * 0.00001, 2), ROUND([May-2016] * 0.00001, 2), ROUND([Jun-2016] * 0.00001, 2), ROUND([Jul-2016] * 0.00001, 2), ROUND([Aug-2016] * 0.00001, 2),
ROUND([Sep-2016] * 0.00001, 2), ROUND([Oct-2016] * 0.00001, 2), ROUND([Nov-2016] * 0.00001, 2), ROUND([Dec-2016] * 0.00001, 2), ROUND([Jan-2017] * 0.00001, 2),
ROUND([Feb-2017] * 0.00001, 2), ROUND([Mar-2017] * 0.00001, 2),
ROUND([Apr-2017] * 0.00001, 2), ROUND([May-2017] * 0.00001, 2), ROUND([Jun-2017] * 0.00001, 2), ROUND([Jul-2017] * 0.00001, 2), ROUND([Aug-2017] * 0.00001, 2),
ROUND([Sep-2017] * 0.00001, 2), ROUND([Oct-2017] * 0.00001, 2), ROUND([Nov-2017] * 0.00001, 2), ROUND([Dec-2017] * 0.00001, 2), ROUND([Jan-2018] * 0.00001, 2),
ROUND([Feb-2018] * 0.00001, 2), ROUND([Mar-2018] * 0.00001, 2),
ROUND([Apr-2018] * 0.00001, 2), ROUND([May-2018] * 0.00001, 2), ROUND([Jun-2018] * 0.00001, 2), ROUND([Jul-2018] * 0.00001, 2), ROUND([Aug-2018] * 0.00001, 2),
ROUND([Sep-2018] * 0.00001, 2), ROUND([Oct-2018] * 0.00001, 2), ROUND([Nov-2018] * 0.00001, 2), ROUND([Dec-2018] * 0.00001, 2), ROUND([Jan-2019] * 0.00001, 2),
ROUND([Feb-2019] * 0.00001, 2), ROUND([Mar-2019] * 0.00001, 2)
FROM #TDRMARKUP_Category;
--
INSERT INTO #TDRMARKUP_Category_New
SELECT 'Total', 2,
SUM([Apr-2014]), SUM([May-2014]), SUM([Jun-2014]), SUM([Jul-2014]), SUM([Aug-2014]), SUM([Sep-2014]), SUM([Oct-2014]), SUM([Nov-2014]), SUM([Dec-2014]), 
SUM([Jan-2015]), SUM([Feb-2015]), SUM([Mar-2015]),
SUM([Apr-2015]), SUM([May-2015]), SUM([Jun-2015]), SUM([Jul-2015]), SUM([Aug-2015]), SUM([Sep-2015]), SUM([Oct-2015]), SUM([Nov-2015]), SUM([Dec-2015]), 
SUM([Jan-2016]), SUM([Feb-2016]), SUM([Mar-2016]), 
SUM([Apr-2016]), SUM([May-2016]), SUM([Jun-2016]), SUM([Jul-2016]), SUM([Aug-2016]), SUM([Sep-2016]), SUM([Oct-2016]), SUM([Nov-2016]), SUM([Dec-2016]), 
SUM([Jan-2017]), SUM([Feb-2017]), SUM([Mar-2017]), 
SUM([Apr-2017]), SUM([May-2017]), SUM([Jun-2017]), SUM([Jul-2017]), SUM([Aug-2017]), SUM([Sep-2017]), SUM([Oct-2017]), SUM([Nov-2017]), SUM([Dec-2017]), 
SUM([Jan-2018]), SUM([Feb-2018]), SUM([Mar-2018]),
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019])
FROM #TDRMARKUP_Category_New;

-- TABLE 7 & 8

/*
SELECT 'Margin from External Properties ( In Lacs )                                                                                       Value in Rs. ( Lacs)' AS Title;
SELECT PropertyCategory,
[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017], 
[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018] 
FROM #TDRMARKUP_Category_New;
*/

-- MARGIN FOR EXP & CPP - CLIENT WISE

CREATE TABLE #TDRMARKUP(MasterClientName NVARCHAR(100), MasterClientId BIGINT, Flg INT,
[Apr-2014] INT, [May-2014] INT, [Jun-2014] INT, [Jul-2014] INT, [Aug-2014] INT, [Sep-2014] INT, [Oct-2014] INT, [Nov-2014] INT, [Dec-2014] INT, 
[Jan-2015] INT, [Feb-2015] INT, [Mar-2015] INT,
[Apr-2015] INT, [May-2015] INT, [Jun-2015] INT, [Jul-2015] INT, [Aug-2015] INT, [Sep-2015] INT, [Oct-2015] INT, [Nov-2015] INT, [Dec-2015] INT, 
[Jan-2016] INT, [Feb-2016] INT, [Mar-2016] INT, 
[Apr-2016] INT, [May-2016] INT, [Jun-2016] INT, [Jul-2016] INT, [Aug-2016] INT, [Sep-2016] INT, [Oct-2016] INT, [Nov-2016] INT, [Dec-2016] INT, 
[Jan-2017] INT, [Feb-2017] INT, [Mar-2017] INT, 
[Apr-2017] INT, [May-2017] INT, [Jun-2017] INT, [Jul-2017] INT, [Aug-2017] INT, [Sep-2017] INT, [Oct-2017] INT, [Nov-2017] INT, [Dec-2017] INT,
[Jan-2018] INT, [Feb-2018] INT, [Mar-2018] INT,
[Apr-2018] INT, [May-2018] INT, [Jun-2018] INT, [Jul-2018] INT, [Aug-2018] INT, [Sep-2018] INT, [Oct-2018] INT, [Nov-2018] INT, [Dec-2018] INT,
[Jan-2019] INT, [Feb-2019] INT, [Mar-2019] INT);
--
INSERT INTO #TDRMARKUP
SELECT C.ClientName, T.MasterClientId, 1,
SUM([Apr-2014]), SUM([May-2014]), SUM([Jun-2014]), SUM([Jul-2014]), SUM([Aug-2014]), SUM([Sep-2014]), SUM([Oct-2014]), SUM([Nov-2014]), SUM([Dec-2014]), 
SUM([Jan-2015]), SUM([Feb-2015]), SUM([Mar-2015]),
SUM([Apr-2015]), SUM([May-2015]), SUM([Jun-2015]), SUM([Jul-2015]), SUM([Aug-2015]), SUM([Sep-2015]), SUM([Oct-2015]), SUM([Nov-2015]), SUM([Dec-2015]), 
SUM([Jan-2016]), SUM([Feb-2016]), SUM([Mar-2016]), 
SUM([Apr-2016]), SUM([May-2016]), SUM([Jun-2016]), SUM([Jul-2016]), SUM([Aug-2016]), SUM([Sep-2016]), SUM([Oct-2016]), SUM([Nov-2016]), SUM([Dec-2016]), 
SUM([Jan-2017]), SUM([Feb-2017]), SUM([Mar-2017]), 
SUM([Apr-2017]), SUM([May-2017]), SUM([Jun-2017]), SUM([Jul-2017]), SUM([Aug-2017]), SUM([Sep-2017]), SUM([Oct-2017]), SUM([Nov-2017]), SUM([Dec-2017]), 
SUM([Jan-2018]), SUM([Feb-2018]), SUM([Mar-2018]),
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019]) 
FROM #TEMPMARKUP T
LEFT OUTER JOIN WRBHBMasterClientManagement C WITH(NOLOCK)ON C.Id = T.MasterClientId
WHERE T.MasterClientId IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1)
GROUP BY C.ClientName, T.MasterClientId;
--
INSERT INTO #TDRMARKUP
SELECT 'Other Clients', 0, 2,
SUM([Apr-2014]), SUM([May-2014]), SUM([Jun-2014]), SUM([Jul-2014]), SUM([Aug-2014]), SUM([Sep-2014]), SUM([Oct-2014]), SUM([Nov-2014]), SUM([Dec-2014]), 
SUM([Jan-2015]), SUM([Feb-2015]), SUM([Mar-2015]),
SUM([Apr-2015]), SUM([May-2015]), SUM([Jun-2015]), SUM([Jul-2015]), SUM([Aug-2015]), SUM([Sep-2015]), SUM([Oct-2015]), SUM([Nov-2015]), SUM([Dec-2015]), 
SUM([Jan-2016]), SUM([Feb-2016]), SUM([Mar-2016]), 
SUM([Apr-2016]), SUM([May-2016]), SUM([Jun-2016]), SUM([Jul-2016]), SUM([Aug-2016]), SUM([Sep-2016]), SUM([Oct-2016]), SUM([Nov-2016]), SUM([Dec-2016]), 
SUM([Jan-2017]), SUM([Feb-2017]), SUM([Mar-2017]), 
SUM([Apr-2017]), SUM([May-2017]), SUM([Jun-2017]), SUM([Jul-2017]), SUM([Aug-2017]), SUM([Sep-2017]), SUM([Oct-2017]), SUM([Nov-2017]), SUM([Dec-2017]), 
SUM([Jan-2018]), SUM([Feb-2018]), SUM([Mar-2018]),
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019]) 
FROM #TEMPMARKUP T
WHERE T.MasterClientId NOT IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1);
--
CREATE TABLE #TDRMARKUP_New(MasterClientName NVARCHAR(100), MasterClientId BIGINT, Flg INT,
[Apr-2014] DECIMAL(27,2), [May-2014] DECIMAL(27,2), [Jun-2014] DECIMAL(27,2), [Jul-2014] DECIMAL(27,2), [Aug-2014] DECIMAL(27,2), [Sep-2014] DECIMAL(27,2), 
[Oct-2014] DECIMAL(27,2), [Nov-2014] DECIMAL(27,2), [Dec-2014] DECIMAL(27,2), [Jan-2015] DECIMAL(27,2), [Feb-2015] DECIMAL(27,2), [Mar-2015] DECIMAL(27,2),
[Apr-2015] DECIMAL(27,2), [May-2015] DECIMAL(27,2), [Jun-2015] DECIMAL(27,2), [Jul-2015] DECIMAL(27,2), [Aug-2015] DECIMAL(27,2), [Sep-2015] DECIMAL(27,2), 
[Oct-2015] DECIMAL(27,2), [Nov-2015] DECIMAL(27,2), [Dec-2015] DECIMAL(27,2), [Jan-2016] DECIMAL(27,2), [Feb-2016] DECIMAL(27,2), [Mar-2016] DECIMAL(27,2), 
[Apr-2016] DECIMAL(27,2), [May-2016] DECIMAL(27,2), [Jun-2016] DECIMAL(27,2), [Jul-2016] DECIMAL(27,2), [Aug-2016] DECIMAL(27,2), [Sep-2016] DECIMAL(27,2), 
[Oct-2016] DECIMAL(27,2), [Nov-2016] DECIMAL(27,2), [Dec-2016] DECIMAL(27,2), [Jan-2017] DECIMAL(27,2), [Feb-2017] DECIMAL(27,2), [Mar-2017] DECIMAL(27,2), 
[Apr-2017] DECIMAL(27,2), [May-2017] DECIMAL(27,2), [Jun-2017] DECIMAL(27,2), [Jul-2017] DECIMAL(27,2), [Aug-2017] DECIMAL(27,2), [Sep-2017] DECIMAL(27,2), 
[Oct-2017] DECIMAL(27,2), [Nov-2017] DECIMAL(27,2), [Dec-2017] DECIMAL(27,2), [Jan-2018] DECIMAL(27,2), [Feb-2018] DECIMAL(27,2), [Mar-2018] DECIMAL(27,2),
[Apr-2018] DECIMAL(27,2), [May-2018] DECIMAL(27,2), [Jun-2018] DECIMAL(27,2), [Jul-2018] DECIMAL(27,2), [Aug-2018] DECIMAL(27,2), [Sep-2018] DECIMAL(27,2), 
[Oct-2018] DECIMAL(27,2), [Nov-2018] DECIMAL(27,2), [Dec-2018] DECIMAL(27,2), [Jan-2019] DECIMAL(27,2), [Feb-2019] DECIMAL(27,2), [Mar-2019] DECIMAL(27,2));
--
INSERT INTO #TDRMARKUP_New
SELECT MasterClientName,MasterClientId, Flg,
ROUND([Apr-2014] * 0.00001, 2), ROUND([May-2014] * 0.00001, 2), ROUND([Jun-2014] * 0.00001, 2), ROUND([Jul-2014] * 0.00001, 2), ROUND([Aug-2014] * 0.00001, 2),
ROUND([Sep-2014] * 0.00001, 2), ROUND([Oct-2014] * 0.00001, 2), ROUND([Nov-2014] * 0.00001, 2), ROUND([Dec-2014] * 0.00001, 2), ROUND([Jan-2015] * 0.00001, 2),
ROUND([Feb-2015] * 0.00001, 2), ROUND([Mar-2015] * 0.00001, 2),
ROUND([Apr-2015] * 0.00001, 2), ROUND([May-2015] * 0.00001, 2), ROUND([Jun-2015] * 0.00001, 2), ROUND([Jul-2015] * 0.00001, 2), ROUND([Aug-2015] * 0.00001, 2),
ROUND([Sep-2015] * 0.00001, 2), ROUND([Oct-2015] * 0.00001, 2), ROUND([Nov-2015] * 0.00001, 2), ROUND([Dec-2015] * 0.00001, 2), ROUND([Jan-2016] * 0.00001, 2),
ROUND([Feb-2016] * 0.00001, 2), ROUND([Mar-2016] * 0.00001, 2),
ROUND([Apr-2016] * 0.00001, 2), ROUND([May-2016] * 0.00001, 2), ROUND([Jun-2016] * 0.00001, 2), ROUND([Jul-2016] * 0.00001, 2), ROUND([Aug-2016] * 0.00001, 2),
ROUND([Sep-2016] * 0.00001, 2), ROUND([Oct-2016] * 0.00001, 2), ROUND([Nov-2016] * 0.00001, 2), ROUND([Dec-2016] * 0.00001, 2), ROUND([Jan-2017] * 0.00001, 2),
ROUND([Feb-2017] * 0.00001, 2), ROUND([Mar-2017] * 0.00001, 2),
ROUND([Apr-2017] * 0.00001, 2), ROUND([May-2017] * 0.00001, 2), ROUND([Jun-2017] * 0.00001, 2), ROUND([Jul-2017] * 0.00001, 2), ROUND([Aug-2017] * 0.00001, 2),
ROUND([Sep-2017] * 0.00001, 2), ROUND([Oct-2017] * 0.00001, 2), ROUND([Nov-2017] * 0.00001, 2), ROUND([Dec-2017] * 0.00001, 2), ROUND([Jan-2018] * 0.00001, 2),
ROUND([Feb-2018] * 0.00001, 2), ROUND([Mar-2018] * 0.00001, 2),
ROUND([Apr-2018] * 0.00001, 2), ROUND([May-2018] * 0.00001, 2), ROUND([Jun-2018] * 0.00001, 2), ROUND([Jul-2018] * 0.00001, 2), ROUND([Aug-2018] * 0.00001, 2),
ROUND([Sep-2018] * 0.00001, 2), ROUND([Oct-2018] * 0.00001, 2), ROUND([Nov-2018] * 0.00001, 2), ROUND([Dec-2018] * 0.00001, 2), ROUND([Jan-2019] * 0.00001, 2),
ROUND([Feb-2019] * 0.00001, 2), ROUND([Mar-2019] * 0.00001, 2)
FROM #TDRMARKUP;
--
INSERT INTO #TDRMARKUP_New
SELECT 'Total', 0, 3,
SUM([Apr-2014]), SUM([May-2014]), SUM([Jun-2014]), SUM([Jul-2014]), SUM([Aug-2014]), SUM([Sep-2014]), SUM([Oct-2014]), SUM([Nov-2014]), SUM([Dec-2014]), 
SUM([Jan-2015]), SUM([Feb-2015]), SUM([Mar-2015]),
SUM([Apr-2015]), SUM([May-2015]), SUM([Jun-2015]), SUM([Jul-2015]), SUM([Aug-2015]), SUM([Sep-2015]), SUM([Oct-2015]), SUM([Nov-2015]), SUM([Dec-2015]), 
SUM([Jan-2016]), SUM([Feb-2016]), SUM([Mar-2016]), 
SUM([Apr-2016]), SUM([May-2016]), SUM([Jun-2016]), SUM([Jul-2016]), SUM([Aug-2016]), SUM([Sep-2016]), SUM([Oct-2016]), SUM([Nov-2016]), SUM([Dec-2016]), 
SUM([Jan-2017]), SUM([Feb-2017]), SUM([Mar-2017]), 
SUM([Apr-2017]), SUM([May-2017]), SUM([Jun-2017]), SUM([Jul-2017]), SUM([Aug-2017]), SUM([Sep-2017]), SUM([Oct-2017]), SUM([Nov-2017]), SUM([Dec-2017]), 
SUM([Jan-2018]), SUM([Feb-2018]), SUM([Mar-2018]),
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019]) 
FROM #TDRMARKUP_New;

-- TABLE 9 & 10

/*
SELECT 'Top Clients - External Margin Analysis ( In Lacs )                                                                               Value in Rs. ( Lacs)' AS Title;
SELECT MasterClientName,
[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017], 
[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018] 
FROM #TDRMARKUP_New;
*/

-- GTV WITH MARKUP

create table #dsadasd3(PropertyCategory nvarchar(100),MonthofBooking nvarchar(100),Tariff DECIMAL(27,2),MasterClientId BIGINT);
insert into #dsadasd3(PropertyCategory,MonthofBooking,Tariff,MasterClientId)
select PropertyCategory,asasd,SUM(Tariff),MasterClientId from #TEMP2
WHERE  PropertyCategory NOT IN ('G H','Dedicated') AND MarkUp != 0
group by PropertyCategory,asasd,MasterClientId;
--
SELECT   PropertyCategory,MasterClientId,
         [Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
		 [Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
		 [Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
		 [Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
		 [Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019]
INTO #output3
FROM #dsadasd3
PIVOT
(
       SUM(Tariff)
       FOR MonthofBooking IN 
	   ([Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
		 [Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
		 [Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
		 [Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
		 [Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019])
) AS P2;
--
CREATE TABLE #TEMPGTVwithMARKUP(PropertyCategory NVARCHAR(100),MasterClientId BIGINT,
[Apr-2014] INT, [May-2014] INT, [Jun-2014] INT, [Jul-2014] INT, [Aug-2014] INT, [Sep-2014] INT, [Oct-2014] INT, [Nov-2014] INT, [Dec-2014] INT, 
[Jan-2015] INT, [Feb-2015] INT, [Mar-2015] INT,
[Apr-2015] INT, [May-2015] INT, [Jun-2015] INT, [Jul-2015] INT, [Aug-2015] INT, [Sep-2015] INT, [Oct-2015] INT, [Nov-2015] INT, [Dec-2015] INT, 
[Jan-2016] INT, [Feb-2016] INT, [Mar-2016] INT, 
[Apr-2016] INT, [May-2016] INT, [Jun-2016] INT, [Jul-2016] INT, [Aug-2016] INT, [Sep-2016] INT, [Oct-2016] INT, [Nov-2016] INT, [Dec-2016] INT, 
[Jan-2017] INT, [Feb-2017] INT, [Mar-2017] INT, 
[Apr-2017] INT, [May-2017] INT, [Jun-2017] INT, [Jul-2017] INT, [Aug-2017] INT, [Sep-2017] INT, [Oct-2017] INT, [Nov-2017] INT, [Dec-2017] INT,
[Jan-2018] INT, [Feb-2018] INT, [Mar-2018] INT,
[Apr-2018] INT, [May-2018] INT, [Jun-2018] INT, [Jul-2018] INT, [Aug-2018] INT, [Sep-2018] INT, [Oct-2018] INT, [Nov-2018] INT, [Dec-2018] INT,
[Jan-2019] INT, [Feb-2019] INT, [Mar-2019] INT);
--
INSERT INTO #TEMPGTVwithMARKUP
SELECT PropertyCategory,MasterClientId,
ISNULL([Apr-2014],0), ISNULL([May-2014],0), ISNULL([Jun-2014],0), ISNULL([Jul-2014],0), ISNULL([Aug-2014],0), ISNULL([Sep-2014],0), ISNULL([Oct-2014],0), 
ISNULL([Nov-2014],0), ISNULL([Dec-2014],0), ISNULL([Jan-2015],0), ISNULL([Feb-2015],0), ISNULL([Mar-2015],0), 
ISNULL([Apr-2015],0), ISNULL([May-2015],0), ISNULL([Jun-2015],0), ISNULL([Jul-2015],0), ISNULL([Aug-2015],0), ISNULL([Sep-2015],0), ISNULL([Oct-2015],0), 
ISNULL([Nov-2015],0), ISNULL([Dec-2015],0), ISNULL([Jan-2016],0), ISNULL([Feb-2016],0), ISNULL([Mar-2016],0), 
ISNULL([Apr-2016],0), ISNULL([May-2016],0), ISNULL([Jun-2016],0), ISNULL([Jul-2016],0), ISNULL([Aug-2016],0), ISNULL([Sep-2016],0), ISNULL([Oct-2016],0), 
ISNULL([Nov-2016],0), ISNULL([Dec-2016],0), ISNULL([Jan-2017],0), ISNULL([Feb-2017],0), ISNULL([Mar-2017],0), 
ISNULL([Apr-2017],0), ISNULL([May-2017],0), ISNULL([Jun-2017],0), ISNULL([Jul-2017],0), ISNULL([Aug-2017],0), ISNULL([Sep-2017],0), ISNULL([Oct-2017],0), 
ISNULL([Nov-2017],0), ISNULL([Dec-2017],0), ISNULL([Jan-2018],0), ISNULL([Feb-2018],0), ISNULL([Mar-2018],0),
ISNULL([Apr-2018],0), ISNULL([May-2018],0), ISNULL([Jun-2018],0), ISNULL([Jul-2018],0), ISNULL([Aug-2018],0), ISNULL([Sep-2018],0), ISNULL([Oct-2018],0), 
ISNULL([Nov-2018],0), ISNULL([Dec-2018],0), ISNULL([Jan-2019],0), ISNULL([Feb-2019],0), ISNULL([Mar-2019],0)  FROM #output3;

-- PROPERTY CATEGORY WISE GTV

CREATE TABLE #GTVTOTAL(PropertyCategory NVARCHAR(100), MarkupFlg INT,
[Apr-2014] DECIMAL(27,2), [May-2014] DECIMAL(27,2), [Jun-2014] DECIMAL(27,2), [Jul-2014] DECIMAL(27,2), [Aug-2014] DECIMAL(27,2), [Sep-2014] DECIMAL(27,2), 
[Oct-2014] DECIMAL(27,2), [Nov-2014] DECIMAL(27,2), [Dec-2014] DECIMAL(27,2), [Jan-2015] DECIMAL(27,2), [Feb-2015] DECIMAL(27,2), [Mar-2015] DECIMAL(27,2),
[Apr-2015] DECIMAL(27,2), [May-2015] DECIMAL(27,2), [Jun-2015] DECIMAL(27,2), [Jul-2015] DECIMAL(27,2), [Aug-2015] DECIMAL(27,2), [Sep-2015] DECIMAL(27,2), 
[Oct-2015] DECIMAL(27,2), [Nov-2015] DECIMAL(27,2), [Dec-2015] DECIMAL(27,2), [Jan-2016] DECIMAL(27,2), [Feb-2016] DECIMAL(27,2), [Mar-2016] DECIMAL(27,2), 
[Apr-2016] DECIMAL(27,2), [May-2016] DECIMAL(27,2), [Jun-2016] DECIMAL(27,2), [Jul-2016] DECIMAL(27,2), [Aug-2016] DECIMAL(27,2), [Sep-2016] DECIMAL(27,2), 
[Oct-2016] DECIMAL(27,2), [Nov-2016] DECIMAL(27,2), [Dec-2016] DECIMAL(27,2), [Jan-2017] DECIMAL(27,2), [Feb-2017] DECIMAL(27,2), [Mar-2017] DECIMAL(27,2), 
[Apr-2017] DECIMAL(27,2), [May-2017] DECIMAL(27,2), [Jun-2017] DECIMAL(27,2), [Jul-2017] DECIMAL(27,2), [Aug-2017] DECIMAL(27,2), [Sep-2017] DECIMAL(27,2), 
[Oct-2017] DECIMAL(27,2), [Nov-2017] DECIMAL(27,2), [Dec-2017] DECIMAL(27,2), [Jan-2018] DECIMAL(27,2), [Feb-2018] DECIMAL(27,2), [Mar-2018] DECIMAL(27,2),
[Apr-2018] DECIMAL(27,2), [May-2018] DECIMAL(27,2), [Jun-2018] DECIMAL(27,2), [Jul-2018] DECIMAL(27,2), [Aug-2018] DECIMAL(27,2), [Sep-2018] DECIMAL(27,2), 
[Oct-2018] DECIMAL(27,2), [Nov-2018] DECIMAL(27,2), [Dec-2018] DECIMAL(27,2), [Jan-2019] DECIMAL(27,2), [Feb-2019] DECIMAL(27,2), [Mar-2019] DECIMAL(27,2));
--
INSERT INTO #GTVTOTAL
SELECT PropertyCategory, 1, 
ROUND(SUM([Apr-2014]) * 0.00001, 2), ROUND(SUM([May-2014]) * 0.00001, 2), ROUND(SUM([Jun-2014]) * 0.00001, 2), ROUND(SUM([Jul-2014]) * 0.00001, 2), 
ROUND(SUM([Aug-2014]) * 0.00001, 2), ROUND(SUM([Sep-2014]) * 0.00001, 2), ROUND(SUM([Oct-2014]) * 0.00001, 2), ROUND(SUM([Nov-2014]) * 0.00001, 2), 
ROUND(SUM([Dec-2014]) * 0.00001, 2), ROUND(SUM([Jan-2015]) * 0.00001, 2), ROUND(SUM([Feb-2015]) * 0.00001, 2), ROUND(SUM([Mar-2015]) * 0.00001, 2),

ROUND(SUM([Apr-2015]) * 0.00001, 2), ROUND(SUM([May-2015]) * 0.00001, 2), ROUND(SUM([Jun-2015]) * 0.00001, 2), ROUND(SUM([Jul-2015]) * 0.00001, 2), 
ROUND(SUM([Aug-2015]) * 0.00001, 2), ROUND(SUM([Sep-2015]) * 0.00001, 2), ROUND(SUM([Oct-2015]) * 0.00001, 2), ROUND(SUM([Nov-2015]) * 0.00001, 2), 
ROUND(SUM([Dec-2015]) * 0.00001, 2), ROUND(SUM([Jan-2016]) * 0.00001, 2), ROUND(SUM([Feb-2016]) * 0.00001, 2), ROUND(SUM([Mar-2016]) * 0.00001, 2),
 
ROUND(SUM([Apr-2016]) * 0.00001, 2), ROUND(SUM([May-2016]) * 0.00001, 2), ROUND(SUM([Jun-2016]) * 0.00001, 2), ROUND(SUM([Jul-2016]) * 0.00001, 2), 
ROUND(SUM([Aug-2016]) * 0.00001, 2), ROUND(SUM([Sep-2016]) * 0.00001, 2), ROUND(SUM([Oct-2016]) * 0.00001, 2), ROUND(SUM([Nov-2016]) * 0.00001, 2), 
ROUND(SUM([Dec-2016]) * 0.00001, 2), ROUND(SUM([Jan-2017]) * 0.00001, 2), ROUND(SUM([Feb-2017]) * 0.00001, 2), ROUND(SUM([Mar-2017]) * 0.00001, 2), 

ROUND(SUM([Apr-2017]) * 0.00001, 2), ROUND(SUM([May-2017]) * 0.00001, 2), ROUND(SUM([Jun-2017]) * 0.00001, 2), ROUND(SUM([Jul-2017]) * 0.00001, 2), 
ROUND(SUM([Aug-2017]) * 0.00001, 2), ROUND(SUM([Sep-2017]) * 0.00001, 2), ROUND(SUM([Oct-2017]) * 0.00001, 2), ROUND(SUM([Nov-2017]) * 0.00001, 2), 
ROUND(SUM([Dec-2017]) * 0.00001, 2), ROUND(SUM([Jan-2018]) * 0.00001, 2), ROUND(SUM([Feb-2018]) * 0.00001, 2), ROUND(SUM([Mar-2018]) * 0.00001, 2),

ROUND(SUM([Apr-2018]) * 0.00001, 2), ROUND(SUM([May-2018]) * 0.00001, 2), ROUND(SUM([Jun-2018]) * 0.00001, 2), ROUND(SUM([Jul-2018]) * 0.00001, 2), 
ROUND(SUM([Aug-2018]) * 0.00001, 2), ROUND(SUM([Sep-2018]) * 0.00001, 2), ROUND(SUM([Oct-2018]) * 0.00001, 2), ROUND(SUM([Nov-2018]) * 0.00001, 2), 
ROUND(SUM([Dec-2018]) * 0.00001, 2), ROUND(SUM([Jan-2019]) * 0.00001, 2), ROUND(SUM([Feb-2019]) * 0.00001, 2), ROUND(SUM([Mar-2019]) * 0.00001, 2)
FROM #TEMPGTVwithMARKUP
GROUP BY PropertyCategory
ORDER BY PropertyCategory;
--
INSERT INTO #GTVTOTAL
SELECT 'GTV with Margin Total', 2, 
SUM([Apr-2014]), SUM([May-2014]), SUM([Jun-2014]), SUM([Jul-2014]), SUM([Aug-2014]), SUM([Sep-2014]), SUM([Oct-2014]), SUM([Nov-2014]), SUM([Dec-2014]), 
SUM([Jan-2015]), SUM([Feb-2015]), SUM([Mar-2015]),
SUM([Apr-2015]), SUM([May-2015]), SUM([Jun-2015]), SUM([Jul-2015]), SUM([Aug-2015]), SUM([Sep-2015]), SUM([Oct-2015]), SUM([Nov-2015]), SUM([Dec-2015]), 
SUM([Jan-2016]), SUM([Feb-2016]), SUM([Mar-2016]), 
SUM([Apr-2016]), SUM([May-2016]), SUM([Jun-2016]), SUM([Jul-2016]), SUM([Aug-2016]), SUM([Sep-2016]), SUM([Oct-2016]), SUM([Nov-2016]), SUM([Dec-2016]), 
SUM([Jan-2017]), SUM([Feb-2017]), SUM([Mar-2017]), 
SUM([Apr-2017]), SUM([May-2017]), SUM([Jun-2017]), SUM([Jul-2017]), SUM([Aug-2017]), SUM([Sep-2017]), SUM([Oct-2017]), SUM([Nov-2017]), SUM([Dec-2017]), 
SUM([Jan-2018]), SUM([Feb-2018]), SUM([Mar-2018]),
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019])
FROM #GTVTOTAL;

-- GTV WITHOUT MARKUP

create table #dsadasd2(PropertyCategory nvarchar(100),MonthofBooking nvarchar(100),Tariff DECIMAL(27,2),MasterClientId BIGINT);
insert into #dsadasd2(PropertyCategory,MonthofBooking,Tariff,MasterClientId)
select PropertyCategory,asasd,SUM(Tariff),MasterClientId from #TEMP2
WHERE  PropertyCategory NOT IN ('G H','Dedicated') AND MarkUp = 0
group by PropertyCategory,asasd,MasterClientId;
--
SELECT   PropertyCategory,MasterClientId,
         [Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
		 [Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
		 [Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
		 [Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
		 [Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019]
INTO #output2
FROM #dsadasd2
PIVOT
(
       SUM(Tariff)
       FOR MonthofBooking IN 
	   ([Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
		 [Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
		 [Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
		 [Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
		 [Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019])
) AS P2;
--
CREATE TABLE #TEMPGTVwithoutMARKUP(PropertyCategory NVARCHAR(100),MasterClientId BIGINT,
[Apr-2014] INT, [May-2014] INT, [Jun-2014] INT, [Jul-2014] INT, [Aug-2014] INT, [Sep-2014] INT, [Oct-2014] INT, [Nov-2014] INT, [Dec-2014] INT, 
[Jan-2015] INT, [Feb-2015] INT, [Mar-2015] INT,
[Apr-2015] INT, [May-2015] INT, [Jun-2015] INT, [Jul-2015] INT, [Aug-2015] INT, [Sep-2015] INT, [Oct-2015] INT, [Nov-2015] INT, [Dec-2015] INT, 
[Jan-2016] INT, [Feb-2016] INT, [Mar-2016] INT, 
[Apr-2016] INT, [May-2016] INT, [Jun-2016] INT, [Jul-2016] INT, [Aug-2016] INT, [Sep-2016] INT, [Oct-2016] INT, [Nov-2016] INT, [Dec-2016] INT, 
[Jan-2017] INT, [Feb-2017] INT, [Mar-2017] INT, 
[Apr-2017] INT, [May-2017] INT, [Jun-2017] INT, [Jul-2017] INT, [Aug-2017] INT, [Sep-2017] INT, [Oct-2017] INT, [Nov-2017] INT, [Dec-2017] INT,
[Jan-2018] INT, [Feb-2018] INT, [Mar-2018] INT,
[Apr-2018] INT, [May-2018] INT, [Jun-2018] INT, [Jul-2018] INT, [Aug-2018] INT, [Sep-2018] INT, [Oct-2018] INT, [Nov-2018] INT, [Dec-2018] INT,
[Jan-2019] INT, [Feb-2019] INT, [Mar-2019] INT);
--
INSERT INTO #TEMPGTVwithoutMARKUP
select PropertyCategory,MasterClientId,
ISNULL([Apr-2014],0), ISNULL([May-2014],0), ISNULL([Jun-2014],0), ISNULL([Jul-2014],0), ISNULL([Aug-2014],0), ISNULL([Sep-2014],0), ISNULL([Oct-2014],0), 
ISNULL([Nov-2014],0), ISNULL([Dec-2014],0), ISNULL([Jan-2015],0), ISNULL([Feb-2015],0), ISNULL([Mar-2015],0), 
ISNULL([Apr-2015],0), ISNULL([May-2015],0), ISNULL([Jun-2015],0), ISNULL([Jul-2015],0), ISNULL([Aug-2015],0), ISNULL([Sep-2015],0), ISNULL([Oct-2015],0), 
ISNULL([Nov-2015],0), ISNULL([Dec-2015],0), ISNULL([Jan-2016],0), ISNULL([Feb-2016],0), ISNULL([Mar-2016],0), 
ISNULL([Apr-2016],0), ISNULL([May-2016],0), ISNULL([Jun-2016],0), ISNULL([Jul-2016],0), ISNULL([Aug-2016],0), ISNULL([Sep-2016],0), ISNULL([Oct-2016],0), 
ISNULL([Nov-2016],0), ISNULL([Dec-2016],0), ISNULL([Jan-2017],0), ISNULL([Feb-2017],0), ISNULL([Mar-2017],0), 
ISNULL([Apr-2017],0), ISNULL([May-2017],0), ISNULL([Jun-2017],0), ISNULL([Jul-2017],0), ISNULL([Aug-2017],0), ISNULL([Sep-2017],0), ISNULL([Oct-2017],0), 
ISNULL([Nov-2017],0), ISNULL([Dec-2017],0), ISNULL([Jan-2018],0), ISNULL([Feb-2018],0), ISNULL([Mar-2018],0),
ISNULL([Apr-2018],0), ISNULL([May-2018],0), ISNULL([Jun-2018],0), ISNULL([Jul-2018],0), ISNULL([Aug-2018],0), ISNULL([Sep-2018],0), ISNULL([Oct-2018],0), 
ISNULL([Nov-2018],0), ISNULL([Dec-2018],0), ISNULL([Jan-2019],0), ISNULL([Feb-2019],0), ISNULL([Mar-2019],0)  from #output2;
--
INSERT INTO #GTVTOTAL
SELECT PropertyCategory, 3, 
ROUND(SUM([Apr-2014]) * 0.00001, 2), ROUND(SUM([May-2014]) * 0.00001, 2), ROUND(SUM([Jun-2014]) * 0.00001, 2), ROUND(SUM([Jul-2014]) * 0.00001, 2), 
ROUND(SUM([Aug-2014]) * 0.00001, 2), ROUND(SUM([Sep-2014]) * 0.00001, 2), ROUND(SUM([Oct-2014]) * 0.00001, 2), ROUND(SUM([Nov-2014]) * 0.00001, 2), 
ROUND(SUM([Dec-2014]) * 0.00001, 2), ROUND(SUM([Jan-2015]) * 0.00001, 2), ROUND(SUM([Feb-2015]) * 0.00001, 2), ROUND(SUM([Mar-2015]) * 0.00001, 2),

ROUND(SUM([Apr-2015]) * 0.00001, 2), ROUND(SUM([May-2015]) * 0.00001, 2), ROUND(SUM([Jun-2015]) * 0.00001, 2), ROUND(SUM([Jul-2015]) * 0.00001, 2), 
ROUND(SUM([Aug-2015]) * 0.00001, 2), ROUND(SUM([Sep-2015]) * 0.00001, 2), ROUND(SUM([Oct-2015]) * 0.00001, 2), ROUND(SUM([Nov-2015]) * 0.00001, 2), 
ROUND(SUM([Dec-2015]) * 0.00001, 2), ROUND(SUM([Jan-2016]) * 0.00001, 2), ROUND(SUM([Feb-2016]) * 0.00001, 2), ROUND(SUM([Mar-2016]) * 0.00001, 2),
 
ROUND(SUM([Apr-2016]) * 0.00001, 2), ROUND(SUM([May-2016]) * 0.00001, 2), ROUND(SUM([Jun-2016]) * 0.00001, 2), ROUND(SUM([Jul-2016]) * 0.00001, 2), 
ROUND(SUM([Aug-2016]) * 0.00001, 2), ROUND(SUM([Sep-2016]) * 0.00001, 2), ROUND(SUM([Oct-2016]) * 0.00001, 2), ROUND(SUM([Nov-2016]) * 0.00001, 2), 
ROUND(SUM([Dec-2016]) * 0.00001, 2), ROUND(SUM([Jan-2017]) * 0.00001, 2), ROUND(SUM([Feb-2017]) * 0.00001, 2), ROUND(SUM([Mar-2017]) * 0.00001, 2), 

ROUND(SUM([Apr-2017]) * 0.00001, 2), ROUND(SUM([May-2017]) * 0.00001, 2), ROUND(SUM([Jun-2017]) * 0.00001, 2), ROUND(SUM([Jul-2017]) * 0.00001, 2), 
ROUND(SUM([Aug-2017]) * 0.00001, 2), ROUND(SUM([Sep-2017]) * 0.00001, 2), ROUND(SUM([Oct-2017]) * 0.00001, 2), ROUND(SUM([Nov-2017]) * 0.00001, 2), 
ROUND(SUM([Dec-2017]) * 0.00001, 2), ROUND(SUM([Jan-2018]) * 0.00001, 2), ROUND(SUM([Feb-2018]) * 0.00001, 2), ROUND(SUM([Mar-2018]) * 0.00001, 2),

ROUND(SUM([Apr-2018]) * 0.00001, 2), ROUND(SUM([May-2018]) * 0.00001, 2), ROUND(SUM([Jun-2018]) * 0.00001, 2), ROUND(SUM([Jul-2018]) * 0.00001, 2), 
ROUND(SUM([Aug-2018]) * 0.00001, 2), ROUND(SUM([Sep-2018]) * 0.00001, 2), ROUND(SUM([Oct-2018]) * 0.00001, 2), ROUND(SUM([Nov-2018]) * 0.00001, 2), 
ROUND(SUM([Dec-2018]) * 0.00001, 2), ROUND(SUM([Jan-2019]) * 0.00001, 2), ROUND(SUM([Feb-2019]) * 0.00001, 2), ROUND(SUM([Mar-2019]) * 0.00001, 2)
FROM #TEMPGTVwithoutMARKUP
GROUP BY PropertyCategory
ORDER BY PropertyCategory;
--
INSERT INTO #GTVTOTAL
SELECT 'GTV without Margin Total', 4, 
SUM([Apr-2014]), SUM([May-2014]), SUM([Jun-2014]), SUM([Jul-2014]), SUM([Aug-2014]), SUM([Sep-2014]), SUM([Oct-2014]), SUM([Nov-2014]), SUM([Dec-2014]), 
SUM([Jan-2015]), SUM([Feb-2015]), SUM([Mar-2015]),
SUM([Apr-2015]), SUM([May-2015]), SUM([Jun-2015]), SUM([Jul-2015]), SUM([Aug-2015]), SUM([Sep-2015]), SUM([Oct-2015]), SUM([Nov-2015]), SUM([Dec-2015]), 
SUM([Jan-2016]), SUM([Feb-2016]), SUM([Mar-2016]), 
SUM([Apr-2016]), SUM([May-2016]), SUM([Jun-2016]), SUM([Jul-2016]), SUM([Aug-2016]), SUM([Sep-2016]), SUM([Oct-2016]), SUM([Nov-2016]), SUM([Dec-2016]), 
SUM([Jan-2017]), SUM([Feb-2017]), SUM([Mar-2017]), 
SUM([Apr-2017]), SUM([May-2017]), SUM([Jun-2017]), SUM([Jul-2017]), SUM([Aug-2017]), SUM([Sep-2017]), SUM([Oct-2017]), SUM([Nov-2017]), SUM([Dec-2017]), 
SUM([Jan-2018]), SUM([Feb-2018]), SUM([Mar-2018]),
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019])
FROM #GTVTOTAL
WHERE MarkupFlg = 3;
--
INSERT INTO #GTVTOTAL
SELECT 'GTV Total', 5, 
SUM([Apr-2014]), SUM([May-2014]), SUM([Jun-2014]), SUM([Jul-2014]), SUM([Aug-2014]), SUM([Sep-2014]), SUM([Oct-2014]), SUM([Nov-2014]), SUM([Dec-2014]), 
SUM([Jan-2015]), SUM([Feb-2015]), SUM([Mar-2015]),
SUM([Apr-2015]), SUM([May-2015]), SUM([Jun-2015]), SUM([Jul-2015]), SUM([Aug-2015]), SUM([Sep-2015]), SUM([Oct-2015]), SUM([Nov-2015]), SUM([Dec-2015]), 
SUM([Jan-2016]), SUM([Feb-2016]), SUM([Mar-2016]), 
SUM([Apr-2016]), SUM([May-2016]), SUM([Jun-2016]), SUM([Jul-2016]), SUM([Aug-2016]), SUM([Sep-2016]), SUM([Oct-2016]), SUM([Nov-2016]), SUM([Dec-2016]), 
SUM([Jan-2017]), SUM([Feb-2017]), SUM([Mar-2017]), 
SUM([Apr-2017]), SUM([May-2017]), SUM([Jun-2017]), SUM([Jul-2017]), SUM([Aug-2017]), SUM([Sep-2017]), SUM([Oct-2017]), SUM([Nov-2017]), SUM([Dec-2017]), 
SUM([Jan-2018]), SUM([Feb-2018]), SUM([Mar-2018]),
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019])
FROM #GTVTOTAL
WHERE MarkupFlg IN (2,4);
--
-- TABLE 11 & 12

--SELECT PropertyCategory, SUM([Jun-2017]) FROM #TEMPGTVwithMARKUP GROUP BY PropertyCategory;
--SELECT PropertyCategory, SUM([Jun-2017]) FROM #TEMPGTVwithoutMARKUP GROUP BY PropertyCategory;
--
/*
SELECT 'GTV - Property Category Wise (Excluding Guest House)                                                                              Value in Rs. ( Lacs)' AS Title;
SELECT PropertyCategory,
[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017], 
[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018]  
FROM #GTVTOTAL;
*/

-- CLIENT WISE GTV

CREATE TABLE #GTVTOTALCLIENT(MasterClientName NVARCHAR(100),MasterClientId BIGINT, MarkupFlg INT,
[Apr-2014] DECIMAL(27,2), [May-2014] DECIMAL(27,2), [Jun-2014] DECIMAL(27,2), [Jul-2014] DECIMAL(27,2), [Aug-2014] DECIMAL(27,2), [Sep-2014] DECIMAL(27,2), 
[Oct-2014] DECIMAL(27,2), [Nov-2014] DECIMAL(27,2), [Dec-2014] DECIMAL(27,2), [Jan-2015] DECIMAL(27,2), [Feb-2015] DECIMAL(27,2), [Mar-2015] DECIMAL(27,2),
[Apr-2015] DECIMAL(27,2), [May-2015] DECIMAL(27,2), [Jun-2015] DECIMAL(27,2), [Jul-2015] DECIMAL(27,2), [Aug-2015] DECIMAL(27,2), [Sep-2015] DECIMAL(27,2), 
[Oct-2015] DECIMAL(27,2), [Nov-2015] DECIMAL(27,2), [Dec-2015] DECIMAL(27,2), [Jan-2016] DECIMAL(27,2), [Feb-2016] DECIMAL(27,2), [Mar-2016] DECIMAL(27,2), 
[Apr-2016] DECIMAL(27,2), [May-2016] DECIMAL(27,2), [Jun-2016] DECIMAL(27,2), [Jul-2016] DECIMAL(27,2), [Aug-2016] DECIMAL(27,2), [Sep-2016] DECIMAL(27,2), 
[Oct-2016] DECIMAL(27,2), [Nov-2016] DECIMAL(27,2), [Dec-2016] DECIMAL(27,2), [Jan-2017] DECIMAL(27,2), [Feb-2017] DECIMAL(27,2), [Mar-2017] DECIMAL(27,2), 
[Apr-2017] DECIMAL(27,2), [May-2017] DECIMAL(27,2), [Jun-2017] DECIMAL(27,2), [Jul-2017] DECIMAL(27,2), [Aug-2017] DECIMAL(27,2), [Sep-2017] DECIMAL(27,2), 
[Oct-2017] DECIMAL(27,2), [Nov-2017] DECIMAL(27,2), [Dec-2017] DECIMAL(27,2), [Jan-2018] DECIMAL(27,2), [Feb-2018] DECIMAL(27,2), [Mar-2018] DECIMAL(27,2),
[Apr-2018] DECIMAL(27,2), [May-2018] DECIMAL(27,2), [Jun-2018] DECIMAL(27,2), [Jul-2018] DECIMAL(27,2), [Aug-2018] DECIMAL(27,2), [Sep-2018] DECIMAL(27,2), 
[Oct-2018] DECIMAL(27,2), [Nov-2018] DECIMAL(27,2), [Dec-2018] DECIMAL(27,2), [Jan-2019] DECIMAL(27,2), [Feb-2019] DECIMAL(27,2), [Mar-2019] DECIMAL(27,2));
--
INSERT INTO #GTVTOTALCLIENT
SELECT C.ClientName, T.MasterClientId, 1, 
ROUND(SUM([Apr-2014]) * 0.00001, 2), ROUND(SUM([May-2014]) * 0.00001, 2), ROUND(SUM([Jun-2014]) * 0.00001, 2), ROUND(SUM([Jul-2014]) * 0.00001, 2), 
ROUND(SUM([Aug-2014]) * 0.00001, 2), ROUND(SUM([Sep-2014]) * 0.00001, 2), ROUND(SUM([Oct-2014]) * 0.00001, 2), ROUND(SUM([Nov-2014]) * 0.00001, 2), 
ROUND(SUM([Dec-2014]) * 0.00001, 2), ROUND(SUM([Jan-2015]) * 0.00001, 2), ROUND(SUM([Feb-2015]) * 0.00001, 2), ROUND(SUM([Mar-2015]) * 0.00001, 2),

ROUND(SUM([Apr-2015]) * 0.00001, 2), ROUND(SUM([May-2015]) * 0.00001, 2), ROUND(SUM([Jun-2015]) * 0.00001, 2), ROUND(SUM([Jul-2015]) * 0.00001, 2), 
ROUND(SUM([Aug-2015]) * 0.00001, 2), ROUND(SUM([Sep-2015]) * 0.00001, 2), ROUND(SUM([Oct-2015]) * 0.00001, 2), ROUND(SUM([Nov-2015]) * 0.00001, 2), 
ROUND(SUM([Dec-2015]) * 0.00001, 2), ROUND(SUM([Jan-2016]) * 0.00001, 2), ROUND(SUM([Feb-2016]) * 0.00001, 2), ROUND(SUM([Mar-2016]) * 0.00001, 2),
 
ROUND(SUM([Apr-2016]) * 0.00001, 2), ROUND(SUM([May-2016]) * 0.00001, 2), ROUND(SUM([Jun-2016]) * 0.00001, 2), ROUND(SUM([Jul-2016]) * 0.00001, 2), 
ROUND(SUM([Aug-2016]) * 0.00001, 2), ROUND(SUM([Sep-2016]) * 0.00001, 2), ROUND(SUM([Oct-2016]) * 0.00001, 2), ROUND(SUM([Nov-2016]) * 0.00001, 2), 
ROUND(SUM([Dec-2016]) * 0.00001, 2), ROUND(SUM([Jan-2017]) * 0.00001, 2), ROUND(SUM([Feb-2017]) * 0.00001, 2), ROUND(SUM([Mar-2017]) * 0.00001, 2), 

ROUND(SUM([Apr-2017]) * 0.00001, 2), ROUND(SUM([May-2017]) * 0.00001, 2), ROUND(SUM([Jun-2017]) * 0.00001, 2), ROUND(SUM([Jul-2017]) * 0.00001, 2), 
ROUND(SUM([Aug-2017]) * 0.00001, 2), ROUND(SUM([Sep-2017]) * 0.00001, 2), ROUND(SUM([Oct-2017]) * 0.00001, 2), ROUND(SUM([Nov-2017]) * 0.00001, 2), 
ROUND(SUM([Dec-2017]) * 0.00001, 2), ROUND(SUM([Jan-2018]) * 0.00001, 2), ROUND(SUM([Feb-2018]) * 0.00001, 2), ROUND(SUM([Mar-2018]) * 0.00001, 2),

ROUND(SUM([Apr-2018]) * 0.00001, 2), ROUND(SUM([May-2018]) * 0.00001, 2), ROUND(SUM([Jun-2018]) * 0.00001, 2), ROUND(SUM([Jul-2018]) * 0.00001, 2), 
ROUND(SUM([Aug-2018]) * 0.00001, 2), ROUND(SUM([Sep-2018]) * 0.00001, 2), ROUND(SUM([Oct-2018]) * 0.00001, 2), ROUND(SUM([Nov-2018]) * 0.00001, 2), 
ROUND(SUM([Dec-2018]) * 0.00001, 2), ROUND(SUM([Jan-2019]) * 0.00001, 2), ROUND(SUM([Feb-2019]) * 0.00001, 2), ROUND(SUM([Mar-2019]) * 0.00001, 2)
FROM #TEMPGTVwithMARKUP T
LEFT OUTER JOIN WRBHBMasterClientManagement C WITH(NOLOCK)ON C.Id = T.MasterClientId
WHERE T.MasterClientId IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1)
GROUP BY C.ClientName, T.MasterClientId;
--
INSERT INTO #GTVTOTALCLIENT
SELECT 'Other Clients', 0, 2, 
ROUND(SUM([Apr-2014]) * 0.00001, 2), ROUND(SUM([May-2014]) * 0.00001, 2), ROUND(SUM([Jun-2014]) * 0.00001, 2), ROUND(SUM([Jul-2014]) * 0.00001, 2), 
ROUND(SUM([Aug-2014]) * 0.00001, 2), ROUND(SUM([Sep-2014]) * 0.00001, 2), ROUND(SUM([Oct-2014]) * 0.00001, 2), ROUND(SUM([Nov-2014]) * 0.00001, 2), 
ROUND(SUM([Dec-2014]) * 0.00001, 2), ROUND(SUM([Jan-2015]) * 0.00001, 2), ROUND(SUM([Feb-2015]) * 0.00001, 2), ROUND(SUM([Mar-2015]) * 0.00001, 2),

ROUND(SUM([Apr-2015]) * 0.00001, 2), ROUND(SUM([May-2015]) * 0.00001, 2), ROUND(SUM([Jun-2015]) * 0.00001, 2), ROUND(SUM([Jul-2015]) * 0.00001, 2), 
ROUND(SUM([Aug-2015]) * 0.00001, 2), ROUND(SUM([Sep-2015]) * 0.00001, 2), ROUND(SUM([Oct-2015]) * 0.00001, 2), ROUND(SUM([Nov-2015]) * 0.00001, 2), 
ROUND(SUM([Dec-2015]) * 0.00001, 2), ROUND(SUM([Jan-2016]) * 0.00001, 2), ROUND(SUM([Feb-2016]) * 0.00001, 2), ROUND(SUM([Mar-2016]) * 0.00001, 2),
 
ROUND(SUM([Apr-2016]) * 0.00001, 2), ROUND(SUM([May-2016]) * 0.00001, 2), ROUND(SUM([Jun-2016]) * 0.00001, 2), ROUND(SUM([Jul-2016]) * 0.00001, 2), 
ROUND(SUM([Aug-2016]) * 0.00001, 2), ROUND(SUM([Sep-2016]) * 0.00001, 2), ROUND(SUM([Oct-2016]) * 0.00001, 2), ROUND(SUM([Nov-2016]) * 0.00001, 2), 
ROUND(SUM([Dec-2016]) * 0.00001, 2), ROUND(SUM([Jan-2017]) * 0.00001, 2), ROUND(SUM([Feb-2017]) * 0.00001, 2), ROUND(SUM([Mar-2017]) * 0.00001, 2), 

ROUND(SUM([Apr-2017]) * 0.00001, 2), ROUND(SUM([May-2017]) * 0.00001, 2), ROUND(SUM([Jun-2017]) * 0.00001, 2), ROUND(SUM([Jul-2017]) * 0.00001, 2), 
ROUND(SUM([Aug-2017]) * 0.00001, 2), ROUND(SUM([Sep-2017]) * 0.00001, 2), ROUND(SUM([Oct-2017]) * 0.00001, 2), ROUND(SUM([Nov-2017]) * 0.00001, 2), 
ROUND(SUM([Dec-2017]) * 0.00001, 2), ROUND(SUM([Jan-2018]) * 0.00001, 2), ROUND(SUM([Feb-2018]) * 0.00001, 2), ROUND(SUM([Mar-2018]) * 0.00001, 2),

ROUND(SUM([Apr-2018]) * 0.00001, 2), ROUND(SUM([May-2018]) * 0.00001, 2), ROUND(SUM([Jun-2018]) * 0.00001, 2), ROUND(SUM([Jul-2018]) * 0.00001, 2), 
ROUND(SUM([Aug-2018]) * 0.00001, 2), ROUND(SUM([Sep-2018]) * 0.00001, 2), ROUND(SUM([Oct-2018]) * 0.00001, 2), ROUND(SUM([Nov-2018]) * 0.00001, 2), 
ROUND(SUM([Dec-2018]) * 0.00001, 2), ROUND(SUM([Jan-2019]) * 0.00001, 2), ROUND(SUM([Feb-2019]) * 0.00001, 2), ROUND(SUM([Mar-2019]) * 0.00001, 2)
FROM #TEMPGTVwithMARKUP
WHERE MasterClientId NOT IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1);
--
INSERT INTO #GTVTOTALCLIENT
SELECT ' GTV with Margin Total', 0, 3, 
SUM([Apr-2014]), SUM([May-2014]), SUM([Jun-2014]), SUM([Jul-2014]), SUM([Aug-2014]), SUM([Sep-2014]), SUM([Oct-2014]), SUM([Nov-2014]), SUM([Dec-2014]), 
SUM([Jan-2015]), SUM([Feb-2015]), SUM([Mar-2015]),
SUM([Apr-2015]), SUM([May-2015]), SUM([Jun-2015]), SUM([Jul-2015]), SUM([Aug-2015]), SUM([Sep-2015]), SUM([Oct-2015]), SUM([Nov-2015]), SUM([Dec-2015]), 
SUM([Jan-2016]), SUM([Feb-2016]), SUM([Mar-2016]), 
SUM([Apr-2016]), SUM([May-2016]), SUM([Jun-2016]), SUM([Jul-2016]), SUM([Aug-2016]), SUM([Sep-2016]), SUM([Oct-2016]), SUM([Nov-2016]), SUM([Dec-2016]), 
SUM([Jan-2017]), SUM([Feb-2017]), SUM([Mar-2017]), 
SUM([Apr-2017]), SUM([May-2017]), SUM([Jun-2017]), SUM([Jul-2017]), SUM([Aug-2017]), SUM([Sep-2017]), SUM([Oct-2017]), SUM([Nov-2017]), SUM([Dec-2017]), 
SUM([Jan-2018]), SUM([Feb-2018]), SUM([Mar-2018]),
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019])
FROM #GTVTOTALCLIENT;
--
INSERT INTO #GTVTOTALCLIENT
SELECT C.ClientName, T.MasterClientId, 4, 
ROUND(SUM([Apr-2014]) * 0.00001, 2), ROUND(SUM([May-2014]) * 0.00001, 2), ROUND(SUM([Jun-2014]) * 0.00001, 2), ROUND(SUM([Jul-2014]) * 0.00001, 2), 
ROUND(SUM([Aug-2014]) * 0.00001, 2), ROUND(SUM([Sep-2014]) * 0.00001, 2), ROUND(SUM([Oct-2014]) * 0.00001, 2), ROUND(SUM([Nov-2014]) * 0.00001, 2), 
ROUND(SUM([Dec-2014]) * 0.00001, 2), ROUND(SUM([Jan-2015]) * 0.00001, 2), ROUND(SUM([Feb-2015]) * 0.00001, 2), ROUND(SUM([Mar-2015]) * 0.00001, 2),

ROUND(SUM([Apr-2015]) * 0.00001, 2), ROUND(SUM([May-2015]) * 0.00001, 2), ROUND(SUM([Jun-2015]) * 0.00001, 2), ROUND(SUM([Jul-2015]) * 0.00001, 2), 
ROUND(SUM([Aug-2015]) * 0.00001, 2), ROUND(SUM([Sep-2015]) * 0.00001, 2), ROUND(SUM([Oct-2015]) * 0.00001, 2), ROUND(SUM([Nov-2015]) * 0.00001, 2), 
ROUND(SUM([Dec-2015]) * 0.00001, 2), ROUND(SUM([Jan-2016]) * 0.00001, 2), ROUND(SUM([Feb-2016]) * 0.00001, 2), ROUND(SUM([Mar-2016]) * 0.00001, 2),
 
ROUND(SUM([Apr-2016]) * 0.00001, 2), ROUND(SUM([May-2016]) * 0.00001, 2), ROUND(SUM([Jun-2016]) * 0.00001, 2), ROUND(SUM([Jul-2016]) * 0.00001, 2), 
ROUND(SUM([Aug-2016]) * 0.00001, 2), ROUND(SUM([Sep-2016]) * 0.00001, 2), ROUND(SUM([Oct-2016]) * 0.00001, 2), ROUND(SUM([Nov-2016]) * 0.00001, 2), 
ROUND(SUM([Dec-2016]) * 0.00001, 2), ROUND(SUM([Jan-2017]) * 0.00001, 2), ROUND(SUM([Feb-2017]) * 0.00001, 2), ROUND(SUM([Mar-2017]) * 0.00001, 2), 

ROUND(SUM([Apr-2017]) * 0.00001, 2), ROUND(SUM([May-2017]) * 0.00001, 2), ROUND(SUM([Jun-2017]) * 0.00001, 2), ROUND(SUM([Jul-2017]) * 0.00001, 2), 
ROUND(SUM([Aug-2017]) * 0.00001, 2), ROUND(SUM([Sep-2017]) * 0.00001, 2), ROUND(SUM([Oct-2017]) * 0.00001, 2), ROUND(SUM([Nov-2017]) * 0.00001, 2), 
ROUND(SUM([Dec-2017]) * 0.00001, 2), ROUND(SUM([Jan-2018]) * 0.00001, 2), ROUND(SUM([Feb-2018]) * 0.00001, 2), ROUND(SUM([Mar-2018]) * 0.00001, 2),

ROUND(SUM([Apr-2018]) * 0.00001, 2), ROUND(SUM([May-2018]) * 0.00001, 2), ROUND(SUM([Jun-2018]) * 0.00001, 2), ROUND(SUM([Jul-2018]) * 0.00001, 2), 
ROUND(SUM([Aug-2018]) * 0.00001, 2), ROUND(SUM([Sep-2018]) * 0.00001, 2), ROUND(SUM([Oct-2018]) * 0.00001, 2), ROUND(SUM([Nov-2018]) * 0.00001, 2), 
ROUND(SUM([Dec-2018]) * 0.00001, 2), ROUND(SUM([Jan-2019]) * 0.00001, 2), ROUND(SUM([Feb-2019]) * 0.00001, 2), ROUND(SUM([Mar-2019]) * 0.00001, 2)
FROM #TEMPGTVwithoutMARKUP T
LEFT OUTER JOIN WRBHBMasterClientManagement C WITH(NOLOCK)ON C.Id = T.MasterClientId
WHERE T.MasterClientId IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1)
GROUP BY C.ClientName, T.MasterClientId;
--
INSERT INTO #GTVTOTALCLIENT
SELECT 'Other Clients', 0, 5, 
ROUND(SUM([Apr-2014]) * 0.00001, 2), ROUND(SUM([May-2014]) * 0.00001, 2), ROUND(SUM([Jun-2014]) * 0.00001, 2), ROUND(SUM([Jul-2014]) * 0.00001, 2), 
ROUND(SUM([Aug-2014]) * 0.00001, 2), ROUND(SUM([Sep-2014]) * 0.00001, 2), ROUND(SUM([Oct-2014]) * 0.00001, 2), ROUND(SUM([Nov-2014]) * 0.00001, 2), 
ROUND(SUM([Dec-2014]) * 0.00001, 2), ROUND(SUM([Jan-2015]) * 0.00001, 2), ROUND(SUM([Feb-2015]) * 0.00001, 2), ROUND(SUM([Mar-2015]) * 0.00001, 2),

ROUND(SUM([Apr-2015]) * 0.00001, 2), ROUND(SUM([May-2015]) * 0.00001, 2), ROUND(SUM([Jun-2015]) * 0.00001, 2), ROUND(SUM([Jul-2015]) * 0.00001, 2), 
ROUND(SUM([Aug-2015]) * 0.00001, 2), ROUND(SUM([Sep-2015]) * 0.00001, 2), ROUND(SUM([Oct-2015]) * 0.00001, 2), ROUND(SUM([Nov-2015]) * 0.00001, 2), 
ROUND(SUM([Dec-2015]) * 0.00001, 2), ROUND(SUM([Jan-2016]) * 0.00001, 2), ROUND(SUM([Feb-2016]) * 0.00001, 2), ROUND(SUM([Mar-2016]) * 0.00001, 2),
 
ROUND(SUM([Apr-2016]) * 0.00001, 2), ROUND(SUM([May-2016]) * 0.00001, 2), ROUND(SUM([Jun-2016]) * 0.00001, 2), ROUND(SUM([Jul-2016]) * 0.00001, 2), 
ROUND(SUM([Aug-2016]) * 0.00001, 2), ROUND(SUM([Sep-2016]) * 0.00001, 2), ROUND(SUM([Oct-2016]) * 0.00001, 2), ROUND(SUM([Nov-2016]) * 0.00001, 2), 
ROUND(SUM([Dec-2016]) * 0.00001, 2), ROUND(SUM([Jan-2017]) * 0.00001, 2), ROUND(SUM([Feb-2017]) * 0.00001, 2), ROUND(SUM([Mar-2017]) * 0.00001, 2), 

ROUND(SUM([Apr-2017]) * 0.00001, 2), ROUND(SUM([May-2017]) * 0.00001, 2), ROUND(SUM([Jun-2017]) * 0.00001, 2), ROUND(SUM([Jul-2017]) * 0.00001, 2), 
ROUND(SUM([Aug-2017]) * 0.00001, 2), ROUND(SUM([Sep-2017]) * 0.00001, 2), ROUND(SUM([Oct-2017]) * 0.00001, 2), ROUND(SUM([Nov-2017]) * 0.00001, 2), 
ROUND(SUM([Dec-2017]) * 0.00001, 2), ROUND(SUM([Jan-2018]) * 0.00001, 2), ROUND(SUM([Feb-2018]) * 0.00001, 2), ROUND(SUM([Mar-2018]) * 0.00001, 2),

ROUND(SUM([Apr-2018]) * 0.00001, 2), ROUND(SUM([May-2018]) * 0.00001, 2), ROUND(SUM([Jun-2018]) * 0.00001, 2), ROUND(SUM([Jul-2018]) * 0.00001, 2), 
ROUND(SUM([Aug-2018]) * 0.00001, 2), ROUND(SUM([Sep-2018]) * 0.00001, 2), ROUND(SUM([Oct-2018]) * 0.00001, 2), ROUND(SUM([Nov-2018]) * 0.00001, 2), 
ROUND(SUM([Dec-2018]) * 0.00001, 2), ROUND(SUM([Jan-2019]) * 0.00001, 2), ROUND(SUM([Feb-2019]) * 0.00001, 2), ROUND(SUM([Mar-2019]) * 0.00001, 2)
FROM #TEMPGTVwithoutMARKUP
WHERE MasterClientId NOT IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1);
--
INSERT INTO #GTVTOTALCLIENT
SELECT ' GTV without Margin Total', 0, 6, 
SUM([Apr-2014]), SUM([May-2014]), SUM([Jun-2014]), SUM([Jul-2014]), SUM([Aug-2014]), SUM([Sep-2014]), SUM([Oct-2014]), SUM([Nov-2014]), SUM([Dec-2014]), 
SUM([Jan-2015]), SUM([Feb-2015]), SUM([Mar-2015]),
SUM([Apr-2015]), SUM([May-2015]), SUM([Jun-2015]), SUM([Jul-2015]), SUM([Aug-2015]), SUM([Sep-2015]), SUM([Oct-2015]), SUM([Nov-2015]), SUM([Dec-2015]), 
SUM([Jan-2016]), SUM([Feb-2016]), SUM([Mar-2016]), 
SUM([Apr-2016]), SUM([May-2016]), SUM([Jun-2016]), SUM([Jul-2016]), SUM([Aug-2016]), SUM([Sep-2016]), SUM([Oct-2016]), SUM([Nov-2016]), SUM([Dec-2016]), 
SUM([Jan-2017]), SUM([Feb-2017]), SUM([Mar-2017]), 
SUM([Apr-2017]), SUM([May-2017]), SUM([Jun-2017]), SUM([Jul-2017]), SUM([Aug-2017]), SUM([Sep-2017]), SUM([Oct-2017]), SUM([Nov-2017]), SUM([Dec-2017]), 
SUM([Jan-2018]), SUM([Feb-2018]), SUM([Mar-2018]),
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019])
FROM #GTVTOTALCLIENT
WHERE MarkupFlg IN (4,5);
--
INSERT INTO #GTVTOTALCLIENT
SELECT ' GTV Total', 0, 7, 
SUM([Apr-2014]), SUM([May-2014]), SUM([Jun-2014]), SUM([Jul-2014]), SUM([Aug-2014]), SUM([Sep-2014]), SUM([Oct-2014]), SUM([Nov-2014]), SUM([Dec-2014]), 
SUM([Jan-2015]), SUM([Feb-2015]), SUM([Mar-2015]),
SUM([Apr-2015]), SUM([May-2015]), SUM([Jun-2015]), SUM([Jul-2015]), SUM([Aug-2015]), SUM([Sep-2015]), SUM([Oct-2015]), SUM([Nov-2015]), SUM([Dec-2015]), 
SUM([Jan-2016]), SUM([Feb-2016]), SUM([Mar-2016]), 
SUM([Apr-2016]), SUM([May-2016]), SUM([Jun-2016]), SUM([Jul-2016]), SUM([Aug-2016]), SUM([Sep-2016]), SUM([Oct-2016]), SUM([Nov-2016]), SUM([Dec-2016]), 
SUM([Jan-2017]), SUM([Feb-2017]), SUM([Mar-2017]), 
SUM([Apr-2017]), SUM([May-2017]), SUM([Jun-2017]), SUM([Jul-2017]), SUM([Aug-2017]), SUM([Sep-2017]), SUM([Oct-2017]), SUM([Nov-2017]), SUM([Dec-2017]), 
SUM([Jan-2018]), SUM([Feb-2018]), SUM([Mar-2018]),
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019])
FROM #GTVTOTALCLIENT
WHERE MarkupFlg IN (3,6);
--

-- TABLE 13 & 14

/*
SELECT 'GTV by Client Wise (Excluding Guest House)                                                                             Value in Rs. ( Lacs)' AS Title;
SELECT MasterClientName AS 'Top Clients',
[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017], 
[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018]  
FROM #GTVTOTALCLIENT;
*/

----- Result -----

SELECT '' AS C1,
'Jun-18' AS C22, 'May-18' AS C2, 'Apr-18' AS C3,
'Mar-18' AS C4, 'Feb-18' AS C5, 'Jan-18' AS C6, 'Dec-17' AS C7, 'Nov-17' AS C8, 'Oct-17' AS C9, 'Sep-17' AS C10, 
'Aug-17' AS C11, 'Jul-17' AS C12, 'Jun-17' AS C13, 'May-17' AS C14, 'Apr-17' AS C15;

-- TABLE 1 & 2
SELECT 'Property ( Hotel Chain ) - Room Nights ( Value in Nos )' AS Title;
SELECT 'PropertyName' AS C1;
SELECT MasterPropertyName AS PropertyName,
[Jun-2018], [May-2018], [Apr-2018],
[Mar-2018], [Feb-2018], [Jan-2018], [Dec-2017], [Nov-2017], [Oct-2017], [Sep-2017], [Aug-2017], [Jul-2017], [Jun-2017], [May-2017], [Apr-2017]
FROM #TDR T
ORDER BY Flg ASC, [Jun-2018] DESC, MasterPropertyName ASC;
-- TABLE 3 & 4
SELECT 'Clients - Room Nights ( Value in Nos )' AS Title;
SELECT 'Top Clients' AS C1;
SELECT MasterClientName,
[Jun-2018], [May-2018], [Apr-2018],
[Mar-2018], [Feb-2018], [Jan-2018], [Dec-2017], [Nov-2017], [Oct-2017], [Sep-2017], [Aug-2017], [Jul-2017], [Jun-2017], [May-2017], [Apr-2017]
FROM #TDRClient T
ORDER BY Flg ASC, [Jun-2018] DESC, MasterClientName ASC;
-- TABLE 5 & 6
SELECT 'Room Nights by Property Category ( Value in Nos )' AS Title;
SELECT 'Property Category' AS C1;
SELECT PropertyCategory,
[Jun-2018], [May-2018], [Apr-2018],
[Mar-2018], [Feb-2018], [Jan-2018], [Dec-2017], [Nov-2017], [Oct-2017], [Sep-2017], [Aug-2017], [Jul-2017], [Jun-2017], [May-2017], [Apr-2017]
FROM #TDRCatgy
ORDER BY Flg;
-- TABLE 7 & 8
SELECT 'Margin from External Properties by Property Category ( Value in Rs. ( Lacs) )' AS Title;
SELECT 'Property Category' AS C1;
SELECT PropertyCategory,
[Jun-2018], [May-2018], [Apr-2018],
[Mar-2018], [Feb-2018], [Jan-2018], [Dec-2017], [Nov-2017], [Oct-2017], [Sep-2017], [Aug-2017], [Jul-2017], [Jun-2017], [May-2017], [Apr-2017]
FROM #TDRMARKUP_Category_New
ORDER BY Flg;
-- TABLE 9 & 10
SELECT 'External Margin Analysis by Client ( Value in Rs. ( Lacs) )' AS Title;
SELECT 'Top Clients' AS C1;
SELECT MasterClientName,
[Jun-2018], [May-2018], [Apr-2018],
[Mar-2018], [Feb-2018], [Jan-2018], [Dec-2017], [Nov-2017], [Oct-2017], [Sep-2017], [Aug-2017], [Jul-2017], [Jun-2017], [May-2017], [Apr-2017]
FROM #TDRMARKUP_New
ORDER BY Flg ASC, [Jun-2018] DESC, MasterClientName ASC;
-- TABLE 11 & 12
SELECT 'GTV by Property Category (Excluding Guest House) ( Value in Rs. ( Lacs) )' AS Title;
SELECT 'Property Category' AS C1;
SELECT PropertyCategory,
[Jun-2018], [May-2018], [Apr-2018],
[Mar-2018], [Feb-2018], [Jan-2018], [Dec-2017], [Nov-2017], [Oct-2017], [Sep-2017], [Aug-2017], [Jul-2017], [Jun-2017], [May-2017], [Apr-2017]
FROM #GTVTOTAL ORDER BY MarkupFlg;
-- TABLE 13 & 14
SELECT 'GTV by Client Wise (Excluding Guest House) ( Value in Rs. ( Lacs) )' AS Title;
SELECT 'Top Clients' AS C1;
SELECT MasterClientName,
[Jun-2018], [May-2018], [Apr-2018],
[Mar-2018], [Feb-2018], [Jan-2018], [Dec-2017], [Nov-2017], [Oct-2017], [Sep-2017], [Aug-2017], [Jul-2017], [Jun-2017], [May-2017], [Apr-2017]
FROM #GTVTOTALCLIENT
ORDER BY MarkupFlg ASC, [Jun-2018] DESC, MasterClientName ASC;

----- Daily Tracking Report End -----

----- Monthly Analysis Report Start -----

CREATE TABLE #TEMPMONTH1(CityId BIGINT, MonthofBooking NVARCHAR(100));
INSERT INTO #TEMPMONTH1(CityId, MonthofBooking)
SELECT CityId, asasd FROM #TEMP2 WHERE PropertyCategory IN ('External','C P P')
GROUP BY asasd,CityId;
---
CREATE TABLE #TEMPMONTH2(MonthofBooking NVARCHAR(100), CityCount INT);
INSERT INTO #TEMPMONTH2
SELECT MonthofBooking,COUNT(CityId) FROM #TEMPMONTH1 GROUP BY MonthofBooking;
---
SELECT [Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
       [Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
	   [Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
	   [Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
	   [Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019]
INTO #TEMPMONTH3
FROM #TEMPMONTH2
PIVOT
(
       SUM(CityCount)
       FOR MonthofBooking IN 
	   ([Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
		[Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
		[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
		[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
		[Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019])
) AS P;
---
CREATE TABLE #TEMPMONTH4(Title NVARCHAR(100), Flg INT,
[Apr-2014] INT, [May-2014] INT, [Jun-2014] INT, [Jul-2014] INT, [Aug-2014] INT, [Sep-2014] INT, [Oct-2014] INT, [Nov-2014] INT, [Dec-2014] INT, 
[Jan-2015] INT, [Feb-2015] INT, [Mar-2015] INT,
[Apr-2015] INT, [May-2015] INT, [Jun-2015] INT, [Jul-2015] INT, [Aug-2015] INT, [Sep-2015] INT, [Oct-2015] INT, [Nov-2015] INT, [Dec-2015] INT, 
[Jan-2016] INT, [Feb-2016] INT, [Mar-2016] INT, 
[Apr-2016] INT, [May-2016] INT, [Jun-2016] INT, [Jul-2016] INT, [Aug-2016] INT, [Sep-2016] INT, [Oct-2016] INT, [Nov-2016] INT, [Dec-2016] INT, 
[Jan-2017] INT, [Feb-2017] INT, [Mar-2017] INT, 
[Apr-2017] INT, [May-2017] INT, [Jun-2017] INT, [Jul-2017] INT, [Aug-2017] INT, [Sep-2017] INT, [Oct-2017] INT, [Nov-2017] INT, [Dec-2017] INT,
[Jan-2018] INT, [Feb-2018] INT, [Mar-2018] INT,
[Apr-2018] INT, [May-2018] INT, [Jun-2018] INT, [Jul-2018] INT, [Aug-2018] INT, [Sep-2018] INT, [Oct-2018] INT, [Nov-2018] INT, [Dec-2018] INT,
[Jan-2019] INT, [Feb-2019] INT, [Mar-2019] INT);
---
INSERT INTO #TEMPMONTH4
SELECT 'Total No of Cities', 1,
ISNULL([Apr-2014],0), ISNULL([May-2014],0), ISNULL([Jun-2014],0), ISNULL([Jul-2014],0), ISNULL([Aug-2014],0), ISNULL([Sep-2014],0), ISNULL([Oct-2014],0), 
ISNULL([Nov-2014],0), ISNULL([Dec-2014],0), ISNULL([Jan-2015],0), ISNULL([Feb-2015],0), ISNULL([Mar-2015],0), 
ISNULL([Apr-2015],0), ISNULL([May-2015],0), ISNULL([Jun-2015],0), ISNULL([Jul-2015],0), ISNULL([Aug-2015],0), ISNULL([Sep-2015],0), ISNULL([Oct-2015],0), 
ISNULL([Nov-2015],0), ISNULL([Dec-2015],0), ISNULL([Jan-2016],0), ISNULL([Feb-2016],0), ISNULL([Mar-2016],0), 
ISNULL([Apr-2016],0), ISNULL([May-2016],0), ISNULL([Jun-2016],0), ISNULL([Jul-2016],0), ISNULL([Aug-2016],0), ISNULL([Sep-2016],0), ISNULL([Oct-2016],0), 
ISNULL([Nov-2016],0), ISNULL([Dec-2016],0), ISNULL([Jan-2017],0), ISNULL([Feb-2017],0), ISNULL([Mar-2017],0), 
ISNULL([Apr-2017],0), ISNULL([May-2017],0), ISNULL([Jun-2017],0), ISNULL([Jul-2017],0), ISNULL([Aug-2017],0), ISNULL([Sep-2017],0), ISNULL([Oct-2017],0), 
ISNULL([Nov-2017],0), ISNULL([Dec-2017],0), ISNULL([Jan-2018],0), ISNULL([Feb-2018],0), ISNULL([Mar-2018],0),
ISNULL([Apr-2018],0), ISNULL([May-2018],0), ISNULL([Jun-2018],0), ISNULL([Jul-2018],0), ISNULL([Aug-2018],0), ISNULL([Sep-2018],0), ISNULL([Oct-2018],0), 
ISNULL([Nov-2018],0), ISNULL([Dec-2018],0), ISNULL([Jan-2019],0), ISNULL([Feb-2019],0), ISNULL([Mar-2019],0)  from #TEMPMONTH3;
---
CREATE TABLE #TEMPMONTH5(PropertyId BIGINT, MonthofBooking NVARCHAR(100));
INSERT INTO #TEMPMONTH5(PropertyId, MonthofBooking)
SELECT PropertyId, asasd FROM #TEMP2 WHERE PropertyCategory IN ('External','C P P') 
GROUP BY PropertyId, asasd;
---
CREATE TABLE #TEMPMONTH6(MonthofBooking NVARCHAR(100), PropertyCount INT);
INSERT INTO #TEMPMONTH6
SELECT MonthofBooking,COUNT(PropertyId) FROM #TEMPMONTH5 GROUP BY MonthofBooking;
---
SELECT [Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
       [Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
	   [Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
	   [Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
	   [Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019]
INTO #TEMPMONTH7
FROM #TEMPMONTH6
PIVOT
(
       SUM(PropertyCount)
       FOR MonthofBooking IN 
	   ([Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
		[Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
		[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
		[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
		[Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019])
) AS P;
---
INSERT INTO #TEMPMONTH4
SELECT 'Total No of Hotels HB Digital', 2,
ISNULL([Apr-2014],0), ISNULL([May-2014],0), ISNULL([Jun-2014],0), ISNULL([Jul-2014],0), ISNULL([Aug-2014],0), ISNULL([Sep-2014],0), ISNULL([Oct-2014],0), 
ISNULL([Nov-2014],0), ISNULL([Dec-2014],0), ISNULL([Jan-2015],0), ISNULL([Feb-2015],0), ISNULL([Mar-2015],0), 
ISNULL([Apr-2015],0), ISNULL([May-2015],0), ISNULL([Jun-2015],0), ISNULL([Jul-2015],0), ISNULL([Aug-2015],0), ISNULL([Sep-2015],0), ISNULL([Oct-2015],0), 
ISNULL([Nov-2015],0), ISNULL([Dec-2015],0), ISNULL([Jan-2016],0), ISNULL([Feb-2016],0), ISNULL([Mar-2016],0), 
ISNULL([Apr-2016],0), ISNULL([May-2016],0), ISNULL([Jun-2016],0), ISNULL([Jul-2016],0), ISNULL([Aug-2016],0), ISNULL([Sep-2016],0), ISNULL([Oct-2016],0), 
ISNULL([Nov-2016],0), ISNULL([Dec-2016],0), ISNULL([Jan-2017],0), ISNULL([Feb-2017],0), ISNULL([Mar-2017],0), 
ISNULL([Apr-2017],0), ISNULL([May-2017],0), ISNULL([Jun-2017],0), ISNULL([Jul-2017],0), ISNULL([Aug-2017],0), ISNULL([Sep-2017],0), ISNULL([Oct-2017],0), 
ISNULL([Nov-2017],0), ISNULL([Dec-2017],0), ISNULL([Jan-2018],0), ISNULL([Feb-2018],0), ISNULL([Mar-2018],0),
ISNULL([Apr-2018],0), ISNULL([May-2018],0), ISNULL([Jun-2018],0), ISNULL([Jul-2018],0), ISNULL([Aug-2018],0), ISNULL([Sep-2018],0), ISNULL([Oct-2018],0), 
ISNULL([Nov-2018],0), ISNULL([Dec-2018],0), ISNULL([Jan-2019],0), ISNULL([Feb-2019],0), ISNULL([Mar-2019],0)  from #TEMPMONTH7;
--
CREATE TABLE #TEMPMONTH8(PropertyId BIGINT, MonthofBooking NVARCHAR(100));
INSERT INTO #TEMPMONTH8(PropertyId, MonthofBooking)
SELECT PropertyId,asasd FROM #TEMP2 
WHERE MasterPropertyId NOT IN (0,1) AND PropertyCategory IN ('External','C P P')
GROUP BY PropertyId,asasd;
---
CREATE TABLE #TEMPMONTH9(MonthofBooking NVARCHAR(100), ChainPropertyCount INT);
INSERT INTO #TEMPMONTH9
SELECT MonthofBooking,COUNT(PropertyId) FROM #TEMPMONTH8 GROUP BY MonthofBooking;

SELECT [Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
       [Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
	   [Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
	   [Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
	   [Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019]
INTO #TEMPMONTH10
FROM #TEMPMONTH9
PIVOT
(
       SUM(ChainPropertyCount)
       FOR MonthofBooking IN 
	   ([Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
		[Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
		[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
		[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
		[Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019])
) AS P;
---
INSERT INTO #TEMPMONTH4
SELECT '     Total No of Chain Hotels', 3,
ISNULL([Apr-2014],0), ISNULL([May-2014],0), ISNULL([Jun-2014],0), ISNULL([Jul-2014],0), ISNULL([Aug-2014],0), ISNULL([Sep-2014],0), ISNULL([Oct-2014],0), 
ISNULL([Nov-2014],0), ISNULL([Dec-2014],0), ISNULL([Jan-2015],0), ISNULL([Feb-2015],0), ISNULL([Mar-2015],0), 
ISNULL([Apr-2015],0), ISNULL([May-2015],0), ISNULL([Jun-2015],0), ISNULL([Jul-2015],0), ISNULL([Aug-2015],0), ISNULL([Sep-2015],0), ISNULL([Oct-2015],0), 
ISNULL([Nov-2015],0), ISNULL([Dec-2015],0), ISNULL([Jan-2016],0), ISNULL([Feb-2016],0), ISNULL([Mar-2016],0), 
ISNULL([Apr-2016],0), ISNULL([May-2016],0), ISNULL([Jun-2016],0), ISNULL([Jul-2016],0), ISNULL([Aug-2016],0), ISNULL([Sep-2016],0), ISNULL([Oct-2016],0), 
ISNULL([Nov-2016],0), ISNULL([Dec-2016],0), ISNULL([Jan-2017],0), ISNULL([Feb-2017],0), ISNULL([Mar-2017],0), 
ISNULL([Apr-2017],0), ISNULL([May-2017],0), ISNULL([Jun-2017],0), ISNULL([Jul-2017],0), ISNULL([Aug-2017],0), ISNULL([Sep-2017],0), ISNULL([Oct-2017],0), 
ISNULL([Nov-2017],0), ISNULL([Dec-2017],0), ISNULL([Jan-2018],0), ISNULL([Feb-2018],0), ISNULL([Mar-2018],0),
ISNULL([Apr-2018],0), ISNULL([May-2018],0), ISNULL([Jun-2018],0), ISNULL([Jul-2018],0), ISNULL([Aug-2018],0), ISNULL([Sep-2018],0), ISNULL([Oct-2018],0), 
ISNULL([Nov-2018],0), ISNULL([Dec-2018],0), ISNULL([Jan-2019],0), ISNULL([Feb-2019],0), ISNULL([Mar-2019],0)  from #TEMPMONTH10;

INSERT INTO #TEMPMONTH4
SELECT '', 4,
-ISNULL([Apr-2014],0), -ISNULL([May-2014],0), -ISNULL([Jun-2014],0), -ISNULL([Jul-2014],0), -ISNULL([Aug-2014],0), -ISNULL([Sep-2014],0), -ISNULL([Oct-2014],0), 
-ISNULL([Nov-2014],0), -ISNULL([Dec-2014],0), -ISNULL([Jan-2015],0), -ISNULL([Feb-2015],0), -ISNULL([Mar-2015],0), 
-ISNULL([Apr-2015],0), -ISNULL([May-2015],0), -ISNULL([Jun-2015],0), -ISNULL([Jul-2015],0), -ISNULL([Aug-2015],0), -ISNULL([Sep-2015],0), -ISNULL([Oct-2015],0), 
-ISNULL([Nov-2015],0), -ISNULL([Dec-2015],0), -ISNULL([Jan-2016],0), -ISNULL([Feb-2016],0), -ISNULL([Mar-2016],0), 
-ISNULL([Apr-2016],0), -ISNULL([May-2016],0), -ISNULL([Jun-2016],0), -ISNULL([Jul-2016],0), -ISNULL([Aug-2016],0), -ISNULL([Sep-2016],0), -ISNULL([Oct-2016],0), 
-ISNULL([Nov-2016],0), -ISNULL([Dec-2016],0), -ISNULL([Jan-2017],0), -ISNULL([Feb-2017],0), -ISNULL([Mar-2017],0), 
-ISNULL([Apr-2017],0), -ISNULL([May-2017],0), -ISNULL([Jun-2017],0), -ISNULL([Jul-2017],0), -ISNULL([Aug-2017],0), -ISNULL([Sep-2017],0), -ISNULL([Oct-2017],0), 
-ISNULL([Nov-2017],0), -ISNULL([Dec-2017],0), -ISNULL([Jan-2018],0), -ISNULL([Feb-2018],0), -ISNULL([Mar-2018],0),
-ISNULL([Apr-2018],0), -ISNULL([May-2018],0), -ISNULL([Jun-2018],0), -ISNULL([Jul-2018],0), -ISNULL([Aug-2018],0), -ISNULL([Sep-2018],0), -ISNULL([Oct-2018],0), 
-ISNULL([Nov-2018],0), -ISNULL([Dec-2018],0), -ISNULL([Jan-2019],0), -ISNULL([Feb-2019],0), -ISNULL([Mar-2019],0)  from #TEMPMONTH10;

INSERT INTO #TEMPMONTH4
SELECT '     Total No of Non Chain Hotels', 5,
SUM([Apr-2014]), SUM([May-2014]), SUM([Jun-2014]), SUM([Jul-2014]), SUM([Aug-2014]), SUM([Sep-2014]), SUM([Oct-2014]), SUM([Nov-2014]), SUM([Dec-2014]), 
SUM([Jan-2015]), SUM([Feb-2015]), SUM([Mar-2015]),
SUM([Apr-2015]), SUM([May-2015]), SUM([Jun-2015]), SUM([Jul-2015]), SUM([Aug-2015]), SUM([Sep-2015]), SUM([Oct-2015]), SUM([Nov-2015]), SUM([Dec-2015]), 
SUM([Jan-2016]), SUM([Feb-2016]), SUM([Mar-2016]), 
SUM([Apr-2016]), SUM([May-2016]), SUM([Jun-2016]), SUM([Jul-2016]), SUM([Aug-2016]), SUM([Sep-2016]), SUM([Oct-2016]), SUM([Nov-2016]), SUM([Dec-2016]), 
SUM([Jan-2017]), SUM([Feb-2017]), SUM([Mar-2017]), 
SUM([Apr-2017]), SUM([May-2017]), SUM([Jun-2017]), SUM([Jul-2017]), SUM([Aug-2017]), SUM([Sep-2017]), SUM([Oct-2017]), SUM([Nov-2017]), SUM([Dec-2017]), 
SUM([Jan-2018]), SUM([Feb-2018]), SUM([Mar-2018]),
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019])
FROM #TEMPMONTH4 WHERE Flg IN (2,4);
-- TABLE 1
/*SELECT '', Title,
[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017], 
[Apr-2016] + [May-2016] + [Jun-2016] + [Jul-2016] + [Aug-2016] + [Sep-2016] + [Oct-2016] + [Nov-2016] + [Dec-2016] + [Jan-2017] + [Feb-2017] + [Mar-2017] AS Total,
[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018]
FROM #TEMPMONTH4 
WHERE Flg IN (1,2,3,5);*/
--
CREATE TABLE #TEMPMONTH11(Title1 NVARCHAR(100),Title2 NVARCHAR(100), Flg INT,
[Apr-2014] INT, [May-2014] INT, [Jun-2014] INT, [Jul-2014] INT, [Aug-2014] INT, [Sep-2014] INT, [Oct-2014] INT, [Nov-2014] INT, [Dec-2014] INT, 
[Jan-2015] INT, [Feb-2015] INT, [Mar-2015] INT,
[Apr-2015] INT, [May-2015] INT, [Jun-2015] INT, [Jul-2015] INT, [Aug-2015] INT, [Sep-2015] INT, [Oct-2015] INT, [Nov-2015] INT, [Dec-2015] INT, 
[Jan-2016] INT, [Feb-2016] INT, [Mar-2016] INT, 
[Apr-2016] INT, [May-2016] INT, [Jun-2016] INT, [Jul-2016] INT, [Aug-2016] INT, [Sep-2016] INT, [Oct-2016] INT, [Nov-2016] INT, [Dec-2016] INT, 
[Jan-2017] INT, [Feb-2017] INT, [Mar-2017] INT, 
[Apr-2017] INT, [May-2017] INT, [Jun-2017] INT, [Jul-2017] INT, [Aug-2017] INT, [Sep-2017] INT, [Oct-2017] INT, [Nov-2017] INT, [Dec-2017] INT,
[Jan-2018] INT, [Feb-2018] INT, [Mar-2018] INT,
[Apr-2018] INT, [May-2018] INT, [Jun-2018] INT, [Jul-2018] INT, [Aug-2018] INT, [Sep-2018] INT, [Oct-2018] INT, [Nov-2018] INT, [Dec-2018] INT,
[Jan-2019] INT, [Feb-2019] INT, [Mar-2019] INT);

INSERT INTO #TEMPMONTH11
SELECT 'Type of Hotels', 'Total No of Hotels ( Room Nights)', 1,
SUM([Apr-2014]), SUM([May-2014]), SUM([Jun-2014]), SUM([Jul-2014]), SUM([Aug-2014]), SUM([Sep-2014]), SUM([Oct-2014]), SUM([Nov-2014]), SUM([Dec-2014]), 
SUM([Jan-2015]), SUM([Feb-2015]), SUM([Mar-2015]),
SUM([Apr-2015]), SUM([May-2015]), SUM([Jun-2015]), SUM([Jul-2015]), SUM([Aug-2015]), SUM([Sep-2015]), SUM([Oct-2015]), SUM([Nov-2015]), SUM([Dec-2015]), 
SUM([Jan-2016]), SUM([Feb-2016]), SUM([Mar-2016]), 
SUM([Apr-2016]), SUM([May-2016]), SUM([Jun-2016]), SUM([Jul-2016]), SUM([Aug-2016]), SUM([Sep-2016]), SUM([Oct-2016]), SUM([Nov-2016]), SUM([Dec-2016]), 
SUM([Jan-2017]), SUM([Feb-2017]), SUM([Mar-2017]), 
SUM([Apr-2017]), SUM([May-2017]), SUM([Jun-2017]), SUM([Jul-2017]), SUM([Aug-2017]), SUM([Sep-2017]), SUM([Oct-2017]), SUM([Nov-2017]), SUM([Dec-2017]), 
SUM([Jan-2018]), SUM([Feb-2018]), SUM([Mar-2018]),
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019]) 
FROM #TEMPDAILYREPORTCOUNT WHERE PropertyCategory IN ('External','C P P');
--
INSERT INTO #TEMPMONTH11
SELECT '', '     Chain Hotels ( Room Nights)', 2,
SUM([Apr-2014]), SUM([May-2014]), SUM([Jun-2014]), SUM([Jul-2014]), SUM([Aug-2014]), SUM([Sep-2014]), SUM([Oct-2014]), SUM([Nov-2014]), SUM([Dec-2014]), 
SUM([Jan-2015]), SUM([Feb-2015]), SUM([Mar-2015]),
SUM([Apr-2015]), SUM([May-2015]), SUM([Jun-2015]), SUM([Jul-2015]), SUM([Aug-2015]), SUM([Sep-2015]), SUM([Oct-2015]), SUM([Nov-2015]), SUM([Dec-2015]), 
SUM([Jan-2016]), SUM([Feb-2016]), SUM([Mar-2016]), 
SUM([Apr-2016]), SUM([May-2016]), SUM([Jun-2016]), SUM([Jul-2016]), SUM([Aug-2016]), SUM([Sep-2016]), SUM([Oct-2016]), SUM([Nov-2016]), SUM([Dec-2016]), 
SUM([Jan-2017]), SUM([Feb-2017]), SUM([Mar-2017]), 
SUM([Apr-2017]), SUM([May-2017]), SUM([Jun-2017]), SUM([Jul-2017]), SUM([Aug-2017]), SUM([Sep-2017]), SUM([Oct-2017]), SUM([Nov-2017]), SUM([Dec-2017]), 
SUM([Jan-2018]), SUM([Feb-2018]), SUM([Mar-2018]),
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019])
FROM #TDR T;

INSERT INTO #TEMPMONTH11
SELECT '', '', 3,
-[Apr-2014], -[May-2014], -[Jun-2014], -[Jul-2014], -[Aug-2014], -[Sep-2014], -[Oct-2014], -[Nov-2014], -[Dec-2014], -[Jan-2015], -[Feb-2015], -[Mar-2015],
-[Apr-2015], -[May-2015], -[Jun-2015], -[Jul-2015], -[Aug-2015], -[Sep-2015], -[Oct-2015], -[Nov-2015], -[Dec-2015], -[Jan-2016], -[Feb-2016], -[Mar-2016], 
-[Apr-2016], -[May-2016], -[Jun-2016], -[Jul-2016], -[Aug-2016], -[Sep-2016], -[Oct-2016], -[Nov-2016], -[Dec-2016], -[Jan-2017], -[Feb-2017], -[Mar-2017], 
-[Apr-2017], -[May-2017], -[Jun-2017], -[Jul-2017], -[Aug-2017], -[Sep-2017], -[Oct-2017], -[Nov-2017], -[Dec-2017], -[Jan-2018], -[Feb-2018], -[Mar-2018],
-[Apr-2018], -[May-2018], -[Jun-2018], -[Jul-2018], -[Aug-2018], -[Sep-2018], -[Oct-2018], -[Nov-2018], -[Dec-2018], -[Jan-2019], -[Feb-2019], -[Mar-2019]
FROM #TEMPMONTH11 T WHERE Flg = 2;
--
INSERT INTO #TEMPMONTH11
SELECT '', '     Non Chain Hotels ( Room Nights)', 4,
SUM([Apr-2014]), SUM([May-2014]), SUM([Jun-2014]), SUM([Jul-2014]), SUM([Aug-2014]), SUM([Sep-2014]), SUM([Oct-2014]), SUM([Nov-2014]), SUM([Dec-2014]), 
SUM([Jan-2015]), SUM([Feb-2015]), SUM([Mar-2015]),
SUM([Apr-2015]), SUM([May-2015]), SUM([Jun-2015]), SUM([Jul-2015]), SUM([Aug-2015]), SUM([Sep-2015]), SUM([Oct-2015]), SUM([Nov-2015]), SUM([Dec-2015]), 
SUM([Jan-2016]), SUM([Feb-2016]), SUM([Mar-2016]), 
SUM([Apr-2016]), SUM([May-2016]), SUM([Jun-2016]), SUM([Jul-2016]), SUM([Aug-2016]), SUM([Sep-2016]), SUM([Oct-2016]), SUM([Nov-2016]), SUM([Dec-2016]), 
SUM([Jan-2017]), SUM([Feb-2017]), SUM([Mar-2017]), 
SUM([Apr-2017]), SUM([May-2017]), SUM([Jun-2017]), SUM([Jul-2017]), SUM([Aug-2017]), SUM([Sep-2017]), SUM([Oct-2017]), SUM([Nov-2017]), SUM([Dec-2017]), 
SUM([Jan-2018]), SUM([Feb-2018]), SUM([Mar-2018]),
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019])
FROM #TEMPMONTH11 T WHERE Flg IN (1,3);
-- Table 2.1
/*SELECT Title1, Title2,
[Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
[Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
[Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019]
FROM #TEMPMONTH11
WHERE Flg IN (1,2,4)
ORDER BY Flg;*/
--
CREATE TABLE #TEMPMONTH12_WithMarkup(MasterPropertyId BIGINT,PropertyCategory NVARCHAR(100),cnt INT,MonthofBooking NVARCHAR(100),MarkUp DECIMAL(27,2));
INSERT INTO #TEMPMONTH12_WithMarkup(MasterPropertyId,PropertyCategory,cnt,MonthofBooking,MarkUp)
SELECT MasterPropertyId,PropertyCategory,COUNT(CalendarDate),asasd,MarkUp FROM #TEMP2
WHERE PropertyCategory IN ('External','C P P') 
GROUP BY MasterPropertyId,PropertyCategory,asasd,MarkUp,BookingId;
--
SELECT   MasterPropertyId,PropertyCategory,MarkUp,
         [Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
		 [Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
		 [Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
		 [Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
		 [Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019]
INTO #TEMPMONTH12
FROM #TEMPMONTH12_WithMarkup
PIVOT
(
       SUM(Cnt)
       FOR MonthofBooking IN 
	   ([Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
		[Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
		[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
		[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
		[Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019])
) AS P;
--
CREATE TABLE #TEMPMONTH13(Title1 NVARCHAR(100),Title2 NVARCHAR(100), Flg INT,
[Apr-2014] INT, [May-2014] INT, [Jun-2014] INT, [Jul-2014] INT, [Aug-2014] INT, [Sep-2014] INT, [Oct-2014] INT, [Nov-2014] INT, [Dec-2014] INT, 
[Jan-2015] INT, [Feb-2015] INT, [Mar-2015] INT,
[Apr-2015] INT, [May-2015] INT, [Jun-2015] INT, [Jul-2015] INT, [Aug-2015] INT, [Sep-2015] INT, [Oct-2015] INT, [Nov-2015] INT, [Dec-2015] INT, 
[Jan-2016] INT, [Feb-2016] INT, [Mar-2016] INT, 
[Apr-2016] INT, [May-2016] INT, [Jun-2016] INT, [Jul-2016] INT, [Aug-2016] INT, [Sep-2016] INT, [Oct-2016] INT, [Nov-2016] INT, [Dec-2016] INT, 
[Jan-2017] INT, [Feb-2017] INT, [Mar-2017] INT, 
[Apr-2017] INT, [May-2017] INT, [Jun-2017] INT, [Jul-2017] INT, [Aug-2017] INT, [Sep-2017] INT, [Oct-2017] INT, [Nov-2017] INT, [Dec-2017] INT,
[Jan-2018] INT, [Feb-2018] INT, [Mar-2018] INT,
[Apr-2018] INT, [May-2018] INT, [Jun-2018] INT, [Jul-2018] INT, [Aug-2018] INT, [Sep-2018] INT, [Oct-2018] INT, [Nov-2018] INT, [Dec-2018] INT,
[Jan-2019] INT, [Feb-2019] INT, [Mar-2019] INT);
--
INSERT INTO #TEMPMONTH13
SELECT 'Revenue Earning Rooms', 'With Commission ( Room Nights)', 1,
SUM(ISNULL([Apr-2014],0)), SUM(ISNULL([May-2014],0)), SUM(ISNULL([Jun-2014],0)), SUM(ISNULL([Jul-2014],0)), SUM(ISNULL([Aug-2014],0)), SUM(ISNULL([Sep-2014],0)), 
SUM(ISNULL([Oct-2014],0)), SUM(ISNULL([Nov-2014],0)), SUM(ISNULL([Dec-2014],0)), SUM(ISNULL([Jan-2015],0)), SUM(ISNULL([Feb-2015],0)), SUM(ISNULL([Mar-2015],0)), 
SUM(ISNULL([Apr-2015],0)), SUM(ISNULL([May-2015],0)), SUM(ISNULL([Jun-2015],0)), SUM(ISNULL([Jul-2015],0)), SUM(ISNULL([Aug-2015],0)), SUM(ISNULL([Sep-2015],0)), 
SUM(ISNULL([Oct-2015],0)), SUM(ISNULL([Nov-2015],0)), SUM(ISNULL([Dec-2015],0)), SUM(ISNULL([Jan-2016],0)), SUM(ISNULL([Feb-2016],0)), SUM(ISNULL([Mar-2016],0)), 
SUM(ISNULL([Apr-2016],0)), SUM(ISNULL([May-2016],0)), SUM(ISNULL([Jun-2016],0)), SUM(ISNULL([Jul-2016],0)), SUM(ISNULL([Aug-2016],0)), SUM(ISNULL([Sep-2016],0)), 
SUM(ISNULL([Oct-2016],0)), SUM(ISNULL([Nov-2016],0)), SUM(ISNULL([Dec-2016],0)), SUM(ISNULL([Jan-2017],0)), SUM(ISNULL([Feb-2017],0)), SUM(ISNULL([Mar-2017],0)), 
SUM(ISNULL([Apr-2017],0)), SUM(ISNULL([May-2017],0)), SUM(ISNULL([Jun-2017],0)), SUM(ISNULL([Jul-2017],0)), SUM(ISNULL([Aug-2017],0)), SUM(ISNULL([Sep-2017],0)), 
SUM(ISNULL([Oct-2017],0)), SUM(ISNULL([Nov-2017],0)), SUM(ISNULL([Dec-2017],0)), SUM(ISNULL([Jan-2018],0)), SUM(ISNULL([Feb-2018],0)), SUM(ISNULL([Mar-2018],0)),
SUM(ISNULL([Apr-2018],0)), SUM(ISNULL([May-2018],0)), SUM(ISNULL([Jun-2018],0)), SUM(ISNULL([Jul-2018],0)), SUM(ISNULL([Aug-2018],0)), SUM(ISNULL([Sep-2018],0)), 
SUM(ISNULL([Oct-2018],0)), SUM(ISNULL([Nov-2018],0)), SUM(ISNULL([Dec-2018],0)), SUM(ISNULL([Jan-2019],0)), SUM(ISNULL([Feb-2019],0)), SUM(ISNULL([Mar-2019],0))
FROM #TEMPMONTH12
WHERE MarkUp != 0;
--
INSERT INTO #TEMPMONTH13
SELECT '', 'Without Commission ( Room Nights)', 2,
SUM(ISNULL([Apr-2014],0)), SUM(ISNULL([May-2014],0)), SUM(ISNULL([Jun-2014],0)), SUM(ISNULL([Jul-2014],0)), SUM(ISNULL([Aug-2014],0)), SUM(ISNULL([Sep-2014],0)), 
SUM(ISNULL([Oct-2014],0)), SUM(ISNULL([Nov-2014],0)), SUM(ISNULL([Dec-2014],0)), SUM(ISNULL([Jan-2015],0)), SUM(ISNULL([Feb-2015],0)), SUM(ISNULL([Mar-2015],0)), 
SUM(ISNULL([Apr-2015],0)), SUM(ISNULL([May-2015],0)), SUM(ISNULL([Jun-2015],0)), SUM(ISNULL([Jul-2015],0)), SUM(ISNULL([Aug-2015],0)), SUM(ISNULL([Sep-2015],0)), 
SUM(ISNULL([Oct-2015],0)), SUM(ISNULL([Nov-2015],0)), SUM(ISNULL([Dec-2015],0)), SUM(ISNULL([Jan-2016],0)), SUM(ISNULL([Feb-2016],0)), SUM(ISNULL([Mar-2016],0)), 
SUM(ISNULL([Apr-2016],0)), SUM(ISNULL([May-2016],0)), SUM(ISNULL([Jun-2016],0)), SUM(ISNULL([Jul-2016],0)), SUM(ISNULL([Aug-2016],0)), SUM(ISNULL([Sep-2016],0)), 
SUM(ISNULL([Oct-2016],0)), SUM(ISNULL([Nov-2016],0)), SUM(ISNULL([Dec-2016],0)), SUM(ISNULL([Jan-2017],0)), SUM(ISNULL([Feb-2017],0)), SUM(ISNULL([Mar-2017],0)), 
SUM(ISNULL([Apr-2017],0)), SUM(ISNULL([May-2017],0)), SUM(ISNULL([Jun-2017],0)), SUM(ISNULL([Jul-2017],0)), SUM(ISNULL([Aug-2017],0)), SUM(ISNULL([Sep-2017],0)), 
SUM(ISNULL([Oct-2017],0)), SUM(ISNULL([Nov-2017],0)), SUM(ISNULL([Dec-2017],0)), SUM(ISNULL([Jan-2018],0)), SUM(ISNULL([Feb-2018],0)), SUM(ISNULL([Mar-2018],0)),
SUM(ISNULL([Apr-2018],0)), SUM(ISNULL([May-2018],0)), SUM(ISNULL([Jun-2018],0)), SUM(ISNULL([Jul-2018],0)), SUM(ISNULL([Aug-2018],0)), SUM(ISNULL([Sep-2018],0)), 
SUM(ISNULL([Oct-2018],0)), SUM(ISNULL([Nov-2018],0)), SUM(ISNULL([Dec-2018],0)), SUM(ISNULL([Jan-2019],0)), SUM(ISNULL([Feb-2019],0)), SUM(ISNULL([Mar-2019],0))
FROM #TEMPMONTH12
WHERE MarkUp = 0;
-- Table 2.2
/*SELECT Title1, Title2,
[Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
[Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
[Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019]
FROM #TEMPMONTH13
WHERE Flg IN (1,2)
ORDER BY Flg;*/
--
INSERT INTO #TEMPMONTH13
SELECT 'Client Preferred Property', 'Total (Room Nights)', 3,
SUM(ISNULL([Apr-2014],0)), SUM(ISNULL([May-2014],0)), SUM(ISNULL([Jun-2014],0)), SUM(ISNULL([Jul-2014],0)), SUM(ISNULL([Aug-2014],0)), SUM(ISNULL([Sep-2014],0)), 
SUM(ISNULL([Oct-2014],0)), SUM(ISNULL([Nov-2014],0)), SUM(ISNULL([Dec-2014],0)), SUM(ISNULL([Jan-2015],0)), SUM(ISNULL([Feb-2015],0)), SUM(ISNULL([Mar-2015],0)), 
SUM(ISNULL([Apr-2015],0)), SUM(ISNULL([May-2015],0)), SUM(ISNULL([Jun-2015],0)), SUM(ISNULL([Jul-2015],0)), SUM(ISNULL([Aug-2015],0)), SUM(ISNULL([Sep-2015],0)), 
SUM(ISNULL([Oct-2015],0)), SUM(ISNULL([Nov-2015],0)), SUM(ISNULL([Dec-2015],0)), SUM(ISNULL([Jan-2016],0)), SUM(ISNULL([Feb-2016],0)), SUM(ISNULL([Mar-2016],0)), 
SUM(ISNULL([Apr-2016],0)), SUM(ISNULL([May-2016],0)), SUM(ISNULL([Jun-2016],0)), SUM(ISNULL([Jul-2016],0)), SUM(ISNULL([Aug-2016],0)), SUM(ISNULL([Sep-2016],0)), 
SUM(ISNULL([Oct-2016],0)), SUM(ISNULL([Nov-2016],0)), SUM(ISNULL([Dec-2016],0)), SUM(ISNULL([Jan-2017],0)), SUM(ISNULL([Feb-2017],0)), SUM(ISNULL([Mar-2017],0)), 
SUM(ISNULL([Apr-2017],0)), SUM(ISNULL([May-2017],0)), SUM(ISNULL([Jun-2017],0)), SUM(ISNULL([Jul-2017],0)), SUM(ISNULL([Aug-2017],0)), SUM(ISNULL([Sep-2017],0)), 
SUM(ISNULL([Oct-2017],0)), SUM(ISNULL([Nov-2017],0)), SUM(ISNULL([Dec-2017],0)), SUM(ISNULL([Jan-2018],0)), SUM(ISNULL([Feb-2018],0)), SUM(ISNULL([Mar-2018],0)),
SUM(ISNULL([Apr-2018],0)), SUM(ISNULL([May-2018],0)), SUM(ISNULL([Jun-2018],0)), SUM(ISNULL([Jul-2018],0)), SUM(ISNULL([Aug-2018],0)), SUM(ISNULL([Sep-2018],0)), 
SUM(ISNULL([Oct-2018],0)), SUM(ISNULL([Nov-2018],0)), SUM(ISNULL([Dec-2018],0)), SUM(ISNULL([Jan-2019],0)), SUM(ISNULL([Feb-2019],0)), SUM(ISNULL([Mar-2019],0))
FROM #TEMPMONTH12
WHERE PropertyCategory = 'C P P';
--
INSERT INTO #TEMPMONTH13
SELECT '', '     With Commission ( Room Nights)', 4,
SUM(ISNULL([Apr-2014],0)), SUM(ISNULL([May-2014],0)), SUM(ISNULL([Jun-2014],0)), SUM(ISNULL([Jul-2014],0)), SUM(ISNULL([Aug-2014],0)), SUM(ISNULL([Sep-2014],0)), 
SUM(ISNULL([Oct-2014],0)), SUM(ISNULL([Nov-2014],0)), SUM(ISNULL([Dec-2014],0)), SUM(ISNULL([Jan-2015],0)), SUM(ISNULL([Feb-2015],0)), SUM(ISNULL([Mar-2015],0)), 
SUM(ISNULL([Apr-2015],0)), SUM(ISNULL([May-2015],0)), SUM(ISNULL([Jun-2015],0)), SUM(ISNULL([Jul-2015],0)), SUM(ISNULL([Aug-2015],0)), SUM(ISNULL([Sep-2015],0)), 
SUM(ISNULL([Oct-2015],0)), SUM(ISNULL([Nov-2015],0)), SUM(ISNULL([Dec-2015],0)), SUM(ISNULL([Jan-2016],0)), SUM(ISNULL([Feb-2016],0)), SUM(ISNULL([Mar-2016],0)), 
SUM(ISNULL([Apr-2016],0)), SUM(ISNULL([May-2016],0)), SUM(ISNULL([Jun-2016],0)), SUM(ISNULL([Jul-2016],0)), SUM(ISNULL([Aug-2016],0)), SUM(ISNULL([Sep-2016],0)), 
SUM(ISNULL([Oct-2016],0)), SUM(ISNULL([Nov-2016],0)), SUM(ISNULL([Dec-2016],0)), SUM(ISNULL([Jan-2017],0)), SUM(ISNULL([Feb-2017],0)), SUM(ISNULL([Mar-2017],0)), 
SUM(ISNULL([Apr-2017],0)), SUM(ISNULL([May-2017],0)), SUM(ISNULL([Jun-2017],0)), SUM(ISNULL([Jul-2017],0)), SUM(ISNULL([Aug-2017],0)), SUM(ISNULL([Sep-2017],0)), 
SUM(ISNULL([Oct-2017],0)), SUM(ISNULL([Nov-2017],0)), SUM(ISNULL([Dec-2017],0)), SUM(ISNULL([Jan-2018],0)), SUM(ISNULL([Feb-2018],0)), SUM(ISNULL([Mar-2018],0)),
SUM(ISNULL([Apr-2018],0)), SUM(ISNULL([May-2018],0)), SUM(ISNULL([Jun-2018],0)), SUM(ISNULL([Jul-2018],0)), SUM(ISNULL([Aug-2018],0)), SUM(ISNULL([Sep-2018],0)), 
SUM(ISNULL([Oct-2018],0)), SUM(ISNULL([Nov-2018],0)), SUM(ISNULL([Dec-2018],0)), SUM(ISNULL([Jan-2019],0)), SUM(ISNULL([Feb-2019],0)), SUM(ISNULL([Mar-2019],0))
FROM #TEMPMONTH12
WHERE PropertyCategory = 'C P P' AND MarkUp != 0;
--
INSERT INTO #TEMPMONTH13
SELECT '', '     Without Commission ( Room Nights)', 5,
SUM(ISNULL([Apr-2014],0)), SUM(ISNULL([May-2014],0)), SUM(ISNULL([Jun-2014],0)), SUM(ISNULL([Jul-2014],0)), SUM(ISNULL([Aug-2014],0)), SUM(ISNULL([Sep-2014],0)), 
SUM(ISNULL([Oct-2014],0)), SUM(ISNULL([Nov-2014],0)), SUM(ISNULL([Dec-2014],0)), SUM(ISNULL([Jan-2015],0)), SUM(ISNULL([Feb-2015],0)), SUM(ISNULL([Mar-2015],0)), 
SUM(ISNULL([Apr-2015],0)), SUM(ISNULL([May-2015],0)), SUM(ISNULL([Jun-2015],0)), SUM(ISNULL([Jul-2015],0)), SUM(ISNULL([Aug-2015],0)), SUM(ISNULL([Sep-2015],0)), 
SUM(ISNULL([Oct-2015],0)), SUM(ISNULL([Nov-2015],0)), SUM(ISNULL([Dec-2015],0)), SUM(ISNULL([Jan-2016],0)), SUM(ISNULL([Feb-2016],0)), SUM(ISNULL([Mar-2016],0)), 
SUM(ISNULL([Apr-2016],0)), SUM(ISNULL([May-2016],0)), SUM(ISNULL([Jun-2016],0)), SUM(ISNULL([Jul-2016],0)), SUM(ISNULL([Aug-2016],0)), SUM(ISNULL([Sep-2016],0)), 
SUM(ISNULL([Oct-2016],0)), SUM(ISNULL([Nov-2016],0)), SUM(ISNULL([Dec-2016],0)), SUM(ISNULL([Jan-2017],0)), SUM(ISNULL([Feb-2017],0)), SUM(ISNULL([Mar-2017],0)), 
SUM(ISNULL([Apr-2017],0)), SUM(ISNULL([May-2017],0)), SUM(ISNULL([Jun-2017],0)), SUM(ISNULL([Jul-2017],0)), SUM(ISNULL([Aug-2017],0)), SUM(ISNULL([Sep-2017],0)), 
SUM(ISNULL([Oct-2017],0)), SUM(ISNULL([Nov-2017],0)), SUM(ISNULL([Dec-2017],0)), SUM(ISNULL([Jan-2018],0)), SUM(ISNULL([Feb-2018],0)), SUM(ISNULL([Mar-2018],0)),
SUM(ISNULL([Apr-2018],0)), SUM(ISNULL([May-2018],0)), SUM(ISNULL([Jun-2018],0)), SUM(ISNULL([Jul-2018],0)), SUM(ISNULL([Aug-2018],0)), SUM(ISNULL([Sep-2018],0)), 
SUM(ISNULL([Oct-2018],0)), SUM(ISNULL([Nov-2018],0)), SUM(ISNULL([Dec-2018],0)), SUM(ISNULL([Jan-2019],0)), SUM(ISNULL([Feb-2019],0)), SUM(ISNULL([Mar-2019],0))
FROM #TEMPMONTH12
WHERE PropertyCategory = 'C P P' AND MarkUp = 0;
-- Table 2.3
/*SELECT Title1, Title2,
[Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
[Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
[Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019]
FROM #TEMPMONTH13
WHERE Flg IN (3, 4, 5)
ORDER BY Flg;*/
--
INSERT INTO #TEMPMONTH13
SELECT 'HB Partners Property', 'Total  (Room Nights)', 6,
SUM(ISNULL([Apr-2014],0)), SUM(ISNULL([May-2014],0)), SUM(ISNULL([Jun-2014],0)), SUM(ISNULL([Jul-2014],0)), SUM(ISNULL([Aug-2014],0)), SUM(ISNULL([Sep-2014],0)), 
SUM(ISNULL([Oct-2014],0)), SUM(ISNULL([Nov-2014],0)), SUM(ISNULL([Dec-2014],0)), SUM(ISNULL([Jan-2015],0)), SUM(ISNULL([Feb-2015],0)), SUM(ISNULL([Mar-2015],0)), 
SUM(ISNULL([Apr-2015],0)), SUM(ISNULL([May-2015],0)), SUM(ISNULL([Jun-2015],0)), SUM(ISNULL([Jul-2015],0)), SUM(ISNULL([Aug-2015],0)), SUM(ISNULL([Sep-2015],0)), 
SUM(ISNULL([Oct-2015],0)), SUM(ISNULL([Nov-2015],0)), SUM(ISNULL([Dec-2015],0)), SUM(ISNULL([Jan-2016],0)), SUM(ISNULL([Feb-2016],0)), SUM(ISNULL([Mar-2016],0)), 
SUM(ISNULL([Apr-2016],0)), SUM(ISNULL([May-2016],0)), SUM(ISNULL([Jun-2016],0)), SUM(ISNULL([Jul-2016],0)), SUM(ISNULL([Aug-2016],0)), SUM(ISNULL([Sep-2016],0)), 
SUM(ISNULL([Oct-2016],0)), SUM(ISNULL([Nov-2016],0)), SUM(ISNULL([Dec-2016],0)), SUM(ISNULL([Jan-2017],0)), SUM(ISNULL([Feb-2017],0)), SUM(ISNULL([Mar-2017],0)), 
SUM(ISNULL([Apr-2017],0)), SUM(ISNULL([May-2017],0)), SUM(ISNULL([Jun-2017],0)), SUM(ISNULL([Jul-2017],0)), SUM(ISNULL([Aug-2017],0)), SUM(ISNULL([Sep-2017],0)), 
SUM(ISNULL([Oct-2017],0)), SUM(ISNULL([Nov-2017],0)), SUM(ISNULL([Dec-2017],0)), SUM(ISNULL([Jan-2018],0)), SUM(ISNULL([Feb-2018],0)), SUM(ISNULL([Mar-2018],0)),
SUM(ISNULL([Apr-2018],0)), SUM(ISNULL([May-2018],0)), SUM(ISNULL([Jun-2018],0)), SUM(ISNULL([Jul-2018],0)), SUM(ISNULL([Aug-2018],0)), SUM(ISNULL([Sep-2018],0)), 
SUM(ISNULL([Oct-2018],0)), SUM(ISNULL([Nov-2018],0)), SUM(ISNULL([Dec-2018],0)), SUM(ISNULL([Jan-2019],0)), SUM(ISNULL([Feb-2019],0)), SUM(ISNULL([Mar-2019],0))
FROM #TEMPMONTH12
WHERE PropertyCategory = 'External';
--
INSERT INTO #TEMPMONTH13
SELECT '', '     Commissionable Room Nights HB Property', 7,
SUM(ISNULL([Apr-2014],0)), SUM(ISNULL([May-2014],0)), SUM(ISNULL([Jun-2014],0)), SUM(ISNULL([Jul-2014],0)), SUM(ISNULL([Aug-2014],0)), SUM(ISNULL([Sep-2014],0)), 
SUM(ISNULL([Oct-2014],0)), SUM(ISNULL([Nov-2014],0)), SUM(ISNULL([Dec-2014],0)), SUM(ISNULL([Jan-2015],0)), SUM(ISNULL([Feb-2015],0)), SUM(ISNULL([Mar-2015],0)), 
SUM(ISNULL([Apr-2015],0)), SUM(ISNULL([May-2015],0)), SUM(ISNULL([Jun-2015],0)), SUM(ISNULL([Jul-2015],0)), SUM(ISNULL([Aug-2015],0)), SUM(ISNULL([Sep-2015],0)), 
SUM(ISNULL([Oct-2015],0)), SUM(ISNULL([Nov-2015],0)), SUM(ISNULL([Dec-2015],0)), SUM(ISNULL([Jan-2016],0)), SUM(ISNULL([Feb-2016],0)), SUM(ISNULL([Mar-2016],0)), 
SUM(ISNULL([Apr-2016],0)), SUM(ISNULL([May-2016],0)), SUM(ISNULL([Jun-2016],0)), SUM(ISNULL([Jul-2016],0)), SUM(ISNULL([Aug-2016],0)), SUM(ISNULL([Sep-2016],0)), 
SUM(ISNULL([Oct-2016],0)), SUM(ISNULL([Nov-2016],0)), SUM(ISNULL([Dec-2016],0)), SUM(ISNULL([Jan-2017],0)), SUM(ISNULL([Feb-2017],0)), SUM(ISNULL([Mar-2017],0)), 
SUM(ISNULL([Apr-2017],0)), SUM(ISNULL([May-2017],0)), SUM(ISNULL([Jun-2017],0)), SUM(ISNULL([Jul-2017],0)), SUM(ISNULL([Aug-2017],0)), SUM(ISNULL([Sep-2017],0)), 
SUM(ISNULL([Oct-2017],0)), SUM(ISNULL([Nov-2017],0)), SUM(ISNULL([Dec-2017],0)), SUM(ISNULL([Jan-2018],0)), SUM(ISNULL([Feb-2018],0)), SUM(ISNULL([Mar-2018],0)),
SUM(ISNULL([Apr-2018],0)), SUM(ISNULL([May-2018],0)), SUM(ISNULL([Jun-2018],0)), SUM(ISNULL([Jul-2018],0)), SUM(ISNULL([Aug-2018],0)), SUM(ISNULL([Sep-2018],0)), 
SUM(ISNULL([Oct-2018],0)), SUM(ISNULL([Nov-2018],0)), SUM(ISNULL([Dec-2018],0)), SUM(ISNULL([Jan-2019],0)), SUM(ISNULL([Feb-2019],0)), SUM(ISNULL([Mar-2019],0))
FROM #TEMPMONTH12
WHERE PropertyCategory = 'External' AND MarkUp != 0;
--
INSERT INTO #TEMPMONTH13
SELECT '', '     Non Commissionable Room Nights HB Property', 8,
SUM(ISNULL([Apr-2014],0)), SUM(ISNULL([May-2014],0)), SUM(ISNULL([Jun-2014],0)), SUM(ISNULL([Jul-2014],0)), SUM(ISNULL([Aug-2014],0)), SUM(ISNULL([Sep-2014],0)), 
SUM(ISNULL([Oct-2014],0)), SUM(ISNULL([Nov-2014],0)), SUM(ISNULL([Dec-2014],0)), SUM(ISNULL([Jan-2015],0)), SUM(ISNULL([Feb-2015],0)), SUM(ISNULL([Mar-2015],0)), 
SUM(ISNULL([Apr-2015],0)), SUM(ISNULL([May-2015],0)), SUM(ISNULL([Jun-2015],0)), SUM(ISNULL([Jul-2015],0)), SUM(ISNULL([Aug-2015],0)), SUM(ISNULL([Sep-2015],0)), 
SUM(ISNULL([Oct-2015],0)), SUM(ISNULL([Nov-2015],0)), SUM(ISNULL([Dec-2015],0)), SUM(ISNULL([Jan-2016],0)), SUM(ISNULL([Feb-2016],0)), SUM(ISNULL([Mar-2016],0)), 
SUM(ISNULL([Apr-2016],0)), SUM(ISNULL([May-2016],0)), SUM(ISNULL([Jun-2016],0)), SUM(ISNULL([Jul-2016],0)), SUM(ISNULL([Aug-2016],0)), SUM(ISNULL([Sep-2016],0)), 
SUM(ISNULL([Oct-2016],0)), SUM(ISNULL([Nov-2016],0)), SUM(ISNULL([Dec-2016],0)), SUM(ISNULL([Jan-2017],0)), SUM(ISNULL([Feb-2017],0)), SUM(ISNULL([Mar-2017],0)), 
SUM(ISNULL([Apr-2017],0)), SUM(ISNULL([May-2017],0)), SUM(ISNULL([Jun-2017],0)), SUM(ISNULL([Jul-2017],0)), SUM(ISNULL([Aug-2017],0)), SUM(ISNULL([Sep-2017],0)), 
SUM(ISNULL([Oct-2017],0)), SUM(ISNULL([Nov-2017],0)), SUM(ISNULL([Dec-2017],0)), SUM(ISNULL([Jan-2018],0)), SUM(ISNULL([Feb-2018],0)), SUM(ISNULL([Mar-2018],0)),
SUM(ISNULL([Apr-2018],0)), SUM(ISNULL([May-2018],0)), SUM(ISNULL([Jun-2018],0)), SUM(ISNULL([Jul-2018],0)), SUM(ISNULL([Aug-2018],0)), SUM(ISNULL([Sep-2018],0)), 
SUM(ISNULL([Oct-2018],0)), SUM(ISNULL([Nov-2018],0)), SUM(ISNULL([Dec-2018],0)), SUM(ISNULL([Jan-2019],0)), SUM(ISNULL([Feb-2019],0)), SUM(ISNULL([Mar-2019],0))
FROM #TEMPMONTH12
WHERE PropertyCategory = 'External' AND MarkUp = 0;
-- Table 2.4
/*SELECT Title1, Title2,
[Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
[Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
[Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019]
FROM #TEMPMONTH13
WHERE Flg IN (6, 7, 8)
ORDER BY Flg;*/
--
CREATE TABLE #TEMPMONTH14(MasterPropertyId BIGINT,PropertyCategory NVARCHAR(100),MasterClientId BIGINT,MonthofBooking NVARCHAR(100),Tariff DECIMAL(27,2),Markup DECIMAL(27,2));
INSERT INTO #TEMPMONTH14(MasterPropertyId,PropertyCategory,MasterClientId,MonthofBooking,Tariff,Markup)
SELECT MasterPropertyId,PropertyCategory,MasterClientId,asasd,SUM(Tariff),MarkUp FROM #TEMP2
WHERE PropertyCategory IN ('External', 'C P P') 
GROUP BY MasterPropertyId,PropertyCategory,MasterClientId,asasd,MarkUp,BookingId;
--
SELECT   MasterPropertyId,PropertyCategory,MasterClientId,Markup,
         [Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
		 [Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
		 [Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
		 [Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
		 [Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019]
INTO #TEMPMONTH15
FROM #TEMPMONTH14
PIVOT
(
       SUM(Tariff)
       FOR MonthofBooking IN 
	   ([Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
		[Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
		[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
		[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
		[Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019])
) AS P;
--
CREATE TABLE #TEMPMONTH16(MasterPropertyId BIGINT,PropertyCategory NVARCHAR(100),MasterClientId BIGINT,Markup DECIMAL(27,2),
[Apr-2014] INT, [May-2014] INT, [Jun-2014] INT, [Jul-2014] INT, [Aug-2014] INT, [Sep-2014] INT, [Oct-2014] INT, [Nov-2014] INT, [Dec-2014] INT, 
[Jan-2015] INT, [Feb-2015] INT, [Mar-2015] INT,
[Apr-2015] INT, [May-2015] INT, [Jun-2015] INT, [Jul-2015] INT, [Aug-2015] INT, [Sep-2015] INT, [Oct-2015] INT, [Nov-2015] INT, [Dec-2015] INT, 
[Jan-2016] INT, [Feb-2016] INT, [Mar-2016] INT, 
[Apr-2016] INT, [May-2016] INT, [Jun-2016] INT, [Jul-2016] INT, [Aug-2016] INT, [Sep-2016] INT, [Oct-2016] INT, [Nov-2016] INT, [Dec-2016] INT, 
[Jan-2017] INT, [Feb-2017] INT, [Mar-2017] INT, 
[Apr-2017] INT, [May-2017] INT, [Jun-2017] INT, [Jul-2017] INT, [Aug-2017] INT, [Sep-2017] INT, [Oct-2017] INT, [Nov-2017] INT, [Dec-2017] INT,
[Jan-2018] INT, [Feb-2018] INT, [Mar-2018] INT,
[Apr-2018] INT, [May-2018] INT, [Jun-2018] INT, [Jul-2018] INT, [Aug-2018] INT, [Sep-2018] INT, [Oct-2018] INT, [Nov-2018] INT, [Dec-2018] INT,
[Jan-2019] INT, [Feb-2019] INT, [Mar-2019] INT);
---
INSERT INTO #TEMPMONTH16
SELECT MasterPropertyId,PropertyCategory,MasterClientId,Markup,
ISNULL([Apr-2014],0), ISNULL([May-2014],0), ISNULL([Jun-2014],0), ISNULL([Jul-2014],0), ISNULL([Aug-2014],0), ISNULL([Sep-2014],0), ISNULL([Oct-2014],0), 
ISNULL([Nov-2014],0), ISNULL([Dec-2014],0), ISNULL([Jan-2015],0), ISNULL([Feb-2015],0), ISNULL([Mar-2015],0), 
ISNULL([Apr-2015],0), ISNULL([May-2015],0), ISNULL([Jun-2015],0), ISNULL([Jul-2015],0), ISNULL([Aug-2015],0), ISNULL([Sep-2015],0), ISNULL([Oct-2015],0), 
ISNULL([Nov-2015],0), ISNULL([Dec-2015],0), ISNULL([Jan-2016],0), ISNULL([Feb-2016],0), ISNULL([Mar-2016],0), 
ISNULL([Apr-2016],0), ISNULL([May-2016],0), ISNULL([Jun-2016],0), ISNULL([Jul-2016],0), ISNULL([Aug-2016],0), ISNULL([Sep-2016],0), ISNULL([Oct-2016],0), 
ISNULL([Nov-2016],0), ISNULL([Dec-2016],0), ISNULL([Jan-2017],0), ISNULL([Feb-2017],0), ISNULL([Mar-2017],0), 
ISNULL([Apr-2017],0), ISNULL([May-2017],0), ISNULL([Jun-2017],0), ISNULL([Jul-2017],0), ISNULL([Aug-2017],0), ISNULL([Sep-2017],0), ISNULL([Oct-2017],0), 
ISNULL([Nov-2017],0), ISNULL([Dec-2017],0), ISNULL([Jan-2018],0), ISNULL([Feb-2018],0), ISNULL([Mar-2018],0),
ISNULL([Apr-2018],0), ISNULL([May-2018],0), ISNULL([Jun-2018],0), ISNULL([Jul-2018],0), ISNULL([Aug-2018],0), ISNULL([Sep-2018],0), ISNULL([Oct-2018],0), 
ISNULL([Nov-2018],0), ISNULL([Dec-2018],0), ISNULL([Jan-2019],0), ISNULL([Feb-2019],0), ISNULL([Mar-2019],0)  from #TEMPMONTH15;
--
CREATE TABLE #TEMPMONTH117(Title1 NVARCHAR(100),Title2 NVARCHAR(100), Flg INT,
[Apr-2014] INT, [May-2014] INT, [Jun-2014] INT, [Jul-2014] INT, [Aug-2014] INT, [Sep-2014] INT, [Oct-2014] INT, [Nov-2014] INT, [Dec-2014] INT, 
[Jan-2015] INT, [Feb-2015] INT, [Mar-2015] INT,
[Apr-2015] INT, [May-2015] INT, [Jun-2015] INT, [Jul-2015] INT, [Aug-2015] INT, [Sep-2015] INT, [Oct-2015] INT, [Nov-2015] INT, [Dec-2015] INT, 
[Jan-2016] INT, [Feb-2016] INT, [Mar-2016] INT, 
[Apr-2016] INT, [May-2016] INT, [Jun-2016] INT, [Jul-2016] INT, [Aug-2016] INT, [Sep-2016] INT, [Oct-2016] INT, [Nov-2016] INT, [Dec-2016] INT, 
[Jan-2017] INT, [Feb-2017] INT, [Mar-2017] INT, 
[Apr-2017] INT, [May-2017] INT, [Jun-2017] INT, [Jul-2017] INT, [Aug-2017] INT, [Sep-2017] INT, [Oct-2017] INT, [Nov-2017] INT, [Dec-2017] INT,
[Jan-2018] INT, [Feb-2018] INT, [Mar-2018] INT,
[Apr-2018] INT, [May-2018] INT, [Jun-2018] INT, [Jul-2018] INT, [Aug-2018] INT, [Sep-2018] INT, [Oct-2018] INT, [Nov-2018] INT, [Dec-2018] INT,
[Jan-2019] INT, [Feb-2019] INT, [Mar-2019] INT);
--
INSERT INTO #TEMPMONTH117
SELECT 'Chain Vs Non Chain', 'Total No of Hotels ( Value in Rs Lacs )', 1,
ROUND(SUM([Apr-2014]) * 0.00001, 0), ROUND(SUM([May-2014]) * 0.00001, 0), ROUND(SUM([Jun-2014]) * 0.00001, 0), ROUND(SUM([Jul-2014]) * 0.00001, 0), 
ROUND(SUM([Aug-2014]) * 0.00001, 0), ROUND(SUM([Sep-2014]) * 0.00001, 0), ROUND(SUM([Oct-2014]) * 0.00001, 0), ROUND(SUM([Nov-2014]) * 0.00001, 0), 
ROUND(SUM([Dec-2014]) * 0.00001, 0), ROUND(SUM([Jan-2015]) * 0.00001, 0), ROUND(SUM([Feb-2015]) * 0.00001, 0), ROUND(SUM([Mar-2015]) * 0.00001, 0),

ROUND(SUM([Apr-2015]) * 0.00001, 0), ROUND(SUM([May-2015]) * 0.00001, 0), ROUND(SUM([Jun-2015]) * 0.00001, 0), ROUND(SUM([Jul-2015]) * 0.00001, 0), 
ROUND(SUM([Aug-2015]) * 0.00001, 0), ROUND(SUM([Sep-2015]) * 0.00001, 0), ROUND(SUM([Oct-2015]) * 0.00001, 0), ROUND(SUM([Nov-2015]) * 0.00001, 0), 
ROUND(SUM([Dec-2015]) * 0.00001, 0), ROUND(SUM([Jan-2016]) * 0.00001, 0), ROUND(SUM([Feb-2016]) * 0.00001, 0), ROUND(SUM([Mar-2016]) * 0.00001, 0),
 
ROUND(SUM([Apr-2016]) * 0.00001, 0), ROUND(SUM([May-2016]) * 0.00001, 0), ROUND(SUM([Jun-2016]) * 0.00001, 0), ROUND(SUM([Jul-2016]) * 0.00001, 0), 
ROUND(SUM([Aug-2016]) * 0.00001, 0), ROUND(SUM([Sep-2016]) * 0.00001, 0), ROUND(SUM([Oct-2016]) * 0.00001, 0), ROUND(SUM([Nov-2016]) * 0.00001, 0), 
ROUND(SUM([Dec-2016]) * 0.00001, 0), ROUND(SUM([Jan-2017]) * 0.00001, 0), ROUND(SUM([Feb-2017]) * 0.00001, 0), ROUND(SUM([Mar-2017]) * 0.00001, 0), 

ROUND(SUM([Apr-2017]) * 0.00001, 0), ROUND(SUM([May-2017]) * 0.00001, 0), ROUND(SUM([Jun-2017]) * 0.00001, 0), ROUND(SUM([Jul-2017]) * 0.00001, 0), 
ROUND(SUM([Aug-2017]) * 0.00001, 0), ROUND(SUM([Sep-2017]) * 0.00001, 0), ROUND(SUM([Oct-2017]) * 0.00001, 0), ROUND(SUM([Nov-2017]) * 0.00001, 0), 
ROUND(SUM([Dec-2017]) * 0.00001, 0), ROUND(SUM([Jan-2018]) * 0.00001, 0), ROUND(SUM([Feb-2018]) * 0.00001, 0), ROUND(SUM([Mar-2018]) * 0.00001, 0),

ROUND(SUM([Apr-2018]) * 0.00001, 0), ROUND(SUM([May-2018]) * 0.00001, 0), ROUND(SUM([Jun-2018]) * 0.00001, 0), ROUND(SUM([Jul-2018]) * 0.00001, 0), 
ROUND(SUM([Aug-2018]) * 0.00001, 0), ROUND(SUM([Sep-2018]) * 0.00001, 0), ROUND(SUM([Oct-2018]) * 0.00001, 0), ROUND(SUM([Nov-2018]) * 0.00001, 0), 
ROUND(SUM([Dec-2018]) * 0.00001, 0), ROUND(SUM([Jan-2019]) * 0.00001, 0), ROUND(SUM([Feb-2019]) * 0.00001, 0), ROUND(SUM([Mar-2019]) * 0.00001, 0)
FROM #TEMPMONTH16;
--
INSERT INTO #TEMPMONTH117
SELECT '', '     Chain Hotels ( Value in Rs Lacs )', 2,
ROUND(SUM([Apr-2014]) * 0.00001, 0), ROUND(SUM([May-2014]) * 0.00001, 0), ROUND(SUM([Jun-2014]) * 0.00001, 0), ROUND(SUM([Jul-2014]) * 0.00001, 0), 
ROUND(SUM([Aug-2014]) * 0.00001, 0), ROUND(SUM([Sep-2014]) * 0.00001, 0), ROUND(SUM([Oct-2014]) * 0.00001, 0), ROUND(SUM([Nov-2014]) * 0.00001, 0), 
ROUND(SUM([Dec-2014]) * 0.00001, 0), ROUND(SUM([Jan-2015]) * 0.00001, 0), ROUND(SUM([Feb-2015]) * 0.00001, 0), ROUND(SUM([Mar-2015]) * 0.00001, 0),

ROUND(SUM([Apr-2015]) * 0.00001, 0), ROUND(SUM([May-2015]) * 0.00001, 0), ROUND(SUM([Jun-2015]) * 0.00001, 0), ROUND(SUM([Jul-2015]) * 0.00001, 0), 
ROUND(SUM([Aug-2015]) * 0.00001, 0), ROUND(SUM([Sep-2015]) * 0.00001, 0), ROUND(SUM([Oct-2015]) * 0.00001, 0), ROUND(SUM([Nov-2015]) * 0.00001, 0), 
ROUND(SUM([Dec-2015]) * 0.00001, 0), ROUND(SUM([Jan-2016]) * 0.00001, 0), ROUND(SUM([Feb-2016]) * 0.00001, 0), ROUND(SUM([Mar-2016]) * 0.00001, 0),
 
ROUND(SUM([Apr-2016]) * 0.00001, 0), ROUND(SUM([May-2016]) * 0.00001, 0), ROUND(SUM([Jun-2016]) * 0.00001, 0), ROUND(SUM([Jul-2016]) * 0.00001, 0), 
ROUND(SUM([Aug-2016]) * 0.00001, 0), ROUND(SUM([Sep-2016]) * 0.00001, 0), ROUND(SUM([Oct-2016]) * 0.00001, 0), ROUND(SUM([Nov-2016]) * 0.00001, 0), 
ROUND(SUM([Dec-2016]) * 0.00001, 0), ROUND(SUM([Jan-2017]) * 0.00001, 0), ROUND(SUM([Feb-2017]) * 0.00001, 0), ROUND(SUM([Mar-2017]) * 0.00001, 0), 

ROUND(SUM([Apr-2017]) * 0.00001, 0), ROUND(SUM([May-2017]) * 0.00001, 0), ROUND(SUM([Jun-2017]) * 0.00001, 0), ROUND(SUM([Jul-2017]) * 0.00001, 0), 
ROUND(SUM([Aug-2017]) * 0.00001, 0), ROUND(SUM([Sep-2017]) * 0.00001, 0), ROUND(SUM([Oct-2017]) * 0.00001, 0), ROUND(SUM([Nov-2017]) * 0.00001, 0), 
ROUND(SUM([Dec-2017]) * 0.00001, 0), ROUND(SUM([Jan-2018]) * 0.00001, 0), ROUND(SUM([Feb-2018]) * 0.00001, 0), ROUND(SUM([Mar-2018]) * 0.00001, 0),

ROUND(SUM([Apr-2018]) * 0.00001, 0), ROUND(SUM([May-2018]) * 0.00001, 0), ROUND(SUM([Jun-2018]) * 0.00001, 0), ROUND(SUM([Jul-2018]) * 0.00001, 0), 
ROUND(SUM([Aug-2018]) * 0.00001, 0), ROUND(SUM([Sep-2018]) * 0.00001, 0), ROUND(SUM([Oct-2018]) * 0.00001, 0), ROUND(SUM([Nov-2018]) * 0.00001, 0), 
ROUND(SUM([Dec-2018]) * 0.00001, 0), ROUND(SUM([Jan-2019]) * 0.00001, 0), ROUND(SUM([Feb-2019]) * 0.00001, 0), ROUND(SUM([Mar-2019]) * 0.00001, 0)
FROM #TEMPMONTH16
WHERE PropertyCategory IN ('External', 'C P P') AND MasterPropertyId NOT IN (1,0);
--
INSERT INTO #TEMPMONTH117
SELECT '', '', 3,
ROUND(SUM([Apr-2014]) * 0.00001, 0), ROUND(SUM([May-2014]) * 0.00001, 0), ROUND(SUM([Jun-2014]) * 0.00001, 0), ROUND(SUM([Jul-2014]) * 0.00001, 0), 
ROUND(SUM([Aug-2014]) * 0.00001, 0), ROUND(SUM([Sep-2014]) * 0.00001, 0), ROUND(SUM([Oct-2014]) * 0.00001, 0), ROUND(SUM([Nov-2014]) * 0.00001, 0), 
ROUND(SUM([Dec-2014]) * 0.00001, 0), ROUND(SUM([Jan-2015]) * 0.00001, 0), ROUND(SUM([Feb-2015]) * 0.00001, 0), ROUND(SUM([Mar-2015]) * 0.00001, 0),

ROUND(SUM([Apr-2015]) * 0.00001, 0), ROUND(SUM([May-2015]) * 0.00001, 0), ROUND(SUM([Jun-2015]) * 0.00001, 0), ROUND(SUM([Jul-2015]) * 0.00001, 0), 
ROUND(SUM([Aug-2015]) * 0.00001, 0), ROUND(SUM([Sep-2015]) * 0.00001, 0), ROUND(SUM([Oct-2015]) * 0.00001, 0), ROUND(SUM([Nov-2015]) * 0.00001, 0), 
ROUND(SUM([Dec-2015]) * 0.00001, 0), ROUND(SUM([Jan-2016]) * 0.00001, 0), ROUND(SUM([Feb-2016]) * 0.00001, 0), ROUND(SUM([Mar-2016]) * 0.00001, 0),
 
ROUND(SUM([Apr-2016]) * 0.00001, 0), ROUND(SUM([May-2016]) * 0.00001, 0), ROUND(SUM([Jun-2016]) * 0.00001, 0), ROUND(SUM([Jul-2016]) * 0.00001, 0), 
ROUND(SUM([Aug-2016]) * 0.00001, 0), ROUND(SUM([Sep-2016]) * 0.00001, 0), ROUND(SUM([Oct-2016]) * 0.00001, 0), ROUND(SUM([Nov-2016]) * 0.00001, 0), 
ROUND(SUM([Dec-2016]) * 0.00001, 0), ROUND(SUM([Jan-2017]) * 0.00001, 0), ROUND(SUM([Feb-2017]) * 0.00001, 0), ROUND(SUM([Mar-2017]) * 0.00001, 0), 

ROUND(SUM([Apr-2017]) * 0.00001, 0), ROUND(SUM([May-2017]) * 0.00001, 0), ROUND(SUM([Jun-2017]) * 0.00001, 0), ROUND(SUM([Jul-2017]) * 0.00001, 0), 
ROUND(SUM([Aug-2017]) * 0.00001, 0), ROUND(SUM([Sep-2017]) * 0.00001, 0), ROUND(SUM([Oct-2017]) * 0.00001, 0), ROUND(SUM([Nov-2017]) * 0.00001, 0), 
ROUND(SUM([Dec-2017]) * 0.00001, 0), ROUND(SUM([Jan-2018]) * 0.00001, 0), ROUND(SUM([Feb-2018]) * 0.00001, 0), ROUND(SUM([Mar-2018]) * 0.00001, 0),

ROUND(SUM([Apr-2018]) * 0.00001, 0), ROUND(SUM([May-2018]) * 0.00001, 0), ROUND(SUM([Jun-2018]) * 0.00001, 0), ROUND(SUM([Jul-2018]) * 0.00001, 0), 
ROUND(SUM([Aug-2018]) * 0.00001, 0), ROUND(SUM([Sep-2018]) * 0.00001, 0), ROUND(SUM([Oct-2018]) * 0.00001, 0), ROUND(SUM([Nov-2018]) * 0.00001, 0), 
ROUND(SUM([Dec-2018]) * 0.00001, 0), ROUND(SUM([Jan-2019]) * 0.00001, 0), ROUND(SUM([Feb-2019]) * 0.00001, 0), ROUND(SUM([Mar-2019]) * 0.00001, 0)
FROM #TEMPMONTH16
WHERE PropertyCategory IN ('External', 'C P P') AND MasterPropertyId IN (1,0);
--
INSERT INTO #TEMPMONTH117
SELECT '', '', 4,
ROUND(SUM([Apr-2014]) * 0.00001, 0), ROUND(SUM([May-2014]) * 0.00001, 0), ROUND(SUM([Jun-2014]) * 0.00001, 0), ROUND(SUM([Jul-2014]) * 0.00001, 0), 
ROUND(SUM([Aug-2014]) * 0.00001, 0), ROUND(SUM([Sep-2014]) * 0.00001, 0), ROUND(SUM([Oct-2014]) * 0.00001, 0), ROUND(SUM([Nov-2014]) * 0.00001, 0), 
ROUND(SUM([Dec-2014]) * 0.00001, 0), ROUND(SUM([Jan-2015]) * 0.00001, 0), ROUND(SUM([Feb-2015]) * 0.00001, 0), ROUND(SUM([Mar-2015]) * 0.00001, 0),

ROUND(SUM([Apr-2015]) * 0.00001, 0), ROUND(SUM([May-2015]) * 0.00001, 0), ROUND(SUM([Jun-2015]) * 0.00001, 0), ROUND(SUM([Jul-2015]) * 0.00001, 0), 
ROUND(SUM([Aug-2015]) * 0.00001, 0), ROUND(SUM([Sep-2015]) * 0.00001, 0), ROUND(SUM([Oct-2015]) * 0.00001, 0), ROUND(SUM([Nov-2015]) * 0.00001, 0), 
ROUND(SUM([Dec-2015]) * 0.00001, 0), ROUND(SUM([Jan-2016]) * 0.00001, 0), ROUND(SUM([Feb-2016]) * 0.00001, 0), ROUND(SUM([Mar-2016]) * 0.00001, 0),
 
ROUND(SUM([Apr-2016]) * 0.00001, 0), ROUND(SUM([May-2016]) * 0.00001, 0), ROUND(SUM([Jun-2016]) * 0.00001, 0), ROUND(SUM([Jul-2016]) * 0.00001, 0), 
ROUND(SUM([Aug-2016]) * 0.00001, 0), ROUND(SUM([Sep-2016]) * 0.00001, 0), ROUND(SUM([Oct-2016]) * 0.00001, 0), ROUND(SUM([Nov-2016]) * 0.00001, 0), 
ROUND(SUM([Dec-2016]) * 0.00001, 0), ROUND(SUM([Jan-2017]) * 0.00001, 0), ROUND(SUM([Feb-2017]) * 0.00001, 0), ROUND(SUM([Mar-2017]) * 0.00001, 0), 

ROUND(SUM([Apr-2017]) * 0.00001, 0), ROUND(SUM([May-2017]) * 0.00001, 0), ROUND(SUM([Jun-2017]) * 0.00001, 0), ROUND(SUM([Jul-2017]) * 0.00001, 0), 
ROUND(SUM([Aug-2017]) * 0.00001, 0), ROUND(SUM([Sep-2017]) * 0.00001, 0), ROUND(SUM([Oct-2017]) * 0.00001, 0), ROUND(SUM([Nov-2017]) * 0.00001, 0), 
ROUND(SUM([Dec-2017]) * 0.00001, 0), ROUND(SUM([Jan-2018]) * 0.00001, 0), ROUND(SUM([Feb-2018]) * 0.00001, 0), ROUND(SUM([Mar-2018]) * 0.00001, 0),

ROUND(SUM([Apr-2018]) * 0.00001, 0), ROUND(SUM([May-2018]) * 0.00001, 0), ROUND(SUM([Jun-2018]) * 0.00001, 0), ROUND(SUM([Jul-2018]) * 0.00001, 0), 
ROUND(SUM([Aug-2018]) * 0.00001, 0), ROUND(SUM([Sep-2018]) * 0.00001, 0), ROUND(SUM([Oct-2018]) * 0.00001, 0), ROUND(SUM([Nov-2018]) * 0.00001, 0), 
ROUND(SUM([Dec-2018]) * 0.00001, 0), ROUND(SUM([Jan-2019]) * 0.00001, 0), ROUND(SUM([Feb-2019]) * 0.00001, 0), ROUND(SUM([Mar-2019]) * 0.00001, 0)
FROM #TEMPMONTH16
WHERE PropertyCategory NOT IN ('External', 'C P P');
--
INSERT INTO #TEMPMONTH117
SELECT '', '     Non Chain Hotels ( Value in Rs Lacs )', 5,
SUM([Apr-2014]), SUM([May-2014]), SUM([Jun-2014]), SUM([Jul-2014]), SUM([Aug-2014]), SUM([Sep-2014]), SUM([Oct-2014]), SUM([Nov-2014]), SUM([Dec-2014]), 
SUM([Jan-2015]), SUM([Feb-2015]), SUM([Mar-2015]),
SUM([Apr-2015]), SUM([May-2015]), SUM([Jun-2015]), SUM([Jul-2015]), SUM([Aug-2015]), SUM([Sep-2015]), SUM([Oct-2015]), SUM([Nov-2015]), SUM([Dec-2015]), 
SUM([Jan-2016]), SUM([Feb-2016]), SUM([Mar-2016]), 
SUM([Apr-2016]), SUM([May-2016]), SUM([Jun-2016]), SUM([Jul-2016]), SUM([Aug-2016]), SUM([Sep-2016]), SUM([Oct-2016]), SUM([Nov-2016]), SUM([Dec-2016]), 
SUM([Jan-2017]), SUM([Feb-2017]), SUM([Mar-2017]), 
SUM([Apr-2017]), SUM([May-2017]), SUM([Jun-2017]), SUM([Jul-2017]), SUM([Aug-2017]), SUM([Sep-2017]), SUM([Oct-2017]), SUM([Nov-2017]), SUM([Dec-2017]), 
SUM([Jan-2018]), SUM([Feb-2018]), SUM([Mar-2018]),
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019])
FROM #TEMPMONTH117
WHERE Flg IN (3,4);
-- TABLE 3.1
/*SELECT Title1, Title2,
[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017], 
[Apr-2016] + [May-2016] + [Jun-2016] + [Jul-2016] + [Aug-2016] + [Sep-2016] + [Oct-2016] + [Nov-2016] + [Dec-2016] + [Jan-2017] + [Feb-2017] + [Mar-2017] AS Total,
[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018] 
FROM #TEMPMONTH117
WHERE Flg IN (1,2,5)
ORDER BY Flg;*/
--
CREATE TABLE #TEMPMONTH18(MonthofBooking NVARCHAR(100),Tariff DECIMAL(27,2));
INSERT INTO #TEMPMONTH18(MonthofBooking,Tariff)
SELECT asasd,SUM(Tariff) FROM #TEMP2 WHERE Tariff <= 3000 AND PropertyCategory IN ('External', 'C P P')  
GROUP BY asasd;
--
SELECT   [Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
		 [Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
		 [Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
		 [Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
		 [Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019]
INTO #TEMPMONTH19
FROM #TEMPMONTH18
PIVOT
(
       SUM(Tariff)
       FOR MonthofBooking IN 
	   ([Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
		[Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
		[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
		[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
		[Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019])
) AS P;
---
INSERT INTO #TEMPMONTH117
SELECT 'Budget Vs Others', 'Budget ( Rs.1 to Rs.3000 per night ) ( Value in Rs Lacs )', 6,
ROUND(SUM(ISNULL([Apr-2014], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([May-2014], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Jun-2014], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Jul-2014], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Aug-2014], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Sep-2014], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Oct-2014], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Nov-2014], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Dec-2014], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Jan-2015], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Feb-2015], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Mar-2015], 0)) * 0.00001, 0), 

ROUND(SUM(ISNULL([Apr-2015], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([May-2015], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Jun-2015], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Jul-2015], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Aug-2015], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Sep-2015], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Oct-2015], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Nov-2015], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Dec-2015], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Jan-2016], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Feb-2016], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Mar-2016], 0)) * 0.00001, 0), 

ROUND(SUM(ISNULL([Apr-2016], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([May-2016], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Jun-2016], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Jul-2016], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Aug-2016], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Sep-2016], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Oct-2016], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Nov-2016], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Dec-2016], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Jan-2017], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Feb-2017], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Mar-2017], 0)) * 0.00001, 0), 

ROUND(SUM(ISNULL([Apr-2017], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([May-2017], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Jun-2017], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Jul-2017], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Aug-2017], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Sep-2017], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Oct-2017], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Nov-2017], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Dec-2017], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Jan-2018], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Feb-2018], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Mar-2018], 0)) * 0.00001, 0),

ROUND(SUM(ISNULL([Apr-2018], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([May-2018], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Jun-2018], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Jul-2018], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Aug-2018], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Sep-2018], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Oct-2018], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Nov-2018], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Dec-2018], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Jan-2019], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Feb-2019], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Mar-2019], 0)) * 0.00001, 0)
FROM #TEMPMONTH19;
--
CREATE TABLE #TEMPMONTH20(MonthofBooking NVARCHAR(100),Tariff DECIMAL(27,2));
INSERT INTO #TEMPMONTH20(MonthofBooking,Tariff)
SELECT asasd,SUM(Tariff) FROM #TEMP2 WHERE Tariff > 3000 AND PropertyCategory IN ('External', 'C P P')  
GROUP BY asasd;
--
SELECT   [Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
		 [Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
		 [Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
		 [Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
		 [Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019]
INTO #TEMPMONTH21
FROM #TEMPMONTH20
PIVOT
(
       SUM(Tariff)
       FOR MonthofBooking IN 
	   ([Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
		[Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
		[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
		[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
		[Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019])
) AS P;
---
INSERT INTO #TEMPMONTH117
SELECT '', 'Other ( Above Rs.3000 per night ) ( Value in Rs Lacs )', 7,
ROUND(SUM(ISNULL([Apr-2014], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([May-2014], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Jun-2014], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Jul-2014], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Aug-2014], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Sep-2014], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Oct-2014], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Nov-2014], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Dec-2014], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Jan-2015], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Feb-2015], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Mar-2015], 0)) * 0.00001, 0), 

ROUND(SUM(ISNULL([Apr-2015], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([May-2015], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Jun-2015], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Jul-2015], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Aug-2015], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Sep-2015], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Oct-2015], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Nov-2015], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Dec-2015], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Jan-2016], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Feb-2016], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Mar-2016], 0)) * 0.00001, 0), 

ROUND(SUM(ISNULL([Apr-2016], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([May-2016], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Jun-2016], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Jul-2016], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Aug-2016], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Sep-2016], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Oct-2016], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Nov-2016], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Dec-2016], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Jan-2017], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Feb-2017], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Mar-2017], 0)) * 0.00001, 0), 

ROUND(SUM(ISNULL([Apr-2017], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([May-2017], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Jun-2017], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Jul-2017], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Aug-2017], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Sep-2017], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Oct-2017], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Nov-2017], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Dec-2017], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Jan-2018], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Feb-2018], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Mar-2018], 0)) * 0.00001, 0),

ROUND(SUM(ISNULL([Apr-2018], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([May-2018], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Jun-2018], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Jul-2018], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Aug-2018], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Sep-2018], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Oct-2018], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Nov-2018], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Dec-2018], 0)) * 0.00001, 0), 
ROUND(SUM(ISNULL([Jan-2019], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Feb-2019], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Mar-2019], 0)) * 0.00001, 0)
FROM #TEMPMONTH21;
/*-- TABLE 3.2
 SELECT Title1, Title2,
[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017], 
[Apr-2016] + [May-2016] + [Jun-2016] + [Jul-2016] + [Aug-2016] + [Sep-2016] + [Oct-2016] + [Nov-2016] + [Dec-2016] + [Jan-2017] + [Feb-2017] + [Mar-2017] AS Total,
[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018] 
FROM #TEMPMONTH117
WHERE Flg IN (6,7)
ORDER BY Flg;*/
--
INSERT INTO #TEMPMONTH117
SELECT 'Property Category', 'Client Preferered Property ( Value in Rs Lacs )', 8,
ROUND(SUM([Apr-2014]) * 0.00001, 0), ROUND(SUM([May-2014]) * 0.00001, 0), ROUND(SUM([Jun-2014]) * 0.00001, 0), ROUND(SUM([Jul-2014]) * 0.00001, 0), 
ROUND(SUM([Aug-2014]) * 0.00001, 0), ROUND(SUM([Sep-2014]) * 0.00001, 0), ROUND(SUM([Oct-2014]) * 0.00001, 0), ROUND(SUM([Nov-2014]) * 0.00001, 0), 
ROUND(SUM([Dec-2014]) * 0.00001, 0), ROUND(SUM([Jan-2015]) * 0.00001, 0), ROUND(SUM([Feb-2015]) * 0.00001, 0), ROUND(SUM([Mar-2015]) * 0.00001, 0),

ROUND(SUM([Apr-2015]) * 0.00001, 0), ROUND(SUM([May-2015]) * 0.00001, 0), ROUND(SUM([Jun-2015]) * 0.00001, 0), ROUND(SUM([Jul-2015]) * 0.00001, 0), 
ROUND(SUM([Aug-2015]) * 0.00001, 0), ROUND(SUM([Sep-2015]) * 0.00001, 0), ROUND(SUM([Oct-2015]) * 0.00001, 0), ROUND(SUM([Nov-2015]) * 0.00001, 0), 
ROUND(SUM([Dec-2015]) * 0.00001, 0), ROUND(SUM([Jan-2016]) * 0.00001, 0), ROUND(SUM([Feb-2016]) * 0.00001, 0), ROUND(SUM([Mar-2016]) * 0.00001, 0),
 
ROUND(SUM([Apr-2016]) * 0.00001, 0), ROUND(SUM([May-2016]) * 0.00001, 0), ROUND(SUM([Jun-2016]) * 0.00001, 0), ROUND(SUM([Jul-2016]) * 0.00001, 0), 
ROUND(SUM([Aug-2016]) * 0.00001, 0), ROUND(SUM([Sep-2016]) * 0.00001, 0), ROUND(SUM([Oct-2016]) * 0.00001, 0), ROUND(SUM([Nov-2016]) * 0.00001, 0), 
ROUND(SUM([Dec-2016]) * 0.00001, 0), ROUND(SUM([Jan-2017]) * 0.00001, 0), ROUND(SUM([Feb-2017]) * 0.00001, 0), ROUND(SUM([Mar-2017]) * 0.00001, 0), 

ROUND(SUM([Apr-2017]) * 0.00001, 0), ROUND(SUM([May-2017]) * 0.00001, 0), ROUND(SUM([Jun-2017]) * 0.00001, 0), ROUND(SUM([Jul-2017]) * 0.00001, 0), 
ROUND(SUM([Aug-2017]) * 0.00001, 0), ROUND(SUM([Sep-2017]) * 0.00001, 0), ROUND(SUM([Oct-2017]) * 0.00001, 0), ROUND(SUM([Nov-2017]) * 0.00001, 0), 
ROUND(SUM([Dec-2017]) * 0.00001, 0), ROUND(SUM([Jan-2018]) * 0.00001, 0), ROUND(SUM([Feb-2018]) * 0.00001, 0), ROUND(SUM([Mar-2018]) * 0.00001, 0),

ROUND(SUM([Apr-2018]) * 0.00001, 0), ROUND(SUM([May-2018]) * 0.00001, 0), ROUND(SUM([Jun-2018]) * 0.00001, 0), ROUND(SUM([Jul-2018]) * 0.00001, 0), 
ROUND(SUM([Aug-2018]) * 0.00001, 0), ROUND(SUM([Sep-2018]) * 0.00001, 0), ROUND(SUM([Oct-2018]) * 0.00001, 0), ROUND(SUM([Nov-2018]) * 0.00001, 0), 
ROUND(SUM([Dec-2018]) * 0.00001, 0), ROUND(SUM([Jan-2019]) * 0.00001, 0), ROUND(SUM([Feb-2019]) * 0.00001, 0), ROUND(SUM([Mar-2019]) * 0.00001, 0)
FROM #TEMPMONTH16
WHERE PropertyCategory IN ('C P P');
--
INSERT INTO #TEMPMONTH117
SELECT '', 'HB Partners ( Value in Rs Lacs )', 9,
ROUND(SUM([Apr-2014]) * 0.00001, 0), ROUND(SUM([May-2014]) * 0.00001, 0), ROUND(SUM([Jun-2014]) * 0.00001, 0), ROUND(SUM([Jul-2014]) * 0.00001, 0), 
ROUND(SUM([Aug-2014]) * 0.00001, 0), ROUND(SUM([Sep-2014]) * 0.00001, 0), ROUND(SUM([Oct-2014]) * 0.00001, 0), ROUND(SUM([Nov-2014]) * 0.00001, 0), 
ROUND(SUM([Dec-2014]) * 0.00001, 0), ROUND(SUM([Jan-2015]) * 0.00001, 0), ROUND(SUM([Feb-2015]) * 0.00001, 0), ROUND(SUM([Mar-2015]) * 0.00001, 0),

ROUND(SUM([Apr-2015]) * 0.00001, 0), ROUND(SUM([May-2015]) * 0.00001, 0), ROUND(SUM([Jun-2015]) * 0.00001, 0), ROUND(SUM([Jul-2015]) * 0.00001, 0), 
ROUND(SUM([Aug-2015]) * 0.00001, 0), ROUND(SUM([Sep-2015]) * 0.00001, 0), ROUND(SUM([Oct-2015]) * 0.00001, 0), ROUND(SUM([Nov-2015]) * 0.00001, 0), 
ROUND(SUM([Dec-2015]) * 0.00001, 0), ROUND(SUM([Jan-2016]) * 0.00001, 0), ROUND(SUM([Feb-2016]) * 0.00001, 0), ROUND(SUM([Mar-2016]) * 0.00001, 0),
 
ROUND(SUM([Apr-2016]) * 0.00001, 0), ROUND(SUM([May-2016]) * 0.00001, 0), ROUND(SUM([Jun-2016]) * 0.00001, 0), ROUND(SUM([Jul-2016]) * 0.00001, 0), 
ROUND(SUM([Aug-2016]) * 0.00001, 0), ROUND(SUM([Sep-2016]) * 0.00001, 0), ROUND(SUM([Oct-2016]) * 0.00001, 0), ROUND(SUM([Nov-2016]) * 0.00001, 0), 
ROUND(SUM([Dec-2016]) * 0.00001, 0), ROUND(SUM([Jan-2017]) * 0.00001, 0), ROUND(SUM([Feb-2017]) * 0.00001, 0), ROUND(SUM([Mar-2017]) * 0.00001, 0), 

ROUND(SUM([Apr-2017]) * 0.00001, 0), ROUND(SUM([May-2017]) * 0.00001, 0), ROUND(SUM([Jun-2017]) * 0.00001, 0), ROUND(SUM([Jul-2017]) * 0.00001, 0), 
ROUND(SUM([Aug-2017]) * 0.00001, 0), ROUND(SUM([Sep-2017]) * 0.00001, 0), ROUND(SUM([Oct-2017]) * 0.00001, 0), ROUND(SUM([Nov-2017]) * 0.00001, 0), 
ROUND(SUM([Dec-2017]) * 0.00001, 0), ROUND(SUM([Jan-2018]) * 0.00001, 0), ROUND(SUM([Feb-2018]) * 0.00001, 0), ROUND(SUM([Mar-2018]) * 0.00001, 0),

ROUND(SUM([Apr-2018]) * 0.00001, 0), ROUND(SUM([May-2018]) * 0.00001, 0), ROUND(SUM([Jun-2018]) * 0.00001, 0), ROUND(SUM([Jul-2018]) * 0.00001, 0), 
ROUND(SUM([Aug-2018]) * 0.00001, 0), ROUND(SUM([Sep-2018]) * 0.00001, 0), ROUND(SUM([Oct-2018]) * 0.00001, 0), ROUND(SUM([Nov-2018]) * 0.00001, 0), 
ROUND(SUM([Dec-2018]) * 0.00001, 0), ROUND(SUM([Jan-2019]) * 0.00001, 0), ROUND(SUM([Feb-2019]) * 0.00001, 0), ROUND(SUM([Mar-2019]) * 0.00001, 0)
FROM #TEMPMONTH16
WHERE PropertyCategory IN ('External');
/*-- TABLE 3.3
SELECT Title1, Title2,
[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017], 
[Apr-2016] + [May-2016] + [Jun-2016] + [Jul-2016] + [Aug-2016] + [Sep-2016] + [Oct-2016] + [Nov-2016] + [Dec-2016] + [Jan-2017] + [Feb-2017] + [Mar-2017] AS Total,
[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018] 
FROM #TEMPMONTH117
WHERE Flg IN (8,9)
ORDER BY Flg;*/
--
INSERT INTO #TEMPMONTH117
SELECT 'Top clients Vs Others Clients', 'Total No of Clients ( Value in Rs Lacs )', 10,
ROUND(SUM([Apr-2014]) * 0.00001, 0), ROUND(SUM([May-2014]) * 0.00001, 0), ROUND(SUM([Jun-2014]) * 0.00001, 0), ROUND(SUM([Jul-2014]) * 0.00001, 0), 
ROUND(SUM([Aug-2014]) * 0.00001, 0), ROUND(SUM([Sep-2014]) * 0.00001, 0), ROUND(SUM([Oct-2014]) * 0.00001, 0), ROUND(SUM([Nov-2014]) * 0.00001, 0), 
ROUND(SUM([Dec-2014]) * 0.00001, 0), ROUND(SUM([Jan-2015]) * 0.00001, 0), ROUND(SUM([Feb-2015]) * 0.00001, 0), ROUND(SUM([Mar-2015]) * 0.00001, 0),

ROUND(SUM([Apr-2015]) * 0.00001, 0), ROUND(SUM([May-2015]) * 0.00001, 0), ROUND(SUM([Jun-2015]) * 0.00001, 0), ROUND(SUM([Jul-2015]) * 0.00001, 0), 
ROUND(SUM([Aug-2015]) * 0.00001, 0), ROUND(SUM([Sep-2015]) * 0.00001, 0), ROUND(SUM([Oct-2015]) * 0.00001, 0), ROUND(SUM([Nov-2015]) * 0.00001, 0), 
ROUND(SUM([Dec-2015]) * 0.00001, 0), ROUND(SUM([Jan-2016]) * 0.00001, 0), ROUND(SUM([Feb-2016]) * 0.00001, 0), ROUND(SUM([Mar-2016]) * 0.00001, 0),
 
ROUND(SUM([Apr-2016]) * 0.00001, 0), ROUND(SUM([May-2016]) * 0.00001, 0), ROUND(SUM([Jun-2016]) * 0.00001, 0), ROUND(SUM([Jul-2016]) * 0.00001, 0), 
ROUND(SUM([Aug-2016]) * 0.00001, 0), ROUND(SUM([Sep-2016]) * 0.00001, 0), ROUND(SUM([Oct-2016]) * 0.00001, 0), ROUND(SUM([Nov-2016]) * 0.00001, 0), 
ROUND(SUM([Dec-2016]) * 0.00001, 0), ROUND(SUM([Jan-2017]) * 0.00001, 0), ROUND(SUM([Feb-2017]) * 0.00001, 0), ROUND(SUM([Mar-2017]) * 0.00001, 0), 

ROUND(SUM([Apr-2017]) * 0.00001, 0), ROUND(SUM([May-2017]) * 0.00001, 0), ROUND(SUM([Jun-2017]) * 0.00001, 0), ROUND(SUM([Jul-2017]) * 0.00001, 0), 
ROUND(SUM([Aug-2017]) * 0.00001, 0), ROUND(SUM([Sep-2017]) * 0.00001, 0), ROUND(SUM([Oct-2017]) * 0.00001, 0), ROUND(SUM([Nov-2017]) * 0.00001, 0), 
ROUND(SUM([Dec-2017]) * 0.00001, 0), ROUND(SUM([Jan-2018]) * 0.00001, 0), ROUND(SUM([Feb-2018]) * 0.00001, 0), ROUND(SUM([Mar-2018]) * 0.00001, 0),

ROUND(SUM([Apr-2018]) * 0.00001, 0), ROUND(SUM([May-2018]) * 0.00001, 0), ROUND(SUM([Jun-2018]) * 0.00001, 0), ROUND(SUM([Jul-2018]) * 0.00001, 0), 
ROUND(SUM([Aug-2018]) * 0.00001, 0), ROUND(SUM([Sep-2018]) * 0.00001, 0), ROUND(SUM([Oct-2018]) * 0.00001, 0), ROUND(SUM([Nov-2018]) * 0.00001, 0), 
ROUND(SUM([Dec-2018]) * 0.00001, 0), ROUND(SUM([Jan-2019]) * 0.00001, 0), ROUND(SUM([Feb-2019]) * 0.00001, 0), ROUND(SUM([Mar-2019]) * 0.00001, 0)
FROM #TEMPMONTH16
WHERE PropertyCategory IN ('External', 'C P P') ;
--
INSERT INTO #TEMPMONTH117
SELECT '', '     Top Clients ( Value in Rs Lacs )', 11,
ROUND(SUM([Apr-2014]) * 0.00001, 0), ROUND(SUM([May-2014]) * 0.00001, 0), ROUND(SUM([Jun-2014]) * 0.00001, 0), ROUND(SUM([Jul-2014]) * 0.00001, 0), 
ROUND(SUM([Aug-2014]) * 0.00001, 0), ROUND(SUM([Sep-2014]) * 0.00001, 0), ROUND(SUM([Oct-2014]) * 0.00001, 0), ROUND(SUM([Nov-2014]) * 0.00001, 0), 
ROUND(SUM([Dec-2014]) * 0.00001, 0), ROUND(SUM([Jan-2015]) * 0.00001, 0), ROUND(SUM([Feb-2015]) * 0.00001, 0), ROUND(SUM([Mar-2015]) * 0.00001, 0),

ROUND(SUM([Apr-2015]) * 0.00001, 0), ROUND(SUM([May-2015]) * 0.00001, 0), ROUND(SUM([Jun-2015]) * 0.00001, 0), ROUND(SUM([Jul-2015]) * 0.00001, 0), 
ROUND(SUM([Aug-2015]) * 0.00001, 0), ROUND(SUM([Sep-2015]) * 0.00001, 0), ROUND(SUM([Oct-2015]) * 0.00001, 0), ROUND(SUM([Nov-2015]) * 0.00001, 0), 
ROUND(SUM([Dec-2015]) * 0.00001, 0), ROUND(SUM([Jan-2016]) * 0.00001, 0), ROUND(SUM([Feb-2016]) * 0.00001, 0), ROUND(SUM([Mar-2016]) * 0.00001, 0),
 
ROUND(SUM([Apr-2016]) * 0.00001, 0), ROUND(SUM([May-2016]) * 0.00001, 0), ROUND(SUM([Jun-2016]) * 0.00001, 0), ROUND(SUM([Jul-2016]) * 0.00001, 0), 
ROUND(SUM([Aug-2016]) * 0.00001, 0), ROUND(SUM([Sep-2016]) * 0.00001, 0), ROUND(SUM([Oct-2016]) * 0.00001, 0), ROUND(SUM([Nov-2016]) * 0.00001, 0), 
ROUND(SUM([Dec-2016]) * 0.00001, 0), ROUND(SUM([Jan-2017]) * 0.00001, 0), ROUND(SUM([Feb-2017]) * 0.00001, 0), ROUND(SUM([Mar-2017]) * 0.00001, 0), 

ROUND(SUM([Apr-2017]) * 0.00001, 0), ROUND(SUM([May-2017]) * 0.00001, 0), ROUND(SUM([Jun-2017]) * 0.00001, 0), ROUND(SUM([Jul-2017]) * 0.00001, 0), 
ROUND(SUM([Aug-2017]) * 0.00001, 0), ROUND(SUM([Sep-2017]) * 0.00001, 0), ROUND(SUM([Oct-2017]) * 0.00001, 0), ROUND(SUM([Nov-2017]) * 0.00001, 0), 
ROUND(SUM([Dec-2017]) * 0.00001, 0), ROUND(SUM([Jan-2018]) * 0.00001, 0), ROUND(SUM([Feb-2018]) * 0.00001, 0), ROUND(SUM([Mar-2018]) * 0.00001, 0),

ROUND(SUM([Apr-2018]) * 0.00001, 0), ROUND(SUM([May-2018]) * 0.00001, 0), ROUND(SUM([Jun-2018]) * 0.00001, 0), ROUND(SUM([Jul-2018]) * 0.00001, 0), 
ROUND(SUM([Aug-2018]) * 0.00001, 0), ROUND(SUM([Sep-2018]) * 0.00001, 0), ROUND(SUM([Oct-2018]) * 0.00001, 0), ROUND(SUM([Nov-2018]) * 0.00001, 0), 
ROUND(SUM([Dec-2018]) * 0.00001, 0), ROUND(SUM([Jan-2019]) * 0.00001, 0), ROUND(SUM([Feb-2019]) * 0.00001, 0), ROUND(SUM([Mar-2019]) * 0.00001, 0)
FROM #TEMPMONTH16
WHERE MasterClientId IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1) AND PropertyCategory IN ('External', 'C P P') ;
--
INSERT INTO #TEMPMONTH117
SELECT '', '     Other than Top Clients ( Value in Rs Lacs )', 12,
ROUND(SUM([Apr-2014]) * 0.00001, 0), ROUND(SUM([May-2014]) * 0.00001, 0), ROUND(SUM([Jun-2014]) * 0.00001, 0), ROUND(SUM([Jul-2014]) * 0.00001, 0), 
ROUND(SUM([Aug-2014]) * 0.00001, 0), ROUND(SUM([Sep-2014]) * 0.00001, 0), ROUND(SUM([Oct-2014]) * 0.00001, 0), ROUND(SUM([Nov-2014]) * 0.00001, 0), 
ROUND(SUM([Dec-2014]) * 0.00001, 0), ROUND(SUM([Jan-2015]) * 0.00001, 0), ROUND(SUM([Feb-2015]) * 0.00001, 0), ROUND(SUM([Mar-2015]) * 0.00001, 0),

ROUND(SUM([Apr-2015]) * 0.00001, 0), ROUND(SUM([May-2015]) * 0.00001, 0), ROUND(SUM([Jun-2015]) * 0.00001, 0), ROUND(SUM([Jul-2015]) * 0.00001, 0), 
ROUND(SUM([Aug-2015]) * 0.00001, 0), ROUND(SUM([Sep-2015]) * 0.00001, 0), ROUND(SUM([Oct-2015]) * 0.00001, 0), ROUND(SUM([Nov-2015]) * 0.00001, 0), 
ROUND(SUM([Dec-2015]) * 0.00001, 0), ROUND(SUM([Jan-2016]) * 0.00001, 0), ROUND(SUM([Feb-2016]) * 0.00001, 0), ROUND(SUM([Mar-2016]) * 0.00001, 0),
 
ROUND(SUM([Apr-2016]) * 0.00001, 0), ROUND(SUM([May-2016]) * 0.00001, 0), ROUND(SUM([Jun-2016]) * 0.00001, 0), ROUND(SUM([Jul-2016]) * 0.00001, 0), 
ROUND(SUM([Aug-2016]) * 0.00001, 0), ROUND(SUM([Sep-2016]) * 0.00001, 0), ROUND(SUM([Oct-2016]) * 0.00001, 0), ROUND(SUM([Nov-2016]) * 0.00001, 0), 
ROUND(SUM([Dec-2016]) * 0.00001, 0), ROUND(SUM([Jan-2017]) * 0.00001, 0), ROUND(SUM([Feb-2017]) * 0.00001, 0), ROUND(SUM([Mar-2017]) * 0.00001, 0), 

ROUND(SUM([Apr-2017]) * 0.00001, 0), ROUND(SUM([May-2017]) * 0.00001, 0), ROUND(SUM([Jun-2017]) * 0.00001, 0), ROUND(SUM([Jul-2017]) * 0.00001, 0), 
ROUND(SUM([Aug-2017]) * 0.00001, 0), ROUND(SUM([Sep-2017]) * 0.00001, 0), ROUND(SUM([Oct-2017]) * 0.00001, 0), ROUND(SUM([Nov-2017]) * 0.00001, 0), 
ROUND(SUM([Dec-2017]) * 0.00001, 0), ROUND(SUM([Jan-2018]) * 0.00001, 0), ROUND(SUM([Feb-2018]) * 0.00001, 0), ROUND(SUM([Mar-2018]) * 0.00001, 0),

ROUND(SUM([Apr-2018]) * 0.00001, 0), ROUND(SUM([May-2018]) * 0.00001, 0), ROUND(SUM([Jun-2018]) * 0.00001, 0), ROUND(SUM([Jul-2018]) * 0.00001, 0), 
ROUND(SUM([Aug-2018]) * 0.00001, 0), ROUND(SUM([Sep-2018]) * 0.00001, 0), ROUND(SUM([Oct-2018]) * 0.00001, 0), ROUND(SUM([Nov-2018]) * 0.00001, 0), 
ROUND(SUM([Dec-2018]) * 0.00001, 0), ROUND(SUM([Jan-2019]) * 0.00001, 0), ROUND(SUM([Feb-2019]) * 0.00001, 0), ROUND(SUM([Mar-2019]) * 0.00001, 0)
FROM #TEMPMONTH16
WHERE MasterClientId NOT IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1) AND PropertyCategory IN ('External', 'C P P') ;
/*-- TABLE 3.4
SELECT Title1, Title2,
[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017], 
[Apr-2016] + [May-2016] + [Jun-2016] + [Jul-2016] + [Aug-2016] + [Sep-2016] + [Oct-2016] + [Nov-2016] + [Dec-2016] + [Jan-2017] + [Feb-2017] + [Mar-2017] AS Total,
[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018] 
FROM #TEMPMONTH117
WHERE Flg IN (10,11,12)
ORDER BY Flg;*/
--
INSERT INTO #TEMPMONTH117
SELECT 'Hotels Pays Commission', 'With Commission ( Value in Rs Lacs )', 13,
ROUND(SUM([Apr-2014]) * 0.00001, 0), ROUND(SUM([May-2014]) * 0.00001, 0), ROUND(SUM([Jun-2014]) * 0.00001, 0), ROUND(SUM([Jul-2014]) * 0.00001, 0), 
ROUND(SUM([Aug-2014]) * 0.00001, 0), ROUND(SUM([Sep-2014]) * 0.00001, 0), ROUND(SUM([Oct-2014]) * 0.00001, 0), ROUND(SUM([Nov-2014]) * 0.00001, 0), 
ROUND(SUM([Dec-2014]) * 0.00001, 0), ROUND(SUM([Jan-2015]) * 0.00001, 0), ROUND(SUM([Feb-2015]) * 0.00001, 0), ROUND(SUM([Mar-2015]) * 0.00001, 0),

ROUND(SUM([Apr-2015]) * 0.00001, 0), ROUND(SUM([May-2015]) * 0.00001, 0), ROUND(SUM([Jun-2015]) * 0.00001, 0), ROUND(SUM([Jul-2015]) * 0.00001, 0), 
ROUND(SUM([Aug-2015]) * 0.00001, 0), ROUND(SUM([Sep-2015]) * 0.00001, 0), ROUND(SUM([Oct-2015]) * 0.00001, 0), ROUND(SUM([Nov-2015]) * 0.00001, 0), 
ROUND(SUM([Dec-2015]) * 0.00001, 0), ROUND(SUM([Jan-2016]) * 0.00001, 0), ROUND(SUM([Feb-2016]) * 0.00001, 0), ROUND(SUM([Mar-2016]) * 0.00001, 0),
 
ROUND(SUM([Apr-2016]) * 0.00001, 0), ROUND(SUM([May-2016]) * 0.00001, 0), ROUND(SUM([Jun-2016]) * 0.00001, 0), ROUND(SUM([Jul-2016]) * 0.00001, 0), 
ROUND(SUM([Aug-2016]) * 0.00001, 0), ROUND(SUM([Sep-2016]) * 0.00001, 0), ROUND(SUM([Oct-2016]) * 0.00001, 0), ROUND(SUM([Nov-2016]) * 0.00001, 0), 
ROUND(SUM([Dec-2016]) * 0.00001, 0), ROUND(SUM([Jan-2017]) * 0.00001, 0), ROUND(SUM([Feb-2017]) * 0.00001, 0), ROUND(SUM([Mar-2017]) * 0.00001, 0), 

ROUND(SUM([Apr-2017]) * 0.00001, 0), ROUND(SUM([May-2017]) * 0.00001, 0), ROUND(SUM([Jun-2017]) * 0.00001, 0), ROUND(SUM([Jul-2017]) * 0.00001, 0), 
ROUND(SUM([Aug-2017]) * 0.00001, 0), ROUND(SUM([Sep-2017]) * 0.00001, 0), ROUND(SUM([Oct-2017]) * 0.00001, 0), ROUND(SUM([Nov-2017]) * 0.00001, 0), 
ROUND(SUM([Dec-2017]) * 0.00001, 0), ROUND(SUM([Jan-2018]) * 0.00001, 0), ROUND(SUM([Feb-2018]) * 0.00001, 0), ROUND(SUM([Mar-2018]) * 0.00001, 0),

ROUND(SUM([Apr-2018]) * 0.00001, 0), ROUND(SUM([May-2018]) * 0.00001, 0), ROUND(SUM([Jun-2018]) * 0.00001, 0), ROUND(SUM([Jul-2018]) * 0.00001, 0), 
ROUND(SUM([Aug-2018]) * 0.00001, 0), ROUND(SUM([Sep-2018]) * 0.00001, 0), ROUND(SUM([Oct-2018]) * 0.00001, 0), ROUND(SUM([Nov-2018]) * 0.00001, 0), 
ROUND(SUM([Dec-2018]) * 0.00001, 0), ROUND(SUM([Jan-2019]) * 0.00001, 0), ROUND(SUM([Feb-2019]) * 0.00001, 0), ROUND(SUM([Mar-2019]) * 0.00001, 0)
FROM #TEMPMONTH16
WHERE Markup != 0 AND PropertyCategory IN ('External', 'C P P') ;
--
INSERT INTO #TEMPMONTH117
SELECT '', '     Client Preferred Property ( Value in Rs Lacs )', 14,
ROUND(SUM([Apr-2014]) * 0.00001, 0), ROUND(SUM([May-2014]) * 0.00001, 0), ROUND(SUM([Jun-2014]) * 0.00001, 0), ROUND(SUM([Jul-2014]) * 0.00001, 0), 
ROUND(SUM([Aug-2014]) * 0.00001, 0), ROUND(SUM([Sep-2014]) * 0.00001, 0), ROUND(SUM([Oct-2014]) * 0.00001, 0), ROUND(SUM([Nov-2014]) * 0.00001, 0), 
ROUND(SUM([Dec-2014]) * 0.00001, 0), ROUND(SUM([Jan-2015]) * 0.00001, 0), ROUND(SUM([Feb-2015]) * 0.00001, 0), ROUND(SUM([Mar-2015]) * 0.00001, 0),

ROUND(SUM([Apr-2015]) * 0.00001, 0), ROUND(SUM([May-2015]) * 0.00001, 0), ROUND(SUM([Jun-2015]) * 0.00001, 0), ROUND(SUM([Jul-2015]) * 0.00001, 0), 
ROUND(SUM([Aug-2015]) * 0.00001, 0), ROUND(SUM([Sep-2015]) * 0.00001, 0), ROUND(SUM([Oct-2015]) * 0.00001, 0), ROUND(SUM([Nov-2015]) * 0.00001, 0), 
ROUND(SUM([Dec-2015]) * 0.00001, 0), ROUND(SUM([Jan-2016]) * 0.00001, 0), ROUND(SUM([Feb-2016]) * 0.00001, 0), ROUND(SUM([Mar-2016]) * 0.00001, 0),
 
ROUND(SUM([Apr-2016]) * 0.00001, 0), ROUND(SUM([May-2016]) * 0.00001, 0), ROUND(SUM([Jun-2016]) * 0.00001, 0), ROUND(SUM([Jul-2016]) * 0.00001, 0), 
ROUND(SUM([Aug-2016]) * 0.00001, 0), ROUND(SUM([Sep-2016]) * 0.00001, 0), ROUND(SUM([Oct-2016]) * 0.00001, 0), ROUND(SUM([Nov-2016]) * 0.00001, 0), 
ROUND(SUM([Dec-2016]) * 0.00001, 0), ROUND(SUM([Jan-2017]) * 0.00001, 0), ROUND(SUM([Feb-2017]) * 0.00001, 0), ROUND(SUM([Mar-2017]) * 0.00001, 0), 

ROUND(SUM([Apr-2017]) * 0.00001, 0), ROUND(SUM([May-2017]) * 0.00001, 0), ROUND(SUM([Jun-2017]) * 0.00001, 0), ROUND(SUM([Jul-2017]) * 0.00001, 0), 
ROUND(SUM([Aug-2017]) * 0.00001, 0), ROUND(SUM([Sep-2017]) * 0.00001, 0), ROUND(SUM([Oct-2017]) * 0.00001, 0), ROUND(SUM([Nov-2017]) * 0.00001, 0), 
ROUND(SUM([Dec-2017]) * 0.00001, 0), ROUND(SUM([Jan-2018]) * 0.00001, 0), ROUND(SUM([Feb-2018]) * 0.00001, 0), ROUND(SUM([Mar-2018]) * 0.00001, 0),

ROUND(SUM([Apr-2018]) * 0.00001, 0), ROUND(SUM([May-2018]) * 0.00001, 0), ROUND(SUM([Jun-2018]) * 0.00001, 0), ROUND(SUM([Jul-2018]) * 0.00001, 0), 
ROUND(SUM([Aug-2018]) * 0.00001, 0), ROUND(SUM([Sep-2018]) * 0.00001, 0), ROUND(SUM([Oct-2018]) * 0.00001, 0), ROUND(SUM([Nov-2018]) * 0.00001, 0), 
ROUND(SUM([Dec-2018]) * 0.00001, 0), ROUND(SUM([Jan-2019]) * 0.00001, 0), ROUND(SUM([Feb-2019]) * 0.00001, 0), ROUND(SUM([Mar-2019]) * 0.00001, 0)
FROM #TEMPMONTH16
WHERE PropertyCategory IN ('C P P') AND Markup != 0;
--
INSERT INTO #TEMPMONTH117
SELECT '', '     HB Partners Property ( Value in Rs Lacs )', 15,
ROUND(SUM([Apr-2014]) * 0.00001, 0), ROUND(SUM([May-2014]) * 0.00001, 0), ROUND(SUM([Jun-2014]) * 0.00001, 0), ROUND(SUM([Jul-2014]) * 0.00001, 0), 
ROUND(SUM([Aug-2014]) * 0.00001, 0), ROUND(SUM([Sep-2014]) * 0.00001, 0), ROUND(SUM([Oct-2014]) * 0.00001, 0), ROUND(SUM([Nov-2014]) * 0.00001, 0), 
ROUND(SUM([Dec-2014]) * 0.00001, 0), ROUND(SUM([Jan-2015]) * 0.00001, 0), ROUND(SUM([Feb-2015]) * 0.00001, 0), ROUND(SUM([Mar-2015]) * 0.00001, 0),

ROUND(SUM([Apr-2015]) * 0.00001, 0), ROUND(SUM([May-2015]) * 0.00001, 0), ROUND(SUM([Jun-2015]) * 0.00001, 0), ROUND(SUM([Jul-2015]) * 0.00001, 0), 
ROUND(SUM([Aug-2015]) * 0.00001, 0), ROUND(SUM([Sep-2015]) * 0.00001, 0), ROUND(SUM([Oct-2015]) * 0.00001, 0), ROUND(SUM([Nov-2015]) * 0.00001, 0), 
ROUND(SUM([Dec-2015]) * 0.00001, 0), ROUND(SUM([Jan-2016]) * 0.00001, 0), ROUND(SUM([Feb-2016]) * 0.00001, 0), ROUND(SUM([Mar-2016]) * 0.00001, 0),
 
ROUND(SUM([Apr-2016]) * 0.00001, 0), ROUND(SUM([May-2016]) * 0.00001, 0), ROUND(SUM([Jun-2016]) * 0.00001, 0), ROUND(SUM([Jul-2016]) * 0.00001, 0), 
ROUND(SUM([Aug-2016]) * 0.00001, 0), ROUND(SUM([Sep-2016]) * 0.00001, 0), ROUND(SUM([Oct-2016]) * 0.00001, 0), ROUND(SUM([Nov-2016]) * 0.00001, 0), 
ROUND(SUM([Dec-2016]) * 0.00001, 0), ROUND(SUM([Jan-2017]) * 0.00001, 0), ROUND(SUM([Feb-2017]) * 0.00001, 0), ROUND(SUM([Mar-2017]) * 0.00001, 0), 

ROUND(SUM([Apr-2017]) * 0.00001, 0), ROUND(SUM([May-2017]) * 0.00001, 0), ROUND(SUM([Jun-2017]) * 0.00001, 0), ROUND(SUM([Jul-2017]) * 0.00001, 0), 
ROUND(SUM([Aug-2017]) * 0.00001, 0), ROUND(SUM([Sep-2017]) * 0.00001, 0), ROUND(SUM([Oct-2017]) * 0.00001, 0), ROUND(SUM([Nov-2017]) * 0.00001, 0), 
ROUND(SUM([Dec-2017]) * 0.00001, 0), ROUND(SUM([Jan-2018]) * 0.00001, 0), ROUND(SUM([Feb-2018]) * 0.00001, 0), ROUND(SUM([Mar-2018]) * 0.00001, 0),

ROUND(SUM([Apr-2018]) * 0.00001, 0), ROUND(SUM([May-2018]) * 0.00001, 0), ROUND(SUM([Jun-2018]) * 0.00001, 0), ROUND(SUM([Jul-2018]) * 0.00001, 0), 
ROUND(SUM([Aug-2018]) * 0.00001, 0), ROUND(SUM([Sep-2018]) * 0.00001, 0), ROUND(SUM([Oct-2018]) * 0.00001, 0), ROUND(SUM([Nov-2018]) * 0.00001, 0), 
ROUND(SUM([Dec-2018]) * 0.00001, 0), ROUND(SUM([Jan-2019]) * 0.00001, 0), ROUND(SUM([Feb-2019]) * 0.00001, 0), ROUND(SUM([Mar-2019]) * 0.00001, 0)
FROM #TEMPMONTH16
WHERE PropertyCategory IN ('External') AND Markup != 0;
/*-- TABLE 3.5
SELECT Title1, Title2,
[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017], 
[Apr-2016] + [May-2016] + [Jun-2016] + [Jul-2016] + [Aug-2016] + [Sep-2016] + [Oct-2016] + [Nov-2016] + [Dec-2016] + [Jan-2017] + [Feb-2017] + [Mar-2017] AS Total,
[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018] 
FROM #TEMPMONTH117
WHERE Flg IN (13,14,15)
ORDER BY Flg;*/
--
INSERT INTO #TEMPMONTH117
SELECT 'Hotels not Paying Commission', 'Without Commission ( Value in Rs Lacs )', 16,
ROUND(SUM([Apr-2014]) * 0.00001, 0), ROUND(SUM([May-2014]) * 0.00001, 0), ROUND(SUM([Jun-2014]) * 0.00001, 0), ROUND(SUM([Jul-2014]) * 0.00001, 0), 
ROUND(SUM([Aug-2014]) * 0.00001, 0), ROUND(SUM([Sep-2014]) * 0.00001, 0), ROUND(SUM([Oct-2014]) * 0.00001, 0), ROUND(SUM([Nov-2014]) * 0.00001, 0), 
ROUND(SUM([Dec-2014]) * 0.00001, 0), ROUND(SUM([Jan-2015]) * 0.00001, 0), ROUND(SUM([Feb-2015]) * 0.00001, 0), ROUND(SUM([Mar-2015]) * 0.00001, 0),

ROUND(SUM([Apr-2015]) * 0.00001, 0), ROUND(SUM([May-2015]) * 0.00001, 0), ROUND(SUM([Jun-2015]) * 0.00001, 0), ROUND(SUM([Jul-2015]) * 0.00001, 0), 
ROUND(SUM([Aug-2015]) * 0.00001, 0), ROUND(SUM([Sep-2015]) * 0.00001, 0), ROUND(SUM([Oct-2015]) * 0.00001, 0), ROUND(SUM([Nov-2015]) * 0.00001, 0), 
ROUND(SUM([Dec-2015]) * 0.00001, 0), ROUND(SUM([Jan-2016]) * 0.00001, 0), ROUND(SUM([Feb-2016]) * 0.00001, 0), ROUND(SUM([Mar-2016]) * 0.00001, 0),
 
ROUND(SUM([Apr-2016]) * 0.00001, 0), ROUND(SUM([May-2016]) * 0.00001, 0), ROUND(SUM([Jun-2016]) * 0.00001, 0), ROUND(SUM([Jul-2016]) * 0.00001, 0), 
ROUND(SUM([Aug-2016]) * 0.00001, 0), ROUND(SUM([Sep-2016]) * 0.00001, 0), ROUND(SUM([Oct-2016]) * 0.00001, 0), ROUND(SUM([Nov-2016]) * 0.00001, 0), 
ROUND(SUM([Dec-2016]) * 0.00001, 0), ROUND(SUM([Jan-2017]) * 0.00001, 0), ROUND(SUM([Feb-2017]) * 0.00001, 0), ROUND(SUM([Mar-2017]) * 0.00001, 0), 

ROUND(SUM([Apr-2017]) * 0.00001, 0), ROUND(SUM([May-2017]) * 0.00001, 0), ROUND(SUM([Jun-2017]) * 0.00001, 0), ROUND(SUM([Jul-2017]) * 0.00001, 0), 
ROUND(SUM([Aug-2017]) * 0.00001, 0), ROUND(SUM([Sep-2017]) * 0.00001, 0), ROUND(SUM([Oct-2017]) * 0.00001, 0), ROUND(SUM([Nov-2017]) * 0.00001, 0), 
ROUND(SUM([Dec-2017]) * 0.00001, 0), ROUND(SUM([Jan-2018]) * 0.00001, 0), ROUND(SUM([Feb-2018]) * 0.00001, 0), ROUND(SUM([Mar-2018]) * 0.00001, 0),

ROUND(SUM([Apr-2018]) * 0.00001, 0), ROUND(SUM([May-2018]) * 0.00001, 0), ROUND(SUM([Jun-2018]) * 0.00001, 0), ROUND(SUM([Jul-2018]) * 0.00001, 0), 
ROUND(SUM([Aug-2018]) * 0.00001, 0), ROUND(SUM([Sep-2018]) * 0.00001, 0), ROUND(SUM([Oct-2018]) * 0.00001, 0), ROUND(SUM([Nov-2018]) * 0.00001, 0), 
ROUND(SUM([Dec-2018]) * 0.00001, 0), ROUND(SUM([Jan-2019]) * 0.00001, 0), ROUND(SUM([Feb-2019]) * 0.00001, 0), ROUND(SUM([Mar-2019]) * 0.00001, 0)
FROM #TEMPMONTH16
WHERE Markup = 0 AND PropertyCategory IN ('External', 'C P P');
--
INSERT INTO #TEMPMONTH117
SELECT '', '     Client Preferred Property ( Value in Rs Lacs )', 17,
ROUND(SUM([Apr-2014]) * 0.00001, 0), ROUND(SUM([May-2014]) * 0.00001, 0), ROUND(SUM([Jun-2014]) * 0.00001, 0), ROUND(SUM([Jul-2014]) * 0.00001, 0), 
ROUND(SUM([Aug-2014]) * 0.00001, 0), ROUND(SUM([Sep-2014]) * 0.00001, 0), ROUND(SUM([Oct-2014]) * 0.00001, 0), ROUND(SUM([Nov-2014]) * 0.00001, 0), 
ROUND(SUM([Dec-2014]) * 0.00001, 0), ROUND(SUM([Jan-2015]) * 0.00001, 0), ROUND(SUM([Feb-2015]) * 0.00001, 0), ROUND(SUM([Mar-2015]) * 0.00001, 0),

ROUND(SUM([Apr-2015]) * 0.00001, 0), ROUND(SUM([May-2015]) * 0.00001, 0), ROUND(SUM([Jun-2015]) * 0.00001, 0), ROUND(SUM([Jul-2015]) * 0.00001, 0), 
ROUND(SUM([Aug-2015]) * 0.00001, 0), ROUND(SUM([Sep-2015]) * 0.00001, 0), ROUND(SUM([Oct-2015]) * 0.00001, 0), ROUND(SUM([Nov-2015]) * 0.00001, 0), 
ROUND(SUM([Dec-2015]) * 0.00001, 0), ROUND(SUM([Jan-2016]) * 0.00001, 0), ROUND(SUM([Feb-2016]) * 0.00001, 0), ROUND(SUM([Mar-2016]) * 0.00001, 0),
 
ROUND(SUM([Apr-2016]) * 0.00001, 0), ROUND(SUM([May-2016]) * 0.00001, 0), ROUND(SUM([Jun-2016]) * 0.00001, 0), ROUND(SUM([Jul-2016]) * 0.00001, 0), 
ROUND(SUM([Aug-2016]) * 0.00001, 0), ROUND(SUM([Sep-2016]) * 0.00001, 0), ROUND(SUM([Oct-2016]) * 0.00001, 0), ROUND(SUM([Nov-2016]) * 0.00001, 0), 
ROUND(SUM([Dec-2016]) * 0.00001, 0), ROUND(SUM([Jan-2017]) * 0.00001, 0), ROUND(SUM([Feb-2017]) * 0.00001, 0), ROUND(SUM([Mar-2017]) * 0.00001, 0), 

ROUND(SUM([Apr-2017]) * 0.00001, 0), ROUND(SUM([May-2017]) * 0.00001, 0), ROUND(SUM([Jun-2017]) * 0.00001, 0), ROUND(SUM([Jul-2017]) * 0.00001, 0), 
ROUND(SUM([Aug-2017]) * 0.00001, 0), ROUND(SUM([Sep-2017]) * 0.00001, 0), ROUND(SUM([Oct-2017]) * 0.00001, 0), ROUND(SUM([Nov-2017]) * 0.00001, 0), 
ROUND(SUM([Dec-2017]) * 0.00001, 0), ROUND(SUM([Jan-2018]) * 0.00001, 0), ROUND(SUM([Feb-2018]) * 0.00001, 0), ROUND(SUM([Mar-2018]) * 0.00001, 0),

ROUND(SUM([Apr-2018]) * 0.00001, 0), ROUND(SUM([May-2018]) * 0.00001, 0), ROUND(SUM([Jun-2018]) * 0.00001, 0), ROUND(SUM([Jul-2018]) * 0.00001, 0), 
ROUND(SUM([Aug-2018]) * 0.00001, 0), ROUND(SUM([Sep-2018]) * 0.00001, 0), ROUND(SUM([Oct-2018]) * 0.00001, 0), ROUND(SUM([Nov-2018]) * 0.00001, 0), 
ROUND(SUM([Dec-2018]) * 0.00001, 0), ROUND(SUM([Jan-2019]) * 0.00001, 0), ROUND(SUM([Feb-2019]) * 0.00001, 0), ROUND(SUM([Mar-2019]) * 0.00001, 0)
FROM #TEMPMONTH16
WHERE PropertyCategory IN ('C P P') AND Markup = 0;
--
INSERT INTO #TEMPMONTH117
SELECT '', '     HB Partners Property ( Value in Rs Lacs )', 18,
ROUND(SUM([Apr-2014]) * 0.00001, 0), ROUND(SUM([May-2014]) * 0.00001, 0), ROUND(SUM([Jun-2014]) * 0.00001, 0), ROUND(SUM([Jul-2014]) * 0.00001, 0), 
ROUND(SUM([Aug-2014]) * 0.00001, 0), ROUND(SUM([Sep-2014]) * 0.00001, 0), ROUND(SUM([Oct-2014]) * 0.00001, 0), ROUND(SUM([Nov-2014]) * 0.00001, 0), 
ROUND(SUM([Dec-2014]) * 0.00001, 0), ROUND(SUM([Jan-2015]) * 0.00001, 0), ROUND(SUM([Feb-2015]) * 0.00001, 0), ROUND(SUM([Mar-2015]) * 0.00001, 0),

ROUND(SUM([Apr-2015]) * 0.00001, 0), ROUND(SUM([May-2015]) * 0.00001, 0), ROUND(SUM([Jun-2015]) * 0.00001, 0), ROUND(SUM([Jul-2015]) * 0.00001, 0), 
ROUND(SUM([Aug-2015]) * 0.00001, 0), ROUND(SUM([Sep-2015]) * 0.00001, 0), ROUND(SUM([Oct-2015]) * 0.00001, 0), ROUND(SUM([Nov-2015]) * 0.00001, 0), 
ROUND(SUM([Dec-2015]) * 0.00001, 0), ROUND(SUM([Jan-2016]) * 0.00001, 0), ROUND(SUM([Feb-2016]) * 0.00001, 0), ROUND(SUM([Mar-2016]) * 0.00001, 0),
 
ROUND(SUM([Apr-2016]) * 0.00001, 0), ROUND(SUM([May-2016]) * 0.00001, 0), ROUND(SUM([Jun-2016]) * 0.00001, 0), ROUND(SUM([Jul-2016]) * 0.00001, 0), 
ROUND(SUM([Aug-2016]) * 0.00001, 0), ROUND(SUM([Sep-2016]) * 0.00001, 0), ROUND(SUM([Oct-2016]) * 0.00001, 0), ROUND(SUM([Nov-2016]) * 0.00001, 0), 
ROUND(SUM([Dec-2016]) * 0.00001, 0), ROUND(SUM([Jan-2017]) * 0.00001, 0), ROUND(SUM([Feb-2017]) * 0.00001, 0), ROUND(SUM([Mar-2017]) * 0.00001, 0), 

ROUND(SUM([Apr-2017]) * 0.00001, 0), ROUND(SUM([May-2017]) * 0.00001, 0), ROUND(SUM([Jun-2017]) * 0.00001, 0), ROUND(SUM([Jul-2017]) * 0.00001, 0), 
ROUND(SUM([Aug-2017]) * 0.00001, 0), ROUND(SUM([Sep-2017]) * 0.00001, 0), ROUND(SUM([Oct-2017]) * 0.00001, 0), ROUND(SUM([Nov-2017]) * 0.00001, 0), 
ROUND(SUM([Dec-2017]) * 0.00001, 0), ROUND(SUM([Jan-2018]) * 0.00001, 0), ROUND(SUM([Feb-2018]) * 0.00001, 0), ROUND(SUM([Mar-2018]) * 0.00001, 0),

ROUND(SUM([Apr-2018]) * 0.00001, 0), ROUND(SUM([May-2018]) * 0.00001, 0), ROUND(SUM([Jun-2018]) * 0.00001, 0), ROUND(SUM([Jul-2018]) * 0.00001, 0), 
ROUND(SUM([Aug-2018]) * 0.00001, 0), ROUND(SUM([Sep-2018]) * 0.00001, 0), ROUND(SUM([Oct-2018]) * 0.00001, 0), ROUND(SUM([Nov-2018]) * 0.00001, 0), 
ROUND(SUM([Dec-2018]) * 0.00001, 0), ROUND(SUM([Jan-2019]) * 0.00001, 0), ROUND(SUM([Feb-2019]) * 0.00001, 0), ROUND(SUM([Mar-2019]) * 0.00001, 0)
FROM #TEMPMONTH16
WHERE PropertyCategory IN ('External') AND Markup = 0;
/*-- TABLE 3.6
SELECT Title1, Title2,
[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017], 
[Apr-2016] + [May-2016] + [Jun-2016] + [Jul-2016] + [Aug-2016] + [Sep-2016] + [Oct-2016] + [Nov-2016] + [Dec-2016] + [Jan-2017] + [Feb-2017] + [Mar-2017] AS Total,
[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018] 
FROM #TEMPMONTH117
WHERE Flg IN (16,17,18)
ORDER BY Flg;*/
--
CREATE TABLE #TEMPMONTH22(MonthofBooking NVARCHAR(100),Markup DECIMAL(27,2),PropertyCategory NVARCHAR(100));
INSERT INTO #TEMPMONTH22(MonthofBooking,Markup,PropertyCategory)
SELECT asasd,SUM(MarkUp),PropertyCategory FROM #TEMP2 
WHERE MarkUp != 0 AND PropertyCategory IN ('External', 'C P P') 
GROUP BY asasd,PropertyCategory;
--
SELECT   PropertyCategory,
         [Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
		 [Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
		 [Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
		 [Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
		 [Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019]
INTO #TEMPMONTH23
FROM #TEMPMONTH22
PIVOT
(
       SUM(MarkUp)
       FOR MonthofBooking IN 
	   ([Apr-2014], [May-2014], [Jun-2014], [Jul-2014], [Aug-2014], [Sep-2014], [Oct-2014], [Nov-2014], [Dec-2014], [Jan-2015], [Feb-2015], [Mar-2015],
		[Apr-2015], [May-2015], [Jun-2015], [Jul-2015], [Aug-2015], [Sep-2015], [Oct-2015], [Nov-2015], [Dec-2015], [Jan-2016], [Feb-2016], [Mar-2016],
		[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017],
		[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018],
		[Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019])
) AS P;
--
CREATE TABLE #TEMPMONTH24(PropertyCategory NVARCHAR(100),
[Apr-2014] INT, [May-2014] INT, [Jun-2014] INT, [Jul-2014] INT, [Aug-2014] INT, [Sep-2014] INT, [Oct-2014] INT, [Nov-2014] INT, [Dec-2014] INT, 
[Jan-2015] INT, [Feb-2015] INT, [Mar-2015] INT,
[Apr-2015] INT, [May-2015] INT, [Jun-2015] INT, [Jul-2015] INT, [Aug-2015] INT, [Sep-2015] INT, [Oct-2015] INT, [Nov-2015] INT, [Dec-2015] INT, 
[Jan-2016] INT, [Feb-2016] INT, [Mar-2016] INT, 
[Apr-2016] INT, [May-2016] INT, [Jun-2016] INT, [Jul-2016] INT, [Aug-2016] INT, [Sep-2016] INT, [Oct-2016] INT, [Nov-2016] INT, [Dec-2016] INT, 
[Jan-2017] INT, [Feb-2017] INT, [Mar-2017] INT, 
[Apr-2017] INT, [May-2017] INT, [Jun-2017] INT, [Jul-2017] INT, [Aug-2017] INT, [Sep-2017] INT, [Oct-2017] INT, [Nov-2017] INT, [Dec-2017] INT,
[Jan-2018] INT, [Feb-2018] INT, [Mar-2018] INT,
[Apr-2018] INT, [May-2018] INT, [Jun-2018] INT, [Jul-2018] INT, [Aug-2018] INT, [Sep-2018] INT, [Oct-2018] INT, [Nov-2018] INT, [Dec-2018] INT,
[Jan-2019] INT, [Feb-2019] INT, [Mar-2019] INT);
---
INSERT INTO #TEMPMONTH24
SELECT PropertyCategory,
ISNULL([Apr-2014],0), ISNULL([May-2014],0), ISNULL([Jun-2014],0), ISNULL([Jul-2014],0), ISNULL([Aug-2014],0), ISNULL([Sep-2014],0), ISNULL([Oct-2014],0), 
ISNULL([Nov-2014],0), ISNULL([Dec-2014],0), ISNULL([Jan-2015],0), ISNULL([Feb-2015],0), ISNULL([Mar-2015],0), 
ISNULL([Apr-2015],0), ISNULL([May-2015],0), ISNULL([Jun-2015],0), ISNULL([Jul-2015],0), ISNULL([Aug-2015],0), ISNULL([Sep-2015],0), ISNULL([Oct-2015],0), 
ISNULL([Nov-2015],0), ISNULL([Dec-2015],0), ISNULL([Jan-2016],0), ISNULL([Feb-2016],0), ISNULL([Mar-2016],0), 
ISNULL([Apr-2016],0), ISNULL([May-2016],0), ISNULL([Jun-2016],0), ISNULL([Jul-2016],0), ISNULL([Aug-2016],0), ISNULL([Sep-2016],0), ISNULL([Oct-2016],0), 
ISNULL([Nov-2016],0), ISNULL([Dec-2016],0), ISNULL([Jan-2017],0), ISNULL([Feb-2017],0), ISNULL([Mar-2017],0), 
ISNULL([Apr-2017],0), ISNULL([May-2017],0), ISNULL([Jun-2017],0), ISNULL([Jul-2017],0), ISNULL([Aug-2017],0), ISNULL([Sep-2017],0), ISNULL([Oct-2017],0), 
ISNULL([Nov-2017],0), ISNULL([Dec-2017],0), ISNULL([Jan-2018],0), ISNULL([Feb-2018],0), ISNULL([Mar-2018],0),
ISNULL([Apr-2018],0), ISNULL([May-2018],0), ISNULL([Jun-2018],0), ISNULL([Jul-2018],0), ISNULL([Aug-2018],0), ISNULL([Sep-2018],0), ISNULL([Oct-2018],0), 
ISNULL([Nov-2018],0), ISNULL([Dec-2018],0), ISNULL([Jan-2019],0), ISNULL([Feb-2019],0), ISNULL([Mar-2019],0)  from #TEMPMONTH23;
--
CREATE TABLE #TEMPMONTH25(Title NVARCHAR(100), Flg INT,
[Apr-2014] INT, [May-2014] INT, [Jun-2014] INT, [Jul-2014] INT, [Aug-2014] INT, [Sep-2014] INT, [Oct-2014] INT, [Nov-2014] INT, [Dec-2014] INT, 
[Jan-2015] INT, [Feb-2015] INT, [Mar-2015] INT,
[Apr-2015] INT, [May-2015] INT, [Jun-2015] INT, [Jul-2015] INT, [Aug-2015] INT, [Sep-2015] INT, [Oct-2015] INT, [Nov-2015] INT, [Dec-2015] INT, 
[Jan-2016] INT, [Feb-2016] INT, [Mar-2016] INT, 
[Apr-2016] INT, [May-2016] INT, [Jun-2016] INT, [Jul-2016] INT, [Aug-2016] INT, [Sep-2016] INT, [Oct-2016] INT, [Nov-2016] INT, [Dec-2016] INT, 
[Jan-2017] INT, [Feb-2017] INT, [Mar-2017] INT, 
[Apr-2017] INT, [May-2017] INT, [Jun-2017] INT, [Jul-2017] INT, [Aug-2017] INT, [Sep-2017] INT, [Oct-2017] INT, [Nov-2017] INT, [Dec-2017] INT,
[Jan-2018] INT, [Feb-2018] INT, [Mar-2018] INT,
[Apr-2018] INT, [May-2018] INT, [Jun-2018] INT, [Jul-2018] INT, [Aug-2018] INT, [Sep-2018] INT, [Oct-2018] INT, [Nov-2018] INT, [Dec-2018] INT,
[Jan-2019] INT, [Feb-2019] INT, [Mar-2019] INT);
--
INSERT INTO #TEMPMONTH25
SELECT 'With Commission ( Value in Lacs)', 1,
ROUND(SUM([Apr-2014]) * 0.00001, 0), ROUND(SUM([May-2014]) * 0.00001, 0), ROUND(SUM([Jun-2014]) * 0.00001, 0), ROUND(SUM([Jul-2014]) * 0.00001, 0), 
ROUND(SUM([Aug-2014]) * 0.00001, 0), ROUND(SUM([Sep-2014]) * 0.00001, 0), ROUND(SUM([Oct-2014]) * 0.00001, 0), ROUND(SUM([Nov-2014]) * 0.00001, 0), 
ROUND(SUM([Dec-2014]) * 0.00001, 0), ROUND(SUM([Jan-2015]) * 0.00001, 0), ROUND(SUM([Feb-2015]) * 0.00001, 0), ROUND(SUM([Mar-2015]) * 0.00001, 0),

ROUND(SUM([Apr-2015]) * 0.00001, 0), ROUND(SUM([May-2015]) * 0.00001, 0), ROUND(SUM([Jun-2015]) * 0.00001, 0), ROUND(SUM([Jul-2015]) * 0.00001, 0), 
ROUND(SUM([Aug-2015]) * 0.00001, 0), ROUND(SUM([Sep-2015]) * 0.00001, 0), ROUND(SUM([Oct-2015]) * 0.00001, 0), ROUND(SUM([Nov-2015]) * 0.00001, 0), 
ROUND(SUM([Dec-2015]) * 0.00001, 0), ROUND(SUM([Jan-2016]) * 0.00001, 0), ROUND(SUM([Feb-2016]) * 0.00001, 0), ROUND(SUM([Mar-2016]) * 0.00001, 0),
 
ROUND(SUM([Apr-2016]) * 0.00001, 0), ROUND(SUM([May-2016]) * 0.00001, 0), ROUND(SUM([Jun-2016]) * 0.00001, 0), ROUND(SUM([Jul-2016]) * 0.00001, 0), 
ROUND(SUM([Aug-2016]) * 0.00001, 0), ROUND(SUM([Sep-2016]) * 0.00001, 0), ROUND(SUM([Oct-2016]) * 0.00001, 0), ROUND(SUM([Nov-2016]) * 0.00001, 0), 
ROUND(SUM([Dec-2016]) * 0.00001, 0), ROUND(SUM([Jan-2017]) * 0.00001, 0), ROUND(SUM([Feb-2017]) * 0.00001, 0), ROUND(SUM([Mar-2017]) * 0.00001, 0), 

ROUND(SUM([Apr-2017]) * 0.00001, 0), ROUND(SUM([May-2017]) * 0.00001, 0), ROUND(SUM([Jun-2017]) * 0.00001, 0), ROUND(SUM([Jul-2017]) * 0.00001, 0), 
ROUND(SUM([Aug-2017]) * 0.00001, 0), ROUND(SUM([Sep-2017]) * 0.00001, 0), ROUND(SUM([Oct-2017]) * 0.00001, 0), ROUND(SUM([Nov-2017]) * 0.00001, 0), 
ROUND(SUM([Dec-2017]) * 0.00001, 0), ROUND(SUM([Jan-2018]) * 0.00001, 0), ROUND(SUM([Feb-2018]) * 0.00001, 0), ROUND(SUM([Mar-2018]) * 0.00001, 0),

ROUND(SUM([Apr-2018]) * 0.00001, 0), ROUND(SUM([May-2018]) * 0.00001, 0), ROUND(SUM([Jun-2018]) * 0.00001, 0), ROUND(SUM([Jul-2018]) * 0.00001, 0), 
ROUND(SUM([Aug-2018]) * 0.00001, 0), ROUND(SUM([Sep-2018]) * 0.00001, 0), ROUND(SUM([Oct-2018]) * 0.00001, 0), ROUND(SUM([Nov-2018]) * 0.00001, 0), 
ROUND(SUM([Dec-2018]) * 0.00001, 0), ROUND(SUM([Jan-2019]) * 0.00001, 0), ROUND(SUM([Feb-2019]) * 0.00001, 0), ROUND(SUM([Mar-2019]) * 0.00001, 0)
FROM #TEMPMONTH24;
--
INSERT INTO #TEMPMONTH25
SELECT '     Client Preferred Property ( Value in Lacs )', 2,
ROUND(SUM([Apr-2014]) * 0.00001, 0), ROUND(SUM([May-2014]) * 0.00001, 0), ROUND(SUM([Jun-2014]) * 0.00001, 0), ROUND(SUM([Jul-2014]) * 0.00001, 0), 
ROUND(SUM([Aug-2014]) * 0.00001, 0), ROUND(SUM([Sep-2014]) * 0.00001, 0), ROUND(SUM([Oct-2014]) * 0.00001, 0), ROUND(SUM([Nov-2014]) * 0.00001, 0), 
ROUND(SUM([Dec-2014]) * 0.00001, 0), ROUND(SUM([Jan-2015]) * 0.00001, 0), ROUND(SUM([Feb-2015]) * 0.00001, 0), ROUND(SUM([Mar-2015]) * 0.00001, 0),

ROUND(SUM([Apr-2015]) * 0.00001, 0), ROUND(SUM([May-2015]) * 0.00001, 0), ROUND(SUM([Jun-2015]) * 0.00001, 0), ROUND(SUM([Jul-2015]) * 0.00001, 0), 
ROUND(SUM([Aug-2015]) * 0.00001, 0), ROUND(SUM([Sep-2015]) * 0.00001, 0), ROUND(SUM([Oct-2015]) * 0.00001, 0), ROUND(SUM([Nov-2015]) * 0.00001, 0), 
ROUND(SUM([Dec-2015]) * 0.00001, 0), ROUND(SUM([Jan-2016]) * 0.00001, 0), ROUND(SUM([Feb-2016]) * 0.00001, 0), ROUND(SUM([Mar-2016]) * 0.00001, 0),
 
ROUND(SUM([Apr-2016]) * 0.00001, 0), ROUND(SUM([May-2016]) * 0.00001, 0), ROUND(SUM([Jun-2016]) * 0.00001, 0), ROUND(SUM([Jul-2016]) * 0.00001, 0), 
ROUND(SUM([Aug-2016]) * 0.00001, 0), ROUND(SUM([Sep-2016]) * 0.00001, 0), ROUND(SUM([Oct-2016]) * 0.00001, 0), ROUND(SUM([Nov-2016]) * 0.00001, 0), 
ROUND(SUM([Dec-2016]) * 0.00001, 0), ROUND(SUM([Jan-2017]) * 0.00001, 0), ROUND(SUM([Feb-2017]) * 0.00001, 0), ROUND(SUM([Mar-2017]) * 0.00001, 0), 

ROUND(SUM([Apr-2017]) * 0.00001, 0), ROUND(SUM([May-2017]) * 0.00001, 0), ROUND(SUM([Jun-2017]) * 0.00001, 0), ROUND(SUM([Jul-2017]) * 0.00001, 0), 
ROUND(SUM([Aug-2017]) * 0.00001, 0), ROUND(SUM([Sep-2017]) * 0.00001, 0), ROUND(SUM([Oct-2017]) * 0.00001, 0), ROUND(SUM([Nov-2017]) * 0.00001, 0), 
ROUND(SUM([Dec-2017]) * 0.00001, 0), ROUND(SUM([Jan-2018]) * 0.00001, 0), ROUND(SUM([Feb-2018]) * 0.00001, 0), ROUND(SUM([Mar-2018]) * 0.00001, 0),

ROUND(SUM([Apr-2018]) * 0.00001, 0), ROUND(SUM([May-2018]) * 0.00001, 0), ROUND(SUM([Jun-2018]) * 0.00001, 0), ROUND(SUM([Jul-2018]) * 0.00001, 0), 
ROUND(SUM([Aug-2018]) * 0.00001, 0), ROUND(SUM([Sep-2018]) * 0.00001, 0), ROUND(SUM([Oct-2018]) * 0.00001, 0), ROUND(SUM([Nov-2018]) * 0.00001, 0), 
ROUND(SUM([Dec-2018]) * 0.00001, 0), ROUND(SUM([Jan-2019]) * 0.00001, 0), ROUND(SUM([Feb-2019]) * 0.00001, 0), ROUND(SUM([Mar-2019]) * 0.00001, 0)
FROM #TEMPMONTH24
WHERE PropertyCategory IN ('C P P');
--
INSERT INTO #TEMPMONTH25
SELECT '     HB Partners Property ( Value in Lacs )', 3,
ROUND(SUM([Apr-2014]) * 0.00001, 0), ROUND(SUM([May-2014]) * 0.00001, 0), ROUND(SUM([Jun-2014]) * 0.00001, 0), ROUND(SUM([Jul-2014]) * 0.00001, 0), 
ROUND(SUM([Aug-2014]) * 0.00001, 0), ROUND(SUM([Sep-2014]) * 0.00001, 0), ROUND(SUM([Oct-2014]) * 0.00001, 0), ROUND(SUM([Nov-2014]) * 0.00001, 0), 
ROUND(SUM([Dec-2014]) * 0.00001, 0), ROUND(SUM([Jan-2015]) * 0.00001, 0), ROUND(SUM([Feb-2015]) * 0.00001, 0), ROUND(SUM([Mar-2015]) * 0.00001, 0),

ROUND(SUM([Apr-2015]) * 0.00001, 0), ROUND(SUM([May-2015]) * 0.00001, 0), ROUND(SUM([Jun-2015]) * 0.00001, 0), ROUND(SUM([Jul-2015]) * 0.00001, 0), 
ROUND(SUM([Aug-2015]) * 0.00001, 0), ROUND(SUM([Sep-2015]) * 0.00001, 0), ROUND(SUM([Oct-2015]) * 0.00001, 0), ROUND(SUM([Nov-2015]) * 0.00001, 0), 
ROUND(SUM([Dec-2015]) * 0.00001, 0), ROUND(SUM([Jan-2016]) * 0.00001, 0), ROUND(SUM([Feb-2016]) * 0.00001, 0), ROUND(SUM([Mar-2016]) * 0.00001, 0),
 
ROUND(SUM([Apr-2016]) * 0.00001, 0), ROUND(SUM([May-2016]) * 0.00001, 0), ROUND(SUM([Jun-2016]) * 0.00001, 0), ROUND(SUM([Jul-2016]) * 0.00001, 0), 
ROUND(SUM([Aug-2016]) * 0.00001, 0), ROUND(SUM([Sep-2016]) * 0.00001, 0), ROUND(SUM([Oct-2016]) * 0.00001, 0), ROUND(SUM([Nov-2016]) * 0.00001, 0), 
ROUND(SUM([Dec-2016]) * 0.00001, 0), ROUND(SUM([Jan-2017]) * 0.00001, 0), ROUND(SUM([Feb-2017]) * 0.00001, 0), ROUND(SUM([Mar-2017]) * 0.00001, 0), 

ROUND(SUM([Apr-2017]) * 0.00001, 0), ROUND(SUM([May-2017]) * 0.00001, 0), ROUND(SUM([Jun-2017]) * 0.00001, 0), ROUND(SUM([Jul-2017]) * 0.00001, 0), 
ROUND(SUM([Aug-2017]) * 0.00001, 0), ROUND(SUM([Sep-2017]) * 0.00001, 0), ROUND(SUM([Oct-2017]) * 0.00001, 0), ROUND(SUM([Nov-2017]) * 0.00001, 0), 
ROUND(SUM([Dec-2017]) * 0.00001, 0), ROUND(SUM([Jan-2018]) * 0.00001, 0), ROUND(SUM([Feb-2018]) * 0.00001, 0), ROUND(SUM([Mar-2018]) * 0.00001, 0),

ROUND(SUM([Apr-2018]) * 0.00001, 0), ROUND(SUM([May-2018]) * 0.00001, 0), ROUND(SUM([Jun-2018]) * 0.00001, 0), ROUND(SUM([Jul-2018]) * 0.00001, 0), 
ROUND(SUM([Aug-2018]) * 0.00001, 0), ROUND(SUM([Sep-2018]) * 0.00001, 0), ROUND(SUM([Oct-2018]) * 0.00001, 0), ROUND(SUM([Nov-2018]) * 0.00001, 0), 
ROUND(SUM([Dec-2018]) * 0.00001, 0), ROUND(SUM([Jan-2019]) * 0.00001, 0), ROUND(SUM([Feb-2019]) * 0.00001, 0), ROUND(SUM([Mar-2019]) * 0.00001, 0)
FROM #TEMPMONTH24
WHERE PropertyCategory NOT IN ('C P P');
-- TABLE 5
/*SELECT Title,
[Apr-2016], [May-2016], [Jun-2016], [Jul-2016], [Aug-2016], [Sep-2016], [Oct-2016], [Nov-2016], [Dec-2016], [Jan-2017], [Feb-2017], [Mar-2017], 
[Apr-2016] + [May-2016] + [Jun-2016] + [Jul-2016] + [Aug-2016] + [Sep-2016] + [Oct-2016] + [Nov-2016] + [Dec-2016] + [Jan-2017] + [Feb-2017] + [Mar-2017] AS Total,
[Apr-2017], [May-2017], [Jun-2017], [Jul-2017], [Aug-2017], [Sep-2017], [Oct-2017], [Nov-2017], [Dec-2017], [Jan-2018], [Feb-2018], [Mar-2018] 
FROM #TEMPMONTH25
ORDER BY Flg;*/

-- Result

SELECT '' AS C1,
'Jun-2018' AS C22, 'May-2018' AS C2, 'Apr-2018' AS C3,
'Total' AS Total,
'Mar-18' AS C4, 'Feb-18' AS C5, 'Jan-18' AS C6, 'Dec-17' AS C7, 'Nov-17' AS C8, 'Oct-17' AS C9, 'Sep-17' AS C10, 'Aug-17' AS C11, 'Jul-17' AS C12, 'Jun-17' AS C13, 
'May-17' AS C14, 'Apr-17' AS C15;

-- TABLE 1
SELECT 'HB Universe' AS Title;
SELECT '', Title,
[Jun-2018], [May-2018], [Apr-2018],
[Mar-2018] + [Feb-2018] + [Jan-2018] + [Dec-2017] + [Nov-2017] + [Oct-2017] + [Sep-2017] + [Aug-2017] + [Jul-2017] + [Jun-2017] + [May-2017] + [Apr-2017] AS Total,
[Mar-2018], [Feb-2018], [Jan-2018], [Dec-2017], [Nov-2017], [Oct-2017], [Sep-2017], [Aug-2017], [Jul-2017], [Jun-2017], [May-2017], [Apr-2017]
FROM #TEMPMONTH4 
WHERE Flg IN (1,2,3,5)
ORDER BY Flg;
-- Table 2
SELECT 'Room night' AS Title;
-- Table 2.1
SELECT Title1, Title2,
[Jun-2018], [May-2018], [Apr-2018],
[Mar-2018] + [Feb-2018] + [Jan-2018] + [Dec-2017] + [Nov-2017] + [Oct-2017] + [Sep-2017] + [Aug-2017] + [Jul-2017] + [Jun-2017] + [May-2017] + [Apr-2017] AS Total,
[Mar-2018], [Feb-2018], [Jan-2018], [Dec-2017], [Nov-2017], [Oct-2017], [Sep-2017], [Aug-2017], [Jul-2017], [Jun-2017], [May-2017], [Apr-2017]
FROM #TEMPMONTH11
WHERE Flg IN (1,2,4)
ORDER BY Flg;
-- Table 2.2
SELECT Title1, Title2,
[Jun-2018], [May-2018], [Apr-2018],
[Mar-2018] + [Feb-2018] + [Jan-2018] + [Dec-2017] + [Nov-2017] + [Oct-2017] + [Sep-2017] + [Aug-2017] + [Jul-2017] + [Jun-2017] + [May-2017] + [Apr-2017] AS Total,
[Mar-2018], [Feb-2018], [Jan-2018], [Dec-2017], [Nov-2017], [Oct-2017], [Sep-2017], [Aug-2017], [Jul-2017], [Jun-2017], [May-2017], [Apr-2017]
FROM #TEMPMONTH13
WHERE Flg IN (1,2)
ORDER BY Flg;
-- Table 2.3
SELECT Title1, Title2,
[Jun-2018], [May-2018], [Apr-2018],
[Mar-2018] + [Feb-2018] + [Jan-2018] + [Dec-2017] + [Nov-2017] + [Oct-2017] + [Sep-2017] + [Aug-2017] + [Jul-2017] + [Jun-2017] + [May-2017] + [Apr-2017] AS Total,
[Mar-2018], [Feb-2018], [Jan-2018], [Dec-2017], [Nov-2017], [Oct-2017], [Sep-2017], [Aug-2017], [Jul-2017], [Jun-2017], [May-2017], [Apr-2017]
FROM #TEMPMONTH13
WHERE Flg IN (3, 4, 5)
ORDER BY Flg;
-- Table 2.4
SELECT Title1, Title2,
[Jun-2018], [May-2018], [Apr-2018],
[Mar-2018] + [Feb-2018] + [Jan-2018] + [Dec-2017] + [Nov-2017] + [Oct-2017] + [Sep-2017] + [Aug-2017] + [Jul-2017] + [Jun-2017] + [May-2017] + [Apr-2017] AS Total,
[Mar-2018], [Feb-2018], [Jan-2018], [Dec-2017], [Nov-2017], [Oct-2017], [Sep-2017], [Aug-2017], [Jul-2017], [Jun-2017], [May-2017], [Apr-2017]
FROM #TEMPMONTH13
WHERE Flg IN (6, 7, 8)
ORDER BY Flg;
-- TABLE 3
SELECT 'GTV' AS Title;
-- TABLE 3.1
SELECT Title1, Title2,
[Jun-2018], [May-2018], [Apr-2018],
[Mar-2018] + [Feb-2018] + [Jan-2018] + [Dec-2017] + [Nov-2017] + [Oct-2017] + [Sep-2017] + [Aug-2017] + [Jul-2017] + [Jun-2017] + [May-2017] + [Apr-2017] AS Total,
[Mar-2018], [Feb-2018], [Jan-2018], [Dec-2017], [Nov-2017], [Oct-2017], [Sep-2017], [Aug-2017], [Jul-2017], [Jun-2017], [May-2017], [Apr-2017]
FROM #TEMPMONTH117
WHERE Flg IN (1,2,5)
ORDER BY Flg;
-- TABLE 3.2
 SELECT Title1, Title2,
[Jun-2018], [May-2018], [Apr-2018],
[Mar-2018] + [Feb-2018] + [Jan-2018] + [Dec-2017] + [Nov-2017] + [Oct-2017] + [Sep-2017] + [Aug-2017] + [Jul-2017] + [Jun-2017] + [May-2017] + [Apr-2017] AS Total,
[Mar-2018], [Feb-2018], [Jan-2018], [Dec-2017], [Nov-2017], [Oct-2017], [Sep-2017], [Aug-2017], [Jul-2017], [Jun-2017], [May-2017], [Apr-2017]
FROM #TEMPMONTH117
WHERE Flg IN (6,7)
ORDER BY Flg;
-- TABLE 3.3
SELECT Title1, Title2,
[Jun-2018], [May-2018], [Apr-2018],
[Mar-2018] + [Feb-2018] + [Jan-2018] + [Dec-2017] + [Nov-2017] + [Oct-2017] + [Sep-2017] + [Aug-2017] + [Jul-2017] + [Jun-2017] + [May-2017] + [Apr-2017] AS Total,
[Mar-2018], [Feb-2018], [Jan-2018], [Dec-2017], [Nov-2017], [Oct-2017], [Sep-2017], [Aug-2017], [Jul-2017], [Jun-2017], [May-2017], [Apr-2017]
FROM #TEMPMONTH117
WHERE Flg IN (8,9)
ORDER BY Flg;
-- TABLE 3.4
SELECT Title1, Title2,
[Jun-2018], [May-2018], [Apr-2018],
[Mar-2018] + [Feb-2018] + [Jan-2018] + [Dec-2017] + [Nov-2017] + [Oct-2017] + [Sep-2017] + [Aug-2017] + [Jul-2017] + [Jun-2017] + [May-2017] + [Apr-2017] AS Total,
[Mar-2018], [Feb-2018], [Jan-2018], [Dec-2017], [Nov-2017], [Oct-2017], [Sep-2017], [Aug-2017], [Jul-2017], [Jun-2017], [May-2017], [Apr-2017]
FROM #TEMPMONTH117
WHERE Flg IN (10,11,12)
ORDER BY Flg;
-- TABLE 3.5
SELECT Title1, Title2,
[Jun-2018], [May-2018], [Apr-2018],
[Mar-2018] + [Feb-2018] + [Jan-2018] + [Dec-2017] + [Nov-2017] + [Oct-2017] + [Sep-2017] + [Aug-2017] + [Jul-2017] + [Jun-2017] + [May-2017] + [Apr-2017] AS Total,
[Mar-2018], [Feb-2018], [Jan-2018], [Dec-2017], [Nov-2017], [Oct-2017], [Sep-2017], [Aug-2017], [Jul-2017], [Jun-2017], [May-2017], [Apr-2017]
FROM #TEMPMONTH117
WHERE Flg IN (13,14,15)
ORDER BY Flg;
-- TABLE 3.6
SELECT Title1, Title2,
[Jun-2018], [May-2018], [Apr-2018],
[Mar-2018] + [Feb-2018] + [Jan-2018] + [Dec-2017] + [Nov-2017] + [Oct-2017] + [Sep-2017] + [Aug-2017] + [Jul-2017] + [Jun-2017] + [May-2017] + [Apr-2017] AS Total,
[Mar-2018], [Feb-2018], [Jan-2018], [Dec-2017], [Nov-2017], [Oct-2017], [Sep-2017], [Aug-2017], [Jul-2017], [Jun-2017], [May-2017], [Apr-2017]
FROM #TEMPMONTH117
WHERE Flg IN (16,17,18)
ORDER BY Flg;
-- TABLE 4
-- TABLE 4.1
SELECT 'Ratio %' AS Title;
SELECT '' AS Title1, REPLACE(T1.Title2,' ( Value in Rs Lacs )','') AS Title2,
CAST(CAST(ROUND(((T1.[Jun-2018] * 10000) / T2.[Jun-2018]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Jun-2018],
CAST(CAST(ROUND(((T1.[May-2018] * 10000) / T2.[May-2018]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [May-2018],
CAST(CAST(ROUND(((T1.[Apr-2018] * 10000) / T2.[Apr-2018]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Apr-2018],
CAST(CAST(ROUND((((T1.[Apr-2017] + T1.[May-2017] + T1.[Jun-2017] + T1.[Jul-2017] + T1.[Aug-2017] + T1.[Sep-2017] + T1.[Oct-2017] + 
T1.[Nov-2017] + T1.[Dec-2017] + T1.[Jan-2018] + T1.[Feb-2018] + T1.[Mar-2018]) * 10000) / 
(T2.[Apr-2017] + T2.[May-2017] + T2.[Jun-2017] + T2.[Jul-2017] + T2.[Aug-2017] + T2.[Sep-2017] + T2.[Oct-2017] + 
T2.[Nov-2017] + T2.[Dec-2017] + T2.[Jan-2018] + T2.[Feb-2018] + T2.[Mar-2018])) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS Total,
CAST(CAST(ROUND(((T1.[Mar-2018] * 10000) / T2.[Mar-2018]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Mar-2018],
CAST(CAST(ROUND(((T1.[Feb-2018] * 10000) / T2.[Feb-2018]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Feb-2018],
CAST(CAST(ROUND(((T1.[Jan-2018] * 10000) / T2.[Jan-2018]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Jan-2018],
CAST(CAST(ROUND(((T1.[Dec-2017] * 10000) / T2.[Dec-2017]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Dec-2017],
CAST(CAST(ROUND(((T1.[Nov-2017] * 10000) / T2.[Nov-2017]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Nov-2017],
CAST(CAST(ROUND(((T1.[Oct-2017] * 10000) / T2.[Oct-2017]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Oct-2017],
CAST(CAST(ROUND(((T1.[Sep-2017] * 10000) / T2.[Sep-2017]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Sep-2017],
CAST(CAST(ROUND(((T1.[Aug-2017] * 10000) / T2.[Aug-2017]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Aug-2017],
CAST(CAST(ROUND(((T1.[Jul-2017] * 10000) / T2.[Jul-2017]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Jul-2017],
CAST(CAST(ROUND(((T1.[Jun-2017] * 10000) / T2.[Jun-2017]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Jun-2017], 
CAST(CAST(ROUND(((T1.[May-2017] * 10000) / T2.[May-2017]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [May-2017],
CAST(CAST(ROUND(((T1.[Apr-2017] * 10000) / T2.[Apr-2017]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Apr-2017]
FROM #TEMPMONTH117 T1
LEFT OUTER JOIN #TEMPMONTH117 T2 WITH(NOLOCK)ON T2.Flg = 1
WHERE T1.Flg IN (13, 14, 15)
ORDER BY T1.Flg;
-- TABLE 4.2
SELECT 'Opportunity %' AS Title;
SELECT '' AS Title1, REPLACE(T1.Title2,' ( Value in Rs Lacs )','') AS Title2,
CAST(CAST(ROUND(((T1.[Jun-2018] * 10000) / T2.[Jun-2018]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Jun-2018],
CAST(CAST(ROUND(((T1.[May-2018] * 10000) / T2.[May-2018]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [May-2018],
CAST(CAST(ROUND(((T1.[Apr-2018] * 10000) / T2.[Apr-2018]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Apr-2018],
CAST(CAST(ROUND((((T1.[Apr-2017] + T1.[May-2017] + T1.[Jun-2017] + T1.[Jul-2017] + T1.[Aug-2017] + T1.[Sep-2017] + T1.[Oct-2017] + 
T1.[Nov-2017] + T1.[Dec-2017] + T1.[Jan-2018] + T1.[Feb-2018] + T1.[Mar-2018]) * 10000) / 
(T2.[Apr-2017] + T2.[May-2017] + T2.[Jun-2017] + T2.[Jul-2017] + T2.[Aug-2017] + T2.[Sep-2017] + T2.[Oct-2017] + 
T2.[Nov-2017] + T2.[Dec-2017] + T2.[Jan-2018] + T2.[Feb-2018] + T2.[Mar-2018])) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS Total,
CAST(CAST(ROUND(((T1.[Mar-2018] * 10000) / T2.[Mar-2018]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Mar-2018],
CAST(CAST(ROUND(((T1.[Feb-2018] * 10000) / T2.[Feb-2018]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Feb-2018],
CAST(CAST(ROUND(((T1.[Jan-2018] * 10000) / T2.[Jan-2018]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Jan-2018],
CAST(CAST(ROUND(((T1.[Dec-2017] * 10000) / T2.[Dec-2017]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Dec-2017],
CAST(CAST(ROUND(((T1.[Nov-2017] * 10000) / T2.[Nov-2017]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Nov-2017],
CAST(CAST(ROUND(((T1.[Oct-2017] * 10000) / T2.[Oct-2017]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Oct-2017],
CAST(CAST(ROUND(((T1.[Sep-2017] * 10000) / T2.[Sep-2017]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Sep-2017],
CAST(CAST(ROUND(((T1.[Aug-2017] * 10000) / T2.[Aug-2017]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Aug-2017],
CAST(CAST(ROUND(((T1.[Jul-2017] * 10000) / T2.[Jul-2017]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Jul-2017],
CAST(CAST(ROUND(((T1.[Jun-2017] * 10000) / T2.[Jun-2017]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Jun-2017], 
CAST(CAST(ROUND(((T1.[May-2017] * 10000) / T2.[May-2017]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [May-2017],
CAST(CAST(ROUND(((T1.[Apr-2017] * 10000) / T2.[Apr-2017]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Apr-2017]
FROM #TEMPMONTH117 T1
LEFT OUTER JOIN #TEMPMONTH117 T2 WITH(NOLOCK)ON T2.Flg = 1
WHERE T1.Flg IN (16, 17, 18)
ORDER BY T1.Flg;
-- TABLE 5
SELECT 'Net Revenue' AS Title;
-- TABLE 5.1
SELECT '' AS Title1, Title AS Title2,
[Jun-2018], [May-2018], [Apr-2018],
[Mar-2018] + [Feb-2018] + [Jan-2018] + [Dec-2017] + [Nov-2017] + [Oct-2017] + [Sep-2017] + [Aug-2017] + [Jul-2017] + [Jun-2017] + [May-2017] + [Apr-2017] AS Total,
[Mar-2018], [Feb-2018], [Jan-2018], [Dec-2017], [Nov-2017], [Oct-2017], [Sep-2017], [Aug-2017], [Jul-2017], [Jun-2017], [May-2017], [Apr-2017]
FROM #TEMPMONTH25
ORDER BY Flg;

----- Monthly Analysis Report End -----

END
END