/*
 Log:
    @11/05/2020 :  In Step1&2,Updated current_row_ind,begin_dt,begin_dtm, end_dt and end_dtm as per the updated mapping
 */


--TRUNCATE TABLE edw_staging.aifrps_dim_coverage_initial_load_pre_work;

DELETE FROM edw_staging.aifrps_dim_coverage_initial_load_pre_work;

--TRUNCATE TABLE edw_work.aifrps_dim_coverage_initial_load;
DELETE FROM edw_work.aifrps_dim_coverage_initial_load;


/*INSERT SCRIPT FOR PRE WORK TABLE -ALL RECORDS FROM STG*/

-- Step 1:
INSERT INTO edw_staging.aifrps_dim_coverage_initial_load_pre_work

( dim_coverage_natural_key_hash_uuid
, dim_agreement_natural_key_hash_uuid
, coverage_key_id
, agreement_nr_pfx
, agreement_nr
, agreement_nr_sfx
, agreement_source_cde
, agreement_type_cde
, dim_product_natural_key_hash_uuid
, coverage_pt1_kind_cde
, coverage_pt2_issue_basis_cde
, coverage_pt3_rt_cde
, coverage_sequence_nr
, coverage_long_nm
, coverage_short_nm
, coverage_status_cde
, source_coverage_exception_status_cde
, source_coverage_effective_dt
, source_coverage_effective_dt_txt
, occupation_class_cde
, source_occupation_class_cde
, return_premium_policy_nr
, issue_age_nr
, coverage_type_cde
, minor_product_cde
, coverage_category_cde
, source_coverage_category_cde
, coverage_cease_dt
, coverage_crossover_opt_dt
, coverage_1035_ind
, scheduled_unscheduled_cde
, active_ind
, pending_collection_ind
, increment_counter_nr
, source_coverage_cease_dt_txt
, occupation_class_modifier_nr
, coverage_period_txt
, source_coverage_period_txt
, coverage_person_cde
, coverage_benefit_type_amt
, palir_roll_status_cde
, coverage_face_amt
, coverage_income_amt
, coverage_increase_pct
, coverage_dividend_option_cde
, source_coverage_dividend_option_cde
, coverage_secondary_dividend_option_cde
, source_coverage_secondary_dividend_option_cde
, coverage_conversion_expiry_dt
, coverage_conversion_eligibility_start_dt
, coverage_fio_next_dt
, coverage_fio_expiry_dt
, coverage_employer_discount_type_cde
, coverage_employer_discount_amt
, coverage_employer_discount_pct
, coverage_declared_dividend_amt
, coverage_covered_insured_cde
, coverage_cash_val_amt
, coverage_cash_val_quality_cde
, elimination_period_sickness_cde
, source_waiting_period_sickness_cde
, source_waiting_period_sickness_day_cde
, source_waiting_period_sickness_desc
, elimination_period_injury_cde
, source_waiting_period_injury_cde
, source_waiting_period_injury_day_cde
, source_waiting_period_injury_desc
, benefit_period_sickness_cde
, source_benefit_period_sickness_cde
, source_benefit_period_sickness_duration_cde
, source_benefit_period_sickness_desc
, benefit_period_injury_cde
, source_benefit_period_injury_cde
, source_benefit_period_injury_duration_cde
, source_benefit_period_injury_desc
, begin_dt
, begin_dtm
, row_process_dtm
, check_sum
, end_dt
, end_dtm
, restricted_row_ind
, current_row_ind
, logical_delete_ind
, source_system_id
, audit_id
, update_audit_id
, source_delete_ind
, process_ind
, coverage_smoker_cde
, coverage_expiry_dt
, source_coverage_smoker_cde
, flat_extra_amt
, flat_extra_expiry_dt
, insured_permanent_temporary_cde
, substandard_rating_1_pct
, substandard_rating_type_1_cde
, source_substandard_rating_type_1_cde
, substandard_rating_2_pct
, substandard_rating_type_2_cde
, source_substandard_rating_type_2_cde
, table_rating_cde
, source_table_rating_cde
, coverage_table_rating_pct)


