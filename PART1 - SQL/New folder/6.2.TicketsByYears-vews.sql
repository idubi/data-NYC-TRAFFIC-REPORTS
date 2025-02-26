drop view VU_TicketsBetween2015To2017ByBorough 
Go
CREATE view VU_TicketsBetween2015To2017ByBorough as   
        SELECT
            COUNT(vft.ParkingViolationKey) AS NumberOfTickets,
            db.BoroughName AS Bborough,
            db.BoroughCode AS BoroughCode,
            YEAR(vft.ViolationDate) AS Year
        FROM
            VU_FactTableFor2015To2017 vft
            Join 
                DimBorough db ON db.BoroughCode = vft.BoroughCode
        GROUP BY 
        db.BoroughCode , db.BoroughName  , YEAR(vft.ViolationDate);

Go 

drop view VU_TicketsBetween2015To2017ByState;

Go
-- dbo.VU_TicketsBetween2015To2017ByState source

CREATE view VU_TicketsBetween2015To2017ByState as 
        SELECT
            COUNT(vft.ParkingViolationKey) AS NumberOftickets,
            ds.StateCode,
            ds.StateName AS state,
            YEAR(vft.ViolationDate) AS Year ,
            DATENAME(WEEKDAY, vft.ViolationDate) AS DayName,
            DATEPART(WEEKDAY, vft.ViolationDate) AS DayNumber
        FROM
            VU_FactTableFor2015To2017 vft
            JOIN
            DimState ds ON vft.RegistrationStateCode = ds.StateCode
        GROUP BY 
           ds.StateCode,ds.StateName, YEAR(vft.ViolationDate), DATENAME(WEEKDAY, vft.ViolationDate)  ,
            DATEPART(WEEKDAY, vft.ViolationDate);        

GO


drop view VU_TicketsBetween2015To2017ByViolation;

Go

-- dbo.VU_TicketsBetween2015To2017ByViolation source

CREATE view VU_TicketsBetween2015To2017ByViolation as
        SELECT
            COUNT(vft.ParkingViolationKey) AS NumberOfTickets,
            vft.ViolationCode AS ViolationCode,
            dvf.violationDescription AS Violation,
            YEAR(vft.ViolationDate) AS Year,
            DATENAME(WEEKDAY, vft.ViolationDate) AS DayName,
            DATEPART(WEEKDAY, vft.ViolationDate) AS DayNumber
        FROM
            VU_FactTableFor2015To2017 vft
            JOIN
            DimViolationsFine dvf ON dvf.ViolationKey = vft.ViolationCode
        GROUP BY 
            vft.ViolationCode , dvf.ViolationDescription  , YEAR(vft.ViolationDate),
            DATENAME(WEEKDAY, vft.ViolationDate)  ,
            DATEPART(WEEKDAY, vft.ViolationDate);            