--drop table if exists COVG_PROD_ID_HASH;

/*
		FILENAME: aifrps_DIM_COVERAGE.SQL
		AUTHOR: MM16034
		SUBJECT AREA : AGREEMENT
		SOURCE: AIF-RPS
		TERADATA SOURCE CODE: 72
		DESCRIPTION: DIM_COVERAGE TABLE POPULATION
		JIRA:
		CREATE DATE:2021-06-24

		===============================================================================================================
		VERSION/JIRA STORY#			CREATED BY          LAST_MODIFIED_DATE		DESCRIPTION
		---------------------------------------------------------------------------------------------------------------
		JIRA  TERSUNKB-1973      AGREEMENT TIER-2    2021-06-28			    FIRST VERSION OF DDL FOR TIER-2
		---------------------------------------------------------------------------------------------------------------
*/




/* TRUNCATE STAGING PRE WORK TABLE */
truncate table edw_staging.aifrps_dim_coverage_pre_work;

/*TRUNCATE WORK TABLE */
truncate table edw_work.aifrps_dim_coverage;


select analyze_statistics('edw_staging.aif_rps_edw_ctrt_delta_dedup');

/*create temp table to join coverage,contract and product translator*/

CREATE LOCAL TEMPORARY TABLE COVG_PROD_ID_HASH ON
COMMIT PRESERVE ROWS AS
select
	coverage_pt1_kind_cde,
	coverage_pt2_issue_basis_cde,
	coverage_pt3_rt_cde,
	pdt1.prod_id,
    pdt1.prod_typ_cde,
    pdt1.prod_typ_nme,
    pdt1.minor_prod_cde
from
	(
	select 'INPRT' as coverage_pt1_kind_cde,
    '00' as coverage_pt2_issue_basis_cde,
    'RPS' as coverage_pt3_rt_cde  
UNION
select
    'AIR' as coverage_pt1_kind_cde,
    '00' as coverage_pt2_issue_basis_cde,
    'RPS' as coverage_pt3_rt_cde
UNION
select
    'PAPRT' as coverage_pt1_kind_cde,
    '00' as coverage_pt2_issue_basis_cde,
    'RPS' as coverage_pt3_rt_cde
UNION
select
    'BUPRT' as coverage_pt1_kind_cde,
    '00' as coverage_pt2_issue_basis_cde,
    'RPS' as coverage_pt3_rt_cde
UNION
select
    'PRDCRTN' as coverage_pt1_kind_cde,
    '00' as coverage_pt2_issue_basis_cde,
    'RPS' as coverage_pt3_rt_cde
UNION
select
    'WDRLBEN' as coverage_pt1_kind_cde,
    '00' as coverage_pt2_issue_basis_cde,
    'RPS' as coverage_pt3_rt_cde
)CVG_PROD
LEFT JOIN 
(SELECT
    PROD_ID,
    PROD_TYP_CDE,
    PROD_TYP_NME,
    MINOR_PROD_CDE,
    KND_MIN_CDE,
    KND_MAX_CDE,
    RATE_MIN_CDE,
    RATE_MAX_CDE,
    BSIS_MIN_CDE,
    BSIS_MAX_CDE
FROM
    EDW_REF.PRODUCT_TRANSLATOR
WHERE
    ADMN_SYS_GRP_CDE = '08'
    and end_dt = TO_DATE('99991231',
    'YYYYMMDD')) PDT1 
    ON
        CLEAN_STRING(upper(CVG_PROD.coverage_pt1_kind_cde)) >= CLEAN_STRING(upper(PDT1.KND_MIN_CDE)) AND 
        CLEAN_STRING(upper(CVG_PROD.coverage_pt1_kind_cde)) <= CLEAN_STRING(upper(PDT1.KND_MAX_CDE)) AND 
        CLEAN_STRING(upper(CVG_PROD.coverage_pt3_rt_cde))>= CLEAN_STRING(upper(PDT1.RATE_MIN_CDE)) AND 
        CLEAN_STRING(upper(CVG_PROD.coverage_pt3_rt_cde)) <= CLEAN_STRING(upper(PDT1.RATE_MAX_CDE)) AND
        CLEAN_STRING(upper(CVG_PROD.coverage_pt2_issue_basis_cde)) >= CLEAN_STRING(upper(PDT1.BSIS_MIN_CDE))  AND 
        CLEAN_STRING(upper(CVG_PROD.coverage_pt2_issue_basis_cde)) <= CLEAN_STRING(upper(PDT1.BSIS_MAX_CDE))
        order by 2;

/*INSERT SCRIPT FOR PRE WORK TABLE -ALL RECORDS FROM STG*/


