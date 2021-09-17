CREATE TABLE edw_staging.aifrps_dim_underwriting_pre_work (
dim_underwriting_natural_key_hash_uuid uuid NOT NULL
,dim_agreement_natural_key_hash_uuid uuid NOT NULL
,agreement_nr_pfx varchar(50) 
,agreement_nr varchar(150) NOT NULL
,agreement_nr_sfx varchar(50) 
,agreement_source_cde varchar(50) NOT NULL
,agreement_type_cde varchar(50) NOT NULL
,participant_role_cde varchar(50) NOT NULL
,source_participant_role_cde varchar(50) 
,underwriting_sequence_nr int 
,source_participant_role_stype_cde varchar(50) NOT NULL
,issue_age_nr int 
,exclusion_rider_ind boolean 
,source_exclusion_rider_ind varchar(50) 
,exclusion_rider_form_nr int 
,exclusion_cde varchar(50) 
,source_exclusion_cde varchar(50) 
,tobacco_class_cde varchar(50) 
,source_tobacco_class_cde varchar(50) 
,risk_class_cde varchar(50) 
,source_risk_class_cde varchar(50) 
,risk_class_pct numeric(9,6) 
,unisex_ind boolean 
,exclusion_rider_2_form_nr int 
,underwriting_key_id varchar(600) 
,begin_dt date NOT NULL DEFAULT '0001-01-01'::date
,begin_dtm timestamp(6) NOT NULL DEFAULT '0001-01-01 00:00:00'::timestamp
,row_process_dtm timestamp(6) NOT NULL DEFAULT (now())::timestamptz(6)
,check_sum uuid NOT NULL
,end_dt date NOT NULL DEFAULT '9999-12-31'::date
,end_dtm timestamp(6) NOT NULL DEFAULT '9999-12-31 23:59:59.999999'::timestamp
,restricted_row_ind boolean NOT NULL DEFAULT false
,row_sid IDENTITY 
,current_row_ind boolean NOT NULL DEFAULT true
,logical_delete_ind boolean NOT NULL DEFAULT false
,source_system_id varchar(50) NOT NULL
,audit_id int NOT NULL DEFAULT 0
,update_audit_id int NOT NULL DEFAULT 0
,source_delete_ind boolean NOT NULL DEFAULT false
,PROCESS_IND varchar(1) );