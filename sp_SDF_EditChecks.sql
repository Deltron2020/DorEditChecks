IF OBJECT_ID('dbo.sp_SDF_EditChecks') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.sp_SDF_EditChecks
END
GO


CREATE PROCEDURE [dbo].[sp_SDF_EditChecks] (@ExportPath VARCHAR(512) , @IncludeReports BIT )
AS
BEGIN

/* ===========================
Created on 3/30/23 By Tyler Trice
 -- This SP replicates the SDF Edit Checks performed by the DOR --
 -- Modification History:
 -- 4/10/23 > Changed YearID to be RollYear in SDF data rather than current active year in AP5
 -- > Modified edit check 16, now it checks entire field versus individual records. It will no longer produce a report at all, only 1 if field is completely blank, 0 if it is not.
 -- > Changed @Database variable from input parameter to being declared in sp as name of active db

==============================*/

/*=================== SDF DQ Edits ===================*/

DECLARE @SDF_Edits TABLE ([Edit_Number] VARCHAR(6), [Edit_Desc] VARCHAR(512), [Percentage] DECIMAL(10,4), [FailedCheck] VARCHAR(4), [Edit_Count] INT, [PathToResults] VARCHAR(512)) ;
DECLARE @Database VARCHAR(24) = (SELECT DB_NAME());
--DECLARE @IncludeReports BIT = 1;

IF OBJECT_ID('dbo.ext_SDFResults') IS NOT NULL 
BEGIN;
	DROP TABLE ext_SDFResults ;
END;

CREATE TABLE ext_SDFResults ([ParcelNumber] VARCHAR(64));

DECLARE @Extension VARCHAR(4) = '.csv';
DECLARE @YearID SMALLINT = (SELECT RollYear FROM dbo.extFloridaSDF GROUP BY RollYear);
DECLARE @TotalCount SMALLINT = (SELECT COUNT(*) FROM extFloridaSDF);
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
SET @EditDescription = 'Do any sales have a missing or invalid sales month?';
SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM extFloridaSDF WHERE NULLIF(SaleMonth, '') IS NULL OR  SaleMonth NOT IN ('01','02','03','04','05','06','07','08','09','10','11','12'));
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );

TRUNCATE TABLE ext_SDFResults

INSERT INTO ext_SDFResults ( [ParcelNumber] )
SELECT 
	ParcelNumber 
FROM 
	extFloridaSDF 
WHERE 
	NULLIF(SaleMonth, '') IS NULL 
OR  
	SaleMonth NOT IN ('01','02','03','04','05','06','07','08','09','10','11','12')


IF ((SELECT COUNT(*) FROM ext_SDFResults) >= 1 AND @IncludeReports = 1)
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_SDFResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


--SELECT * FROM @SDF_Edits

/* ============= -- 02 -- ============= */

SET @EditNumber = '02';
SET @EditDescription = 'Do any records have a missing or invalid sale year?';
SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM extFloridaSDF WHERE NULLIF(SaleYear, '') IS NULL OR ISNUMERIC(SaleYear) = 0 OR (ISNUMERIC(SaleYear) = 1 AND SaleYear > @YearID) OR (ISNUMERIC(SaleYear) = 1 AND SaleYear <= (@YearID - 2))); -- review >> sdf report from DOR says only 2022 and 2023 sales should be on report
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_SDFResults

INSERT INTO ext_SDFResults ( [ParcelNumber] )
SELECT 
	ParcelNumber 
FROM 
	extFloridaSDF 
WHERE 
	NULLIF(SaleYear, '') IS NULL
OR
	ISNUMERIC(SaleYear) = 0
OR 
	(ISNUMERIC(SaleYear) = 1 AND SaleYear > @YearID)
OR 
	(ISNUMERIC(SaleYear) = 1 AND SaleYear <= (@YearID - 2))


IF ((SELECT COUNT(*) FROM ext_SDFResults) >= 1  AND @IncludeReports = 1)
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_SDFResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


/* ============= -- 03 -- ============= */

SET @EditNumber = '03';
SET @EditDescription = 'Do any records have a missing or invalid roll year?';
SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM extFloridaSDF WHERE NULLIF(RollYear, '') IS NULL OR ISNUMERIC(RollYear) = 0 OR (ISNUMERIC(RollYear) = 1 AND RollYear <> @YearID) );
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_SDFResults