insert into edw_staging.aifrps_dim_coverage_pre_work

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
               clean_string(sdt_agmt_src_cd.trnslt_fld_val),
               clean_string(calc.agreement_type_cde),
               clean_string(calc.agreement_nr_pfx),
               calc.agreement_nr,
               clean_string(calc.agreement_nr_sfx),
               clean_string(calc.coverage_pt1_kind_cde),
               clean_string(calc.coverage_pt2_issue_basis_cde),
               clean_string(calc.coverage_pt3_rt_cde))::uuid
                                                           as dim_coverage_natural_key_hash_uuid,
       uuid_gen(
               clean_string(sdt_agmt_src_cd.trnslt_fld_val),
               clean_string(calc.agreement_type_cde),
               clean_string(calc.agreement_nr_pfx),
               calc.agreement_nr,
               clean_string(calc.agreement_nr_sfx))::uuid
                                                           as dim_agreement_natural_key_hash_uuid,
       prehash_value(
               clean_string(calc.coverage_pt1_kind_cde),
               clean_string(calc.coverage_pt2_issue_basis_cde),
               clean_string(calc.coverage_pt3_rt_cde))                  as coverage_key_id,
       calc.agreement_nr_pfx                               as agreement_nr_pfx,
       calc.agreement_nr                                   as agreement_nr,
       calc.agreement_nr_sfx                               as agreement_nr_sfx,
       clean_string(sdt_agmt_src_cd.trnslt_fld_val)        as agreement_source_cde,
       calc.agreement_type_cde                             as agreement_type_cde,
       case
           when clean_string(thash.prod_id) is not null
               then uuid_gen(thash.prod_id)::uuid
           when clean_string(thash.prod_id) is null
               then uuid_gen('Unk')::uuid               
           end                                             as dim_product_natural_key_hash_uuid,
       calc.coverage_pt1_kind_cde,
       calc.coverage_pt2_issue_basis_cde,
       calc.coverage_pt3_rt_cde,
       calc.coverage_sequence_nr,
       case
           when clean_string(thash.prod_typ_nme) is not null
               then clean_string(thash.prod_typ_nme)
           when clean_string(thash.prod_typ_nme) is null
               then 'Unk'
           end as coverage_long_nm,
        case
           when clean_string(thash.prod_typ_cde) is not null
               then clean_string(thash.prod_typ_cde)
           when clean_string(thash.prod_typ_cde) is null
               then 'Unk'
       end as coverage_short_nm,
       case
           when clean_string(sdt_covg_sts_cd.trnslt_fld_val) is null
               then 'Unk'
           else clean_string(sdt_covg_sts_cd.trnslt_fld_val)
           end                                             as coverage_status_cde,
       calc.source_coverage_exception_status_cde,
       calc.source_coverage_effective_dt,
       calc.source_coverage_effective_dt_txt,
       calc.occupation_class_cde,
       calc.source_occupation_class_cde,
       calc.return_premium_policy_nr,
       calc.issue_age_nr,
       case
           when clean_string(sdt_covg_type_cd.trnslt_fld_val) is null
               then 'Unk'
           else clean_string(sdt_covg_type_cd.trnslt_fld_val)
           end                                             as coverage_type_cde,
	   case
           when clean_string(thash.minor_prod_cde) is not null
               then clean_string(thash.minor_prod_cde)
           when clean_string(thash.minor_prod_cde) is null
               then 'Unk'
           end as minor_product_cde,
       calc.coverage_category_cde,
       calc.source_coverage_category_cde,
       calc.coverage_cease_dt,
       calc.coverage_crossover_opt_dt,
       calc.coverage_1035_ind,
       calc.scheduled_unscheduled_cde,
       calc.active_ind,
       calc.pending_collection_ind,
       calc.increment_counter_nr,
       calc.source_coverage_cease_dt_txt,
       calc.occupation_class_modifier_nr,
       calc.coverage_period_txt,
       calc.source_coverage_period_txt                     as source_coverage_period_txt,
       calc.coverage_person_cde,
       calc.coverage_benefit_type_amt,
       calc.palir_roll_status_cde,
       calc.coverage_face_amt,
       calc.coverage_income_amt,
       calc.coverage_increase_pct                          as coverage_increase_pct,
       calc.coverage_dividend_option_cde,
       calc.source_coverage_dividend_option_cde,
       calc.coverage_secondary_dividend_option_cde,
       calc.source_coverage_secondary_dividend_option_cde,
       calc.coverage_conversion_expiry_dt,
       calc.coverage_conversion_eligibility_start_dt,
       calc.coverage_fio_next_dt,
       calc.coverage_fio_expiry_dt,
       calc.coverage_employer_discount_type_cde,
       calc.coverage_employer_discount_amt,
       calc.coverage_employer_discount_pct                 as coverage_employer_discount_pct,
       calc.coverage_declared_dividend_amt,
       calc.coverage_covered_insured_cde,
       calc.coverage_cash_val_amt,
	   calc.coverage_cash_val_quality_cde,
       calc.elimination_period_sickness_cde,
       calc.source_waiting_period_sickness_cde,
       calc.source_waiting_period_sickness_day_cde,
       calc.source_waiting_period_sickness_desc,
       calc.elimination_period_injury_cde,
       calc.source_waiting_period_injury_cde,
       calc.source_waiting_period_injury_day_cde,
       calc.source_waiting_period_injury_desc,
       calc.benefit_period_sickness_cde,
       calc.source_benefit_period_sickness_cde,
       calc.source_benefit_period_sickness_duration_cde,
       calc.source_benefit_period_sickness_desc,
       calc.benefit_period_injury_cde,
       calc.source_benefit_period_injury_cde,
       calc.source_benefit_period_injury_duration_cde,
       calc.source_benefit_period_injury_desc,
       calc.begin_dt                                       as begin_dt,
       calc.begin_dtm,
       calc.row_process_dtm,
       uuid_gen
           (
               calc.source_delete_ind,
               case
                   when clean_string(thash.prod_id) is not null
                       then clean_string(thash.prod_id)
                   when clean_string(thash.prod_id) is null
                             then 'Unk'
               end,
               calc.coverage_sequence_nr,
               clean_string(thash.prod_typ_nme),
               clean_string(thash.prod_typ_cde),
               clean_string(sdt_covg_sts_cd.trnslt_fld_val),
               clean_string(calc.source_coverage_exception_status_cde),
               calc.source_coverage_effective_dt,
               clean_string(calc.source_coverage_effective_dt_txt),
               clean_string(sdt_covg_type_cd.trnslt_fld_val),
               clean_string(thash.minor_prod_cde),
               clean_string(calc.coverage_category_cde),
			   calc.coverage_cease_dt,
               calc.increment_counter_nr,
               clean_string(calc.source_coverage_cease_dt_txt),
			   calc.coverage_income_amt,
               calc.coverage_increase_pct) :: uuid                                       as check_sum,

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
select udf_replaceemptystr(clean_string(aifcow_source_system_id), 'SPACE') as covg_row_adm_sys_name,
'Ipa'                                                                 	as agreement_type_cde,
clean_string(udf_aif_hldg_key_format(aifcow_policy_id,'PFX'))			as agreement_nr_pfx,
udf_aif_hldg_key_format(aifcow_policy_id,'KEY')							as agreement_nr,
clean_string(udf_aif_hldg_key_format(aifcow_policy_id,'SFX'))        	as agreement_nr_sfx,
NULL	                                                                as prod_id,
clean_string('INPRT')														as coverage_pt1_kind_cde,
'00'																	as coverage_pt2_issue_basis_cde,
clean_string('RPS')													as coverage_pt3_rt_cde,
1																		as coverage_sequence_nr,
NULL 																	as coverage_long_nm,
NULL 																	as coverage_short_nm,
udf_replaceemptystr(clean_string(aifcow_contract_status_code), 'SPACE')	as covg_excpt_sts, -- recalculated in outer query
aifcow_contract_status_code												as source_coverage_exception_status_cde,
case when aifcow_infprt_issue_date=99999999 or aifcow_infprt_issue_date >52000000 
	then to_date('9999-12-31','YYYY-MM-DD')
	else
	isdate(aifcow_infprt_issue_date)	 end							as source_coverage_effective_dt,	
to_char(aifcow_infprt_issue_date)										as	source_coverage_effective_dt_txt,
NULL	 																as occupation_class_cde,
NULL	 																as source_occupation_class_cde,
NULL	 																as return_premium_policy_nr,
NULL	 																as issue_age_nr,
NULL	 																as coverage_type_cde, --calculated in outer query
NULL	 																as minor_product_cde, --calculated in outer query
'R'																		as coverage_category_cde,
'R'																		as source_coverage_category_cde,
case when aifcow_infprt_term_date=99999999 or aifcow_infprt_term_date >52000000 
	then to_date('9999-12-31','YYYY-MM-DD')
	else
	isdate(aifcow_infprt_term_date)	 end									as coverage_cease_dt,	
NULL	 																as coverage_crossover_opt_dt,
NULL	 																as coverage_1035_ind,
NULL	 																as scheduled_unscheduled_cde,
NULL	 																as active_ind,
NULL	 																as pending_collection_ind,
1 																		as increment_counter_nr,
to_char(aifcow_infprt_term_date)					 						as source_coverage_cease_dt_txt,
NULL	 																as occupation_class_modifier_nr,
NULL 																	as covg_period_term,
NULL	 																as coverage_period_txt,
NULL	 																as source_coverage_period_txt,
NULL	 																as coverage_person_cde,
NULL	 																as coverage_benefit_type_amt,
NULL	 																as palir_roll_status_cde,
NULL	 																as coverage_face_amt,
NULL	 																as coverage_income_amt,
aifcow_infprt_percent/100												as coverage_increase_pct,
NULL	 																as coverage_dividend_option_cde,
NULL	 																as source_coverage_dividend_option_cde,
NULL	 																as coverage_secondary_dividend_option_cde,
NULL	 																as source_coverage_secondary_dividend_option_cde,
NULL	 																as coverage_conversion_expiry_dt,
NULL	 																as coverage_conversion_eligibility_start_dt,
NULL	 																as coverage_fio_next_dt,
NULL	 																as coverage_fio_expiry_dt,
NULL	 																as coverage_employer_discount_type_cde,
NULL	 																as coverage_employer_discount_amt,
NULL	 																as coverage_employer_discount_pct,
NULL	 																as coverage_declared_dividend_amt,
NULL	 																as coverage_covered_insured_cde,
NULL	 																as coverage_cash_val_amt,
NULL																	as covg_cash_value_sig,
NULL	 																as coverage_cash_val_quality_cde,
NULL	 																as elimination_period_sickness_cde,
NULL 																	as elmn_perd_sicknss_cde,
NULL 																	as waiting_period_sickness_cde,
NULL	 																as source_waiting_period_sickness_cde,
NULL	 																as source_waiting_period_sickness_day_cde,
NULL	 																as source_waiting_period_sickness_desc,
NULL	 																as elimination_period_injury_cde,
NULL	 																as source_waiting_period_injury_cde,
NULL	 																as source_waiting_period_injury_day_cde,
NULL	 																as source_waiting_period_injury_desc,
NULL	 																as benefit_period_sickness_cde,
NULL	 																as source_benefit_period_sickness_cde,
NULL	 																as source_benefit_period_sickness_duration_cde,
NULL	 																as source_benefit_period_sickness_desc,
NULL	 																as benefit_period_injury_cde,
NULL	 																as source_benefit_period_injury_cde,
NULL	 																as source_benefit_period_injury_duration_cde,
NULL	 																as source_benefit_period_injury_desc,
to_date(to_char(cycle_date), 'yyyymmdd')                       as begin_dt,
to_date(to_char(cycle_date), 'yyyymmdd') :: timestamp          as begin_dtm,
current_timestamp(6)			                                        as row_process_dtm,
null                            	                                    as check_sum, -- will be updated in the outer qry
'9999-12-31'::date                  	                                as end_dt,
'9999-12-31'::timestamp                 	                            as end_dtm,
false                                       	                        as restricted_row_ind,
true                                            	                    as current_row_ind,
false                                               	                as logical_delete_ind,
72                                                      		        as source_system_id,
:audit_id                                                       	    as audit_id,
:audit_id                                                           	as update_audit_id,
case
    when upper(processed_ind) = 'D' then true
    else false
    end                                                               	as source_delete_ind,
