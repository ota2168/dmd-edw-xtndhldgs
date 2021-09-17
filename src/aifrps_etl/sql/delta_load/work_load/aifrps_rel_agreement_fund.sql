/*
		FILENAME: AIFRPS_REL_AGREEMENT_FUND.SQL
		AUTHOR: Chandra Pragallapati
		SUBJECT AREA : AGREEMENT
		SOURCE: AIF-RPS
		SOURCE SYSTEM CODE: 72
		DESCRIPTION: REL_AGREEMENT_FUND TABLE DELTA POPULATION
		JIRA: 
		CREATE DATE:07/13/2021

		===============================================================================================================
		VERSION/JIRA STORY#			CREATED BY          LAST_MODIFIED_DATE		DESCRIPTION
		---------------------------------------------------------------------------------------------------------------
									cp35479              07/13/2021			FIRST VERSION OF CODE FOR TIER-2
									                    
		---------------------------------------------------------------------------------------------------------------
*/


truncate table edw_staging.aifrps_rel_agreement_fund_pre_work;

truncate table edw_work.aifrps_rel_agreement_fund;


create local temporary table aifrpsrafpt on
commit preserve rows as 
select prod_id,ctrt_kind_plan_8, ctrt_basis, ctrt_rate_edition
from (
select distinct ctrt.aifcow_plan_code as ctrt_kind_plan_8,
				'00' as ctrt_basis,
				'0000' as ctrt_rate_edition
    from edw_staging.aif_rps_funddata_edw_funddata_delta fnddata --10,202
					inner join edw_staging.aif_rps_edw_ctrt_full_dedup ctrt
					on trim(fnddata.aifcfv_policy_id)=trim(aifcow_policy_id)
	) contract
--product_id
left join edw_ref.product_translator product_dt
on clean_string(trim(contract.ctrt_kind_plan_8)) >= clean_string(trim(product_dt.knd_min_cde))
and clean_string(trim(contract.ctrt_kind_plan_8)) <= clean_string(trim(product_dt.knd_max_cde))
and clean_string(lpad(ltrim(coalesce(btrim(contract.ctrt_basis), ''), '0'), 2, '0')) >= clean_string(trim(product_dt.bsis_min_cde))
and clean_string(lpad(ltrim(coalesce(btrim(contract.ctrt_basis), ''), '0'), 2, '0')) <= clean_string(trim(product_dt.bsis_max_cde))
and clean_string(lpad(ltrim(coalesce(btrim(contract.ctrt_rate_edition), ''), '0'), 4, '0')) >= clean_string(trim(product_dt.rate_min_cde))
and clean_string(lpad(ltrim(coalesce(btrim(contract.ctrt_rate_edition), ''), '0'), 4, '0')) <= clean_string(trim(product_dt.rate_max_cde))
and product_dt.admn_sys_grp_cde = '02' ;