select uuid_gen
           (
               clean_string(calc.covg_row_adm_sys_name),
               clean_string(calc.agreement_type_cde),
               clean_string(calc.agreement_nr_pfx),
               clean_string(calc.agreement_nr),
               clean_string(calc.agreement_nr_sfx),
               clean_string(coverage_pt1_kind_cde),
			   clean_string(calc.coverage_pt2_issue_basis_cde),
               clean_string(calc.coverage_pt3_rt_cde))::uuid
                                                as dim_coverage_natural_key_hash_uuid,
       uuid_gen(clean_string(calc.covg_row_adm_sys_name), 
       			clean_string(calc.agreement_type_cde),
                clean_string(calc.agreement_nr_pfx), 
                clean_string(calc.agreement_nr),
                clean_string(calc.agreement_nr_sfx))::uuid
                                                as dim_agreement_natural_key_hash_uuid,
       prehash_value(
               clean_string(calc.coverage_pt1_kind_cde),
               clean_string(calc.coverage_pt2_issue_basis_cde),
               clean_string(calc.coverage_pt3_rt_cde))       as coverage_key_id,
       calc.agreement_nr_pfx                    as agreement_nr_pfx,
       calc.agreement_nr                        as agreement_nr,
       calc.agreement_nr_sfx                    as agreement_nr_sfx,
       clean_string(calc.covg_row_adm_sys_name) as agreement_source_cde,
       calc.agreement_type_cde                  as agreement_type_cde,
       uuid_gen(prod_id)::uuid                  as dim_product_natural_key_hash_uuid,
       calc.coverage_pt1_kind_cde,
       calc.coverage_pt2_issue_basis_cde,
       calc.coverage_pt3_rt_cde,
       calc.coverage_sequence_nr,
       calc.coverage_long_nm,
       calc.coverage_short_nm,
       calc.coverage_status_cde                 as coverage_status_cde,
       calc.source_coverage_exception_status_cde,
       calc.source_coverage_effective_dt,
       calc.source_coverage_effective_dt_txt,
       calc.occupation_class_cde,
       calc.source_occupation_class_cde,
       calc.return_premium_policy_nr,     -- varchar to integer conversion from src to tgt
       calc.issue_age_nr,
       calc.coverage_type_cde,
       calc.minor_product_cde,
       calc.coverage_category_cde,
       calc.source_coverage_category_cde,
       calc.coverage_cease_dt,
       calc.coverage_crossover_opt_dt,
       calc.coverage_1035_ind,            -- varchar source field target boolean
       calc.scheduled_unscheduled_cde,
       calc.active_ind,                   -- varchar source field target boolean
       calc.pending_collection_ind,       -- varchar source field target boolean
       calc.increment_counter_nr,
       calc.source_coverage_cease_dt_txt,
       calc.occupation_class_modifier_nr, -- varchar to integer conversion from src to tgt
       calc.coverage_period_txt,
       calc.source_coverage_period_txt          as source_coverage_period_txt,
       calc.coverage_person_cde,
       calc.coverage_benefit_type_amt,
       calc.palir_roll_status_cde,
       calc.coverage_face_amt,
       calc.coverage_income_amt,
       calc.coverage_increase_pct               as coverage_increase_pct,
       calc.coverage_dividend_option_cde        as coverage_dividend_option_cde,
       calc.source_coverage_dividend_option_cde,
       calc.coverage_secondary_dividend_option_cde,
       calc.source_coverage_secondary_dividend_option_cde,
       calc.coverage_conversion_expiry_dt,
       calc.coverage_conversion_eligibility_start_dt,
       calc.coverage_fio_next_dt,
       calc.coverage_fio_expiry_dt,
       calc.coverage_employer_discount_type_cde,
       calc.coverage_employer_discount_amt,
       calc.coverage_employer_discount_pct      as coverage_employer_discount_pct,
       calc.coverage_declared_dividend_amt,
       calc.coverage_covered_insured_cde,
       calc.coverage_cash_val_amt,
       calc.coverage_cash_val_quality_cde       as coverage_cash_val_quality_cde,
       calc.elimination_period_sickness_cde     as elimination_period_sickness_cde,
       calc.source_waiting_period_sickness_cde,
       calc.source_waiting_period_sickness_day_cde,
       calc.source_waiting_period_sickness_desc,
       calc.elimination_period_injury_cde       as elimination_period_injury_cde,
       calc.source_waiting_period_injury_cde,
       calc.source_waiting_period_injury_day_cde,
       calc.source_waiting_period_injury_desc,
       calc.benefit_period_sickness_cde         as benefit_period_sickness_cde,
       calc.source_benefit_period_sickness_cde,
       calc.source_benefit_period_sickness_duration_cde,
       calc.source_benefit_period_sickness_desc,
       calc.benefit_period_injury_cde           as benefit_period_injury_cde,
       calc.source_benefit_period_injury_cde,
       calc.source_benefit_period_injury_duration_cde,
       calc.source_benefit_period_injury_desc,
       calc.begin_dt                            as begin_dt,
       calc.begin_dtm                           as begin_dtm,
       calc.row_process_dtm,
       uuid_gen
           (
               calc.source_delete_ind,
               calc.prod_id,
               calc.coverage_sequence_nr,
               clean_string(calc.coverage_long_nm),
		       clean_string(calc.coverage_short_nm),
		       clean_string(calc.coverage_status_cde),
               clean_string(calc.source_coverage_exception_status_cde),
			   calc.source_coverage_effective_dt,
               clean_string(calc.source_coverage_effective_dt_txt_cal),
               clean_string(calc.coverage_type_cde),
               clean_string(calc.minor_product_cde),
               clean_string(calc.coverage_category_cde),
               calc.coverage_cease_dt_cal,
               calc.increment_counter_nr,
               clean_string(calc.source_coverage_cease_dt_txt),
			   calc.coverage_face_amt,
               calc.coverage_income_amt,
               calc.coverage_increase_pct,
               clean_string(calc.coverage_dividend_option_cde),
               clean_string(calc.source_coverage_dividend_option_cde),
               clean_string(calc.coverage_secondary_dividend_option_cde),
               clean_string(calc.source_coverage_secondary_dividend_option_cde),
               calc.coverage_conversion_expiry_dt,
               calc.coverage_conversion_eligibility_start_dt,
               calc.coverage_fio_next_dt,
               calc.coverage_fio_expiry_dt,
               clean_string(calc.coverage_employer_discount_type_cde),
               calc.coverage_employer_discount_amt,
               calc.coverage_employer_discount_pct,
               calc.coverage_declared_dividend_amt,
               clean_string(calc.coverage_covered_insured_cde),
               calc.coverage_cash_val_amt,
               clean_string(calc.coverage_cash_val_quality_cde)) :: uuid                            as check_sum,

       calc.end_dt,
       calc.end_dtm,
       calc.restricted_row_ind,
       calc.current_row_ind,
       calc.logical_delete_ind,
       calc.source_system_id,
       calc.audit_id,
       calc.update_audit_id,
       calc.source_delete_ind,
       calc.process_ind,
       calc.coverage_smoker_cde,
       calc.coverage_expiry_dt,
       calc.source_coverage_smoker_cde,
       calc.flat_extra_amt,
       calc.flat_extra_expiry_dt,
       calc.insured_permanent_temporary_cde,
       calc.substandard_rating_1_pct,
       calc.substandard_rating_type_1_cde,
       calc.source_substandard_rating_type_1_cde,
       calc.substandard_rating_2_pct,
       calc.substandard_rating_type_2_cde,
       calc.source_substandard_rating_type_2_cde,
       calc.table_rating_cde,
       calc.source_table_rating_cde,
       calc.coverage_table_rating_pct