processed_ind	                                                       	as process_ind,
NULL	 																as coverage_smoker_cde,
NULL	 																as coverage_expiry_dt,
NULL	 																as source_coverage_smoker_cde,
NULL	 																as flat_extra_amt,
NULL	 																as flat_extra_expiry_dt,
NULL	 																as insured_permanent_temporary_cde,
NULL	 																as substandard_rating_1_pct,
NULL	 																as substandard_rating_type_1_cde,
NULL	 																as source_substandard_rating_type_1_cde,
NULL	 																as substandard_rating_2_pct,
NULL	 																as substandard_rating_type_2_cde,
NULL	 																as source_substandard_rating_type_2_cde,
NULL	 																as table_rating_cde,
NULL	 																as source_table_rating_cde,
NULL	 																as coverage_table_rating_pct
FROM 
(select * from edw_staging.aif_rps_edw_ctrt_full_dedup
union	
select * from edw_staging.aif_rps_edw_ctrt_delta_dedup where processed_ind = 'D') cov 
join edw_staging.aif_rps_edw_ctrt_delta_count covcnt
on covcnt.audit_id = cov.audit_id and covcnt.source_system_id = 72
where AIFCOW_INFPRT_IND='Y'
union all
select udf_replaceemptystr(clean_string(aifcow_source_system_id), 'SPACE') as covg_row_adm_sys_name,
'Ipa'                                                                 	as agreement_type_cde,
clean_string(udf_aif_hldg_key_format(aifcow_policy_id,'PFX'))			as agreement_nr_pfx,
udf_aif_hldg_key_format(aifcow_policy_id,'KEY')							as agreement_nr,
clean_string(udf_aif_hldg_key_format(aifcow_policy_id,'SFX')) 			as agreement_nr_sfx,
NULL	                                                                as prod_id,
clean_string('PAPRT')													as coverage_pt1_kind_cde,
'00'																	as coverage_pt2_issue_basis_cde,
clean_string('RPS')													as coverage_pt3_rt_cde,
1																		as coverage_sequence_nr,
NULL 																	as coverage_long_nm,
NULL 																	as coverage_short_nm,
udf_replaceemptystr(clean_string(aifcow_contract_status_code), 'SPACE')	as covg_excpt_sts, --recalculated in outer query
aifcow_contract_status_code												as source_coverage_exception_status_cde,
case when aifcow_payprt_issue_date = 99999999 or aifcow_payprt_issue_date = 52000000 then 
to_date('9999-12-31','YYYY-MM-DD') 
else 
isdate(aifcow_payprt_issue_date) end 									as source_coverage_effective_dt,
to_char(aifcow_payprt_issue_date)										as	source_coverage_effective_dt_txt,
NULL	 																as occupation_class_cde,
NULL	 																as source_occupation_class_cde,
NULL	 																as return_premium_policy_nr,
NULL	 																as issue_age_nr,
NULL	 																as coverage_type_cde, --calculated in outer query
NULL	 																as minor_product_cde, --calculated in outer query
'R'																		as coverage_category_cde,
'R'																		as source_coverage_category_cde,
case when aifcow_payprt_term_date=99999999 or aifcow_payprt_term_date >52000000 
	then to_date('9999-12-31','YYYY-MM-DD')
	else
	isdate(aifcow_payprt_term_date)	 end								as coverage_cease_dt,
NULL	 																as coverage_crossover_opt_dt,
NULL	 																as coverage_1035_ind,
NULL	 																as scheduled_unscheduled_cde,
NULL	 																as active_ind,
NULL	 																as pending_collection_ind,
1 																		as increment_counter_nr,
to_char(aifcow_payprt_term_date)				 						as source_coverage_cease_dt_txt,
NULL	 																as occupation_class_modifier_nr,
NULL 																	as covg_period_term,
NULL	 																as coverage_period_txt,
NULL	 																as source_coverage_period_txt,
NULL	 																as coverage_person_cde,
NULL	 																as coverage_benefit_type_amt,
NULL	 																as palir_roll_status_cde,
NULL	 																as coverage_face_amt,
aifcow_prch_gteedmin_pyot_amt											as coverage_income_amt,
aifcow_air_rate/100														as coverage_increase_pct,
NULL	 																as coverage_dividend_option_cde,
NULL	 																as source_coverage_dividend_option_cde,
NULL	 																as coverage_secondary_dividend_option_cde,
NULL	 																as source_coverage_secondary_dividend_option_cde,
NULL	 																as coverage_conversion_expiry_dt,
NULL	 																as coverage_conversion_eligibility_start_dt,
NULL	 																as coverage_fio_next_dt,
NULL	 																as coverage_fio_expiry_dt,
NULL	 																as coverage_employer_discount_type_cde,
NULL	 																as coverage_employer_discount_amt,
NULL	 																as coverage_employer_discount_pct,
NULL	 																as coverage_declared_dividend_amt,
NULL	 																as coverage_covered_insured_cde,
NULL	 																as coverage_cash_val_amt,
NULL 																	as covg_cash_value_sig,
NULL	 																as coverage_cash_val_quality_cde,
NULL	 																as elimination_period_sickness_cde,
NULL 																	as elmn_perd_sicknss_cde,
NULL 																	as waiting_period_sickness_cde,
NULL	 																as source_waiting_period_sickness_cde,
NULL	 																as source_waiting_period_sickness_day_cde,
NULL	 																as source_waiting_period_sickness_desc,
NULL	 																as elimination_period_injury_cde,
NULL	 																as source_waiting_period_injury_cde,
NULL	 																as source_waiting_period_injury_day_cde,
NULL	 																as source_waiting_period_injury_desc,
NULL	 																as benefit_period_sickness_cde,
NULL	 																as source_benefit_period_sickness_cde,
NULL	 																as source_benefit_period_sickness_duration_cde,
NULL	 																as source_benefit_period_sickness_desc,
NULL	 																as benefit_period_injury_cde,
NULL	 																as source_benefit_period_injury_cde,
NULL	 																as source_benefit_period_injury_duration_cde,
NULL	 																as source_benefit_period_injury_desc,
to_date(to_char(cycle_date), 'yyyymmdd')                       as begin_dt,
to_date(to_char(cycle_date), 'yyyymmdd') :: timestamp          as begin_dtm,
current_timestamp(6)			                                        as row_process_dtm,
null                            	                                    as check_sum, -- will be updated in the outer qry
'9999-12-31'::date                  	                                as end_dt,
'9999-12-31'::timestamp                 	                            as end_dtm,
false                                       	                        as restricted_row_ind,
true                                            	                    as current_row_ind,
false                                               	                as logical_delete_ind,
72                                                      		        as source_system_id,
:audit_id                                                       	    as audit_id,
:audit_id                                                           	as update_audit_id,
case
    when upper(processed_ind) = 'D' then true
    else false
    end                                                               	as source_delete_ind,
