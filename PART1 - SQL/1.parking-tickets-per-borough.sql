-- SQL

SELECT  BoroughName
       ,count (vfpv.ParkingViolationKey ) AS #tickets
FROM DimBorough db
    JOIN VU_DimLocationCelan vdlc
        ON vdlc.BoroughCode = db.BoroughCode
    JOIN VU_FactTableFor2015To2017 vfpv
        ON vdlc.LocationKey = vfpv.LocationKey
GROUP BY  BoroughName
ORDER BY  2 desc;


GO
-- STORED PROCEDURE

ALTER PROCEDURE GetBoroughTicketCounts @Borough NVARCHAR(255) = NULL AS BEGIN
    SET NOCOUNT ON;

    SELECT  BoroughName
        ,count (vfpv.ParkingViolationKey ) AS #tickets
    FROM DimBorough db
        JOIN VU_DimLocationCelan vdlc
            ON vdlc.BoroughCode = db.BoroughCode
        JOIN VU_FactTableFor2015To2017 vfpv
            ON vdlc.LocationKey = vfpv.LocationKey
    WHERE (@Borough IS NULL OR LOWER(db.BoroughName) LIKE LOWER(@Borough)+'%')
    GROUP BY  BoroughName
    ORDER BY  #tickets DESC; 
END;

 