from (
	select cov.carr_admin_sys_cd                               as covg_row_adm_sys_name,
                'Ipa'                                               as agreement_type_cde,
                cov.hldg_key_pfx                                    as agreement_nr_pfx,
                cov.hldg_key                                        as agreement_nr,
                cov.hldg_key_sfx                                    as agreement_nr_sfx,
                clean_string(cov.prod_id)                           as prod_id,
                cov.prod_typ_cd_1                                   as coverage_pt1_kind_cde,
                cov.prod_typ_cd_2                                   as coverage_pt2_issue_basis_cde,
                cov.prod_typ_cd_3                                   as coverage_pt3_rt_cde,
                cov.cvg_seq_nbr                                     as coverage_sequence_nr,
                cov.cvg_lng_nm                                      as coverage_long_nm,
                cov.cvg_sht_nm                                      as coverage_short_nm,
                cov.cvg_xcpt_stus_cd                                as coverage_status_cde,
                cov.src_cvg_xcpt_stus_cd                            as source_coverage_exception_status_cde,
                to_date(to_char(cov.src_cvg_eff_dt), 'yyyy-mm-dd')  as source_coverage_effective_dt,
                cov.src_cvg_eff_txt                                 as source_coverage_effective_dt_txt,
                to_char(to_number(cov.src_cvg_eff_txt))             as source_coverage_effective_dt_txt_cal,
                cov.occ_cls_cd                                      as occupation_class_cde,
                cov.src_occ_cls_cd                                  as source_occupation_class_cde,
                to_number(clean_string(cov.rtrn_prem_pol_nbr))      as return_premium_policy_nr,
                cov.iss_age                                         as issue_age_nr,
                cov.rdr_typ_cd                                      as coverage_type_cde,
                cov.mnr_prod_cd                                     as minor_product_cde,
                cov.cvg_ctgry_cd                                    as coverage_category_cde,
                cov.src_cvg_ctgry_cd                                as source_coverage_category_cde,
                cov.cvg_cease_dt                                    as coverage_cease_dt,
                to_date(to_char(cov.cvg_cease_dt), 'yyyy-mm-dd')    as coverage_cease_dt_cal,
                cov.cvg_xovr_opt_dt                                 as coverage_crossover_opt_dt,
                to_date(to_char(cov.cvg_xovr_opt_dt), 'yyyy-mm-dd') as coverage_crossover_opt_dt_cal,
                case
                    when clean_string(cov.cvg_1035_ind) is null
                        or clean_string(cov.cvg_1035_ind) = ''
                        then null
                    when clean_string(cov.cvg_1035_ind) = 'N'
                        then false
                    when clean_string(cov.cvg_1035_ind) = 'Y'
                        then true
                    end                                             as coverage_1035_ind,
                cov.schd_unschd_cd                                  as scheduled_unscheduled_cde,
                case
                    when clean_string(cov.actv_ind) is null
                        or clean_string(cov.actv_ind) = ''
                        then null
                    when clean_string(cov.actv_ind) = 'N'
                        then false
                    when clean_string(cov.actv_ind) = 'Y'
                        then true
                    end                                             as active_ind,
                case
                    when clean_string(cov.pnd_coll_ind) is null
                        or clean_string(cov.pnd_coll_ind) = ''
                        then null
                    when clean_string(cov.pnd_coll_ind) = 'N'
                        then false
                    when clean_string(cov.pnd_coll_ind) = 'Y'
                        then true
                    end                                             as pending_collection_ind,
                cov.incr_cntr                                       as increment_counter_nr,
                cov.cvg_cease_dt_txt                                as source_coverage_cease_dt_txt,
                to_number(clean_string(cov.occ_cls_mod))            as occupation_class_modifier_nr,
                cov.cvg_period                                      as coverage_period_txt,
                cov.src_cvg_period                                  as source_coverage_period_txt,
                cov.cvg_prsn_cd                                     as coverage_person_cde,
                cov.bene_typ_amt                                    as coverage_benefit_type_amt,
                cov.palir_roll_sts_cd                               as palir_roll_status_cde,
                covben.cvg_face_amt                                 as coverage_face_amt,
                covben.cvg_incm_amt                                 as coverage_income_amt,
                covben.cvg_incr_pct                                 as coverage_increase_pct,
                covben.cvg_divd_opt_cd                              as coverage_dividend_option_cde,
                covben.cvg_src_divd_opt_cd                          as source_coverage_dividend_option_cde,
                covben.cvg_scnd_divd_opt_cd                         as coverage_secondary_dividend_option_cde,
                covben.cvg_src_scnd_divd_opt_cd                     as source_coverage_secondary_dividend_option_cde,
                covben.conv_exp_dt                                  as coverage_conversion_expiry_dt,
                covben.conv_elig_strt_dt                            as coverage_conversion_eligibility_start_dt,
                covben.nxt_fio_dt                                   as coverage_fio_next_dt,
                covben.fio_exp_dt                                   as coverage_fio_expiry_dt,
                covben.emp_dscnt_typ_cd                             as coverage_employer_discount_type_cde,
                covben.emp_dscnt_amt                                as coverage_employer_discount_amt,
                covben.emp_dscnt_pct                                as coverage_employer_discount_pct,
                covben.cvg_dclr_dvd_amt                             as coverage_declared_dividend_amt,
                covben.covered_insd_cd                              as coverage_covered_insured_cde,
                covben.cvg_csh_val_amt                              as coverage_cash_val_amt,
                covben.cvg_csh_val_qlty_cd                          as coverage_cash_val_quality_cde,
                NULL					                            as elimination_period_sickness_cde,
                NULL					                            as source_waiting_period_sickness_cde,
                NULL					                            as source_waiting_period_sickness_day_cde,
                NULL					                            as source_waiting_period_sickness_desc,
                NULL					                            as elimination_period_injury_cde,
                NULL					                            as source_waiting_period_injury_cde,
                NULL					                            as source_waiting_period_injury_day_cde,
                NULL					                            as source_waiting_period_injury_desc,
                NULL					                            as benefit_period_sickness_cde,
                NULL					                            as source_benefit_period_sickness_cde,
                NULL					                            as source_benefit_period_sickness_duration_cde,
                NULL					                            as source_benefit_period_sickness_desc,
                NULL					                            as benefit_period_injury_cde,
                NULL					                            as source_benefit_period_injury_cde,
                NULL					                            as source_benefit_period_injury_duration_cde,
                NULL					                            as source_benefit_period_injury_desc,
                case
                    when cov.current_batch = true
                        then to_date(to_char(cov.trans_dt), 'yyyy-mm-dd')
                    when covben.current_batch = true
                        then to_date(to_char(covben.trans_dt), 'yyyy-mm-dd')
                    end                                             as begin_dt,
                case
                    when cov.current_batch = true
                        then to_date(to_char(cov.trans_dt), 'yyyy-mm-dd') :: timestamp
                    when covben.current_batch = true
                        then to_date(to_char(covben.trans_dt), 'yyyy-mm-dd') :: timestamp
                    end                                             as begin_dtm,
                current_timestamp(6)                                as row_process_dtm,
                null                                                as check_sum,        -- will be updated in the outer qry
                '9999-12-31'::date								    as end_dt,
                '9999-12-31'::timestamp								as end_dtm,
                false                                               as restricted_row_ind,
                true                              					as current_row_ind,
                false                                               as logical_delete_ind,
                266                                                 as source_system_id, -- Initial load  source_system_id = 266
                :RUN_ID                	        	                as audit_id,
                :RUN_ID                       		                as update_audit_id,
                case
                    when cov.current_batch = true and upper(cov.src_del_ind) = 'Y'
                        then true
                    when covben.current_batch = true and upper(covben.src_del_ind) = 'Y'
                        then true
                    else false
                    end                                             as source_delete_ind,
                cov.src_del_ind                                     as process_ind,
                NULL					                            as coverage_smoker_cde,
                NULL                                                as coverage_expiry_dt,
                NULL					                            as source_coverage_smoker_cde,
                NULL					                            as flat_extra_amt,
                NULL					                            as flat_extra_expiry_dt,
                NULL					                            as insured_permanent_temporary_cde,
                NULL					                            as substandard_rating_1_pct,
                NULL					                            as substandard_rating_type_1_cde,
                NULL					                            as source_substandard_rating_type_1_cde,
                NULL					                            as substandard_rating_2_pct,
                NULL					                            as substandard_rating_type_2_cde,
                NULL					                            as source_substandard_rating_type_2_cde,
                NULL					                            as table_rating_cde,
                NULL					                            as source_table_rating_cde,
                NULL					                            as coverage_table_rating_pct

         from edw_staging.aifrps_agmt_cvg_vw_snapshot cov
                  left join
              edw_staging.aifrps_agmt_cvg_ben_vw_snapshot covben
              on
                  cov.agmt_cvg_id = covben.agmt_cvg_id

         where (cov.current_batch = true
             or covben.current_batch = true
               )
    ) calc

