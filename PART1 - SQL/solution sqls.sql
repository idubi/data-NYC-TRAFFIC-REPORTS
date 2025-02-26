--1	יש לפתח שליפה שתציג את כמות דוחות החנייה לפי רובעים(Borough)  בעיריית ניו יורק בין השנים 2015 – 2017 
--
--• יש להציג את שם הרובע.
--• יש למיין את התוצאות לפי סדר יורד של כמות דוחות החניה
--• בסיום פיתוח השאילתה יש להפוך אותה ל-  Stored Procedure
--  כך שהפרוצדורה תופעל עם פרמטר של שם הרובע.
--

SELECT  BoroughName
       ,count (fact.ParkingViolationKey ) AS #tickets
FROM DimBorough db
    JOIN DimLocation dl
        ON dl.BoroughCode = db.BoroughCode
    JOIN FactParkingViolation fact
        ON dl.LocationKey = fact.LocationKey
	WHERE db.BoroughCode <> 99 -- unknown
	    and YEAR(CAST(fact.IssueDate AS DATE)) BETWEEN 2015 AND 2017
	GROUP BY  BoroughName
ORDER BY  2 desc;





CREATE or alter PROCEDURE GetBoroughTicketCounts @Borough NVARCHAR(255) = NULL AS BEGIN
    SET NOCOUNT ON;

    SELECT  BoroughName
        ,count (fact.ParkingViolationKey ) AS #tickets
    FROM DimBorough db
        JOIN DimLocation dl
            ON dl.BoroughCode = db.BoroughCode
        JOIN FactParkingViolation fact
            ON dl.LocationKey = fact.LocationKey
    WHERE (@Borough IS NULL OR LOWER(db.BoroughName) LIKE LOWER(@Borough)+'%')
	    and db.BoroughCode <> 99 -- unknown
	    and YEAR(CAST(fact.IssueDate AS DATE)) BETWEEN 2015 AND 2017
    GROUP BY  BoroughName
    ORDER BY  #tickets DESC; 
END;


exec GetBoroughTicketCounts  @Borough='bronx'
exec GetBoroughTicketCounts  




--2	יש להוסיף לשליפה הקודמת את היום בשבוע שבו ניתנו דוחות החנייה כך שהשליפה תציג את כמות דוחות החנייה לכל רובע ולכל יום בשבוע.
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
			where db.BoroughCode <> 99 -- unknown
					and YEAR(CAST(fact.IssueDate AS DATE)) BETWEEN 2015 AND 2017
GROUP BY BoroughName,
    DATENAME(WEEKDAY, fact.IssueDate)
ORDER BY BoroughName,DayName
     


CREATE or alter PROCEDURE GetParkingViolationCountsForBoroughAndDayOfWeek
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
			WHERE db.BoroughCode <> 99 -- unknown
					and YEAR(CAST(fact.IssueDate AS DATE)) BETWEEN 2015 AND 2017
			GROUP BY BoroughName,
				DATENAME(WEEKDAY, fact.IssueDate),DATEPART(WEEKDAY,fact.IssueDate)
    ) sql4DayAndBoroughName
    where (@Borough is null or sql4DayAndBoroughName.BoroughName like lower(@Borough)+'%')
      and (@Day is null or sql4DayAndBoroughName.DayName like lower(@Day)+'%')   
	ORDER BY BoroughName,_daynum ;

-- the return of days is in chronological day order , and not day name order 
exec GetParkingViolationCountsForBoroughAndDayOfWeek @Borough=bronx , @day=sunday
exec GetParkingViolationCountsForBoroughAndDayOfWeek @Borough=bronx 
exec GetParkingViolationCountsForBoroughAndDayOfWeek @day=sunday
exec GetParkingViolationCountsForBoroughAndDayOfWeek  ;




