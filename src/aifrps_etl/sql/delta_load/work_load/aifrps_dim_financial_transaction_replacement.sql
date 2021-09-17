/*
		FILENAME: AIFRPS_DIM_FINANCIAL_TRANSACTION_REPLACEMENT.SQL
		AUTHOR: SATWIK CHEBROLU / SURESH REDDY MEDAPATI
		SUBJECT AREA : AGREEMENT
		SOURCE: AIF-RPS
		SOURCE SYSTEM CODE: 72
		DESCRIPTION: DIM_FINANCIAL_TRANSACTION TABLE DELTA POPULATION FOR REPLACEMENT TRANSACTIONS
		JIRA: 
		CREATE DATE:08/03/2021

		===============================================================================================================
		VERSION/JIRA STORY#			CREATED BY          LAST_MODIFIED_DATE		DESCRIPTION
		---------------------------------------------------------------------------------------------------------------
									MM06683 / MM16034       08/03/2021			FIRST VERSION OF DDL FOR TIER-2
									                    
		---------------------------------------------------------------------------------------------------------------
*/ 

--clean up the prework and work table before loading
truncate table edw_staging.aifrps_dim_financial_transaction_replacement_pre_work;

truncate table edw_work.aifrps_dim_financial_transaction_replacement;

--load data into pre-work table.
insert into edw_staging.aifrps_dim_financial_transaction_replacement_pre_work
(
dim_financial_transaction_natural_key_hash_uuid,
financial_transaction_unique_id,
ref_financial_transaction_source_natural_key_hash_uuid,
ref_financial_transaction_type_natural_key_hash_uuid,
pay_group_nr_txt,
check_form_id,
transaction_dt,
check_status_cde,
account_nr_txt,
tax_reporting_cde,
original_check_nr,
distribution_cde,
source_payee_unique_id,
clear_dt,
clear_reference_nr_txt,
reversal_dt,
begin_dt,
begin_dtm,
row_process_dtm,
audit_id,
logical_delete_ind,
check_sum,
current_row_ind,
end_dt,
end_dtm,
source_system_id,
restricted_row_ind,
update_audit_id,
source_delete_ind,
source_transaction_key_txt,
routing_nr_txt,
payment_method_cde,
previous_source_transaction_key_txt,
effective_dt,
system_dt,
transaction_cde,
source_transaction_cde,
transaction_reversal_cde,
admin_fund_cde,
product_id,
company_cde,
source_company_cde,
pt1_kind_cde,
product_tier_cde,
fund_type_cde,
source_fund_type_cde,
coverage_type_cde,
coverage_occurance_nr,
transaction_source_id,
transaction_memo_cde,
rollover_cde,
source_rollover_cde,
gmib_status_cde,
administration_cde,
source_administration_cde,
disbursement_transaction_nr_txt,
replacement_transaction_nr_txt,
transaction_desc,
source_transaction_desc,
transaction_reporting_desc,
transaction_reporting_detail_desc
)

select 
uuid_gen(
clean_string(agreement_source_cde),
clean_string(agreement_type_cde),
clean_string(agreement_nr_pfx),
clean_string(agreement_nr),
clean_string(agreement_nr_sfx),
clean_string(replacement_transaction_nr_txt),
clean_string(financial_transaction_source),
clean_string(financial_transaction_type))::uuid as dim_financial_transaction_natural_key_hash_uuid,

prehash_value(
clean_string(agreement_source_cde),
clean_string(agreement_type_cde),
clean_string(agreement_nr_pfx),
clean_string(agreement_nr),
clean_string(agreement_nr_sfx),
clean_string(replacement_transaction_nr_txt)) as financial_transaction_unique_id,

uuid_gen(
clean_string(financial_transaction_source))::uuid as ref_financial_transaction_source_natural_key_hash_uuid,

uuid_gen(
clean_string(financial_transaction_type))::uuid as ref_financial_transaction_type_natural_key_hash_uuid,

