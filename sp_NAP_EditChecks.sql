IF OBJECT_ID('dbo.sp_NAP_EditChecks') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.sp_NAP_EditChecks
END
GO

CREATE PROCEDURE [dbo].[sp_NAP_EditChecks] (@ExportPath VARCHAR(512) , @IncludeReports BIT )
AS
BEGIN

/* ===========================
Created on 6/30/23 By Tyler Trice
 -- This SP replicates the NAP Edit Checks performed by the DOR --
 -- Modification History:

==============================*/

  
/*=================== NAP DQ Edits ===================*/  
  
DECLARE @NAP_Edits TABLE ([Edit_Number] VARCHAR(6), [Edit_Desc] VARCHAR(512), [Percentage] DECIMAL(10,4), [FailedCheck] VARCHAR(4), [Edit_Count] INT, [PathToResults] VARCHAR(512)) ;  
DECLARE @Database VARCHAR(24) = (SELECT DB_NAME());  
--DECLARE @IncludeReports BIT = 1;  
  
IF OBJECT_ID('dbo.ext_NAPResults') IS NOT NULL   
BEGIN;  
 DROP TABLE ext_NAPResults ;  
END;  
  
CREATE TABLE ext_NAPResults ([PropertyID] VARCHAR(64), [ParcelNumber] VARCHAR(64));  
  
DECLARE @Extension VARCHAR(4) = '.csv';  
DECLARE @YearID SMALLINT = (SELECT RollYear FROM dbo.extFileTransferFlorida GROUP BY RollYear);
DECLARE @TotalCount SMALLINT = ( SELECT COUNT(*) FROM dbo.ExtFileTransferFlorida );
DECLARE @sql NVARCHAR(1000);  
  
/* ============= -- 01 -- ============= */  

DECLARE @EditNumber VARCHAR(6);
DECLARE @EditDescription VARCHAR(512); 
DECLARE @Percentage DECIMAL(10,4);
DECLARE @YesNo VARCHAR(4);
DECLARE @EditCount FLOAT;
--DECLARE @ExportPath VARCHAR(512);
DECLARE @ReportPath VARCHAR(512);
DECLARE @Report VARCHAR(128);
SET @EditNumber = '01';
SET @EditDescription = 'Do any accounts have a Total of Furniture, Fixtures and Equipment Just Value (Field 7) and Total of Leasehold Improvements Just Value (Field 8) that do not equal Total Just Value (Field 9)?';

TRUNCATE TABLE ext_NAPResults

INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
SELECT
	AltKey [PropertyID] ,
	CountyAccountNumber
FROM 
	dbo.ExtFileTransferFlorida
WHERE
	1=1
AND
	(CAST(FFEQJustValue AS INT) + CAST(LeaseHoldJustValue AS INT)) <> CAST(TotalJustValue AS INT)


SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM ext_NAPResults );
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );


IF EXISTS (SELECT * FROM ext_NAPResults) AND @IncludeReports = 1
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_NAPResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @NAP_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


--SELECT * FROM @NAP_Edits

/* ============= -- 02 -- ============= */

SET @EditNumber = '02';
SET @EditDescription = 'Do any accounts have a difference between Total Just Value (Field 9) and Total Assessed Value (Field 10) that does not equal the difference between Pollution Control Devices Just Value (Field 11) and Pollution Control Devices Assessed Value (Field 12)?';
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_NAPResults

INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
SELECT
	AltKey [PropertyID] ,
	CountyAccountNumber
FROM 
	dbo.ExtFileTransferFlorida
WHERE
	1=1
AND
	(CAST(TotalJustValue AS INT) - CAST(TotalAssessedValue AS INT)) 
	<> 
	(CAST(PollutionControlJustValue AS INT) - CAST(PollutionControlAssessedValue AS INT))


SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM ext_NAPResults );
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );


IF EXISTS (SELECT * FROM ext_NAPResults) AND @IncludeReports = 1
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_NAPResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @NAP_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


--SELECT * FROM @NAP_Edits

/* ============= -- 03 -- ============= */

SET @EditNumber = '03';
SET @EditDescription = 'Do any accounts have a difference between Total Assessed Value (Field 10) and Total Exemption Value (Field 13) that does not equal Total Taxable Value (Field 14)?';
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_NAPResults

INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
SELECT
	AltKey [PropertyID] ,
	CountyAccountNumber
FROM 
	dbo.ExtFileTransferFlorida
