-- SQL

SELECT  top(5) 
COUNT(vft.ParkingViolationKey) AS  NumberOfTickets
       ,dc.ColorName ,dc.ColorCode 
FROM VU_FactTableFor2015To2017 vft 
	JOIN DimColor dc
         ON dc.ColorCode = vft.VehicleColorCode
GROUP BY  dc.ColorCode,dc.ColorName 
ORDER BY   NumberOfTickets DESC


GO
-- STORED PROCEDURE
alter PROCEDURE GetTopParkingViolationsByColor
     @TopNumber INT = 0 -- Default is 0, meaning no limit , 
                       -- IF WE EXECUTE IT WITHOUT PARAMETER THE SAME AS 0 
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SQL NVARCHAR(MAX);

    -- create DYNAMIC SQL 
    SET @SQL = 
        'SELECT ' +
          CASE WHEN @TopNumber > 0         
            THEN
              'TOP (' + CAST(@TopNumber AS NVARCHAR) + ') ' 
            ELSE 
               ''
          END +
              'COUNT(vft.ParkingViolationKey) AS  NumberOfTickets
                     ,dc.ColorName,dc.ColorCode 
              FROM VU_FactTableFor2015To2017 vft 
                     JOIN DimColor dc 
                            ON dc.ColorCode = vft.VehicleColorCode

              GROUP BY  dc.ColorCode 
                     ,dc.ColorName
              ORDER BY   NumberOfTickets DESC';

    -- Execute the DYNAMIC SQL
    EXEC sp_executesql @SQL;
END; 

go 

exec GetTopParkingViolationsByColor;