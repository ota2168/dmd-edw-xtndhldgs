
insert into edw_financial_transactions.rel_financial_transaction
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
clean_string(replacement_transaction_nr_txt1),
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
begin_dtm,
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
'Ipa' as agreement_type_cde,
ar.carr_admin_sys_cd as agreement_source_cde,
public.udf_isnum_lpad(ar.hldg_key_pfx, 20, '0', true) as agreement_nr_pfx,
lpad(ar.hldg_key::varchar, 20, '0') as agreement_nr,
public.udf_isnum_lpad(ar.hldg_key_sfx, 20, '0', true) as agreement_nr_sfx,
ar.repl_txn_nr as replacement_transaction_nr_txt,
null as replacement_transaction_nr_txt1,
'Rps' as financial_transaction_source,
'Replacement Transaction' as financial_transaction_type,
ar.agmt_repl_fr_dt::date as begin_dt,
ar.agmt_repl_fr_dt::timestamp as begin_dtm,
current_timestamp(6) as row_process_dtm,
'9999-12-31'::date as end_dt,
'9999-12-31'::timestamp as end_dtm,
false as restricted_row_ind,
false as logical_delete_ind,
266 as source_system_id,
ar.run_id as audit_id,
ar.updt_run_id as update_audit_id,
true as current_row_ind,
--needs to verified for other admins
case when ar.src_del_ind = 'N' then false
else true end  as source_delete_ind
from (
select	b.*,
row_number () over(partition by agmt_id order by agmt_repl_fr_dt asc) as rownumber
from prod_stnd_vw_tersun.agmt_repl_vw_aif_rps b 
where b.src_sys_id =72 and b.agmt_id not in (53727909,54957911,55069911,56479917,61820911,68514915,69778912)
) ar where ar.rownumber =1 
)rel_financial_transaction;


insert into edw_financial_transactions.rel_financial_transaction
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
clean_string(replacement_transaction_nr_txt1),
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
begin_dtm,
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
'Ipa' as agreement_type_cde,
ar.carr_admin_sys_cd as agreement_source_cde,
public.udf_isnum_lpad(ar.hldg_key_pfx, 20, '0', true) as agreement_nr_pfx,
lpad(ar.hldg_key::varchar, 20, '0') as agreement_nr,
public.udf_isnum_lpad(ar.hldg_key_sfx, 20, '0', true) as agreement_nr_sfx,
ar.repl_txn_nr as replacement_transaction_nr_txt,
null as replacement_transaction_nr_txt1,
'Rps' as financial_transaction_source,
'Replacement Transaction' as financial_transaction_type,
ar.agmt_repl_fr_dt::date as begin_dt,
ar.agmt_repl_fr_dt::timestamp as begin_dtm,
current_timestamp(6) as row_process_dtm,
ar.agmt_repl_to_dt::date as end_dt,
ar.agmt_repl_to_dt::timestamp as end_dtm,
false as restricted_row_ind,
false as logical_delete_ind,
266 as source_system_id,
ar.run_id as audit_id,
ar.updt_run_id as update_audit_id,
case when ar.curr_ind ='N' then false
else true end  as current_row_ind,
--needs to verified for other admins
case when ar.src_del_ind = 'N' then false
else true end  as source_delete_ind
from (
select	* from prod_stnd_vw_tersun.agmt_repl_vw_aif_rps b
where b.src_sys_id =72 and b.agmt_id in (53727909,54957911,55069911,56479917,61820911,68514915,69778912)
) ar 
)rel_financial_transaction;
