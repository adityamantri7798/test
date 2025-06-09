BEGIN;

SET TIMEZONE = 'Singapore';

DELETE FROM el_eds_def.DimEndorsementTypeMapping WHERE 1 = 1;

INSERT INTO el_eds_def.dimendorsementtypemapping (
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
    endorsement_type_mapping_uuid,
    business_key
    
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
    -1 AS endorsement_type_mapping_uuid,
    'MANUAL~-1' AS business_key
WHERE (
    SELECT COUNT(1) FROM el_eds_def.dimendorsementtypemapping
	WHERE endorsement_type_mapping_uuid = -1
) = 0;

create table #dimendorsementtype as 
SELECT
endorsement_type_id,
endorsement_type_desc
FROM el_eds_def.dimendorsementtype 
WHERE endorsement_type_id <> -1 and active_record_ind='Y';




INSERT INTO el_eds_def.dimendorsementtypemapping (
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
    endorsement_type_mapping_uuid,
    business_key,
    endorsement_type_mapping_id,
    ref_endorsement_type_id,
    endorsement_type_code,
    endorsement_type_desc
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
	SHA2(coalesce(cast(row_number() over (order by UPPER(a.code_desc))  AS VARCHAR), 'null') ||
        coalesce(cast(b.endorsement_type_id AS VARCHAR), 'null')
        ||coalesce(cast(a.Code_value as varchar), 'null') 
        ||coalesce(cast(UPPER(a.code_desc) as varchar),cast('null' as varchar))
        ||coalesce(cast(source_app_code as varchar),cast('null' as varchar)),256) AS checksum,
		
		
		
	SHA2('EBLI' ||'~'|| cast(row_number() over (order by UPPER(a.code_desc))  AS VARCHAR),256) 
	as endorsement_type_mapping_uuid,
	
    ('EBLI' ||'~'|| cast(row_number() over (order by UPPER(a.code_desc))  AS VARCHAR)) as business_key,
	
	
   row_number() over (order by UPPER(a.code_desc)) AS endorsement_type_mapping_id,
   
    b.endorsement_type_id  AS ref_endorsement_type_id,
    a.code_value AS endorsement_type_code,
    UPPER(a.code_desc) AS endorsement_type_desc
FROM el_eds_def.DimCodeLookup a left join #DimEndorsementType b on upper(b.endorsement_type_desc) = upper(a.code_desc)

WHERE UPPER(a.code_type) = 'T_SERVICE';


INSERT INTO el_eds_def.dimendorsementtypemapping (
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
    endorsement_type_mapping_uuid,
    business_key,
    endorsement_type_mapping_id,
    ref_endorsement_type_id,
    endorsement_type_code,
    endorsement_type_desc
)
SELECT
    'ISIS' as Source_app_code,
    'ISIS' as source_data_set,
    'I' as dml_ind,
    getdate() as record_created_date,
    getdate() as record_updated_date,
    'EDS' as record_created_by,
    'EDS' as record_updated_by,
    GETDATE() AS record_eff_from_date,
    cast('9999-12-31 00:00:00.000000' as timestamp) as record_eff_to_date,
    'Y' as active_record_ind,
	SHA2(coalesce(cast(row_number() over (order by a.description)AS VARCHAR), 'null') 
        ||coalesce(cast(b.endorsement_type_id  AS VARCHAR), 'null')
        ||coalesce(cast(a.endorsementtypeid AS VARCHAR), 'null')
        ||coalesce(cast(UPPER(a.description)  AS VARCHAR), 'null') 
        ||coalesce(cast(source_app_code as varchar),cast('null' as varchar)),256) AS checksum,
	SHA2('ISIS' ||'~'|| cast(row_number() over (order by a.description)AS VARCHAR), 256)
	as endorsement_type_mapping_uuid,
    ('ISIS' ||'~'||cast(row_number() over (order by a.description)AS VARCHAR))
    AS business_key,
	
	
    row_number() over (order by a.description) AS endorsement_type_mapping_id,
	
    b.endorsement_type_id AS ref_endorsement_type_id,
	
    a.endorsementtypeid AS endorsement_type_code,
    UPPER(a.description) AS endorsement_type_desc
FROM tl_isis_def.tb_endorsementtype_hist a left join #DimEndorsementType b on upper(b.endorsement_type_desc) = upper(a.description);



drop table if EXISTS #DimEndorsementType;

END;


