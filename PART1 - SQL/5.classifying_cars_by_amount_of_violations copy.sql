-- SQL
with parking_violations_cte (VehicleKey, NumberOfTickets,ViolationsAmountRecurrence) 
AS 
	(select vft.VehicleKey ,
	 count(vft.ParkingViolationKey) as  NumberOfTickets , 
     case
	      when count(vft.ParkingViolationKey) > 9 then 'group of 10 or more violations' 
	      when count(vft.ParkingViolationKey) > 4 then 'group of 5-9 violations' 
	      else 'group with less then 5 violations' 
     end   as ViolationClassification
	from VU_FactTableFor2015To2017 vft  
	  group by vft.VehicleKey
	 )
select count(vehiclekey) as  NumberOfTickets, ViolationsAmountRecurrence 
  from parking_violations_cte
  group by ViolationsAmountRecurrence

go 

alter VIEW VU_ViolationsRecurrenceByVehicle AS
	with parking_violations_cte (VehicleKey, NumberOfTickets,ViolationsAmountRecurrence) 
	AS 
		(select vft.VehicleKey ,
		count(vft.ParkingViolationKey) as  NumberOfTickets , 
		case
			when count(vft.ParkingViolationKey) > 9 then 'group of 10 or more violations' 
			when count(vft.ParkingViolationKey) > 4 then 'group of 5-9 violations' 
			else 'group with less then 5 violations' 
		end   as ViolationClassification
		from VU_FactTableFor2015To2017 vft  
		group by vft.VehicleKey
		)
	select count(vehiclekey) as  NumberOfTickets, ViolationsAmountRecurrence 
	from parking_violations_cte
	group by ViolationsAmountRecurrence
go 

select * from VU_ViolationsRecurrenceByVehicle;