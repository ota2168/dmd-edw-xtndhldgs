/*
		FILENAME: AIFRPS_REL_FINANCIAL_TRANSACTION_REPLACEMENT.SQL
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
truncate table edw_staging.aifrps_rel_financial_transaction_replacement_pre_work;

truncate table edw_work.aifrps_rel_financial_transaction_replacement;

--load data into pre-work table.
insert into edw_staging.aifrps_rel_financial_transaction_replacement_pre_work
(
dim_financial_transaction_natural_key_hash_uuid,
dim_party_natural_key_hash_uuid,
dim_agreement_natural_key_hash_uuid,
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
dim_fund_natural_key_hash_uuid
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

uuid_gen(null)::uuid as dim_party_natural_key_hash_uuid,

uuid_gen(
clean_string(agreement_source_cde),
clean_string(agreement_type_cde),
clean_string(agreement_nr_pfx),
clean_string(agreement_nr),
clean_string(agreement_nr_sfx))::uuid as dim_agreement_natural_key_hash_uuid,


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

uuid_gen(null)::uuid as dim_fund_natural_key_hash_uuid
from (

select
agrmt_sdt.trnslt_fld_val as agreement_source_cde,
'Ipa' as agreement_type_cde,
public.udf_aif_hldg_key_format(agrmtdelta.aifcow_policy_id,'PFX') as agreement_nr_pfx, 
public.udf_aif_hldg_key_format(agrmtdelta.aifcow_policy_id,'KEY') as agreement_nr, 
public.udf_aif_hldg_key_format(agrmtdelta.aifcow_policy_id,'SFX') as agreement_nr_sfx,
fts_sdt.trnslt_fld_val as financial_transaction_source,
ftt_sdt.trnslt_fld_val as financial_transaction_type,

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

null as replacement_transaction_nr_txt

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

select analyze_statistics('edw_staging.aifrps_rel_financial_transaction_replacement_pre_work');


/* WORK TABLE - INSERTS 
 * 
 * this script is used to load the records that don't have a record in target
 * */


insert into edw_work.aifrps_rel_financial_transaction_replacement
(
dim_financial_transaction_natural_key_hash_uuid,
dim_party_natural_key_hash_uuid,
dim_agreement_natural_key_hash_uuid,
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
dim_fund_natural_key_hash_uuid
)
select
dim_financial_transaction_natural_key_hash_uuid,
dim_party_natural_key_hash_uuid,
dim_agreement_natural_key_hash_uuid,
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
dim_fund_natural_key_hash_uuid
from edw_staging.aifrps_rel_financial_transaction_replacement_pre_work
--insert when either no records in target table
where (dim_financial_transaction_natural_key_hash_uuid,dim_agreement_natural_key_hash_uuid) not in 
(select distinct dim_financial_transaction_natural_key_hash_uuid,dim_agreement_natural_key_hash_uuid from edw_financial_transactions.rel_financial_transaction
where source_system_id in ('72','266'));



/* WORK TABLE - UPDATE TGT RECORD
 * 
 * This script finds records where the new record from the source has a different check_sum than the current target record or the record is being ended/deleted. 
 * The current record in the target will be ended since the source record will be inserted in the next step.
 * */


insert into edw_work.aifrps_rel_financial_transaction_replacement
(
dim_financial_transaction_natural_key_hash_uuid,
dim_party_natural_key_hash_uuid,
dim_agreement_natural_key_hash_uuid,
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
dim_fund_natural_key_hash_uuid
)
select
rft.dim_financial_transaction_natural_key_hash_uuid,
rft.dim_party_natural_key_hash_uuid,
rft.dim_agreement_natural_key_hash_uuid,
rft.begin_dt,
rft.begin_dtm,
current_timestamp(6) as row_process_dtm,
rft.audit_id,
rft.logical_delete_ind,
rft.check_sum,
false as current_row_ind,
rft.begin_dt - interval '1' day  as end_dt,
rft.begin_dt - interval '1' second  as end_dtm,
rft.source_system_id,
rft.restricted_row_ind,
pw.update_audit_id,
rft.source_delete_ind,
rft.dim_fund_natural_key_hash_uuid
from edw_financial_transactions.rel_financial_transaction rft
inner join edw_staging.aifrps_rel_financial_transaction_replacement_pre_work pw
on rft.dim_financial_transaction_natural_key_hash_uuid = pw.dim_financial_transaction_natural_key_hash_uuid
and rft.dim_agreement_natural_key_hash_uuid = pw.dim_agreement_natural_key_hash_uuid
and rft.current_row_ind = TRUE
and rft.source_system_id in ('72','266')
--change in check_sum
where rft.check_sum <> pw.check_sum ;


/* WORK TABLE - UPDATE WHERE RECORD ALREADY EXISTS IN TARGET 
 * 
 * 
 * */
insert into edw_work.aifrps_rel_financial_transaction_replacement
(
dim_financial_transaction_natural_key_hash_uuid,
dim_party_natural_key_hash_uuid,
dim_agreement_natural_key_hash_uuid,
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
dim_fund_natural_key_hash_uuid
)
select
pw.dim_financial_transaction_natural_key_hash_uuid,
pw.dim_party_natural_key_hash_uuid,
pw.dim_agreement_natural_key_hash_uuid,
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
pw.dim_fund_natural_key_hash_uuid
from edw_staging.aifrps_rel_financial_transaction_replacement_pre_work pw
left join edw_financial_transactions.rel_financial_transaction rft
on rft.dim_financial_transaction_natural_key_hash_uuid = pw.dim_financial_transaction_natural_key_hash_uuid
and rft.dim_agreement_natural_key_hash_uuid = pw.dim_agreement_natural_key_hash_uuid
and rft.current_row_ind = true
where 
--handle when there isn't a current record in target but there are historical records and a delta coming through
(rft.row_sid is null and (pw.dim_financial_transaction_natural_key_hash_uuid,pw.dim_agreement_natural_key_hash_uuid)  in 
(select distinct dim_financial_transaction_natural_key_hash_uuid,dim_agreement_natural_key_hash_uuid from edw_financial_transactions.rel_financial_transaction
where source_system_id in ('72','266')))

--handle when there is a current target record and either the check_sum has changed or record is being logically deleted.
or 
(rft.row_sid is not null 
--checksum changed
and (rft.check_sum <> pw.check_sum)
);

select analyze_statistics('edw_work.aifrps_rel_financial_transaction_replacement');

