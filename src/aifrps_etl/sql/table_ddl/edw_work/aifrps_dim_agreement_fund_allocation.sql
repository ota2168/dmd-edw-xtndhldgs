CREATE TABLE edw_work.aifrps_dim_agreement_fund_allocation (
dim_agreement_fund_allocation_natural_key_hash_uuid uuid NOT NULL
,dim_agreement_natural_key_hash_uuid uuid 
,dim_fund_natural_key_hash_uuid uuid 
,agreement_source_cde varchar(50) NOT NULL
,agreement_type_cde varchar(50) NOT NULL
,agreement_nr_pfx varchar(50) 
,agreement_nr varchar(150) NOT NULL
,agreement_nr_sfx varchar(50) 
,admin_fund_cde varchar(50) 
,product_id varchar(200) 
,company_cde varchar(50) 
,pt1_kind_cde varchar(50) 
,product_tier_cde varchar(50) 
,fund_allocation_counter_nr int NOT NULL
,allocation_pct numeric(9,6) 
,fund_model_id varchar(20) 
,business_start_dt date NOT NULL
,business_end_dt date 
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
);