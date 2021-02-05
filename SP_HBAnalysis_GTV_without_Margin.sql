-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[SP_HBAnalysis_GTV_without_Margin]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
DROP PROCEDURE [dbo].[SP_HBAnalysis_GTV_without_Margin]
GO 
CREATE PROCEDURE [dbo].[SP_HBAnalysis_GTV_without_Margin](@Action NVARCHAR(100),@Str NVARCHAR(100),@Id BIGINT)
/*
Exec [dbo].[SP_HBAnalysis_GTV_without_Margin] @Action = '',@Str = '',@Id = 0;
*/
AS
BEGIN
SET NOCOUNT ON
SET ANSI_WARNINGS OFF
IF @Action = ''
BEGIN

CREATE TABLE #TEMP1(BookingCode BIGINT,CheckInDt DATE,CheckOutDt DATE,Tariff DECIMAL(27,2),MarkUp DECIMAL(27,2),PropertyId BIGINT,MasterPropertyId BIGINT,
RoomCaptured BIGINT,BookingId BIGINT,CityId BIGINT,PropertyCategory NVARCHAR(100),ClientId BIGINT,MasterClientId BIGINT,BookedDt VARCHAR(100));
INSERT INTO #TEMP1
SELECT S.BookingCode,S.CheckInDt,S.CheckOutDt,SUM(S.Tariff),SUM(S.MarkUp),S.PropertyId,S.MasterPropertyId,RoomCaptured,S.BookingId,S.CityId,S.PropertyCategory,S.ClientId,
C.MasterClientId, SUBSTRING(DATENAME(MONTH, S.BookingDate), 1, 3) + '-' + CAST(YEAR(S.BookingDate) AS VARCHAR)
FROM WRBHBBookingStatus S
LEFT OUTER JOIN WRBHBClientManagement C WITH(NOLOCK)ON C.Id = S.ClientId
WHERE
S.Status != 'Canceled' AND S.PropertyCategory = 'C P P' AND S.MarkUp = 0
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

DELETE #TEMP2 WHERE asasd NOT IN ('Aug-2019', 'Sep-2019', 'Oct-2019', 'Nov-2019', 'Dec-2019', 'Jan-2020');

/* ----- Daily Tracking Report Start ----- */

/* -- GTV WITHOUT MARKUP */

/*CREATE TABLE #dsadasd2(PropertyCategory NVARCHAR(100),MonthofBooking NVARCHAR(100),Tariff DECIMAL(27,2),MasterClientId BIGINT,PropertyId BIGINT,ClientId BIGINT);
INSERT INTO #dsadasd2(PropertyCategory,MonthofBooking,Tariff,MasterClientId,PropertyId,ClientId)
SELECT PropertyCategory,asasd,SUM(Tariff),MasterClientId,PropertyId,ClientId FROM #TEMP2
GROUP BY PropertyCategory,asasd,MasterClientId,PropertyId,ClientId;

SELECT   PropertyCategory,MasterClientId,PropertyId,ClientId,
         [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020]
INTO #output2
FROM #dsadasd2
PIVOT
(
       SUM(Tariff)
       FOR MonthofBooking IN 
	   ([Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020])
) AS P2;

CREATE TABLE #TEMPGTVwithoutMARKUP(PropertyCategory NVARCHAR(100),MasterClientId BIGINT,PropertyId BIGINT,ClientId BIGINT,
[Aug-2019] INT, [Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT, [Jan-2020] INT);

INSERT INTO #TEMPGTVwithoutMARKUP
SELECT PropertyCategory,MasterClientId,PropertyId,ClientId,
ISNULL([Aug-2019],0), ISNULL([Sep-2019],0), ISNULL([Oct-2019],0), ISNULL([Nov-2019],0), ISNULL([Dec-2019],0), ISNULL([Jan-2020],0)
FROM #output2;

/* - CLIENT WISE GTV */

SELECT C.ClientName, T.MasterClientId, P.PropertyName, T.PropertyId,
SUM([Aug-2019]) AS [Aug-2019], SUM([Sep-2019]) AS [Sep-2019], SUM([Oct-2019]) AS [Oct-2019], SUM([Nov-2019]) AS [Nov-2019], SUM([Dec-2019]) AS [Dec-2019],
SUM([Jan-2020]) AS [Jan-2020]
FROM #TEMPGTVwithoutMARKUP T
LEFT OUTER JOIN WRBHBMasterClientManagement C WITH(NOLOCK)ON C.Id = T.MasterClientId
LEFT OUTER JOIN WRBHBProperty P WITH(NOLOCK)ON P.Id = T.PropertyId
GROUP BY C.ClientName, T.MasterClientId, P.PropertyName, T.PropertyId;*/


