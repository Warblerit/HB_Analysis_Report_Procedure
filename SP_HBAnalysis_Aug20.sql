-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[SP_HBAnalysis_Aug20]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
DROP PROCEDURE [dbo].[SP_HBAnalysis_Aug20]
GO
CREATE PROCEDURE [dbo].[SP_HBAnalysis_Aug20](@Action NVARCHAR(100), @Str NVARCHAR(100), @Id BIGINT)  
/*  
Exec [dbo].[SP_HBAnalysis_Aug20] @Action = '',@Str = '',@Id = 0;  
*/  
AS  
BEGIN  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF  
IF @Action = ''  
BEGIN  
  
CREATE TABLE #TEMP1(BookingCode BIGINT, CheckInDt DATE, CheckOutDt DATE, Tariff DECIMAL(27,2), MarkUp DECIMAL(27,2), PropertyId BIGINT, MasterPropertyId BIGINT,  
RoomCaptured BIGINT, BookingId BIGINT, CityId BIGINT, PropertyCategory NVARCHAR(100), ClientId BIGINT, MasterClientId BIGINT, BookedDt VARCHAR(100));  
  
INSERT INTO #TEMP1  
SELECT S.BookingCode, S.CheckInDt, S.CheckOutDt, SUM(S.Tariff), SUM(S.MarkUp), S.PropertyId, S.MasterPropertyId, S.RoomCaptured, S.BookingId, S.CityId,  
S.PropertyCategory, S.ClientId, C.MasterClientId,  
SUBSTRING(DATENAME(MONTH, S.BookingDate), 1, 3) + '-' + CAST(YEAR(S.BookingDate) AS VARCHAR)  
FROM WRBHBBookingStatus S  
LEFT OUTER JOIN WRBHBClientManagement C WITH(NOLOCK)ON C.Id = S.ClientId  
WHERE  
S.Status != 'Canceled'  
GROUP BY S.BookingCode, S.CheckInDt, S.CheckOutDt, S.Tariff, S.MarkUp, S.PropertyId, S.MasterPropertyId, S.RoomCaptured, S.BookingId, S.CityId, S.PropertyCategory, S.ClientId,  
C.MasterClientId, S.BookingDate;  
  
CREATE TABLE #TEMP2(BookingCode BIGINT, CalendarDate DATE, CheckInDt DATE, CheckOutDt DATE, Tariff DECIMAL(27,2), MarkUp DECIMAL(27,2), PropertyId BIGINT,  
MasterPropertyId BIGINT, RoomCaptured BIGINT, BookingId BIGINT, CityId BIGINT, PropertyCategory NVARCHAR(100), ClientId BIGINT, Stay_Month NVARCHAR(100), MasterClientId BIGINT);  
  
INSERT INTO #TEMP2  
SELECT S.BookingCode, C.calendarDate, S.CheckInDt, S.CheckOutDt, S.Tariff, ROUND(S.MarkUp / DATEDIFF(DAY,S.CheckInDt,S.CheckOutDt),0), S.PropertyId, S.MasterPropertyId,  
S.RoomCaptured, S.BookingId, S.CityId, S.PropertyCategory, S.ClientId, SUBSTRING(DATENAME(MONTH, C.CalendarDate), 1, 3) + '-' + CAST(YEAR(C.CalendarDate) AS VARCHAR),  
S.MasterClientId  
FROM #TEMP1 S  
LEFT OUTER JOIN calendar.main C WITH(NOLOCK)ON C.calendarYear != 0  
WHERE S.CheckInDt != S.CheckOutDt AND C.calendarDate BETWEEN S.CheckInDt AND DATEADD(DAY, -1, S.CheckOutDt);  
  
INSERT INTO #TEMP2  
SELECT S.BookingCode, S.CheckInDt, S.CheckInDt, S.CheckOutDt, S.Tariff, ROUND(S.MarkUp, 0), S.PropertyId, S.MasterPropertyId, S.RoomCaptured, S.BookingId, S.CityId,  
S.PropertyCategory, S.ClientId, SUBSTRING(DATENAME(MONTH,S.CheckInDt),1,3)+'-'+CAST(YEAR(S.CheckInDt) AS VARCHAR), S.MasterClientId  
FROM #TEMP1 S  
WHERE S.CheckInDt = S.CheckOutDt;  
  
DELETE #TEMP2 WHERE  
Stay_Month NOT IN ('Apr-2019', 'May-2019', 'Jun-2019', 'Jul-2019', 'Aug-2019', 'Sep-2019', 'Oct-2019', 'Nov-2019', 'Dec-2019', 'Jan-2020', 'Feb-2020', 'Mar-2020',
                   'Apr-2020', 'May-2020', 'Jun-2020', 'Jul-2020', 'Aug-2020');
  
/* ----- Daily Tracking Report Start ----- */  
  
CREATE TABLE #dsadasd(MasterPropertyId BIGINT, PropertyCategory NVARCHAR(100), cnt INT, MonthofBooking NVARCHAR(100), Tariff DECIMAL(27,2),MarkUp DECIMAL(27,2),  
MasterClientId BIGINT);  
INSERT INTO #dsadasd(MasterPropertyId,PropertyCategory,cnt,MonthofBooking,Tariff,MarkUp,MasterClientId)  
SELECT MasterPropertyId,PropertyCategory,COUNT(CalendarDate),Stay_Month,SUM(Tariff),SUM(MarkUp),MasterClientId FROM #TEMP2   
GROUP BY MasterPropertyId,PropertyCategory,Stay_Month,MasterClientId;  
  
SELECT   MasterPropertyId,PropertyCategory,MasterClientId,  
   [Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
   [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021]  
INTO #output  
FROM #dsadasd  
PIVOT  
(  
       SUM(Cnt)  
       FOR MonthofBooking IN   
    ([Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
  [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021])  
) AS P;  
  
CREATE TABLE #TEMPDAILYREPORTCOUNT(MasterPropertyId BIGINT,PropertyCategory NVARCHAR(100),MasterClientId BIGINT,  
[Apr-2019] INT, [May-2019] INT, [Jun-2019] INT, [Jul-2019] INT, [Aug-2019] INT, [Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT,  
[Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT,  
[Apr-2020] INT, [May-2020] INT, [Jun-2020] INT, [Jul-2020] INT, [Aug-2020] INT, [Sep-2020] INT, [Oct-2020] INT, [Nov-2020] INT, [Dec-2020] INT,  
[Jan-2021] INT, [Feb-2021] INT, [Mar-2021] INT);  
  
INSERT INTO #TEMPDAILYREPORTCOUNT  
SELECT MasterPropertyId,PropertyCategory,MasterClientId,  
ISNULL([Apr-2019], 0), ISNULL([May-2019], 0), ISNULL([Jun-2019], 0), ISNULL([Jul-2019], 0), ISNULL([Aug-2019], 0), ISNULL([Sep-2019], 0), ISNULL([Oct-2019], 0),   
ISNULL([Nov-2019], 0), ISNULL([Dec-2019], 0), ISNULL([Jan-2020], 0), ISNULL([Feb-2020], 0), ISNULL([Mar-2020], 0),  
ISNULL([Apr-2020], 0), ISNULL([May-2020], 0), ISNULL([Jun-2020], 0), ISNULL([Jul-2020], 0), ISNULL([Aug-2020], 0), ISNULL([Sep-2020], 0), ISNULL([Oct-2020], 0),   
ISNULL([Nov-2020], 0), ISNULL([Dec-2020], 0), ISNULL([Jan-2021], 0), ISNULL([Feb-2021], 0), ISNULL([Mar-2021], 0)  
FROM #output;  
  
/* master property wise room nights */  
  
CREATE TABLE #TDRNew(MasterPropertyId BIGINT,  
[Apr-2019] INT, [May-2019] INT, [Jun-2019] INT, [Jul-2019] INT, [Aug-2019] INT, [Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT,  
[Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT,  
[Apr-2020] INT, [May-2020] INT, [Jun-2020] INT, [Jul-2020] INT, [Aug-2020] INT, [Sep-2020] INT, [Oct-2020] INT, [Nov-2020] INT, [Dec-2020] INT,  
[Jan-2021] INT, [Feb-2021] INT, [Mar-2021] INT,  
Id BIGINT IDENTITY(1,1));  
  
/* ORDERBY */  
INSERT INTO #TDRNew  
SELECT MasterPropertyId,  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]),   
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]), SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]),   
SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021])  
FROM #TEMPDAILYREPORTCOUNT T  
WHERE PropertyCategory IN ('External','C P P') AND MasterPropertyId NOT IN (1,0)  
GROUP BY MasterPropertyId  
ORDER BY SUM([Aug-2020]) DESC;  
  
CREATE TABLE #TDR(MasterPropertyName NVARCHAR(100), MasterPropertyId BIGINT, Flg INT,  
[Apr-2019] INT, [May-2019] INT, [Jun-2019] INT, [Jul-2019] INT, [Aug-2019] INT, [Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT,  
[Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT,  
[Apr-2020] INT, [May-2020] INT, [Jun-2020] INT, [Jul-2020] INT, [Aug-2020] INT, [Sep-2020] INT, [Oct-2020] INT, [Nov-2020] INT, [Dec-2020] INT,  
[Jan-2021] INT, [Feb-2021] INT, [Mar-2021] INT);  
  
INSERT INTO #TDR  
SELECT TOP 20 P.MasterPropertyName, T.MasterPropertyId, 1,  
[Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
[Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021]  
FROM #TDRNew T  
LEFT OUTER JOIN WRBHBMasterProperty P ON P.Id = T.MasterPropertyId  
ORDER BY T.Id;  
  
INSERT INTO #TDR  
SELECT 'Other than Top 20 Property', 0, 2,  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]),   
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]), SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]),   
SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021])  
FROM #TDRNew T  
WHERE T.Id > 20;  
  
INSERT INTO #TDR  
SELECT 'Total', 0, 3,  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]),   
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]), SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]),   
SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021])  
FROM #TDR;  
  
/*TABLE 1 & 2  
  
SELECT * FROM #TDR T;  
  
*/  
  
/* client wise room nights */  
  
CREATE TABLE #TDRClient(MasterClientName NVARCHAR(100), MasterClientId BIGINT, Flg INT,  
[Apr-2019] INT, [May-2019] INT, [Jun-2019] INT, [Jul-2019] INT, [Aug-2019] INT, [Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT,  
[Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT,  
[Apr-2020] INT, [May-2020] INT, [Jun-2020] INT, [Jul-2020] INT, [Aug-2020] INT, [Sep-2020] INT, [Oct-2020] INT, [Nov-2020] INT, [Dec-2020] INT,  
[Jan-2021] INT, [Feb-2021] INT, [Mar-2021] INT);  
  
INSERT INTO #TDRClient  
SELECT C.ClientName,T.MasterClientId, 1,  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]),   
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]), SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]),   
SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021])  
FROM #TEMPDAILYREPORTCOUNT T  
LEFT OUTER JOIN WRBHBMasterClientManagement C ON C.Id = T.MasterClientId  
WHERE   
T.MasterClientId IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1) AND PropertyCategory IN ('External','C P P')  
GROUP BY  
C.ClientName, T.MasterClientId;  
  
INSERT INTO #TDRClient  
SELECT 'Other Clients', 0, 2,  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]),   
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]), SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]),   
SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021])  
FROM #TEMPDAILYREPORTCOUNT T  
WHERE  
T.MasterClientId NOT IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1) AND PropertyCategory IN ('External','C P P');  
  
INSERT INTO #TDRClient  
SELECT 'Total', 0, 3,  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]),   
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]), SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]),   
SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021])  
FROM #TDRClient;  
  
/* TABLE 3 & 4  
  
SELECT * FROM #TDRClient T;  
  
*/  
  
/* property category room nights */  
  
CREATE TABLE #TDRCatgy(PropertyCategory nvarchar(100), Flg INT,  
[Apr-2019] INT, [May-2019] INT, [Jun-2019] INT, [Jul-2019] INT, [Aug-2019] INT, [Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT,  
[Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT,  
[Apr-2020] INT, [May-2020] INT, [Jun-2020] INT, [Jul-2020] INT, [Aug-2020] INT, [Sep-2020] INT, [Oct-2020] INT, [Nov-2020] INT, [Dec-2020] INT,  
[Jan-2021] INT, [Feb-2021] INT, [Mar-2021] INT);  
  
INSERT INTO #TDRCatgy  
SELECT PropertyCategory, 1,  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]),   
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]), SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]),   
SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021])  
FROM #TEMPDAILYREPORTCOUNT  
WHERE PropertyCategory NOT IN ('Dedicated')  
GROUP BY PropertyCategory  
ORDER BY PropertyCategory;  
  
INSERT INTO #TDRCatgy  
SELECT 'Total', 2,  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]),   
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]), SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]),   
SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021])  
FROM #TDRCatgy;  
  
/*TABLE 5 & 6  
SELECT * FROM #TDRCatgy;  
*/  
  
/* MARKUP */  
  
CREATE TABLE #dsadasd1(PropertyCategory NVARCHAR(100),cnt INT,MonthofBooking NVARCHAR(100),Tariff DECIMAL(27,2),MarkUp DECIMAL(27,2),MasterClientId BIGINT);  
INSERT INTO #dsadasd1(PropertyCategory,cnt,MonthofBooking,Tariff,MarkUp,MasterClientId)  
SELECT PropertyCategory,COUNT(CalendarDate),Stay_Month,SUM(Tariff),SUM(MarkUp),MasterClientId FROM #TEMP2  
WHERE  PropertyCategory IN ('External','C P P')  
GROUP BY PropertyCategory,Stay_Month,MasterClientId;  
  
SELECT   PropertyCategory,MasterClientId,  
   [Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
   [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021]  
INTO #output1  
FROM #dsadasd1  
PIVOT  
(  
       SUM(MarkUp)  
       FOR MonthofBooking IN   
    ([Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
  [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021])  
) AS P1;  
  
CREATE TABLE #TEMPMARKUP(PropertyCategory NVARCHAR(100),MasterClientId BIGINT,  
[Apr-2019] INT, [May-2019] INT, [Jun-2019] INT, [Jul-2019] INT, [Aug-2019] INT, [Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT,  
[Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT,  
[Apr-2020] INT, [May-2020] INT, [Jun-2020] INT, [Jul-2020] INT, [Aug-2020] INT, [Sep-2020] INT, [Oct-2020] INT, [Nov-2020] INT, [Dec-2020] INT,  
[Jan-2021] INT, [Feb-2021] INT, [Mar-2021] INT);  
  
INSERT INTO #TEMPMARKUP  
SELECT PropertyCategory,MasterClientId,  
ISNULL([Apr-2019], 0), ISNULL([May-2019], 0), ISNULL([Jun-2019], 0), ISNULL([Jul-2019], 0), ISNULL([Aug-2019], 0), ISNULL([Sep-2019], 0), ISNULL([Oct-2019], 0),  
ISNULL([Nov-2019], 0), ISNULL([Dec-2019], 0), ISNULL([Jan-2020], 0), ISNULL([Feb-2020], 0), ISNULL([Mar-2020], 0),  
ISNULL([Apr-2020], 0), ISNULL([May-2020], 0), ISNULL([Jun-2020], 0), ISNULL([Jul-2020], 0), ISNULL([Aug-2020], 0), ISNULL([Sep-2020], 0), ISNULL([Oct-2020], 0),   
ISNULL([Nov-2020], 0), ISNULL([Dec-2020], 0), ISNULL([Jan-2021], 0), ISNULL([Feb-2021], 0), ISNULL([Mar-2021], 0)  
FROM  
#output1;  
  
/* -- MARGIN FOR EXP & CPP */  
  
CREATE TABLE #TDRMARKUP_Category(PropertyCategory NVARCHAR(100),  
[Apr-2019] INT, [May-2019] INT, [Jun-2019] INT, [Jul-2019] INT, [Aug-2019] INT, [Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT,  
[Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT,  
[Apr-2020] INT, [May-2020] INT, [Jun-2020] INT, [Jul-2020] INT, [Aug-2020] INT, [Sep-2020] INT, [Oct-2020] INT, [Nov-2020] INT, [Dec-2020] INT,  
[Jan-2021] INT, [Feb-2021] INT, [Mar-2021] INT);  
  
INSERT INTO #TDRMARKUP_Category  
SELECT PropertyCategory,  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]),   
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]), SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]),   
SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021])  
FROM  
#TEMPMARKUP  
GROUP BY PropertyCategory  
ORDER BY PropertyCategory;  
  
CREATE TABLE #TDRMARKUP_Category_New(PropertyCategory NVARCHAR(100), Flg INT,  
[Apr-2019] DECIMAL(27,2), [May-2019] DECIMAL(27,2), [Jun-2019] DECIMAL(27,2), [Jul-2019] DECIMAL(27,2), [Aug-2019] DECIMAL(27,2), [Sep-2019] DECIMAL(27, 2),  
[Oct-2019] DECIMAL(27,2), [Nov-2019] DECIMAL(27,2), [Dec-2019] DECIMAL(27,2), [Jan-2020] DECIMAL(27,2), [Feb-2020] DECIMAL(27,2), [Mar-2020] DECIMAL(27,2),  
  
[Apr-2020] DECIMAL(27,2), [May-2020] DECIMAL(27,2), [Jun-2020] DECIMAL(27,2), [Jul-2020] DECIMAL(27,2), [Aug-2020] DECIMAL(27,2), [Sep-2020] DECIMAL(27,2),   
[Oct-2020] DECIMAL(27,2), [Nov-2020] DECIMAL(27,2), [Dec-2020] DECIMAL(27,2), [Jan-2021] DECIMAL(27,2), [Feb-2021] DECIMAL(27,2), [Mar-2021] DECIMAL(27,2));  
  
INSERT INTO #TDRMARKUP_Category_New  
SELECT PropertyCategory, 1,  
ROUND([Apr-2019] * 0.00001, 2), ROUND([May-2019] * 0.00001, 2), ROUND([Jun-2019] * 0.00001, 2), ROUND([Jul-2019] * 0.00001, 2), ROUND([Aug-2019] * 0.00001, 2),  
ROUND([Sep-2019] * 0.00001, 2), ROUND([Oct-2019] * 0.00001, 2), ROUND([Nov-2019] * 0.00001, 2), ROUND([Dec-2019] * 0.00001, 2), ROUND([Jan-2020] * 0.00001, 2),  
ROUND([Feb-2020] * 0.00001, 2), ROUND([Mar-2020] * 0.00001, 2),  
  
ROUND([Apr-2020] * 0.00001, 2), ROUND([May-2020] * 0.00001, 2), ROUND([Jun-2020] * 0.00001, 2), ROUND([Jul-2020] * 0.00001, 2), ROUND([Aug-2020] * 0.00001, 2),  
ROUND([Sep-2020] * 0.00001, 2), ROUND([Oct-2020] * 0.00001, 2), ROUND([Nov-2020] * 0.00001, 2), ROUND([Dec-2020] * 0.00001, 2), ROUND([Jan-2021] * 0.00001, 2),  
ROUND([Feb-2021] * 0.00001, 2), ROUND([Mar-2021] * 0.00001, 2)  
FROM #TDRMARKUP_Category;  
  
INSERT INTO #TDRMARKUP_Category_New  
SELECT 'Total', 2,  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]),   
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]), SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]),   
SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021])  
FROM #TDRMARKUP_Category_New;  
  
/* -- TABLE 7 & 8  
SELECT * FROM #TDRMARKUP_Category_New;  
*/  
  
/* -- MARGIN FOR EXP & CPP - CLIENT WISE */  
  
CREATE TABLE #TDRMARKUP(MasterClientName NVARCHAR(100), MasterClientId BIGINT, Flg INT,  
[Apr-2019] INT, [May-2019] INT, [Jun-2019] INT, [Jul-2019] INT, [Aug-2019] INT, [Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT,  
[Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT,  
  
[Apr-2020] INT, [May-2020] INT, [Jun-2020] INT, [Jul-2020] INT, [Aug-2020] INT, [Sep-2020] INT, [Oct-2020] INT, [Nov-2020] INT, [Dec-2020] INT,  
[Jan-2021] INT, [Feb-2021] INT, [Mar-2021] INT);  
  
INSERT INTO #TDRMARKUP  
SELECT C.ClientName, T.MasterClientId, 1,  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]),   
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]), SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]),   
SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021])  
FROM #TEMPMARKUP T  
LEFT OUTER JOIN WRBHBMasterClientManagement C WITH(NOLOCK)ON C.Id = T.MasterClientId  
WHERE  
T.MasterClientId IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1)  
GROUP BY  
C.ClientName, T.MasterClientId;  
  
INSERT INTO #TDRMARKUP  
SELECT 'Other Clients', 0, 2,  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]),   
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]), SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]),   
SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021])  
FROM #TEMPMARKUP T  
WHERE T.MasterClientId NOT IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1);  
  
CREATE TABLE #TDRMARKUP_New(MasterClientName NVARCHAR(100), MasterClientId BIGINT, Flg INT,  
[Apr-2019] DECIMAL(27,2), [May-2019] DECIMAL(27,2), [Jun-2019] DECIMAL(27,2), [Jul-2019] DECIMAL(27,2), [Aug-2019] DECIMAL(27,2), [Sep-2019] DECIMAL(27,2),  
[Oct-2019] DECIMAL(27,2), [Nov-2019] DECIMAL(27,2), [Dec-2019] DECIMAL(27,2), [Jan-2020] DECIMAL(27,2), [Feb-2020] DECIMAL(27,2), [Mar-2020] DECIMAL(27,2),  
  
[Apr-2020] DECIMAL(27,2), [May-2020] DECIMAL(27,2), [Jun-2020] DECIMAL(27,2), [Jul-2020] DECIMAL(27,2), [Aug-2020] DECIMAL(27,2), [Sep-2020] DECIMAL(27,2),   
[Oct-2020] DECIMAL(27,2), [Nov-2020] DECIMAL(27,2), [Dec-2020] DECIMAL(27,2), [Jan-2021] DECIMAL(27,2), [Feb-2021] DECIMAL(27,2), [Mar-2021] DECIMAL(27,2));  
  
INSERT INTO #TDRMARKUP_New  
SELECT MasterClientName,MasterClientId, Flg,  
ROUND([Apr-2019] * 0.00001, 2), ROUND([May-2019] * 0.00001, 2), ROUND([Jun-2019] * 0.00001, 2), ROUND([Jul-2019] * 0.00001, 2), ROUND([Aug-2019] * 0.00001, 2),  
ROUND([Sep-2019] * 0.00001, 2), ROUND([Oct-2019] * 0.00001, 2), ROUND([Nov-2019] * 0.00001, 2), ROUND([Dec-2019] * 0.00001, 2), ROUND([Jan-2020] * 0.00001, 2),  
ROUND([Feb-2020] * 0.00001, 2), ROUND([Mar-2020] * 0.00001, 2),  
  
ROUND([Apr-2020] * 0.00001, 2), ROUND([May-2020] * 0.00001, 2), ROUND([Jun-2020] * 0.00001, 2), ROUND([Jul-2020] * 0.00001, 2), ROUND([Aug-2020] * 0.00001, 2),  
ROUND([Sep-2020] * 0.00001, 2), ROUND([Oct-2020] * 0.00001, 2), ROUND([Nov-2020] * 0.00001, 2), ROUND([Dec-2020] * 0.00001, 2), ROUND([Jan-2021] * 0.00001, 2),  
ROUND([Feb-2021] * 0.00001, 2), ROUND([Mar-2021] * 0.00001, 2)  
FROM #TDRMARKUP;  
  