INSERT INTO ext_SDFResults ( [ParcelNumber] )
SELECT 
	ParcelNumber 
FROM 
	extFloridaSDF 
WHERE 
	NULLIF(RollYear, '') IS NULL 
OR
	ISNUMERIC(RollYear) = 0
OR 
	(ISNUMERIC(RollYear) = 1 AND RollYear <> @YearID)


IF ((SELECT COUNT(*) FROM ext_SDFResults) >= 1  AND @IncludeReports = 1)
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_SDFResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


/* ============= -- 04 -- ============= */

SET @EditNumber = '04';
SET @EditDescription = 'Do any sales have a missing or invalid O.R. Book or Clerk Instrument Number?';
SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM extFloridaSDF WHERE NULLIF(ORBook, '') IS NULL OR ISNUMERIC(ORBook) <> 1 );
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_SDFResults

INSERT INTO ext_SDFResults ( [ParcelNumber] )
SELECT 
	ParcelNumber 
FROM 
	extFloridaSDF 
WHERE 
	NULLIF(ORBook, '') IS NULL 
OR 
	ISNUMERIC(ORBook) <> 1


IF ((SELECT COUNT(*) FROM ext_SDFResults) >= 1  AND @IncludeReports = 1)
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_SDFResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


/* ============= -- 05 -- ============= */

SET @EditNumber = '05';
SET @EditDescription = 'Do any sales have a missing or invalid Page Number?';
SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM extFloridaSDF WHERE NULLIF(ORPage, '') IS NULL OR ISNUMERIC(ORPage) <> 1 );
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_SDFResults

INSERT INTO ext_SDFResults ( [ParcelNumber] )
SELECT 
	ParcelNumber 
FROM 
	extFloridaSDF 
WHERE 
	NULLIF(ORPage, '') IS NULL 
OR 
	ISNUMERIC(ORPage) <> 1


IF ((SELECT COUNT(*) FROM ext_SDFResults) >= 1  AND @IncludeReports = 1)
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_SDFResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


/* ============= -- 06 -- ============= */

SET @EditNumber = '06';
SET @EditDescription = 'Are both the instrument number and the O.R. Book & Page Number fields filled? (Records should only have one or the other populated)';
SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM extFloridaSDF WHERE NOT ( (NULLIF(ClerkInstrumentNumber, '') IS NULL AND NULLIF(ORBook, '') IS NOT NULL AND NULLIF(ORPage, '') IS NOT NULL) OR (NULLIF(ClerkInstrumentNumber, '') IS NOT NULL AND NULLIF(ORBook, '') IS NULL AND NULLIF(ORPage, '') IS NULL)  ) );
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_SDFResults

INSERT INTO ext_SDFResults
SELECT 
	ParcelNumber 
FROM 
	extFloridaSDF 
WHERE NOT ( 
   (NULLIF(ClerkInstrumentNumber, '') IS NULL AND NULLIF(ORBook, '') IS NOT NULL AND NULLIF(ORPage, '') IS NOT NULL)  -- Instrument Number not populated and book/page are
   OR (NULLIF(ClerkInstrumentNumber, '') IS NOT NULL AND NULLIF(ORBook, '') IS NULL AND NULLIF(ORPage, '') IS NULL)  ) -- Instrument Number is populated and book/page are not


IF ((SELECT COUNT(*) FROM ext_SDFResults) >= 1  AND @IncludeReports = 1)
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_SDFResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


/* ============= -- 07 -- ============= */

SET @EditNumber = '07';
SET @EditDescription = 'Do any sales have a missing or invalid sales price?';
SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM extFloridaSDF WHERE NULLIF(SalePrice,'') IS NULL OR ISNUMERIC(SalePrice) <> 1 OR SalePrice < 0 );
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_SDFResults

INSERT INTO ext_SDFResults
SELECT 
	ParcelNumber 
FROM 
	extFloridaSDF 
WHERE
	NULLIF(SalePrice,'') IS NULL
OR
	ISNUMERIC(SalePrice) <> 1
OR
	SalePrice < 0


IF ((SELECT COUNT(*) FROM ext_SDFResults) >= 1  AND @IncludeReports = 1)
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_SDFResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


/* ============= -- 08 -- ============= */

SET @EditNumber = '08';
SET @EditDescription = 'Are there any sale prices between $1 and $99?';
SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM extFloridaSDF WHERE ISNUMERIC(SalePrice) = 1 AND SalePrice BETWEEN 1 AND 99 );
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_SDFResults

