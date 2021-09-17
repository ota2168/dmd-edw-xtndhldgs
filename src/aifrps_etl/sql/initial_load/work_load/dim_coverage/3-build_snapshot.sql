--de-duplicating the data --


--truncate the temp tables

truncate table edw_staging.agmt_cvg_vw_tmp1;

truncate table edw_staging.agmt_cvg_vw_tmp2;


-- creating temp tables for agmt_cvg

insert into edw_staging.agmt_cvg_vw_tmp1
(
select cov.cvg_seq_nbr,cov.hldg_key_pfx,cov.hldg_key_sfx,cov.prod_id,cov.prod_typ_cd_1,cov.prod_typ_cd_2,cov.prod_typ_cd_3,cov.cvg_ctgry_cd,cov.cvg_sht_nm,cov.cvg_lng_nm,
cov.cvg_xcpt_stus_cd,cov.src_cvg_eff_dt,cov.cvg_cease_dt,cov.rtrn_prem_pol_nbr,cov.iss_age,mnr_prod_cd,cov.cvg_xovr_opt_dt,cov.cvg_1035_ind,cov.rdr_typ_cd,cov.schd_unschd_cd,
cov.actv_ind,cov.pnd_coll_ind,cov.run_id,cov.src_sys_id,cov.updt_run_id,cov.trans_dt,cov.occ_cls_cd,cov.agmt_cvg_id,cov.agmt_data_fr_dt,cov.agmt_id,cov.agmt_cvg_fr_dt,
cov.agmt_cvg_to_dt,cov.hldg_key,cov.curr_ind,cov.src_del_ind,cov.carr_admin_sys_cd,cov.src_cvg_ctgry_cd,cov.src_cvg_eff_txt,cov.src_cvg_xcpt_stus_cd,
cov.src_occ_cls_cd,cov.incr_cntr,cov.cvg_cease_dt_txt,cov.occ_cls_mod,cov.cvg_period,cov.src_cvg_period,cov.cvg_prsn_cd,cov.bene_typ_amt,
cov.avail_wdrwl_amt,cov.palir_roll_sts_cd from
prod_stnd_vw_tersun.agmt_cvg_vw_aif_rps cov
join

	(
		select agmt_cvg_id, run_id, trans_dt, count(*)
		from prod_stnd_vw_tersun.agmt_cvg_vw_aif_rps
		where src_sys_id = 72
		group by agmt_cvg_id, run_id, trans_dt
		having count(*)>1
	)dup

on 	cov.agmt_cvg_id=dup.agmt_cvg_id
and cov.run_id=dup.run_id
and cov.trans_dt=dup.trans_dt
and cov.run_id = :RUN_ID 
and src_sys_id = 72
);


insert into edw_staging.agmt_cvg_vw_tmp2
(
select cov.cvg_seq_nbr,cov.hldg_key_pfx,cov.hldg_key_sfx,cov.prod_id,cov.prod_typ_cd_1,cov.prod_typ_cd_2,cov.prod_typ_cd_3,cov.cvg_ctgry_cd,cov.cvg_sht_nm,cov.cvg_lng_nm,
cov.cvg_xcpt_stus_cd,cov.src_cvg_eff_dt,cov.cvg_cease_dt,cov.rtrn_prem_pol_nbr,cov.iss_age,mnr_prod_cd,cov.cvg_xovr_opt_dt,cov.cvg_1035_ind,cov.rdr_typ_cd,cov.schd_unschd_cd,
cov.actv_ind,cov.pnd_coll_ind,cov.run_id,cov.src_sys_id,cov.updt_run_id,cov.trans_dt,cov.occ_cls_cd,cov.agmt_cvg_id,cov.agmt_data_fr_dt,cov.agmt_id,cov.agmt_cvg_fr_dt,
cov.agmt_cvg_to_dt,cov.hldg_key,cov.curr_ind,cov.src_del_ind,cov.carr_admin_sys_cd,cov.src_cvg_ctgry_cd,cov.src_cvg_eff_txt,cov.src_cvg_xcpt_stus_cd,
cov.src_occ_cls_cd,cov.incr_cntr,cov.cvg_cease_dt_txt,cov.occ_cls_mod,cov.cvg_period,cov.src_cvg_period,cov.cvg_prsn_cd,cov.bene_typ_amt,
cov.avail_wdrwl_amt,cov.palir_roll_sts_cd from
prod_stnd_vw_tersun.agmt_cvg_vw_aif_rps cov
left join

	(
		select agmt_cvg_id, run_id, trans_dt, count(*)
		from prod_stnd_vw_tersun.agmt_cvg_vw_aif_rps
		where src_sys_id = 72
		group by agmt_cvg_id, run_id, trans_dt
		having count(*)>1
	)dup

on 	cov.agmt_cvg_id=dup.agmt_cvg_id
and cov.run_id=dup.run_id
and cov.trans_dt=dup.trans_dt
--and cov.run_id = :RUN_ID 
--and src_sys_id = 72
where dup.agmt_cvg_id is null
and cov.run_id = :RUN_ID 
and src_sys_id = 72
);


