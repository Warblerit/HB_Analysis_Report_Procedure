-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[SP_HBAnalysis_Jan2020_PayMode_Splitup]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
DROP PROCEDURE [dbo].[SP_HBAnalysis_Jan2020_PayMode_Splitup]
GO 
CREATE PROCEDURE [dbo].[SP_HBAnalysis_Jan2020_PayMode_Splitup](@Action NVARCHAR(100),@Str NVARCHAR(100),@Id BIGINT)
/*
Exec [dbo].[SP_HBAnalysis_Jan2020_PayMode_Splitup] @Action = '',@Str = '',@Id = 0;
*/
AS
BEGIN
SET NOCOUNT ON
SET ANSI_WARNINGS OFF
IF @Action = ''
BEGIN

CREATE TABLE #TEMP1(BookingCode BIGINT,CheckInDt DATE,CheckOutDt DATE,Tariff DECIMAL(27,2),MarkUp DECIMAL(27,2),PropertyId BIGINT,MasterPropertyId BIGINT,
RoomCaptured BIGINT,BookingId BIGINT,CityId BIGINT,PropertyCategory NVARCHAR(100),ClientId BIGINT,MasterClientId BIGINT,BookedDt VARCHAR(100),
TariffPaymentMode NVARCHAR(100));
INSERT INTO #TEMP1
SELECT S.BookingCode,S.CheckInDt,S.CheckOutDt,SUM(S.Tariff),SUM(S.MarkUp),S.PropertyId,S.MasterPropertyId,RoomCaptured,S.BookingId,S.CityId,S.PropertyCategory,S.ClientId,
C.MasterClientId, SUBSTRING(DATENAME(MONTH, S.BookingDate), 1, 3) + '-' + CAST(YEAR(S.BookingDate) AS VARCHAR), S.TariffPaymentMode
FROM WRBHBBookingStatus S
LEFT OUTER JOIN WRBHBClientManagement C WITH(NOLOCK)ON C.Id = S.ClientId
WHERE
S.Status != 'Canceled' AND S.PropertyCategory = 'External'
GROUP BY S.BookingCode,S.CheckInDt,S.CheckOutDt,S.Tariff,S.MarkUp,S.PropertyId,S.MasterPropertyId,RoomCaptured,S.BookingId,S.CityId,S.PropertyCategory,S.ClientId,
C.MasterClientId, S.BookingDate, S.TariffPaymentMode;

CREATE TABLE #TEMP2(BookingCode BIGINT,CalendarDate DATE,CheckInDt DATE,CheckOutDt DATE,Tariff DECIMAL(27,2),MarkUp DECIMAL(27,2),PropertyId BIGINT,
MasterPropertyId BIGINT,RoomCaptured BIGINT,BookingId BIGINT,CityId BIGINT,PropertyCategory NVARCHAR(100),ClientId BIGINT,asasd nvarchar(100),MasterClientId BIGINT,
TariffPaymentMode NVARCHAR(100));
INSERT INTO #TEMP2
SELECT S.BookingCode, C.calendarDate, S.CheckInDt, S.CheckOutDt, S.Tariff, ROUND(S.MarkUp / DATEDIFF(DAY,S.CheckInDt,S.CheckOutDt),0), S.PropertyId, S.MasterPropertyId,
S.RoomCaptured, S.BookingId, S.CityId, S.PropertyCategory, S.ClientId, SUBSTRING(DATENAME(MONTH,C.CalendarDate),1,3) + '-' + CAST(YEAR(C.CalendarDate) AS VARCHAR),
S.MasterClientId, S.TariffPaymentMode 
FROM #TEMP1 S
LEFT OUTER JOIN calendar.main C WITH(NOLOCK)ON C.calendarYear != 0
WHERE S.CheckInDt != S.CheckOutDt AND C.calendarDate BETWEEN S.CheckInDt AND DATEADD(DAY, -1, S.CheckOutDt);

INSERT INTO #TEMP2
SELECT S.BookingCode,S.CheckInDt,S.CheckInDt,S.CheckOutDt,S.Tariff,ROUND(S.MarkUp,0),S.PropertyId,S.MasterPropertyId,RoomCaptured,S.BookingId,S.CityId,S.PropertyCategory,
S.ClientId,SUBSTRING(DATENAME(MONTH,S.CheckInDt),1,3)+'-'+CAST(YEAR(S.CheckInDt) AS VARCHAR),S.MasterClientId,S.TariffPaymentMode FROM #TEMP1 S
WHERE S.CheckInDt = S.CheckOutDt;