processed_ind	                                                       	as process_ind,
NULL	 																as coverage_smoker_cde,
NULL	 																as coverage_expiry_dt,
NULL	 																as source_coverage_smoker_cde,
NULL	 																as flat_extra_amt,
NULL	 																as flat_extra_expiry_dt,
NULL	 																as insured_permanent_temporary_cde,
NULL	 																as substandard_rating_1_pct,
NULL	 																as substandard_rating_type_1_cde,
NULL	 																as source_substandard_rating_type_1_cde,
NULL	 																as substandard_rating_2_pct,
NULL	 																as substandard_rating_type_2_cde,
NULL	 																as source_substandard_rating_type_2_cde,
NULL	 																as table_rating_cde,
NULL	 																as source_table_rating_cde,
NULL	 																as coverage_table_rating_pct
FROM 
(select * from edw_staging.aif_rps_edw_ctrt_full_dedup
union	
select * from edw_staging.aif_rps_edw_ctrt_delta_dedup where processed_ind = 'D') cov 
join edw_staging.aif_rps_edw_ctrt_delta_count covcnt
on covcnt.audit_id = cov.audit_id and covcnt.source_system_id = 72
where AIFCOW_PAYPRT_IND='Y'
union all
select udf_replaceemptystr(clean_string(aifcow_source_system_id), 'SPACE') as covg_row_adm_sys_name,
'Ipa'                                                                 	as agreement_type_cde,
clean_string(udf_aif_hldg_key_format(aifcow_policy_id,'PFX'))			as agreement_nr_pfx,
udf_aif_hldg_key_format(aifcow_policy_id,'KEY')							as agreement_nr,
clean_string(udf_aif_hldg_key_format(aifcow_policy_id,'SFX')) 			as agreement_nr_sfx,
NULL	                                                                as prod_id,
clean_string('AIR')													as coverage_pt1_kind_cde,
'00'																	as coverage_pt2_issue_basis_cde,
clean_string('RPS')													as coverage_pt3_rt_cde,
1																		as coverage_sequence_nr,
NULL 																	as coverage_long_nm,
NULL 																	as coverage_short_nm,
udf_replaceemptystr(clean_string(aifcow_contract_status_code), 'SPACE')	as covg_excpt_sts, --recalculated in outer query
aifcow_contract_status_code												as source_coverage_exception_status_cde,
case when aifcow_air_issue_date = 99999999 or aifcow_air_issue_date = 52000000 then 
to_date('9999-12-31','YYYY-MM-DD') 
else isdate(aifcow_air_issue_date) end as source_coverage_effective_dt,
to_char(aifcow_air_issue_date)	as	source_coverage_effective_dt_txt,
NULL	 																as occupation_class_cde,
NULL	 																as source_occupation_class_cde,
NULL	 																as return_premium_policy_nr,
NULL	 																as issue_age_nr,
NULL	 																as coverage_type_cde, --calculated in outer query
NULL	 																as minor_product_cde, --calculated in outer query
'R'																		as coverage_category_cde,
'R'																		as source_coverage_category_cde,
case when aifcow_air_term_date=99999999 or aifcow_air_term_date >52000000 
	then to_date('9999-12-31','YYYY-MM-DD')
	else
	isdate(aifcow_air_term_date)	 end								as coverage_cease_dt,
NULL	 																as coverage_crossover_opt_dt,
NULL	 																as coverage_1035_ind,
NULL	 																as scheduled_unscheduled_cde,
NULL	 																as active_ind,
NULL	 																as pending_collection_ind,
1 																		as increment_counter_nr,
to_char(aifcow_air_term_date)					 						as source_coverage_cease_dt_txt,
NULL	 																as occupation_class_modifier_nr,
NULL 																	as covg_period_term,
NULL	 																as coverage_period_txt,
NULL	 																as source_coverage_period_txt,
NULL	 																as coverage_person_cde,
NULL	 																as coverage_benefit_type_amt,
NULL	 																as palir_roll_status_cde,
NULL	 																as coverage_face_amt,
NULL	 																as coverage_income_amt,
aifcow_air_rate/100														as coverage_increase_pct,
NULL	 																as coverage_dividend_option_cde,
NULL	 																as source_coverage_dividend_option_cde,
NULL	 																as coverage_secondary_dividend_option_cde,
NULL	 																as source_coverage_secondary_dividend_option_cde,
NULL	 																as coverage_conversion_expiry_dt,
NULL	 																as coverage_conversion_eligibility_start_dt,
NULL	 																as coverage_fio_next_dt,
NULL	 																as coverage_fio_expiry_dt,
NULL	 																as coverage_employer_discount_type_cde,
NULL	 																as coverage_employer_discount_amt,
NULL	 																as coverage_employer_discount_pct,
NULL	 																as coverage_declared_dividend_amt,
NULL	 																as coverage_covered_insured_cde,
NULL	 																as coverage_cash_val_amt,
NULL 																	as covg_cash_value_sig,
NULL	 																as coverage_cash_val_quality_cde,
NULL	 																as elimination_period_sickness_cde,
NULL 																	as elmn_perd_sicknss_cde,
NULL 																	as waiting_period_sickness_cde,
NULL	 																as source_waiting_period_sickness_cde,
NULL	 																as source_waiting_period_sickness_day_cde,
NULL	 																as source_waiting_period_sickness_desc,
NULL	 																as elimination_period_injury_cde,
NULL	 																as source_waiting_period_injury_cde,
NULL	 																as source_waiting_period_injury_day_cde,
NULL	 																as source_waiting_period_injury_desc,
NULL	 																as benefit_period_sickness_cde,
NULL	 																as source_benefit_period_sickness_cde,
NULL	 																as source_benefit_period_sickness_duration_cde,
NULL	 																as source_benefit_period_sickness_desc,
NULL	 																as benefit_period_injury_cde,
NULL	 																as source_benefit_period_injury_cde,
NULL	 																as source_benefit_period_injury_duration_cde,
NULL	 																as source_benefit_period_injury_desc,
to_date(to_char(cycle_date), 'yyyymmdd')                       as begin_dt,
to_date(to_char(cycle_date), 'yyyymmdd') :: timestamp          as begin_dtm,
current_timestamp(6)			                                        as row_process_dtm,
null                            	                                    as check_sum, -- will be updated in the outer qry
'9999-12-31'::date                  	                                as end_dt,
'9999-12-31'::timestamp                 	                            as end_dtm,
false                                       	                        as restricted_row_ind,
true                                            	                    as current_row_ind,
false                                               	                as logical_delete_ind,
72                                                      		        as source_system_id,
:audit_id                                                       	    as audit_id,
:audit_id                                                           	as update_audit_id,
case
    when upper(processed_ind) = 'D' then true
    else false
    end                                                               	as source_delete_ind,
processed_ind	                                                       	as process_ind,
NULL	 																as coverage_smoker_cde,
NULL	 																as coverage_expiry_dt,
NULL	 																as source_coverage_smoker_cde,
NULL	 																as flat_extra_amt,
NULL	 																as flat_extra_expiry_dt,
NULL	 																as insured_permanent_temporary_cde,
NULL	 																as substandard_rating_1_pct,
NULL	 																as substandard_rating_type_1_cde,
NULL	 																as source_substandard_rating_type_1_cde,
NULL	 																as substandard_rating_2_pct,
NULL	 																as substandard_rating_type_2_cde,
NULL	 																as source_substandard_rating_type_2_cde,
NULL	 																as table_rating_cde,
NULL	 																as source_table_rating_cde,
NULL	 																as coverage_table_rating_pct
FROM 
(select * from edw_staging.aif_rps_edw_ctrt_full_dedup
union	
select * from edw_staging.aif_rps_edw_ctrt_delta_dedup where processed_ind = 'D') cov 
join edw_staging.aif_rps_edw_ctrt_delta_count covcnt
on covcnt.audit_id = cov.audit_id and covcnt.source_system_id = 72
where AIFCOW_AIR_IND='Y'
UNION ALL
select udf_replaceemptystr(clean_string(aifcow_source_system_id), 'SPACE') as covg_row_adm_sys_name,
'Ipa'                                                                 	as agreement_type_cde,
clean_string(udf_aif_hldg_key_format(aifcow_policy_id,'PFX'))			as agreement_nr_pfx,
udf_aif_hldg_key_format(aifcow_policy_id,'KEY')							as agreement_nr,
clean_string(udf_aif_hldg_key_format(aifcow_policy_id,'SFX')) 			as agreement_nr_sfx,
NULL	                                                                as prod_id,
clean_string('BUPRT')													as coverage_pt1_kind_cde,
'00'																	as coverage_pt2_issue_basis_cde,
clean_string('RPS')													as coverage_pt3_rt_cde,
1																		as coverage_sequence_nr,
NULL 																	as coverage_long_nm,
NULL 																	as coverage_short_nm,
udf_replaceemptystr(clean_string(aifcow_contract_status_code), 'SPACE')	as covg_excpt_sts, --recalculated in outer query
aifcow_contract_status_code												as source_coverage_exception_status_cde,
case when aifcow_bdgprt_issue_date = 99999999 or aifcow_bdgprt_issue_date = 52000000 then 
to_date('9999-12-31','YYYY-MM-DD') 
else 
isdate(aifcow_bdgprt_issue_date) end 									as source_coverage_effective_dt,
to_char(aifcow_bdgprt_issue_date)										as	source_coverage_effective_dt_txt,
NULL	 																as occupation_class_cde,
NULL	 																as source_occupation_class_cde,
NULL	 																as return_premium_policy_nr,
NULL	 																as issue_age_nr,
NULL	 																as coverage_type_cde, --calculated in outer query
NULL	 																as minor_product_cde, --calculated in outer query
'R'																		as coverage_category_cde,
'R'																		as source_coverage_category_cde,
case when aifcow_bdgprt_term_date=99999999 or aifcow_bdgprt_term_date >52000000 
	then to_date('9999-12-31','YYYY-MM-DD')
	else
	isdate(aifcow_bdgprt_term_date)	 end								as coverage_cease_dt,