INSERT INTO #TDRMARKUP_New  
SELECT 'Total', 0, 3,  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]),   
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]), SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]),   
SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021])  
FROM #TDRMARKUP_New;  
  
/* -- TABLE 9 & 10  
SELECT * FROM #TDRMARKUP_New;  
*/  
  
/* -- GTV WITH MARKUP */  
  
CREATE TABLE #dsadasd3(PropertyCategory NVARCHAR(100),MonthofBooking NVARCHAR(100),Tariff DECIMAL(27,2),MasterClientId BIGINT);  
INSERT INTO #dsadasd3(PropertyCategory,MonthofBooking,Tariff,MasterClientId)  
SELECT PropertyCategory,Stay_Month,SUM(Tariff),MasterClientId FROM #TEMP2  
WHERE PropertyCategory NOT IN ('G H','Dedicated') AND MarkUp != 0  
GROUP BY PropertyCategory,Stay_Month,MasterClientId;  
  
SELECT   PropertyCategory,MasterClientId,  
   [Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
   [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021]  
INTO #output3  
FROM #dsadasd3  
PIVOT  
(  
       SUM(Tariff)  
       FOR MonthofBooking IN   
    ([Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
        [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021])  
) AS P2;  
  
CREATE TABLE #TEMPGTVwithMARKUP(PropertyCategory NVARCHAR(100),MasterClientId BIGINT,  
[Apr-2019] INT, [May-2019] INT, [Jun-2019] INT, [Jul-2019] INT, [Aug-2019] INT, [Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT,  
[Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT,  
[Apr-2020] INT, [May-2020] INT, [Jun-2020] INT, [Jul-2020] INT, [Aug-2020] INT, [Sep-2020] INT, [Oct-2020] INT, [Nov-2020] INT, [Dec-2020] INT,  
[Jan-2021] INT, [Feb-2021] INT, [Mar-2021] INT);  
  
INSERT INTO #TEMPGTVwithMARKUP  
SELECT PropertyCategory,MasterClientId,  
ISNULL([Apr-2019], 0), ISNULL([May-2019], 0), ISNULL([Jun-2019], 0), ISNULL([Jul-2019], 0), ISNULL([Aug-2019], 0), ISNULL([Sep-2019], 0), ISNULL([Oct-2019], 0),   
ISNULL([Nov-2019], 0), ISNULL([Dec-2019], 0), ISNULL([Jan-2020], 0), ISNULL([Feb-2020], 0), ISNULL([Mar-2020], 0),  
  
ISNULL([Apr-2020], 0), ISNULL([May-2020], 0), ISNULL([Jun-2020], 0), ISNULL([Jul-2020], 0), ISNULL([Aug-2020], 0), ISNULL([Sep-2020], 0), ISNULL([Oct-2020], 0),   
ISNULL([Nov-2020], 0), ISNULL([Dec-2020], 0), ISNULL([Jan-2021], 0), ISNULL([Feb-2021], 0), ISNULL([Mar-2021], 0)  
FROM  
#output3;  
  
/* -- PROPERTY CATEGORY WISE GTV */  
  
CREATE TABLE #GTVTOTAL(PropertyCategory NVARCHAR(100), MarkupFlg INT,  
[Apr-2019] DECIMAL(27,2), [May-2019] DECIMAL(27,2), [Jun-2019] DECIMAL(27,2), [Jul-2019] DECIMAL(27,2), [Aug-2019] DECIMAL(27,2), [Sep-2019] DECIMAL(27,2),  
[Oct-2019] DECIMAL(27,2), [Nov-2019] DECIMAL(27,2), [Dec-2019] DECIMAL(27,2), [Jan-2020] DECIMAL(27,2), [Feb-2020] DECIMAL(27,2), [Mar-2020] DECIMAL(27,2),  
  
[Apr-2020] DECIMAL(27,2), [May-2020] DECIMAL(27,2), [Jun-2020] DECIMAL(27,2), [Jul-2020] DECIMAL(27,2), [Aug-2020] DECIMAL(27,2), [Sep-2020] DECIMAL(27,2),   
[Oct-2020] DECIMAL(27,2), [Nov-2020] DECIMAL(27,2), [Dec-2020] DECIMAL(27,2), [Jan-2021] DECIMAL(27,2), [Feb-2021] DECIMAL(27,2), [Mar-2021] DECIMAL(27,2));  
  
INSERT INTO #GTVTOTAL  
SELECT PropertyCategory, 1,  
ROUND(SUM([Apr-2019]) * 0.00001, 2), ROUND(SUM([May-2019]) * 0.00001, 2), ROUND(SUM([Jun-2019]) * 0.00001, 2), ROUND(SUM([Jul-2019]) * 0.00001, 2),  
ROUND(SUM([Aug-2019]) * 0.00001, 2), ROUND(SUM([Sep-2019]) * 0.00001, 2), ROUND(SUM([Oct-2019]) * 0.00001, 2), ROUND(SUM([Nov-2019]) * 0.00001, 2),   
ROUND(SUM([Dec-2019]) * 0.00001, 2), ROUND(SUM([Jan-2020]) * 0.00001, 2), ROUND(SUM([Feb-2020]) * 0.00001, 2), ROUND(SUM([Mar-2020]) * 0.00001, 2),  
  
ROUND(SUM([Apr-2020]) * 0.00001, 2), ROUND(SUM([May-2020]) * 0.00001, 2), ROUND(SUM([Jun-2020]) * 0.00001, 2), ROUND(SUM([Jul-2020]) * 0.00001, 2),   
ROUND(SUM([Aug-2020]) * 0.00001, 2), ROUND(SUM([Sep-2020]) * 0.00001, 2), ROUND(SUM([Oct-2020]) * 0.00001, 2), ROUND(SUM([Nov-2020]) * 0.00001, 2),   
ROUND(SUM([Dec-2020]) * 0.00001, 2), ROUND(SUM([Jan-2021]) * 0.00001, 2), ROUND(SUM([Feb-2021]) * 0.00001, 2), ROUND(SUM([Mar-2021]) * 0.00001, 2)  
FROM #TEMPGTVwithMARKUP  
GROUP BY PropertyCategory  
ORDER BY PropertyCategory;  
  
INSERT INTO #GTVTOTAL  
SELECT 'GTV with Margin Total', 2,  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]),   
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]), SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]),   
SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021])  
FROM #GTVTOTAL;  
  
/* -- GTV WITHOUT MARKUP */  
  
CREATE TABLE #dsadasd2(PropertyCategory NVARCHAR(100),MonthofBooking NVARCHAR(100),Tariff DECIMAL(27,2),MasterClientId BIGINT);  
INSERT INTO #dsadasd2(PropertyCategory,MonthofBooking,Tariff,MasterClientId)  
SELECT PropertyCategory,Stay_Month,SUM(Tariff),MasterClientId FROM #TEMP2  
WHERE  PropertyCategory NOT IN ('G H','Dedicated') AND MarkUp = 0  
GROUP BY PropertyCategory,Stay_Month,MasterClientId;  
  
SELECT   PropertyCategory,MasterClientId,  
   [Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
   [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021]  
INTO #output2  
FROM #dsadasd2  
PIVOT  
(  
       SUM(Tariff)  
       FOR MonthofBooking IN   
    ([Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
        [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021])  
) AS P2;  
  
CREATE TABLE #TEMPGTVwithoutMARKUP(PropertyCategory NVARCHAR(100),MasterClientId BIGINT,  
[Apr-2019] INT, [May-2019] INT, [Jun-2019] INT, [Jul-2019] INT, [Aug-2019] INT, [Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT,  
[Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT,  
  
[Apr-2020] INT, [May-2020] INT, [Jun-2020] INT, [Jul-2020] INT, [Aug-2020] INT, [Sep-2020] INT, [Oct-2020] INT, [Nov-2020] INT, [Dec-2020] INT,  
[Jan-2021] INT, [Feb-2021] INT, [Mar-2021] INT);  
  
INSERT INTO #TEMPGTVwithoutMARKUP  
SELECT PropertyCategory,MasterClientId,  
ISNULL([Apr-2019], 0), ISNULL([May-2019], 0), ISNULL([Jun-2019], 0), ISNULL([Jul-2019], 0), ISNULL([Aug-2019], 0), ISNULL([Sep-2019], 0), ISNULL([Oct-2019], 0),   
ISNULL([Nov-2019], 0), ISNULL([Dec-2019], 0), ISNULL([Jan-2020], 0), ISNULL([Feb-2020], 0), ISNULL([Mar-2020], 0),  
  
ISNULL([Apr-2020], 0), ISNULL([May-2020], 0), ISNULL([Jun-2020], 0), ISNULL([Jul-2020], 0), ISNULL([Aug-2020], 0), ISNULL([Sep-2020], 0), ISNULL([Oct-2020], 0),   
ISNULL([Nov-2020], 0), ISNULL([Dec-2020], 0), ISNULL([Jan-2021], 0), ISNULL([Feb-2021], 0), ISNULL([Mar-2021], 0)  
FROM #output2;  
  
INSERT INTO #GTVTOTAL  
SELECT PropertyCategory, 3,  
ROUND(SUM([Apr-2019]) * 0.00001, 2), ROUND(SUM([May-2019]) * 0.00001, 2), ROUND(SUM([Jun-2019]) * 0.00001, 2), ROUND(SUM([Jul-2019]) * 0.00001, 2),  
ROUND(SUM([Aug-2019]) * 0.00001, 2), ROUND(SUM([Sep-2019]) * 0.00001, 2), ROUND(SUM([Oct-2019]) * 0.00001, 2), ROUND(SUM([Nov-2019]) * 0.00001, 2),   
ROUND(SUM([Dec-2019]) * 0.00001, 2), ROUND(SUM([Jan-2020]) * 0.00001, 2), ROUND(SUM([Feb-2020]) * 0.00001, 2), ROUND(SUM([Mar-2020]) * 0.00001, 2),  
  
ROUND(SUM([Apr-2020]) * 0.00001, 2), ROUND(SUM([May-2020]) * 0.00001, 2), ROUND(SUM([Jun-2020]) * 0.00001, 2), ROUND(SUM([Jul-2020]) * 0.00001, 2),   
ROUND(SUM([Aug-2020]) * 0.00001, 2), ROUND(SUM([Sep-2020]) * 0.00001, 2), ROUND(SUM([Oct-2020]) * 0.00001, 2), ROUND(SUM([Nov-2020]) * 0.00001, 2),   
ROUND(SUM([Dec-2020]) * 0.00001, 2), ROUND(SUM([Jan-2021]) * 0.00001, 2), ROUND(SUM([Feb-2021]) * 0.00001, 2), ROUND(SUM([Mar-2021]) * 0.00001, 2)  
FROM  
#TEMPGTVwithoutMARKUP  
GROUP BY PropertyCategory  
ORDER BY PropertyCategory;  
  
INSERT INTO #GTVTOTAL  
SELECT 'GTV without Margin Total', 4,  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]),   
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]), SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]),   
SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021])  
FROM #GTVTOTAL  
WHERE MarkupFlg = 3;  
  
INSERT INTO #GTVTOTAL  
SELECT 'GTV Total', 5,  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]),   
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]), SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]),   
SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021])  
FROM #GTVTOTAL  
WHERE MarkupFlg IN (2,4);  
  
/* -- TABLE 11 & 12  
SELECT * FROM #GTVTOTAL;  
*/  
  
/* - CLIENT WISE GTV */  
  
CREATE TABLE #GTVTOTALCLIENT(MasterClientName NVARCHAR(100),MasterClientId BIGINT, MarkupFlg INT,  
  
[Apr-2019] DECIMAL(27,2), [May-2019] DECIMAL(27,2), [Jun-2019] DECIMAL(27,2), [Jul-2019] DECIMAL(27,2), [Aug-2019] DECIMAL(27,2), [Sep-2019] DECIMAL(27,2),  
[Oct-2019] DECIMAL(27,2), [Nov-2019] DECIMAL(27,2), [Dec-2019] DECIMAL(27,2), [Jan-2020] DECIMAL(27,2), [Feb-2020] DECIMAL(27,2), [Mar-2020] DECIMAL(27,2),  
  
[Apr-2020] DECIMAL(27,2), [May-2020] DECIMAL(27,2), [Jun-2020] DECIMAL(27,2), [Jul-2020] DECIMAL(27,2), [Aug-2020] DECIMAL(27,2), [Sep-2020] DECIMAL(27,2),   
[Oct-2020] DECIMAL(27,2), [Nov-2020] DECIMAL(27,2), [Dec-2020] DECIMAL(27,2), [Jan-2021] DECIMAL(27,2), [Feb-2021] DECIMAL(27,2), [Mar-2021] DECIMAL(27,2));  
  
INSERT INTO #GTVTOTALCLIENT  
SELECT C.ClientName, T.MasterClientId, 1,   
  
ROUND(SUM([Apr-2019]) * 0.00001, 2), ROUND(SUM([May-2019]) * 0.00001, 2), ROUND(SUM([Jun-2019]) * 0.00001, 2), ROUND(SUM([Jul-2019]) * 0.00001, 2),  
ROUND(SUM([Aug-2019]) * 0.00001, 2), ROUND(SUM([Sep-2019]) * 0.00001, 2), ROUND(SUM([Oct-2019]) * 0.00001, 2), ROUND(SUM([Nov-2019]) * 0.00001, 2),   
ROUND(SUM([Dec-2019]) * 0.00001, 2), ROUND(SUM([Jan-2020]) * 0.00001, 2), ROUND(SUM([Feb-2020]) * 0.00001, 2), ROUND(SUM([Mar-2020]) * 0.00001, 2),  
  
ROUND(SUM([Apr-2020]) * 0.00001, 2), ROUND(SUM([May-2020]) * 0.00001, 2), ROUND(SUM([Jun-2020]) * 0.00001, 2), ROUND(SUM([Jul-2020]) * 0.00001, 2),   
ROUND(SUM([Aug-2020]) * 0.00001, 2), ROUND(SUM([Sep-2020]) * 0.00001, 2), ROUND(SUM([Oct-2020]) * 0.00001, 2), ROUND(SUM([Nov-2020]) * 0.00001, 2),   
ROUND(SUM([Dec-2020]) * 0.00001, 2), ROUND(SUM([Jan-2021]) * 0.00001, 2), ROUND(SUM([Feb-2021]) * 0.00001, 2), ROUND(SUM([Mar-2021]) * 0.00001, 2)  
FROM #TEMPGTVwithMARKUP T  
LEFT OUTER JOIN WRBHBMasterClientManagement C WITH(NOLOCK)ON C.Id = T.MasterClientId  
WHERE T.MasterClientId IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1)  
GROUP BY C.ClientName, T.MasterClientId;  
  
INSERT INTO #GTVTOTALCLIENT  
SELECT 'Other Clients', 0, 2,   
  
ROUND(SUM([Apr-2019]) * 0.00001, 2), ROUND(SUM([May-2019]) * 0.00001, 2), ROUND(SUM([Jun-2019]) * 0.00001, 2), ROUND(SUM([Jul-2019]) * 0.00001, 2),  
ROUND(SUM([Aug-2019]) * 0.00001, 2), ROUND(SUM([Sep-2019]) * 0.00001, 2), ROUND(SUM([Oct-2019]) * 0.00001, 2), ROUND(SUM([Nov-2019]) * 0.00001, 2),   
ROUND(SUM([Dec-2019]) * 0.00001, 2), ROUND(SUM([Jan-2020]) * 0.00001, 2), ROUND(SUM([Feb-2020]) * 0.00001, 2), ROUND(SUM([Mar-2020]) * 0.00001, 2),  
  
ROUND(SUM([Apr-2020]) * 0.00001, 2), ROUND(SUM([May-2020]) * 0.00001, 2), ROUND(SUM([Jun-2020]) * 0.00001, 2), ROUND(SUM([Jul-2020]) * 0.00001, 2),   
ROUND(SUM([Aug-2020]) * 0.00001, 2), ROUND(SUM([Sep-2020]) * 0.00001, 2), ROUND(SUM([Oct-2020]) * 0.00001, 2), ROUND(SUM([Nov-2020]) * 0.00001, 2),   
ROUND(SUM([Dec-2020]) * 0.00001, 2), ROUND(SUM([Jan-2021]) * 0.00001, 2), ROUND(SUM([Feb-2021]) * 0.00001, 2), ROUND(SUM([Mar-2021]) * 0.00001, 2)  
FROM #TEMPGTVwithMARKUP  
WHERE MasterClientId NOT IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1);  
  
INSERT INTO #GTVTOTALCLIENT  
SELECT ' GTV with Margin Total', 0, 3,  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]),   
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]), SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]),   
SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021])  
FROM #GTVTOTALCLIENT;  
  
INSERT INTO #GTVTOTALCLIENT  
SELECT C.ClientName, T.MasterClientId, 4,  
ROUND(SUM([Apr-2019]) * 0.00001, 2), ROUND(SUM([May-2019]) * 0.00001, 2), ROUND(SUM([Jun-2019]) * 0.00001, 2), ROUND(SUM([Jul-2019]) * 0.00001, 2),  
ROUND(SUM([Aug-2019]) * 0.00001, 2), ROUND(SUM([Sep-2019]) * 0.00001, 2), ROUND(SUM([Oct-2019]) * 0.00001, 2), ROUND(SUM([Nov-2019]) * 0.00001, 2),   
ROUND(SUM([Dec-2019]) * 0.00001, 2), ROUND(SUM([Jan-2020]) * 0.00001, 2), ROUND(SUM([Feb-2020]) * 0.00001, 2), ROUND(SUM([Mar-2020]) * 0.00001, 2),  
  
ROUND(SUM([Apr-2020]) * 0.00001, 2), ROUND(SUM([May-2020]) * 0.00001, 2), ROUND(SUM([Jun-2020]) * 0.00001, 2), ROUND(SUM([Jul-2020]) * 0.00001, 2),   
ROUND(SUM([Aug-2020]) * 0.00001, 2), ROUND(SUM([Sep-2020]) * 0.00001, 2), ROUND(SUM([Oct-2020]) * 0.00001, 2), ROUND(SUM([Nov-2020]) * 0.00001, 2),   
ROUND(SUM([Dec-2020]) * 0.00001, 2), ROUND(SUM([Jan-2021]) * 0.00001, 2), ROUND(SUM([Feb-2021]) * 0.00001, 2), ROUND(SUM([Mar-2021]) * 0.00001, 2)  
FROM #TEMPGTVwithoutMARKUP T  
LEFT OUTER JOIN WRBHBMasterClientManagement C WITH(NOLOCK)ON C.Id = T.MasterClientId  
WHERE T.MasterClientId IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1)  
GROUP BY C.ClientName, T.MasterClientId;  
  
INSERT INTO #GTVTOTALCLIENT  
SELECT 'Other Clients', 0, 5,  
ROUND(SUM([Apr-2019]) * 0.00001, 2), ROUND(SUM([May-2019]) * 0.00001, 2), ROUND(SUM([Jun-2019]) * 0.00001, 2), ROUND(SUM([Jul-2019]) * 0.00001, 2),  
ROUND(SUM([Aug-2019]) * 0.00001, 2), ROUND(SUM([Sep-2019]) * 0.00001, 2), ROUND(SUM([Oct-2019]) * 0.00001, 2), ROUND(SUM([Nov-2019]) * 0.00001, 2),   
ROUND(SUM([Dec-2019]) * 0.00001, 2), ROUND(SUM([Jan-2020]) * 0.00001, 2), ROUND(SUM([Feb-2020]) * 0.00001, 2), ROUND(SUM([Mar-2020]) * 0.00001, 2),  
  
ROUND(SUM([Apr-2020]) * 0.00001, 2), ROUND(SUM([May-2020]) * 0.00001, 2), ROUND(SUM([Jun-2020]) * 0.00001, 2), ROUND(SUM([Jul-2020]) * 0.00001, 2),   
ROUND(SUM([Aug-2020]) * 0.00001, 2), ROUND(SUM([Sep-2020]) * 0.00001, 2), ROUND(SUM([Oct-2020]) * 0.00001, 2), ROUND(SUM([Nov-2020]) * 0.00001, 2),   
ROUND(SUM([Dec-2020]) * 0.00001, 2), ROUND(SUM([Jan-2021]) * 0.00001, 2), ROUND(SUM([Feb-2021]) * 0.00001, 2), ROUND(SUM([Mar-2021]) * 0.00001, 2)  
FROM #TEMPGTVwithoutMARKUP  
WHERE MasterClientId NOT IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1);  
  
INSERT INTO #GTVTOTALCLIENT  
SELECT ' GTV without Margin Total', 0, 6,  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]),   
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]), SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]),   
SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021])  
FROM #GTVTOTALCLIENT  
WHERE MarkupFlg IN (4,5);  
  
INSERT INTO #GTVTOTALCLIENT  
SELECT ' GTV Total', 0, 7,  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]),   
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]), SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]),   
SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021])  
FROM #GTVTOTALCLIENT  
WHERE MarkupFlg IN (3,6);  
  
  
/*-- TABLE 13 & 14   
SELECT * FROM #GTVTOTALCLIENT;  
*/  
  
/*----- Result -----*/  
  
SELECT '' AS C1,  
'Aug-20' AS C30, 'Jul-20' AS C29, 'Jun-20' AS C28, 'May-20' AS C27, 'Apr-20' AS C26,  
'Mar-20' AS C25, 'Feb-20' AS C24, 'Jan-20' AS C23, 'Dec-19' AS C22, 'Nov-19' AS C21, 'Oct-19' AS C20,  
'Sep-19' AS C19, 'Aug-19' AS C18, 'Jul-19' AS C17, 'Jun-19' AS C16, 'May-19' AS C15, 'Apr-19' AS C14;  
  
/* -- TABLE 1 & 2 */  
  
SELECT 'Property ( Hotel Chain ) - Room Nights ( Value in Nos )' AS Title;  
SELECT 'PropertyName' AS C1;  
SELECT MasterPropertyName AS PropertyName,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019], [Aug-2019], [Jul-2019], [Jun-2019], [May-2019], [Apr-2019]  
FROM #TDR T  
ORDER BY Flg ASC, [Aug-2020] DESC, MasterPropertyName ASC;  
  
/* -- TABLE 3 & 4 */  
  
SELECT 'Clients - Room Nights ( Value in Nos )' AS Title;  
SELECT 'Top Clients' AS C1;  
SELECT MasterClientName,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019], [Aug-2019], [Jul-2019], [Jun-2019], [May-2019], [Apr-2019]  
FROM #TDRClient T  
ORDER BY Flg ASC, [Aug-2020] DESC, MasterClientName ASC;  
  
/* -- TABLE 5 & 6 */  
  
SELECT 'Room Nights by Property Category ( Value in Nos )' AS Title;  
SELECT 'Property Category' AS C1;  
SELECT PropertyCategory,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019], [Aug-2019], [Jul-2019], [Jun-2019], [May-2019], [Apr-2019]  
FROM #TDRCatgy  
ORDER BY Flg;  
  
/* -- TABLE 7 & 8 */  
  
SELECT 'Margin from External Properties by Property Category ( Value in Rs. ( Lacs) )' AS Title;  
SELECT 'Property Category' AS C1;  
SELECT PropertyCategory,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019], [Aug-2019], [Jul-2019], [Jun-2019], [May-2019], [Apr-2019]  
FROM #TDRMARKUP_Category_New  
ORDER BY Flg;  
  