;
--------------------------------------------------------------------------
-- Step 2:

insert into edw_work.aifrps_dim_coverage_initial_load
(
 dim_coverage_natural_key_hash_uuid
, dim_agreement_natural_key_hash_uuid
, coverage_key_id
, agreement_nr_pfx
, agreement_nr
, agreement_nr_sfx 
, agreement_source_cde
, agreement_type_cde
, dim_product_natural_key_hash_uuid
, coverage_pt1_kind_cde
, coverage_pt2_issue_basis_cde
, coverage_pt3_rt_cde
, coverage_sequence_nr
, coverage_long_nm
, coverage_short_nm
, coverage_status_cde
, source_coverage_exception_status_cde
, source_coverage_effective_dt
, source_coverage_effective_dt_txt
, occupation_class_cde
, source_occupation_class_cde
, return_premium_policy_nr
, issue_age_nr
, coverage_type_cde
, minor_product_cde
, coverage_category_cde
, source_coverage_category_cde
, coverage_cease_dt
, coverage_crossover_opt_dt
, coverage_1035_ind
, scheduled_unscheduled_cde
, active_ind
, pending_collection_ind
, increment_counter_nr
, source_coverage_cease_dt_txt
, occupation_class_modifier_nr
, coverage_period_txt
, source_coverage_period_txt
, coverage_person_cde
, coverage_benefit_type_amt
, palir_roll_status_cde
, coverage_face_amt
, coverage_income_amt
, coverage_increase_pct
, coverage_dividend_option_cde
, source_coverage_dividend_option_cde
, coverage_secondary_dividend_option_cde
, source_coverage_secondary_dividend_option_cde
, coverage_conversion_expiry_dt
, coverage_conversion_eligibility_start_dt
, coverage_fio_next_dt
, coverage_fio_expiry_dt
, coverage_employer_discount_type_cde
, coverage_employer_discount_amt
, coverage_employer_discount_pct
, coverage_declared_dividend_amt
, coverage_covered_insured_cde
, coverage_cash_val_amt
, coverage_cash_val_quality_cde
, elimination_period_sickness_cde
, source_waiting_period_sickness_cde
, source_waiting_period_sickness_day_cde
, source_waiting_period_sickness_desc
, elimination_period_injury_cde
, source_waiting_period_injury_cde
, source_waiting_period_injury_day_cde
, source_waiting_period_injury_desc
, benefit_period_sickness_cde
, source_benefit_period_sickness_cde
, source_benefit_period_sickness_duration_cde
, source_benefit_period_sickness_desc
, benefit_period_injury_cde
, source_benefit_period_injury_cde
, source_benefit_period_injury_duration_cde
, source_benefit_period_injury_desc
, begin_dt
, begin_dtm
, row_process_dtm
, check_sum
, end_dt
, end_dtm
, restricted_row_ind
, current_row_ind
, logical_delete_ind
, source_system_id
, audit_id
, update_audit_id
, source_delete_ind
, coverage_smoker_cde
, coverage_expiry_dt
, source_coverage_smoker_cde
, flat_extra_amt
, flat_extra_expiry_dt
, insured_permanent_temporary_cde
, substandard_rating_1_pct
, substandard_rating_type_1_cde
, source_substandard_rating_type_1_cde
, substandard_rating_2_pct
, substandard_rating_type_2_cde
, source_substandard_rating_type_2_cde
, table_rating_cde
, source_table_rating_cde
, coverage_table_rating_pct)

