CREATE TABLE edw_work.aifrps_dim_agreement_special_program (
dim_agreement_special_program_natural_key_hash_uuid uuid NOT NULL
,dim_agreement_natural_key_hash_uuid uuid NOT NULL
,special_program_key_id varchar(600) NOT NULL
,agreement_nr_pfx varchar(50) 
,agreement_nr varchar(150) NOT NULL
,agreement_nr_sfx varchar(50) 
,agreement_source_cde varchar(50) NOT NULL
,agreement_type_cde varchar(50) NOT NULL
,special_program_type_cde varchar(50) NOT NULL
,special_program_counter_nr int NOT NULL
,special_program_feature_type_cde varchar(50) 
,admin_fund_cde varchar(50) 
,product_id varchar(200) 
,company_cde varchar(50) 
,pt1_kind_cde varchar(50) 
,product_tier_cde varchar(50) 
,dim_fund_natural_key_hash_uuid uuid NOT NULL
,source_special_program_type_cde varchar(50) 
,program_business_start_dt timestamp 
,program_business_end_dt timestamp 
,program_mode_cde varchar(50) 
,source_program_mode_cde varchar(50) 
,program_mode_nr int 
,program_duration_nr int 
,program_amt numeric(17,4) 
,program_calculation_type_cde varchar(50) 
,source_program_calculation_type_cde varchar(50) 
,program_amt_type_cde varchar(50) 
,source_program_amt_type_cde varchar(50) 
,detail_amt numeric(17,4) 
,detail_pct numeric(15,5) 
,program_interest_rt numeric(15,6) 
,next_run_dt date 
,first_payment_dt date 
,first_payment_year_nr int 
,prior_mrd_amt numeric(17,4) 
,prior_mrd_amt_type_cde varchar(50) 
,source_prior_mrd_amt_type_cde varchar(50) 
,exclusion_amt numeric(17,4) 
,begin_dt date NOT NULL DEFAULT '0001-01-01'::date
,begin_dtm timestamp(6) NOT NULL
,row_process_dtm timestamp(6) NOT NULL
,check_sum uuid NOT NULL
,end_dt date NOT NULL DEFAULT '9999-12-31'::date
,end_dtm timestamp(6) NOT NULL
,restricted_row_ind boolean NOT NULL DEFAULT false
,row_sid IDENTITY 
,current_row_ind boolean NOT NULL
,logical_delete_ind boolean NOT NULL
,source_system_id varchar(50) NOT NULL
,audit_id int NOT NULL
,update_audit_id int NOT NULL
,source_delete_ind boolean NOT NULL
);