-- DROP SCHEMA dbo;

CREATE SCHEMA dbo;
-- DWH_DATA_ANALYST.dbo.DimBodyType definition

-- Drop table

-- DROP TABLE DWH_DATA_ANALYST.dbo.DimBodyType;

CREATE TABLE DimBodyType (
	BodyTypeCode varchar(5) COLLATE Hebrew_CI_AS NOT NULL,
	BodyTypeName varchar(40) COLLATE Hebrew_CI_AS NULL,
	CONSTRAINT PK_BodyTypeCode PRIMARY KEY (BodyTypeCode)
);


-- DWH_DATA_ANALYST.dbo.DimBorough definition

-- Drop table

-- DROP TABLE DWH_DATA_ANALYST.dbo.DimBorough;

CREATE TABLE DimBorough (
	BoroughCode varchar(2) COLLATE Hebrew_CI_AS NOT NULL,
	BoroughName varchar(20) COLLATE Hebrew_CI_AS NULL,
	CONSTRAINT PK_BoroughCode PRIMARY KEY (BoroughCode)
);


-- DWH_DATA_ANALYST.dbo.DimColor definition

-- Drop table

-- DROP TABLE DWH_DATA_ANALYST.dbo.DimColor;

CREATE TABLE DimColor (
	ColorCode varchar(10) COLLATE Hebrew_CI_AS NOT NULL,
	ColorName varchar(40) COLLATE Hebrew_CI_AS NULL,
	CONSTRAINT PK_ColorCode PRIMARY KEY (ColorCode)
);


-- DWH_DATA_ANALYST.dbo.DimIssuer definition

-- Drop table

-- DROP TABLE DWH_DATA_ANALYST.dbo.DimIssuer;

CREATE TABLE DimIssuer (
	IssuerKey int NOT NULL,
	IssuerID varchar(20) COLLATE Hebrew_CI_AS NULL,
	IssuingAgencyCode varchar(5) COLLATE Hebrew_CI_AS NULL,
	CONSTRAINT PK_issuerKey PRIMARY KEY (IssuerKey)
);


-- DWH_DATA_ANALYST.dbo.DimIssuingAgency definition

-- Drop table

-- DROP TABLE DWH_DATA_ANALYST.dbo.DimIssuingAgency;

CREATE TABLE DimIssuingAgency (
	IssuingAgencyCode varchar(5) COLLATE Hebrew_CI_AS NOT NULL,
	IssuingAgencyName varchar(100) COLLATE Hebrew_CI_AS NULL,
	IssuingAgencyAverageYearlySalary money NULL,
	CONSTRAINT PK_IssuingAgencyCode PRIMARY KEY (IssuingAgencyCode)
);


-- DWH_DATA_ANALYST.dbo.DimLocation definition

-- Drop table

-- DROP TABLE DWH_DATA_ANALYST.dbo.DimLocation;

CREATE TABLE DimLocation (
	LocationKey int NOT NULL,
	BoroughCode varchar(2) COLLATE Hebrew_CI_AS NULL,
	StreetCode varchar(10) COLLATE Hebrew_CI_AS NULL,
	StreetName varchar(20) COLLATE Hebrew_CI_AS NULL,
	HouseNumber varchar(20) COLLATE Hebrew_CI_AS NULL,
	City varchar(20) COLLATE Hebrew_CI_AS NULL,
	StateCode varchar(2) COLLATE Hebrew_CI_AS NULL,
	CONSTRAINT PK_LocationKey PRIMARY KEY (LocationKey)
);


-- DWH_DATA_ANALYST.dbo.DimPlateType definition

-- Drop table

-- DROP TABLE DWH_DATA_ANALYST.dbo.DimPlateType;

CREATE TABLE DimPlateType (
	PlateTypeCode varchar(3) COLLATE Hebrew_CI_AS NOT NULL,
	PlateTypeName varchar(40) COLLATE Hebrew_CI_AS NULL,
	CONSTRAINT PK_PlateTypeCode PRIMARY KEY (PlateTypeCode)
);