INSERT INTO ext_SDFResults
SELECT 
	ParcelNumber 
FROM 
	extFloridaSDF 
WHERE
	ISNUMERIC(SalePrice) = 1
AND
	SalePrice BETWEEN 1 AND 99


IF ((SELECT COUNT(*) FROM ext_SDFResults) >= 1  AND @IncludeReports = 1)
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_SDFResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


/* ============= -- 09 -- ============= */

SET @EditNumber = '09';
SET @EditDescription = 'Do any reported qualified sales have a price of $100 or less?';
SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM extFloridaSDF WHERE ISNUMERIC(SalePrice) = 1 AND SalePrice <= 100 AND NULLIF(SaleTransferCode, '') BETWEEN 1 AND 6 ); -- review (Michelle said qualified sales qual codes were 01 & 05, Patriot coded for codes 01, 02, 03, 04, 05, 06. The 4 records that failed were 01 & 05 but some other codes are present in the sdf.)
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_SDFResults

INSERT INTO ext_SDFResults
SELECT 
	ParcelNumber
FROM 
	extFloridaSDF 
WHERE
	ISNUMERIC(SalePrice) = 1
AND
	SalePrice <= 100
AND
	NULLIF(SaleTransferCode, '') BETWEEN 1 AND 6


IF ((SELECT COUNT(*) FROM ext_SDFResults) >= 1  AND @IncludeReports = 1)
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_SDFResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ;


/* ============= -- 10 -- ============= */

SET @EditNumber = '10';
SET @EditDescription = 'Are any fields on the SDF completely blank or minimally filled?';
SET @EditCount = NULL;
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_SDFResults

--DECLARE @sql NVARCHAR(1000);

ALTER TABLE ext_SDFResults
ADD [Field] VARCHAR(64), [Count] SMALLINT ;

-- County Field --
SET @sql = '
INSERT INTO ext_SDFResults ([ParcelNumber], [Field], [Count])
SELECT 
	ParcelNumber,
	''CountyNumber'',
	COUNT(ISNULL(CountyNumber,1))