-- 3	יש לפתח שליפה שתציג את חמשת סוגי עבירות החנייה, על-פי קוד עבירה, 
-- ViolationCodeהכי נפוצות בעיריית ניו יורק .2017 עד2015 בשנים
--• בסיום פיתוח השאילתה יש להפוך אותה ל- Stored Procedure   
--   כשהפרוצדורה תופעל עם פרמטר של מספר העבירות הכי נפוצות
--
SELECT  top(5)  fact.ViolationCode , COUNT(fact.ParkingViolationKey) AS count#
FROM FactParkingViolation fact
where YEAR(CAST(fact.IssueDate AS DATE)) BETWEEN 2015 AND 2017
GROUP BY  ViolationCode
ORDER BY  count# desc
               
                              
create or alter PROCEDURE GetTopParkingViolationCodes
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
            ' fact.ViolationCode ,  COUNT(fact.ParkingViolationKey) AS count#
            FROM FactParkingViolation fact
			where YEAR(CAST(fact.IssueDate AS DATE)) BETWEEN 2015 AND 2017
            GROUP BY  fact.ViolationCode
            ORDER BY  count# desc';
               
    -- Execute the DYNAMIC SQL
    EXEC sp_executesql @SQL;
END;
               
exec  GetTopParkingViolationCodes @TopNumber=5




-- BONUS : with name of violation , not only code 
               SELECT  top(5) dvf.ViolationDescription,  
			       fact.ViolationCode , COUNT(fact.ParkingViolationKey) AS count#
               FROM FactParkingViolation fact
                   JOIN DimViolationsFine dvf
                       ON dvf.ViolationKey = fact.ViolationCode
               where YEAR(CAST(fact.IssueDate AS DATE)) BETWEEN 2015 AND 2017
               GROUP BY  dvf.ViolationDescription,ViolationCode
               ORDER BY  count# desc
               


               create or alter PROCEDURE GetTopParkingViolations
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
                           'dvf.ViolationDescription,  fact.ViolationCode , COUNT(fact.ParkingViolationKey) AS count#
                            FROM FactParkingViolation fact
                                JOIN DimViolationsFine dvf
                                    ON dvf.ViolationKey = fact.ViolationCode
							where YEAR(CAST(fact.IssueDate AS DATE)) BETWEEN 2015 AND 2017
                            GROUP BY  dvf.ViolationDescription, fact.ViolationCode
                            ORDER BY  count# desc';
               
                   -- Execute the DYNAMIC SQL
                   EXEC sp_executesql @SQL;
               END;
               
               exec  GetTopParkingViolations @TopNumber=5
               exec  GetTopParkingViolations 


--  4	יש להציג את שתי סוגי העבירות הכי נפוצות לכל צבע רכב בעיריית ניו יורק בשנים 2015 - 2017
-- • יש להימנע מלהציג צבע רכב לא ידוע.
-- • בסיום פיתוח השאילתה יש להפוך אותה ל- Stored Procedure 
--   כשהפרוצדורה תופעל עם פרמטר של מספר העבירות הכי נפוצות 
-- 
 
 

WITH all_count_colors AS (
    SELECT 
        COUNT(fact.ParkingViolationKey) AS count_num,
        dc.ColorName, 
        dvf.ViolationDescription
    FROM FactParkingViolation fact
    JOIN DimVehicle dv ON fact.VehicleKey = dv.VehicleKey
    JOIN DimColor dc ON dc.ColorCode = dv.VehicleColorCode
    JOIN DimViolationsFine dvf ON dvf.ViolationKey = fact.ViolationCode
    WHERE YEAR(CAST(fact.IssueDate AS DATE)) BETWEEN 2015 AND 2017
        AND dv.VehicleColorCode <> 'UNK'
    GROUP BY dc.ColorName, dvf.ViolationDescription
),
ranked_colors AS (
    SELECT 
        count_num, 
        ColorName, 
        ViolationDescription, 
        RANK() OVER (PARTITION BY ColorName ORDER BY count_num DESC) AS ranks
    FROM all_count_colors
)
SELECT ColorName ,ViolationDescription,count_num FROM ranked_colors where ranks<=2
 
  


 
CREATE or alter PROCEDURE GetTopParkingViolationsForColors
    @TopNumber INT = 0 ,       -- number of violations to show for colors
    @Color NVARCHAR(20) = NULL  -- color name parameter (e.g., 'white')