WHERE
	1=1
AND
	(CAST(TotalAssessedValue AS INT) - CAST(TotalExemptValue AS INT)) 
	<> 
	(CAST(TotalTaxValue AS INT))


SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM ext_NAPResults );
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );


IF EXISTS (SELECT * FROM ext_NAPResults) AND @IncludeReports = 1
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_NAPResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @NAP_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


--SELECT * FROM @NAP_Edits

/* ============= -- 04 -- ============= */

SET @EditNumber = '04';
SET @EditDescription = 'Are any fields completely blank (except Fields 21-28, 32, 33, 35 and 36)?';
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

-- this check is for the entire field, not individual records
TRUNCATE TABLE ext_NAPResults

/* Field 1 - CountyNumber */
IF ( SELECT COUNT(CountyNumber) FROM dbo.ExtFileTransferFlorida WHERE NULLIF(CountyNumber,'') IS NULL ) = @TotalCount
BEGIN
	INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
	VALUES ('Field:','CountyNumber')
END

/* Field 2 - CountyAccountNumber */
IF ( SELECT COUNT(CountyAccountNumber) FROM dbo.ExtFileTransferFlorida WHERE NULLIF(CountyAccountNumber,'') IS NULL ) = @TotalCount
BEGIN
	INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
	VALUES ('Field:','CountyAccountNumber')
END

/* Field 3 - TaxingCode */
IF ( SELECT COUNT(TaxingCode) FROM dbo.ExtFileTransferFlorida WHERE NULLIF(TaxingCode,'') IS NULL ) = @TotalCount
BEGIN
	INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
	VALUES ('Field:','TaxingCode')
END

/* Field 4 - RollType */
IF ( SELECT COUNT(RollType) FROM dbo.ExtFileTransferFlorida WHERE NULLIF(RollType,'') IS NULL ) = @TotalCount
BEGIN
	INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
	VALUES ('Field:','RollType')
END

/* Field 5 - RollYear */
IF ( SELECT COUNT(RollYear) FROM dbo.ExtFileTransferFlorida WHERE NULLIF(RollYear,'') IS NULL ) = @TotalCount
BEGIN
	INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
	VALUES ('Field:','RollYear')
END

/* Field 6 - NAICSCode */
IF ( SELECT COUNT(NAICSCode) FROM dbo.ExtFileTransferFlorida WHERE NULLIF(NAICSCode,'') IS NULL ) = @TotalCount
BEGIN
	INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
	VALUES ('Field:','NAICSCode')
END

/* Field 7 - FFEQJustValue */
IF ( SELECT COUNT(FFEQJustValue) FROM dbo.ExtFileTransferFlorida WHERE NULLIF(FFEQJustValue,'') IS NULL ) = @TotalCount
BEGIN
	INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
	VALUES ('Field:','FFEQJustValue')
END

/* Field 8 - LeaseHoldJustValue */
IF ( SELECT COUNT(LeaseHoldJustValue) FROM dbo.ExtFileTransferFlorida WHERE NULLIF(LeaseHoldJustValue,'') IS NULL ) = @TotalCount
BEGIN
	INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
	VALUES ('Field:','LeaseHoldJustValue')
END

/* Field 9 - TotalJustValue */
IF ( SELECT COUNT(TotalJustValue) FROM dbo.ExtFileTransferFlorida WHERE NULLIF(TotalJustValue,'') IS NULL ) = @TotalCount
BEGIN
	INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
	VALUES ('Field:','TotalJustValue')
END

/* Field 10 - TotalAssessedValue */
IF ( SELECT COUNT(TotalAssessedValue) FROM dbo.ExtFileTransferFlorida WHERE NULLIF(TotalAssessedValue,'') IS NULL ) = @TotalCount
BEGIN
	INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
	VALUES ('Field:','TotalAssessedValue')
END

/* Field 11 - PollutionControlJustValue */
IF ( SELECT COUNT(PollutionControlJustValue) FROM dbo.ExtFileTransferFlorida WHERE NULLIF(PollutionControlJustValue,'') IS NULL ) = @TotalCount
BEGIN
	INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
	VALUES ('Field:','PollutionControlJustValue')
END

/* Field 12 - PollutionControlAssessedValue */
IF ( SELECT COUNT(PollutionControlAssessedValue) FROM dbo.ExtFileTransferFlorida WHERE NULLIF(PollutionControlAssessedValue,'') IS NULL ) = @TotalCount
BEGIN
	INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
	VALUES ('Field:','PollutionControlAssessedValue')