/* -- TABLE 9 & 10 */  
  
SELECT 'External Margin Analysis by Client ( Value in Rs. ( Lacs) )' AS Title;  
SELECT 'Top Clients' AS C1;  
SELECT MasterClientName,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019], [Aug-2019], [Jul-2019], [Jun-2019], [May-2019], [Apr-2019]  
FROM #TDRMARKUP_New  
ORDER BY Flg ASC, [Aug-2020] DESC, MasterClientName ASC;  
  
/* -- TABLE 11 & 12 */  
  
SELECT 'GTV by Property Category (Excluding Guest House) ( Value in Rs. ( Lacs) )' AS Title;  
SELECT 'Property Category' AS C1;  
SELECT PropertyCategory,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019], [Aug-2019], [Jul-2019], [Jun-2019], [May-2019], [Apr-2019]  
FROM #GTVTOTAL  
ORDER BY MarkupFlg;  
  
/* -- TABLE 13 & 14 */  
  
SELECT 'GTV by Client Wise (Excluding Guest House) ( Value in Rs. ( Lacs) )' AS Title;  
SELECT 'Top Clients' AS C1;  
SELECT MasterClientName,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019], [Aug-2019], [Jul-2019], [Jun-2019], [May-2019], [Apr-2019]  
FROM #GTVTOTALCLIENT  
ORDER BY MarkupFlg ASC, [Aug-2020] DESC, MasterClientName ASC;  
  
/*----- Daily Tracking Report End -----*/  
  
/*----- Monthly Analysis Report Start -----*/  
  
CREATE TABLE #TEMPMONTH1(CityId BIGINT, MonthofBooking NVARCHAR(100));  
INSERT INTO #TEMPMONTH1(CityId, MonthofBooking)  
SELECT CityId, Stay_Month FROM #TEMP2 WHERE PropertyCategory IN ('External','C P P')  
GROUP BY Stay_Month,CityId;  
  
CREATE TABLE #TEMPMONTH2(MonthofBooking NVARCHAR(100), CityCount INT);  
INSERT INTO #TEMPMONTH2  
SELECT MonthofBooking,COUNT(CityId) FROM #TEMPMONTH1 GROUP BY MonthofBooking;  
  
SELECT [Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
    [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021]  
INTO #TEMPMONTH3  
FROM #TEMPMONTH2  
PIVOT  
(  
       SUM(CityCount)  
       FOR MonthofBooking IN   
    ([Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
     [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021])  
) AS P;  
  
CREATE TABLE #TEMPMONTH4(Title NVARCHAR(100), Flg INT,  
[Apr-2019] INT, [May-2019] INT, [Jun-2019] INT, [Jul-2019] INT, [Aug-2019] INT, [Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT,  
[Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT,  
  
[Apr-2020] INT, [May-2020] INT, [Jun-2020] INT, [Jul-2020] INT, [Aug-2020] INT, [Sep-2020] INT, [Oct-2020] INT, [Nov-2020] INT, [Dec-2020] INT,  
[Jan-2021] INT, [Feb-2021] INT, [Mar-2021] INT);  
  
INSERT INTO #TEMPMONTH4  
SELECT 'Total No of Cities', 1,  
ISNULL([Apr-2019], 0), ISNULL([May-2019], 0), ISNULL([Jun-2019], 0), ISNULL([Jul-2019], 0), ISNULL([Aug-2019], 0), ISNULL([Sep-2019], 0), ISNULL([Oct-2019], 0),   
ISNULL([Nov-2019], 0), ISNULL([Dec-2019], 0), ISNULL([Jan-2020], 0), ISNULL([Feb-2020], 0), ISNULL([Mar-2020], 0),  
  
ISNULL([Apr-2020], 0), ISNULL([May-2020], 0), ISNULL([Jun-2020], 0), ISNULL([Jul-2020], 0), ISNULL([Aug-2020], 0), ISNULL([Sep-2020], 0), ISNULL([Oct-2020], 0),   
ISNULL([Nov-2020], 0), ISNULL([Dec-2020], 0), ISNULL([Jan-2021], 0), ISNULL([Feb-2021], 0), ISNULL([Mar-2021], 0)  
FROM #TEMPMONTH3;  
  
CREATE TABLE #TEMPMONTH5(PropertyId BIGINT, MonthofBooking NVARCHAR(100));  
INSERT INTO #TEMPMONTH5(PropertyId, MonthofBooking)  
SELECT PropertyId, Stay_Month FROM #TEMP2 WHERE PropertyCategory IN ('External','C P P')   
GROUP BY PropertyId, Stay_Month;  
  
CREATE TABLE #TEMPMONTH6(MonthofBooking NVARCHAR(100), PropertyCount INT);  
INSERT INTO #TEMPMONTH6  
SELECT MonthofBooking,COUNT(PropertyId) FROM #TEMPMONTH5 GROUP BY MonthofBooking;  
  
SELECT [Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
    [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021]  
INTO #TEMPMONTH7  
FROM #TEMPMONTH6  
PIVOT  
(  
       SUM(PropertyCount)  
       FOR MonthofBooking IN   
    ([Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
  [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021])  
) AS P;  
  
INSERT INTO #TEMPMONTH4  
SELECT 'Total No of Hotels HB Digital', 2,  
ISNULL([Apr-2019], 0), ISNULL([May-2019], 0), ISNULL([Jun-2019], 0), ISNULL([Jul-2019], 0), ISNULL([Aug-2019], 0), ISNULL([Sep-2019], 0), ISNULL([Oct-2019], 0),   
ISNULL([Nov-2019], 0), ISNULL([Dec-2019], 0), ISNULL([Jan-2020], 0), ISNULL([Feb-2020], 0), ISNULL([Mar-2020], 0),  
  
ISNULL([Apr-2020], 0), ISNULL([May-2020], 0), ISNULL([Jun-2020], 0), ISNULL([Jul-2020], 0), ISNULL([Aug-2020], 0), ISNULL([Sep-2020], 0), ISNULL([Oct-2020], 0),   
ISNULL([Nov-2020], 0), ISNULL([Dec-2020], 0), ISNULL([Jan-2021], 0), ISNULL([Feb-2021], 0), ISNULL([Mar-2021], 0)  
FROM #TEMPMONTH7;  
--  
CREATE TABLE #TEMPMONTH8(PropertyId BIGINT, MonthofBooking NVARCHAR(100));  
INSERT INTO #TEMPMONTH8(PropertyId, MonthofBooking)  
SELECT PropertyId,Stay_Month FROM #TEMP2   
WHERE MasterPropertyId NOT IN (0,1) AND PropertyCategory IN ('External','C P P')  
GROUP BY PropertyId,Stay_Month;  
  
CREATE TABLE #TEMPMONTH9(MonthofBooking NVARCHAR(100), ChainPropertyCount INT);  
INSERT INTO #TEMPMONTH9  
SELECT MonthofBooking,COUNT(PropertyId) FROM #TEMPMONTH8 GROUP BY MonthofBooking;  
  
SELECT [Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
    [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021]  
INTO #TEMPMONTH10  
FROM #TEMPMONTH9  
PIVOT  
(  
       SUM(ChainPropertyCount)  
       FOR MonthofBooking IN   
    ([Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
  [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021])  
) AS P;  
  
INSERT INTO #TEMPMONTH4  
SELECT '     Total No of Chain Hotels', 3,  
ISNULL([Apr-2019], 0), ISNULL([May-2019], 0), ISNULL([Jun-2019], 0), ISNULL([Jul-2019], 0), ISNULL([Aug-2019], 0), ISNULL([Sep-2019], 0), ISNULL([Oct-2019], 0),   
ISNULL([Nov-2019], 0), ISNULL([Dec-2019], 0), ISNULL([Jan-2020], 0), ISNULL([Feb-2020], 0), ISNULL([Mar-2020], 0),  
  
ISNULL([Apr-2020], 0), ISNULL([May-2020], 0), ISNULL([Jun-2020], 0), ISNULL([Jul-2020], 0), ISNULL([Aug-2020], 0), ISNULL([Sep-2020], 0), ISNULL([Oct-2020], 0),   
ISNULL([Nov-2020], 0), ISNULL([Dec-2020], 0), ISNULL([Jan-2021], 0), ISNULL([Feb-2021], 0), ISNULL([Mar-2021], 0)  
FROM #TEMPMONTH10;  
  
INSERT INTO #TEMPMONTH4  
SELECT '', 4,  
-ISNULL([Apr-2019],0), -ISNULL([May-2019],0), -ISNULL([Jun-2019],0), -ISNULL([Jul-2019],0), -ISNULL([Aug-2019],0), -ISNULL([Sep-2019],0), -ISNULL([Oct-2019],0),   
-ISNULL([Nov-2019],0), -ISNULL([Dec-2019],0), -ISNULL([Jan-2020],0), -ISNULL([Feb-2020],0), -ISNULL([Mar-2020],0),  
  
-ISNULL([Apr-2020],0), -ISNULL([May-2020],0), -ISNULL([Jun-2020],0), -ISNULL([Jul-2020],0), -ISNULL([Aug-2020],0), -ISNULL([Sep-2020],0), -ISNULL([Oct-2020],0),   
-ISNULL([Nov-2020],0), -ISNULL([Dec-2020],0), -ISNULL([Jan-2021],0), -ISNULL([Feb-2021],0), -ISNULL([Mar-2021],0)  
FROM #TEMPMONTH10;  
  
INSERT INTO #TEMPMONTH4  
SELECT '     Total No of Non Chain Hotels', 5,  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]),  
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
  
  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]), SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]),   
SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021])  
FROM #TEMPMONTH4 WHERE Flg IN (2,4);  
  
/*-- TABLE 1  
SELECT * FROM #TEMPMONTH4 WHERE Flg IN (1,2,3,5);  
*/  
  
CREATE TABLE #TEMPMONTH11(Title1 NVARCHAR(100),Title2 NVARCHAR(100), Flg INT,  
[Apr-2019] INT, [May-2019] INT, [Jun-2019] INT, [Jul-2019] INT, [Aug-2019] INT, [Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT,  
[Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT,  
  
[Apr-2020] INT, [May-2020] INT, [Jun-2020] INT, [Jul-2020] INT, [Aug-2020] INT, [Sep-2020] INT, [Oct-2020] INT, [Nov-2020] INT, [Dec-2020] INT,  
[Jan-2021] INT, [Feb-2021] INT, [Mar-2021] INT);  
  
INSERT INTO #TEMPMONTH11  
SELECT 'Type of Hotels', 'Total No of Hotels ( Room Nights)', 1,  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]),   
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]), SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]),   
SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021])  
FROM #TEMPDAILYREPORTCOUNT  
WHERE PropertyCategory IN ('External','C P P');  
  
INSERT INTO #TEMPMONTH11  
SELECT '', '     Chain Hotels ( Room Nights)', 2,  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]),   
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]), SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]),   
SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021])  
FROM #TDR T;  
  
INSERT INTO #TEMPMONTH11  
SELECT '', '', 3,  
-[Apr-2019], -[May-2019], -[Jun-2019], -[Jul-2019], -[Aug-2019], -[Sep-2019], -[Oct-2019], -[Nov-2019], -[Dec-2019], -[Jan-2020], -[Feb-2020], -[Mar-2020],  
-[Apr-2020], -[May-2020], -[Jun-2020], -[Jul-2020], -[Aug-2020], -[Sep-2020], -[Oct-2020], -[Nov-2020], -[Dec-2020], -[Jan-2021], -[Feb-2021], -[Mar-2021]  
FROM #TEMPMONTH11 T  
WHERE Flg = 2;  
  
INSERT INTO #TEMPMONTH11  
SELECT '', '     Non Chain Hotels ( Room Nights)', 4,  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]),   
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]), SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]),   
SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021])  
FROM #TEMPMONTH11 T  
WHERE Flg IN (1,3);  
  
/*Table 2.1  
  
SELECT * FROM #TEMPMONTH11 WHERE Flg IN (1,2,4) ORDER BY Flg;  
  
*/  
  
CREATE TABLE #TEMPMONTH12_WithMarkup(MasterPropertyId BIGINT,PropertyCategory NVARCHAR(100),cnt INT,MonthofBooking NVARCHAR(100),MarkUp DECIMAL(27,2));  
INSERT INTO #TEMPMONTH12_WithMarkup(MasterPropertyId,PropertyCategory,cnt,MonthofBooking,MarkUp)  
SELECT MasterPropertyId,PropertyCategory,COUNT(CalendarDate),Stay_Month,MarkUp FROM #TEMP2  
WHERE PropertyCategory IN ('External','C P P')   
GROUP BY MasterPropertyId,PropertyCategory,Stay_Month,MarkUp,BookingId;  
  
