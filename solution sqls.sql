--2.1	יש לפתח שליפה שתציג את כמות דוחות החנייה לפי רובעים(Borough)  בעיריית ניו יורק בין השנים 2015 – 2017 
--
--• יש להציג את שם הרובע.
--• יש למיין את התוצאות לפי סדר יורד של כמות דוחות החניה
--• בסיום פיתוח השאילתה יש להפוך אותה ל-  Stored Procedure
--  כך שהפרוצדורה תופעל עם פרמטר של שם הרובע.
--

SELECT  BoroughName
       ,count (vfpv.ParkingViolationKey ) AS #tickets
FROM DimBorough db
    JOIN VU_DimLocationClean vdlc
        ON vdlc.BoroughCode = db.BoroughCode
    JOIN VU_FactTableFor2015To2017 vfpv
        ON vdlc.LocationKey = vfpv.LocationKey
GROUP BY  BoroughName
ORDER BY  2 desc;

drop procedure GetBoroughTicketCounts ;
CREATE PROCEDURE GetBoroughTicketCounts @Borough NVARCHAR(255) = NULL AS BEGIN
    SET NOCOUNT ON;

    SELECT  BoroughName
        ,count (vfpv.ParkingViolationKey ) AS #tickets
    FROM DimBorough db
        JOIN VU_DimLocationClean vdlc
            ON vdlc.BoroughCode = db.BoroughCode
        JOIN VU_FactTableFor2015To2017 vfpv
            ON vdlc.LocationKey = vfpv.LocationKey
    WHERE (@Borough IS NULL OR LOWER(db.BoroughName) LIKE LOWER(@Borough)+'%')
    GROUP BY  BoroughName
    ORDER BY  #tickets DESC; 
END;


exec GetBoroughTicketCounts  @Borough='bronx'




--2.2	יש להוסיף לשליפה הקודמת את היום בשבוע שבו ניתנו דוחות החנייה כך שהשליפה תציג את כמות דוחות החנייה לכל רובע ולכל יום בשבוע.
--•  יש להציג את שם היום בשבוע (לא את המספר)
--•  תוצאת השליפה תהיה ממוינת לפי רובע ויום בשבוע
--• בסיום פיתוח השאילתה יש להפוך אותה ל- 	Stored Procedure 
--  כך שהפרוצדורה תופעל עם פרמטר של יום בשבוע

--	אין כאן דרישה להגבלה בשנים 2015-2017, אבל רשום להוסיף לשאילתה הקודמת שכן מסננת את זה 
--

SELECT BoroughName,
            DATENAME(WEEKDAY, fact.IssueDate) AS DayName,
            count(fact.ParkingViolationKey) AS #tickets                          
FROM DimBorough db
            JOIN DimLocation dlc 
                ON dlc.BoroughCode = db.BoroughCode
            JOIN FactParkingViolation  fact 
                ON fact.LocationKey = dlc.LocationKey
GROUP BY BoroughName,
    DATENAME(WEEKDAY, fact.IssueDate)
ORDER BY BoroughName,DayName
     
drop procedure GetParkingViolationCountsForBoroughAndDayOfWeek;

CREATE PROCEDURE GetParkingViolationCountsForBoroughAndDayOfWeek
    @Day NVARCHAR(50) = NULL,       -- Day name parameter (e.g., 'Monday')
    @Borough NVARCHAR(255) = NULL  -- Borough name parameter (e.g., 'Manhattan')
AS
select BoroughName, DayName , #tickets  
    from (
			SELECT BoroughName,
						DATENAME(WEEKDAY, fact.IssueDate) AS DayName,
						DATEPART(WEEKDAY, fact.IssueDate) AS _daynum,
						count(fact.ParkingViolationKey) AS #tickets                          
			FROM DimBorough db
						JOIN DimLocation dlc 
							ON dlc.BoroughCode = db.BoroughCode
						JOIN FactParkingViolation  fact 
							ON fact.LocationKey = dlc.LocationKey
			GROUP BY BoroughName,
				DATENAME(WEEKDAY, fact.IssueDate),DATEPART(WEEKDAY,fact.IssueDate)
    ) sql4DayAndBoroughName
    where (@Borough is null or sql4DayAndBoroughName.BoroughName like lower(@Borough)+'%')
      and (@Day is null or sql4DayAndBoroughName.DayName like lower(@Day)+'%')   
	ORDER BY BoroughName,_daynum ;

-- the return of days is in chronological day order , and not day name order 
exec GetParkingViolationCountsForBoroughAndDayOfWeek @Borough=bronx 
exec GetParkingViolationCountsForBoroughAndDayOfWeek 
