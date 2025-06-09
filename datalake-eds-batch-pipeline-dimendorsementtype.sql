BEGIN;

SET TIMEZONE = 'Singapore';
 
DELETE FROM el_eds_def.DimEndorsementType WHERE 1=1;
 
INSERT INTO  el_eds_def.DimEndorsementType
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
,Endorsement_Type_uuid
,business_key
,Endorsement_Type_id
,Endorsement_Type_Desc
)
 
 
SELECT
    'MANUAL' as source_app_code,
    'MANUAL' as source_data_set,
    'I' AS dml_ind,
    GETDATE() AS record_created_date,
    GETDATE() AS record_updated_date,
    'EDS' AS record_created_by,
    'EDS' AS record_updated_by,
    CAST('1900-01-01 00:00:00.000000' AS timestamp) AS record_eff_from_date,
    CAST('9999-12-31 00:00:00.000000' AS timestamp) AS record_eff_to_date,
    'Y' AS active_record_ind,
    '-1' AS Endorsement_Type_uuid,
    ('MANUAL' || '~' || -1) AS business_key,
    -1 as Endorsement_Type_id,
    'UNKNOWN' as Endorsement_Type_Desc
WHERE (
	SELECT COUNT(1) FROM el_eds_def.DimEndorsementType WHERE Endorsement_Type_uuid = -1
	) = 0;
 
INSERT INTO el_eds_def.DimEndorsementType
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
	checksum
	,Endorsement_Type_uuid
	,business_key
	,Endorsement_Type_id
	,endorsement_type_desc
)
SELECT 
    'EBLI' as Source_app_code,
    'EBLI' as source_data_set,
    'I' as dml_ind,
    getdate() as record_created_date,
    getdate() as record_updated_date,
    'EDS' as record_created_by,
    'EDS' as record_updated_by,
    getdate() as record_eff_from_date,
    cast('9999-12-31 00:00:00.000000' as timestamp) as record_eff_to_date,
    'Y' as active_record_ind,
    SHA2(coalesce(cast(row_number() over (order by upper(endorsement_type_desc))  AS VARCHAR), 'null')
        ||coalesce(cast(upper(endorsement_type_desc) AS VARCHAR), 'null')
		||coalesce(cast(source_app_code as varchar),cast('null' as varchar)),256) AS checksum,
    SHA2('EBLI' || cast(row_number() over (order by upper(endorsement_type_desc)) as varchar),256) as Endorsement_Type_uuid,
    ('EBLI' ||'~'||cast(row_number() over (order by upper(endorsement_type_desc)) as varchar)) as business_key,
   row_number() over (order by upper(endorsement_type_desc)) as Endorsement_Type_id,
   upper(endorsement_type_desc) as endorsement_type_desc

FROM 
(
	SELECT distinct
	code_desc as Endorsement_Type_desc
	FROM el_eds_def.dimcodelookup
	WHERE UPPER(code_type) = 'T_SERVICE'
	);

 
INSERT INTO el_eds_def.DimEndorsementType
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
	checksum
	,Endorsement_Type_uuid
	,business_key
	,Endorsement_Type_id
	,Endorsement_Type_Desc
)
SELECT 
    'ISIS' as Source_app_code,
    'ISIS' as source_data_set,
    'I' as dml_ind,
    getdate() as record_created_date,
    getdate() as record_updated_date,
    'EDS' as record_created_by,
    'EDS' as record_updated_by,
    getdate() as record_eff_from_date,
    cast('9999-12-31 00:00:00.000000' as timestamp) as record_eff_to_date,
    'Y' as active_record_ind,
    SHA2( coalesce(cast(row_number() over (order by  upper(endorsement_type_desc))AS VARCHAR), 'null') ||
        coalesce(cast(upper(endorsement_type_desc) as varchar),cast('null' as varchar))
		||coalesce(cast(source_app_code as varchar),cast('null' as varchar)),256 ) AS checksum,
		
    SHA2('ISIS' || cast(row_number() over (order by  upper(endorsement_type_desc)) as varchar),256) as Endorsement_Type_uuid,
    ('ISIS' ||'~'||cast(row_number() over (order by upper(endorsement_type_desc)) as varchar)) as business_key,
   row_number() over (order by upper(endorsement_type_desc)) as endorsement_type_id,
   upper(Endorsement_Type_Desc) as Endorsement_Type_Desc

FROM 
(
	SELECT distinct
	description as Endorsement_Type_desc
	FROM tl_isis_def.tb_endorsementtype_hist
	 );

END;	 
	 
	