FROM extFloridaSDF
WHERE NULLIF(CountyNumber,'''') IS NULL
GROUP BY ParcelNumber
HAVING COUNT(ISNULL(CountyNumber,1)) >= 1 '
EXEC (@sql)

-- ParcelID Field --
SET @sql = '
INSERT INTO ext_SDFResults ([ParcelNumber], [Field], [Count])
SELECT 
	ParcelNumber,
	''ParcelNumber'',
	COUNT(ISNULL(ParcelNumber,1))
FROM extFloridaSDF
WHERE NULLIF(ParcelNumber,'''') IS NULL
GROUP BY ParcelNumber
HAVING COUNT(ISNULL(ParcelNumber,1)) >= 1 '
EXEC (@sql)

-- RollYear Field --
SET @sql = '
INSERT INTO ext_SDFResults ([ParcelNumber], [Field], [Count])
SELECT 
	ParcelNumber,
	''RollYear'',
	COUNT(ISNULL(RollYear,1))
FROM extFloridaSDF
WHERE NULLIF(RollYear,'''') IS NULL
GROUP BY ParcelNumber
HAVING COUNT(ISNULL(RollYear,1)) >= 1 '
EXEC (@sql)

-- Qual Field (SaleTransferCode) --
SET @sql = '
INSERT INTO ext_SDFResults ([ParcelNumber], [Field], [Count])
SELECT 
	ParcelNumber,
	''SaleTransferCode'',
	COUNT(ISNULL(SaleTransferCode,1))
FROM extFloridaSDF
WHERE NULLIF(SaleTransferCode,'''') IS NULL
GROUP BY ParcelNumber
HAVING COUNT(ISNULL(SaleTransferCode,1)) >= 1 '
EXEC (@sql)

-- VacantOrImprovedCode Field --
SET @sql = '
INSERT INTO ext_SDFResults ([ParcelNumber], [Field], [Count])
SELECT 
	ParcelNumber,
	''VacantOrImprovedCode'',
	COUNT(ISNULL(VacantOrImprovedCode,1))
FROM extFloridaSDF
WHERE NULLIF(VacantOrImprovedCode,'''') IS NULL
GROUP BY ParcelNumber
HAVING COUNT(ISNULL(VacantOrImprovedCode,1)) >= 1 '
EXEC (@sql)

-- Sale Price Field --
SET @sql = '
INSERT INTO ext_SDFResults ([ParcelNumber], [Field], [Count])
SELECT 
	ParcelNumber,
	''SalePrice'',
	COUNT(ISNULL(SalePrice,1))
FROM extFloridaSDF
WHERE NULLIF(SalePrice,'''') IS NULL
GROUP BY ParcelNumber
HAVING COUNT(ISNULL(SalePrice,1)) >= 1 '
EXEC (@sql)

-- Sale Year Field --
SET @sql = '
INSERT INTO ext_SDFResults ([ParcelNumber], [Field], [Count])
SELECT 
	ParcelNumber,
	''SaleYear'',
	COUNT(ISNULL(SaleYear,1))
FROM extFloridaSDF
WHERE NULLIF(SaleYear,'''') IS NULL
GROUP BY ParcelNumber
HAVING COUNT(ISNULL(SaleYear,1)) >= 1 '
EXEC (@sql)

-- Sale Month Field --
SET @sql = '
INSERT INTO ext_SDFResults ([ParcelNumber], [Field], [Count])
SELECT 
	ParcelNumber,
	''SaleMonth'',
	COUNT(ISNULL(SaleMonth,1))
FROM extFloridaSDF
WHERE NULLIF(SaleMonth,'''') IS NULL
GROUP BY ParcelNumber
HAVING COUNT(ISNULL(SaleMonth,1)) >= 1 '
EXEC (@sql)

-- Sale Month Field --
SET @sql = '
INSERT INTO ext_SDFResults ([ParcelNumber], [Field], [Count])
SELECT 
	ParcelNumber,
	''SaleMonth'',
	COUNT(ISNULL(SaleMonth,1))
FROM extFloridaSDF
WHERE NULLIF(SaleMonth,'''') IS NULL
GROUP BY ParcelNumber
HAVING COUNT(ISNULL(SaleMonth,1)) >= 1 '
EXEC (@sql)

-- ORBook Field --
SET @sql = '
INSERT INTO ext_SDFResults ([ParcelNumber], [Field], [Count])
SELECT 
	ParcelNumber,
	''ORBook'',
	COUNT(ISNULL(ORBook,1))
FROM extFloridaSDF
WHERE NULLIF(ORBook,'''') IS NULL
GROUP BY ParcelNumber
HAVING COUNT(ISNULL(ORBook,1)) >= 1 '
EXEC (@sql)

-- ORPage Field --
SET @sql = '
INSERT INTO ext_SDFResults ([ParcelNumber], [Field], [Count])
SELECT 
	ParcelNumber,
	''ORPage'',
	COUNT(ISNULL(ORPage,1))
FROM extFloridaSDF
WHERE NULLIF(ORPage,'''') IS NULL
GROUP BY ParcelNumber
HAVING COUNT(ISNULL(ORPage,1)) >= 1 '
EXEC (@sql)
/*
-- ClerkInstrumentNumber Field --
SET @sql = '
INSERT INTO ext_SDFResults ([ParcelNumber], [Field], [Count])
SELECT 
	ParcelNumber,
	''ClerkInstrumentNumber'',
	COUNT(ISNULL(ClerkInstrumentNumber,1))
FROM extFloridaSDF
WHERE NULLIF(ClerkInstrumentNumber,'''') IS NULL
GROUP BY ParcelNumber
HAVING COUNT(ISNULL(ClerkInstrumentNumber,1)) >= 1 '
EXEC (@sql)
*/
-- SaleIdentificationCode Field --
SET @sql = '
INSERT INTO ext_SDFResults ([ParcelNumber], [Field], [Count])
SELECT 
	ParcelNumber,
	''SaleIdentificationCode'',
	COUNT(ISNULL(SaleIdentificationCode,1))
FROM extFloridaSDF
WHERE NULLIF(SaleIdentificationCode,'''') IS NULL
GROUP BY ParcelNumber
HAVING COUNT(ISNULL(SaleIdentificationCode,1)) >= 1 '
EXEC (@sql)
/*
-- SalePropertyChangeCode Field --
SET @sql = '
INSERT INTO ext_SDFResults ([ParcelNumber], [Field], [Count])
SELECT 
	ParcelNumber,
	''SalePropertyChangeCode'',
	COUNT(ISNULL(SalePropertyChangeCode,1))
FROM extFloridaSDF
WHERE NULLIF(SalePropertyChangeCode,'''') IS NULL
GROUP BY ParcelNumber
HAVING COUNT(ISNULL(SalePropertyChangeCode,1)) >= 1 '
EXEC (@sql)
*/

-- https://stackoverflow.com/questions/49531989/setting-a-variable-inside-dynamic-sql
SET @sql = N'SET @EditCount = ( SELECT SUM([Count]) FROM ext_SDFResults );'
EXEC sys.sp_executesql @sql, N'@EditCount FLOAT OUTPUT', @EditCount OUTPUT

IF @EditCount IS NULL
BEGIN;
	SET @EditCount = 0;
END;

SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );


IF ((SELECT COUNT(*) FROM ext_SDFResults) >= 1  AND @IncludeReports = 1)
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_SDFResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


ALTER TABLE ext_SDFResults --> Edit Results
DROP COLUMN [Field], [Count] ;


INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ;


/* ============= -- 11 -- ============= */

SET @EditNumber = '11';
SET @EditDescription = 'Do any sales have a missing or invalid vacant or improvement code?';
SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM extFloridaSDF WHERE NULLIF(VacantOrImprovedCode, '') IS NULL OR VacantOrImprovedCode NOT IN ('I', 'V') ); 
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_SDFResults

INSERT INTO ext_SDFResults
SELECT 
	ParcelNumber 
FROM 
	extFloridaSDF 
WHERE 
	NULLIF(VacantOrImprovedCode, '') IS NULL 
OR 
	VacantOrImprovedCode NOT IN ('I', 'V')


IF ((SELECT COUNT(*) FROM ext_SDFResults) >= 1  AND @IncludeReports = 1)
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_SDFResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


/* ============= -- 12 -- ============= */

SET @EditNumber = '12';
SET @EditDescription = 'Do any sales have a missing or invalid qualification code?';
SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM extFloridaSDF WHERE NULLIF(SaleTransferCode, '') IS NULL OR ISNUMERIC(SaleTransferCode) <> 1 OR SaleTransferCode NOT IN ('01','02','03','04','05','06','11','12','13','14','16','17','18','19','20','21','30','31','32','33','34','35','36','37','38','39','40','41','42','43','98','99') ); 
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_SDFResults

INSERT INTO ext_SDFResults
SELECT 
	ParcelNumber 
FROM 
	extFloridaSDF 
WHERE
	NULLIF(SaleTransferCode, '') IS NULL 
OR 
	ISNUMERIC(SaleTransferCode) <> 1
OR 
	SaleTransferCode NOT IN
	('01','02','03','04','05','06','11','12','13','14','16','17','18','19','20','21','30','31','32','33','34','35','36','37','38','39','40','41','42','43','98','99')


IF ((SELECT COUNT(*) FROM ext_SDFResults) >= 1  AND @IncludeReports = 1)
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_SDFResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


/* ============= -- 13 -- ============= */

SET @EditNumber = '13';
SET @EditDescription = 'Do any sales have an invalid sale property change code?';
SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM extFloridaSDF WHERE (NULLIF(SalePropertyChangeCode, '') IS NOT NULL AND ISNUMERIC(SalePropertyChangeCode) <> 1)  OR (NULLIF(SalePropertyChangeCode, '') IS NOT NULL AND ISNUMERIC(SalePropertyChangeCode) = 1 AND (SalePropertyChangeCode < 1 OR SalePropertyChangeCode > 9)) ); 
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_SDFResults

INSERT INTO ext_SDFResults
SELECT 
	ParcelNumber 
FROM 
	extFloridaSDF 
WHERE 
	(NULLIF(SalePropertyChangeCode, '') IS NOT NULL AND ISNUMERIC(SalePropertyChangeCode) <> 1)  -- not null/blank & not a number
OR 
	(NULLIF(SalePropertyChangeCode, '') IS NOT NULL AND ISNUMERIC(SalePropertyChangeCode) = 1 AND (SalePropertyChangeCode < 1 OR SalePropertyChangeCode > 9))   -- not null/blank and a number less than 1 or greater than 9
  

IF ((SELECT COUNT(*) FROM ext_SDFResults) >= 1 AND @IncludeReports = 1)
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_SDFResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


/* ============= -- 14 -- ============= */

SET @EditNumber = '14';
SET @EditDescription = 'Do any of the sales prior to January 1 [RYR] have sale qualification code 99s? (Greater than 25 require response)';
SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM extFloridaSDF WHERE SaleYear < RollYear AND SaleTransferCode = '99' ); 
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_SDFResults

INSERT INTO ext_SDFResults
SELECT 
	ParcelNumber 
FROM 
	extFloridaSDF 
WHERE 
	SaleYear < RollYear
AND 
	SaleTransferCode = '99' 
  

IF ((SELECT COUNT(*) FROM ext_SDFResults) >= 1 AND @IncludeReports = 1)
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_SDFResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


/* ============= -- 15 -- ============= */

SET @EditNumber = '15';
SET @EditDescription = 'Are there any sale qualification code 41s? (The use of qual code 41 requires the Department''s prior approval)';
SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM extFloridaSDF WHERE SaleTransferCode = '41' );
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_SDFResults

INSERT INTO ext_SDFResults
SELECT 
	ParcelNumber 
FROM 
	extFloridaSDF 
WHERE 
	SaleTransferCode = '41'
  

IF ((SELECT COUNT(*) FROM ext_SDFResults) >= 1 AND @IncludeReports = 1)
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_SDFResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


/* ============= -- 16 -- ============= */

SET @EditNumber = '16';
SET @EditDescription = 'Is the sale property change code field completely blank?';

TRUNCATE TABLE ext_SDFResults

;WITH IsChangeCodeFieldBlank AS
(
SELECT COUNT(SalePropertyChangeCode) [TotalEmpty], @TotalCount [TotalRows]
FROM extFloridaSDF
WHERE NULLIF(SalePropertyChangeCode,'') IS NULL
)

INSERT INTO ext_SDFResults
SELECT COUNT(*) FROM IsChangeCodeFieldBlank
WHERE TotalEmpty = TotalRows


SET @EditCount = ( SELECT ParcelNumber FROM ext_SDFResults ); -- results will be either 1 or 0
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( IIF(@YesNo = 'Yes', 100, 0) );
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;
  
/* -- Don't ever need to export results after changing this edit check, it's either FailedCheck if the field is completely blank and the information provided in summary report is enough --
IF ((SELECT COUNT(*) FROM ext_SDFResults) >= 1 AND @IncludeReports = 1)
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_SDFResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END
*/

INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


/* ============= -- 17 -- ============= */

SET @EditNumber = '17';
SET @EditDescription = 'Do any sales have a sale property change code of 6? (Other - Explanation Required)';
SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM extFloridaSDF WHERE SalePropertyChangeCode = '6' );
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_SDFResults