NULL	 																as coverage_crossover_opt_dt,
NULL	 																as coverage_1035_ind,
NULL	 																as scheduled_unscheduled_cde,
NULL	 																as active_ind,
NULL	 																as pending_collection_ind,
1 																		as increment_counter_nr,
to_char(aifcow_bdgprt_term_date)										as source_coverage_cease_dt_txt,
NULL	 																as occupation_class_modifier_nr,
NULL 																	as covg_period_term,
NULL	 																as coverage_period_txt,
NULL	 																as source_coverage_period_txt,
NULL	 																as coverage_person_cde,
NULL	 																as coverage_benefit_type_amt,
NULL	 																as palir_roll_status_cde,
NULL	 																as coverage_face_amt,
NULL	 																as coverage_income_amt,
0																		as coverage_increase_pct,
NULL	 																as coverage_dividend_option_cde,
NULL	 																as source_coverage_dividend_option_cde,
NULL	 																as coverage_secondary_dividend_option_cde,
NULL	 																as source_coverage_secondary_dividend_option_cde,
NULL	 																as coverage_conversion_expiry_dt,
NULL	 																as coverage_conversion_eligibility_start_dt,
NULL	 																as coverage_fio_next_dt,
NULL	 																as coverage_fio_expiry_dt,
NULL	 																as coverage_employer_discount_type_cde,
NULL	 																as coverage_employer_discount_amt,
NULL	 																as coverage_employer_discount_pct,
NULL	 																as coverage_declared_dividend_amt,
NULL	 																as coverage_covered_insured_cde,
NULL	 																as coverage_cash_val_amt,
NULL 																	as covg_cash_value_sig,
NULL	 																as coverage_cash_val_quality_cde,
NULL	 																as elimination_period_sickness_cde,
NULL 																	as elmn_perd_sicknss_cde,
NULL 																	as waiting_period_sickness_cde,
NULL	 																as source_waiting_period_sickness_cde,
NULL	 																as source_waiting_period_sickness_day_cde,
NULL	 																as source_waiting_period_sickness_desc,
NULL	 																as elimination_period_injury_cde,
NULL	 																as source_waiting_period_injury_cde,
NULL	 																as source_waiting_period_injury_day_cde,
NULL	 																as source_waiting_period_injury_desc,
NULL	 																as benefit_period_sickness_cde,
NULL	 																as source_benefit_period_sickness_cde,
NULL	 																as source_benefit_period_sickness_duration_cde,
NULL	 																as source_benefit_period_sickness_desc,
NULL	 																as benefit_period_injury_cde,
NULL	 																as source_benefit_period_injury_cde,
NULL	 																as source_benefit_period_injury_duration_cde,
NULL	 																as source_benefit_period_injury_desc,
to_date(to_char(cycle_date), 'yyyymmdd')                       as begin_dt,
to_date(to_char(cycle_date), 'yyyymmdd') :: timestamp          as begin_dtm,
current_timestamp(6)			                                        as row_process_dtm,
null                            	                                    as check_sum, -- will be updated in the outer qry
'9999-12-31'::date                  	                                as end_dt,
'9999-12-31'::timestamp                 	                            as end_dtm,
false                                       	                        as restricted_row_ind,
true                                            	                    as current_row_ind,
false                                               	                as logical_delete_ind,
72                                                      		        as source_system_id,
:audit_id                                                       	    as audit_id,
:audit_id                                                           	as update_audit_id,
case
    when upper(processed_ind) = 'D' then true
    else false
    end                                                               	as source_delete_ind,
processed_ind	                                                       	as process_ind,
NULL	 																as coverage_smoker_cde,
NULL	 																as coverage_expiry_dt,
NULL	 																as source_coverage_smoker_cde,
NULL	 																as flat_extra_amt,
NULL	 																as flat_extra_expiry_dt,
NULL	 																as insured_permanent_temporary_cde,
NULL	 																as substandard_rating_1_pct,
NULL	 																as substandard_rating_type_1_cde,
NULL	 																as source_substandard_rating_type_1_cde,
NULL	 																as substandard_rating_2_pct,
NULL	 																as substandard_rating_type_2_cde,
NULL	 																as source_substandard_rating_type_2_cde,
NULL	 																as table_rating_cde,
NULL	 																as source_table_rating_cde,
NULL	 																as coverage_table_rating_pct
FROM 
(select * from edw_staging.aif_rps_edw_ctrt_full_dedup
union	
select * from edw_staging.aif_rps_edw_ctrt_delta_dedup where processed_ind = 'D') cov 
join edw_staging.aif_rps_edw_ctrt_delta_count covcnt
on covcnt.audit_id = cov.audit_id and covcnt.source_system_id = 72
where AIFCOW_BDGPRT_IND='Y'
UNION ALL
select udf_replaceemptystr(clean_string(aifcow_source_system_id), 'SPACE') as covg_row_adm_sys_name,
'Ipa'                                                                 	as agreement_type_cde,
clean_string(udf_aif_hldg_key_format(aifcow_policy_id,'PFX'))			as agreement_nr_pfx,
udf_aif_hldg_key_format(aifcow_policy_id,'KEY')							as agreement_nr,
clean_string(udf_aif_hldg_key_format(aifcow_policy_id,'SFX')) 			as agreement_nr_sfx,
NULL	                                                                as prod_id,
clean_string('PRDCRTN')													as coverage_pt1_kind_cde,
'00'																	as coverage_pt2_issue_basis_cde,
clean_string('RPS')													as coverage_pt3_rt_cde,
1																		as coverage_sequence_nr,
NULL 																	as coverage_long_nm,
NULL 																	as coverage_short_nm,
udf_replaceemptystr(clean_string(aifcow_contract_status_code), 'SPACE')	as covg_excpt_sts, --recalculated in outer query
aifcow_contract_status_code												as source_coverage_exception_status_cde,
case when to_char(aifcow_policy_issue_yyyy)||lpad(to_char(aifcow_policy_issue_mm), 2, '0')||lpad(to_char(aifcow_policy_issue_dd), 2, '0') = 99999999 
or to_char(aifcow_policy_issue_yyyy)||lpad(to_char(aifcow_policy_issue_mm), 2, '0')||lpad(to_char(aifcow_policy_issue_dd), 2, '0') = 52000000 then 
to_date('9999-12-31','YYYY-MM-DD') else isdate(to_char(aifcow_policy_issue_yyyy)||lpad(to_char(aifcow_policy_issue_mm), 2, '0')||lpad(to_char(aifcow_policy_issue_dd), 2, '0')) end as source_coverage_effective_dt,
to_char(aifcow_policy_issue_yyyy||lpad(to_char(aifcow_policy_issue_mm), 2, '0')||lpad(to_char(aifcow_policy_issue_dd), 2, '0'))	as	source_coverage_effective_dt_txt,
NULL	 																as occupation_class_cde,
NULL	 																as source_occupation_class_cde,
NULL	 																as return_premium_policy_nr,
NULL	 																as issue_age_nr,
NULL	 																as coverage_type_cde, --calculated in outer query
NULL	 																as minor_product_cde, --calculated in outer query
'R'																		as coverage_category_cde,
'R'																		as source_coverage_category_cde,
case when to_char(aifcow_last_gteed_payout_yyyy)||lpad(to_char(aifcow_last_gteed_payout_mm), 2, '0')||lpad(to_char(aifcow_last_gteed_payout_dd), 2, '0') = 99999999 
or to_char(aifcow_last_gteed_payout_yyyy)||lpad(to_char(aifcow_last_gteed_payout_mm), 2, '0')||lpad(to_char(aifcow_last_gteed_payout_dd), 2, '0') = 52000000 then 
to_date('9999-12-31','YYYY-MM-DD') else isdate(to_char(aifcow_last_gteed_payout_yyyy)||lpad(to_char(aifcow_last_gteed_payout_mm), 2, '0')||lpad(to_char(aifcow_last_gteed_payout_dd), 2, '0')) end
																		as coverage_cease_dt,