END

/* Field 13 - TotalExemptValue */
IF ( SELECT COUNT(TotalExemptValue) FROM dbo.ExtFileTransferFlorida WHERE NULLIF(TotalExemptValue,'') IS NULL ) = @TotalCount
BEGIN
	INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
	VALUES ('Field:','TotalExemptValue')
END

/* Field 14 - TotalTaxValue */
IF ( SELECT COUNT(TotalTaxValue) FROM dbo.ExtFileTransferFlorida WHERE NULLIF(TotalTaxValue,'') IS NULL ) = @TotalCount
BEGIN
	INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
	VALUES ('Field:','TotalTaxValue')
END

/* Field 15 - PenaltyRate */
IF ( SELECT COUNT(PenaltyRate) FROM dbo.ExtFileTransferFlorida WHERE NULLIF(PenaltyRate,'') IS NULL ) = @TotalCount
BEGIN
	INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
	VALUES ('Field:','PenaltyRate')
END

/* Field 16 - OwnerName */
IF ( SELECT COUNT(OwnerName) FROM dbo.ExtFileTransferFlorida WHERE NULLIF(OwnerName,'') IS NULL ) = @TotalCount
BEGIN
	INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
	VALUES ('Field:','OwnerName')
END

/* Field 17 - OwnerMailing */
IF ( SELECT COUNT(OwnerMailing) FROM dbo.ExtFileTransferFlorida WHERE NULLIF(OwnerMailing,'') IS NULL ) = @TotalCount
BEGIN
	INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
	VALUES ('Field:','OwnerMailing')
END

/* Field 18 - OwnerCity */
IF ( SELECT COUNT(OwnerCity) FROM dbo.ExtFileTransferFlorida WHERE NULLIF(OwnerCity,'') IS NULL ) = @TotalCount
BEGIN
	INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
	VALUES ('Field:','OwnerCity')
END

/* Field 19 - OwnerStateOrCountry */
IF ( SELECT COUNT(OwnerStateOrCountry) FROM dbo.ExtFileTransferFlorida WHERE NULLIF(OwnerStateOrCountry,'') IS NULL ) = @TotalCount
BEGIN
	INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
	VALUES ('Field:','OwnerStateOrCountry')
END

/* Field 20 - OwnerZipCode */
IF ( SELECT COUNT(OwnerZipCode) FROM dbo.ExtFileTransferFlorida WHERE NULLIF(OwnerZipCode,'') IS NULL ) = @TotalCount
BEGIN
	INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
	VALUES ('Field:','OwnerZipCode')
END

/* Field 29 - LocAddr */
IF ( SELECT COUNT(LocAddr) FROM dbo.ExtFileTransferFlorida WHERE NULLIF(LocAddr,'') IS NULL ) = @TotalCount
BEGIN
	INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
	VALUES ('Field:','LocAddr')
END

/* Field 30 - LocCity */
IF ( SELECT COUNT(LocCity) FROM dbo.ExtFileTransferFlorida WHERE NULLIF(LocCity,'') IS NULL ) = @TotalCount
BEGIN
	INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
	VALUES ('Field:','LocCity')
END

/* Field 31 - LocZip */
IF ( SELECT COUNT(LocZip) FROM dbo.ExtFileTransferFlorida WHERE NULLIF(LocZip,'') IS NULL ) = @TotalCount
BEGIN
	INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
	VALUES ('Field:','LocZip')
END

/* Field 34 - Exemptions */
IF ( SELECT COUNT(Exemptions) FROM dbo.ExtFileTransferFlorida WHERE NULLIF(Exemptions,'') IS NULL ) = @TotalCount
BEGIN
	INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
	VALUES ('Field:','Exemptions')
END


SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM ext_NAPResults );
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );

IF EXISTS (SELECT * FROM ext_NAPResults) AND @IncludeReports = 1
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_NAPResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @NAP_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


--SELECT * FROM @NAP_Edits

/* ============= -- 05 -- ============= */

SET @EditNumber = '05';
SET @EditDescription = 'Inactive Edit';

IF @ReportPath IS NOT NULL SET @ReportPath = NULL;
IF @EditCount IS NOT NULL SET @EditCount = NULL;
IF @YesNo IS NOT NULL SET @YesNo = NULL;
IF @Percentage IS NOT NULL SET @Percentage = NULL;