INSERT INTO ext_SDFResults
SELECT 
	ParcelNumber 
FROM 
	extFloridaSDF 
WHERE 
	SalePropertyChangeCode = '6'
  

IF ((SELECT COUNT(*) FROM ext_SDFResults) >= 1 AND @IncludeReports = 1)
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_SDFResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


/* ============= -- 18 -- ============= */

SET @EditNumber = '18';
SET @EditDescription = 'Are the sale property change codes used correctly according to the sample researched? ';


INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , NULL , NULL , NULL , NULL ) ; 


/* ============= -- 19 -- ============= */

SET @EditNumber = '19';
SET @EditDescription = 'Do any multi-parcel sale transactions have a sale price that is split between the parcels involved in the transaction?';

TRUNCATE TABLE ext_SDFResults

BEGIN TRY

;WITH SDF_Edit_19 AS
(
SELECT SaleIdentificationCode, SUM(CAST(SalePrice AS INT)) / COUNT(SaleIdentificationCode) [Total]
FROM extFloridaSDF
WHERE 1=1
GROUP BY SaleIdentificationCode
)


INSERT INTO ext_SDFResults
SELECT 
	ParcelNumber 
FROM
	SDF_Edit_19 e
JOIN 
	(SELECT ParcelNumber, SaleIdentificationCode, SalePrice FROM extFloridaSDF GROUP BY ParcelNumber, SaleIdentificationCode, SalePrice) f ON f.SaleIdentificationCode = e.SaleIdentificationCode
