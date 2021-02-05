-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[SP_HBAnalysis_Report]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
DROP PROCEDURE [dbo].[SP_HBAnalysis_Report]
GO 
CREATE PROCEDURE [dbo].[SP_HBAnalysis_Report](@Action NVARCHAR(100),@Str NVARCHAR(100),@Id BIGINT)
--Exec [dbo].[SP_HBAnalysis_Report] @Action = '',@Str = '',@Id = 0;
AS
BEGIN
SET NOCOUNT ON
SET ANSI_WARNINGS OFF
IF @Action = ''
BEGIN

Exec [dbo].[SP_HBAnalysis_Feb21] @Action = '',@Str = '',@Id = 0; 

END

END