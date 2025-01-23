-- SQL
SELECT BoroughName,
			DATENAME(WEEKDAY, vftft.ViolationDateTime) AS DayName,
			count(vftft.ParkingViolationKey) AS #tickets	,					  
			DATEPART(WEEKDAY, vftft.ViolationDateTime) AS DayNumber	 	 
			
FROM DimBorough db
			JOIN VU_DimLocationCelan vdlc 
				ON vdlc.BoroughCode = db.BoroughCode
			JOIN VU_FactTableFor2015To2017 vftft 
				ON vftft.LocationKey = vdlc.LocationKey
GROUP BY BoroughName,
	DATENAME(WEEKDAY, vftft.ViolationDateTime) ,
    DATEPART(WEEKDAY, vftft.ViolationDateTime)
    
ORDER BY BoroughName,
	DATEPART(WEEKDAY, vftft.ViolationDateTime) -- number of day


GO
-- STORED PROCEDURE
ALTER PROCEDURE GetParkingViolationCountsForBoroughAndDayOfWeek
    @Day NVARCHAR(50) = NULL,       -- Day name parameter (e.g., 'Monday')
    @Borough NVARCHAR(255) = NULL  -- Borough name parameter (e.g., 'Manhattan')
AS

select BoroughName, DayName , #tickets , DayNumber 
	from (
			SELECT BoroughName,
						DATENAME(WEEKDAY, vftft.ViolationDateTime) AS DayName,
						DATEPART(WEEKDAY, vftft.ViolationDateTime) AS DayNumber,
						count(vftft.ParkingViolationKey) AS #tickets						  

			FROM DimBorough db
						JOIN VU_DimLocationCelan vdlc 
							ON vdlc.BoroughCode = db.BoroughCode
						JOIN VU_FactTableFor2015To2017 vftft 
							ON vftft.LocationKey = vdlc.LocationKey
			GROUP BY BoroughName,
				DATENAME(WEEKDAY, vftft.ViolationDateTime) ,
			    DATEPART(WEEKDAY, vftft.ViolationDateTime)
				)  sql4DayAndBoroughName
	where (@Borough is null or sql4DayAndBoroughName.BoroughName like lower(@Borough)+'%')
      and (@Day is null or sql4DayAndBoroughName.DayName like lower(@Day)+'%')   

ORDER BY BoroughName,
  DayNumber-- number of day