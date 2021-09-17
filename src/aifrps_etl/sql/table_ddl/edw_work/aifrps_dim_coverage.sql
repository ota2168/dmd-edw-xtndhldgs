CREATE TABLE edw_work.aifrps_dim_coverage (
dim_coverage_natural_key_hash_uuid uuid NOT NULL
,dim_agreement_natural_key_hash_uuid uuid NOT NULL
,coverage_key_id varchar(600) 
,agreement_nr_pfx varchar(50) 
,agreement_nr varchar(150) NOT NULL
,agreement_nr_sfx varchar(50) 
,agreement_source_cde varchar(50) NOT NULL
,agreement_type_cde varchar(50) NOT NULL
,dim_product_natural_key_hash_uuid uuid 
,coverage_pt1_kind_cde varchar(50) 
,coverage_pt2_issue_basis_cde varchar(50) 
,coverage_pt3_rt_cde varchar(50) 
,coverage_sequence_nr int 
,coverage_long_nm varchar(500) 
,coverage_short_nm varchar(100) 
,coverage_status_cde varchar(50) 
,source_coverage_exception_status_cde varchar(50) 
,source_coverage_effective_dt date 
,source_coverage_effective_dt_txt varchar(100) 
,occupation_class_cde varchar(50) 
,source_occupation_class_cde varchar(50) 
,return_premium_policy_nr int 
,issue_age_nr int 
,coverage_type_cde varchar(50) 
,minor_product_cde varchar(50) 
,coverage_category_cde varchar(50) 
,source_coverage_category_cde varchar(50) 
,coverage_cease_dt date 
,coverage_crossover_opt_dt date 
,coverage_1035_ind boolean 
,scheduled_unscheduled_cde varchar(50) 
,active_ind boolean 
,pending_collection_ind boolean 
,increment_counter_nr int 
,source_coverage_cease_dt_txt varchar(100) 
,occupation_class_modifier_nr int 
,coverage_period_txt varchar(25) 
,source_coverage_period_txt varchar(50) 
,coverage_person_cde varchar(50) 
,coverage_benefit_type_amt numeric(17,4) 
,palir_roll_status_cde varchar(50) 
,coverage_face_amt numeric(17,4) 
,coverage_income_amt numeric(17,4) 
,coverage_increase_pct numeric(9,6) 
,coverage_dividend_option_cde varchar(50) 
,source_coverage_dividend_option_cde varchar(50) 
,coverage_secondary_dividend_option_cde varchar(50) 
,source_coverage_secondary_dividend_option_cde varchar(50) 
,coverage_conversion_expiry_dt date 
,coverage_conversion_eligibility_start_dt date 
,coverage_fio_next_dt date 
,coverage_fio_expiry_dt date 
,coverage_employer_discount_type_cde varchar(50) 
,coverage_employer_discount_amt numeric(17,4) 
,coverage_employer_discount_pct numeric(9,6) 
,coverage_declared_dividend_amt numeric(17,4) 
,coverage_covered_insured_cde varchar(50) 
,coverage_cash_val_amt numeric(17,4) 
,coverage_cash_val_quality_cde varchar(50) 
,elimination_period_sickness_cde varchar(50) 
,source_waiting_period_sickness_cde varchar(50) 
,source_waiting_period_sickness_day_cde varchar(50) 
,source_waiting_period_sickness_desc varchar(200) 
,elimination_period_injury_cde varchar(50) 
,source_waiting_period_injury_cde varchar(50) 
,source_waiting_period_injury_day_cde varchar(50) 
,source_waiting_period_injury_desc varchar(200) 
,benefit_period_sickness_cde varchar(50) 
,source_benefit_period_sickness_cde varchar(50) 
,source_benefit_period_sickness_duration_cde varchar(50) 
,source_benefit_period_sickness_desc varchar(200) 
,benefit_period_injury_cde varchar(50) 
,source_benefit_period_injury_cde varchar(50) 
,source_benefit_period_injury_duration_cde varchar(50) 
,source_benefit_period_injury_desc varchar(200) 
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
,source_delete_ind boolean NOT NULL DEFAULT false
,coverage_smoker_cde varchar(50) 
,coverage_expiry_dt date 
,source_coverage_smoker_cde varchar(50) 
,flat_extra_amt numeric(17,4) 
,flat_extra_expiry_dt date 
,insured_permanent_temporary_cde varchar(50) 
,substandard_rating_1_pct numeric(9,6) 
,substandard_rating_type_1_cde varchar(50) 
,source_substandard_rating_type_1_cde varchar(50) 
,substandard_rating_2_pct numeric(9,6) 
,substandard_rating_type_2_cde varchar(50) 
,source_substandard_rating_type_2_cde varchar(50) 
,table_rating_cde varchar(50) 
,source_table_rating_cde varchar(50) 
,coverage_table_rating_pct numeric(9,6) 
);