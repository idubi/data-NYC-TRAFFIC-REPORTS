CREATE VIEW dbo.VU_dimLocationClean AS
SELECT  LocationKey
       ,BoroughCode
       ,StreetCode
       ,StreetName
       ,HouseNumber
       ,City
       ,StateCode
FROM DWH_DATA_ANALYST.dbo.DimLocation
WHERE BoroughCode <> 99 --99 = unknown borough
;

