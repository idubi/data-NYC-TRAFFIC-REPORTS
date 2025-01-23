--SQL 

SELECT  top(5) COUNT(vftft.ParkingViolationKey) AS count#
       ,dvf.ViolationDescription
FROM VU_FactTableFor2015To2017 vftft
    JOIN DimViolationsFine dvf
        ON dvf.ViolationKey = vftft.ViolationCode
GROUP BY  dvf.ViolationDescription
ORDER BY  count# desc




GO
-- STORED PROCEDURE
CREATE PROCEDURE GetTopParkingViolations
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
                    ,dvf.ViolationDescription
             FROM VU_FactTableFor2015To2017 vftft
                 JOIN DimViolationsFine dvf
                     ON dvf.ViolationKey = vftft.ViolationCode
             GROUP BY  dvf.ViolationDescription
             ORDER BY  count# desc';

    -- Execute the DYNAMIC SQL
    EXEC sp_executesql @SQL;
END;
