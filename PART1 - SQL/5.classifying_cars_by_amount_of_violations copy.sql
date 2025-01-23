-- SQL
with parking_violations_cte (VehicleKey,count#,ViolationsAmountRecurrence) 
AS 
	(select vftft.VehicleKey ,
	 count(vftft.ParkingViolationKey) as count# , 
     case
	      when count(vftft.ParkingViolationKey) > 9 then 'group of 10 or more violations' 
	      when count(vftft.ParkingViolationKey) > 4 then 'group of 5-9 violations' 
	      else 'group with less then 5 violations' 
     end   as ViolationClassification
	from VU_FactTableFor2015To2017 vftft  
	  group by vftft.VehicleKey
	 )
select count(vehiclekey) as count#, ViolationsAmountRecurrence 
  from parking_violations_cte
  group by ViolationsAmountRecurrence

go 

CREATE VIEW VU_ViolationsRecurrenceByVehicle AS
	with parking_violations_cte (VehicleKey,count#,ViolationsAmountRecurrence) 
	AS 
		(select vftft.VehicleKey ,
		count(vftft.ParkingViolationKey) as count# , 
		case
			when count(vftft.ParkingViolationKey) > 9 then 'group of 10 or more violations' 
			when count(vftft.ParkingViolationKey) > 4 then 'group of 5-9 violations' 
			else 'group with less then 5 violations' 
		end   as ViolationClassification
		from VU_FactTableFor2015To2017 vftft  
		group by vftft.VehicleKey
		)
	select count(vehiclekey) as count#, ViolationsAmountRecurrence 
	from parking_violations_cte
	group by ViolationsAmountRecurrence