CREATE TABLE #sfsfsf(NightCount int,MonthofBooking NVARCHAR(100),MasterClientId BIGINT,PropertyId BIGINT,ClientId BIGINT);
INSERT INTO #sfsfsf(NightCount,MonthofBooking,MasterClientId,PropertyId,ClientId)
SELECT count(CalendarDate),asasd,MasterClientId,PropertyId,ClientId FROM #TEMP2
GROUP BY PropertyCategory,asasd,MasterClientId,PropertyId,ClientId;

SELECT   MasterClientId,PropertyId,ClientId,
         [Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020]
INTO #fdsfsfsfsdf
FROM #sfsfsf
PIVOT
(
       SUM(NightCount)
       FOR MonthofBooking IN 
	   ([Aug-2019], [Sep-2019], [Oct-2019], [Nov-2019], [Dec-2019], [Jan-2020])
) AS P2;

CREATE TABLE #dfsfdfsdffsfsdfsfd(MasterClientId BIGINT,PropertyId BIGINT,ClientId BIGINT,
[Aug-2019] INT, [Sep-2019] INT, [Oct-2019] INT, [Nov-2019] INT, [Dec-2019] INT, [Jan-2020] INT);

INSERT INTO #dfsfdfsdffsfsdfsfd
SELECT MasterClientId,PropertyId,ClientId,
ISNULL([Aug-2019],0), ISNULL([Sep-2019],0), ISNULL([Oct-2019],0), ISNULL([Nov-2019],0), ISNULL([Dec-2019],0), ISNULL([Jan-2020],0)
FROM #fdsfsfsfsdf;

--SELECT * FROM #dfsfdfsdffsfsdfsfd WHERE PropertyId = 37513;

SELECT MC.ClientName, T.MasterClientId, T.ClientId, P.PropertyName, T.PropertyId, D.ContactName, D.ContactPhone, D.Email,
T.[Aug-2019], T.[Sep-2019], T.[Oct-2019], T.[Nov-2019], T.[Dec-2019], T.[Jan-2020]
FROM WRBHBContractClientPref_Header H
LEFT OUTER JOIN WRBHBContractClientPref_Details D WITH(NOLOCK)ON H.Id = D.HeaderId
LEFT OUTER JOIN #dfsfdfsdffsfsdfsfd T WITH(NOLOCK)ON T.PropertyId = D.PropertyId AND T.ClientId = H.ClientId
LEFT OUTER JOIN WRBHBMasterClientManagement MC WITH(NOLOCK)ON MC.Id = T.MasterClientId
LEFT OUTER JOIN WRBHBProperty P WITH(NOLOCK)ON P.Id = T.PropertyId
WHERE
H.IsActive = 1 AND H.IsDeleted = 0 AND
D.IsActive = 1 AND D.IsDeleted = 0 AND
T.ClientId = H.ClientId AND
T.PropertyId = D.PropertyId
--AND P.Id = 37513
GROUP BY MC.ClientName, T.MasterClientId, P.PropertyName, T.PropertyId, D.ContactName, D.ContactPhone, D.Email, T.ClientId,
T.[Aug-2019], T.[Sep-2019], T.[Oct-2019], T.[Nov-2019], T.[Dec-2019], T.[Jan-2020]
ORDER BY MC.ClientName, P.PropertyName, T.ClientId;RETURN;



SELECT MC.ClientName, T.MasterClientId, P.PropertyName, T.PropertyId,
T.[Aug-2019], T.[Sep-2019], T.[Oct-2019], T.[Nov-2019], T.[Dec-2019], T.[Jan-2020]
FROM #dfsfdfsdffsfsdfsfd T
LEFT OUTER JOIN WRBHBMasterClientManagement MC WITH(NOLOCK)ON MC.Id = T.MasterClientId
LEFT OUTER JOIN WRBHBProperty P WITH(NOLOCK)ON P.Id = T.PropertyId
WHERE P.Id = 37513
ORDER BY MC.ClientName, P.PropertyName;






END
END