-- DWH_DATA_ANALYST.dbo.DimState definition

-- Drop table

-- DROP TABLE DWH_DATA_ANALYST.dbo.DimState;

CREATE TABLE DimState (
	StateCode varchar(2) COLLATE Hebrew_CI_AS NOT NULL,
	StateName varchar(40) COLLATE Hebrew_CI_AS NULL,
	CONSTRAINT PK_StateCode PRIMARY KEY (StateCode)
);


-- DWH_DATA_ANALYST.dbo.DimVehicle definition

-- Drop table

-- DROP TABLE DWH_DATA_ANALYST.dbo.DimVehicle;

CREATE TABLE DimVehicle (
	VehicleKey int NOT NULL,
	PlateID varchar(10) COLLATE Hebrew_CI_AS NULL,
	RegistrationStateCode varchar(2) COLLATE Hebrew_CI_AS NULL,
	PlateTypeCode varchar(3) COLLATE Hebrew_CI_AS NULL,
	BodyTypeCode varchar(5) COLLATE Hebrew_CI_AS NULL,
	BodyMakeName varchar(5) COLLATE Hebrew_CI_AS NULL,
	VehicleColorCode varchar(10) COLLATE Hebrew_CI_AS NULL,
	vehicleYear varchar(4) COLLATE Hebrew_CI_AS NULL,
	ExpirationDate varchar(8) COLLATE Hebrew_CI_AS NULL,
	CONSTRAINT PK_VehicleKey PRIMARY KEY (VehicleKey)
);


-- DWH_DATA_ANALYST.dbo.DimViolationsFine definition

-- Drop table

-- DROP TABLE DWH_DATA_ANALYST.dbo.DimViolationsFine;

CREATE TABLE DimViolationsFine (
	ViolationKey int NOT NULL,
	ViolationDescription nvarchar(255) COLLATE Hebrew_CI_AS NULL,
	FineAmountUSDManhattan96 float NULL,
	FineAmountUSD float NULL,
	CONSTRAINT PK_DimViolations_ViolationCode PRIMARY KEY (ViolationKey)
);


-- DWH_DATA_ANALYST.dbo.FactParkingViolation definition

-- Drop table

-- DROP TABLE DWH_DATA_ANALYST.dbo.FactParkingViolation;

CREATE TABLE FactParkingViolation (
	ParkingViolationKey int IDENTITY(1,1) NOT NULL,
	SummonsNumber varchar(50) COLLATE Hebrew_CI_AS NULL,
	IssueDate varchar(50) COLLATE Hebrew_CI_AS NULL,
	ViolationCode int NULL,
	ViolationTime varchar(50) COLLATE Hebrew_CI_AS NULL,
	ViolationInFrontOfOrOpposite varchar(50) COLLATE Hebrew_CI_AS NULL,
	VehicleKey int NULL,
	IssuerKey int NULL,
	LocationKey int NULL,
	CONSTRAINT PK_ParkingViolationKey PRIMARY KEY (ParkingViolationKey)
);


-- dbo.VU_AGR_Between2015To2017ByBorough source

create view VU_AGR_Between2015To2017ByBorough as   
WITH
    year_data_cte
    AS
    (
        SELECT
            COUNT(vft.ParkingViolationKey) AS  NumberOfTickets,
            db.BoroughCode AS BoroughCode,
            db.BoroughName AS Borough,
            YEAR(vft.ViolationDate) AS Year


        FROM
            VU_FactTableFor2015To2017 vft
            Join 
                DimBorough db ON db.BoroughCode = vft.BoroughCode
        GROUP BY 
         db.BoroughCode, db.BoroughName  , YEAR(vft.ViolationDate)
    )
SELECT
    Borough,
    BoroughCode, 
    Value2015,
    Value2016,
    Value2017,
    CASE 
        WHEN value2015 IS NOT NULL AND value2015 != 0 THEN 
            ((value2017 - value2015) * 100.0 / value2015) 
        ELSE 
            NULL 
    END AS PercentageChange