WHERE
	f.SalePrice <> e.Total

SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM ext_SDFResults);
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;


IF ((SELECT COUNT(*) FROM ext_SDFResults) >= 1 AND @IncludeReports = 1)
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_SDFResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 

END TRY
BEGIN CATCH

INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , NULL , NULL , NULL , error_message() ) ; 

END CATCH

/* ============= -- 20 -- ============= */

SET @EditNumber = '20';
SET @EditDescription = 'Do any sales in a specific use code indicate a discounted sale price before the application of 8th criterion?';

INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , NULL , NULL , NULL , NULL ) ; 


/* ============= -- 21 -- ============= */

SET @EditNumber = '21';
SET @EditDescription = 'Do any sale qualification codes 01 or 02 have a sale property change code 1, 2, 5, 6, 7 or 8?';
SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM extFloridaSDF WHERE SaleTransferCode IN ('01','02') AND SalePropertyChangeCode IN ('1', '2', '5', '6', '7', '8') );
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_SDFResults

INSERT INTO ext_SDFResults
SELECT 
	ParcelNumber
FROM
	extFloridaSDF
WHERE
	SaleTransferCode IN ('01','02')
AND
	SalePropertyChangeCode IN ('1', '2', '5', '6', '7', '8')
	

IF ((SELECT COUNT(*) FROM ext_SDFResults) >= 1 AND @IncludeReports = 1)
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_SDFResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