DELETE #TEMP2 WHERE asasd NOT IN ('Apr-2018', 'May-2018', 'Jun-2018', 'Jul-2018', 'Aug-2018', 'Sep-2018', 'Oct-2018', 'Nov-2018', 'Dec-2018', 'Jan-2019', 'Feb-2019', 'Mar-2019',
'Apr-2019', 'May-2019', 'Jun-2019', 'Jul-2019', 'Aug-2019', 'Sep-2019', 'Oct-2019', 'Nov-2019', 'Dec-2019', 'Jan-2020');

/* ----- Daily Tracking Report Start ----- */

CREATE TABLE #dsadasd(MasterPropertyId BIGINT, PropertyCategory NVARCHAR(100), cnt INT, MonthofBooking NVARCHAR(100), Tariff DECIMAL(27,2),MarkUp DECIMAL(27,2),
MasterClientId BIGINT,TariffPaymentMode NVARCHAR(100));
INSERT INTO #dsadasd(MasterPropertyId,PropertyCategory,cnt,MonthofBooking,Tariff,MarkUp,MasterClientId,TariffPaymentMode)
SELECT MasterPropertyId,PropertyCategory,COUNT(CalendarDate),asasd,SUM(Tariff),SUM(MarkUp),MasterClientId,TariffPaymentMode FROM #TEMP2 
GROUP BY MasterPropertyId,PropertyCategory,asasd,MasterClientId,TariffPaymentMode;

SELECT   MasterPropertyId,PropertyCategory,MasterClientId,TariffPaymentMode,
		 [Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019],
		 [Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020]
INTO #output
FROM #dsadasd
PIVOT
(
       SUM(Cnt)
       FOR MonthofBooking IN 
	   ([Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019],
	    [Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020])
) AS P;

CREATE TABLE #TEMPDAILYREPORTCOUNT(MasterPropertyId BIGINT,PropertyCategory NVARCHAR(100),MasterClientId BIGINT,TariffPaymentMode NVARCHAR(100),
[Apr-2018] INT, [May-2018] INT, [Jun-2018] INT, [Jul-2018] INT, [Aug-2018] INT, [Sep-2018] INT, [Oct-2018] INT, [Nov-2018] INT, [Dec-2018] INT,
[Jan-2019] INT, [Feb-2019] INT, [Mar-2019] INT,
[Apr-2019] INT, [May-2019] INT, [Jun-2019] INT, [Jul-2019] INT, [Aug-2019] INT, [Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT,
[Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT);

INSERT INTO #TEMPDAILYREPORTCOUNT
SELECT MasterPropertyId,PropertyCategory,MasterClientId,TariffPaymentMode,
ISNULL([Apr-2018], 0), ISNULL([May-2018], 0), ISNULL([Jun-2018], 0), ISNULL([Jul-2018], 0), ISNULL([Aug-2018], 0), ISNULL([Sep-2018], 0), ISNULL([Oct-2018], 0), 
ISNULL([Nov-2018], 0), ISNULL([Dec-2018], 0), ISNULL([Jan-2019], 0), ISNULL([Feb-2019], 0), ISNULL([Mar-2019], 0),
ISNULL([Apr-2019], 0), ISNULL([May-2019], 0), ISNULL([Jun-2019], 0), ISNULL([Jul-2019], 0), ISNULL([Aug-2019], 0), ISNULL([Sep-2019], 0), ISNULL([Oct-2019], 0), 
ISNULL([Nov-2019], 0), ISNULL([Dec-2019], 0), ISNULL([Jan-2020], 0), ISNULL([Feb-2020], 0), ISNULL([Mar-2020], 0)
FROM #output;

/* Room Nights TariffPaymentMode */

CREATE TABLE #TDRCatgy(TariffPaymentMode NVARCHAR(100),Flg INT, 
[Apr-2018] INT, [May-2018] INT, [Jun-2018] INT, [Jul-2018] INT, [Aug-2018] INT, [Sep-2018] INT, [Oct-2018] INT, [Nov-2018] INT, [Dec-2018] INT,
[Jan-2019] INT, [Feb-2019] INT, [Mar-2019] INT,
[Apr-2019] INT, [May-2019] INT, [Jun-2019] INT, [Jul-2019] INT, [Aug-2019] INT, [Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT,
[Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT);

INSERT INTO #TDRCatgy
SELECT TariffPaymentMode,1,
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019]),
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]), 
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020])
FROM #TEMPDAILYREPORTCOUNT
GROUP BY TariffPaymentMode;