SELECT   MasterPropertyId,PropertyCategory,MarkUp,  
         [Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
   [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021]  
INTO #TEMPMONTH12  
FROM #TEMPMONTH12_WithMarkup  
PIVOT  
(  
       SUM(Cnt)  
       FOR MonthofBooking IN   
    ([Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
  [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021])  
) AS P;  
  
CREATE TABLE #TEMPMONTH13(Title1 NVARCHAR(100),Title2 NVARCHAR(100), Flg INT,  
[Apr-2019] INT, [May-2019] INT, [Jun-2019] INT, [Jul-2019] INT, [Aug-2019] INT, [Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT,  
[Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT,  
[Apr-2020] INT, [May-2020] INT, [Jun-2020] INT, [Jul-2020] INT, [Aug-2020] INT, [Sep-2020] INT, [Oct-2020] INT, [Nov-2020] INT, [Dec-2020] INT,  
[Jan-2021] INT, [Feb-2021] INT, [Mar-2021] INT);  
  
INSERT INTO #TEMPMONTH13  
SELECT 'Revenue Earning Rooms', 'With Commission ( Room Nights)', 1,  
SUM(ISNULL([Apr-2019],0)), SUM(ISNULL([May-2019],0)), SUM(ISNULL([Jun-2019],0)), SUM(ISNULL([Jul-2019],0)), SUM(ISNULL([Aug-2019],0)), SUM(ISNULL([Sep-2019],0)),  
SUM(ISNULL([Oct-2019],0)), SUM(ISNULL([Nov-2019],0)), SUM(ISNULL([Dec-2019],0)), SUM(ISNULL([Jan-2020],0)), SUM(ISNULL([Feb-2020],0)), SUM(ISNULL([Mar-2020],0)),  
SUM(ISNULL([Apr-2020],0)), SUM(ISNULL([May-2020],0)), SUM(ISNULL([Jun-2020],0)), SUM(ISNULL([Jul-2020],0)), SUM(ISNULL([Aug-2020],0)), SUM(ISNULL([Sep-2020],0)),   
SUM(ISNULL([Oct-2020],0)), SUM(ISNULL([Nov-2020],0)), SUM(ISNULL([Dec-2020],0)), SUM(ISNULL([Jan-2021],0)), SUM(ISNULL([Feb-2021],0)), SUM(ISNULL([Mar-2021],0))  
FROM #TEMPMONTH12  
WHERE MarkUp != 0;  
  
INSERT INTO #TEMPMONTH13  
SELECT '', 'Without Commission ( Room Nights)', 2,  
SUM(ISNULL([Apr-2019],0)), SUM(ISNULL([May-2019],0)), SUM(ISNULL([Jun-2019],0)), SUM(ISNULL([Jul-2019],0)), SUM(ISNULL([Aug-2019],0)), SUM(ISNULL([Sep-2019],0)),  
SUM(ISNULL([Oct-2019],0)), SUM(ISNULL([Nov-2019],0)), SUM(ISNULL([Dec-2019],0)), SUM(ISNULL([Jan-2020],0)), SUM(ISNULL([Feb-2020],0)), SUM(ISNULL([Mar-2020],0)),  
SUM(ISNULL([Apr-2020],0)), SUM(ISNULL([May-2020],0)), SUM(ISNULL([Jun-2020],0)), SUM(ISNULL([Jul-2020],0)), SUM(ISNULL([Aug-2020],0)), SUM(ISNULL([Sep-2020],0)),   
SUM(ISNULL([Oct-2020],0)), SUM(ISNULL([Nov-2020],0)), SUM(ISNULL([Dec-2020],0)), SUM(ISNULL([Jan-2021],0)), SUM(ISNULL([Feb-2021],0)), SUM(ISNULL([Mar-2021],0))  
FROM #TEMPMONTH12  
WHERE MarkUp = 0;  
  
/*Table 2.2  
  
SELECT * FROM #TEMPMONTH13 WHERE Flg IN (1,2) ORDER BY Flg;  
  
*/  
  
INSERT INTO #TEMPMONTH13  
SELECT 'Client Preferred Property', 'Total (Room Nights)', 3,  
SUM(ISNULL([Apr-2019],0)), SUM(ISNULL([May-2019],0)), SUM(ISNULL([Jun-2019],0)), SUM(ISNULL([Jul-2019],0)), SUM(ISNULL([Aug-2019],0)), SUM(ISNULL([Sep-2019],0)),  
SUM(ISNULL([Oct-2019],0)), SUM(ISNULL([Nov-2019],0)), SUM(ISNULL([Dec-2019],0)), SUM(ISNULL([Jan-2020],0)), SUM(ISNULL([Feb-2020],0)), SUM(ISNULL([Mar-2020],0)),  
SUM(ISNULL([Apr-2020],0)), SUM(ISNULL([May-2020],0)), SUM(ISNULL([Jun-2020],0)), SUM(ISNULL([Jul-2020],0)), SUM(ISNULL([Aug-2020],0)), SUM(ISNULL([Sep-2020],0)),   
SUM(ISNULL([Oct-2020],0)), SUM(ISNULL([Nov-2020],0)), SUM(ISNULL([Dec-2020],0)), SUM(ISNULL([Jan-2021],0)), SUM(ISNULL([Feb-2021],0)), SUM(ISNULL([Mar-2021],0))  
FROM #TEMPMONTH12  
WHERE PropertyCategory = 'C P P';  
  
INSERT INTO #TEMPMONTH13  
SELECT '', '     With Commission ( Room Nights)', 4,  
SUM(ISNULL([Apr-2019],0)), SUM(ISNULL([May-2019],0)), SUM(ISNULL([Jun-2019],0)), SUM(ISNULL([Jul-2019],0)), SUM(ISNULL([Aug-2019],0)), SUM(ISNULL([Sep-2019],0)),  
SUM(ISNULL([Oct-2019],0)), SUM(ISNULL([Nov-2019],0)), SUM(ISNULL([Dec-2019],0)), SUM(ISNULL([Jan-2020],0)), SUM(ISNULL([Feb-2020],0)), SUM(ISNULL([Mar-2020],0)),  
SUM(ISNULL([Apr-2020],0)), SUM(ISNULL([May-2020],0)), SUM(ISNULL([Jun-2020],0)), SUM(ISNULL([Jul-2020],0)), SUM(ISNULL([Aug-2020],0)), SUM(ISNULL([Sep-2020],0)),   
SUM(ISNULL([Oct-2020],0)), SUM(ISNULL([Nov-2020],0)), SUM(ISNULL([Dec-2020],0)), SUM(ISNULL([Jan-2021],0)), SUM(ISNULL([Feb-2021],0)), SUM(ISNULL([Mar-2021],0))  
FROM #TEMPMONTH12  
WHERE PropertyCategory = 'C P P' AND MarkUp != 0;  
  
INSERT INTO #TEMPMONTH13  
SELECT '', '     Without Commission ( Room Nights)', 5,  
SUM(ISNULL([Apr-2019],0)), SUM(ISNULL([May-2019],0)), SUM(ISNULL([Jun-2019],0)), SUM(ISNULL([Jul-2019],0)), SUM(ISNULL([Aug-2019],0)), SUM(ISNULL([Sep-2019],0)),  
SUM(ISNULL([Oct-2019],0)), SUM(ISNULL([Nov-2019],0)), SUM(ISNULL([Dec-2019],0)), SUM(ISNULL([Jan-2020],0)), SUM(ISNULL([Feb-2020],0)), SUM(ISNULL([Mar-2020],0)),  
SUM(ISNULL([Apr-2020],0)), SUM(ISNULL([May-2020],0)), SUM(ISNULL([Jun-2020],0)), SUM(ISNULL([Jul-2020],0)), SUM(ISNULL([Aug-2020],0)), SUM(ISNULL([Sep-2020],0)),   
SUM(ISNULL([Oct-2020],0)), SUM(ISNULL([Nov-2020],0)), SUM(ISNULL([Dec-2020],0)), SUM(ISNULL([Jan-2021],0)), SUM(ISNULL([Feb-2021],0)), SUM(ISNULL([Mar-2021],0))  
FROM #TEMPMONTH12  
WHERE PropertyCategory = 'C P P' AND MarkUp = 0;  
  
/*Table 2.3  
  
SELECT * FROM #TEMPMONTH13 WHERE Flg IN (3, 4, 5) ORDER BY Flg;  
  
*/  
  
INSERT INTO #TEMPMONTH13  
SELECT 'HB Partners Property', 'Total  (Room Nights)', 6,  
SUM(ISNULL([Apr-2019],0)), SUM(ISNULL([May-2019],0)), SUM(ISNULL([Jun-2019],0)), SUM(ISNULL([Jul-2019],0)), SUM(ISNULL([Aug-2019],0)), SUM(ISNULL([Sep-2019],0)),  
SUM(ISNULL([Oct-2019],0)), SUM(ISNULL([Nov-2019],0)), SUM(ISNULL([Dec-2019],0)), SUM(ISNULL([Jan-2020],0)), SUM(ISNULL([Feb-2020],0)), SUM(ISNULL([Mar-2020],0)),  
SUM(ISNULL([Apr-2020],0)), SUM(ISNULL([May-2020],0)), SUM(ISNULL([Jun-2020],0)), SUM(ISNULL([Jul-2020],0)), SUM(ISNULL([Aug-2020],0)), SUM(ISNULL([Sep-2020],0)),   
SUM(ISNULL([Oct-2020],0)), SUM(ISNULL([Nov-2020],0)), SUM(ISNULL([Dec-2020],0)), SUM(ISNULL([Jan-2021],0)), SUM(ISNULL([Feb-2021],0)), SUM(ISNULL([Mar-2021],0))  
FROM #TEMPMONTH12  
WHERE PropertyCategory = 'External';  
  
INSERT INTO #TEMPMONTH13  
SELECT '', '     Commissionable Room Nights HB Property', 7,  
SUM(ISNULL([Apr-2019],0)), SUM(ISNULL([May-2019],0)), SUM(ISNULL([Jun-2019],0)), SUM(ISNULL([Jul-2019],0)), SUM(ISNULL([Aug-2019],0)), SUM(ISNULL([Sep-2019],0)),  
SUM(ISNULL([Oct-2019],0)), SUM(ISNULL([Nov-2019],0)), SUM(ISNULL([Dec-2019],0)), SUM(ISNULL([Jan-2020],0)), SUM(ISNULL([Feb-2020],0)), SUM(ISNULL([Mar-2020],0)),  
SUM(ISNULL([Apr-2020],0)), SUM(ISNULL([May-2020],0)), SUM(ISNULL([Jun-2020],0)), SUM(ISNULL([Jul-2020],0)), SUM(ISNULL([Aug-2020],0)), SUM(ISNULL([Sep-2020],0)),   
SUM(ISNULL([Oct-2020],0)), SUM(ISNULL([Nov-2020],0)), SUM(ISNULL([Dec-2020],0)), SUM(ISNULL([Jan-2021],0)), SUM(ISNULL([Feb-2021],0)), SUM(ISNULL([Mar-2021],0))  
FROM #TEMPMONTH12  
WHERE PropertyCategory = 'External' AND MarkUp != 0;  
  
INSERT INTO #TEMPMONTH13  
SELECT '', '     Non Commissionable Room Nights HB Property', 8,  
SUM(ISNULL([Apr-2019],0)), SUM(ISNULL([May-2019],0)), SUM(ISNULL([Jun-2019],0)), SUM(ISNULL([Jul-2019],0)), SUM(ISNULL([Aug-2019],0)), SUM(ISNULL([Sep-2019],0)),  
SUM(ISNULL([Oct-2019],0)), SUM(ISNULL([Nov-2019],0)), SUM(ISNULL([Dec-2019],0)), SUM(ISNULL([Jan-2020],0)), SUM(ISNULL([Feb-2020],0)), SUM(ISNULL([Mar-2020],0)),  
SUM(ISNULL([Apr-2020],0)), SUM(ISNULL([May-2020],0)), SUM(ISNULL([Jun-2020],0)), SUM(ISNULL([Jul-2020],0)), SUM(ISNULL([Aug-2020],0)), SUM(ISNULL([Sep-2020],0)),   
SUM(ISNULL([Oct-2020],0)), SUM(ISNULL([Nov-2020],0)), SUM(ISNULL([Dec-2020],0)), SUM(ISNULL([Jan-2021],0)), SUM(ISNULL([Feb-2021],0)), SUM(ISNULL([Mar-2021],0))  
FROM #TEMPMONTH12  
WHERE PropertyCategory = 'External' AND MarkUp = 0;  
  
/*Table 2.4  
  
SELECT * FROM #TEMPMONTH13 WHERE Flg IN (6, 7, 8) ORDER BY Flg;  
  
*/  
  
CREATE TABLE #TEMPMONTH14(MasterPropertyId BIGINT,PropertyCategory NVARCHAR(100),MasterClientId BIGINT,MonthofBooking NVARCHAR(100),Tariff DECIMAL(27,2),Markup DECIMAL(27,2));  
INSERT INTO #TEMPMONTH14(MasterPropertyId,PropertyCategory,MasterClientId,MonthofBooking,Tariff,Markup)  
SELECT MasterPropertyId,PropertyCategory,MasterClientId,Stay_Month,SUM(Tariff),MarkUp FROM #TEMP2  
WHERE PropertyCategory IN ('External', 'C P P')   
GROUP BY MasterPropertyId,PropertyCategory,MasterClientId,Stay_Month,MarkUp,BookingId;  
  
SELECT   MasterPropertyId,PropertyCategory,MasterClientId,Markup,  
         [Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
   [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021]  
INTO #TEMPMONTH15  
FROM #TEMPMONTH14  
PIVOT  
(  
       SUM(Tariff)  
       FOR MonthofBooking IN   
    ([Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
  [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021])  
) AS P;  
  
CREATE TABLE #TEMPMONTH16(MasterPropertyId BIGINT,PropertyCategory NVARCHAR(100),MasterClientId BIGINT,Markup DECIMAL(27,2),  
[Apr-2019] INT, [May-2019] INT, [Jun-2019] INT, [Jul-2019] INT, [Aug-2019] INT, [Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT,  
[Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT,  
[Apr-2020] INT, [May-2020] INT, [Jun-2020] INT, [Jul-2020] INT, [Aug-2020] INT, [Sep-2020] INT, [Oct-2020] INT, [Nov-2020] INT, [Dec-2020] INT,  
[Jan-2021] INT, [Feb-2021] INT, [Mar-2021] INT);  
  
INSERT INTO #TEMPMONTH16  
SELECT MasterPropertyId,PropertyCategory,MasterClientId,Markup,  
ISNULL([Apr-2019], 0), ISNULL([May-2019], 0), ISNULL([Jun-2019], 0), ISNULL([Jul-2019], 0), ISNULL([Aug-2019], 0), ISNULL([Sep-2019], 0), ISNULL([Oct-2019], 0),   
ISNULL([Nov-2019], 0), ISNULL([Dec-2019], 0), ISNULL([Jan-2020], 0), ISNULL([Feb-2020], 0), ISNULL([Mar-2020], 0),  
ISNULL([Apr-2020], 0), ISNULL([May-2020], 0), ISNULL([Jun-2020], 0), ISNULL([Jul-2020], 0), ISNULL([Aug-2020], 0), ISNULL([Sep-2020], 0), ISNULL([Oct-2020], 0),   
ISNULL([Nov-2020], 0), ISNULL([Dec-2020], 0), ISNULL([Jan-2021], 0), ISNULL([Feb-2021], 0), ISNULL([Mar-2021], 0)  
FROM #TEMPMONTH15;  
  
CREATE TABLE #TEMPMONTH117(Title1 NVARCHAR(100),Title2 NVARCHAR(100), Flg INT,  
[Apr-2019] INT, [May-2019] INT, [Jun-2019] INT, [Jul-2019] INT, [Aug-2019] INT, [Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT,  
[Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT,  
[Apr-2020] INT, [May-2020] INT, [Jun-2020] INT, [Jul-2020] INT, [Aug-2020] INT, [Sep-2020] INT, [Oct-2020] INT, [Nov-2020] INT, [Dec-2020] INT,  
[Jan-2021] INT, [Feb-2021] INT, [Mar-2021] INT);  
  
INSERT INTO #TEMPMONTH117  
SELECT 'Chain Vs Non Chain', 'Total No of Hotels ( Value in Rs Lacs )', 1,  
ROUND(SUM([Apr-2019]) * 0.00001, 0), ROUND(SUM([May-2019]) * 0.00001, 0), ROUND(SUM([Jun-2019]) * 0.00001, 0), ROUND(SUM([Jul-2019]) * 0.00001, 0),  
ROUND(SUM([Aug-2019]) * 0.00001, 0), ROUND(SUM([Sep-2019]) * 0.00001, 0), ROUND(SUM([Oct-2019]) * 0.00001, 0), ROUND(SUM([Nov-2019]) * 0.00001, 0),   
ROUND(SUM([Dec-2019]) * 0.00001, 0), ROUND(SUM([Jan-2020]) * 0.00001, 0), ROUND(SUM([Feb-2020]) * 0.00001, 0), ROUND(SUM([Mar-2020]) * 0.00001, 0),  
ROUND(SUM([Apr-2020]) * 0.00001, 0), ROUND(SUM([May-2020]) * 0.00001, 0), ROUND(SUM([Jun-2020]) * 0.00001, 0), ROUND(SUM([Jul-2020]) * 0.00001, 0),   
ROUND(SUM([Aug-2020]) * 0.00001, 0), ROUND(SUM([Sep-2020]) * 0.00001, 0), ROUND(SUM([Oct-2020]) * 0.00001, 0), ROUND(SUM([Nov-2020]) * 0.00001, 0),   
ROUND(SUM([Dec-2020]) * 0.00001, 0), ROUND(SUM([Jan-2021]) * 0.00001, 0), ROUND(SUM([Feb-2021]) * 0.00001, 0), ROUND(SUM([Mar-2021]) * 0.00001, 0)  
FROM #TEMPMONTH16;  
  
INSERT INTO #TEMPMONTH117  
SELECT '', '     Chain Hotels ( Value in Rs Lacs )', 2,  
ROUND(SUM([Apr-2019]) * 0.00001, 0), ROUND(SUM([May-2019]) * 0.00001, 0), ROUND(SUM([Jun-2019]) * 0.00001, 0), ROUND(SUM([Jul-2019]) * 0.00001, 0),  
ROUND(SUM([Aug-2019]) * 0.00001, 0), ROUND(SUM([Sep-2019]) * 0.00001, 0), ROUND(SUM([Oct-2019]) * 0.00001, 0), ROUND(SUM([Nov-2019]) * 0.00001, 0),   
ROUND(SUM([Dec-2019]) * 0.00001, 0), ROUND(SUM([Jan-2020]) * 0.00001, 0), ROUND(SUM([Feb-2020]) * 0.00001, 0), ROUND(SUM([Mar-2020]) * 0.00001, 0),  
ROUND(SUM([Apr-2020]) * 0.00001, 0), ROUND(SUM([May-2020]) * 0.00001, 0), ROUND(SUM([Jun-2020]) * 0.00001, 0), ROUND(SUM([Jul-2020]) * 0.00001, 0),   
ROUND(SUM([Aug-2020]) * 0.00001, 0), ROUND(SUM([Sep-2020]) * 0.00001, 0), ROUND(SUM([Oct-2020]) * 0.00001, 0), ROUND(SUM([Nov-2020]) * 0.00001, 0),   
ROUND(SUM([Dec-2020]) * 0.00001, 0), ROUND(SUM([Jan-2021]) * 0.00001, 0), ROUND(SUM([Feb-2021]) * 0.00001, 0), ROUND(SUM([Mar-2021]) * 0.00001, 0)  
FROM #TEMPMONTH16  
WHERE PropertyCategory IN ('External', 'C P P') AND MasterPropertyId NOT IN (1,0);  
  
INSERT INTO #TEMPMONTH117  
SELECT '', '', 3,  
ROUND(SUM([Apr-2019]) * 0.00001, 0), ROUND(SUM([May-2019]) * 0.00001, 0), ROUND(SUM([Jun-2019]) * 0.00001, 0), ROUND(SUM([Jul-2019]) * 0.00001, 0),  
ROUND(SUM([Aug-2019]) * 0.00001, 0), ROUND(SUM([Sep-2019]) * 0.00001, 0), ROUND(SUM([Oct-2019]) * 0.00001, 0), ROUND(SUM([Nov-2019]) * 0.00001, 0),   
ROUND(SUM([Dec-2019]) * 0.00001, 0), ROUND(SUM([Jan-2020]) * 0.00001, 0), ROUND(SUM([Feb-2020]) * 0.00001, 0), ROUND(SUM([Mar-2020]) * 0.00001, 0),  
ROUND(SUM([Apr-2020]) * 0.00001, 0), ROUND(SUM([May-2020]) * 0.00001, 0), ROUND(SUM([Jun-2020]) * 0.00001, 0), ROUND(SUM([Jul-2020]) * 0.00001, 0),   
ROUND(SUM([Aug-2020]) * 0.00001, 0), ROUND(SUM([Sep-2020]) * 0.00001, 0), ROUND(SUM([Oct-2020]) * 0.00001, 0), ROUND(SUM([Nov-2020]) * 0.00001, 0),   
ROUND(SUM([Dec-2020]) * 0.00001, 0), ROUND(SUM([Jan-2021]) * 0.00001, 0), ROUND(SUM([Feb-2021]) * 0.00001, 0), ROUND(SUM([Mar-2021]) * 0.00001, 0)  
FROM #TEMPMONTH16  
WHERE PropertyCategory IN ('External', 'C P P') AND MasterPropertyId IN (1,0);  
  
INSERT INTO #TEMPMONTH117  
SELECT '', '', 4,  
ROUND(SUM([Apr-2019]) * 0.00001, 0), ROUND(SUM([May-2019]) * 0.00001, 0), ROUND(SUM([Jun-2019]) * 0.00001, 0), ROUND(SUM([Jul-2019]) * 0.00001, 0),  
ROUND(SUM([Aug-2019]) * 0.00001, 0), ROUND(SUM([Sep-2019]) * 0.00001, 0), ROUND(SUM([Oct-2019]) * 0.00001, 0), ROUND(SUM([Nov-2019]) * 0.00001, 0),   
ROUND(SUM([Dec-2019]) * 0.00001, 0), ROUND(SUM([Jan-2020]) * 0.00001, 0), ROUND(SUM([Feb-2020]) * 0.00001, 0), ROUND(SUM([Mar-2020]) * 0.00001, 0),  
ROUND(SUM([Apr-2020]) * 0.00001, 0), ROUND(SUM([May-2020]) * 0.00001, 0), ROUND(SUM([Jun-2020]) * 0.00001, 0), ROUND(SUM([Jul-2020]) * 0.00001, 0),   
ROUND(SUM([Aug-2020]) * 0.00001, 0), ROUND(SUM([Sep-2020]) * 0.00001, 0), ROUND(SUM([Oct-2020]) * 0.00001, 0), ROUND(SUM([Nov-2020]) * 0.00001, 0),   
ROUND(SUM([Dec-2020]) * 0.00001, 0), ROUND(SUM([Jan-2021]) * 0.00001, 0), ROUND(SUM([Feb-2021]) * 0.00001, 0), ROUND(SUM([Mar-2021]) * 0.00001, 0)  
FROM #TEMPMONTH16  
WHERE PropertyCategory NOT IN ('External', 'C P P');  
  
INSERT INTO #TEMPMONTH117  
SELECT '', '     Non Chain Hotels ( Value in Rs Lacs )', 5,  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]),   
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]), SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]),   
SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021])  
FROM #TEMPMONTH117  
WHERE Flg IN (3,4);  
  
/*TABLE 3.1  
  
SELECT * FROM #TEMPMONTH117 WHERE Flg IN (1,2,5) ORDER BY Flg;  
  
*/  
  
CREATE TABLE #TEMPMONTH18(MonthofBooking NVARCHAR(100),Tariff DECIMAL(27,2));  
INSERT INTO #TEMPMONTH18(MonthofBooking,Tariff)  
SELECT Stay_Month,SUM(Tariff) FROM #TEMP2 WHERE Tariff <= 3000 AND PropertyCategory IN ('External', 'C P P')  
GROUP BY Stay_Month;  
  
SELECT   [Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
   [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021]  
INTO #TEMPMONTH19  
FROM #TEMPMONTH18  
PIVOT  
(  
       SUM(Tariff)  
       FOR MonthofBooking IN   
    ([Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
  [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021])  
) AS P;  
  
INSERT INTO #TEMPMONTH117  
SELECT 'Budget Vs Others', 'Budget ( Rs.1 to Rs.3000 per night ) ( Value in Rs Lacs )', 6,  
ROUND(SUM(ISNULL([Apr-2019], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([May-2019], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Jun-2019], 0)) * 0.00001, 0),  
ROUND(SUM(ISNULL([Jul-2019], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Aug-2019], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Sep-2019], 0)) * 0.00001, 0),  
ROUND(SUM(ISNULL([Oct-2019], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Nov-2019], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Dec-2019], 0)) * 0.00001, 0),   
ROUND(SUM(ISNULL([Jan-2020], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Feb-2020], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Mar-2020], 0)) * 0.00001, 0),  
  
ROUND(SUM(ISNULL([Apr-2020], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([May-2020], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Jun-2020], 0)) * 0.00001, 0),   
ROUND(SUM(ISNULL([Jul-2020], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Aug-2020], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Sep-2020], 0)) * 0.00001, 0),   
ROUND(SUM(ISNULL([Oct-2020], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Nov-2020], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Dec-2020], 0)) * 0.00001, 0),   
ROUND(SUM(ISNULL([Jan-2021], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Feb-2021], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Mar-2021], 0)) * 0.00001, 0)  
FROM #TEMPMONTH19;  
  
CREATE TABLE #TEMPMONTH20(MonthofBooking NVARCHAR(100),Tariff DECIMAL(27,2));  
INSERT INTO #TEMPMONTH20(MonthofBooking,Tariff)  
SELECT Stay_Month,SUM(Tariff) FROM #TEMP2 WHERE Tariff > 3000 AND PropertyCategory IN ('External', 'C P P')    
GROUP BY Stay_Month;  
  
SELECT   [Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
   [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021]  
INTO #TEMPMONTH21  
FROM #TEMPMONTH20  
PIVOT  
(  
       SUM(Tariff)  
       FOR MonthofBooking IN   
    ([Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
  [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021])  
) AS P;  
  
INSERT INTO #TEMPMONTH117  
SELECT '', 'Other ( Above Rs.3000 per night ) ( Value in Rs Lacs )', 7,  
ROUND(SUM(ISNULL([Apr-2019], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([May-2019], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Jun-2019], 0)) * 0.00001, 0),  
ROUND(SUM(ISNULL([Jul-2019], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Aug-2019], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Sep-2019], 0)) * 0.00001, 0),  
ROUND(SUM(ISNULL([Oct-2019], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Nov-2019], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Dec-2019], 0)) * 0.00001, 0),   
ROUND(SUM(ISNULL([Jan-2020], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Feb-2020], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Mar-2020], 0)) * 0.00001, 0),  
ROUND(SUM(ISNULL([Apr-2020], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([May-2020], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Jun-2020], 0)) * 0.00001, 0),   
ROUND(SUM(ISNULL([Jul-2020], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Aug-2020], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Sep-2020], 0)) * 0.00001, 0),   
ROUND(SUM(ISNULL([Oct-2020], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Nov-2020], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Dec-2020], 0)) * 0.00001, 0),   
ROUND(SUM(ISNULL([Jan-2021], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Feb-2021], 0)) * 0.00001, 0), ROUND(SUM(ISNULL([Mar-2021], 0)) * 0.00001, 0)  
FROM #TEMPMONTH21;  
  
/*TABLE 3.2  
  
SELECT * FROM #TEMPMONTH117 WHERE Flg IN (6,7) ORDER BY Flg;  
  
*/  
  
INSERT INTO #TEMPMONTH117  
SELECT 'Property Category', 'Client Preferered Property ( Value in Rs Lacs )', 8,  
ROUND(SUM([Apr-2019]) * 0.00001, 0), ROUND(SUM([May-2019]) * 0.00001, 0), ROUND(SUM([Jun-2019]) * 0.00001, 0), ROUND(SUM([Jul-2019]) * 0.00001, 0),  
ROUND(SUM([Aug-2019]) * 0.00001, 0), ROUND(SUM([Sep-2019]) * 0.00001, 0), ROUND(SUM([Oct-2019]) * 0.00001, 0), ROUND(SUM([Nov-2019]) * 0.00001, 0),   
ROUND(SUM([Dec-2019]) * 0.00001, 0), ROUND(SUM([Jan-2020]) * 0.00001, 0), ROUND(SUM([Feb-2020]) * 0.00001, 0), ROUND(SUM([Mar-2020]) * 0.00001, 0),  
ROUND(SUM([Apr-2020]) * 0.00001, 0), ROUND(SUM([May-2020]) * 0.00001, 0), ROUND(SUM([Jun-2020]) * 0.00001, 0), ROUND(SUM([Jul-2020]) * 0.00001, 0),   
ROUND(SUM([Aug-2020]) * 0.00001, 0), ROUND(SUM([Sep-2020]) * 0.00001, 0), ROUND(SUM([Oct-2020]) * 0.00001, 0), ROUND(SUM([Nov-2020]) * 0.00001, 0),   
ROUND(SUM([Dec-2020]) * 0.00001, 0), ROUND(SUM([Jan-2021]) * 0.00001, 0), ROUND(SUM([Feb-2021]) * 0.00001, 0), ROUND(SUM([Mar-2021]) * 0.00001, 0)  
FROM #TEMPMONTH16  
WHERE PropertyCategory IN ('C P P');  
  
INSERT INTO #TEMPMONTH117  
SELECT '', 'HB Partners ( Value in Rs Lacs )', 9,  
ROUND(SUM([Apr-2019]) * 0.00001, 0), ROUND(SUM([May-2019]) * 0.00001, 0), ROUND(SUM([Jun-2019]) * 0.00001, 0), ROUND(SUM([Jul-2019]) * 0.00001, 0),  
ROUND(SUM([Aug-2019]) * 0.00001, 0), ROUND(SUM([Sep-2019]) * 0.00001, 0), ROUND(SUM([Oct-2019]) * 0.00001, 0), ROUND(SUM([Nov-2019]) * 0.00001, 0),   
ROUND(SUM([Dec-2019]) * 0.00001, 0), ROUND(SUM([Jan-2020]) * 0.00001, 0), ROUND(SUM([Feb-2020]) * 0.00001, 0), ROUND(SUM([Mar-2020]) * 0.00001, 0),  
ROUND(SUM([Apr-2020]) * 0.00001, 0), ROUND(SUM([May-2020]) * 0.00001, 0), ROUND(SUM([Jun-2020]) * 0.00001, 0), ROUND(SUM([Jul-2020]) * 0.00001, 0),   
ROUND(SUM([Aug-2020]) * 0.00001, 0), ROUND(SUM([Sep-2020]) * 0.00001, 0), ROUND(SUM([Oct-2020]) * 0.00001, 0), ROUND(SUM([Nov-2020]) * 0.00001, 0),   
ROUND(SUM([Dec-2020]) * 0.00001, 0), ROUND(SUM([Jan-2021]) * 0.00001, 0), ROUND(SUM([Feb-2021]) * 0.00001, 0), ROUND(SUM([Mar-2021]) * 0.00001, 0)  
FROM #TEMPMONTH16  
WHERE PropertyCategory IN ('External');  
  
/*TABLE 3.3  
  
SELECT * FROM #TEMPMONTH117 WHERE Flg IN (8,9) ORDER BY Flg;  
  
*/  
  
INSERT INTO #TEMPMONTH117  
SELECT 'Top clients Vs Others Clients', 'Total No of Clients ( Value in Rs Lacs )', 10,  
ROUND(SUM([Apr-2019]) * 0.00001, 0), ROUND(SUM([May-2019]) * 0.00001, 0), ROUND(SUM([Jun-2019]) * 0.00001, 0), ROUND(SUM([Jul-2019]) * 0.00001, 0),  
ROUND(SUM([Aug-2019]) * 0.00001, 0), ROUND(SUM([Sep-2019]) * 0.00001, 0), ROUND(SUM([Oct-2019]) * 0.00001, 0), ROUND(SUM([Nov-2019]) * 0.00001, 0),   
ROUND(SUM([Dec-2019]) * 0.00001, 0), ROUND(SUM([Jan-2020]) * 0.00001, 0), ROUND(SUM([Feb-2020]) * 0.00001, 0), ROUND(SUM([Mar-2020]) * 0.00001, 0),  
ROUND(SUM([Apr-2020]) * 0.00001, 0), ROUND(SUM([May-2020]) * 0.00001, 0), ROUND(SUM([Jun-2020]) * 0.00001, 0), ROUND(SUM([Jul-2020]) * 0.00001, 0),   
ROUND(SUM([Aug-2020]) * 0.00001, 0), ROUND(SUM([Sep-2020]) * 0.00001, 0), ROUND(SUM([Oct-2020]) * 0.00001, 0), ROUND(SUM([Nov-2020]) * 0.00001, 0),   
ROUND(SUM([Dec-2020]) * 0.00001, 0), ROUND(SUM([Jan-2021]) * 0.00001, 0), ROUND(SUM([Feb-2021]) * 0.00001, 0), ROUND(SUM([Mar-2021]) * 0.00001, 0)  
FROM #TEMPMONTH16  
WHERE PropertyCategory IN ('External', 'C P P') ;  
  
