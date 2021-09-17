/*
		FILENAME: AIFRPS_FACT_REPLACEMENT_TRANSACTION.SQL
		AUTHOR: SATWIK CHEBROLU / SURESH REDDY MEDAPATI
		SUBJECT AREA : AGREEMENT
		SOURCE: AIF-RPS
		SOURCE SYSTEM CODE: 72
		DESCRIPTION: FACT_REPLACEMENT_TRANSACTION TABLE DELTA POPULATION
		JIRA: 
		CREATE DATE:08/02/2021

		===============================================================================================================
		VERSION/JIRA STORY#			CREATED BY          LAST_MODIFIED_DATE		DESCRIPTION
		---------------------------------------------------------------------------------------------------------------
									MM06683 / MM16034     08/02/2021			FIRST VERSION OF DDL FOR TIER-2
									                    
		---------------------------------------------------------------------------------------------------------------
*/ 

--clean up the prework and work table before loading
truncate table edw_staging.aifrps_fact_replacement_transaction_pre_work;

truncate table edw_work.aifrps_fact_replacement_transaction;

--load data into pre-work table.
insert into edw_staging.aifrps_fact_replacement_transaction_pre_work
(
fact_replacement_transaction_natural_key_hash_uuid,
dim_financial_transaction_natural_key_hash_uuid,
calender_dt,
replacement_type_cde,
source_replacement_type_cde,
exchange_type_cde,
source_exchange_type_cde,
replaced_agreement_nr,
replaced_company_nm,
estimated_transfer_amt,
rt_lock_dt,
rt_lock_cde,
source_rt_lock_cde,
fund_received_cde,
source_fund_received_cde,
distribution_transaction_id,
row_process_dtm,
check_sum,
restricted_row_ind,
logical_delete_ind,
source_system_id,
audit_id,
update_audit_id,
source_delete_ind
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
clean_string(financial_transaction_type),
calender_dt)::uuid as fact_replacement_transaction_natural_key_hash_uuid,

uuid_gen(
clean_string(agreement_source_cde),
clean_string(agreement_type_cde),
clean_string(agreement_nr_pfx),
clean_string(agreement_nr),
clean_string(agreement_nr_sfx),
clean_string(replacement_transaction_nr_txt),
clean_string(financial_transaction_source),
clean_string(financial_transaction_type))::uuid as dim_financial_transaction_natural_key_hash_uuid,