NULL	 																as coverage_crossover_opt_dt,
NULL	 																as coverage_1035_ind,
NULL	 																as scheduled_unscheduled_cde,
NULL	 																as active_ind,
NULL	 																as pending_collection_ind,
1 																		as increment_counter_nr,
to_char(aifcow_last_gteed_payout_yyyy||lpad(to_char(aifcow_last_gteed_payout_mm), 2, '0')||lpad(to_char(aifcow_last_gteed_payout_dd), 2, '0'))														
																		as source_coverage_cease_dt_txt,
NULL	 																as occupation_class_modifier_nr,
NULL 																	as covg_period_term,
NULL	 																as coverage_period_txt,
NULL	 																as source_coverage_period_txt,
NULL	 																as coverage_person_cde,
NULL	 																as coverage_benefit_type_amt,
NULL	 																as palir_roll_status_cde,
NULL	 																as coverage_face_amt,
NULL	 																as coverage_income_amt,
NULL	 																as coverage_increase_pct,
NULL	 																as coverage_dividend_option_cde,
NULL	 																as source_coverage_dividend_option_cde,
NULL	 																as coverage_secondary_dividend_option_cde,
NULL	 																as source_coverage_secondary_dividend_option_cde,
NULL	 																as coverage_conversion_expiry_dt,
NULL	 																as coverage_conversion_eligibility_start_dt,
NULL	 																as coverage_fio_next_dt,
NULL	 																as coverage_fio_expiry_dt,
NULL	 																as coverage_employer_discount_type_cde,
NULL	 																as coverage_employer_discount_amt,
NULL	 																as coverage_employer_discount_pct,
NULL	 																as coverage_declared_dividend_amt,
NULL	 																as coverage_covered_insured_cde,
NULL	 																as coverage_cash_val_amt,
NULL 																	as covg_cash_value_sig,
NULL	 																as coverage_cash_val_quality_cde,
NULL	 																as elimination_period_sickness_cde,
NULL 																	as elmn_perd_sicknss_cde,
NULL 																	as waiting_period_sickness_cde,
NULL	 																as source_waiting_period_sickness_cde,
NULL	 																as source_waiting_period_sickness_day_cde,
NULL	 																as source_waiting_period_sickness_desc,
NULL	 																as elimination_period_injury_cde,
NULL	 																as source_waiting_period_injury_cde,
NULL	 																as source_waiting_period_injury_day_cde,
NULL	 																as source_waiting_period_injury_desc,
NULL	 																as benefit_period_sickness_cde,
NULL	 																as source_benefit_period_sickness_cde,
NULL	 																as source_benefit_period_sickness_duration_cde,
NULL	 																as source_benefit_period_sickness_desc,
NULL	 																as benefit_period_injury_cde,
NULL	 																as source_benefit_period_injury_cde,
NULL	 																as source_benefit_period_injury_duration_cde,
NULL	 																as source_benefit_period_injury_desc,
to_date(to_char(cycle_date), 'yyyymmdd')                       as begin_dt,
to_date(to_char(cycle_date), 'yyyymmdd') :: timestamp          as begin_dtm,
current_timestamp(6)			                                        as row_process_dtm,
null                            	                                    as check_sum, -- will be updated in the outer qry
'9999-12-31'::date                  	                                as end_dt,
'9999-12-31'::timestamp                 	                            as end_dtm,
false                                       	                        as restricted_row_ind,
true                                            	                    as current_row_ind,
false                                               	                as logical_delete_ind,
72                                                      		        as source_system_id,
:audit_id                                                       	    as audit_id,
:audit_id                                                           	as update_audit_id,
case
    when upper(processed_ind) = 'D' then true
    else false
    end                                                               	as source_delete_ind,
processed_ind	                                                       	as process_ind,
NULL	 																as coverage_smoker_cde,
NULL	 																as coverage_expiry_dt,
NULL	 																as source_coverage_smoker_cde,
NULL	 																as flat_extra_amt,
NULL	 																as flat_extra_expiry_dt,
NULL	 																as insured_permanent_temporary_cde,
NULL	 																as substandard_rating_1_pct,
NULL	 																as substandard_rating_type_1_cde,
NULL	 																as source_substandard_rating_type_1_cde,
NULL	 																as substandard_rating_2_pct,
NULL	 																as substandard_rating_type_2_cde,
NULL	 																as source_substandard_rating_type_2_cde,
NULL	 																as table_rating_cde,
NULL	 																as source_table_rating_cde,
NULL	 																as coverage_table_rating_pct
FROM 
(select * from edw_staging.aif_rps_edw_ctrt_full_dedup
union	
select * from edw_staging.aif_rps_edw_ctrt_delta_dedup where processed_ind = 'D') cov 
join edw_staging.aif_rps_edw_ctrt_delta_count covcnt
on covcnt.audit_id = cov.audit_id and covcnt.source_system_id = 72
left join edw_tdsunset.dim_annuity_payout_option OPT on clean_string(BTRIM(OPT.PAYOUT_OPTION_CDE)) = clean_string(BTRIM(AIFCOW_BEN_DESC_ANNTY_OPT_CODE)) 
--and OPT.PERIOD_CERTAIN_IND = True
UNION ALL 
select udf_replaceemptystr(clean_string(aifcow_source_system_id), 'SPACE') as covg_row_adm_sys_name,
'Ipa'                                                                 	as agreement_type_cde,
clean_string(udf_aif_hldg_key_format(aifcow_policy_id,'PFX'))			as agreement_nr_pfx,
udf_aif_hldg_key_format(aifcow_policy_id,'KEY')							as agreement_nr,
clean_string(udf_aif_hldg_key_format(aifcow_policy_id,'SFX')) 			as agreement_nr_sfx,
NULL	                                                                as prod_id,
clean_string('WDRLBEN')													as coverage_pt1_kind_cde,
'00'																	as coverage_pt2_issue_basis_cde,
clean_string('RPS')													as coverage_pt3_rt_cde,
1																		as coverage_sequence_nr,
NULL 																	as coverage_long_nm,
NULL 																	as coverage_short_nm,
udf_replaceemptystr(clean_string(aifcow_contract_status_code), 'SPACE')	as covg_excpt_sts, --recalculated in outer query
aifcow_contract_status_code												as source_coverage_exception_status_cde,
case when to_char(aifcow_policy_issue_yyyy)||lpad(to_char(aifcow_policy_issue_mm), 2, '0')||lpad(to_char(aifcow_policy_issue_dd), 2, '0') = 99999999 
or to_char(aifcow_policy_issue_yyyy)||lpad(to_char(aifcow_policy_issue_mm), 2, '0')||lpad(to_char(aifcow_policy_issue_dd), 2, '0') = 52000000 then 
to_date('9999-12-31','YYYY-MM-DD') else isdate(to_char(aifcow_policy_issue_yyyy)||lpad(to_char(aifcow_policy_issue_mm), 2, '0')||lpad(to_char(aifcow_policy_issue_dd), 2, '0')) end as source_coverage_effective_dt,
to_char(aifcow_policy_issue_yyyy||lpad(to_char(aifcow_policy_issue_mm), 2, '0')||lpad(to_char(aifcow_policy_issue_dd), 2, '0'))	as	source_coverage_effective_dt_txt,
NULL	 																as occupation_class_cde,
NULL	 																as source_occupation_class_cde,
NULL	 																as return_premium_policy_nr,
NULL	 																as issue_age_nr,
NULL	 																as coverage_type_cde, --calculated in outer query
NULL	 																as minor_product_cde, --calculated in outer query
'R'																		as coverage_category_cde,
'R'																		as source_coverage_category_cde,
case when to_char(aifcow_last_gteed_payout_yyyy)||lpad(to_char(aifcow_last_gteed_payout_mm), 2, '0')||lpad(to_char(aifcow_last_gteed_payout_dd), 2, '0') = 99999999 
or to_char(aifcow_last_gteed_payout_yyyy)||lpad(to_char(aifcow_last_gteed_payout_mm), 2, '0')||lpad(to_char(aifcow_last_gteed_payout_dd), 2, '0') = 52000000 then 
to_date('9999-12-31','YYYY-MM-DD') else isdate(to_char(aifcow_last_gteed_payout_yyyy)||lpad(to_char(aifcow_last_gteed_payout_mm), 2, '0')||lpad(to_char(aifcow_last_gteed_payout_dd), 2, '0')) end
																		as coverage_cease_dt,