insert into edw_staging.aifrps_rel_agreement_fund_pre_work
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
dim_agreement_natural_key_hash_uuid,
dim_fund_natural_key_hash_uuid,
agreement_source_cde,
admin_fund_cde,
product_id,
company_cde,
pt1_kind_cde,
product_tier_cde,
agreement_fund_cnt as agreement_fund_cnt,
fund_dmdp_cde,
fund_dmdp_termination_dt,
fund_account_type_cde,
source_fund_account_type_cde,
begin_dt,
begin_dtm,
current_timestamp(6) as row_process_dtm,
uuid_gen(source_delete_ind,
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
fnddata.aifcfv_policy_id,
uuid_gen(
clean_string(agrmt_sdt.trnslt_fld_val),
clean_string('Ipa'),
clean_string(public.udf_aif_hldg_key_format(fnddata.aifcfv_policy_id,'PFX')),
clean_string(public.udf_aif_hldg_key_format(fnddata.aifcfv_policy_id,'KEY')),
clean_string(public.udf_aif_hldg_key_format(fnddata.aifcfv_policy_id,'SFX')))::uuid as dim_agreement_natural_key_hash_uuid,
uuid_gen(
clean_string(agrmt_sdt.trnslt_fld_val),
clean_string(fnddata.admin_fund_cde),
clean_string(aifrpsrafpt.prod_id),
clean_string(company_sdt.trnslt_fld_val),
clean_string(ctrt.aifcow_plan_code),
clean_string(to_char(cast(df.product_tier_cde as integer))) )::uuid as dim_fund_natural_key_hash_uuid,
clean_string(agrmt_sdt.trnslt_fld_val) as agreement_source_cde,
clean_string(fnddata.admin_fund_cde) as admin_fund_cde,
case when aifrpsrafpt.prod_id is null
	then 'Unk'
	else clean_string(aifrpsrafpt.prod_id) end as product_id,
case when company_sdt.trnslt_fld_val is null
	then 'Unk'
	else clean_string(company_sdt.trnslt_fld_val) end as company_cde,
clean_string(ctrt.aifcow_plan_code) as pt1_kind_cde,
df.product_tier_cde as product_tier_cde,
 COUNT(AIFCFV_POLICY_ID) over (partition by aifcfv_policy_id) as agreement_fund_cnt, -- need to work on more
null as fund_dmdp_cde,
null as fund_dmdp_termination_dt,
null as fund_account_type_cde,
null as source_fund_account_type_cde,
to_date(to_char(fndcyc.cycle_date),'yyyymmdd') as begin_dt,
to_date(to_char(fndcyc.cycle_date),'yyyymmdd')::timestamp as begin_dtm,
'9999-12-31'::date as end_dt,
'9999-12-31'::timestamp as end_dtm,
false as restricted_row_ind,
true as current_row_ind,
false as logical_delete_ind,
72 as source_system_id,
:audit_id as audit_id,
:audit_id as update_audit_id,
false as source_delete_ind
from (
	 select aifcfv_source_system_id,
			aifcfv_policy_id,
			case when upper(trim(aifcfv_source_fund_no))='FIXED'
		 		then '997' else aifcfv_fund_no end as admin_fund_cde,
			aifcfv_source_fund_no,
			aifcfv_company_code,
			audit_id
			from edw_staging.aif_rps_funddata_edw_funddata_delta  --449,163
			where  (case when upper(trim(aifcfv_source_fund_no))='FIXED'
				then '997' else aifcfv_fund_no end) is not null ) fnddata --10,202
inner join edw_staging.aif_rps_edw_ctrt_full_dedup ctrt
on trim(fnddata.aifcfv_policy_id)=trim(aifcow_policy_id)
inner join edw_staging.aif_rps_funddata_edw_funddata_delta_count fndcyc
on fnddata.audit_id=fndcyc.audit_id

--agreement_source_cde
left join (select distinct trnslt_fld_val, src_cde, src_fld_nm, src_fld_val, trnslt_fld_nm from edw_ref.src_data_trnslt
where upper(btrim(src_cde)) ='ANN'
and upper(btrim(src_fld_nm)) ='ADMN_SYS_CDE'
and upper(btrim(trnslt_fld_nm)) = 'ADMIN OR SOURCE SYSTEM CODE') agrmt_sdt
on upper(btrim(agrmt_sdt.src_fld_val)) = upper(udf_replaceemptystr(fnddata.aifcfv_source_system_id, 'SPACE'))

--company_cde
left join (select distinct trnslt_fld_val, src_cde, src_fld_nm, src_fld_val, trnslt_fld_nm from edw_ref.src_data_trnslt
where upper(btrim(src_cde)) ='RPS'
and upper(btrim(src_fld_nm)) ='COMPANY-CD'
and upper(btrim(trnslt_fld_nm)) = 'COMPANY NUMERICAL CODE') company_sdt
on upper(btrim(company_sdt.src_fld_val)) = upper(udf_replaceemptystr(fnddata.aifcfv_company_code, 'SPACE'))

--product_id
left join aifrpsrafpt on
UPPER(aifrpsrafpt.ctrt_kind_plan_8) =UPPER(ctrt.aifcow_plan_code)

-- to get the admin_fund_cde & product_tier_cde
left join edw.dim_fund df
on df.source_system_cde = clean_string(agrmt_sdt.trnslt_fld_val)
and company_cde= clean_string(company_sdt.trnslt_fld_val)
and df.pt1_kind_cde=clean_string(ctrt.aifcow_plan_code)
and df.dim_product_natural_key_hash_uuid= UUID_GEN(clean_string(aifrpsrafpt.prod_id))::UUID
and df.admin_fund_cde=fnddata.admin_fund_cde
and df.current_row_ind=TRUE

) rel_fund;

select analyze_statistics('edw_staging.aifrps_rel_agreement_fund_pre_work') ;


/* WORK TABLE - INSERTS 
 * 
 * this script is used to load the records that don't have a record in target
 * */