/* ============= -- 22 -- ============= */

SET @EditNumber = '22';
SET @EditDescription = 'Are there any sale qualification codes 03 that do NOT have a sale property change code?';
SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM extFloridaSDF WHERE NULLIF(SalePropertyChangeCode, '') IS NULL AND SaleTransferCode = '03' );
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_SDFResults

INSERT INTO ext_SDFResults
SELECT 
	ParcelNumber 
FROM 
	extFloridaSDF 
WHERE 
	NULLIF(SalePropertyChangeCode, '') IS NULL
AND
	SaleTransferCode = '03' -- 03 qual code always needs a change code
  

IF ((SELECT COUNT(*) FROM ext_SDFResults) >= 1 AND @IncludeReports = 1)
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_SDFResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


/* ============= -- 23 -- ============= */

SET @EditNumber = '23';
SET @EditDescription = 'Are any sale months not represented in the current year up to the current submission?';

TRUNCATE TABLE ext_SDFResults

DECLARE @currentMonth SMALLINT;

IF @YearID = (SELECT YearID FROM xrYearColor WHERE IsCurrentFlag = 1 GROUP BY YearID) -- If RollYear = Active AP5 year, get current month. Else (its the previous year) and set month to 12. --
BEGIN;
	SET @currentMonth = (MONTH(GetDate()));
END;
ELSE
BEGIN;
	SET @currentMonth = 12;
END;

DECLARE @Months TABLE (MonthNumber VARCHAR(4));

WHILE @CurrentMonth > 0
BEGIN
	INSERT INTO @Months
	VALUES (@CurrentMonth)
	SET @currentMonth = @currentMonth - 1
END

--SELECT * FROM @Months

INSERT INTO ext_SDFResults
SELECT 
	CONCAT('Month Number: ',m.MonthNumber)
FROM 
	@Months m 
LEFT JOIN 
	(SELECT SaleMonth FROM extFloridaSDF WHERE SaleYear = @YearID) s ON CAST(m.MonthNumber AS SMALLINT) = CAST(s.SaleMonth AS SMALLINT)
WHERE
	NULLIF(SaleMonth, '') IS NULL
GROUP BY
	m.MonthNumber

SET @EditCount = ( ISNULL((SELECT COUNT(ParcelNumber) FROM dbo.ext_SDFResults),0) );
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / 12 );
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;


IF ((SELECT COUNT(*) FROM ext_SDFResults) >= 1 AND @IncludeReports = 1)
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_SDFResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


/* ============= -- 24 -- ============= */

SET @EditNumber = '24';
SET @EditDescription = 'Are any records of sales in the current year greater than the current month?';
SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM extFloridaSDF WHERE SaleYear = @YearID AND CAST(SaleMonth AS SMALLINT) > (SELECT MAX(CAST(MonthNumber As SMALLINT)) FROM @Months) );
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_SDFResults

INSERT INTO ext_SDFResults
SELECT 
	ParcelNumber
FROM 
	extFloridaSDF
WHERE 
	SaleYear = @YearID
AND 
	CAST(SaleMonth AS SMALLINT) > (SELECT MAX(CAST(MonthNumber As SMALLINT)) FROM @Months)