select prework.dim_coverage_natural_key_hash_uuid
     , prework.dim_agreement_natural_key_hash_uuid
     , prework.coverage_key_id
     , prework.agreement_nr_pfx
     , prework.agreement_nr
     , prework.agreement_nr_sfx
     , prework.agreement_source_cde
     , prework.agreement_type_cde
     , prework.dim_product_natural_key_hash_uuid
     , prework.coverage_pt1_kind_cde
     , prework.coverage_pt2_issue_basis_cde
     , prework.coverage_pt3_rt_cde
     , prework.coverage_sequence_nr
     , prework.coverage_long_nm
     , prework.coverage_short_nm
     , prework.coverage_status_cde
     , prework.source_coverage_exception_status_cde
     , prework.source_coverage_effective_dt
     , prework.source_coverage_effective_dt_txt
     , prework.occupation_class_cde
     , prework.source_occupation_class_cde
     , prework.return_premium_policy_nr
     , prework.issue_age_nr
     , prework.coverage_type_cde
     , prework.minor_product_cde
     , prework.coverage_category_cde
     , prework.source_coverage_category_cde
     , prework.coverage_cease_dt
     , prework.coverage_crossover_opt_dt
     , prework.coverage_1035_ind
     , prework.scheduled_unscheduled_cde
     , prework.active_ind
     , prework.pending_collection_ind
     , prework.increment_counter_nr
     , prework.source_coverage_cease_dt_txt
     , prework.occupation_class_modifier_nr
     , prework.coverage_period_txt
     , prework.source_coverage_period_txt
     , prework.coverage_person_cde
     , prework.coverage_benefit_type_amt
     , prework.palir_roll_status_cde
     , prework.coverage_face_amt
     , prework.coverage_income_amt
     , prework.coverage_increase_pct
     , prework.coverage_dividend_option_cde
     , prework.source_coverage_dividend_option_cde
     , prework.coverage_secondary_dividend_option_cde
     , prework.source_coverage_secondary_dividend_option_cde
     , prework.coverage_conversion_expiry_dt
     , prework.coverage_conversion_eligibility_start_dt
     , prework.coverage_fio_next_dt
     , prework.coverage_fio_expiry_dt
     , prework.coverage_employer_discount_type_cde
     , prework.coverage_employer_discount_amt
     , prework.coverage_employer_discount_pct
     , prework.coverage_declared_dividend_amt
     , prework.coverage_covered_insured_cde
     , prework.coverage_cash_val_amt
     , prework.coverage_cash_val_quality_cde
     , prework.elimination_period_sickness_cde
     , prework.source_waiting_period_sickness_cde
     , prework.source_waiting_period_sickness_day_cde
     , prework.source_waiting_period_sickness_desc
     , prework.elimination_period_injury_cde
     , prework.source_waiting_period_injury_cde
     , prework.source_waiting_period_injury_day_cde
     , prework.source_waiting_period_injury_desc
     , prework.benefit_period_sickness_cde
     , prework.source_benefit_period_sickness_cde
     , prework.source_benefit_period_sickness_duration_cde
     , prework.source_benefit_period_sickness_desc
     , prework.benefit_period_injury_cde
     , prework.source_benefit_period_injury_cde
     , prework.source_benefit_period_injury_duration_cde
     , prework.source_benefit_period_injury_desc

     , prework.begin_dt
     , prework.begin_dtm
     , current_timestamp(6) as row_process_dtm
     , prework.check_sum
     , prework.end_dt       as end_dt
     , prework.end_dtm      as end_dtm
     , prework.restricted_row_ind
     , prework.current_row_ind
     , prework.logical_delete_ind
     , prework.source_system_id
     , prework.audit_id
     , prework.update_audit_id
     , prework.source_delete_ind

     , prework.coverage_smoker_cde
     , prework.coverage_expiry_dt
     , prework.source_coverage_smoker_cde
     , prework.flat_extra_amt
     , prework.flat_extra_expiry_dt
     , prework.insured_permanent_temporary_cde
     , prework.substandard_rating_1_pct
     , prework.substandard_rating_type_1_cde
     , prework.source_substandard_rating_type_1_cde
     , prework.substandard_rating_2_pct
     , prework.substandard_rating_type_2_cde
     , prework.source_substandard_rating_type_2_cde
     , prework.table_rating_cde
     , prework.source_table_rating_cde
     , prework.coverage_table_rating_pct

from edw_staging.aifrps_dim_coverage_initial_load_pre_work prework
--insert when no records in target table insert only
where dim_coverage_natural_key_hash_uuid not in
      (select distinct dim_coverage_natural_key_hash_uuid
       from edw_tdsunset.dim_coverage
            --edw_work.aifrps_dim_coverage_initial_load_target
       where source_system_id = 266
         and logical_delete_ind = false -- Initial load  source_system_id = 266
      )