INSERT INTO #TDRCatgy
SELECT 'Total', 2,
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019]),
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]), 
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020])
FROM #TDRCatgy;


/* MARKUP */

CREATE TABLE #dsadasd1(PropertyCategory NVARCHAR(100),cnt INT,MonthofBooking NVARCHAR(100),Tariff DECIMAL(27,2),MarkUp DECIMAL(27,2),MasterClientId BIGINT,
TariffPaymentMode nvarchar(100));
INSERT INTO #dsadasd1(PropertyCategory,cnt,MonthofBooking,Tariff,MarkUp,MasterClientId,TariffPaymentMode)
SELECT PropertyCategory,COUNT(CalendarDate),asasd,SUM(Tariff),SUM(MarkUp),MasterClientId, TariffPaymentMode FROM #TEMP2
GROUP BY PropertyCategory,asasd,MasterClientId,TariffPaymentMode;

SELECT   PropertyCategory,MasterClientId,TariffPaymentMode,
		 [Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019],
		 [Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020]
INTO #output1
FROM #dsadasd1
PIVOT
(
       SUM(MarkUp)
       FOR MonthofBooking IN 
	   ([Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019],
	    [Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020])
) AS P1;

CREATE TABLE #TEMPMARKUP(PropertyCategory NVARCHAR(100),MasterClientId BIGINT,TariffPaymentMode nvarchar(100),
[Apr-2018] INT, [May-2018] INT, [Jun-2018] INT, [Jul-2018] INT, [Aug-2018] INT, [Sep-2018] INT, [Oct-2018] INT, [Nov-2018] INT, [Dec-2018] INT,
[Jan-2019] INT, [Feb-2019] INT, [Mar-2019] INT,
[Apr-2019] INT, [May-2019] INT, [Jun-2019] INT, [Jul-2019] INT, [Aug-2019] INT, [Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT,
[Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT);

INSERT INTO #TEMPMARKUP
SELECT PropertyCategory,MasterClientId,TariffPaymentMode,
ISNULL([Apr-2018], 0), ISNULL([May-2018], 0), ISNULL([Jun-2018], 0), ISNULL([Jul-2018], 0), ISNULL([Aug-2018], 0), ISNULL([Sep-2018], 0), ISNULL([Oct-2018], 0),
ISNULL([Nov-2018], 0), ISNULL([Dec-2018], 0), ISNULL([Jan-2019], 0), ISNULL([Feb-2019], 0), ISNULL([Mar-2019], 0),
ISNULL([Apr-2019], 0), ISNULL([May-2019], 0), ISNULL([Jun-2019], 0), ISNULL([Jul-2019], 0), ISNULL([Aug-2019], 0), ISNULL([Sep-2019], 0), ISNULL([Oct-2019], 0),
ISNULL([Nov-2019], 0), ISNULL([Dec-2019], 0), ISNULL([Jan-2020], 0), ISNULL([Feb-2020], 0), ISNULL([Mar-2020], 0)
FROM
#output1;

/* -- MARGIN FOR EXP & CPP */

CREATE TABLE #TDRMARKUP_Category(TariffPaymentMode NVARCHAR(100),
[Apr-2018] INT, [May-2018] INT, [Jun-2018] INT, [Jul-2018] INT, [Aug-2018] INT, [Sep-2018] INT, [Oct-2018] INT, [Nov-2018] INT, [Dec-2018] INT,
[Jan-2019] INT, [Feb-2019] INT, [Mar-2019] INT,
[Apr-2019] INT, [May-2019] INT, [Jun-2019] INT, [Jul-2019] INT, [Aug-2019] INT, [Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT,
[Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT);

INSERT INTO #TDRMARKUP_Category
SELECT TariffPaymentMode,
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019]),
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]), 
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020])
FROM
#TEMPMARKUP
GROUP BY TariffPaymentMode;

