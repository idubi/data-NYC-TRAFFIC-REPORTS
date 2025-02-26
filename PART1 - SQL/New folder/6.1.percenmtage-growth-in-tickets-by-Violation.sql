
WITH
    year_data_cte
    AS
    (
        SELECT
            COUNT(vftft.ParkingViolationKey) AS tickets,
            dvf.ViolationDescription AS violation,
            YEAR(vftft.ViolationDateTime) AS Year
        FROM
            VU_FactTableFor2015To2017 vftft
            JOIN
                DimViolationsFine dvf ON dvf.ViolationKey = vftft.ViolationCode
        GROUP BY 
        dvf.ViolationDescription  , YEAR(vftft.ViolationDateTime)
    )
SELECT
    violation,
    value2015,
    value2016,
    value2017,
    CASE 
        WHEN value2015 IS NOT NULL AND value2015 != 0 THEN 
            ((value2017 - value2015) * 100.0 / value2015) 
        ELSE 
            NULL 
    END AS PercentageChange
    
FROM (
    SELECT
        violation,
        tickets,
        -- Get values for each year
        MAX(CASE WHEN year = 2015 THEN tickets END) OVER (PARTITION BY violation) AS value2015,
        MAX(CASE WHEN year = 2016 THEN tickets END) OVER (PARTITION BY violation) AS value2016,
        MAX(CASE WHEN year = 2017 THEN tickets END) OVER (PARTITION BY violation) AS value2017
    FROM year_data_cte
) AS ranked_data
--where violation like 'A%'
GROUP BY violation, value2015, value2016, value2017
ORDER BY violation 

go

CREATE view VU_TicketsProgressBetween2015To2017ByViolationDescription as 
WITH
    year_data_cte
    AS
    (
        SELECT
            COUNT(vftft.ParkingViolationKey) AS tickets,
            dvf.ViolationDescription AS violation,
            YEAR(vftft.ViolationDateTime) AS Year
        FROM
            VU_FactTableFor2015To2017 vftft
            JOIN
                DimViolationsFine dvf ON dvf.ViolationKey = vftft.ViolationCode
        GROUP BY 
        dvf.ViolationDescription  , YEAR(vftft.ViolationDateTime)
    )
SELECT
    violation,
    value2015,
    value2016,
    value2017,
    CASE 
        WHEN value2015 IS NOT NULL AND value2015 != 0 THEN 
            ((value2017 - value2015) * 100.0 / value2015) 
        ELSE 
            NULL 
    END AS PercentageChange
FROM (
    SELECT
        violation,
        tickets,
        -- Get values for each year
        MAX(CASE WHEN year = 2015 THEN tickets END) OVER (PARTITION BY violation) AS value2015,
        MAX(CASE WHEN year = 2016 THEN tickets END) OVER (PARTITION BY violation) AS value2016,
        MAX(CASE WHEN year = 2017 THEN tickets END) OVER (PARTITION BY violation) AS value2017
    FROM year_data_cte
) AS ranked_data
GROUP BY violation, value2015, value2016, value2017
ORDER BY violation 
