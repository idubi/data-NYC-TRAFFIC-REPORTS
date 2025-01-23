-- SQL

SELECT vft.BoroughCode
       ,BoroughName
       ,count (vft.ParkingViolationKey )  AS  NumberOfTickets
FROM DimBorough db
    JOIN VU_FactTableFor2015To2017 vft
        ON vft.BoroughCode = db.BoroughCode
GROUP BY  vft.BoroughCode,BoroughName
ORDER BY   NumberOfTickets desc;


GO
-- STORED PROCEDURE

ALTER PROCEDURE GetBoroughTicketCounts @Borough NVARCHAR(255) = NULL AS BEGIN
    SET NOCOUNT ON;
    SELECT  vft.BoroughCode
        ,BoroughName
        ,count (vft.ParkingViolationKey ) AS  NumberOfTickets
    FROM DimBorough db
        JOIN VU_FactTableFor2015To2017 vft
           on db.BoroughCode = vft.BoroughCode            
    WHERE (@Borough IS NULL OR LOWER(db.BoroughName) = LOWER(@Borough))
    GROUP BY  vft.BoroughCode,BoroughName
    ORDER BY   NumberOfTickets DESC; 
END;

GO

  exec GetBoroughTicketCounts 



 