CREATE TABLE #TDRMARKUP_Category_New(TariffPaymentMode NVARCHAR(100), Flg INT,
[Apr-2018] DECIMAL(27,2), [May-2018] DECIMAL(27,2), [Jun-2018] DECIMAL(27,2), [Jul-2018] DECIMAL(27,2), [Aug-2018] DECIMAL(27,2), [Sep-2018] DECIMAL(27,2), 
[Oct-2018] DECIMAL(27,2), [Nov-2018] DECIMAL(27,2), [Dec-2018] DECIMAL(27,2), [Jan-2019] DECIMAL(27,2), [Feb-2019] DECIMAL(27,2), [Mar-2019] DECIMAL(27,2),
[Apr-2019] DECIMAL(27,2), [May-2019] DECIMAL(27,2), [Jun-2019] DECIMAL(27,2), [Jul-2019] DECIMAL(27,2), [Aug-2019] DECIMAL(27,2), [Sep-2019] DECIMAL(27, 2),
[Oct-2019] DECIMAL(27,2), [Nov-2019] DECIMAL(27,2), [Dec-2019] DECIMAL(27,2), [Jan-2020] DECIMAL(27,2), [Feb-2020] DECIMAL(27,2), [Mar-2020] DECIMAL(27,2));

INSERT INTO #TDRMARKUP_Category_New
SELECT TariffPaymentMode, 1,
ROUND([Apr-2018] * 0.00001, 2), ROUND([May-2018] * 0.00001, 2), ROUND([Jun-2018] * 0.00001, 2), ROUND([Jul-2018] * 0.00001, 2), ROUND([Aug-2018] * 0.00001, 2),
ROUND([Sep-2018] * 0.00001, 2), ROUND([Oct-2018] * 0.00001, 2), ROUND([Nov-2018] * 0.00001, 2), ROUND([Dec-2018] * 0.00001, 2), ROUND([Jan-2019] * 0.00001, 2),
ROUND([Feb-2019] * 0.00001, 2), ROUND([Mar-2019] * 0.00001, 2),
ROUND([Apr-2019] * 0.00001, 2), ROUND([May-2019] * 0.00001, 2), ROUND([Jun-2019] * 0.00001, 2), ROUND([Jul-2019] * 0.00001, 2), ROUND([Aug-2019] * 0.00001, 2),
ROUND([Sep-2019] * 0.00001, 2), ROUND([Oct-2019] * 0.00001, 2), ROUND([Nov-2019] * 0.00001, 2), ROUND([Dec-2019] * 0.00001, 2), ROUND([Jan-2020] * 0.00001, 2),
ROUND([Feb-2020] * 0.00001, 2), ROUND([Mar-2020] * 0.00001, 2)
FROM #TDRMARKUP_Category;

INSERT INTO #TDRMARKUP_Category_New
SELECT 'Total', 2,
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019]),
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]), 
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020])
FROM #TDRMARKUP_Category_New;


/* -- GTV WITH MARKUP */

CREATE TABLE #dsadasd3(PropertyCategory NVARCHAR(100),MonthofBooking NVARCHAR(100),Tariff DECIMAL(27,2),MasterClientId BIGINT,TariffPaymentMode nvarchar(100));
INSERT INTO #dsadasd3(PropertyCategory,MonthofBooking,Tariff,MasterClientId,TariffPaymentMode)
SELECT PropertyCategory,asasd,SUM(Tariff),MasterClientId,TariffPaymentMode FROM #TEMP2
WHERE MarkUp != 0
GROUP BY PropertyCategory,asasd,MasterClientId,TariffPaymentMode;

SELECT   PropertyCategory,MasterClientId,TariffPaymentMode,
         [Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019],
		 [Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020]
INTO #output3
FROM #dsadasd3
PIVOT
(
       SUM(Tariff)
       FOR MonthofBooking IN 
	   ([Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019],
	    [Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020])
) AS P2;