pay_group_nr_txt,
check_form_id,
transaction_dt,
check_status_cde,
account_nr_txt,
tax_reporting_cde,
original_check_nr,
distribution_cde,
source_payee_unique_id,
clear_dt,
clear_reference_nr_txt,
reversal_dt,
begin_dt,
begin_dt::timestamp as begin_dtm,
row_process_dtm,
audit_id,
logical_delete_ind,
uuid_gen(source_delete_ind)::uuid as check_sum,
current_row_ind,
end_dt,
end_dtm,
source_system_id,
restricted_row_ind,
update_audit_id,
source_delete_ind,
source_transaction_key_txt,
routing_nr_txt,
payment_method_cde,
previous_source_transaction_key_txt,
effective_dt,
system_dt,
transaction_cde,
source_transaction_cde,
transaction_reversal_cde,
admin_fund_cde,
product_id,
company_cde,
source_company_cde,
pt1_kind_cde,
product_tier_cde,
fund_type_cde,
source_fund_type_cde,
coverage_type_cde,
coverage_occurance_nr,
transaction_source_id,
transaction_memo_cde,
rollover_cde,
source_rollover_cde,
gmib_status_cde,
administration_cde,
source_administration_cde,
disbursement_transaction_nr_txt,
replacement_transaction_nr_txt,
transaction_desc,
source_transaction_desc,
transaction_reporting_desc,
transaction_reporting_detail_desc
from (

select
agrmt_sdt.trnslt_fld_val as agreement_source_cde,
'Ipa' as agreement_type_cde,
public.udf_aif_hldg_key_format(agrmtdelta.aifcow_policy_id,'PFX') as agreement_nr_pfx, 
public.udf_aif_hldg_key_format(agrmtdelta.aifcow_policy_id,'KEY') as agreement_nr, 
public.udf_aif_hldg_key_format(agrmtdelta.aifcow_policy_id,'SFX') as agreement_nr_sfx,
fts_sdt.trnslt_fld_val as financial_transaction_source,
ftt_sdt.trnslt_fld_val as financial_transaction_type,

null as pay_group_nr_txt,
null as check_form_id,
null as transaction_dt,
null as check_status_cde,
null as account_nr_txt,
null as tax_reporting_cde,
null as original_check_nr,
null as distribution_cde,
null as source_payee_unique_id,
null as clear_dt,
null as clear_reference_nr_txt,
null as reversal_dt,

public.isdate(clean_string(agrmtcyc.cycle_date::varchar)) as begin_dt,
--begin_dtm,
current_timestamp(6) as row_process_dtm,
:audit_id as audit_id,
false as logical_delete_ind,
--check_sum,
true as current_row_ind,
'9999-12-31'::date as end_dt,
'9999-12-31'::timestamp as end_dtm,
72 as source_system_id,
false as restricted_row_ind,
:audit_id as update_audit_id,
case when upper(agrmtdelta.processed_ind) ='D' then true
else false end as source_delete_ind,

null as source_transaction_key_txt,
null as routing_nr_txt,
null as payment_method_cde,
null as previous_source_transaction_key_txt,
null as effective_dt,
null as system_dt,
null as transaction_cde,
null as source_transaction_cde,
null as transaction_reversal_cde,
null as admin_fund_cde,
null as product_id,
null as company_cde,
null as source_company_cde,
null as pt1_kind_cde,
null as product_tier_cde,
null as fund_type_cde,
null as source_fund_type_cde,
null as coverage_type_cde,
null as coverage_occurance_nr,
null as transaction_source_id,
null as transaction_memo_cde,
null as rollover_cde,
null as source_rollover_cde,
null as gmib_status_cde,
null as administration_cde,
null as source_administration_cde,
null as disbursement_transaction_nr_txt,
null as replacement_transaction_nr_txt,
null as transaction_desc,
null as source_transaction_desc,
null as transaction_reporting_desc,
null as transaction_reporting_detail_desc


from edw_staging.aif_rps_edw_ctrt_delta_dedup agrmtdelta
inner join edw_staging.aif_rps_edw_ctrt_delta_count agrmtcyc
on agrmtdelta.audit_id=agrmtcyc.audit_id
and agrmtcyc.source_system_id =72


--agreement_source_cde
left join (select distinct trnslt_fld_val, src_cde, src_fld_nm, src_fld_val, src_tbl_nm , trnslt_fld_nm from edw_ref.src_data_trnslt
where upper(btrim(src_cde)) ='ANN'
and upper(btrim(src_fld_nm)) ='ADMN_SYS_CDE'
and upper(btrim(trnslt_fld_nm)) = 'ADMIN OR SOURCE SYSTEM CODE') agrmt_sdt
on upper(btrim(agrmt_sdt.src_fld_val)) = upper(udf_replaceemptystr(agrmtdelta.aifcow_source_system_id, 'SPACE'))

--financial_transaction_source
left join (select distinct trnslt_fld_val, src_cde, src_fld_nm, src_fld_val, src_tbl_nm , trnslt_fld_nm from edw_ref.src_data_trnslt
where upper(btrim(src_cde)) ='TERSUN'
and upper(btrim(src_fld_nm)) ='CARR_ADMIN_SYS_CD'
and upper(btrim(trnslt_fld_nm)) = 'FINANCIAL TRANSACTION SOURCE CDE') fts_sdt
on upper(btrim(fts_sdt.src_fld_val)) = upper(btrim(agrmt_sdt.trnslt_fld_val)) 
--'ASIA'

--financial_transaction_type
left join (select distinct trnslt_fld_val, src_cde, src_fld_nm, src_fld_val, src_tbl_nm , trnslt_fld_nm from edw_ref.src_data_trnslt
where upper(btrim(src_cde)) ='TERSUN'
and upper(btrim(src_fld_nm)) ='FINANCIAL TRANSACTION TYPE'
and upper(btrim(trnslt_fld_nm)) = 'FINANCIAL TRANSACTION TYPE CDE') ftt_sdt
on upper(btrim(ftt_sdt.src_fld_val)) = 'REPLACEMENT TRANSACTION'

) agreement_replacement;

