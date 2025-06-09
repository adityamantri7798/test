BEGIN;

SET timezone = 'Asia/Singapore';

DELETE FROM el_eds_def.DimClaimEventStatus WHERE 1=1;

-- Insert UNKNOWN status
INSERT INTO el_eds_def.DimClaimEventStatus
(
    source_app_code, source_data_set,
	dml_ind,
    record_created_date,
	record_updated_date,
	record_created_by,
	record_updated_by,
    record_eff_from_date,
	record_eff_to_date,
	active_record_ind,
    Claim_Event_Status_uuid,
	business_key, 
	Claim_Event_Status_id,
	Claim_Event_Status_Desc
)
SELECT
    'MANUAL' AS source_app_code,
    'MANUAL' AS source_data_set,
    'I' AS dml_ind,
    GETDATE() AS record_created_date,
    GETDATE() AS record_updated_date,
    'EDS' AS record_created_by,
    'EDS' AS record_updated_by,
    CAST('1900-01-01 00:00:00.000000' AS timestamp) AS record_eff_from_date,
    CAST('9999-12-31 00:00:00.000000' AS timestamp) AS record_eff_to_date,
    'Y' AS active_record_ind,
    '-1' AS Claim_Event_Status_uuid,
    ('MANUAL' || '~' || -1) AS business_key,
    -1 AS Claim_Event_Status_id,
    'UNKNOWN' AS Claim_Event_Status_Desc
WHERE (
    SELECT count(1) FROM el_eds_def.DimClaimEventStatus WHERE Claim_Event_Status_uuid = -1)=0;


create table #DimClaimEventStatus 
(
    source_app_code varchar(100),
	source_data_set varchar(100),
    Claim_Event_Status_id INTEGER,
	Claim_Event_Status_Desc varchar(100)
);


insert into #DimClaimEventStatus
(
    source_app_code,
	source_data_set,
    Claim_Event_Status_id,
	Claim_Event_Status_Desc
)
values
    ('EBGI','EBGI',1,'CLOSED'),
	('EBGI','EBGI',2,'NEW'), 
	('EBGI','EBGI',3,'OPEN'), 
	('EBGI','EBGI',4,'REOPEN'), 
	('RDS','RDS',5,'CANCELLED'), 
	('RDS','RDS',6,'IN PROCESS'),
	('RDS','RDS',7,'MIGRATED'),
	('RDS','RDS',8,'NOTIFIED'),
	('RDS','RDS',9,'REJECTED'),
	('RDS','RDS',10,'SUSPENDED'),
	('RDS','RDS',11,'VOID'), 
	('RDS','RDS',12,'PENDING'), 
	('RDS','RDS',13,'SETTLED'),
	('RDS','RDS',14,'WITHDRAWN'),
	('RDS','RDS',15,'REPORTING ONLY');
	
INSERT INTO el_eds_def.DimClaimEventStatus
(
source_app_code
,source_data_set
,dml_ind
,record_created_date
,record_updated_date
,record_created_by
,record_updated_by
,record_eff_from_date
,record_eff_to_date
,active_record_ind
,checksum
,Claim_Event_Status_uuid
,business_key
,Claim_Event_Status_id
,Claim_Event_Status_Desc
)
SELECT 
source_app_code
,source_data_set
,'I' as dml_ind
,getdate() as record_created_date
,getdate() as record_updated_date
,'EDS' as record_created_by
,'EDS' as record_updated_by
,getdate() as record_eff_from_date
,cast('9999-12-31 00:00:00.000000' as timestamp) as record_eff_to_date
,'Y' as active_record_ind
,SHA2(coalesce(cast(source_app_code as varchar),cast('null' as varchar))+
coalesce(cast(source_data_set as varchar),cast('null' as varchar))+
coalesce(cast(Claim_Event_Status_id as varchar),cast('null' as varchar))+
coalesce(cast(Claim_Event_Status_Desc as varchar),cast('null' as varchar)),256) AS checksum
,SHA2(source_app_code||'~'||cast(Claim_Event_Status_id as varchar),256) as claim_payment_status_uuid
,(source_app_code ||'~'||cast(Claim_Event_Status_id as varchar)) AS business_key
,Claim_Event_Status_id
,Claim_Event_Status_Desc
FROM 
    #DimClaimEventStatus;	
	
DROP TABLE IF EXISTS #DimClaimEventStatus;


create table #DimClaimEventStatus as 
SELECT
Claim_Event_Status_id,
Claim_Event_Status_desc
FROM el_eds_def.DimClaimEventStatus 
 WHERE Claim_Event_Status_Desc = (CASE WHEN a.STR_DESC = 'CANCELLATION' THEN 'CANCELLED' ELSE a.STR_DESC END) AND Claim_Event_Status_id <> -1);



INSERT INTO el_eds_def.DimClaimEventStatus
(
    source_app_code,
	source_data_set,
	dml_ind,
    record_created_date,
	record_updated_date,
	record_created_by,
	record_updated_by,
    record_eff_from_date,
	record_eff_to_date,
	active_record_ind,
    checksum,
	Claim_Event_Status_uuid,
	business_key,
	Claim_Event_Status_id,
	Claim_Event_Status_Desc
)
SELECT 
    'EBLI' AS source_app_code,
    'EBLI' AS source_data_set,
    'I' AS dml_ind,
    GETDATE() AS record_created_date,
    GETDATE() AS record_updated_date,
    'EDS' AS record_created_by,
    'EDS' AS record_updated_by,
    GETDATE() AS record_eff_from_date,
    CAST('9999-12-31 00:00:00.000000' AS timestamp) AS record_eff_to_date,
    'Y' AS active_record_ind,
    SHA2(
	  COALESCE(CAST(source_app_code AS VARCHAR), 'null')
	    || COALESCE(CAST(source_data_set AS VARCHAR), 'null'),
        || COALESCE(CAST(row_number() OVER (ORDER BY UPPER(Claim_Event_Status_Desc)) AS VARCHAR), 'null') 
        || COALESCE(CAST(b.Claim_Event_Status_id AS VARCHAR), 'null') 
		|| coalesce(cast(UPPER(Claim_Event_Status_Desc)  AS VARCHAR), 'null') 
      
        256
    ) AS checksum,
    SHA2('EBLI' || CAST(row_number() OVER (ORDER BY UPPER(Claim_Event_Status_Desc)) AS VARCHAR), 256) AS Claim_Event_Status_uuid,
    ('EBLI' || '~' || CAST(row_number() OVER (ORDER BY UPPER(Claim_Event_Status_Desc)) AS VARCHAR)) AS business_key,
    row_number() OVER (ORDER BY UPPER(Claim_Event_Status_Desc)) AS Claim_Event_Status_id,
    UPPER(Claim_Event_Status_Desc) AS Claim_Event_Status_Desc
FROM (
    SELECT DISTINCT 
	a.STR_DESC as Claim_Event_Status_Desc
    FROM rl_ebli_def.vw_v_code_desc a
    WHERE ORG_TABLE = 'T_CASE_STATUS');

END;



