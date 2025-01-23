-- SQL

SELECT  top(5) 
COUNT(vftft.ParkingViolationKey) AS count#
       ,dc.ColorName
FROM VU_FactTableFor2015To2017 vftft 
	JOIN DimVehicle dv
		ON vftft.VehicleKey = dv.VehicleKey
	JOIN DimColor dc
		ON dc.ColorCode = dv.VehicleColorCode
WHERE dv.VehicleColorCode <> 'UNK'
GROUP BY  dv.VehicleColorCode
         ,dc.ColorName
ORDER BY  count# DESC


GO
-- STORED PROCEDURE
CREATE PROCEDURE GetTopParkingViolationsByColor
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
              'COUNT(vftft.ParkingViolationKey) AS count#
                     ,dc.ColorName
              FROM VU_FactTableFor2015To2017 vftft 
                     JOIN DimVehicle dv
                            ON vftft.VehicleKey = dv.VehicleKey
                     JOIN DimColor dc
                            ON dc.ColorCode = dv.VehicleColorCode
              WHERE dv.VehicleColorCode <> ''UNK''
              GROUP BY  dv.VehicleColorCode
                     ,dc.ColorName
              ORDER BY  count# DESC';

    -- Execute the DYNAMIC SQL
    EXEC sp_executesql @SQL;
END; 