INSERT INTO #TEMPMONTH117  
SELECT '', '     Top Clients ( Value in Rs Lacs )', 11,  
ROUND(SUM([Apr-2019]) * 0.00001, 0), ROUND(SUM([May-2019]) * 0.00001, 0), ROUND(SUM([Jun-2019]) * 0.00001, 0), ROUND(SUM([Jul-2019]) * 0.00001, 0),  
ROUND(SUM([Aug-2019]) * 0.00001, 0), ROUND(SUM([Sep-2019]) * 0.00001, 0), ROUND(SUM([Oct-2019]) * 0.00001, 0), ROUND(SUM([Nov-2019]) * 0.00001, 0),   
ROUND(SUM([Dec-2019]) * 0.00001, 0), ROUND(SUM([Jan-2020]) * 0.00001, 0), ROUND(SUM([Feb-2020]) * 0.00001, 0), ROUND(SUM([Mar-2020]) * 0.00001, 0),  
ROUND(SUM([Apr-2020]) * 0.00001, 0), ROUND(SUM([May-2020]) * 0.00001, 0), ROUND(SUM([Jun-2020]) * 0.00001, 0), ROUND(SUM([Jul-2020]) * 0.00001, 0),   
ROUND(SUM([Aug-2020]) * 0.00001, 0), ROUND(SUM([Sep-2020]) * 0.00001, 0), ROUND(SUM([Oct-2020]) * 0.00001, 0), ROUND(SUM([Nov-2020]) * 0.00001, 0),   
ROUND(SUM([Dec-2020]) * 0.00001, 0), ROUND(SUM([Jan-2021]) * 0.00001, 0), ROUND(SUM([Feb-2021]) * 0.00001, 0), ROUND(SUM([Mar-2021]) * 0.00001, 0)  
FROM #TEMPMONTH16  
WHERE MasterClientId IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1) AND PropertyCategory IN ('External', 'C P P') ;  
  
INSERT INTO #TEMPMONTH117  
SELECT '', '     Other than Top Clients ( Value in Rs Lacs )', 12,  
ROUND(SUM([Apr-2019]) * 0.00001, 0), ROUND(SUM([May-2019]) * 0.00001, 0), ROUND(SUM([Jun-2019]) * 0.00001, 0), ROUND(SUM([Jul-2019]) * 0.00001, 0),  
ROUND(SUM([Aug-2019]) * 0.00001, 0), ROUND(SUM([Sep-2019]) * 0.00001, 0), ROUND(SUM([Oct-2019]) * 0.00001, 0), ROUND(SUM([Nov-2019]) * 0.00001, 0),   
ROUND(SUM([Dec-2019]) * 0.00001, 0), ROUND(SUM([Jan-2020]) * 0.00001, 0), ROUND(SUM([Feb-2020]) * 0.00001, 0), ROUND(SUM([Mar-2020]) * 0.00001, 0),  
ROUND(SUM([Apr-2020]) * 0.00001, 0), ROUND(SUM([May-2020]) * 0.00001, 0), ROUND(SUM([Jun-2020]) * 0.00001, 0), ROUND(SUM([Jul-2020]) * 0.00001, 0),   
ROUND(SUM([Aug-2020]) * 0.00001, 0), ROUND(SUM([Sep-2020]) * 0.00001, 0), ROUND(SUM([Oct-2020]) * 0.00001, 0), ROUND(SUM([Nov-2020]) * 0.00001, 0),   
ROUND(SUM([Dec-2020]) * 0.00001, 0), ROUND(SUM([Jan-2021]) * 0.00001, 0), ROUND(SUM([Feb-2021]) * 0.00001, 0), ROUND(SUM([Mar-2021]) * 0.00001, 0)  
FROM #TEMPMONTH16  
WHERE MasterClientId NOT IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1) AND PropertyCategory IN ('External', 'C P P') ;  
  
/*TABLE 3.4  
  
SELECT * FROM #TEMPMONTH117  
WHERE Flg IN (10,11,12)  
ORDER BY Flg;  
  
*/  
  
INSERT INTO #TEMPMONTH117  
SELECT 'Hotels Pays Commission', 'With Commission ( Value in Rs Lacs )', 13,  
ROUND(SUM([Apr-2019]) * 0.00001, 0), ROUND(SUM([May-2019]) * 0.00001, 0), ROUND(SUM([Jun-2019]) * 0.00001, 0), ROUND(SUM([Jul-2019]) * 0.00001, 0),  
ROUND(SUM([Aug-2019]) * 0.00001, 0), ROUND(SUM([Sep-2019]) * 0.00001, 0), ROUND(SUM([Oct-2019]) * 0.00001, 0), ROUND(SUM([Nov-2019]) * 0.00001, 0),   
ROUND(SUM([Dec-2019]) * 0.00001, 0), ROUND(SUM([Jan-2020]) * 0.00001, 0), ROUND(SUM([Feb-2020]) * 0.00001, 0), ROUND(SUM([Mar-2020]) * 0.00001, 0),  
ROUND(SUM([Apr-2020]) * 0.00001, 0), ROUND(SUM([May-2020]) * 0.00001, 0), ROUND(SUM([Jun-2020]) * 0.00001, 0), ROUND(SUM([Jul-2020]) * 0.00001, 0),   
ROUND(SUM([Aug-2020]) * 0.00001, 0), ROUND(SUM([Sep-2020]) * 0.00001, 0), ROUND(SUM([Oct-2020]) * 0.00001, 0), ROUND(SUM([Nov-2020]) * 0.00001, 0),   
ROUND(SUM([Dec-2020]) * 0.00001, 0), ROUND(SUM([Jan-2021]) * 0.00001, 0), ROUND(SUM([Feb-2021]) * 0.00001, 0), ROUND(SUM([Mar-2021]) * 0.00001, 0)  
FROM #TEMPMONTH16  
WHERE Markup != 0 AND PropertyCategory IN ('External', 'C P P');  
  
INSERT INTO #TEMPMONTH117  
SELECT '', '     Client Preferred Property ( Value in Rs Lacs )', 14,  
ROUND(SUM([Apr-2019]) * 0.00001, 0), ROUND(SUM([May-2019]) * 0.00001, 0), ROUND(SUM([Jun-2019]) * 0.00001, 0), ROUND(SUM([Jul-2019]) * 0.00001, 0),  
ROUND(SUM([Aug-2019]) * 0.00001, 0), ROUND(SUM([Sep-2019]) * 0.00001, 0), ROUND(SUM([Oct-2019]) * 0.00001, 0), ROUND(SUM([Nov-2019]) * 0.00001, 0),   
ROUND(SUM([Dec-2019]) * 0.00001, 0), ROUND(SUM([Jan-2020]) * 0.00001, 0), ROUND(SUM([Feb-2020]) * 0.00001, 0), ROUND(SUM([Mar-2020]) * 0.00001, 0),  
ROUND(SUM([Apr-2020]) * 0.00001, 0), ROUND(SUM([May-2020]) * 0.00001, 0), ROUND(SUM([Jun-2020]) * 0.00001, 0), ROUND(SUM([Jul-2020]) * 0.00001, 0),   
ROUND(SUM([Aug-2020]) * 0.00001, 0), ROUND(SUM([Sep-2020]) * 0.00001, 0), ROUND(SUM([Oct-2020]) * 0.00001, 0), ROUND(SUM([Nov-2020]) * 0.00001, 0),   
ROUND(SUM([Dec-2020]) * 0.00001, 0), ROUND(SUM([Jan-2021]) * 0.00001, 0), ROUND(SUM([Feb-2021]) * 0.00001, 0), ROUND(SUM([Mar-2021]) * 0.00001, 0)  
FROM #TEMPMONTH16  
WHERE PropertyCategory IN ('C P P') AND Markup != 0;  
  
INSERT INTO #TEMPMONTH117  
SELECT '', '     HB Partners Property ( Value in Rs Lacs )', 15,  
ROUND(SUM([Apr-2019]) * 0.00001, 0), ROUND(SUM([May-2019]) * 0.00001, 0), ROUND(SUM([Jun-2019]) * 0.00001, 0), ROUND(SUM([Jul-2019]) * 0.00001, 0),  
ROUND(SUM([Aug-2019]) * 0.00001, 0), ROUND(SUM([Sep-2019]) * 0.00001, 0), ROUND(SUM([Oct-2019]) * 0.00001, 0), ROUND(SUM([Nov-2019]) * 0.00001, 0),   
ROUND(SUM([Dec-2019]) * 0.00001, 0), ROUND(SUM([Jan-2020]) * 0.00001, 0), ROUND(SUM([Feb-2020]) * 0.00001, 0), ROUND(SUM([Mar-2020]) * 0.00001, 0),  
ROUND(SUM([Apr-2020]) * 0.00001, 0), ROUND(SUM([May-2020]) * 0.00001, 0), ROUND(SUM([Jun-2020]) * 0.00001, 0), ROUND(SUM([Jul-2020]) * 0.00001, 0),   
ROUND(SUM([Aug-2020]) * 0.00001, 0), ROUND(SUM([Sep-2020]) * 0.00001, 0), ROUND(SUM([Oct-2020]) * 0.00001, 0), ROUND(SUM([Nov-2020]) * 0.00001, 0),   
ROUND(SUM([Dec-2020]) * 0.00001, 0), ROUND(SUM([Jan-2021]) * 0.00001, 0), ROUND(SUM([Feb-2021]) * 0.00001, 0), ROUND(SUM([Mar-2021]) * 0.00001, 0)  
FROM #TEMPMONTH16  
WHERE PropertyCategory IN ('External') AND Markup != 0;  
  
/*TABLE 3.5  
  
SELECT * FROM #TEMPMONTH117  
WHERE Flg IN (13,14,15)  
ORDER BY Flg;  
  
*/  
  
INSERT INTO #TEMPMONTH117  
SELECT 'Hotels not Paying Commission', 'Without Commission ( Value in Rs Lacs )', 16,  
ROUND(SUM([Apr-2019]) * 0.00001, 0), ROUND(SUM([May-2019]) * 0.00001, 0), ROUND(SUM([Jun-2019]) * 0.00001, 0), ROUND(SUM([Jul-2019]) * 0.00001, 0),  
ROUND(SUM([Aug-2019]) * 0.00001, 0), ROUND(SUM([Sep-2019]) * 0.00001, 0), ROUND(SUM([Oct-2019]) * 0.00001, 0), ROUND(SUM([Nov-2019]) * 0.00001, 0),   
ROUND(SUM([Dec-2019]) * 0.00001, 0), ROUND(SUM([Jan-2020]) * 0.00001, 0), ROUND(SUM([Feb-2020]) * 0.00001, 0), ROUND(SUM([Mar-2020]) * 0.00001, 0),  
ROUND(SUM([Apr-2020]) * 0.00001, 0), ROUND(SUM([May-2020]) * 0.00001, 0), ROUND(SUM([Jun-2020]) * 0.00001, 0), ROUND(SUM([Jul-2020]) * 0.00001, 0),   
ROUND(SUM([Aug-2020]) * 0.00001, 0), ROUND(SUM([Sep-2020]) * 0.00001, 0), ROUND(SUM([Oct-2020]) * 0.00001, 0), ROUND(SUM([Nov-2020]) * 0.00001, 0),   
ROUND(SUM([Dec-2020]) * 0.00001, 0), ROUND(SUM([Jan-2021]) * 0.00001, 0), ROUND(SUM([Feb-2021]) * 0.00001, 0), ROUND(SUM([Mar-2021]) * 0.00001, 0)  
FROM #TEMPMONTH16  
WHERE Markup = 0 AND PropertyCategory IN ('External', 'C P P');  
  
INSERT INTO #TEMPMONTH117  
SELECT '', '     Client Preferred Property ( Value in Rs Lacs )', 17,  
ROUND(SUM([Apr-2019]) * 0.00001, 0), ROUND(SUM([May-2019]) * 0.00001, 0), ROUND(SUM([Jun-2019]) * 0.00001, 0), ROUND(SUM([Jul-2019]) * 0.00001, 0),  
ROUND(SUM([Aug-2019]) * 0.00001, 0), ROUND(SUM([Sep-2019]) * 0.00001, 0), ROUND(SUM([Oct-2019]) * 0.00001, 0), ROUND(SUM([Nov-2019]) * 0.00001, 0),   
ROUND(SUM([Dec-2019]) * 0.00001, 0), ROUND(SUM([Jan-2020]) * 0.00001, 0), ROUND(SUM([Feb-2020]) * 0.00001, 0), ROUND(SUM([Mar-2020]) * 0.00001, 0),  
ROUND(SUM([Apr-2020]) * 0.00001, 0), ROUND(SUM([May-2020]) * 0.00001, 0), ROUND(SUM([Jun-2020]) * 0.00001, 0), ROUND(SUM([Jul-2020]) * 0.00001, 0),   
ROUND(SUM([Aug-2020]) * 0.00001, 0), ROUND(SUM([Sep-2020]) * 0.00001, 0), ROUND(SUM([Oct-2020]) * 0.00001, 0), ROUND(SUM([Nov-2020]) * 0.00001, 0),   
ROUND(SUM([Dec-2020]) * 0.00001, 0), ROUND(SUM([Jan-2021]) * 0.00001, 0), ROUND(SUM([Feb-2021]) * 0.00001, 0), ROUND(SUM([Mar-2021]) * 0.00001, 0)  
FROM #TEMPMONTH16  
WHERE PropertyCategory IN ('C P P') AND Markup = 0;  
  
INSERT INTO #TEMPMONTH117  
SELECT '', '     HB Partners Property ( Value in Rs Lacs )', 20,  
ROUND(SUM([Apr-2019]) * 0.00001, 0), ROUND(SUM([May-2019]) * 0.00001, 0), ROUND(SUM([Jun-2019]) * 0.00001, 0), ROUND(SUM([Jul-2019]) * 0.00001, 0),  
ROUND(SUM([Aug-2019]) * 0.00001, 0), ROUND(SUM([Sep-2019]) * 0.00001, 0), ROUND(SUM([Oct-2019]) * 0.00001, 0), ROUND(SUM([Nov-2019]) * 0.00001, 0),   
ROUND(SUM([Dec-2019]) * 0.00001, 0), ROUND(SUM([Jan-2020]) * 0.00001, 0), ROUND(SUM([Feb-2020]) * 0.00001, 0), ROUND(SUM([Mar-2020]) * 0.00001, 0),  
ROUND(SUM([Apr-2020]) * 0.00001, 0), ROUND(SUM([May-2020]) * 0.00001, 0), ROUND(SUM([Jun-2020]) * 0.00001, 0), ROUND(SUM([Jul-2020]) * 0.00001, 0),   
ROUND(SUM([Aug-2020]) * 0.00001, 0), ROUND(SUM([Sep-2020]) * 0.00001, 0), ROUND(SUM([Oct-2020]) * 0.00001, 0), ROUND(SUM([Nov-2020]) * 0.00001, 0),   
ROUND(SUM([Dec-2020]) * 0.00001, 0), ROUND(SUM([Jan-2021]) * 0.00001, 0), ROUND(SUM([Feb-2021]) * 0.00001, 0), ROUND(SUM([Mar-2021]) * 0.00001, 0)  
FROM #TEMPMONTH16  
WHERE PropertyCategory IN ('External') AND Markup = 0;  
  
/*TABLE 3.6  
  
SELECT * FROM #TEMPMONTH117  
WHERE Flg IN (16,17,18)  
ORDER BY Flg;  
  
*/  
  
CREATE TABLE #TEMPMONTH22(MonthofBooking NVARCHAR(100),Markup DECIMAL(27,2),PropertyCategory NVARCHAR(100));  
INSERT INTO #TEMPMONTH22(MonthofBooking,Markup,PropertyCategory)  
SELECT Stay_Month,SUM(MarkUp),PropertyCategory FROM #TEMP2   
WHERE MarkUp != 0 AND PropertyCategory IN ('External', 'C P P')   
GROUP BY Stay_Month,PropertyCategory;  
  
SELECT   PropertyCategory,  
         [Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
   [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021]  
INTO #TEMPMONTH23  
FROM #TEMPMONTH22  
PIVOT  
(  
       SUM(MarkUp)  
       FOR MonthofBooking IN   
    ([Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
  [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021])  
) AS P;  
  
CREATE TABLE #TEMPMONTH24(PropertyCategory NVARCHAR(100),  
[Apr-2019] INT, [May-2019] INT, [Jun-2019] INT, [Jul-2019] INT, [Aug-2019] INT, [Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT,  
[Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT,  
[Apr-2020] INT, [May-2020] INT, [Jun-2020] INT, [Jul-2020] INT, [Aug-2020] INT, [Sep-2020] INT, [Oct-2020] INT, [Nov-2020] INT, [Dec-2020] INT,  
[Jan-2021] INT, [Feb-2021] INT, [Mar-2021] INT);  
  
INSERT INTO #TEMPMONTH24  
SELECT PropertyCategory,  
ISNULL([Apr-2019], 0), ISNULL([May-2019], 0), ISNULL([Jun-2019], 0), ISNULL([Jul-2019], 0), ISNULL([Aug-2019], 0), ISNULL([Sep-2019], 0), ISNULL([Oct-2019], 0),   
ISNULL([Nov-2019], 0), ISNULL([Dec-2019], 0), ISNULL([Jan-2020], 0), ISNULL([Feb-2020], 0), ISNULL([Mar-2020], 0),  
ISNULL([Apr-2020], 0), ISNULL([May-2020], 0), ISNULL([Jun-2020], 0), ISNULL([Jul-2020], 0), ISNULL([Aug-2020], 0), ISNULL([Sep-2020], 0), ISNULL([Oct-2020], 0),   
ISNULL([Nov-2020], 0), ISNULL([Dec-2020], 0), ISNULL([Jan-2021], 0), ISNULL([Feb-2021], 0), ISNULL([Mar-2021], 0)  
FROM #TEMPMONTH23;  
  
CREATE TABLE #TEMPMONTH25(Title NVARCHAR(100), Flg INT,  
[Apr-2019] INT, [May-2019] INT, [Jun-2019] INT, [Jul-2019] INT, [Aug-2019] INT, [Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT,  
[Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT,  
[Apr-2020] INT, [May-2020] INT, [Jun-2020] INT, [Jul-2020] INT, [Aug-2020] INT, [Sep-2020] INT, [Oct-2020] INT, [Nov-2020] INT, [Dec-2020] INT,  
[Jan-2021] INT, [Feb-2021] INT, [Mar-2021] INT);  
  
INSERT INTO #TEMPMONTH25  
SELECT 'With Commission ( Value in Lacs)', 1,  
ROUND(SUM([Apr-2019]) * 0.00001, 0), ROUND(SUM([May-2019]) * 0.00001, 0), ROUND(SUM([Jun-2019]) * 0.00001, 0), ROUND(SUM([Jul-2019]) * 0.00001, 0),  
ROUND(SUM([Aug-2019]) * 0.00001, 0), ROUND(SUM([Sep-2019]) * 0.00001, 0), ROUND(SUM([Oct-2019]) * 0.00001, 0), ROUND(SUM([Nov-2019]) * 0.00001, 0),   
ROUND(SUM([Dec-2019]) * 0.00001, 0), ROUND(SUM([Jan-2020]) * 0.00001, 0), ROUND(SUM([Feb-2020]) * 0.00001, 0), ROUND(SUM([Mar-2020]) * 0.00001, 0),  
ROUND(SUM([Apr-2020]) * 0.00001, 0), ROUND(SUM([May-2020]) * 0.00001, 0), ROUND(SUM([Jun-2020]) * 0.00001, 0), ROUND(SUM([Jul-2020]) * 0.00001, 0),   
ROUND(SUM([Aug-2020]) * 0.00001, 0), ROUND(SUM([Sep-2020]) * 0.00001, 0), ROUND(SUM([Oct-2020]) * 0.00001, 0), ROUND(SUM([Nov-2020]) * 0.00001, 0),  
ROUND(SUM([Dec-2020]) * 0.00001, 0), ROUND(SUM([Jan-2021]) * 0.00001, 0), ROUND(SUM([Feb-2021]) * 0.00001, 0), ROUND(SUM([Mar-2021]) * 0.00001, 0)  
FROM #TEMPMONTH24;  
  
INSERT INTO #TEMPMONTH25  
SELECT '     Client Preferred Property ( Value in Lacs )', 2,  
ROUND(SUM([Apr-2019]) * 0.00001, 0), ROUND(SUM([May-2019]) * 0.00001, 0), ROUND(SUM([Jun-2019]) * 0.00001, 0), ROUND(SUM([Jul-2019]) * 0.00001, 0),  
ROUND(SUM([Aug-2019]) * 0.00001, 0), ROUND(SUM([Sep-2019]) * 0.00001, 0), ROUND(SUM([Oct-2019]) * 0.00001, 0), ROUND(SUM([Nov-2019]) * 0.00001, 0),   
ROUND(SUM([Dec-2019]) * 0.00001, 0), ROUND(SUM([Jan-2020]) * 0.00001, 0), ROUND(SUM([Feb-2020]) * 0.00001, 0), ROUND(SUM([Mar-2020]) * 0.00001, 0),  
ROUND(SUM([Apr-2020]) * 0.00001, 0), ROUND(SUM([May-2020]) * 0.00001, 0), ROUND(SUM([Jun-2020]) * 0.00001, 0), ROUND(SUM([Jul-2020]) * 0.00001, 0),   
ROUND(SUM([Aug-2020]) * 0.00001, 0), ROUND(SUM([Sep-2020]) * 0.00001, 0), ROUND(SUM([Oct-2020]) * 0.00001, 0), ROUND(SUM([Nov-2020]) * 0.00001, 0),  
ROUND(SUM([Dec-2020]) * 0.00001, 0), ROUND(SUM([Jan-2021]) * 0.00001, 0), ROUND(SUM([Feb-2021]) * 0.00001, 0), ROUND(SUM([Mar-2021]) * 0.00001, 0)  
FROM #TEMPMONTH24  
WHERE PropertyCategory IN ('C P P');  
  
INSERT INTO #TEMPMONTH25  
SELECT '     HB Partners Property ( Value in Lacs )', 3,  
ROUND(SUM([Apr-2019]) * 0.00001, 0), ROUND(SUM([May-2019]) * 0.00001, 0), ROUND(SUM([Jun-2019]) * 0.00001, 0), ROUND(SUM([Jul-2019]) * 0.00001, 0),  
ROUND(SUM([Aug-2019]) * 0.00001, 0), ROUND(SUM([Sep-2019]) * 0.00001, 0), ROUND(SUM([Oct-2019]) * 0.00001, 0), ROUND(SUM([Nov-2019]) * 0.00001, 0),   
ROUND(SUM([Dec-2019]) * 0.00001, 0), ROUND(SUM([Jan-2020]) * 0.00001, 0), ROUND(SUM([Feb-2020]) * 0.00001, 0), ROUND(SUM([Mar-2020]) * 0.00001, 0),  
ROUND(SUM([Apr-2020]) * 0.00001, 0), ROUND(SUM([May-2020]) * 0.00001, 0), ROUND(SUM([Jun-2020]) * 0.00001, 0), ROUND(SUM([Jul-2020]) * 0.00001, 0),   
ROUND(SUM([Aug-2020]) * 0.00001, 0), ROUND(SUM([Sep-2020]) * 0.00001, 0), ROUND(SUM([Oct-2020]) * 0.00001, 0), ROUND(SUM([Nov-2020]) * 0.00001, 0),  
ROUND(SUM([Dec-2020]) * 0.00001, 0), ROUND(SUM([Jan-2021]) * 0.00001, 0), ROUND(SUM([Feb-2021]) * 0.00001, 0), ROUND(SUM([Mar-2021]) * 0.00001, 0)  
FROM #TEMPMONTH24  
WHERE PropertyCategory NOT IN ('C P P');  
  
/*TABLE 5  
SELECT * FROM #TEMPMONTH25  
ORDER BY Flg;  
*/  
  
/* TABLE 6 */  
  
CREATE TABLE #TEMPMONTH117_ClientWise(MasterClientId BIGINT, MasterClientName VARCHAR(100), Id INT IDENTITY(1, 1), Flg INT,  
[Apr-2019] DECIMAL(27, 2), [May-2019] DECIMAL(27, 2), [Jun-2019] DECIMAL(27, 2), [Jul-2019] DECIMAL(27, 2), [Aug-2019] DECIMAL(27, 2), [Sep-2019] DECIMAL(27, 2),  
[Oct-2019] DECIMAL(27, 2), [Nov-2019] DECIMAL(27, 2), [Dec-2019] DECIMAL(27, 2), [Jan-2020] DECIMAL(27, 2), [Feb-2020] DECIMAL(27, 2), [Mar-2020] DECIMAL(27, 2),  
[Apr-2020] DECIMAL(27, 2), [May-2020] DECIMAL(27, 2), [Jun-2020] DECIMAL(27, 2), [Jul-2020] DECIMAL(27, 2), [Aug-2020] DECIMAL(27, 2), [Sep-2020] DECIMAL(27, 2),   
[Oct-2020] DECIMAL(27, 2), [Nov-2020] DECIMAL(27, 2), [Dec-2020] DECIMAL(27, 2), [Jan-2021] DECIMAL(27, 2), [Feb-2021] DECIMAL(27, 2), [Mar-2021] DECIMAL(27, 2));  
  
INSERT INTO #TEMPMONTH117_ClientWise  
SELECT T.MasterClientId, M.ClientName, 2,  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]),   
SUM([Dec-2019]), SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]), SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]),   
SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021])  
FROM #TEMPMONTH16 T  
LEFT OUTER JOIN WRBHBMasterClientManagement M WITH(NOLOCK)ON T.MasterClientId = M.Id  
WHERE Markup = 0 AND T.MasterClientId IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1)  
GROUP BY T.MasterClientId, M.ClientName  
ORDER BY SUM([Aug-2020]) DESC;  
  