select analyze_statistics('edw_staging.aifrps_dim_financial_transaction_replacement_pre_work');


/* WORK TABLE - INSERTS 
 * 
 * this script is used to load the records that don't have a record in target
 * */


insert into edw_work.aifrps_dim_financial_transaction_replacement
(
dim_financial_transaction_natural_key_hash_uuid,
financial_transaction_unique_id,
ref_financial_transaction_source_natural_key_hash_uuid,
ref_financial_transaction_type_natural_key_hash_uuid,
pay_group_nr_txt,
check_form_id,
transaction_dt,
check_status_cde,
account_nr_txt,
tax_reporting_cde,
original_check_nr,
distribution_cde,
source_payee_unique_id,
clear_dt,
clear_reference_nr_txt,
reversal_dt,
begin_dt,
begin_dtm,
row_process_dtm,
audit_id,
logical_delete_ind,
check_sum,
current_row_ind,
end_dt,
end_dtm,
source_system_id,
restricted_row_ind,
update_audit_id,
source_delete_ind,
source_transaction_key_txt,
routing_nr_txt,
payment_method_cde,
previous_source_transaction_key_txt,
effective_dt,
system_dt,
transaction_cde,
source_transaction_cde,
transaction_reversal_cde,
admin_fund_cde,
product_id,
company_cde,
source_company_cde,
pt1_kind_cde,
product_tier_cde,
fund_type_cde,
source_fund_type_cde,
coverage_type_cde,
coverage_occurance_nr,
transaction_source_id,
transaction_memo_cde,
rollover_cde,
source_rollover_cde,
gmib_status_cde,
administration_cde,
source_administration_cde,
disbursement_transaction_nr_txt,
replacement_transaction_nr_txt,
transaction_desc,
source_transaction_desc,
transaction_reporting_desc,
transaction_reporting_detail_desc
)
select
dim_financial_transaction_natural_key_hash_uuid,
financial_transaction_unique_id,
ref_financial_transaction_source_natural_key_hash_uuid,
ref_financial_transaction_type_natural_key_hash_uuid,
pay_group_nr_txt,
check_form_id,
transaction_dt,
check_status_cde,
account_nr_txt,
tax_reporting_cde,
original_check_nr,
distribution_cde,
source_payee_unique_id,
clear_dt,
clear_reference_nr_txt,
reversal_dt,
begin_dt,
begin_dtm,
row_process_dtm,
audit_id,
logical_delete_ind,
check_sum,
current_row_ind,
end_dt,
end_dtm,
source_system_id,
restricted_row_ind,
update_audit_id,
source_delete_ind,
source_transaction_key_txt,
routing_nr_txt,
payment_method_cde,
previous_source_transaction_key_txt,
effective_dt,
system_dt,
transaction_cde,
source_transaction_cde,
transaction_reversal_cde,
admin_fund_cde,
product_id,
company_cde,
source_company_cde,
pt1_kind_cde,
product_tier_cde,
fund_type_cde,
source_fund_type_cde,
coverage_type_cde,
coverage_occurance_nr,
transaction_source_id,
transaction_memo_cde,
rollover_cde,
source_rollover_cde,
gmib_status_cde,
administration_cde,
source_administration_cde,
disbursement_transaction_nr_txt,
replacement_transaction_nr_txt,
transaction_desc,
source_transaction_desc,
transaction_reporting_desc,
transaction_reporting_detail_desc
from edw_staging.aifrps_dim_financial_transaction_replacement_pre_work
--insert when either no records in target table
where (dim_financial_transaction_natural_key_hash_uuid) not in 
(select distinct dim_financial_transaction_natural_key_hash_uuid from edw_financial_transactions.dim_financial_transaction
where source_system_id in ('72','266'));



