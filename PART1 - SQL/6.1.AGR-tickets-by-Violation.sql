
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
GROUP BY ViolationCode , violation, value2015, value2016, value2017
ORDER BY violation 

go
drop view VU_AGR_Between2015To2017ByViolation;
go
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


go 
select * from VU_AGR_Between2015To2017ByViolation