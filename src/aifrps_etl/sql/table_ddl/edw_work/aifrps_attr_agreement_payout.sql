CREATE TABLE edw_work.aifrps_attr_agreement_payout (
dim_agreement_natural_key_hash_uuid uuid NOT NULL
,dim_annuity_payout_option_natural_key_hash_uuid uuid 
,agreement_source_cde varchar(50) NOT NULL
,agreement_type_cde varchar(50) NOT NULL
,agreement_nr_pfx varchar(50) 
,agreement_nr varchar(150) NOT NULL
,agreement_nr_sfx varchar(50) 
,payout_method_cde varchar(50) 
,source_payout_method_cde varchar(50) 
,payout_mode_cde varchar(50) 
,source_payout_mode_cde varchar(50) 
,payout_status_cde varchar(50) 
,source_payout_status_cde varchar(50) 
,first_payout_dt date 
,last_payout_dt date 
,next_payout_dt date 
,payout_option_cde varchar(50) 
,payment_acceleration_eligibility_cde varchar(50) 
,payment_acceleration_cnt int 
,period_certain_payout_mode_duration_nr int 
,last_guaranteed_payout_dt date 
,current_payout_amt numeric(17,4) 
,remaining_installment_amt numeric(17,4) 
,fixed_purchase_payout_amt numeric(17,4) 
,variable_purchase_payout_amt numeric(17,4) 
,total_purchase_payment_amt numeric(17,4) 
,total_initial_purchase_payment_amt numeric(17,4) 
,total_gross_payout_amt numeric(17,4) 
,ytd_gross_payout_amt numeric(17,4) 
,total_net_payout_amt numeric(17,4) 
,ytd_net_payout_amt numeric(17,4) 
,primary_and_joint_payout_amt numeric(17,4) 
,primary_only_payout_amt numeric(17,4) 
,joint_only_payout_amt numeric(17,4) 
,begin_dt date NOT NULL DEFAULT '0001-01-01'::date
,begin_dtm timestamp(6) NOT NULL DEFAULT '0001-01-01 00:00:00'::timestamp
,row_process_dtm timestamp(6) NOT NULL DEFAULT (now())::timestamptz
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