------------------------------------------------------------------------------------



--snapshot for agmt_cvg

-- delete the changed record in snapshot, make sure snapshot is all new
delete from edw_staging.aifrps_agmt_cvg_vw_snapshot
where agmt_cvg_id in 
(select agmt_cvg_id from prod_stnd_vw_tersun.agmt_cvg_vw_aif_rps where run_id = :RUN_ID and src_sys_id = 72);

-- set all current_batch to false
update edw_staging.aifrps_agmt_cvg_vw_snapshot
set current_batch = false
where current_batch = true;

-- insert into new data's

insert into edw_staging.aifrps_agmt_cvg_vw_snapshot
(cvg_seq_nbr,hldg_key_pfx,hldg_key_sfx,prod_id,prod_typ_cd_1,prod_typ_cd_2,prod_typ_cd_3,cvg_ctgry_cd,cvg_sht_nm,cvg_lng_nm,cvg_xcpt_stus_cd,src_cvg_eff_dt,cvg_cease_dt,rtrn_prem_pol_nbr,iss_age,mnr_prod_cd,cvg_xovr_opt_dt,cvg_1035_ind,rdr_typ_cd,schd_unschd_cd,actv_ind,pnd_coll_ind,run_id,src_sys_id,updt_run_id,trans_dt,occ_cls_cd,agmt_cvg_id,agmt_data_fr_dt,agmt_id,agmt_cvg_fr_dt,agmt_cvg_to_dt,hldg_key,curr_ind,src_del_ind,carr_admin_sys_cd,src_cvg_ctgry_cd,src_cvg_eff_txt,src_cvg_xcpt_stus_cd,src_occ_cls_cd,incr_cntr,cvg_cease_dt_txt,occ_cls_mod,cvg_period,src_cvg_period,cvg_prsn_cd,bene_typ_amt,avail_wdrwl_amt,palir_roll_sts_cd
)
(
select
cvg_seq_nbr,hldg_key_pfx,hldg_key_sfx,prod_id,prod_typ_cd_1,prod_typ_cd_2,prod_typ_cd_3,cvg_ctgry_cd,cvg_sht_nm,cvg_lng_nm,cvg_xcpt_stus_cd,src_cvg_eff_dt,cvg_cease_dt,rtrn_prem_pol_nbr,iss_age,mnr_prod_cd,cvg_xovr_opt_dt,cvg_1035_ind,rdr_typ_cd,schd_unschd_cd,actv_ind,pnd_coll_ind,run_id,src_sys_id,updt_run_id,trans_dt,occ_cls_cd,agmt_cvg_id,agmt_data_fr_dt,agmt_id,agmt_cvg_fr_dt,agmt_cvg_to_dt,hldg_key,curr_ind,src_del_ind,carr_admin_sys_cd,src_cvg_ctgry_cd,src_cvg_eff_txt,src_cvg_xcpt_stus_cd,src_occ_cls_cd,incr_cntr,cvg_cease_dt_txt,occ_cls_mod,cvg_period,src_cvg_period,cvg_prsn_cd,bene_typ_amt,avail_wdrwl_amt,palir_roll_sts_cd

from
(
select t1.*, row_number() over (partition by t1.agmt_cvg_id, t1.run_id, t1.trans_dt order by t1.agmt_cvg_to_dt desc) as rec_num
from
edw_staging.agmt_cvg_vw_tmp1 t1
)calc
where rec_num=1
);