CREATE TABLE #TEMPGTVwithMARKUP(PropertyCategory NVARCHAR(100),MasterClientId BIGINT,TariffPaymentMode nvarchar(100),
[Apr-2018] INT, [May-2018] INT, [Jun-2018] INT, [Jul-2018] INT, [Aug-2018] INT, [Sep-2018] INT, [Oct-2018] INT, [Nov-2018] INT, [Dec-2018] INT,
[Jan-2019] INT, [Feb-2019] INT, [Mar-2019] INT,
[Apr-2019] INT, [May-2019] INT, [Jun-2019] INT, [Jul-2019] INT, [Aug-2019] INT, [Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT,
[Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT);

INSERT INTO #TEMPGTVwithMARKUP
SELECT PropertyCategory,MasterClientId,TariffPaymentMode,
ISNULL([Apr-2018], 0), ISNULL([May-2018], 0), ISNULL([Jun-2018], 0), ISNULL([Jul-2018], 0), ISNULL([Aug-2018], 0), ISNULL([Sep-2018], 0), ISNULL([Oct-2018], 0), 
ISNULL([Nov-2018], 0), ISNULL([Dec-2018], 0), ISNULL([Jan-2019], 0), ISNULL([Feb-2019], 0), ISNULL([Mar-2019], 0),
ISNULL([Apr-2019], 0), ISNULL([May-2019], 0), ISNULL([Jun-2019], 0), ISNULL([Jul-2019], 0), ISNULL([Aug-2019], 0), ISNULL([Sep-2019], 0), ISNULL([Oct-2019], 0), 
ISNULL([Nov-2019], 0), ISNULL([Dec-2019], 0), ISNULL([Jan-2020], 0), ISNULL([Feb-2020], 0), ISNULL([Mar-2020], 0)
FROM
#output3;

/* -- WISE GTV */

CREATE TABLE #GTVTOTAL(TariffPaymentMode NVARCHAR(100), MarkupFlg INT,
[Apr-2018] DECIMAL(27,2), [May-2018] DECIMAL(27,2), [Jun-2018] DECIMAL(27,2), [Jul-2018] DECIMAL(27,2), [Aug-2018] DECIMAL(27,2), [Sep-2018] DECIMAL(27,2), 
[Oct-2018] DECIMAL(27,2), [Nov-2018] DECIMAL(27,2), [Dec-2018] DECIMAL(27,2), [Jan-2019] DECIMAL(27,2), [Feb-2019] DECIMAL(27,2), [Mar-2019] DECIMAL(27,2),
[Apr-2019] DECIMAL(27,2), [May-2019] DECIMAL(27,2), [Jun-2019] DECIMAL(27,2), [Jul-2019] DECIMAL(27,2), [Aug-2019] DECIMAL(27,2), [Sep-2019] DECIMAL(27,2),
[Oct-2019] DECIMAL(27,2), [Nov-2019] DECIMAL(27,2), [Dec-2019] DECIMAL(27,2), [Jan-2020] DECIMAL(27,2), [Feb-2020] DECIMAL(27,2), [Mar-2020] DECIMAL(27,2));

INSERT INTO #GTVTOTAL
SELECT TariffPaymentMode, 1, 
ROUND(SUM([Apr-2018]) * 0.00001, 2), ROUND(SUM([May-2018]) * 0.00001, 2), ROUND(SUM([Jun-2018]) * 0.00001, 2), ROUND(SUM([Jul-2018]) * 0.00001, 2), 
ROUND(SUM([Aug-2018]) * 0.00001, 2), ROUND(SUM([Sep-2018]) * 0.00001, 2), ROUND(SUM([Oct-2018]) * 0.00001, 2), ROUND(SUM([Nov-2018]) * 0.00001, 2), 
ROUND(SUM([Dec-2018]) * 0.00001, 2), ROUND(SUM([Jan-2019]) * 0.00001, 2), ROUND(SUM([Feb-2019]) * 0.00001, 2), ROUND(SUM([Mar-2019]) * 0.00001, 2),
ROUND(SUM([Apr-2019]) * 0.00001, 2), ROUND(SUM([May-2019]) * 0.00001, 2), ROUND(SUM([Jun-2019]) * 0.00001, 2), ROUND(SUM([Jul-2019]) * 0.00001, 2),
ROUND(SUM([Aug-2019]) * 0.00001, 2), ROUND(SUM([Sep-2019]) * 0.00001, 2), ROUND(SUM([Oct-2019]) * 0.00001, 2), ROUND(SUM([Nov-2019]) * 0.00001, 2), 
ROUND(SUM([Dec-2019]) * 0.00001, 2), ROUND(SUM([Jan-2020]) * 0.00001, 2), ROUND(SUM([Feb-2020]) * 0.00001, 2), ROUND(SUM([Mar-2020]) * 0.00001, 2)
FROM #TEMPGTVwithMARKUP
GROUP BY TariffPaymentMode
ORDER BY TariffPaymentMode;

INSERT INTO #GTVTOTAL
SELECT 'GTV with Margin Total', 2, 
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019]),
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]), 
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020])
FROM #GTVTOTAL;

/* -- GTV WITHOUT MARKUP */