INSERT INTO #TEMPMONTH117_ClientWise  
SELECT 0, 'Other Clients', 3,  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]),   
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]), SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]),   
SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021])  
FROM #TEMPMONTH16 T  
LEFT OUTER JOIN WRBHBMasterClientManagement M WITH(NOLOCK)ON T.MasterClientId = M.Id  
WHERE Markup = 0 AND T.MasterClientId NOT IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1);  
  
CREATE TABLE #TEMPMONTH116_Tot(  
[Apr-2019] INT, [May-2019] INT, [Jun-2019] INT, [Jul-2019] INT, [Aug-2019] INT, [Sep-2019] INT,  
[Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT, [Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT,  
[Apr-2020] INT, [May-2020] INT, [Jun-2020] INT, [Jul-2020] INT, [Aug-2020] INT, [Sep-2020] INT,  
[Oct-2020] INT, [Nov-2020] INT, [Dec-2020] INT, [Jan-2021] INT, [Feb-2021] INT, [Mar-2021] INT,  
Flg INT);  
  
INSERT INTO #TEMPMONTH116_Tot  
SELECT  
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]),  
SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]), SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020]), SUM([Sep-2020]),  
SUM([Oct-2020]), SUM([Nov-2020]), SUM([Dec-2020]), SUM([Jan-2021]), SUM([Feb-2021]), SUM([Mar-2021]),  
0  
FROM #TEMPMONTH16;  
  
/* Result */  
  
SELECT '' AS C1,  
'Aug-20' AS C29, 'Jul-20' AS C28, 'Jun-20' AS C27, 'May-20' AS C26, 'Apr-20' AS C25,  
'Tot(2018)-Avg' AS Total,  
'Mar-20' AS C24, 'Feb-20' AS C23, 'Jan-20' AS C22, 'Dec-19' AS C22, 'Nov-19' AS C21, 'Oct-19' AS C20,  
'Sep-19' AS C19, 'Aug-19' AS C18, 'Jul-19' AS C17, 'Jun-19' AS C16, 'May-19' AS C15, 'Apr-19' AS C14;  
  
/* TABLE 1 */  
  
SELECT 'HB Universe' AS Title;  
  
SELECT '', Title,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
CAST(ROUND(CAST([Mar-2020] + [Feb-2020] + [Jan-2020] + [Dec-2019] + [Nov-2019] + [Oct-2019] + [Sep-2019] + [Aug-2019] + [Jul-2019] + [Jun-2019] + [May-2019] + [Apr-2019] AS DECIMAL) / 12, 0) AS INT) AS Total,  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019], [Aug-2019], [Jul-2019], [Jun-2019], [May-2019], [Apr-2019]  
FROM #TEMPMONTH4   
WHERE Flg IN (1,2,3,5)  
ORDER BY Flg;  
  
/* Table 2 */  
  
SELECT 'Room night' AS Title;  
  
/* Table 2.1 */  
  
SELECT Title1, Title2,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
CAST(ROUND(CAST([Mar-2020] + [Feb-2020] + [Jan-2020] + [Dec-2019] + [Nov-2019] + [Oct-2019] + [Sep-2019] + [Aug-2019] + [Jul-2019] + [Jun-2019] + [May-2019] + [Apr-2019] AS DECIMAL) / 12, 0) AS INT) AS Total,  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019], [Aug-2019], [Jul-2019], [Jun-2019], [May-2019], [Apr-2019]  
FROM #TEMPMONTH11  
WHERE Flg IN (1,2,4)  
ORDER BY Flg;  
  
/* Table 2.2 */  
  
SELECT Title1, Title2,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
CAST(ROUND(CAST([Mar-2020] + [Feb-2020] + [Jan-2020] + [Dec-2019] + [Nov-2019] + [Oct-2019] + [Sep-2019] + [Aug-2019] + [Jul-2019] + [Jun-2019] + [May-2019] + [Apr-2019] AS DECIMAL) / 12, 0) AS INT) AS Total,  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019], [Aug-2019], [Jul-2019], [Jun-2019], [May-2019], [Apr-2019]  
FROM #TEMPMONTH13  
WHERE Flg IN (1,2)  
ORDER BY Flg;  
  
/* Table 2.3 */  
  
SELECT Title1, Title2,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
CAST(ROUND(CAST([Mar-2020] + [Feb-2020] + [Jan-2020] + [Dec-2019] + [Nov-2019] + [Oct-2019] + [Sep-2019] + [Aug-2019] + [Jul-2019] + [Jun-2019] + [May-2019] + [Apr-2019] AS DECIMAL) / 12, 0) AS INT) AS Total,  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019], [Aug-2019], [Jul-2019], [Jun-2019], [May-2019], [Apr-2019]  
FROM #TEMPMONTH13  
WHERE Flg IN (3, 4, 5)  
ORDER BY Flg;  
  
/* Table 2.4 */  
  
SELECT Title1, Title2,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
CAST(ROUND(CAST([Mar-2020] + [Feb-2020] + [Jan-2020] + [Dec-2019] + [Nov-2019] + [Oct-2019] + [Sep-2019] + [Aug-2019] + [Jul-2019] + [Jun-2019] + [May-2019] + [Apr-2019] AS DECIMAL) / 12, 0) AS INT) AS Total,  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019], [Aug-2019], [Jul-2019], [Jun-2019], [May-2019], [Apr-2019]  
FROM #TEMPMONTH13  
WHERE Flg IN (6, 7, 8)  
ORDER BY Flg;  
  
/* TABLE 3 */  
  
SELECT 'GTV' AS Title;  
  
/* TABLE 3.1 */  
  
SELECT Title1, Title2,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
CAST(ROUND(CAST([Mar-2020] + [Feb-2020] + [Jan-2020] + [Dec-2019] + [Nov-2019] + [Oct-2019] + [Sep-2019] + [Aug-2019] + [Jul-2019] + [Jun-2019] + [May-2019] + [Apr-2019] AS DECIMAL) / 12, 0) AS INT) AS Total,  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019], [Aug-2019], [Jul-2019], [Jun-2019], [May-2019], [Apr-2019]  
FROM #TEMPMONTH117  
WHERE Flg IN (1,2,5)  
ORDER BY Flg;  
  
/* TABLE 3.2 */  
  
SELECT Title1, Title2,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
CAST(ROUND(CAST([Mar-2020] + [Feb-2020] + [Jan-2020] + [Dec-2019] + [Nov-2019] + [Oct-2019] + [Sep-2019] + [Aug-2019] + [Jul-2019] + [Jun-2019] + [May-2019] + [Apr-2019] AS DECIMAL) / 12, 0) AS INT) AS Total,  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019], [Aug-2019], [Jul-2019], [Jun-2019], [May-2019], [Apr-2019]  
FROM #TEMPMONTH117  
WHERE Flg IN (6,7)  
ORDER BY Flg;  
  
/* TABLE 3.3 */  
  
SELECT Title1, Title2,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
CAST(ROUND(CAST([Mar-2020] + [Feb-2020] + [Jan-2020] + [Dec-2019] + [Nov-2019] + [Oct-2019] + [Sep-2019] + [Aug-2019] + [Jul-2019] + [Jun-2019] + [May-2019] + [Apr-2019] AS DECIMAL) / 12, 0) AS INT) AS Total,  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019], [Aug-2019], [Jul-2019], [Jun-2019], [May-2019], [Apr-2019]  
FROM #TEMPMONTH117  
WHERE Flg IN (8,9)  
ORDER BY Flg;  
  
/* TABLE 3.4 */  
  
SELECT Title1, Title2,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
CAST(ROUND(CAST([Mar-2020] + [Feb-2020] + [Jan-2020] + [Dec-2019] + [Nov-2019] + [Oct-2019] + [Sep-2019] + [Aug-2019] + [Jul-2019] + [Jun-2019] + [May-2019] + [Apr-2019] AS DECIMAL) / 12, 0) AS INT) AS Total,  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019], [Aug-2019], [Jul-2019], [Jun-2019], [May-2019], [Apr-2019]  
FROM #TEMPMONTH117  
WHERE Flg IN (10,11,12)  
ORDER BY Flg;  
  
/* TABLE 3.5 */  
  
SELECT Title1, Title2,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
CAST(ROUND(CAST([Mar-2020] + [Feb-2020] + [Jan-2020] + [Dec-2019] + [Nov-2019] + [Oct-2019] + [Sep-2019] + [Aug-2019] + [Jul-2019] + [Jun-2019] + [May-2019] + [Apr-2019] AS DECIMAL) / 12, 0) AS INT) AS Total,  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019], [Aug-2019], [Jul-2019], [Jun-2019], [May-2019], [Apr-2019]  
FROM #TEMPMONTH117  
WHERE Flg IN (13,14,15)  
ORDER BY Flg;  
  
/* TABLE 3.6 */  
  
SELECT Title1, Title2,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
CAST(ROUND(CAST([Mar-2020] + [Feb-2020] + [Jan-2020] + [Dec-2019] + [Nov-2019] + [Oct-2019] + [Sep-2019] + [Aug-2019] + [Jul-2019] + [Jun-2019] + [May-2019] + [Apr-2019] AS DECIMAL) / 12, 0) AS INT) AS Total,  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019], [Aug-2019], [Jul-2019], [Jun-2019], [May-2019], [Apr-2019]  
FROM #TEMPMONTH117  
WHERE Flg IN (16,17,18)  
ORDER BY Flg;  
  
/* TABLE 4 */  
  
/* TABLE 4.1 */  
  
SELECT 'Ratio %' AS Title;  
  