calender_dt,
replacement_type_cde,
source_replacement_type_cde,
exchange_type_cde,
source_exchange_type_cde,
replaced_agreement_nr,
replaced_company_nm,
estimated_transfer_amt,
rt_lock_dt,
rt_lock_cde,
source_rt_lock_cde,
fund_received_cde,
source_fund_received_cde,
distribution_transaction_id,
row_process_dtm,
uuid_gen(
source_delete_ind,
replacement_type_cde,
source_replacement_type_cde,
exchange_type_cde,
source_exchange_type_cde,
replaced_agreement_nr,
estimated_transfer_amt)::uuid as check_sum,
restricted_row_ind,
logical_delete_ind,
source_system_id,
audit_id,
update_audit_id,
source_delete_ind
from (

select
agrmt_sdt.trnslt_fld_val as agreement_source_cde,
'Ipa' as agreement_type_cde,
public.udf_aif_hldg_key_format(agrmtdelta.aifcow_policy_id,'PFX') as agreement_nr_pfx, 
public.udf_aif_hldg_key_format(agrmtdelta.aifcow_policy_id,'KEY') as agreement_nr, 
public.udf_aif_hldg_key_format(agrmtdelta.aifcow_policy_id,'SFX') as agreement_nr_sfx,

null as replacement_transaction_nr_txt,

fts_sdt.trnslt_fld_val as financial_transaction_source,
ftt_sdt.trnslt_fld_val as financial_transaction_type,


public.isdate(clean_string(agrmtcyc.cycle_date::varchar)) as calender_dt,
case when aifrpsrtcsdt.trnslt_fld_val is null then 'Unk' 
else clean_string(aifrpsrtcsdt.trnslt_fld_val) end as replacement_type_cde,
case when agrmtdelta.aifcow_source_system_id ='RPS' then agrmtdelta.aifcow_rps_replacement_type
else agrmtdelta.aifcow_replacement_type end as source_replacement_type_cde,
case when aifrpsetcsdt.trnslt_fld_val is null then 'Unk' 
else clean_string(aifrpsetcsdt.trnslt_fld_val) end as exchange_type_cde,
agrmtdelta.aifcow_rps_replacement_type as source_exchange_type_cde,
clean_string(agrmtdelta.aifcow_replacement_policy) as replaced_agreement_nr,

null as replaced_company_nm,

agrmtdelta.aifcow_replace_pol_cst_basis as estimated_transfer_amt,

null as rt_lock_dt,
null as rt_lock_cde,
null as source_rt_lock_cde,
null as fund_received_cde,
null as source_fund_received_cde,
null as distribution_transaction_id,

current_timestamp(6) as row_process_dtm,
null as check_sum,
false as restricted_row_ind,
false as logical_delete_ind,
72 as source_system_id,
:audit_id as audit_id,
:audit_id as update_audit_id,
false as source_delete_ind
from edw_staging.aif_rps_edw_ctrt_delta_dedup agrmtdelta
inner join edw_staging.aif_rps_edw_ctrt_delta_count agrmtcyc
on agrmtdelta.audit_id=agrmtcyc.audit_id
and agrmtcyc.source_system_id =72
and agrmtdelta.processed_ind <> 'D'


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


--financial_transaction_type
left join (select distinct trnslt_fld_val, src_cde, src_fld_nm, src_fld_val, src_tbl_nm , trnslt_fld_nm from edw_ref.src_data_trnslt
where upper(btrim(src_cde)) ='TERSUN'
and upper(btrim(src_fld_nm)) ='FINANCIAL TRANSACTION TYPE'
and upper(btrim(trnslt_fld_nm)) = 'FINANCIAL TRANSACTION TYPE CDE') ftt_sdt
on upper(btrim(ftt_sdt.src_fld_val)) = 'REPLACEMENT TRANSACTION'

--replacement_type_cde
left join (select distinct trnslt_fld_val, src_cde, src_fld_nm, src_fld_val, trnslt_fld_nm 
from edw_ref.src_data_trnslt 
where upper(btrim(src_cde)) ='ANN'
and upper(btrim(src_fld_nm))  ='REPLACEMENT_CODE'
and upper(btrim(trnslt_fld_nm))  ='REPLACEMENT CODE') aifrpsrtcsdt
on upper(btrim(aifrpsrtcsdt.src_fld_val)) = upper(udf_replaceemptystr(agrmtdelta.aifcow_rps_replacement_type, 'SPACE'))

--exchange_type_cde
left join (select distinct trnslt_fld_val, src_cde, src_fld_nm,  src_fld_val, trnslt_fld_nm 
from edw_ref.src_data_trnslt 
where upper(btrim(src_cde)) ='ANN'
and upper(btrim(src_fld_nm))  ='EXCHANGE_TYPE_CODE' 
and upper(btrim(trnslt_fld_nm))  ='REPLACEMENT CODE') aifrpsetcsdt
on upper(btrim(aifrpsetcsdt.src_fld_val)) = upper(udf_replaceemptystr(agrmtdelta.aifcow_rps_replacement_type, 'SPACE'))
) fact_replacement ;


select analyze_statistics('edw_staging.aifrps_fact_replacement_transaction_pre_work') ;

