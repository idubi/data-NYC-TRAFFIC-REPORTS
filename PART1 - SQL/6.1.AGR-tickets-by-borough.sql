
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
GROUP BY BoroughCode, borough, value2015, value2016, value2017
ORDER BY borough 

go
drop view VU_AGR_Between2015To2017ByBorough ; 
go
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



go 
select * from  VU_AGR_Between2015To2017ByBorough;