INSERT INTO  @NAP_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 

--SELECT * FROM @NAP_Edits

/* ============= -- 06 -- ============= */

SET @EditNumber = '06';
SET @EditDescription = 'Do any accounts have an invalid NAICS Code (Field 6)?';
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_NAPResults

INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
SELECT
	AltKey [PropertyID] ,
	CountyAccountNumber
FROM 
	dbo.ExtFileTransferFlorida
WHERE
	1=1
AND
	NAICSCode NOT IN (SELECT Business FROM dbo.GetxrBusinessTable(1,@YearID,1) WHERE Business <> '')


SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM ext_NAPResults );
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );


IF EXISTS (SELECT * FROM ext_NAPResults) AND @IncludeReports = 1
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_NAPResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @NAP_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


--SELECT * FROM @NAP_Edits

/* ============= -- 07 -- ============= */

SET @EditNumber = '07';
SET @EditDescription = 'Do any accounts have a Just Value of Pollution Control (Field 11) greater than Just Value of FFE (Field 7)?';
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_NAPResults

INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
SELECT
	AltKey [PropertyID] ,
	CountyAccountNumber
FROM 
	dbo.ExtFileTransferFlorida
WHERE
	1=1
AND
	CAST(PollutionControlJustValue AS INT) > CAST(FFEQJustValue AS INT)

SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM ext_NAPResults );
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );


IF EXISTS (SELECT * FROM ext_NAPResults) AND @IncludeReports = 1
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_NAPResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @NAP_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


--SELECT * FROM @NAP_Edits

/* ============= -- 08 -- ============= */

SET @EditNumber = '08';
SET @EditDescription = 'Do any accounts have a Total Assessed Value of Pollution Control (Field 12) greater than the Total Assessed Value (Field 10)?';
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_NAPResults

INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
SELECT
	AltKey [PropertyID] ,
	CountyAccountNumber
FROM 
	dbo.ExtFileTransferFlorida
WHERE
	1=1
AND
	CAST(PollutionControlAssessedValue AS INT) > CAST(TotalAssessedValue AS INT)

SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM ext_NAPResults );
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );


IF EXISTS (SELECT * FROM ext_NAPResults) AND @IncludeReports = 1
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_NAPResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @NAP_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


--SELECT * FROM @NAP_Edits

/* ============= -- 09 -- ============= */

SET @EditNumber = '09';
SET @EditDescription = 'Do any accounts have a sum of Exemptions in Field 34 that does not equal the Total Exemption Value (Field 13)?';
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_NAPResults

INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
SELECT
	AltKey [PropertyID] ,
	CountyAccountNumber
FROM 
	dbo.ExtFileTransferFlorida
WHERE
	1=1
AND
	NULLIF(Exemptions,'') IS NOT NULL 
AND
	Exemptions NOT LIKE ('%Q%') -- Removes 80% Renewable energy Exemption becuase it was causing an issue on one account
AND
	CAST(RIGHT(Exemptions,LEN(Exemptions)-2) AS INT)
	<>
	CAST(TotalExemptValue AS INT)

SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM ext_NAPResults );
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );


IF EXISTS (SELECT * FROM ext_NAPResults) AND @IncludeReports = 1
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_NAPResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @NAP_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


--SELECT * FROM @NAP_Edits

/* ============= -- 10 -- ============= */

SET @EditNumber = '10';
SET @EditDescription = 'Do any accounts have an invalid entry in the Exemption Field (Field 34)?';
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_NAPResults

INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
SELECT
	AltKey [PropertyID] ,
	CountyAccountNumber
FROM 
	dbo.ExtFileTransferFlorida
WHERE
	1=1
AND
	NULLIF(Exemptions,'') IS NOT NULL 
AND
	PATINDEX(N'%[ABCDEFGHIJKLMNOPQ1234567890;]%',Exemptions) <> 1

SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM ext_NAPResults );
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );


IF EXISTS (SELECT * FROM ext_NAPResults) AND @IncludeReports = 1
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_NAPResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @NAP_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


--SELECT * FROM @NAP_Edits

/* ============= -- 11 -- ============= */

SET @EditNumber = '11';
SET @EditDescription = 'Inactive Edit';

IF @ReportPath IS NOT NULL SET @ReportPath = NULL;
IF @EditCount IS NOT NULL SET @EditCount = NULL;
IF @YesNo IS NOT NULL SET @YesNo = NULL;
IF @Percentage IS NOT NULL SET @Percentage = NULL;