CREATE TABLE #dsadasd2(PropertyCategory NVARCHAR(100),MonthofBooking NVARCHAR(100),Tariff DECIMAL(27,2),MasterClientId BIGINT,TariffPaymentMode nvarchar(100));
INSERT INTO #dsadasd2(PropertyCategory,MonthofBooking,Tariff,MasterClientId,TariffPaymentMode)
SELECT PropertyCategory,asasd,SUM(Tariff),MasterClientId,TariffPaymentMode FROM #TEMP2
WHERE  MarkUp = 0
GROUP BY PropertyCategory,asasd,MasterClientId,TariffPaymentMode;

SELECT   PropertyCategory,MasterClientId,TariffPaymentMode,
         [Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019],
		 [Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020]
INTO #output2
FROM #dsadasd2
PIVOT
(
       SUM(Tariff)
       FOR MonthofBooking IN 
	   ([Apr-2018], [May-2018], [Jun-2018], [Jul-2018], [Aug-2018], [Sep-2018], [Oct-2018], [Nov-2018], [Dec-2018], [Jan-2019], [Feb-2019], [Mar-2019],
	    [Apr-2019], [May-2019], [Jun-2019], [Jul-2019], [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020], [Feb-2020], [Mar-2020])
) AS P2;

CREATE TABLE #TEMPGTVwithoutMARKUP(PropertyCategory NVARCHAR(100),MasterClientId BIGINT,TariffPaymentMode nvarchar(100),
[Apr-2018] INT, [May-2018] INT, [Jun-2018] INT, [Jul-2018] INT, [Aug-2018] INT, [Sep-2018] INT, [Oct-2018] INT, [Nov-2018] INT, [Dec-2018] INT,
[Jan-2019] INT, [Feb-2019] INT, [Mar-2019] INT,
[Apr-2019] INT, [May-2019] INT, [Jun-2019] INT, [Jul-2019] INT, [Aug-2019] INT, [Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT,
[Jan-2020] INT, [Feb-2020] INT, [Mar-2020] INT);

INSERT INTO #TEMPGTVwithoutMARKUP
SELECT PropertyCategory,MasterClientId,TariffPaymentMode,
ISNULL([Apr-2018],0), ISNULL([May-2018],0), ISNULL([Jun-2018],0), ISNULL([Jul-2018],0), ISNULL([Aug-2018],0), ISNULL([Sep-2018],0), ISNULL([Oct-2018],0), 
ISNULL([Nov-2018],0), ISNULL([Dec-2018],0), ISNULL([Jan-2019],0), ISNULL([Feb-2019],0), ISNULL([Mar-2019],0),
ISNULL([Apr-2019],0), ISNULL([May-2019],0), ISNULL([Jun-2019],0), ISNULL([Jul-2019],0), ISNULL([Aug-2019],0), ISNULL([Sep-2019],0), ISNULL([Oct-2019],0), 
ISNULL([Nov-2019],0), ISNULL([Dec-2019],0), ISNULL([Jan-2020],0), ISNULL([Feb-2020],0), ISNULL([Mar-2020],0)
FROM #output2;

INSERT INTO #GTVTOTAL
SELECT TariffPaymentMode, 3,
ROUND(SUM([Apr-2018]) * 0.00001, 2), ROUND(SUM([May-2018]) * 0.00001, 2), ROUND(SUM([Jun-2018]) * 0.00001, 2), ROUND(SUM([Jul-2018]) * 0.00001, 2), 
ROUND(SUM([Aug-2018]) * 0.00001, 2), ROUND(SUM([Sep-2018]) * 0.00001, 2), ROUND(SUM([Oct-2018]) * 0.00001, 2), ROUND(SUM([Nov-2018]) * 0.00001, 2), 
ROUND(SUM([Dec-2018]) * 0.00001, 2), ROUND(SUM([Jan-2019]) * 0.00001, 2), ROUND(SUM([Feb-2019]) * 0.00001, 2), ROUND(SUM([Mar-2019]) * 0.00001, 2),
ROUND(SUM([Apr-2019]) * 0.00001, 2), ROUND(SUM([May-2019]) * 0.00001, 2), ROUND(SUM([Jun-2019]) * 0.00001, 2), ROUND(SUM([Jul-2019]) * 0.00001, 2),
ROUND(SUM([Aug-2019]) * 0.00001, 2), ROUND(SUM([Sep-2019]) * 0.00001, 2), ROUND(SUM([Oct-2019]) * 0.00001, 2), ROUND(SUM([Nov-2019]) * 0.00001, 2), 
ROUND(SUM([Dec-2019]) * 0.00001, 2), ROUND(SUM([Jan-2020]) * 0.00001, 2), ROUND(SUM([Feb-2020]) * 0.00001, 2), ROUND(SUM([Mar-2020]) * 0.00001, 2)
FROM
#TEMPGTVwithoutMARKUP
GROUP BY TariffPaymentMode
ORDER BY TariffPaymentMode;

