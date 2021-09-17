insert into edw_tdsunset.rel_agreement_fund
(
dim_agreement_natural_key_hash_uuid,
dim_fund_natural_key_hash_uuid,
agreement_source_cde,
admin_fund_cde,
product_id,
company_cde,
pt1_kind_cde,
product_tier_cde,
agreement_fund_cnt,
fund_dmdp_cde,
fund_dmdp_termination_dt,
fund_account_type_cde,
source_fund_account_type_cde,
begin_dt,
begin_dtm,
row_process_dtm,
check_sum,
end_dt,
end_dtm,
restricted_row_ind,
current_row_ind,
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
clean_string(agreement_nr_sfx))::uuid as dim_agreement_natural_key_hash_uuid,
uuid_gen(
clean_string(agreement_source_cde),
clean_string(admin_fund_cde),
clean_string(product_id),
clean_string(company_cde),
clean_string(pt1_kind_cde),
clean_string(to_char(cast(cast(prod_tier_cd as numeric(6,4))as integer))))::uuid as dim_fund_natural_key_hash_uuid,
agreement_source_cde,
admin_fund_cde,
product_id,
company_cde,
pt1_kind_cde,
product_tier_cde,
agreement_fund_cnt,
fund_dmdp_cde,
fund_dmdp_termination_dt,
fund_account_type_cde,
source_fund_account_type_cde,
begin_dt,
begin_dtm,
row_process_dtm,
uuid_gen(
source_delete_ind,
agreement_fund_cnt)::uuid as check_sum,
end_dt,
end_dtm,
restricted_row_ind,
current_row_ind,
logical_delete_ind,
source_system_id,
audit_id,
update_audit_id,
source_delete_ind
from (
select
f.prod_tier_cd,
'Ipa' as agreement_type_cde,
clean_string(af.carr_admin_sys_cd) as agreement_source_cde,
public.udf_isnum_lpad(af.hldg_key_pfx, 20, '0', true) as agreement_nr_pfx,
lpad(af.hldg_key::varchar, 20, '0') as agreement_nr,
public.udf_isnum_lpad(af.hldg_key_sfx, 20, '0', true) as agreement_nr_sfx,
af.admin_fnd_nr as admin_fund_cde,
f.prod_id as product_id,
f.company_cd as company_cde,
f.kind_plan_cd as pt1_kind_cde,
af.prod_tier_cd as product_tier_cde,
af.fnd_data_ctr as agreement_fund_cnt,
af.fnd_dmdp_ind as fund_dmdp_cde,
af.fnd_dmdp_trmn_dt as fund_dmdp_termination_dt,
af.fnd_acct_typ as fund_account_type_cde,
af.src_fnd_acct_typ_cd as source_fund_account_type_cde,
date(af.trans_dt) as begin_dt,  -- need to derive from agmt_fund_to_dt
af.trans_dt::timestamp as begin_dtm, -- need to derive from agmt_fund_to_dt
current_timestamp(6) as row_process_dtm,
--null as check_sum,
date(af.agmt_fund_to_dt) as end_dt,
af.agmt_fund_to_dt::timestamp as end_dtm,
false as restricted_row_ind,
case
	when af.curr_ind = 'N' then false
	else true
end as current_row_ind,
false as logical_delete_ind,
266 as source_system_id,
af.run_id as audit_id,
af.updt_run_id as update_audit_id,
case
	when af.src_del_ind = 'N' then false
	else true
end as source_delete_ind
from
(select
agmt_id,
fnd_id,
carr_admin_sys_cd,
hldg_key_pfx,
hldg_key,
hldg_key_sfx,
admin_fnd_nr ,
prod_tier_cd,
fnd_data_ctr ,
fnd_dmdp_ind ,
fnd_dmdp_trmn_dt ,
fnd_acct_typ ,
src_fnd_acct_typ_cd ,
src_sys_id,
run_id,
updt_run_id ,
trans_dt,
agmt_fund_to_dt,
curr_ind,
src_del_ind
FROM prod_stnd_vw_tersun.agmt_fund_vw_aif_rps
where src_sys_id=72
and admin_fnd_nr=997
and hldg_key_pfx='SPA'
UNION
select	 agmt_id,
fnd_id,
carr_admin_sys_cd,
hldg_key_pfx,
hldg_key,
hldg_key_sfx,
admin_fnd_nr ,
prod_tier_cd,
fnd_data_ctr ,
fnd_dmdp_ind ,
fnd_dmdp_trmn_dt ,
fnd_acct_typ ,
src_fnd_acct_typ_cd ,
src_sys_id,
run_id,
updt_run_id ,
		min(trans_dt) as trans_dt,
		max(agmt_fund_to_dt) as agmt_fund_to_dt,
		max(curr_ind) as curr_ind,
		max(src_del_ind) as src_del_ind
from prod_stnd_vw_tersun.agmt_fund_vw_aif_rps
where src_sys_id=72
and hldg_key_pfx <> 'SPA'
GROUP BY agmt_id,
fnd_id,
carr_admin_sys_cd,
hldg_key_pfx,
hldg_key,
hldg_key_sfx,
admin_fnd_nr ,
prod_tier_cd,
fnd_data_ctr ,
fnd_dmdp_ind ,
fnd_dmdp_trmn_dt ,
fnd_acct_typ ,
src_fnd_acct_typ_cd ,
src_sys_id,
run_id,
updt_run_id) af
inner join prod_stnd_vw_tersun.fund_vw f on
af.fnd_id = f.fnd_id
and f.src_sys_id = 66
and f.curr_ind = 'Y'
) rel_agrmt_fnd ;