insert into edw_staging.aifrps_agmt_cvg_vw_snapshot
(cvg_seq_nbr,hldg_key_pfx,hldg_key_sfx,prod_id,prod_typ_cd_1,prod_typ_cd_2,prod_typ_cd_3,cvg_ctgry_cd,cvg_sht_nm,cvg_lng_nm,cvg_xcpt_stus_cd,src_cvg_eff_dt,cvg_cease_dt,rtrn_prem_pol_nbr,iss_age,mnr_prod_cd,cvg_xovr_opt_dt,cvg_1035_ind,rdr_typ_cd,schd_unschd_cd,actv_ind,pnd_coll_ind,run_id,src_sys_id,updt_run_id,trans_dt,occ_cls_cd,agmt_cvg_id,agmt_data_fr_dt,agmt_id,agmt_cvg_fr_dt,agmt_cvg_to_dt,hldg_key,curr_ind,src_del_ind,carr_admin_sys_cd,src_cvg_ctgry_cd,src_cvg_eff_txt,src_cvg_xcpt_stus_cd,src_occ_cls_cd,incr_cntr,cvg_cease_dt_txt,occ_cls_mod,cvg_period,src_cvg_period,cvg_prsn_cd,bene_typ_amt,avail_wdrwl_amt,palir_roll_sts_cd,current_batch
)
(
select
cvg_seq_nbr,hldg_key_pfx,hldg_key_sfx,prod_id,prod_typ_cd_1,prod_typ_cd_2,prod_typ_cd_3,cvg_ctgry_cd,cvg_sht_nm,cvg_lng_nm,cvg_xcpt_stus_cd,src_cvg_eff_dt,cvg_cease_dt,rtrn_prem_pol_nbr,iss_age,mnr_prod_cd,cvg_xovr_opt_dt,cvg_1035_ind,rdr_typ_cd,schd_unschd_cd,actv_ind,pnd_coll_ind,run_id,src_sys_id,updt_run_id,trans_dt,occ_cls_cd,agmt_cvg_id,agmt_data_fr_dt,agmt_id,agmt_cvg_fr_dt,agmt_cvg_to_dt,hldg_key,curr_ind,src_del_ind,carr_admin_sys_cd,src_cvg_ctgry_cd,src_cvg_eff_txt,src_cvg_xcpt_stus_cd,src_occ_cls_cd,incr_cntr,cvg_cease_dt_txt,occ_cls_mod,cvg_period,src_cvg_period,cvg_prsn_cd,bene_typ_amt,avail_wdrwl_amt,palir_roll_sts_cd,true
from
edw_staging.agmt_cvg_vw_tmp2
);



------------------------------------------------------

--snapshot for agmt_cvg

-- delete the changed record in snapshot, make sure snapshot is all new
--delete from edw_staging.aifrps_agmt_cvg_vw_snapshot
--where agmt_cvg_id in 
--(select agmt_cvg_id from prod_stnd_vw_tersun.agmt_cvg_vw_aif_rps where run_id = :RUN_ID and src_sys_id = 72);

-- set all current_batch to false
--update edw_staging.aifrps_agmt_cvg_vw_snapshot
--set current_batch = false
--where current_batch = true;