insert into edw_work.aifrps_rel_agreement_fund
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
from edw_staging.aifrps_rel_agreement_fund_pre_work
--insert when either no records in target table
where (dim_agreement_natural_key_hash_uuid,dim_fund_natural_key_hash_uuid) not in 
(select distinct dim_agreement_natural_key_hash_uuid,dim_fund_natural_key_hash_uuid from {{target_schema}}.rel_agreement_fund);


/* WORK TABLE - UPDATE TGT RECORD
 * 
 * This script finds records where the new record from the source has a different check_sum than the current target record or the record is being ended/deleted. 
 * The current record in the target will be ended since the source record will be inserted in the next step.
 * */


insert into edw_work.aifrps_rel_agreement_fund
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
raf.dim_agreement_natural_key_hash_uuid,
raf.dim_fund_natural_key_hash_uuid,
raf.agreement_source_cde,
raf.admin_fund_cde,
raf.product_id,
raf.company_cde,
raf.pt1_kind_cde,
raf.product_tier_cde,
raf.agreement_fund_cnt,
raf.fund_dmdp_cde,
raf.fund_dmdp_termination_dt,
raf.fund_account_type_cde,
raf.source_fund_account_type_cde,
raf.begin_dt,
raf.begin_dtm,
current_timestamp(6) as row_process_dtm,
raf.check_sum,
pw.begin_dt - interval '1' day  as end_dt,
pw.begin_dt - interval '1' second  as end_dtm,
raf.restricted_row_ind,
false as current_row_ind,
raf.logical_delete_ind,
raf.source_system_id,
raf.audit_id,
pw.update_audit_id,
raf.source_delete_ind
from {{target_schema}}.rel_agreement_fund raf
inner join edw_staging.aifrps_rel_agreement_fund_pre_work pw
on raf.dim_agreement_natural_key_hash_uuid = pw.dim_agreement_natural_key_hash_uuid
and raf.dim_fund_natural_key_hash_uuid = pw.dim_fund_natural_key_hash_uuid
and raf.current_row_ind = true
--change in check_sum
where raf.check_sum <> pw.check_sum ;


/* WORK TABLE - UPDATE WHERE RECORD ALREADY EXISTS IN TARGET 
 * 
 * 
 * */
insert into edw_work.aifrps_rel_agreement_fund
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
pw.dim_agreement_natural_key_hash_uuid,
pw.dim_fund_natural_key_hash_uuid,
pw.agreement_source_cde,
pw.admin_fund_cde,
pw.product_id,
pw.company_cde,
pw.pt1_kind_cde,
pw.product_tier_cde,
pw.agreement_fund_cnt,
pw.fund_dmdp_cde,
pw.fund_dmdp_termination_dt,
pw.fund_account_type_cde,
pw.source_fund_account_type_cde,
pw.begin_dt,
pw.begin_dtm,
current_timestamp(6) as row_process_dtm,
pw.check_sum,
pw.end_dt,
pw.end_dtm,
pw.restricted_row_ind,
pw.current_row_ind,
pw.logical_delete_ind,
pw.source_system_id,
pw.audit_id,
pw.update_audit_id,
pw.source_delete_ind
from edw_staging.aifrps_rel_agreement_fund_pre_work pw
left join {{target_schema}}.rel_agreement_fund raf
on raf.dim_agreement_natural_key_hash_uuid = pw.dim_agreement_natural_key_hash_uuid
and raf.dim_fund_natural_key_hash_uuid = pw.dim_fund_natural_key_hash_uuid
and raf.current_row_ind = true
where 
	--handle when there isn't a current record in target but there are historical records and a delta coming through
	(raf.row_sid is null and (pw.dim_agreement_natural_key_hash_uuid,pw.dim_fund_natural_key_hash_uuid)  in 
(select distinct dim_agreement_natural_key_hash_uuid,dim_fund_natural_key_hash_uuid from {{target_schema}}.rel_agreement_fund))

	--handle when there is a current target record and either the check_sum has changed or record is being logically deleted.
	OR 
		(raf.row_sid is not null 
			--checksum changed
			AND (raf.check_sum <> pw.check_sum)
		);
	

select analyze_statistics('edw_work.aifrps_rel_agreement_fund') ;

/*

  ************ Calculating the Deleted Records *******************

*/


/* WORK TABLE - insert the updated tgt records from rel_agreement_fund table
 *
 * this script finds records where the record is missing in prework table but present in rel_agreement_fund.
 * the current record in the target will be ended since the source record will be created and inserted in the next step.
 * only checking the target table data other than 'SPIA' kind code.
 */