FROM (
    SELECT
        borough,
        BoroughCode, 
        NumberOfTickets,
        -- Get values for each year
        MAX(CASE WHEN year = 2015 THEN NumberOfTickets END) OVER (PARTITION BY borough) AS value2015,
        MAX(CASE WHEN year = 2016 THEN NumberOfTickets END) OVER (PARTITION BY borough) AS value2016,
        MAX(CASE WHEN year = 2017 THEN NumberOfTickets END) OVER (PARTITION BY borough) AS value2017
    FROM year_data_cte
) AS ranked_data
GROUP BY BoroughCode, borough, value2015, value2016, value2017;


-- dbo.VU_AGR_Between2015To2017ByRegistrationState source

create  VIEW VU_AGR_Between2015To2017ByRegistrationState AS
WITH
    year_data_cte
    AS
    (
        SELECT
            ds.StateCode,
            ds.StateName AS State,
            COUNT(vft.ParkingViolationKey) AS NumberOfTickets,
            YEAR(vft.ViolationDate) AS Year
        FROM
            VU_FactTableFor2015To2017 vft
            JOIN
            DimState ds ON vft.RegistrationStateCode = ds.StateCode
        GROUP BY 
        ds.StateCode,ds.StateName, YEAR(vft.ViolationDate)
    )
SELECT
    StateCode,
    State,
    Value2015,
    Value2016,
    Value2017,
    CASE 
        WHEN value2015 IS NOT NULL AND value2015 != 0 THEN 
            ((value2017 - value2015) * 100.0 / value2015) 
        ELSE 
            NULL 
    END AS PercentageChange
FROM (
    SELECT
        StateCode,
        state,
        NumberOfTickets,
        -- Get values for each year
        MAX(CASE WHEN year = 2015 THEN NumberOfTickets END) OVER (PARTITION BY state) AS value2015,
        MAX(CASE WHEN year = 2016 THEN NumberOfTickets END) OVER (PARTITION BY state) AS value2016,
        MAX(CASE WHEN year = 2017 THEN NumberOfTickets END) OVER (PARTITION BY state) AS value2017
    FROM year_data_cte
) AS ranked_data
GROUP BY StateCode,State, value2015, value2016, value2017;


-- dbo.VU_AGR_Between2015To2017ByViolation source

create  view VU_AGR_Between2015To2017ByViolation as 
WITH
    year_data_cte
    AS
    (
        SELECT
            vft.ViolationCode as ViolationCode ,
            dvf.ViolationDescription AS Violation,
            COUNT(vft.ParkingViolationKey) AS NumberOfTickets,
            YEAR(vft.ViolationDate) AS Year
        FROM
            VU_FactTableFor2015To2017 vft
            JOIN
                DimViolationsFine dvf ON dvf.ViolationKey = vft.ViolationCode
        GROUP BY 
        vft.ViolationCode , dvf.ViolationDescription  , YEAR(vft.ViolationDate)
    )
SELECT
    ViolationCode,
    Violation,
    Value2015,
    Value2016,
    Value2017,
    CASE 
        WHEN value2015 IS NOT NULL AND value2015 != 0 THEN 
            ((value2017 - value2015) * 100.0 / value2015) 
        ELSE 
            NULL 
    END AS PercentageChange
    
FROM (
    SELECT
        ViolationCode,
        violation,
        NumberOfTickets,
        -- Get values for each year
        MAX(CASE WHEN year = 2015 THEN NumberOfTickets END) OVER (PARTITION BY violation) AS value2015,
        MAX(CASE WHEN year = 2016 THEN NumberOfTickets END) OVER (PARTITION BY violation) AS value2016,
        MAX(CASE WHEN year = 2017 THEN NumberOfTickets END) OVER (PARTITION BY violation) AS value2017
    FROM year_data_cte
) AS ranked_data
--where violation like 'A%'
GROUP BY ViolationCode , violation, value2015, value2016, value2017;


-- dbo.VU_DimLocationCelan source

-- dbo.NewView source