-- insert into new data's
--insert into edw_staging.aifrps_agmt_cvg_vw_snapshot
--(cvg_seq_nbr, hldg_key_pfx, hldg_key_sfx, prod_id, prod_typ_cd_1, prod_typ_cd_2, prod_typ_cd_3, cvg_ctgry_cd, cvg_sht_nm, cvg_lng_nm, cvg_xcpt_stus_cd, src_cvg_eff_dt, cvg_cease_dt, rtrn_prem_pol_nbr, iss_age, mnr_prod_cd, cvg_xovr_opt_dt, cvg_1035_ind, rdr_typ_cd, schd_unschd_cd, actv_ind, pnd_coll_ind, run_id, src_sys_id, updt_run_id, trans_dt, occ_cls_cd, agmt_cvg_id, agmt_data_fr_dt, agmt_id, agmt_cvg_fr_dt, agmt_cvg_to_dt, hldg_key, curr_ind, src_del_ind, carr_admin_sys_cd, src_cvg_ctgry_cd, src_cvg_eff_txt, src_cvg_xcpt_stus_cd, src_occ_cls_cd, incr_cntr, cvg_cease_dt_txt, occ_cls_mod, cvg_period, src_cvg_period, cvg_prsn_cd, bene_typ_amt, avail_wdrwl_amt, palir_roll_sts_cd,current_batch)
--select 
--cvg_seq_nbr, hldg_key_pfx, hldg_key_sfx, prod_id, prod_typ_cd_1, prod_typ_cd_2, prod_typ_cd_3, cvg_ctgry_cd, cvg_sht_nm, cvg_lng_nm, cvg_xcpt_stus_cd, src_cvg_eff_dt, cvg_cease_dt, rtrn_prem_pol_nbr, iss_age, mnr_prod_cd, cvg_xovr_opt_dt, cvg_1035_ind, rdr_typ_cd, schd_unschd_cd, actv_ind, pnd_coll_ind, run_id, src_sys_id, updt_run_id, trans_dt, occ_cls_cd, agmt_cvg_id, agmt_data_fr_dt, agmt_id, agmt_cvg_fr_dt, agmt_cvg_to_dt, hldg_key, curr_ind, src_del_ind, carr_admin_sys_cd, src_cvg_ctgry_cd, src_cvg_eff_txt, src_cvg_xcpt_stus_cd, src_occ_cls_cd, incr_cntr, cvg_cease_dt_txt, occ_cls_mod, cvg_period, src_cvg_period, cvg_prsn_cd, bene_typ_amt, avail_wdrwl_amt, palir_roll_sts_cd, true from prod_stnd_vw_tersun.agmt_cvg_vw_aif_rps where run_id = :RUN_ID and src_sys_id = 72;




--snapshot for agmt_cvg_ben

-- delete the changed record in snapshot, make sure snapshot is all new
delete from edw_staging.aifrps_agmt_cvg_ben_vw_snapshot
where agmt_cvg_id in 
(select agmt_cvg_id from prod_stnd_vw_tersun.agmt_cvg_ben_vw_aif_rps where run_id = :RUN_ID and src_sys_id = 72);

-- set all current_batch to false
update edw_staging.aifrps_agmt_cvg_ben_vw_snapshot
set current_batch = false
where current_batch = true;

-- insert into new data's
insert into edw_staging.aifrps_agmt_cvg_ben_vw_snapshot
(agmt_id, agmt_cvg_id, agmt_cvg_fr_dt, agmt_cvg_ben_fr_dt, agmt_cvg_ben_to_dt, cvg_face_amt, cvg_incm_amt, cvg_incr_pct, cvg_divd_opt_cd, cvg_src_divd_opt_cd, cvg_scnd_divd_opt_cd, cvg_src_scnd_divd_opt_cd, conv_exp_dt, conv_elig_strt_dt, nxt_fio_dt, fio_exp_dt, emp_dscnt_typ_cd, emp_dscnt_amt, curr_ind, src_del_ind, src_sys_id, run_id, updt_run_id, trans_dt, emp_dscnt_pct, cvg_dclr_dvd_amt, covered_insd_cd, cvg_csh_val_amt, cvg_csh_val_qlty_cd, current_batch)
select
agmt_id, agmt_cvg_id, agmt_cvg_fr_dt, agmt_cvg_ben_fr_dt, agmt_cvg_ben_to_dt, cvg_face_amt, cvg_incm_amt, cvg_incr_pct, cvg_divd_opt_cd, cvg_src_divd_opt_cd, cvg_scnd_divd_opt_cd, cvg_src_scnd_divd_opt_cd, conv_exp_dt, conv_elig_strt_dt, nxt_fio_dt, fio_exp_dt, emp_dscnt_typ_cd, emp_dscnt_amt, curr_ind, src_del_ind, src_sys_id, run_id, updt_run_id, trans_dt, emp_dscnt_pct, cvg_dclr_dvd_amt, covered_insd_cd, cvg_csh_val_amt, cvg_csh_val_qlty_cd, true
from prod_stnd_vw_tersun.agmt_cvg_ben_vw_aif_rps where run_id = :RUN_ID and src_sys_id = 72;