SELECT '' AS Title1, REPLACE(T1.Title2,' ( Value in Rs Lacs )','') AS Title2,
CASE WHEN T2.[Aug-2020] > 0 THEN CAST(CAST(ROUND(((T1.[Aug-2020] * 10000) / T2.[Aug-2020]) * 0.01, 0) AS INT) AS VARCHAR)+'%' ELSE '0%' END AS [Aug-2020],
CASE WHEN T2.[Jul-2020] > 0 THEN CAST(CAST(ROUND(((T1.[Jul-2020] * 10000) / T2.[Jul-2020]) * 0.01, 0) AS INT) AS VARCHAR)+'%' ELSE '0%' END AS [Jul-2020],
CASE WHEN T2.[Jun-2020] > 0 THEN CAST(CAST(ROUND(((T1.[Jun-2020] * 10000) / T2.[Jun-2020]) * 0.01, 0) AS INT) AS VARCHAR)+'%' ELSE '0%' END AS [Jun-2020],  
CAST(CAST(ROUND(((T1.[May-2020] * 10000) / T2.[May-2020]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [May-2020],  
CAST(CAST(ROUND(((T1.[Apr-2020] * 10000) / T2.[Apr-2020]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Apr-2020],  
CAST(CAST(ROUND((((T1.[Apr-2019] + T1.[May-2019] + T1.[Jun-2019] + T1.[Jul-2019] + T1.[Aug-2019] + T1.[Sep-2019] + T1.[Oct-2019] + T1.[Nov-2019] + T1.[Dec-2019] +   
T1.[Jan-2020] + T1.[Feb-2020] + T1.[Mar-2020]) * 10000) / (T2.[Apr-2019] + T2.[May-2019] + T2.[Jun-2019] + T2.[Jul-2019] + T2.[Aug-2019] + T2.[Sep-2019] + T2.[Oct-2019] +   
T2.[Nov-2019] + T2.[Dec-2019] + T2.[Jan-2020] + T2.[Feb-2020] + T2.[Mar-2020])) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS Total,  
CAST(CAST(ROUND(((T1.[Mar-2020] * 10000) / T2.[Mar-2020]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Mar-2020],  
CAST(CAST(ROUND(((T1.[Feb-2020] * 10000) / T2.[Feb-2020]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Feb-2020],  
CAST(CAST(ROUND(((T1.[Jan-2020] * 10000) / T2.[Jan-2020]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Jan-2020],  
CAST(CAST(ROUND(((T1.[Dec-2019] * 10000) / T2.[Dec-2019]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Dec-2019],  
CAST(CAST(ROUND(((T1.[Nov-2019] * 10000) / T2.[Nov-2019]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Nov-2019],  
CAST(CAST(ROUND(((T1.[Oct-2019] * 10000) / T2.[Oct-2019]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Oct-2019],  
CAST(CAST(ROUND(((T1.[Sep-2019] * 10000) / T2.[Sep-2019]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Sep-2019],  
CAST(CAST(ROUND(((T1.[Aug-2019] * 10000) / T2.[Aug-2019]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Aug-2019],  
CAST(CAST(ROUND(((T1.[Jul-2019] * 10000) / T2.[Jul-2019]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Jul-2019],  
CAST(CAST(ROUND(((T1.[Jun-2019] * 10000) / T2.[Jun-2019]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Jun-2019],  
CAST(CAST(ROUND(((T1.[May-2019] * 10000) / T2.[May-2019]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [May-2019],  
CAST(CAST(ROUND(((T1.[Apr-2019] * 10000) / T2.[Apr-2019]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Apr-2019]  
FROM #TEMPMONTH117 T1  
LEFT OUTER JOIN #TEMPMONTH117 T2 WITH(NOLOCK)ON T2.Flg = 1  
WHERE T1.Flg IN (13, 14, 15)  
ORDER BY T1.Flg;  
  
/* TABLE 4.2 */  
  
SELECT 'Opportunity %' AS Title;  
  
SELECT '' AS Title1, REPLACE(T1.Title2,' ( Value in Rs Lacs )','') AS Title2,  
CASE WHEN T2.[Aug-2020] > 0 THEN CAST(CAST(ROUND(((T1.[Aug-2020] * 10000) / T2.[Aug-2020]) * 0.01, 0) AS INT) AS VARCHAR)+'%' ELSE '0%' END AS [Aug-2020],
CASE WHEN T2.[Jul-2020] > 0 THEN CAST(CAST(ROUND(((T1.[Jul-2020] * 10000) / T2.[Jul-2020]) * 0.01, 0) AS INT) AS VARCHAR)+'%' ELSE '0%' END AS [Jul-2020],  
CASE WHEN T2.[Jun-2020] > 0 THEN CAST(CAST(ROUND(((T1.[Jun-2020] * 10000) / T2.[Jun-2020]) * 0.01, 0) AS INT) AS VARCHAR)+'%' ELSE '0%' END AS [Jun-2020],  
CAST(CAST(ROUND(((T1.[May-2020] * 10000) / T2.[May-2020]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [May-2020],  
CAST(CAST(ROUND(((T1.[Apr-2020] * 10000) / T2.[Apr-2020]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Apr-2020],  
CAST(CAST(ROUND((((T1.[Apr-2019] + T1.[May-2019] + T1.[Jun-2019] + T1.[Jul-2019] + T1.[Aug-2019] + T1.[Sep-2019] + T1.[Oct-2019] + T1.[Nov-2019] + T1.[Dec-2019] +   
T1.[Jan-2020] + T1.[Feb-2020] + T1.[Mar-2020]) * 10000) / (T2.[Apr-2019] + T2.[May-2019] + T2.[Jun-2019] + T2.[Jul-2019] + T2.[Aug-2019] + T2.[Sep-2019] + T2.[Oct-2019] +   
T2.[Nov-2019] + T2.[Dec-2019] + T2.[Jan-2020] + T2.[Feb-2020] + T2.[Mar-2020])) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS Total,  
CAST(CAST(ROUND(((T1.[Mar-2020] * 10000) / T2.[Mar-2020]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Mar-2020],  
CAST(CAST(ROUND(((T1.[Feb-2020] * 10000) / T2.[Feb-2020]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Feb-2020],  
CAST(CAST(ROUND(((T1.[Jan-2020] * 10000) / T2.[Jan-2020]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Jan-2020],  
CAST(CAST(ROUND(((T1.[Dec-2019] * 10000) / T2.[Dec-2019]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Dec-2019],  
CAST(CAST(ROUND(((T1.[Nov-2019] * 10000) / T2.[Nov-2019]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Nov-2019],  
CAST(CAST(ROUND(((T1.[Oct-2019] * 10000) / T2.[Oct-2019]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Oct-2019],  
CAST(CAST(ROUND(((T1.[Sep-2019] * 10000) / T2.[Sep-2019]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Sep-2019],  
CAST(CAST(ROUND(((T1.[Aug-2019] * 10000) / T2.[Aug-2019]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Aug-2019],  
CAST(CAST(ROUND(((T1.[Jul-2019] * 10000) / T2.[Jul-2019]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Jul-2019],  
CAST(CAST(ROUND(((T1.[Jun-2019] * 10000) / T2.[Jun-2019]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Jun-2019],  
CAST(CAST(ROUND(((T1.[May-2019] * 10000) / T2.[May-2019]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [May-2019],  
CAST(CAST(ROUND(((T1.[Apr-2019] * 10000) / T2.[Apr-2019]) * 0.01, 0) AS INT) AS VARCHAR)+'%' AS [Apr-2019]  
FROM #TEMPMONTH117 T1  
LEFT OUTER JOIN #TEMPMONTH117 T2 WITH(NOLOCK)ON T2.Flg = 1  
WHERE T1.Flg IN (16, 17, 18)  
ORDER BY T1.Flg;  
  
/* TABLE 5 */  
  
SELECT 'Net Revenue' AS Title;  
  
/* TABLE 5.1 */  
  
SELECT '' AS Title1, Title AS Title2,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
CAST(ROUND(CAST([Mar-2020] + [Feb-2020] + [Jan-2020] + [Dec-2019] + [Nov-2019] + [Oct-2019] + [Sep-2019] + [Aug-2019] + [Jul-2019] + [Jun-2019] + [May-2019] + [Apr-2019] AS DECIMAL) / 12, 0) AS INT) AS Total,  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019], [Aug-2019], [Jul-2019], [Jun-2019], [May-2019], [Apr-2019]  
FROM #TEMPMONTH25  
ORDER BY Flg;  
  
/* TABLE 6 */  
  
SELECT 'Client Wise Opportunity %' AS Title;  
  
/* TABLE 6.1 */  
  
SELECT '' AS Title1, T1.MasterClientName AS Title2,  
CASE WHEN T2.[Aug-2020] > 0 THEN CAST(ROUND(((T1.[Aug-2020] * 10000) / T2.[Aug-2020]) * 0.01, 0) AS INT) ELSE 0 END AS [Aug-2020],
CASE WHEN T2.[Jul-2020] > 0 THEN CAST(ROUND(((T1.[Jul-2020] * 10000) / T2.[Jul-2020]) * 0.01, 0) AS INT) ELSE 0 END AS [Jul-2020],  
CASE WHEN T2.[Jun-2020] > 0 THEN CAST(ROUND(((T1.[Jun-2020] * 10000) / T2.[Jun-2020]) * 0.01, 0) AS INT) ELSE 0 END AS [Jun-2020],  
CAST(ROUND(((T1.[May-2020] * 10000) / T2.[May-2020]) * 0.01, 0) AS INT) AS [May-2020],  
CAST(ROUND(((T1.[Apr-2020] * 10000) / T2.[Apr-2020]) * 0.01, 0) AS INT) AS [Apr-2020],  
CAST(ROUND((((T1.[Apr-2019] + T1.[May-2019] + T1.[Jun-2019] + T1.[Jul-2019] + T1.[Aug-2019] + T1.[Sep-2019] + T1.[Oct-2019] + T1.[Nov-2019] + T1.[Dec-2019] +   
T1.[Jan-2020] + T1.[Feb-2020] + T1.[Mar-2020]) * 10000) / (T2.[Apr-2019] + T2.[May-2019] + T2.[Jun-2019] + T2.[Jul-2019] + T2.[Aug-2019] + T2.[Sep-2019] + T2.[Oct-2019] +   
T2.[Nov-2019] + T2.[Dec-2019] + T2.[Jan-2020] + T2.[Feb-2020] + T2.[Mar-2020])) * 0.01, 0) AS INT) AS Total,  
CAST(ROUND(((T1.[Mar-2020] * 10000) / T2.[Mar-2020]) * 0.01, 0) AS INT) AS [Mar-2020],  
CAST(ROUND(((T1.[Feb-2020] * 10000) / T2.[Feb-2020]) * 0.01, 0) AS INT) AS [Feb-2020],  
CAST(ROUND(((T1.[Jan-2020] * 10000) / T2.[Jan-2020]) * 0.01, 0) AS INT) AS [Jan-2020],  
CAST(ROUND(((T1.[Dec-2019] * 10000) / T2.[Dec-2019]) * 0.01, 0) AS INT) AS [Dec-2019],  
CAST(ROUND(((T1.[Nov-2019] * 10000) / T2.[Nov-2019]) * 0.01, 0) AS INT) AS [Nov-2019],  
CAST(ROUND(((T1.[Oct-2019] * 10000) / T2.[Oct-2019]) * 0.01, 0) AS INT) AS [Oct-2019],  
CAST(ROUND(((T1.[Sep-2019] * 10000) / T2.[Sep-2019]) * 0.01, 0) AS INT) AS [Sep-2019],  
CAST(ROUND(((T1.[Aug-2019] * 10000) / T2.[Aug-2019]) * 0.01, 0) AS INT) AS [Aug-2019],  
CAST(ROUND(((T1.[Jul-2019] * 10000) / T2.[Jul-2019]) * 0.01, 0) AS INT) AS [Jul-2019],  
CAST(ROUND(((T1.[Jun-2019] * 10000) / T2.[Jun-2019]) * 0.01, 0) AS INT) AS [Jun-2019],  
CAST(ROUND(((T1.[May-2019] * 10000) / T2.[May-2019]) * 0.01, 0) AS INT) AS [May-2019],  
CAST(ROUND(((T1.[Apr-2019] * 10000) / T2.[Apr-2019]) * 0.01, 0) AS INT) AS [Apr-2019]  
FROM #TEMPMONTH117_ClientWise T1  
LEFT OUTER JOIN #TEMPMONTH116_Tot T2 WITH(NOLOCK)ON T2.Flg = 0  
ORDER BY T1.Flg, T1.Id;  
  
/* Table 7 */  
  
SELECT 'Client Wise Booking Count' AS Title;  
  
/* External & CPP Booking Count Start */  
  
CREATE TABLE #Temp_Booking(MasterClientId BIGINT, BookingId BIGINT, BookedDt VARCHAR(100));  
INSERT INTO #Temp_Booking  
SELECT T.MasterClientId, T.BookingId, T.BookedDt FROM #TEMP1 T  
WHERE  
PropertyCategory IN ('External', 'C P P') AND  
T.BookedDt IN ('Apr-2019', 'May-2019', 'Jun-2019', 'Jul-2019', 'Aug-2019', 'Sep-2019', 'Oct-2019', 'Nov-2019', 'Dec-2019', 'Jan-2020', 'Feb-2020', 'Mar-2020',  
               'Apr-2020', 'May-2020', 'Jun-2020', 'Jul-2020', 'Aug-2020')  
GROUP BY T.MasterClientId, T.BookingId, T.BookedDt;  
  
CREATE TABLE #TMP_Booking(BookingCount INT, BookedDt VARCHAR(100), MasterClientId BIGINT);  
INSERT INTO #TMP_Booking  
SELECT COUNT(BookingId), BookedDt, MasterClientId FROM #Temp_Booking GROUP BY BookedDt, MasterClientId;  
  
SELECT   MasterClientId,  
   [Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
   [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021]  
INTO #Temp_BookingCount  
FROM #TMP_Booking  
PIVOT  
(  
       SUM(BookingCount)  
       FOR BookedDt IN   
    ([Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
  [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021])  
) AS P;  
  
CREATE TABLE #Temp_BookingCnt(MasterClientId BIGINT, MasterClientName VARCHAR(100), Flg INT, Id INT IDENTITY(1,1),  
[Apr-2019] INT, [May-2019] INT, [Jun-2019] INT, [Jul-2019] INT, [Aug-2019] INT, [Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT,  
[Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT,  
[Apr-2020] INT, [May-2020] INT, [Jun-2020] INT, [Jul-2020] INT, [Aug-2020] INT, [Sep-2020] INT, [Oct-2020] INT, [Nov-2020] INT, [Dec-2020] INT,  
[Jan-2021] INT, [Feb-2021] INT, [Mar-2021] INT);  
  
INSERT INTO #Temp_BookingCnt  
SELECT T.MasterClientId, M.ClientName, 2,  
SUM(ISNULL([Apr-2019],0)), SUM(ISNULL([May-2019],0)), SUM(ISNULL([Jun-2019],0)), SUM(ISNULL([Jul-2019],0)), SUM(ISNULL([Aug-2019],0)), SUM(ISNULL([Sep-2019],0)),  
SUM(ISNULL([Oct-2019],0)), SUM(ISNULL([Nov-2019],0)), SUM(ISNULL([Dec-2019],0)), SUM(ISNULL([Jan-2020],0)), SUM(ISNULL([Feb-2020],0)), SUM(ISNULL([Mar-2020],0)),  
SUM(ISNULL([Apr-2020],0)), SUM(ISNULL([May-2020],0)), SUM(ISNULL([Jun-2020],0)), SUM(ISNULL([Jul-2020],0)), SUM(ISNULL([Aug-2020],0)), SUM(ISNULL([Sep-2020],0)),  
SUM(ISNULL([Oct-2020],0)), SUM(ISNULL([Nov-2020],0)), SUM(ISNULL([Dec-2020],0)), SUM(ISNULL([Jan-2021],0)), SUM(ISNULL([Feb-2021],0)), SUM(ISNULL([Mar-2021],0))  
FROM #Temp_BookingCount T  
LEFT OUTER JOIN WRBHBMasterClientManagement M WITH(NOLOCK)ON T.MasterClientId = M.Id  
WHERE T.MasterClientId IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1)  
GROUP BY T.MasterClientId, M.ClientName  
ORDER BY SUM(ISNULL([Aug-2020], 0)) DESC;  
  
INSERT INTO #Temp_BookingCnt  
SELECT 0, 'Other Clients', 3,  
SUM(ISNULL([Apr-2019],0)), SUM(ISNULL([May-2019],0)), SUM(ISNULL([Jun-2019],0)), SUM(ISNULL([Jul-2019],0)), SUM(ISNULL([Aug-2019],0)), SUM(ISNULL([Sep-2019],0)),  
SUM(ISNULL([Oct-2019],0)), SUM(ISNULL([Nov-2019],0)), SUM(ISNULL([Dec-2019],0)), SUM(ISNULL([Jan-2020],0)), SUM(ISNULL([Feb-2020],0)), SUM(ISNULL([Mar-2020],0)),  
SUM(ISNULL([Apr-2020],0)), SUM(ISNULL([May-2020],0)), SUM(ISNULL([Jun-2020],0)), SUM(ISNULL([Jul-2020],0)), SUM(ISNULL([Aug-2020],0)), SUM(ISNULL([Sep-2020],0)),  
SUM(ISNULL([Oct-2020],0)), SUM(ISNULL([Nov-2020],0)), SUM(ISNULL([Dec-2020],0)), SUM(ISNULL([Jan-2021],0)), SUM(ISNULL([Feb-2021],0)), SUM(ISNULL([Mar-2021],0))  
FROM #Temp_BookingCount T  
LEFT OUTER JOIN WRBHBMasterClientManagement M WITH(NOLOCK)ON T.MasterClientId = M.Id  
WHERE T.MasterClientId NOT IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1);  
  
/* External & CPP Booking Count End */  
  
/* GH Booking Count Start */  
  
CREATE TABLE #Temp_Booking_MGH(MasterClientId BIGINT, BookingId BIGINT, BookedDt VARCHAR(100));  
INSERT INTO #Temp_Booking_MGH  
SELECT T.MasterClientId, T.BookingId, T.BookedDt FROM #TEMP1 T  
WHERE  
PropertyCategory IN ('G H') AND  
T.BookedDt IN ('Apr-2019', 'May-2019', 'Jun-2019', 'Jul-2019', 'Aug-2019', 'Sep-2019', 'Oct-2019', 'Nov-2019', 'Dec-2019', 'Jan-2020', 'Feb-2020', 'Mar-2020',  
               'Apr-2020', 'May-2020', 'Jun-2020', 'Jul-2020', 'Aug-2020')  
GROUP BY T.MasterClientId, T.BookingId, T.BookedDt;  
  
CREATE TABLE #TMP_Booking_MGH(BookingCount INT, BookedDt VARCHAR(100), MasterClientId BIGINT);  
INSERT INTO #TMP_Booking_MGH  
SELECT COUNT(BookingId), BookedDt, MasterClientId FROM #Temp_Booking_MGH GROUP BY BookedDt, MasterClientId;  
  
SELECT   MasterClientId,  
   [Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
   [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021]  
INTO #Temp_BookingCount_MGH  
FROM #TMP_Booking_MGH  
PIVOT  
(  
       SUM(BookingCount)  
       FOR BookedDt IN   
    ([Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
  [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020], [Sep-2020], [Oct-2020], [Nov-2020], [Dec-2020], [Jan-2021], [Feb-2021], [Mar-2021])  
) AS P;  
  
INSERT INTO #Temp_BookingCnt  
SELECT T.MasterClientId, M.ClientName, 6,  
SUM(ISNULL([Apr-2019],0)), SUM(ISNULL([May-2019],0)), SUM(ISNULL([Jun-2019],0)), SUM(ISNULL([Jul-2019],0)), SUM(ISNULL([Aug-2019],0)), SUM(ISNULL([Sep-2019],0)),  
SUM(ISNULL([Oct-2019],0)), SUM(ISNULL([Nov-2019],0)), SUM(ISNULL([Dec-2019],0)), SUM(ISNULL([Jan-2020],0)), SUM(ISNULL([Feb-2020],0)), SUM(ISNULL([Mar-2020],0)),  
SUM(ISNULL([Apr-2020],0)), SUM(ISNULL([May-2020],0)), SUM(ISNULL([Jun-2020],0)), SUM(ISNULL([Jul-2020],0)), SUM(ISNULL([Aug-2020],0)), SUM(ISNULL([Sep-2020],0)),  
SUM(ISNULL([Oct-2020],0)), SUM(ISNULL([Nov-2020],0)), SUM(ISNULL([Dec-2020],0)), SUM(ISNULL([Jan-2021],0)), SUM(ISNULL([Feb-2021],0)), SUM(ISNULL([Mar-2021],0))  
FROM #Temp_BookingCount_MGH T  
LEFT OUTER JOIN WRBHBMasterClientManagement M WITH(NOLOCK)ON T.MasterClientId = M.Id  
WHERE T.MasterClientId IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1)  
GROUP BY T.MasterClientId, M.ClientName  
ORDER BY SUM(ISNULL([Aug-2020], 0)) DESC;  
  
INSERT INTO #Temp_BookingCnt  
SELECT 0, 'Other Clients', 7,  
SUM(ISNULL([Apr-2019],0)), SUM(ISNULL([May-2019],0)), SUM(ISNULL([Jun-2019],0)), SUM(ISNULL([Jul-2019],0)), SUM(ISNULL([Aug-2019],0)), SUM(ISNULL([Sep-2019],0)),  
SUM(ISNULL([Oct-2019],0)), SUM(ISNULL([Nov-2019],0)), SUM(ISNULL([Dec-2019],0)), SUM(ISNULL([Jan-2020],0)), SUM(ISNULL([Feb-2020],0)), SUM(ISNULL([Mar-2020],0)),  
SUM(ISNULL([Apr-2020],0)), SUM(ISNULL([May-2020],0)), SUM(ISNULL([Jun-2020],0)), SUM(ISNULL([Jul-2020],0)), SUM(ISNULL([Aug-2020],0)), SUM(ISNULL([Sep-2020],0)),  
SUM(ISNULL([Oct-2020],0)), SUM(ISNULL([Nov-2020],0)), SUM(ISNULL([Dec-2020],0)), SUM(ISNULL([Jan-2021],0)), SUM(ISNULL([Feb-2021],0)), SUM(ISNULL([Mar-2021],0))  
FROM #Temp_BookingCount_MGH T  
LEFT OUTER JOIN WRBHBMasterClientManagement M WITH(NOLOCK)ON T.MasterClientId = M.Id  
WHERE T.MasterClientId NOT IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1);  
  
/* GH Booking Count End */  
  
DECLARE @MasterClinetId BIGINT;  
  
/* Table 7.1 */  
  
SELECT TOP 1 @MasterClinetId = MasterClientId FROM #Temp_BookingCnt WHERE Flg = 2 ORDER BY Id;  
  
SELECT (CASE WHEN MasterClientId = @MasterClinetId THEN 'External & CPP Booking Count' ELSE '' END) AS Title1, MasterClientName AS Title2,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
CAST(ROUND(CAST([Mar-2020] + [Feb-2020] + [Jan-2020] + [Dec-2019] + [Nov-2019] + [Oct-2019] + [Sep-2019] + [Aug-2019] + [Jul-2019] + [Jun-2019] + [May-2019] + [Apr-2019] AS DECIMAL) / 12, 0) AS INT) AS Total,  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019], [Aug-2019], [Jul-2019], [Jun-2019], [May-2019], [Apr-2019]  
FROM #Temp_BookingCnt  
WHERE Flg IN (2, 3)  
ORDER BY Flg, Id;  
  
/* Table 7.2 */  
  
SELECT TOP 1 @MasterClinetId = MasterClientId FROM #Temp_BookingCnt WHERE Flg = 6 ORDER BY Id;  
  
SELECT (CASE WHEN MasterClientId = @MasterClinetId THEN 'GH Booking Count' ELSE '' END) AS Title1, MasterClientName AS Title2,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
CAST(ROUND(CAST([Mar-2020] + [Feb-2020] + [Jan-2020] + [Dec-2019] + [Nov-2019] + [Oct-2019] + [Sep-2019] + [Aug-2019] + [Jul-2019] + [Jun-2019] + [May-2019] + [Apr-2019] AS DECIMAL) / 12, 0) AS INT) AS Total,  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019], [Aug-2019], [Jul-2019], [Jun-2019], [May-2019], [Apr-2019]  
FROM #Temp_BookingCnt  
WHERE Flg IN (6, 7)  
ORDER BY Flg, Id;  
  
/* Monthly Analysis Report End */  
  
/* Revnue Report - #Start */    
SELECT '' AS C99,  
'Aug-20' AS C18, 'Jul-20' AS C17, 'Jun-20' AS C16, 'May-20' AS C15, 'Apr-20' AS C14,  
'Mar-20' AS C13, 'Feb-20' AS C12, 'Jan-20' AS C11, 'Dec-19' AS C10, 'Nov-19' AS C09, 'Oct-19' AS C08,  
'Sep-19' AS C07;  
  
CREATE TABLE #Fee_BookingDtls(BookingId BIGINT, CheckInDt DATE, CheckOutDt DATE, GuestId BIGINT, RoomCaptured BIGINT, PropertyCategory NVARCHAR(100),  
ClientId BIGINT, MasterClientId BIGINT, Booked_Month VARCHAR(100), TransactionFee DECIMAL(27, 2), TransactionFee_Type NVARCHAR(100), Stay_Days INT);  
  
INSERT INTO #Fee_BookingDtls  
SELECT S.BookingId, MIN(S.CheckInDt), MAX(S.CheckOutDt), S.GuestId, S.RoomCaptured, S.PropertyCategory, S.ClientId, C.MasterClientId,  
SUBSTRING(DATENAME(MONTH, S.BookingDate), 1, 3) + '-' + CAST(YEAR(S.BookingDate) AS VARCHAR), S.TransactionFee, S.TransactionFee_Type,  
DATEDIFF(DAY, MIN(S.CheckInDt), MAX(S.CheckOutDt))  
FROM  
WRBHBBookingStatus S  
LEFT OUTER JOIN WRBHBClientManagement C WITH(NOLOCK)ON C.Id = S.ClientId  
WHERE  
S.Status != 'Canceled' AND S.TransactionFee <> 0 AND S.TransactionFee_Type <> ''  
GROUP BY  
S.BookingId, S.CheckInDt, S.CheckOutDt, S.GuestId, S.RoomCaptured, S.PropertyCategory, S.ClientId, C.MasterClientId, S.BookingDate, S.TransactionFee, S.TransactionFee_Type;  
  
/*SELECT * FROM #Fee_BookingDtls;*/  
  
/* PerGuests, Perbooking, PerRoomNight */  
  
CREATE TABLE #TransactionFee(ClientId BIGINT, TransactionFee DECIMAL(27, 2), Booked_Month NVARCHAR(100), PropertyCategory NVARCHAR(100), MasterClientId BIGINT,  
TransactionFee_Type NVARCHAR(100));  
  
IF EXISTS(SELECT BookingId FROM #Fee_BookingDtls WHERE TransactionFee_Type = 'PerGuests')  
BEGIN  
  
INSERT INTO #TransactionFee(ClientId, TransactionFee, Booked_Month, PropertyCategory, MasterClientId, TransactionFee_Type)  
SELECT ClientId, SUM(TransactionFee), Booked_Month, PropertyCategory, MasterClientId, TransactionFee_Type  
FROM  
#Fee_BookingDtls  
WHERE  
TransactionFee_Type = 'PerGuests'  
GROUP BY  
ClientId, Booked_Month, PropertyCategory, MasterClientId, TransactionFee_Type;  
  
END  
  
IF EXISTS(SELECT BookingId FROM #Fee_BookingDtls WHERE TransactionFee_Type = 'Perbooking')  
BEGIN  
  
CREATE TABLE #Perbooking(ClientId BIGINT, BookingId BIGINT, TransactionFee DECIMAL(27, 2), Booked_Month NVARCHAR(100), PropertyCategory NVARCHAR(100), MasterClientId BIGINT);  
INSERT INTO #Perbooking  
SELECT DISTINCT ClientId, BookingId, TransactionFee, Booked_Month, PropertyCategory, MasterClientId  
FROM  
#Fee_BookingDtls  
WHERE  
TransactionFee_Type = 'Perbooking';  
  
INSERT INTO #TransactionFee(ClientId, TransactionFee, Booked_Month, PropertyCategory, MasterClientId, TransactionFee_Type)  
SELECT ClientId, SUM(TransactionFee), Booked_Month, PropertyCategory, MasterClientId, 'Perbooking'  
FROM  
#Perbooking  
GROUP BY  
ClientId, Booked_Month, PropertyCategory, MasterClientId;  
  
END  
  
IF EXISTS(SELECT BookingId FROM #Fee_BookingDtls WHERE TransactionFee_Type = 'PerRoomNight')  
BEGIN  
  
CREATE TABLE #PerRoomNight(ClientId BIGINT, BookingId BIGINT, TransactionFee DECIMAL(27, 2), Booked_Month NVARCHAR(100), PropertyCategory NVARCHAR(100), MasterClientId BIGINT);  
INSERT INTO #PerRoomNight  
SELECT ClientId, BookingId, TransactionFee * Stay_Days, Booked_Month, PropertyCategory, MasterClientId  
FROM  
#Fee_BookingDtls  
WHERE  
TransactionFee_Type = 'PerRoomNight'  
GROUP BY  
ClientId, BookingId, TransactionFee, Stay_Days, Booked_Month, PropertyCategory, MasterClientId, RoomCaptured;  
  
INSERT INTO #TransactionFee(ClientId, TransactionFee, Booked_Month, PropertyCategory, MasterClientId, TransactionFee_Type)  
SELECT ClientId, SUM(TransactionFee), Booked_Month, PropertyCategory, MasterClientId, 'PerRoomNight'  
FROM  
#PerRoomNight  
GROUP BY  
ClientId, Booked_Month, PropertyCategory, MasterClientId;  
  
END  
  
/*SELECT * FROM #TransactionFee;RETURN;*/  
  
SELECT   ClientId, PropertyCategory, MasterClientId,  
   [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020], [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020]
INTO #TransactionFee_Month_Split  
FROM #TransactionFee  
PIVOT  
(  
       SUM(TransactionFee)  
       FOR Booked_Month IN   
       ([Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020], [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020])  
) AS P;  
  
CREATE TABLE #TransactionFee_Dtls(ClientId BIGINT, PropertyCategory NVARCHAR(100), MasterClientId BIGINT,  
[Sep-2019] DECIMAL(27, 2),  
[Oct-2019] DECIMAL(27, 2), [Nov-2019] DECIMAL(27, 2), [Dec-2019] DECIMAL(27, 2), [Jan-2020] DECIMAL(27, 2), [Feb-2020] DECIMAL(27, 2), [Mar-2020] DECIMAL(27, 2),  
[Apr-2020] DECIMAL(27, 2), [May-2020] DECIMAL(27, 2), [Jun-2020] DECIMAL(27, 2), [Jul-2020] DECIMAL(27, 2), [Aug-2020] DECIMAL(27, 2));
  
INSERT INTO #TransactionFee_Dtls  
SELECT ClientId, PropertyCategory, MasterClientId,  
ISNULL([Sep-2019], 0),  
ISNULL([Oct-2019], 0), ISNULL([Nov-2019], 0), ISNULL([Dec-2019], 0), ISNULL([Jan-2020], 0), ISNULL([Feb-2020], 0), ISNULL([Mar-2020], 0), ISNULL([Apr-2020], 0),  
ISNULL([May-2020], 0), ISNULL([Jun-2020], 0), ISNULL([Jul-2020], 0), ISNULL([Aug-2020], 0)
FROM #TransactionFee_Month_Split;  
  
CREATE TABLE #Revenue_Table1(Title NVARCHAR(100), Flg INT,  
[Sep-2019] DECIMAL(27, 2),  
[Oct-2019] DECIMAL(27, 2), [Nov-2019] DECIMAL(27, 2), [Dec-2019] DECIMAL(27, 2), [Jan-2020] DECIMAL(27, 2), [Feb-2020] DECIMAL(27, 2), [Mar-2020] DECIMAL(27, 2),  
[Apr-2020] DECIMAL(27, 2), [May-2020] DECIMAL(27, 2), [Jun-2020] DECIMAL(27, 2), [Jul-2020] DECIMAL(27, 2), [Aug-2020] DECIMAL(27, 2));
  
INSERT INTO #Revenue_Table1  
SELECT 'Total Transaction Fee' AS Title, 1,  
ROUND(SUM([Sep-2019]) * 0.00001, 2), ROUND(SUM([Oct-2019]) * 0.00001, 2), ROUND(SUM([Nov-2019]) * 0.00001, 2),  
ROUND(SUM([Dec-2019]) * 0.00001, 2), ROUND(SUM([Jan-2020]) * 0.00001, 2), ROUND(SUM([Feb-2020]) * 0.00001, 2), ROUND(SUM([Mar-2020]) * 0.00001, 2),  
ROUND(SUM([Apr-2020]) * 0.00001, 2), ROUND(SUM([May-2020]) * 0.00001, 2), ROUND(SUM([Jun-2020]) * 0.00001, 2), ROUND(SUM([Jul-2020]) * 0.00001, 2),
ROUND(SUM([Aug-2020]) * 0.00001, 2)
FROM #TransactionFee_Dtls;  
  
INSERT INTO #Revenue_Table1  
SELECT 'Total Hotel Commissions' AS Title, 2,  
[Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
[Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020]
FROM #TDRMARKUP_New  
WHERE  
MasterClientName = 'Total' AND  
MasterClientId = 0 AND  
Flg = 3;  
  
INSERT INTO #Revenue_Table1  
SELECT 'Total', 3,  
SUM([Sep-2019]),  
SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]), SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020])
FROM #Revenue_Table1;  
  
/* TABLE 1 */  
SELECT 'Revenue In Rs (Lakhs)' AS Title;  
SELECT Title,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019]  
FROM #Revenue_Table1  
ORDER BY Flg;  
  
  
CREATE TABLE #RoomNightCount(Title NVARCHAR(100), Flg INT,  
[Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT,  
[Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT,  
[Apr-2020] INT, [May-2020] INT, [Jun-2020] INT, [Jul-2020] INT, [Aug-2020] INT);  
  
INSERT INTO #RoomNightCount  
SELECT 'G H Room Nights', 1,  
[Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
[Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020]
FROM #TDRCatgy  
WHERE PropertyCategory = 'G H';  
  
INSERT INTO #RoomNightCount  
SELECT 'Hotel Room Nights', 2,  
SUM([Sep-2019]),  
SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]), SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020])
FROM #TDRCatgy  
WHERE PropertyCategory IN ('C P P', 'External');  
  
INSERT INTO #RoomNightCount  
SELECT 'Total Room Nights', 3,  
SUM([Sep-2019]),  
SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]), SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020])
FROM #RoomNightCount;  
  
/* TABLE 2 */  
SELECT 'Room Nights' AS Title;  
SELECT Title,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019]
FROM #RoomNightCount  
ORDER BY Flg;  
  
  
CREATE TABLE #BookingCount(Title NVARCHAR(100), Flg INT,   
[Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT,  
[Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT, [Apr-2020] INT, [May-2020] INT, [Jun-2020] INT, [Jul-2020] INT, [Aug-2020] INT);
  
INSERT INTO #BookingCount  
SELECT 'No. of Guest House Bookings', 1,  
SUM([Sep-2019]),  
SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]), SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020])
FROM #Temp_BookingCnt  
WHERE Flg IN (6, 7);/*GH*/  
  
INSERT INTO #BookingCount  
SELECT 'No. Of Hotel Bookings', 2,  
SUM([Sep-2019]),  
SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]), SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020])
FROM #Temp_BookingCnt  
WHERE Flg IN (2, 3);/*EXP & CPP*/  
  
INSERT INTO #BookingCount  
SELECT 'Total Bookings', 3,  
SUM([Sep-2019]),  
SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]), SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020])
FROM #BookingCount;  
  
/* TABLE 3 */  
SELECT 'No. Of Bookings' AS Title;  
SELECT Title,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019]
FROM #BookingCount  
ORDER BY Flg ASC, [Aug-2020] DESC;  
  
/* TABLE 4 */  
SELECT 'Hotel Commissions In Rs (Lakhs)' AS Title;  
SELECT MasterClientName,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019]
FROM #TDRMARKUP_New  
ORDER BY Flg ASC, [Aug-2020] DESC, MasterClientName ASC;  
  
/* Transaction Fee for Guest houses */  
  
CREATE TABLE #TransactionFee_Output(ClientName NVARCHAR(100), Flg INT,  
[Sep-2019] DECIMAL(27, 2),  
[Oct-2019] DECIMAL(27, 2), [Nov-2019] DECIMAL(27, 2), [Dec-2019] DECIMAL(27, 2), [Jan-2020] DECIMAL(27, 2), [Feb-2020] DECIMAL(27, 2), [Mar-2020] DECIMAL(27, 2),  
[Apr-2020] DECIMAL(27, 2), [May-2020] DECIMAL(27, 2), [Jun-2020] DECIMAL(27, 2), [Jul-2020] DECIMAL(27, 2), [Aug-2020] DECIMAL(27, 2));
  
IF EXISTS(SELECT NULL FROM #TransactionFee_Dtls T  
LEFT OUTER JOIN WRBHBMasterClientManagement MC WITH(NOLOCK)ON MC.Id = T.MasterClientId  
WHERE  
T.PropertyCategory = 'G H' AND  
T.MasterClientId IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1))  
BEGIN  
INSERT INTO #TransactionFee_Output  
SELECT MC.ClientName, 1,  
SUM([Sep-2019]),  
SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]), SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020])
FROM #TransactionFee_Dtls T  
LEFT OUTER JOIN WRBHBMasterClientManagement MC WITH(NOLOCK)ON MC.Id = T.MasterClientId  
WHERE  
T.PropertyCategory = 'G H' AND  
T.MasterClientId IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1)  
GROUP BY  
T.MasterClientId, MC.ClientName;  
END  
ELSE  
BEGIN  
INSERT INTO #TransactionFee_Output  
SELECT 'Specific Clients', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;  
END  
  
  
IF EXISTS(SELECT NULL FROM #TransactionFee_Dtls T  
LEFT OUTER JOIN WRBHBMasterClientManagement MC WITH(NOLOCK)ON MC.Id = T.MasterClientId  
WHERE  
T.PropertyCategory = 'G H' AND  
T.MasterClientId NOT IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1))  
BEGIN  
INSERT INTO #TransactionFee_Output  
SELECT 'Other Clients', 2,  
SUM([Sep-2019]),  
SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]), SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020])
FROM #TransactionFee_Dtls  
WHERE  
PropertyCategory = 'G H' AND  
MasterClientId NOT IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1);  
END  
ELSE  
BEGIN  
INSERT INTO #TransactionFee_Output  
SELECT 'Other Clients', 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;  
END  
  
INSERT INTO #TransactionFee_Output  
SELECT 'Total', 3,  
SUM([Sep-2019]),  
SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]), SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020])
FROM #TransactionFee_Dtls  
WHERE  
PropertyCategory = 'G H';  
  
/* Transaction Fee for Guest houses */  
  
/* Transaction Fee For hotels */  
  
IF EXISTS(SELECT NULL FROM #TransactionFee_Dtls T  
LEFT OUTER JOIN WRBHBMasterClientManagement MC WITH(NOLOCK)ON MC.Id = T.MasterClientId  
WHERE  
T.PropertyCategory <> 'G H' AND  
T.MasterClientId IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1))  
BEGIN  
INSERT INTO #TransactionFee_Output  
SELECT MC.ClientName, 4,  
SUM([Sep-2019]),  
SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]), SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020])
FROM #TransactionFee_Dtls T  
LEFT OUTER JOIN WRBHBMasterClientManagement MC WITH(NOLOCK)ON MC.Id = T.MasterClientId  
WHERE  
T.PropertyCategory <> 'G H' AND  
T.MasterClientId IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1)  
GROUP BY  
T.MasterClientId, MC.ClientName;  
END  
ELSE  
BEGIN  
INSERT INTO #TransactionFee_Output  
SELECT 'Specific Clients', 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;  
END  
  
IF EXISTS(SELECT NULL FROM #TransactionFee_Dtls T  
LEFT OUTER JOIN WRBHBMasterClientManagement MC WITH(NOLOCK)ON MC.Id = T.MasterClientId  
WHERE  
T.PropertyCategory <> 'G H' AND  
T.MasterClientId NOT IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1))  
BEGIN  
INSERT INTO #TransactionFee_Output  
SELECT 'Other Clients', 5,  
SUM([Sep-2019]),  
SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]), SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020])
FROM #TransactionFee_Dtls  
WHERE  
PropertyCategory <> 'G H' AND  
MasterClientId NOT IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1);  
END  
ELSE  
BEGIN  
INSERT INTO #TransactionFee_Output  
SELECT 'Other Clients', 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;  
END  
  
INSERT INTO #TransactionFee_Output  
SELECT 'Total', 6,  
SUM([Sep-2019]),  
SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]), SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020])
FROM #TransactionFee_Dtls  
WHERE  
PropertyCategory <> 'G H';  
  
/* Transaction Fee For hotels */  
  
CREATE TABLE #TransactionFee_Output_RoundOff(Title NVARCHAR(100), Flg INT,  
[Sep-2019] DECIMAL(27, 2),  
[Oct-2019] DECIMAL(27, 2), [Nov-2019] DECIMAL(27, 2), [Dec-2019] DECIMAL(27, 2), [Jan-2020] DECIMAL(27, 2), [Feb-2020] DECIMAL(27, 2), [Mar-2020] DECIMAL(27, 2),  
[Apr-2020] DECIMAL(27, 2), [May-2020] DECIMAL(27, 2), [Jun-2020] DECIMAL(27, 2), [Jul-2020] DECIMAL(27, 2), [Aug-2020] DECIMAL(27, 2));
  
INSERT INTO #TransactionFee_Output_RoundOff  
SELECT ClientName, Flg,  
ROUND([Sep-2019] * 0.00001, 2), ROUND([Oct-2019] * 0.00001, 2), ROUND([Nov-2019] * 0.00001, 2),   
ROUND([Dec-2019] * 0.00001, 2), ROUND([Jan-2020] * 0.00001, 2), ROUND([Feb-2020] * 0.00001, 2), ROUND([Mar-2020] * 0.00001, 2),  
ROUND([Apr-2020] * 0.00001, 2), ROUND([May-2020] * 0.00001, 2), ROUND([Jun-2020] * 0.00001, 2), ROUND([Jul-2020] * 0.00001, 2),
ROUND([Aug-2020] * 0.00001, 2)
FROM #TransactionFee_Output;  
  
/* TABLE 5 */  
SELECT 'Transaction Fee for Guesthouses In Rs (Lakhs)' AS Title;  
SELECT Title,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019]
FROM #TransactionFee_Output_RoundOff  
WHERE  
Flg IN (1, 2, 3)  
ORDER BY  
Flg ASC, [Aug-2020] DESC;  
  
/* TABLE 6 */  
SELECT 'Transaction Fee for Hotels In Rs (Lakhs)' AS Title;  
SELECT Title,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019]  
FROM #TransactionFee_Output_RoundOff  
WHERE  
Flg IN (4, 5, 6)  
ORDER BY  
Flg ASC, [Aug-2020] DESC;  
  
/* TABLE 5 + TABLE 6 */  
  
SELECT 'Gross Transaction Fee In Rs (Lakhs)' AS Title,  
SUM([Aug-2020]) AS [Aug-2020],
SUM([Jul-2020]) AS [Jul-2020], SUM([Jun-2020]) AS [Jun-2020], SUM([May-2020]) AS [May-2020], SUM([Apr-2020]) AS [Apr-2020],   
SUM([Mar-2020]) AS [Mar-2020], SUM([Feb-2020]) AS [Feb-2020], SUM([Jan-2020]) AS [Jan-2020], SUM([Dec-2019]) AS [Dec-2019], SUM([Nov-2019]) AS [Nov-2019],  
SUM([Oct-2019]) AS [Oct-2019], SUM([Sep-2019]) AS [Sep-2019]
FROM #TransactionFee_Output_RoundOff  
WHERE  
Flg IN (3, 6);  
  
/* TABLE 7 */  
SELECT 'Hotel Room Nights' AS Title;  
SELECT MasterClientName,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019]  
FROM #TDRClient T  
ORDER BY Flg ASC, [Aug-2020] DESC;  
  
CREATE TABLE #Booking_Count(Title NVARCHAR(100), Flg INT, Id INT IDENTITY(1, 1),   
[Sep-2019] INT,  
[Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT, [Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT,  
[Apr-2020] INT, [May-2020] INT, [Jun-2020] INT, [Jul-2020] INT, [Aug-2020] INT);  
  
/*Flg IN (6, 7) - GH */  
  
INSERT INTO #Booking_Count  
SELECT MasterClientName, 1,  
[Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020],  
[Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020]  
FROM #Temp_BookingCnt  
WHERE Flg IN (6, 7)  
ORDER BY Flg, Id;  
  
INSERT INTO #Booking_Count  
SELECT 'Total', 2,  
SUM([Sep-2019]),  
SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]), SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020])
FROM #Temp_BookingCnt  
WHERE Flg IN (6, 7);  
  
/*Flg IN (2, 3) - EXP & CPP */  
  
INSERT INTO #Booking_Count  
SELECT MasterClientName, 3,  
[Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020], [Apr-2020], [May-2020], [Jun-2020], [Jul-2020], [Aug-2020]
FROM #Temp_BookingCnt  
WHERE Flg IN (2, 3)  
ORDER BY Flg, Id;  
  
INSERT INTO #Booking_Count  
SELECT 'Total', 4,  
SUM([Sep-2019]),  
SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]), SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020])
FROM #Temp_BookingCnt  
WHERE Flg IN (2, 3);  
  
/* TABLE 8 */  
SELECT 'No. of GH Bookings' AS Title;  
SELECT Title,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019]  
FROM #Booking_Count  
WHERE Flg IN (1, 2)  
ORDER BY Id;  
  
/* TABLE 9 */  
SELECT 'No. of Hotel Booking' AS Title;  
SELECT Title,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019]  
FROM #Booking_Count  
WHERE Flg IN (3, 4)  
ORDER BY Flg, Id;  
  
/* Revnue Report - #End */  
  
/* Hotel Details Report - #Start */  
  
SELECT '' AS C99,
'Aug-20' AS C06, 'Jul-20' AS C05, 'Jun-20' AS C16, 'May-20' AS C15, 'Apr-20' AS C14,  
'Mar-20' AS C13, 'Feb-20' AS C12, 'Jan-20' AS C11, 'Dec-19' AS C10, 'Nov-19' AS C09, 'Oct-19' AS C08,  
'Sep-19' AS C07;  
  
/* TABLE 1 */  
SELECT 'GTV In Rs (Lakhs)' AS Title;  
SELECT 'Chain Hotels' AS Title,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019]  
FROM #TEMPMONTH117  
WHERE Flg = 2  
UNION ALL  
SELECT 'Non Chain Hotels' AS Title,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019]  
FROM #TEMPMONTH117  
WHERE Flg = 5  
UNION ALL  
SELECT 'Total' AS Title,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019]  
FROM #TEMPMONTH117  
WHERE Flg = 1;  
  
/* TABLE 2 */  
SELECT 'HB - Revenue In Rs (Lakhs)' AS Title;  
SELECT PropertyCategory,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019]  
FROM #TDRMARKUP_Category_New  
ORDER BY Flg;  
  
/* TABLE 3 */  
SELECT 'Hotel Room Nights' AS Title;  
SELECT PropertyCategory,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019]  
FROM #TDRCatgy  
WHERE PropertyCategory = 'C P P'  
UNION ALL  
SELECT PropertyCategory,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019]  
FROM #TDRCatgy  
WHERE PropertyCategory = 'G H'  
UNION ALL  
SELECT 'External',  
SUM([Aug-2020]) AS [Aug-2020], SUM([Jul-2020]) AS [Jul-2020], SUM([Jun-2020]) AS [Jun-2020], SUM([May-2020]) AS [May-2020], SUM([Apr-2020]) AS [Apr-2020],  
SUM([Mar-2020]) AS [Mar-2020], SUM([Feb-2020]) AS [Feb-2020], SUM([Jan-2020]) AS [Jan-2020], SUM([Dec-2019]) AS [Dec-2019], SUM([Nov-2019]) AS [Nov-2019],  
SUM([Oct-2019]) AS [Oct-2019], SUM([Sep-2019]) AS [Sep-2019]  
FROM #TDRCatgy  
WHERE PropertyCategory IN ('B O K', 'O Y O', 'External')  
UNION ALL  
SELECT 'Total',  
SUM([Aug-2020]) AS [Aug-2020],
SUM([Jul-2020]) AS [Jul-2020], SUM([Jun-2020]) AS [Jun-2020], SUM([May-2020]) AS [May-2020], SUM([Apr-2020]) AS [Apr-2020],  
SUM([Mar-2020]) AS [Mar-2020], SUM([Feb-2020]) AS [Feb-2020], SUM([Jan-2020]) AS [Jan-2020], SUM([Dec-2019]) AS [Dec-2019], SUM([Nov-2019]) AS [Nov-2019],  
SUM([Oct-2019]) AS [Oct-2019], SUM([Sep-2019]) AS [Sep-2019]
FROM #TDRCatgy  
WHERE PropertyCategory IN ('C P P', 'B O K', 'O Y O', 'External', 'G H');  
  
CREATE TABLE #WithCommission_ClientWise(MasterClientId BIGINT, MasterClientName VARCHAR(100), Id INT IDENTITY(1, 1), Flg INT,  
[Sep-2019] DECIMAL(27, 2),  
[Oct-2019] DECIMAL(27, 2), [Nov-2019] DECIMAL(27, 2), [Dec-2019] DECIMAL(27, 2), [Jan-2020] DECIMAL(27, 2), [Feb-2020] DECIMAL(27, 2), [Mar-2020] DECIMAL(27, 2),  
[Apr-2020] DECIMAL(27, 2), [May-2020] DECIMAL(27, 2), [Jun-2020] DECIMAL(27, 2), [Jul-2020] DECIMAL(27, 2), [Aug-2020] DECIMAL(27, 2));
  
INSERT INTO #WithCommission_ClientWise  
SELECT T.MasterClientId, M.ClientName, 2,  
SUM([Sep-2019]),  
SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]), SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020])  
FROM  
#TEMPMONTH16 T  
LEFT OUTER JOIN WRBHBMasterClientManagement M WITH(NOLOCK)ON T.MasterClientId = M.Id  
WHERE  
Markup <> 0 AND  
T.MasterClientId IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1)  
GROUP BY  
T.MasterClientId, M.ClientName  
ORDER BY  
SUM([Aug-2020]) DESC;  
  
INSERT INTO #WithCommission_ClientWise  
SELECT 0, 'Other Clients', 3,  
SUM([Sep-2019]),  
SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]), SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020])  
FROM  
#TEMPMONTH16 T  
LEFT OUTER JOIN WRBHBMasterClientManagement M WITH(NOLOCK)ON T.MasterClientId = M.Id  
WHERE  
Markup <> 0 AND  
T.MasterClientId NOT IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1);  
  
  
CREATE TABLE #GTV_MasterClientWise(MasterClientId BIGINT, MasterClientName VARCHAR(100), Id INT IDENTITY(1, 1), Flg INT,  
[Sep-2019] DECIMAL(27, 2),  
[Oct-2019] DECIMAL(27, 2), [Nov-2019] DECIMAL(27, 2), [Dec-2019] DECIMAL(27, 2), [Jan-2020] DECIMAL(27, 2), [Feb-2020] DECIMAL(27, 2), [Mar-2020] DECIMAL(27, 2),  
[Apr-2020] DECIMAL(27, 2), [May-2020] DECIMAL(27, 2), [Jun-2020] DECIMAL(27, 2), [Jul-2020] DECIMAL(27, 2), [Aug-2020] DECIMAL(27, 2));
  