--and prework.source_delete_ind = false

;


/* EDW_WORK.aifrpsLIFE_DIM_COVERAGE_INITIAL_LOAD WORK TABLE - UPDATE TGT RECORD
 *
 * THIS SCRIPT FINDS RECORDS WHERE THE NEW RECORD FROM THE SOURCE HAS A DIFFERENT CHECK_SUM THAN THE CURRENT TARGET RECORD.
 * THE CURRENT RECORD IN THE TARGET WILL BE ENDED SINCE THE SOURCE RECORD WILL BE INSERTED IN THE NEXT STEP.
 * */


insert into edw_work.aifrps_dim_coverage_initial_load

( dim_coverage_natural_key_hash_uuid
, dim_agreement_natural_key_hash_uuid
, coverage_key_id
, agreement_nr_pfx
, agreement_nr
, agreement_nr_sfx
, agreement_source_cde
, agreement_type_cde
, dim_product_natural_key_hash_uuid
, coverage_pt1_kind_cde
, coverage_pt2_issue_basis_cde
, coverage_pt3_rt_cde
, coverage_sequence_nr
, coverage_long_nm
, coverage_short_nm
, coverage_status_cde
, source_coverage_exception_status_cde
, source_coverage_effective_dt
, source_coverage_effective_dt_txt
, occupation_class_cde
, source_occupation_class_cde
, return_premium_policy_nr
, issue_age_nr
, coverage_type_cde
, minor_product_cde
, coverage_category_cde
, source_coverage_category_cde
, coverage_cease_dt
, coverage_crossover_opt_dt
, coverage_1035_ind
, scheduled_unscheduled_cde
, active_ind
, pending_collection_ind
, increment_counter_nr
, source_coverage_cease_dt_txt
, occupation_class_modifier_nr
, coverage_period_txt
, source_coverage_period_txt
, coverage_person_cde
, coverage_benefit_type_amt
, palir_roll_status_cde
, coverage_face_amt
, coverage_income_amt
, coverage_increase_pct
, coverage_dividend_option_cde
, source_coverage_dividend_option_cde
, coverage_secondary_dividend_option_cde
, source_coverage_secondary_dividend_option_cde
, coverage_conversion_expiry_dt
, coverage_conversion_eligibility_start_dt
, coverage_fio_next_dt
, coverage_fio_expiry_dt
, coverage_employer_discount_type_cde
, coverage_employer_discount_amt
, coverage_employer_discount_pct
, coverage_declared_dividend_amt
, coverage_covered_insured_cde
, coverage_cash_val_amt
, coverage_cash_val_quality_cde
, elimination_period_sickness_cde
, source_waiting_period_sickness_cde
, source_waiting_period_sickness_day_cde
, source_waiting_period_sickness_desc
, elimination_period_injury_cde
, source_waiting_period_injury_cde
, source_waiting_period_injury_day_cde
, source_waiting_period_injury_desc
, benefit_period_sickness_cde
, source_benefit_period_sickness_cde
, source_benefit_period_sickness_duration_cde
, source_benefit_period_sickness_desc
, benefit_period_injury_cde
, source_benefit_period_injury_cde
, source_benefit_period_injury_duration_cde
, source_benefit_period_injury_desc
, begin_dt
, begin_dtm
, row_process_dtm
, check_sum
, end_dt
, end_dtm
, restricted_row_ind
, current_row_ind
, logical_delete_ind
, source_system_id
, audit_id
, update_audit_id
, source_delete_ind
, coverage_smoker_cde
, coverage_expiry_dt
, source_coverage_smoker_cde
, flat_extra_amt
, flat_extra_expiry_dt
, insured_permanent_temporary_cde
, substandard_rating_1_pct
, substandard_rating_type_1_cde
, source_substandard_rating_type_1_cde
, substandard_rating_2_pct
, substandard_rating_type_2_cde
, source_substandard_rating_type_2_cde
, table_rating_cde
, source_table_rating_cde
, coverage_table_rating_pct)