CREATE VIEW dbo.VU_DimLocationCelan AS
  SELECT LocationKey, BoroughCode, StreetCode, StreetName, HouseNumber, City, StateCode
    FROM DWH_DATA_ANALYST.dbo.DimLocation 
    WHERE BoroughCode<>99 --99=unknown borough
    ;


-- dbo.VU_FactTableFor2015To2017 source

-- dbo.VU_FactTableFor2015To2017 source

-- dbo.VU_FactTableFor2015To2017 source

-- dbo.VU_FactTableFor2015To2017 source

-- dbo.VU_FactTableFor2015To2017 source

CREATE VIEW dbo.VU_FactTableFor2015To2017
AS    
SELECT ParkingViolationKey
       , SummonsNumber
       , CAST(fpv.IssueDate AS DATE) AS ViolationDate
       , TRY_CAST(
                     LEFT(fpv.ViolationTime, 2) + ':' + SUBSTRING(ViolationTime, 3, 2) + 
                      ' ' + 
                      CASE 
                             WHEN RIGHT(fpv.ViolationTime, 1) = 'A' THEN 'AM'
                             WHEN RIGHT(fpv.ViolationTime, 1) = 'P' THEN 'PM'
                      END 
              AS TIME) AS ViolationTime       
       -- ,CAST(IssueDate AS DATETIME) + 
       --               COALESCE(
       --        TRY_CAST(
       --        STUFF(LEFT(ViolationTime, 4), 3, 0, ':') + -- Insert ":" at position 3
       --        ' ' + 
       --        CASE 
       --               WHEN RIGHT(ViolationTime, 1) = 'A' THEN 'AM'
       --               WHEN RIGHT(ViolationTime, 1) = 'P' THEN 'PM'
       --        END 
       --        AS datetime), 
       --        '1900-01-01 00:00:00'  -- Default invalid values to 00:00 AM
       -- ) AS ViolationDateTime
       , fpv.ViolationCode
       , fpv.ViolationInFrontOfOrOpposite
       , fpv.IssuerKey
       , fpv.LocationKey
       , vdlc.BoroughCode   
       , dv.VehicleKey
       , dv.PlateID
       , dv.VehicleColorCode      
       , dv.RegistrationStateCode
       , dv.BodyTypeCode
       , dv.BodyMakeName  as BodyMakeCode
       , dv.plateTypeCode       
       , di.issuingAgencyCode
    FROM FactParkingViolation fpv  
	join VU_DimLocationCelan vdlc on vdlc.LocationKey = fpv.LocationKey	
       join DimVehicle dv on dv.VehicleKey = fpv.VehicleKey
          left join DimIssuer di  on  di.IssuerKey = fpv.IssuerKey
WHERE YEAR(CAST(fpv.IssueDate AS DATE)) BETWEEN 2015 AND 2017
              --and dv.VehicleColorCode <> 'UNK';
;


-- dbo.VU_FactViolationRecurrence source

-- dbo.VU_FactViolationRecurrece source

-- dbo.NewView source

CREATE VIEW dbo.VU_FactViolationRecurrence AS
 		select vft.VehicleKey ,
				count(vft.ParkingViolationKey) as NumberOfTickets , 
				vft.RegistrationStateCode as State ,
				vft.BoroughCode ,vft.ViolationCode,
				case
					when count(vft.ParkingViolationKey) > 9 then '3' 
					when count(vft.ParkingViolationKey) > 4 then '2' 
					else '1'  
    			end   as RecurrenceClassificationCode,
    			cast (year(vft.ViolationDate) as varchar(4) ) as year
    			from VU_FactTableFor2015To2017 vft  
				group by vft.VehicleKey, year(vft.ViolationDate) , vft.RegistrationStateCode	, vft.BoroughCode,vft.ViolationCode;


-- dbo.VU_TicketsBetween2015To2017ByBorough source