insert into edw_work.aifrps_rel_agreement_fund
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
raf.dim_agreement_natural_key_hash_uuid,
raf.dim_fund_natural_key_hash_uuid,
raf.agreement_source_cde,
raf.admin_fund_cde,
raf.product_id,
raf.company_cde,
raf.pt1_kind_cde,
raf.product_tier_cde,
raf.agreement_fund_cnt,
raf.fund_dmdp_cde,
raf.fund_dmdp_termination_dt,
raf.fund_account_type_cde,
raf.source_fund_account_type_cde,
raf.begin_dt,
raf.begin_dtm,
current_timestamp(6) as row_process_dtm,
raf.check_sum,
(fndcyc.begin_dt - interval '1' day)::date  as end_dt,
(fndcyc.begin_dt - interval '1' second)::timestamp  as end_dtm,
raf.restricted_row_ind,
false as current_row_ind,
raf.logical_delete_ind,
raf.source_system_id,
raf.audit_id,
fndcyc.audit_id  as update_audit_id,
raf.source_delete_ind
from {{target_schema}}.rel_agreement_fund raf -- Not considering 'SPIA' kind code data is not comming from source.
inner join
(select to_date(to_char(cycle_date),'yyyymmdd') as begin_dt,audit_id
from edw_staging.aif_rps_funddata_edw_funddata_delta_count) fndcyc
on 1=1
left join edw_staging.aifrps_rel_agreement_fund_pre_work pw
on raf.dim_agreement_natural_key_hash_uuid = pw.dim_agreement_natural_key_hash_uuid
and raf.dim_fund_natural_key_hash_uuid = pw.dim_fund_natural_key_hash_uuid
--records not present in prework.
where raf.current_row_ind = true
and raf.source_delete_ind =false
and raf.source_system_id in ('72','266')
and upper(raf.pt1_kind_cde)<>'SPIA'
and ((pw.dim_agreement_natural_key_hash_uuid is null) or (pw.dim_fund_natural_key_hash_uuid is null)) ;

/* WORK TABLE - create and insert the deleted src records using rel_agreement_fund and prework table
 *
 * this script finds records where the record is missing in prework table but present in rel_agreement_fund..
 * the current record missing in the source will be inserted in the work table as source_delete_ind=true.
 *
 */

insert into edw_work.aifrps_rel_agreement_fund
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
raf.dim_agreement_natural_key_hash_uuid,
raf.dim_fund_natural_key_hash_uuid,
raf.agreement_source_cde,
raf.admin_fund_cde,
raf.product_id,
raf.company_cde,
raf.pt1_kind_cde,
raf.product_tier_cde,
raf.agreement_fund_cnt,
raf.fund_dmdp_cde,
raf.fund_dmdp_termination_dt,
raf.fund_account_type_cde,
raf.source_fund_account_type_cde,
fndcyc.begin_dt::date as begin_dt,
fndcyc.begin_dt::timestamp as begin_dtm,
current_timestamp(6) as row_process_dtm,
uuid_gen(true,raf.agreement_fund_cnt)::uuid as check_sum,
'9999-12-31'::date as end_dt,
'9999-12-31'::timestamp as end_dtm,
false as restricted_row_ind,
true as current_row_ind,
false as logical_delete_ind,
72 as source_system_id,
:audit_id as audit_id,
:audit_id as update_audit_id,
true as source_delete_ind
from {{target_schema}}.rel_agreement_fund raf -- Not considering 'SPIA' kind code data is not comming from source.
inner join
(select to_date(to_char(cycle_date),'yyyymmdd') as begin_dt,audit_id
from edw_staging.aif_rps_funddata_edw_funddata_delta_count) fndcyc
on 1=1
left join edw_staging.aifrps_rel_agreement_fund_pre_work pw
on raf.dim_agreement_natural_key_hash_uuid = pw.dim_agreement_natural_key_hash_uuid
and raf.dim_fund_natural_key_hash_uuid = pw.dim_fund_natural_key_hash_uuid
--records not present in prework.
where raf.current_row_ind = true
and raf.source_delete_ind =false
and raf.source_system_id in ('72','266')
and upper(raf.pt1_kind_cde)<>'SPIA'
and ((pw.dim_agreement_natural_key_hash_uuid is null) or (pw.dim_fund_natural_key_hash_uuid is null)) ;

select analyze_statistics('edw_work.aifrps_rel_agreement_fund') ;