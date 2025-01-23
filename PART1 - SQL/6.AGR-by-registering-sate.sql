
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
GROUP BY StateCode,State, value2015, value2016, value2017
ORDER BY state 


GO
-- VIEW
drop  VIEW VU_AGR_Between2015To2017ByRegistrationState;

go

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
GROUP BY StateCode,State, value2015, value2016, value2017


go 

select * from VU_AGR_Between2015To2017ByRegistrationState;