INSERT INTO #GTV_MasterClientWise  
SELECT T.MasterClientId, M.ClientName, 1,  
SUM([Sep-2019]),  
SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]), SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020])
FROM #TEMPMONTH16 T  
LEFT OUTER JOIN WRBHBMasterClientManagement M ON T.MasterClientId = M.Id  
WHERE  
T.MasterClientId IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1)  
GROUP BY  
M.ClientName, T.MasterClientId;  
  
INSERT INTO #GTV_MasterClientWise  
SELECT 0, 'Other Clients', 2,  
SUM([Sep-2019]),  
SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]), SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020]),  
SUM([Apr-2020]), SUM([May-2020]), SUM([Jun-2020]), SUM([Jul-2020]), SUM([Aug-2020])
FROM #TEMPMONTH16 T  
LEFT OUTER JOIN WRBHBMasterClientManagement M ON T.MasterClientId = M.Id  
WHERE  
T.MasterClientId NOT IN (SELECT MasterClientId FROM HBAnalysis_ClientList WHERE Active = 1);  
  
/* TABLE 4 */  
SELECT 'Hotels Giving Commissions Percentage' AS Title;  
SELECT T1.MasterClientName,
CASE WHEN T1.[Aug-2020] <> 0 THEN CAST(CAST(ROUND(((T1.[Aug-2020] * 10000) / T2.[Aug-2020]) * 0.01, 0) AS INT) AS VARCHAR) + '%' ELSE '0%' END AS [Aug-2020],
CASE WHEN T1.[Jul-2020] <> 0 THEN CAST(CAST(ROUND(((T1.[Jul-2020] * 10000) / T2.[Jul-2020]) * 0.01, 0) AS INT) AS VARCHAR) + '%' ELSE '0%' END AS [Jul-2020],  
CASE WHEN T1.[Jun-2020] <> 0 THEN CAST(CAST(ROUND(((T1.[Jun-2020] * 10000) / T2.[Jun-2020]) * 0.01, 0) AS INT) AS VARCHAR) + '%' ELSE '0%' END AS [Jun-2020],  
CASE WHEN T1.[May-2020] <> 0 THEN CAST(CAST(ROUND(((T1.[May-2020] * 10000) / T2.[May-2020]) * 0.01, 0) AS INT) AS VARCHAR) + '%' ELSE '0%' END AS [May-2020],  
CASE WHEN T1.[Apr-2020] <> 0 THEN CAST(CAST(ROUND(((T1.[Apr-2020] * 10000) / T2.[Apr-2020]) * 0.01, 0) AS INT) AS VARCHAR) + '%' ELSE '0%' END AS [Apr-2020],  
CASE WHEN T1.[Mar-2020] <> 0 THEN CAST(CAST(ROUND(((T1.[Mar-2020] * 10000) / T2.[Mar-2020]) * 0.01, 0) AS INT) AS VARCHAR) + '%' ELSE '0%' END AS [Mar-2020],  
CASE WHEN T1.[Feb-2020] <> 0 THEN CAST(CAST(ROUND(((T1.[Feb-2020] * 10000) / T2.[Feb-2020]) * 0.01, 0) AS INT) AS VARCHAR) + '%' ELSE '0%' END AS [Feb-2020],  
CASE WHEN T1.[Jan-2020] <> 0 THEN CAST(CAST(ROUND(((T1.[Jan-2020] * 10000) / T2.[Jan-2020]) * 0.01, 0) AS INT) AS VARCHAR) + '%' ELSE '0%' END AS [Jan-2020],  
CASE WHEN T1.[Dec-2019] <> 0 THEN CAST(CAST(ROUND(((T1.[Dec-2019] * 10000) / T2.[Dec-2019]) * 0.01, 0) AS INT) AS VARCHAR) + '%' ELSE '0%' END AS [Dec-2019],  
CASE WHEN T1.[Nov-2019] <> 0 THEN CAST(CAST(ROUND(((T1.[Nov-2019] * 10000) / T2.[Nov-2019]) * 0.01, 0) AS INT) AS VARCHAR) + '%' ELSE '0%' END AS [Nov-2019],  
CASE WHEN T1.[Oct-2019] <> 0 THEN CAST(CAST(ROUND(((T1.[Oct-2019] * 10000) / T2.[Oct-2019]) * 0.01, 0) AS INT) AS VARCHAR) + '%' ELSE '0%' END AS [Oct-2019],  
CASE WHEN T1.[Sep-2019] <> 0 THEN CAST(CAST(ROUND(((T1.[Sep-2019] * 10000) / T2.[Sep-2019]) * 0.01, 0) AS INT) AS VARCHAR) + '%' ELSE '0%' END AS [Sep-2019]
FROM #WithCommission_ClientWise T1  
LEFT OUTER JOIN #GTV_MasterClientWise T2 WITH(NOLOCK)ON T1.MasterClientId = T2.MasterClientId  
ORDER BY  
T1.Flg, T1.Id;  
  
/* TABLE 5 */  
SELECT 'GTV with Margin In Rs (Lakhs)' AS Title;  
SELECT MasterClientName,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019]  
FROM #GTVTOTALCLIENT  
WHERE MarkupFlg IN (1, 2, 3)  
ORDER BY MarkupFlg ASC, [Aug-2020] DESC;  
  
/* TABLE 6 */  
SELECT 'GTV without Margin In Rs (Lakhs)' AS Title;  
SELECT MasterClientName,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019]  
FROM #GTVTOTALCLIENT  
WHERE MarkupFlg IN (4, 5, 6)  
ORDER BY MarkupFlg ASC, [Aug-2020] DESC;  
  
/* TABLE 7 */  
SELECT MasterClientName,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019]  
FROM #GTVTOTALCLIENT  
WHERE MarkupFlg = 7;  
  
/* TABLE 8 */  
SELECT 'Chain Hotels - Room Nights' AS Title;  
SELECT MasterPropertyName,  
[Aug-2020], [Jul-2020], [Jun-2020], [May-2020], [Apr-2020],  
[Mar-2020], [Feb-2020], [Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019]  
FROM #TDR T  
ORDER BY Flg ASC, [Aug-2020] DESC;  
  
  
/* Hotel Details Report - #End */  
  
  
END  
END