select dim.dim_coverage_natural_key_hash_uuid
     , dim.dim_agreement_natural_key_hash_uuid
     , dim.coverage_key_id
     , dim.agreement_nr_pfx
     , dim.agreement_nr
     , dim.agreement_nr_sfx
     , dim.agreement_source_cde
     , dim.agreement_type_cde
     , dim.dim_product_natural_key_hash_uuid
     , dim.coverage_pt1_kind_cde
     , dim.coverage_pt2_issue_basis_cde
     , dim.coverage_pt3_rt_cde
     , dim.coverage_sequence_nr
     , dim.coverage_long_nm
     , dim.coverage_short_nm
     , dim.coverage_status_cde
     , dim.source_coverage_exception_status_cde
     , dim.source_coverage_effective_dt
     , dim.source_coverage_effective_dt_txt
     , dim.occupation_class_cde
     , dim.source_occupation_class_cde
     , dim.return_premium_policy_nr
     , dim.issue_age_nr
     , dim.coverage_type_cde
     , dim.minor_product_cde
     , dim.coverage_category_cde
     , dim.source_coverage_category_cde
     , dim.coverage_cease_dt
     , dim.coverage_crossover_opt_dt
     , dim.coverage_1035_ind
     , dim.scheduled_unscheduled_cde
     , dim.active_ind
     , dim.pending_collection_ind
     , dim.increment_counter_nr
     , dim.source_coverage_cease_dt_txt
     , dim.occupation_class_modifier_nr
     , dim.coverage_period_txt
     , dim.source_coverage_period_txt
     , dim.coverage_person_cde
     , dim.coverage_benefit_type_amt
     , dim.palir_roll_status_cde
     , dim.coverage_face_amt
     , dim.coverage_income_amt
     , dim.coverage_increase_pct
     , dim.coverage_dividend_option_cde
     , dim.source_coverage_dividend_option_cde
     , dim.coverage_secondary_dividend_option_cde
     , dim.source_coverage_secondary_dividend_option_cde
     , dim.coverage_conversion_expiry_dt
     , dim.coverage_conversion_eligibility_start_dt
     , dim.coverage_fio_next_dt
     , dim.coverage_fio_expiry_dt
     , dim.coverage_employer_discount_type_cde
     , dim.coverage_employer_discount_amt
     , dim.coverage_employer_discount_pct
     , dim.coverage_declared_dividend_amt
     , dim.coverage_covered_insured_cde
     , dim.coverage_cash_val_amt
     , dim.coverage_cash_val_quality_cde
     , dim.elimination_period_sickness_cde
     , dim.source_waiting_period_sickness_cde
     , dim.source_waiting_period_sickness_day_cde
     , dim.source_waiting_period_sickness_desc
     , dim.elimination_period_injury_cde
     , dim.source_waiting_period_injury_cde
     , dim.source_waiting_period_injury_day_cde
     , dim.source_waiting_period_injury_desc
     , dim.benefit_period_sickness_cde
     , dim.source_benefit_period_sickness_cde
     , dim.source_benefit_period_sickness_duration_cde
     , dim.source_benefit_period_sickness_desc
     , dim.benefit_period_injury_cde
     , dim.source_benefit_period_injury_cde
     , dim.source_benefit_period_injury_duration_cde
     , dim.source_benefit_period_injury_desc

     , dim.begin_dt
     , dim.begin_dtm
     , current_timestamp(6)                    as row_process_dtm
     , dim.check_sum
     , prework.begin_dt - interval '1' day     as end_dt
     , prework.begin_dtm - interval '1' second as end_dtm
     , dim.restricted_row_ind
     , false                                   as current_row_ind
     , dim.logical_delete_ind
     , dim.source_system_id
     , dim.audit_id                            as audit_id
     , :RUN_ID                                 as update_audit_id
     , dim.source_delete_ind

     , dim.coverage_smoker_cde
     , dim.coverage_expiry_dt
     , dim.source_coverage_smoker_cde
     , dim.flat_extra_amt
     , dim.flat_extra_expiry_dt
     , dim.insured_permanent_temporary_cde
     , dim.substandard_rating_1_pct
     , dim.substandard_rating_type_1_cde
     , dim.source_substandard_rating_type_1_cde
     , dim.substandard_rating_2_pct
     , dim.substandard_rating_type_2_cde
     , dim.source_substandard_rating_type_2_cde
     , dim.table_rating_cde
     , dim.source_table_rating_cde
     , dim.coverage_table_rating_pct

from edw_tdsunset.dim_coverage dim
--edw_work.aifrps_dim_coverage_initial_load_target dim
         join
     edw_staging.aifrps_dim_coverage_initial_load_pre_work prework
     on dim.dim_coverage_natural_key_hash_uuid = prework.dim_coverage_natural_key_hash_uuid
         and dim.current_row_ind = true
--and prework.source_delete_ind = false

where (dim.check_sum <> prework.check_sum);


/* EDW_WORK.edw_work.aifrps_dim_coverage_initial_load WORK TABLE WORK TABLE - UPDATE WHERE RECORD ALREADY EXISTS IN TARGET
 *
 *
 * */

insert into edw_work.aifrps_dim_coverage_initial_load

( dim_coverage_natural_key_hash_uuid
, dim_agreement_natural_key_hash_uuid
, coverage_key_id
, agreement_nr_pfx
, agreement_nr
, agreement_nr_sfx 
, agreement_source_cde
, agreement_type_cde
, dim_product_natural_key_hash_uuid
, coverage_pt1_kind_cde
, coverage_pt2_issue_basis_cde
, coverage_pt3_rt_cde
, coverage_sequence_nr
, coverage_long_nm
, coverage_short_nm
, coverage_status_cde
, source_coverage_exception_status_cde
, source_coverage_effective_dt
, source_coverage_effective_dt_txt
, occupation_class_cde
, source_occupation_class_cde
, return_premium_policy_nr
, issue_age_nr
, coverage_type_cde
, minor_product_cde
, coverage_category_cde
, source_coverage_category_cde
, coverage_cease_dt
, coverage_crossover_opt_dt
, coverage_1035_ind
, scheduled_unscheduled_cde
, active_ind
, pending_collection_ind
, increment_counter_nr
, source_coverage_cease_dt_txt
, occupation_class_modifier_nr
, coverage_period_txt
, source_coverage_period_txt
, coverage_person_cde
, coverage_benefit_type_amt
, palir_roll_status_cde
, coverage_face_amt
, coverage_income_amt
, coverage_increase_pct
, coverage_dividend_option_cde
, source_coverage_dividend_option_cde
, coverage_secondary_dividend_option_cde
, source_coverage_secondary_dividend_option_cde
, coverage_conversion_expiry_dt
, coverage_conversion_eligibility_start_dt
, coverage_fio_next_dt
, coverage_fio_expiry_dt
, coverage_employer_discount_type_cde
, coverage_employer_discount_amt
, coverage_employer_discount_pct
, coverage_declared_dividend_amt
, coverage_covered_insured_cde
, coverage_cash_val_amt
, coverage_cash_val_quality_cde
, elimination_period_sickness_cde
, source_waiting_period_sickness_cde
, source_waiting_period_sickness_day_cde
, source_waiting_period_sickness_desc
, elimination_period_injury_cde
, source_waiting_period_injury_cde
, source_waiting_period_injury_day_cde
, source_waiting_period_injury_desc
, benefit_period_sickness_cde
, source_benefit_period_sickness_cde
, source_benefit_period_sickness_duration_cde
, source_benefit_period_sickness_desc
, benefit_period_injury_cde
, source_benefit_period_injury_cde
, source_benefit_period_injury_duration_cde
, source_benefit_period_injury_desc
, begin_dt
, begin_dtm
, row_process_dtm
, check_sum
, end_dt
, end_dtm
, restricted_row_ind
, current_row_ind
, logical_delete_ind
, source_system_id
, audit_id
, update_audit_id
, source_delete_ind
, coverage_smoker_cde
, coverage_expiry_dt
, source_coverage_smoker_cde
, flat_extra_amt
, flat_extra_expiry_dt
, insured_permanent_temporary_cde
, substandard_rating_1_pct
, substandard_rating_type_1_cde
, source_substandard_rating_type_1_cde
, substandard_rating_2_pct
, substandard_rating_type_2_cde
, source_substandard_rating_type_2_cde
, table_rating_cde
, source_table_rating_cde
, coverage_table_rating_pct)