CREATE view VU_TicketsBetween2015To2017ByBorough as   
        SELECT
            COUNT(vft.ParkingViolationKey) AS NumberOfTickets,
            db.BoroughName AS Bborough,
            db.BoroughCode AS BoroughCode,
            YEAR(vft.ViolationDate) AS Year
        FROM
            VU_FactTableFor2015To2017 vft
            Join 
                DimBorough db ON db.BoroughCode = vft.BoroughCode
        GROUP BY 
        db.BoroughCode , db.BoroughName  , YEAR(vft.ViolationDate);


-- dbo.VU_TicketsBetween2015To2017ByState source

-- dbo.VU_TicketsBetween2015To2017ByState source

CREATE view VU_TicketsBetween2015To2017ByState as 
        SELECT
            COUNT(vft.ParkingViolationKey) AS NumberOftickets,
            ds.StateCode,
            ds.StateName AS state,
            YEAR(vft.ViolationDate) AS Year ,
            DATENAME(WEEKDAY, vft.ViolationDate) AS DayName,
            DATEPART(WEEKDAY, vft.ViolationDate) AS DayNumber
        FROM
            VU_FactTableFor2015To2017 vft
            JOIN
            DimState ds ON vft.RegistrationStateCode = ds.StateCode
        GROUP BY 
           ds.StateCode,ds.StateName, YEAR(vft.ViolationDate), DATENAME(WEEKDAY, vft.ViolationDate)  ,
            DATEPART(WEEKDAY, vft.ViolationDate);


-- dbo.VU_TicketsBetween2015To2017ByViolation source

-- dbo.VU_TicketsBetween2015To2017ByViolation source

CREATE view VU_TicketsBetween2015To2017ByViolation as
        SELECT
            COUNT(vft.ParkingViolationKey) AS NumberOfTickets,
            vft.ViolationCode AS ViolationCode,
            dvf.violationDescription AS Violation,
            YEAR(vft.ViolationDate) AS Year,
            DATENAME(WEEKDAY, vft.ViolationDate) AS DayName,
            DATEPART(WEEKDAY, vft.ViolationDate) AS DayNumber
        FROM
            VU_FactTableFor2015To2017 vft
            JOIN
            DimViolationsFine dvf ON dvf.ViolationKey = vft.ViolationCode
        GROUP BY 
            vft.ViolationCode , dvf.ViolationDescription  , YEAR(vft.ViolationDate),
            DATENAME(WEEKDAY, vft.ViolationDate)  ,
            DATEPART(WEEKDAY, vft.ViolationDate);


-- dbo.VU_ViolationRecurrenceByYear source

-- dbo.VU_ViolationRecurrenceByYear source

CREATE VIEW dbo.VU_ViolationRecurrenceByYear AS					
		select vft.VehicleKey ,
				count(vft.ParkingViolationKey) as NumberOfTickets , 
				case
					when count(vft.ParkingViolationKey) > 9 then '3' 
					when count(vft.ParkingViolationKey) > 4 then '2' 
					else '1'  
		end   as RecurrenceClassificationCode,
				cast (year(vft.ViolationDate) as varchar(4) ) as year
				from VU_FactTableFor2015To2017 vft  
				group by vft.VehicleKey, year(vft.ViolationDate);


-- dbo.VU_ViolationsRecurrenceByVehicle source

-- dbo.VU_ViolationsRecurrenceByVehicle source

CREATE VIEW VU_ViolationsRecurrenceByVehicle AS
	with parking_violations_cte (VehicleKey,NumberOfTickets,RecurrenceClassificationCode) 
	AS 
		(select vft.VehicleKey ,
		count(vft.ParkingViolationKey) as NumberOfTickets , 
		case
					when count(vft.ParkingViolationKey) > 9 then '3' 
					when count(vft.ParkingViolationKey) > 4 then '2' 
					else '1'  
		end   as RecurrenceClassificationCode
		
		from VU_FactTableFor2015To2017 vft  
		group by vft.VehicleKey
		)		
	select count(vehiclekey) as NumberOfTickets, RecurrenceClassificationCode
	from parking_violations_cte
	group by RecurrenceClassificationCode;