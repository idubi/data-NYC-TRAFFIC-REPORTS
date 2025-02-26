-- SQL
SELECT   vft.BoroughCode   , BoroughName,
			DATENAME(WEEKDAY, vft.ViolationDate) AS DayName,
			count(vft.ParkingViolationKey) AS  NumberOfTickets	,					  
			DATEPART(WEEKDAY, vft.ViolationDate) AS DayNumber	 	 
FROM DimBorough db
			JOIN VU_FactTableFor2015To2017 vft 
				ON db.BoroughCode = vft.BoroughCode        
GROUP BY vft.BoroughCode , BoroughName,
	DATENAME(WEEKDAY, vft.ViolationDate) ,
    DATEPART(WEEKDAY, vft.ViolationDate)
    
ORDER BY BoroughName,
	DATEPART(WEEKDAY, vft.ViolationDate) -- number of day


GO
-- STORED PROCEDURE
ALTER PROCEDURE GetParkingViolationCountsForBoroughAndDayOfWeek
    @Day NVARCHAR(50) = NULL,       -- Day name parameter (e.g., 'Monday')
    @Borough NVARCHAR(255) = NULL  -- Borough name parameter (e.g., 'Manhattan')
AS
select BoroughCode, BoroughName, DayName ,  NumberOfTickets , DayNumber 
	from (
			SELECT vft.BoroughCode, BoroughName,
						DATENAME(WEEKDAY, vft.ViolationDate) AS DayName,
						DATEPART(WEEKDAY, vft.ViolationDate) AS DayNumber,
						count(vft.ParkingViolationKey) AS  NumberOfTickets						  

			FROM DimBorough db
						JOIN VU_FactTableFor2015To2017 vft 
                           ON db.BoroughCode = vft.BoroughCode  
			GROUP BY vft.BoroughCode,BoroughName,
				DATENAME(WEEKDAY, vft.ViolationDate) ,
			    DATEPART(WEEKDAY, vft.ViolationDate)
				)  sql4DayAndBoroughName
	where (@Borough is null or sql4DayAndBoroughName.BoroughName = lower(@Borough))
      and (@Day is null or sql4DayAndBoroughName.DayName = lower(@Day))   

ORDER BY BoroughName,
  DayNumber-- number of day

go 

exec GetParkingViolationCountsForBoroughAndDayOfWeek @borough=bronx