select prework.dim_coverage_natural_key_hash_uuid
     , prework.dim_agreement_natural_key_hash_uuid
     , prework.coverage_key_id
     , prework.agreement_nr_pfx
     , prework.agreement_nr
     , prework.agreement_nr_sfx
     , prework.agreement_source_cde
     , prework.agreement_type_cde
     , prework.dim_product_natural_key_hash_uuid
     , prework.coverage_pt1_kind_cde
     , prework.coverage_pt2_issue_basis_cde
     , prework.coverage_pt3_rt_cde
     , prework.coverage_sequence_nr
     , prework.coverage_long_nm
     , prework.coverage_short_nm
     , prework.coverage_status_cde
     , prework.source_coverage_exception_status_cde
     , prework.source_coverage_effective_dt
     , prework.source_coverage_effective_dt_txt
     , prework.occupation_class_cde
     , prework.source_occupation_class_cde
     , prework.return_premium_policy_nr
     , prework.issue_age_nr
     , prework.coverage_type_cde
     , prework.minor_product_cde
     , prework.coverage_category_cde
     , prework.source_coverage_category_cde
     , prework.coverage_cease_dt
     , prework.coverage_crossover_opt_dt
     , prework.coverage_1035_ind
     , prework.scheduled_unscheduled_cde
     , prework.active_ind
     , prework.pending_collection_ind
     , prework.increment_counter_nr
     , prework.source_coverage_cease_dt_txt
     , prework.occupation_class_modifier_nr
     , prework.coverage_period_txt
     , prework.source_coverage_period_txt
     , prework.coverage_person_cde
     , prework.coverage_benefit_type_amt
     , prework.palir_roll_status_cde
     , prework.coverage_face_amt
     , prework.coverage_income_amt
     , prework.coverage_increase_pct
     , prework.coverage_dividend_option_cde
     , prework.source_coverage_dividend_option_cde
     , prework.coverage_secondary_dividend_option_cde
     , prework.source_coverage_secondary_dividend_option_cde
     , prework.coverage_conversion_expiry_dt
     , prework.coverage_conversion_eligibility_start_dt
     , prework.coverage_fio_next_dt
     , prework.coverage_fio_expiry_dt
     , prework.coverage_employer_discount_type_cde
     , prework.coverage_employer_discount_amt
     , prework.coverage_employer_discount_pct
     , prework.coverage_declared_dividend_amt
     , prework.coverage_covered_insured_cde
     , prework.coverage_cash_val_amt
     , prework.coverage_cash_val_quality_cde
     , prework.elimination_period_sickness_cde
     , prework.source_waiting_period_sickness_cde
     , prework.source_waiting_period_sickness_day_cde
     , prework.source_waiting_period_sickness_desc
     , prework.elimination_period_injury_cde
     , prework.source_waiting_period_injury_cde
     , prework.source_waiting_period_injury_day_cde
     , prework.source_waiting_period_injury_desc
     , prework.benefit_period_sickness_cde
     , prework.source_benefit_period_sickness_cde
     , prework.source_benefit_period_sickness_duration_cde
     , prework.source_benefit_period_sickness_desc
     , prework.benefit_period_injury_cde
     , prework.source_benefit_period_injury_cde
     , prework.source_benefit_period_injury_duration_cde
     , prework.source_benefit_period_injury_desc

     , prework.begin_dt
     , prework.begin_dtm
     , current_timestamp(6) as row_process_dtm
     , prework.check_sum
     , prework.end_dt       as end_dt
     , prework.end_dtm      as end_dtm
     , prework.restricted_row_ind
     , prework.current_row_ind
     , prework.logical_delete_ind
     , prework.source_system_id
     , prework.audit_id
     , prework.update_audit_id
     , prework.source_delete_ind

     , prework.coverage_smoker_cde
     , prework.coverage_expiry_dt
     , prework.source_coverage_smoker_cde
     , prework.flat_extra_amt
     , prework.flat_extra_expiry_dt
     , prework.insured_permanent_temporary_cde
     , prework.substandard_rating_1_pct
     , prework.substandard_rating_type_1_cde
     , prework.source_substandard_rating_type_1_cde
     , prework.substandard_rating_2_pct
     , prework.substandard_rating_type_2_cde
     , prework.source_substandard_rating_type_2_cde
     , prework.table_rating_cde
     , prework.source_table_rating_cde
     , prework.coverage_table_rating_pct

from edw_staging.aifrps_dim_coverage_initial_load_pre_work prework
         join
     edw_tdsunset.dim_coverage dim
         --edw_work.aifrps_dim_coverage_initial_load_target dim
     on dim.dim_coverage_natural_key_hash_uuid = prework.dim_coverage_natural_key_hash_uuid
         and dim.current_row_ind = true
/*and prework.source_delete_ind = false*/
where (dim.check_sum <> prework.check_sum)
;