INSERT INTO  @NAP_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 

--SELECT * FROM @NAP_Edits

/* ============= -- 12 -- ============= */

SET @EditNumber = '12';
SET @EditDescription = 'Do any accounts have a Total Just Value of Pollution Control (Field 11) equal to the Total Assessed Value of Pollution Control (Field 12)?';
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_NAPResults

INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
SELECT
	AltKey [PropertyID] ,
	CountyAccountNumber
FROM 
	dbo.ExtFileTransferFlorida
WHERE
	1=1
AND
	CAST(PollutionControlJustValue AS INT)
	=
	CAST(PollutionControlAssessedValue AS INT)
AND
	CAST(PollutionControlJustValue AS INT) <> 0

SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM ext_NAPResults );
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );


IF EXISTS (SELECT * FROM ext_NAPResults) AND @IncludeReports = 1
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_NAPResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @NAP_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


--SELECT * FROM @NAP_Edits

/* ============= -- 13 -- ============= */

SET @EditNumber = '13';
SET @EditDescription = 'Do any accounts have a negative value reported for Total Just Value (Field 9), Total Assessed Value (Field 10), Total Exemption Value (Field 13), or Total Taxable Value (Field 14)?';
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_NAPResults

INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
SELECT
	AltKey [PropertyID] ,
	CountyAccountNumber
FROM 
	dbo.ExtFileTransferFlorida
WHERE
	1=1
AND
	(
	SIGN(CAST(TotalJustValue AS INT)) = -1
	OR
	SIGN(CAST(TotalAssessedValue AS INT)) = -1
	OR
	SIGN(CAST(TotalExemptValue AS INT)) = -1
	OR
	SIGN(CAST(TotalTaxValue AS INT)) = -1
	)

SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM ext_NAPResults );
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );


IF EXISTS (SELECT * FROM ext_NAPResults) AND @IncludeReports = 1
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_NAPResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @NAP_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


--SELECT * FROM @NAP_Edits

/* ============= -- 14 -- ============= */

SET @EditNumber = '14';
SET @EditDescription = 'Do any accounts have a roll year not equal to assessment year (Field 5)?';
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_NAPResults

INSERT INTO ext_NAPResults ( [PropertyID] , [ParcelNumber] )
SELECT
	AltKey [PropertyID] ,
	CountyAccountNumber
FROM 
	dbo.ExtFileTransferFlorida
WHERE
	1=1
AND
	RollYear <> (SELECT YearID FROM xrYearColor WHERE IsCurrentFlag = 1 GROUP BY YearID)

SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM ext_NAPResults );
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );


IF EXISTS (SELECT * FROM ext_NAPResults) AND @IncludeReports = 1
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_NAPResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @NAP_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 

--SELECT * FROM @NAP_Edits

/* ============= -- Totals -- ============= */

SET @EditNumber = 'Totals';
SET @EditDescription = CONCAT('Total Record Count: ', @TotalCount);

INSERT INTO  @NAP_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , NULL , NULL , NULL, NULL ) ; 

SELECT * FROM @NAP_Edits

/* ========================== 
Export Final NAP Results
 ========================== */

DROP TABLE IF EXISTS ##nap_results;
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

SET @ReportPath = CONCAT(@ExportPath,'\');
SET @Report = 'NAP_Edit_Check_Results.csv';

DECLARE @napCount SMALLINT = (SELECT COUNT(*) + 1 FROM @NAP_Edits);

SELECT * 
INTO ##nap_results
FROM @NAP_Edits --> Edit Report

EXEC [dbo].[ext_ExportDataToCsv] @dbName = 'tempdb',
							 @includeHeaders = 1,
							 @filePath = @ReportPath,
							 @tableName = '##nap_results',
							 @reportName = @Report,
							 @delimiter = '|';

SET @ReportPath = CONCAT(@ReportPath,@Report);
SET @ExportPath = REPLACE(@ReportPath, 'csv', 'xlsx');

EXEC [dbo].[CSVtoXLSXwTable] @fullCsvPath = @ReportPath , @fullXlsxPath = @ExportPath , @rowCount = @napCount, @colCharacter = 'F';

DROP TABLE IF EXISTS ##nap_results;

IF OBJECT_ID('dbo.ext_NAPResults') IS NOT NULL 
BEGIN;
	DROP TABLE ext_NAPResults ;
END;

END