/* WORK TABLE - UPDATE TGT RECORD
 * 
 * This script finds records where the new record from the source has a different check_sum than the current target record or the record is being ended/deleted. 
 * The current record in the target will be ended since the source record will be inserted in the next step.
 * */


insert into edw_work.aifrps_dim_financial_transaction_replacement
(
dim_financial_transaction_natural_key_hash_uuid,
financial_transaction_unique_id,
ref_financial_transaction_source_natural_key_hash_uuid,
ref_financial_transaction_type_natural_key_hash_uuid,
pay_group_nr_txt,
check_form_id,
transaction_dt,
check_status_cde,
account_nr_txt,
tax_reporting_cde,
original_check_nr,
distribution_cde,
source_payee_unique_id,
clear_dt,
clear_reference_nr_txt,
reversal_dt,
begin_dt,
begin_dtm,
row_process_dtm,
audit_id,
logical_delete_ind,
check_sum,
current_row_ind,
end_dt,
end_dtm,
source_system_id,
restricted_row_ind,
update_audit_id,
source_delete_ind,
source_transaction_key_txt,
routing_nr_txt,
payment_method_cde,
previous_source_transaction_key_txt,
effective_dt,
system_dt,
transaction_cde,
source_transaction_cde,
transaction_reversal_cde,
admin_fund_cde,
product_id,
company_cde,
source_company_cde,
pt1_kind_cde,
product_tier_cde,
fund_type_cde,
source_fund_type_cde,
coverage_type_cde,
coverage_occurance_nr,
transaction_source_id,
transaction_memo_cde,
rollover_cde,
source_rollover_cde,
gmib_status_cde,
administration_cde,
source_administration_cde,
disbursement_transaction_nr_txt,
replacement_transaction_nr_txt,
transaction_desc,
source_transaction_desc,
transaction_reporting_desc,
transaction_reporting_detail_desc
)
select
dft.dim_financial_transaction_natural_key_hash_uuid,
dft.financial_transaction_unique_id,
dft.ref_financial_transaction_source_natural_key_hash_uuid,
dft.ref_financial_transaction_type_natural_key_hash_uuid,
dft.pay_group_nr_txt,
dft.check_form_id,
dft.transaction_dt,
dft.check_status_cde,
dft.account_nr_txt,
dft.tax_reporting_cde,
dft.original_check_nr,
dft.distribution_cde,
dft.source_payee_unique_id,
dft.clear_dt,
dft.clear_reference_nr_txt,
dft.reversal_dt,
dft.begin_dt,
dft.begin_dtm,
current_timestamp(6) as row_process_dtm,
dft.audit_id,
dft.logical_delete_ind,
dft.check_sum,
false as current_row_ind,
dft.begin_dt - interval '1' day  as end_dt,
dft.begin_dt - interval '1' second  as end_dtm,
dft.source_system_id,
dft.restricted_row_ind,
pw.update_audit_id,
dft.source_delete_ind,
dft.source_transaction_key_txt,
dft.routing_nr_txt,
dft.payment_method_cde,
dft.previous_source_transaction_key_txt,
dft.effective_dt,
dft.system_dt,
dft.transaction_cde,
dft.source_transaction_cde,
dft.transaction_reversal_cde,
dft.admin_fund_cde,
dft.product_id,
dft.company_cde,
dft.source_company_cde,
dft.pt1_kind_cde,
dft.product_tier_cde,
dft.fund_type_cde,
dft.source_fund_type_cde,
dft.coverage_type_cde,
dft.coverage_occurance_nr,
dft.transaction_source_id,
dft.transaction_memo_cde,
dft.rollover_cde,
dft.source_rollover_cde,
dft.gmib_status_cde,
dft.administration_cde,
dft.source_administration_cde,
dft.disbursement_transaction_nr_txt,
dft.replacement_transaction_nr_txt,
dft.transaction_desc,
dft.source_transaction_desc,
dft.transaction_reporting_desc,
dft.transaction_reporting_detail_desc
from edw_financial_transactions.dim_financial_transaction dft
inner join edw_staging.aifrps_dim_financial_transaction_replacement_pre_work pw
on dft.dim_financial_transaction_natural_key_hash_uuid = pw.dim_financial_transaction_natural_key_hash_uuid
and dft.current_row_ind = true
and dft.source_system_id in ('72','266')
--change in check_sum
where dft.check_sum <> pw.check_sum ;


/* WORK TABLE - UPDATE WHERE RECORD ALREADY EXISTS IN TARGET 
 * 
 * 
 * */