NULL	 																as coverage_crossover_opt_dt,
NULL	 																as coverage_1035_ind,
NULL	 																as scheduled_unscheduled_cde,
NULL	 																as active_ind,
NULL	 																as pending_collection_ind,
1 																		as increment_counter_nr,
to_char(aifcow_last_gteed_payout_yyyy||lpad(to_char(aifcow_last_gteed_payout_mm), 2, '0')||lpad(to_char(aifcow_last_gteed_payout_dd), 2, '0'))
																		as source_coverage_cease_dt_txt,
NULL	 																as occupation_class_modifier_nr,
NULL 																	as covg_period_term,
NULL	 																as coverage_period_txt,
NULL	 																as source_coverage_period_txt,
NULL	 																as coverage_person_cde,
NULL	 																as coverage_benefit_type_amt,
NULL	 																as palir_roll_status_cde,
NULL	 																as coverage_face_amt,
NULL	 																as coverage_income_amt,
NULL	 																as coverage_increase_pct,
NULL	 																as coverage_dividend_option_cde,
NULL	 																as source_coverage_dividend_option_cde,
NULL	 																as coverage_secondary_dividend_option_cde,
NULL	 																as source_coverage_secondary_dividend_option_cde,
NULL	 																as coverage_conversion_expiry_dt,
NULL	 																as coverage_conversion_eligibility_start_dt,
NULL	 																as coverage_fio_next_dt,
NULL	 																as coverage_fio_expiry_dt,
NULL	 																as coverage_employer_discount_type_cde,
NULL	 																as coverage_employer_discount_amt,
NULL	 																as coverage_employer_discount_pct,
NULL	 																as coverage_declared_dividend_amt,
NULL	 																as coverage_covered_insured_cde,
NULL	 																as coverage_cash_val_amt,
NULL 																	as covg_cash_value_sig,
NULL	 																as coverage_cash_val_quality_cde,
NULL	 																as elimination_period_sickness_cde,
NULL 																	as elmn_perd_sicknss_cde,
NULL 																	as waiting_period_sickness_cde,
NULL	 																as source_waiting_period_sickness_cde,
NULL	 																as source_waiting_period_sickness_day_cde,
NULL	 																as source_waiting_period_sickness_desc,
NULL	 																as elimination_period_injury_cde,
NULL	 																as source_waiting_period_injury_cde,
NULL	 																as source_waiting_period_injury_day_cde,
NULL	 																as source_waiting_period_injury_desc,
NULL	 																as benefit_period_sickness_cde,
NULL	 																as source_benefit_period_sickness_cde,
NULL	 																as source_benefit_period_sickness_duration_cde,
NULL	 																as source_benefit_period_sickness_desc,
NULL	 																as benefit_period_injury_cde,
NULL	 																as source_benefit_period_injury_cde,
NULL	 																as source_benefit_period_injury_duration_cde,
NULL	 																as source_benefit_period_injury_desc,
to_date(to_char(cycle_date), 'yyyymmdd')                       as begin_dt,
to_date(to_char(cycle_date), 'yyyymmdd') :: timestamp          as begin_dtm,
current_timestamp(6)			                                        as row_process_dtm,
null                            	                                    as check_sum, -- will be updated in the outer qry
'9999-12-31'::date                  	                                as end_dt,
'9999-12-31'::timestamp                 	                            as end_dtm,
false                                       	                        as restricted_row_ind,
true                                            	                    as current_row_ind,
false                                               	                as logical_delete_ind,
72                                                      		        as source_system_id,
:audit_id                                                       	    as audit_id,
:audit_id                                                           	as update_audit_id,
case
    when upper(processed_ind) = 'D' then true
    else false
    end                                                               	as source_delete_ind,
processed_ind	                                                       	as process_ind,
NULL	 																as coverage_smoker_cde,
NULL	 																as coverage_expiry_dt,
NULL	 																as source_coverage_smoker_cde,
NULL	 																as flat_extra_amt,
NULL	 																as flat_extra_expiry_dt,
NULL	 																as insured_permanent_temporary_cde,
NULL	 																as substandard_rating_1_pct,
NULL	 																as substandard_rating_type_1_cde,
NULL	 																as source_substandard_rating_type_1_cde,
NULL	 																as substandard_rating_2_pct,
NULL	 																as substandard_rating_type_2_cde,
NULL	 																as source_substandard_rating_type_2_cde,
NULL	 																as table_rating_cde,
NULL	 																as source_table_rating_cde,
NULL	 																as coverage_table_rating_pct
FROM 
(select * from edw_staging.aif_rps_edw_ctrt_full_dedup
union	
select * from edw_staging.aif_rps_edw_ctrt_delta_dedup where processed_ind = 'D') cov 
join edw_staging.aif_rps_edw_ctrt_delta_count covcnt
on covcnt.audit_id = cov.audit_id and covcnt.source_system_id = 72
where LTRIM(RTRIM(AIFCOW_WDRWL_OPT_CODE))  IN ('A','P','F')
) calc

--pdt join
     left join COVG_PROD_ID_HASH thash
     on clean_string(thash.coverage_pt1_kind_cde) = clean_string(calc.coverage_pt1_kind_cde)
     and clean_string(thash.coverage_pt2_issue_basis_cde) = clean_string(calc.coverage_pt2_issue_basis_cde)
     and clean_string(thash.coverage_pt3_rt_cde) = clean_string(calc.coverage_pt3_rt_cde)
	 
--agreement_source_cde
         left join (select distinct trnslt_fld_val, src_cde, src_fld_nm, src_fld_val, src_tbl_nm, trnslt_fld_nm
                    from edw_ref.src_data_trnslt
                    where upper(btrim(src_cde)) = 'ANN'
                      and upper(btrim(src_fld_nm)) = 'ADMN_SYS_CDE'
                      and upper(btrim(trnslt_fld_nm)) = 'ADMIN OR SOURCE SYSTEM CODE') sdt_agmt_src_cd
                   on upper(btrim(calc.covg_row_adm_sys_name)) = upper(btrim(sdt_agmt_src_cd.src_fld_val))


--coverage_status_cde
         left join (select distinct trnslt_fld_val, src_cde, src_fld_nm, src_fld_val, src_tbl_nm, trnslt_fld_nm
                    from edw_ref.src_data_trnslt
                    where upper(btrim(src_fld_nm)) = 'CONTRACT_STATUS_CODE'
                      and upper(btrim(trnslt_fld_nm)) = 'COVERAGE STATUS') sdt_covg_sts_cd
                   on upper(btrim(sdt_covg_sts_cd.src_cde)) = upper(sdt_agmt_src_cd.trnslt_fld_val)
				   and upper(btrim(calc.covg_excpt_sts)) = upper(btrim(sdt_covg_sts_cd.src_fld_val))