-- Step 2 insert brand new records to target
--use dim_financial_transaction_natural_key_hash_uuid as key in join condition
insert into edw_work.aifrps_fact_replacement_transaction
(
fact_replacement_transaction_natural_key_hash_uuid,
dim_financial_transaction_natural_key_hash_uuid,
calender_dt,
replacement_type_cde,
source_replacement_type_cde,
exchange_type_cde,
source_exchange_type_cde,
replaced_agreement_nr,
replaced_company_nm,
estimated_transfer_amt,
rt_lock_dt,
rt_lock_cde,
source_rt_lock_cde,
fund_received_cde,
source_fund_received_cde,
distribution_transaction_id,
row_process_dtm,
check_sum,
restricted_row_ind,
logical_delete_ind,
source_system_id,
audit_id,
update_audit_id,
source_delete_ind
)

select 
fact_replacement_transaction_natural_key_hash_uuid,
dim_financial_transaction_natural_key_hash_uuid,
calender_dt,
replacement_type_cde,
source_replacement_type_cde,
exchange_type_cde,
source_exchange_type_cde,
replaced_agreement_nr,
replaced_company_nm,
estimated_transfer_amt,
rt_lock_dt,
rt_lock_cde,
source_rt_lock_cde,
fund_received_cde,
source_fund_received_cde,
distribution_transaction_id,
row_process_dtm,
check_sum,
restricted_row_ind,
logical_delete_ind,
source_system_id,
audit_id,
update_audit_id,
source_delete_ind
from edw_staging.aifrps_fact_replacement_transaction_pre_work 
where dim_financial_transaction_natural_key_hash_uuid not in
(select distinct dim_financial_transaction_natural_key_hash_uuid
from edw_financial_transactions.fact_replacement_transaction
where source_system_id in ('72','266'));



-- Step 4 insert only updated records to target
-- use dim_financial_transaction_natural_key_hash_uuid + calender_dt as key
insert into edw_work.aifrps_fact_replacement_transaction
(
fact_replacement_transaction_natural_key_hash_uuid,
dim_financial_transaction_natural_key_hash_uuid,
calender_dt,
replacement_type_cde,
source_replacement_type_cde,
exchange_type_cde,
source_exchange_type_cde,
replaced_agreement_nr,
replaced_company_nm,
estimated_transfer_amt,
rt_lock_dt,
rt_lock_cde,
source_rt_lock_cde,
fund_received_cde,
source_fund_received_cde,
distribution_transaction_id,
row_process_dtm,
check_sum,
restricted_row_ind,
logical_delete_ind,
source_system_id,
audit_id,
update_audit_id,
source_delete_ind
)

select 
pw.fact_replacement_transaction_natural_key_hash_uuid,
pw.dim_financial_transaction_natural_key_hash_uuid,
pw.calender_dt,
pw.replacement_type_cde,
pw.source_replacement_type_cde,
pw.exchange_type_cde,
pw.source_exchange_type_cde,
pw.replaced_agreement_nr,
pw.replaced_company_nm,
pw.estimated_transfer_amt,
pw.rt_lock_dt,
pw.rt_lock_cde,
pw.source_rt_lock_cde,
pw.fund_received_cde,
pw.source_fund_received_cde,
pw.distribution_transaction_id,
pw.row_process_dtm,
pw.check_sum,
pw.restricted_row_ind,
pw.logical_delete_ind,
pw.source_system_id,
pw.audit_id,
pw.update_audit_id,
pw.source_delete_ind
from edw_staging.aifrps_fact_replacement_transaction_pre_work pw
join (
select dim_financial_transaction_natural_key_hash_uuid,check_sum,
row_number() OVER (PARTITION BY dim_financial_transaction_natural_key_hash_uuid ORDER BY calender_dt DESC) AS rownum
from edw_financial_transactions.fact_replacement_transaction where source_system_id in ('72','266')
) tgt
on tgt.dim_financial_transaction_natural_key_hash_uuid = pw.dim_financial_transaction_natural_key_hash_uuid
where tgt.rownum = 1
and tgt.check_sum <> pw.check_sum
;

select analyze_statistics('edw_work.aifrps_fact_replacement_transaction') ;