insert into edw_work.aifrps_dim_financial_transaction_replacement
(
dim_financial_transaction_natural_key_hash_uuid,
financial_transaction_unique_id,
ref_financial_transaction_source_natural_key_hash_uuid,
ref_financial_transaction_type_natural_key_hash_uuid,
pay_group_nr_txt,
check_form_id,
transaction_dt,
check_status_cde,
account_nr_txt,
tax_reporting_cde,
original_check_nr,
distribution_cde,
source_payee_unique_id,
clear_dt,
clear_reference_nr_txt,
reversal_dt,
begin_dt,
begin_dtm,
row_process_dtm,
audit_id,
logical_delete_ind,
check_sum,
current_row_ind,
end_dt,
end_dtm,
source_system_id,
restricted_row_ind,
update_audit_id,
source_delete_ind,
source_transaction_key_txt,
routing_nr_txt,
payment_method_cde,
previous_source_transaction_key_txt,
effective_dt,
system_dt,
transaction_cde,
source_transaction_cde,
transaction_reversal_cde,
admin_fund_cde,
product_id,
company_cde,
source_company_cde,
pt1_kind_cde,
product_tier_cde,
fund_type_cde,
source_fund_type_cde,
coverage_type_cde,
coverage_occurance_nr,
transaction_source_id,
transaction_memo_cde,
rollover_cde,
source_rollover_cde,
gmib_status_cde,
administration_cde,
source_administration_cde,
disbursement_transaction_nr_txt,
replacement_transaction_nr_txt,
transaction_desc,
source_transaction_desc,
transaction_reporting_desc,
transaction_reporting_detail_desc
)
select
pw.dim_financial_transaction_natural_key_hash_uuid,
pw.financial_transaction_unique_id,
pw.ref_financial_transaction_source_natural_key_hash_uuid,
pw.ref_financial_transaction_type_natural_key_hash_uuid,
pw.pay_group_nr_txt,
pw.check_form_id,
pw.transaction_dt,
pw.check_status_cde,
pw.account_nr_txt,
pw.tax_reporting_cde,
pw.original_check_nr,
pw.distribution_cde,
pw.source_payee_unique_id,
pw.clear_dt,
pw.clear_reference_nr_txt,
pw.reversal_dt,
pw.begin_dt,
pw.begin_dtm,
current_timestamp(6) as row_process_dtm,
pw.audit_id,
pw.logical_delete_ind,
pw.check_sum,
pw.current_row_ind,
pw.end_dt,
pw.end_dtm,
pw.source_system_id,
pw.restricted_row_ind,
pw.update_audit_id,
pw.source_delete_ind,
pw.source_transaction_key_txt,
pw.routing_nr_txt,
pw.payment_method_cde,
pw.previous_source_transaction_key_txt,
pw.effective_dt,
pw.system_dt,
pw.transaction_cde,
pw.source_transaction_cde,
pw.transaction_reversal_cde,
pw.admin_fund_cde,
pw.product_id,
pw.company_cde,
pw.source_company_cde,
pw.pt1_kind_cde,
pw.product_tier_cde,
pw.fund_type_cde,
pw.source_fund_type_cde,
pw.coverage_type_cde,
pw.coverage_occurance_nr,
pw.transaction_source_id,
pw.transaction_memo_cde,
pw.rollover_cde,
pw.source_rollover_cde,
pw.gmib_status_cde,
pw.administration_cde,
pw.source_administration_cde,
pw.disbursement_transaction_nr_txt,
pw.replacement_transaction_nr_txt,
pw.transaction_desc,
pw.source_transaction_desc,
pw.transaction_reporting_desc,
pw.transaction_reporting_detail_desc
from edw_staging.aifrps_dim_financial_transaction_replacement_pre_work pw
left join edw_financial_transactions.dim_financial_transaction dft
on dft.dim_financial_transaction_natural_key_hash_uuid = pw.dim_financial_transaction_natural_key_hash_uuid
and dft.current_row_ind = true
where 
--handle when there isn't a current record in target but there are historical records and a delta coming through
(dft.row_sid is null and (pw.dim_financial_transaction_natural_key_hash_uuid)  in 
(select distinct dim_financial_transaction_natural_key_hash_uuid from edw_financial_transactions.dim_financial_transaction
where source_system_id in ('72','266')))

--handle when there is a current target record and either the check_sum has changed or record is being logically deleted.
or 
(dft.row_sid is not null 
--checksum changed
and (dft.check_sum <> pw.check_sum)
);

select analyze_statistics('edw_work.aifrps_dim_financial_transaction_replacement');

