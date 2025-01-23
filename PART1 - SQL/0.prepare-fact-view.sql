alter VIEW dbo.VU_FactTableFor2015To2017
AS
    
SELECT ParkingViolationKey
       , SummonsNumber
       -- , CAST(fpv.IssueDate AS DATE) AS ViolationDate
       -- , TRY_CAST(
       --               LEFT(ViolationTime, 2) + ':' + SUBSTRING(ViolationTime, 3, 2) + 
       --               ' ' + 
       --               CASE 
       --                      WHEN RIGHT(ViolationTime, 1) = 'A' THEN 'AM'
       --                      WHEN RIGHT(ViolationTime, 1) = 'P' THEN 'PM'
       --               END 
       --        AS TIME) AS ViolationTime
       ,

       CAST(IssueDate AS DATETIME) + 
                     COALESCE(
              TRY_CAST(
              STUFF(LEFT(ViolationTime, 4), 3, 0, ':') + -- Insert ":" at position 3
              ' ' + 
              CASE 
                     WHEN RIGHT(ViolationTime, 1) = 'A' THEN 'AM'
                     WHEN RIGHT(ViolationTime, 1) = 'P' THEN 'PM'
              END 
              AS datetime), 
              '1900-01-01 00:00:00'  -- Default invalid values to 00:00 AM
       ) AS ViolationDateTime

       , ViolationCode
       , ViolationInFrontOfOrOpposite
       , VehicleKey
       , IssuerKey
       , LocationKey
FROM FactParkingViolation fpv
WHERE YEAR(CAST(fpv.IssueDate AS DATE)) BETWEEN 2015 AND 2017
;