--coverage_type_cde
         left join (select distinct trnslt_fld_val, src_cde, src_fld_nm, src_fld_val, src_tbl_nm, trnslt_fld_nm 
                    from edw_ref.src_data_trnslt
                    where upper(btrim(src_cde)) = 'PT'
                      and upper(btrim(src_fld_nm)) = 'PROD_TYP_CDE'
                      and upper(btrim(trnslt_fld_nm)) = 'COVERAGE TYPE') sdt_covg_type_cd
                   on upper(btrim(thash.prod_typ_cde)) = upper(btrim(sdt_covg_type_cd.src_fld_val))
--where agreement_nr in ('00000000000502000050')
;




/* EDW_WORK.aifrps_DIM_COVERAGE - INSERTS
 *
 * THIS SCRIPT IS USED TO LOAD THE RECORDS THAT DON'T HAVE A RECORD IN TARGET
 * 
 */

select analyze_statistics('edw_staging.aifrps_dim_coverage_pre_work');



insert into edw_work.aifrps_dim_coverage

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

select dim_coverage_natural_key_hash_uuid
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
     , coverage_table_rating_pct

from edw_staging.aifrps_dim_coverage_pre_work
--insert when no records in target table insert only
where dim_coverage_natural_key_hash_uuid not in
      (select distinct dim_coverage_natural_key_hash_uuid from {{target_schema}}.dim_coverage where source_system_id in ('72','266'));


/* EDW_WORK.aifrps_DIM_COVERAGE WORK TABLE - Insert updated TGT records from DIM_COVERAGE table
 *
 * THIS SCRIPT FINDS RECORDS WHERE THE NEW RECORD FROM THE SOURCE HAS A DIFFERENT CHECK_SUM THAN THE CURRENT TARGET RECORD.
 * THE CURRENT RECORD IN THE TARGET WILL BE ENDED SINCE THE SOURCE RECORD WILL BE INSERTED IN THE NEXT STEP.
 * 
 */

select analyze_statistics('edw_work.aifrps_dim_coverage');

insert into edw_work.aifrps_dim_coverage

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
     , dim.audit_id
     , prework.update_audit_id
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

from {{target_schema}}.dim_coverage dim
join
edw_staging.aifrps_dim_coverage_pre_work prework
on dim.dim_coverage_natural_key_hash_uuid=prework.dim_coverage_natural_key_hash_uuid
    and dim.current_row_ind= true
where
    --change in check_sum
    (dim.check_sum <> prework.check_sum);




/* EDW_WORK.aifrps_DIM_COVERAGE WORK TABLE - Insert Updated SRC records from PreWork table
 *
 * THIS SCRIPT FINDS RECORDS WHERE THE NEW RECORD FROM THE SOURCE HAS A DIFFERENT CHECK_SUM THAN THE CURRENT TARGET RECORD.
 * THE CURRENT RECORD IN THE SOURCE WILL BE INSERTED IN THE WORK TABLE.
 *
 */

insert into edw_work.aifrps_dim_coverage

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

from edw_staging.aifrps_dim_coverage_pre_work prework
         left join
    {{target_schema}}.dim_coverage dim
on dim.dim_coverage_natural_key_hash_uuid=prework.dim_coverage_natural_key_hash_uuid
    and dim.current_row_ind= true
where
--handle when there isn't a current record in target but there are historical records and a delta coming through
    (dim.row_sid is null
  and prework.dim_coverage_natural_key_hash_uuid in
    (select distinct dim_coverage_natural_key_hash_uuid from {{target_schema}}.dim_coverage dim where source_system_id in ('72','266')) )

--handle when there is a current target record and either the check_sum has changed or record is being logically deleted.
   or
    (dim.row_sid is not null
--checksum changed
  and (dim.check_sum <> prework.check_sum)

    )
;



---deleteme

/*
 ************ Calculating the Deleted Records *******************
 */


/* edw_work.aifrps_dim_coverage WORK TABLE - Insert the updated TGT records from DIM_COVERAGE table
 *
 * THIS SCRIPT FINDS RECORDS WHERE THE RECORD IS MISSING IN PREWORK TABLE BUT PRESENT IN DIM_COVERAGE.
 * THE CURRENT RECORD IN THE TARGET WILL BE ENDED SINCE THE SOURCE RECORD WILL BE CREATED AND INSERTED IN THE NEXT STEP.
 *
 */



insert into edw_work.aifrps_dim_coverage

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
     , current_timestamp(6)                                  as row_process_dtm
     , dim.check_sum
     , (cnt.cnt_cycle_date - interval '1' day)::date         as end_dt
     , (cnt.cnt_cycle_date - interval '1' second)::timestamp as end_dtm
     , dim.restricted_row_ind
     , false                                                 as current_row_ind
     , dim.logical_delete_ind
     , dim.source_system_id
     , dim.audit_id
     , cnt.audit_id                                          as update_audit_id
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
from {{target_schema}}.dim_coverage dim
         join
     edw_staging.aif_rps_edw_ctrt_delta_dedup ctrt
     on dim.agreement_nr = udf_aif_hldg_key_format(aifcow_policy_id,'KEY')      
	 and COALESCE(dim.agreement_nr_pfx,'') = COALESCE(clean_string(udf_aif_hldg_key_format(aifcow_policy_id,'PFX')),'') 
     and COALESCE(dim.agreement_nr_sfx,'') = COALESCE(clean_string(udf_aif_hldg_key_format(aifcow_policy_id,'SFX')),'')
         join
     (select to_date(to_char(cycle_date), 'yyyymmdd') as cnt_cycle_date, audit_id
      from edw_staging.aif_rps_edw_ctrt_delta_count) cnt
     on 1 = 1
         left join
     edw_staging.aifrps_dim_coverage_pre_work prework
     on dim.dim_coverage_natural_key_hash_uuid = prework.dim_coverage_natural_key_hash_uuid
where
  --records not present in pre-work table
    dim.current_row_ind = true
  and dim.source_delete_ind = false
  and dim.source_system_id in ('72', '266')
  and prework.dim_coverage_natural_key_hash_uuid is null
;


/* edw_work.aifrps_dim_coverage WORK TABLE - Create and Insert the deleted SRC records using DIM_COVERAGE and PreWork table
 *
 * THIS SCRIPT FINDS RECORDS WHERE THE RECORD IS MISSING IN PREWORK TABLE BUT PRESENT IN DIM_COVERAGE..
 * THE CURRENT RECORD MISSING IN THE SOURCE WILL BE INSERTED IN THE WORK TABLE AS SOURCE_DELETE_IND=TRUE.
 *
 */


insert into edw_work.aifrps_dim_coverage

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
     , cnt.cnt_cycle_date                           as begin_dt
     , cnt.cnt_cycle_date :: timestamp              as begin_dtm
     , current_timestamp(6)                         as row_process_dtm
     , uuid_gen(true, to_char(dim.check_sum))::uuid as check_sum
     , '9999-12-31'::date                           as end_dt
     , '9999-12-31'::timestamp                      as end_dtm
     , false                                        as restricted_row_ind
     , true                                         as current_row_ind
     , false                                        as logical_delete_ind
     , 72                                           as source_system_id
     , :audit_id                                    as audit_id
     , :audit_id                                    as update_audit_id
     , true                                         as source_delete_ind -- source_delete_ind marking as true
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
from {{target_schema}}.dim_coverage dim
         join
     edw_staging.aif_rps_edw_ctrt_delta_dedup ctrt
     on dim.agreement_nr = udf_aif_hldg_key_format(aifcow_policy_id,'KEY')   
	 and COALESCE(dim.agreement_nr_pfx,'') = COALESCE(clean_string(udf_aif_hldg_key_format(aifcow_policy_id,'PFX')),'') 
     and COALESCE(dim.agreement_nr_sfx,'') = COALESCE(clean_string(udf_aif_hldg_key_format(aifcow_policy_id,'SFX')),'')
         join
     (select to_date(to_char(cycle_date), 'yyyymmdd') as cnt_cycle_date, audit_id
      from edw_staging.aif_rps_edw_ctrt_delta_count) cnt
     on 1 = 1
         left join
     edw_staging.aifrps_dim_coverage_pre_work prework
     on dim.dim_coverage_natural_key_hash_uuid = prework.dim_coverage_natural_key_hash_uuid
where dim.current_row_ind = true
  and dim.source_delete_ind = false
  and dim.source_system_id in ('72', '266')
  and prework.dim_coverage_natural_key_hash_uuid is null
;
