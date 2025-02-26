use DWH_DATA_ANALYST
SELECT DISTINCT * INTO DimViolationsFine FROM DimFine;
ALTER TABLE FactParkingViolation ALTER COLUMN VIOLATIONCODE int ;
ALTER TABLE DimViolationsFine ALTER COLUMN VIOLATION_CODE int NOT NULL;
ALTER TABLE DimViolationsFine ADD CONSTRAINT PK_DimViolations_ViolationCode PRIMARY KEY CLUSTERED (VIOLATION_CODE);
-- rename the name of the columns
EXEC DWH_DATA_ANALYST.sys.sp_rename N'DWH_DATA_ANALYST.dbo.DimViolationsFine.VIOLATION_CODE' , N'ViolationKey', 'COLUMN';
drop table dimFine
