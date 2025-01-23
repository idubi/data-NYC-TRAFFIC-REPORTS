alter VIEW dbo.VU_FactTableFor2015To2017
AS    
SELECT ParkingViolationKey
       , SummonsNumber
       , CAST(fpv.IssueDate AS DATE) AS ViolationDate
       , TRY_CAST(
                     LEFT(fpv.ViolationTime, 2) + ':' + SUBSTRING(ViolationTime, 3, 2) + 
                      ' ' + 
                      CASE 
                             WHEN RIGHT(fpv.ViolationTime, 1) = 'A' THEN 'AM'
                             WHEN RIGHT(fpv.ViolationTime, 1) = 'P' THEN 'PM'
                      END 
              AS TIME) AS ViolationTime       
       -- ,CAST(IssueDate AS DATETIME) + 
       --               COALESCE(
       --        TRY_CAST(
       --        STUFF(LEFT(ViolationTime, 4), 3, 0, ':') + -- Insert ":" at position 3
       --        ' ' + 
       --        CASE 
       --               WHEN RIGHT(ViolationTime, 1) = 'A' THEN 'AM'
       --               WHEN RIGHT(ViolationTime, 1) = 'P' THEN 'PM'
       --        END 
       --        AS datetime), 
       --        '1900-01-01 00:00:00'  -- Default invalid values to 00:00 AM
       -- ) AS ViolationDateTime
       , fpv.ViolationCode
       , fpv.ViolationInFrontOfOrOpposite
       , fpv.IssuerKey
       , fpv.LocationKey
       , vdlc.BoroughCode   
       , dv.VehicleKey
       , dv.PlateID
       , dv.VehicleColorCode
       , dv.RegistrationStateCode
       , dv.BodyTypeCode
    FROM FactParkingViolation fpv  
	join VU_DimLocationCelan vdlc on vdlc.LocationKey = fpv.LocationKey	
       join DimVehicle dv on dv.VehicleKey = fpv.VehicleKey
WHERE YEAR(CAST(fpv.IssueDate AS DATE)) BETWEEN 2015 AND 2017
              and dv.VehicleColorCode <> 'UNK';

go 
   select * from VU_FactTableFor2015To2017