INSERT INTO #GTVTOTAL
SELECT 'GTV without Margin Total', 4, 
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019]),
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]), 
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020])
FROM #GTVTOTAL
WHERE MarkupFlg = 3;

INSERT INTO #GTVTOTAL
SELECT 'GTV Total', 5, 
SUM([Apr-2018]), SUM([May-2018]), SUM([Jun-2018]), SUM([Jul-2018]), SUM([Aug-2018]), SUM([Sep-2018]), SUM([Oct-2018]), SUM([Nov-2018]), SUM([Dec-2018]), 
SUM([Jan-2019]), SUM([Feb-2019]), SUM([Mar-2019]),
SUM([Apr-2019]), SUM([May-2019]), SUM([Jun-2019]), SUM([Jul-2019]), SUM([Aug-2019]), SUM([Sep-2019]), SUM([Oct-2019]), SUM([Nov-2019]), SUM([Dec-2019]), 
SUM([Jan-2020]), SUM([Feb-2020]), SUM([Mar-2020])
FROM #GTVTOTAL
WHERE MarkupFlg IN (2,4);


/*----- Result -----*/

SELECT '' AS C1,
'Jan-20' AS C23, 'Dec-19' AS C22, 'Nov-19' AS C21, 'Oct-19' AS C20, 'Sep-19' AS C19, 'Aug-19' AS C18, 'Jul-19' AS C17, 'Jun-19' AS C16, 'May-19' AS C15, 'Apr-19' AS C14,
'Mar-19' AS C13, 'Feb-19' AS C12, 'Jan-19' AS C11, 'Dec-18' AS C10, 'Nov-18' AS C9, 'Oct-18' AS C8, 'Sep-18' AS C7, 'Aug-18' AS C6, 'Jul-18' AS C5, 'Jun-18' AS C4,
'May-18' AS C3, 'Apr-18' AS C2;

SELECT 'Room Nights by Mode of payment ( Value in Nos )' AS Title;
SELECT 'Mode of payment' AS C1;
SELECT TariffPaymentMode,
[Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019], [Aug-2019], [Jul-2019], [Jun-2019], [May-2019], [Apr-2019],
[Mar-2019], [Feb-2019], [Jan-2019], [Dec-2018], [Nov-2018], [Oct-2018], [Sep-2018], [Aug-2018], [Jul-2018], [Jun-2018], [May-2018], [Apr-2018]
FROM #TDRCatgy
ORDER BY Flg;

SELECT 'Margin from External Properties by Mode of payment ( Value in Rs. ( Lacs) )' AS Title;
SELECT 'Mode of payment' AS C1;
SELECT TariffPaymentMode,
[Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019], [Aug-2019], [Jul-2019], [Jun-2019], [May-2019], [Apr-2019],
[Mar-2019], [Feb-2019], [Jan-2019], [Dec-2018], [Nov-2018], [Oct-2018], [Sep-2018], [Aug-2018], [Jul-2018], [Jun-2018], [May-2018], [Apr-2018]
FROM #TDRMARKUP_Category_New
ORDER BY Flg;


SELECT 'GTV by Mode of Payment (Excluding Guest House) ( Value in Rs. ( Lacs) )' AS Title;
SELECT 'Mode of Payment' AS C1;
SELECT TariffPaymentMode,
[Jan-2020], [Dec-2019], [Nov-2019], [Oct-2019], [Sep-2019], [Aug-2019], [Jul-2019], [Jun-2019], [May-2019], [Apr-2019],
[Mar-2019], [Feb-2019], [Jan-2019], [Dec-2018], [Nov-2018], [Oct-2018], [Sep-2018], [Aug-2018], [Jul-2018], [Jun-2018], [May-2018], [Apr-2018]
FROM #GTVTOTAL
ORDER BY MarkupFlg;

/*----- Daily Tracking Report End -----*/


END
END