IF ((SELECT COUNT(*) FROM ext_SDFResults) >= 1 AND @IncludeReports = 1)
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_SDFResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


/* ============= -- 25 -- ============= */

SET @EditNumber = '25';
SET @EditDescription = 'Are any sale months not represented in the prior year?';
SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM extFloridaSDF WHERE SaleYear = (@YearID - 1) AND SaleMonth NOT IN ('01','02','03','04','05','06','07','08','09','10','11','12') );
SET @YesNo = (IIF(@EditCount > 0,'Yes','No'));
SET @Percentage = ( @EditCount / @TotalCount );
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

TRUNCATE TABLE ext_SDFResults

INSERT INTO ext_SDFResults
SELECT 
	ParcelNumber 
FROM 
	extFloridaSDF 
WHERE 
	SaleYear = (@YearID - 1)
AND 
	SaleMonth NOT IN ('01','02','03','04','05','06','07','08','09','10','11','12')


IF ((SELECT COUNT(*) FROM ext_SDFResults) >= 1 AND @IncludeReports = 1)
BEGIN
	SET @Report = CONCAT(@EditNumber, @Extension);

	EXEC [dbo].[ext_ExportDataToCsv] @dbName = @Database,
							 @includeHeaders = 1,
							 @filePath = @ExportPath,
							 @tableName = 'ext_SDFResults',
							 @reportName =	@Report,
							 @delimiter = '|';

	SET @ReportPath = CONCAT(@ExportPath,'\',@Report);

END


INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , @Percentage , @YesNo , @EditCount , @ReportPath ) ; 


/* ============= -- Totals -- ============= */

SET @EditNumber = 'Totals';

SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM extFloridaSDF );
SET @EditDescription = CONCAT('Total Sale Count: ',@EditCount);

INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , NULL , NULL , NULL, NULL ) ; 

SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM extFloridaSDF WHERE SaleYear = (@YearID - 1) );
SET @EditDescription = CONCAT(' >> Prior Year Sale Count: ', @EditCount);

INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , NULL , NULL , NULL, NULL ) ; 

SET @EditCount = ( SELECT COUNT(ParcelNumber) FROM extFloridaSDF WHERE SaleYear = @YearID );
SET @EditDescription = CONCAT(' >> Roll Year Sale Count: ', @EditCount);

INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , NULL , NULL , NULL, NULL ) ; 

/* ========================== */

SET @EditCount = (SELECT COUNT(SalePropertyChangeCode) FROM extFloridaSDF WHERE NULLIF(SalePropertyChangeCode,'') IS NOT NULL);

SET @EditDescription = CONCAT('Total Sale Prop. Change Codes: ',@EditCount);

INSERT INTO  @SDF_Edits ([Edit_Number], [Edit_Desc], [Percentage], [FailedCheck], [Edit_Count], [PathToResults] )
VALUES ( @EditNumber , @EditDescription , NULL , NULL , NULL, NULL ) ; 


/* ========================== 
Export Final SDF Results
 ========================== */

DROP TABLE IF EXISTS ##sdf_results;
IF @ReportPath IS NOT NULL SET @ReportPath = NULL;

SET @ReportPath = CONCAT(@ExportPath,'\');
SET @Report = 'SDF_Edit_Check_Results.csv';

DECLARE @sdfCount SMALLINT = (SELECT COUNT(*) + 1 FROM @SDF_Edits);

SELECT * 
INTO ##sdf_results
FROM @SDF_Edits --> Edit Report

EXEC [dbo].[ext_ExportDataToCsv] @dbName = 'tempdb',
							 @includeHeaders = 1,
							 @filePath = @ReportPath,
							 @tableName = '##sdf_results',
							 @reportName = @Report,
							 @delimiter = '|';

SET @ReportPath = CONCAT(@ReportPath,@Report);
SET @ExportPath = REPLACE(@ReportPath, 'csv', 'xlsx');

EXEC [dbo].[CSVtoXLSXwTable] @fullCsvPath = @ReportPath , @fullXlsxPath = @ExportPath , @rowCount = @sdfCount, @colCharacter = 'F';

DROP TABLE IF EXISTS ##sdf_results;

IF OBJECT_ID('dbo.ext_SDFResults') IS NOT NULL 
BEGIN;
	DROP TABLE ext_SDFResults ;
END;

END