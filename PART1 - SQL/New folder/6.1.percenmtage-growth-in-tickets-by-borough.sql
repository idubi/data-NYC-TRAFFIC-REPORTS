
WITH
    year_data_cte
    AS
    (
        SELECT
            COUNT(vftft.ParkingViolationKey) AS tickets,
            db.BoroughName AS borough,
            YEAR(vftft.ViolationDateTime) AS Year
        FROM
            VU_FactTableFor2015To2017 vftft
            JOIN
                VU_dimLocationClean vdlc on vdlc.LocationKey = vftft.LocationKey
            Join 
                DimBorough db ON db.BoroughCode = vdlc.BoroughCode
        GROUP BY 
        db.BoroughName  , YEAR(vftft.ViolationDateTime)
    )
SELECT
    borough,
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
        borough,
        tickets,
        -- Get values for each year
        MAX(CASE WHEN year = 2015 THEN tickets END) OVER (PARTITION BY borough) AS value2015,
        MAX(CASE WHEN year = 2016 THEN tickets END) OVER (PARTITION BY borough) AS value2016,
        MAX(CASE WHEN year = 2017 THEN tickets END) OVER (PARTITION BY borough) AS value2017
    FROM year_data_cte
) AS ranked_data
GROUP BY borough, value2015, value2016, value2017
ORDER BY borough 

go

CREATE view VU_TicketsProgressBetween2015To2017ByBorough as   
WITH
    year_data_cte
    AS
    (
        SELECT
            COUNT(vftft.ParkingViolationKey) AS tickets,
            db.BoroughName AS borough,
            YEAR(vftft.ViolationDateTime) AS Year
        FROM
            VU_FactTableFor2015To2017 vftft
            JOIN
                VU_dimLocationClean vdlc on vdlc.LocationKey = vftft.LocationKey
            Join 
                DimBorough db ON db.BoroughCode = vdlc.BoroughCode
        GROUP BY 
        db.BoroughName  , YEAR(vftft.ViolationDateTime)
    )
SELECT
    borough,
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
        borough,
        tickets,
        -- Get values for each year
        MAX(CASE WHEN year = 2015 THEN tickets END) OVER (PARTITION BY borough) AS value2015,
        MAX(CASE WHEN year = 2016 THEN tickets END) OVER (PARTITION BY borough) AS value2016,
        MAX(CASE WHEN year = 2017 THEN tickets END) OVER (PARTITION BY borough) AS value2017
    FROM year_data_cte
) AS ranked_data
GROUP BY borough, value2015, value2016, value2017


go 

CREATE view VU_TicketsBetween2015To2017ByBorough as   
WITH
    year_data_cte
    AS
    (
        SELECT
            COUNT(vftft.ParkingViolationKey) AS tickets,
            db.BoroughName AS borough,
            YEAR(vftft.ViolationDateTime) AS Year
        FROM
            VU_FactTableFor2015To2017 vftft
            JOIN
                VU_dimLocationClean vdlc on vdlc.LocationKey = vftft.LocationKey
            Join 
                DimBorough db ON db.BoroughCode = vdlc.BoroughCode
        GROUP BY 
        db.BoroughName  , YEAR(vftft.ViolationDateTime)
    )
SELECT
    borough,
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
        borough,
        tickets,
        -- Get values for each year
        MAX(CASE WHEN year = 2015 THEN tickets END) OVER (PARTITION BY borough) AS value2015,
        MAX(CASE WHEN year = 2016 THEN tickets END) OVER (PARTITION BY borough) AS value2016,
        MAX(CASE WHEN year = 2017 THEN tickets END) OVER (PARTITION BY borough) AS value2017
    FROM year_data_cte
) AS ranked_data
GROUP BY borough, value2015, value2016, value2017