AS
begin
		WITH all_count_colors AS (
			SELECT 
				COUNT(fact.ParkingViolationKey) AS count_num,
				dc.ColorName, 
				dvf.ViolationDescription
			FROM FactParkingViolation fact
			JOIN DimVehicle dv ON fact.VehicleKey = dv.VehicleKey
			JOIN DimColor dc ON dc.ColorCode = dv.VehicleColorCode
			JOIN DimViolationsFine dvf ON dvf.ViolationKey = fact.ViolationCode
			WHERE YEAR(CAST(fact.IssueDate AS DATE)) BETWEEN 2015 AND 2017
				AND dv.VehicleColorCode <> 'UNK'
			GROUP BY dc.ColorName, dvf.ViolationDescription
		),
		ranked_colors AS (
			SELECT 
				count_num, 
				ColorName, 
				ViolationDescription, 
				RANK() OVER (PARTITION BY ColorName ORDER BY count_num DESC) AS ranks
			FROM all_count_colors
		)
		SELECT ColorName ,ViolationDescription,count_num 
		FROM ranked_colors 
		where (@TopNumber = 0 or ranks<= @TopNumber) 
		  and (@Color is null or UPPER(ColorName) = upper(@Color))
end
exec  GetTopParkingViolationsForColors   
exec  GetTopParkingViolationsForColors   @Color = 'white'
exec  GetTopParkingViolationsForColors   @Color = 'gold'  ,@TopNumber=2
exec  GetTopParkingViolationsForColors   @TopNumber=2




-- 5	יש לבנות שליפה המציגה כמות הרכבים שקיבלו דוחות חניה בין
--     השנים 2015ל 2017לפי קבוצות של:
--• 10 או יותר 
--• 5-9 
--• פחות מ 5 
--

with parking_violations_cte (VehicleKey,count#,ViolationsAmountClassification) 
AS 
       (select fact.VehicleKey ,
        count(fact.ParkingViolationKey) as count# , 
     case
             when count(fact.ParkingViolationKey) > 9 then 'group of 10 or more violations' 
             when count(fact.ParkingViolationKey) > 4 then 'group of 5-9 violations' 
             else 'group with less then 5 violations' 
     end   as ViolationClassification
       from FactParkingViolation fact
	   WHERE YEAR(CAST(fact.IssueDate AS DATE)) BETWEEN 2015 AND 2017
         group by fact.VehicleKey
        )
select count(vehiclekey), ViolationsAmountClassification 
  from parking_violations_cte
  
  group by ViolationsAmountClassification

--
--   6	יש להציג שליפה המציגה לכל מדינה שבה רשום הרכב את העמודות הבאות:
--• כמות דוחות החנייה בשנת 2015
--• כמות דוחות החנייה בשנת 2016
--• כמות דוחות החנייה בשנת 2017
--•אחוז השינוי של כמות דוחות החנייה בין שנת   2017 לבין שנת 2015 (יש להציג את המספר באחוזים) 
--


WITH
    year_data_cte
    AS
    (
        SELECT
            COUNT(fact.ParkingViolationKey) AS tickets,
            ds.StateName AS state,
            YEAR(fact.issueDate) AS Year
        FROM
            FactParkingViolation fact
            JOIN
            DimVehicle dv ON fact.VehicleKey = dv.VehicleKey
            JOIN
            DimState ds ON dv.RegistrationStateCode = ds.StateCode
        WHERE YEAR(CAST(fact.IssueDate AS DATE)) BETWEEN 2015 AND 2017
        GROUP BY 
        ds.StateName, YEAR(fact.issueDate)
    )
SELECT
    state,
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
        state,
        tickets,
        -- Get values for each year
        MAX(CASE WHEN year = 2015 THEN tickets END) OVER (PARTITION BY state) AS value2015,
        MAX(CASE WHEN year = 2016 THEN tickets END) OVER (PARTITION BY state) AS value2016,
        MAX(CASE WHEN year = 2017 THEN tickets END) OVER (PARTITION BY state) AS value2017
    FROM year_data_cte
) AS ranked_data
GROUP BY state, value2015, value2016, value2017
ORDER BY state 
