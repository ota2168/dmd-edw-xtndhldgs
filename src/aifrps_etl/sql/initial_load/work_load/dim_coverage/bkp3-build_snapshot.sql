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
(cvg_seq_nbr, hldg_key_pfx, hldg_key_sfx, prod_id, prod_typ_cd_1, prod_typ_cd_2, prod_typ_cd_3, cvg_ctgry_cd, cvg_sht_nm, cvg_lng_nm, cvg_xcpt_stus_cd, src_cvg_eff_dt, cvg_cease_dt, rtrn_prem_pol_nbr, iss_age, mnr_prod_cd, cvg_xovr_opt_dt, cvg_1035_ind, rdr_typ_cd, schd_unschd_cd, actv_ind, pnd_coll_ind, run_id, src_sys_id, updt_run_id, trans_dt, occ_cls_cd, agmt_cvg_id, agmt_data_fr_dt, agmt_id, agmt_cvg_fr_dt, agmt_cvg_to_dt, hldg_key, curr_ind, src_del_ind, carr_admin_sys_cd, src_cvg_ctgry_cd, src_cvg_eff_txt, src_cvg_xcpt_stus_cd, src_occ_cls_cd, incr_cntr, cvg_cease_dt_txt, occ_cls_mod, cvg_period, src_cvg_period, cvg_prsn_cd, bene_typ_amt, avail_wdrwl_amt, palir_roll_sts_cd,current_batch)
select 
cvg_seq_nbr, hldg_key_pfx, hldg_key_sfx, prod_id, prod_typ_cd_1, prod_typ_cd_2, prod_typ_cd_3, cvg_ctgry_cd, cvg_sht_nm, cvg_lng_nm, cvg_xcpt_stus_cd, src_cvg_eff_dt, cvg_cease_dt, rtrn_prem_pol_nbr, iss_age, mnr_prod_cd, cvg_xovr_opt_dt, cvg_1035_ind, rdr_typ_cd, schd_unschd_cd, actv_ind, pnd_coll_ind, run_id, src_sys_id, updt_run_id, trans_dt, occ_cls_cd, agmt_cvg_id, agmt_data_fr_dt, agmt_id, agmt_cvg_fr_dt, agmt_cvg_to_dt, hldg_key, curr_ind, src_del_ind, carr_admin_sys_cd, src_cvg_ctgry_cd, src_cvg_eff_txt, src_cvg_xcpt_stus_cd, src_occ_cls_cd, incr_cntr, cvg_cease_dt_txt, occ_cls_mod, cvg_period, src_cvg_period, cvg_prsn_cd, bene_typ_amt, avail_wdrwl_amt, palir_roll_sts_cd, true from prod_stnd_vw_tersun.agmt_cvg_vw_aif_rps where run_id = :RUN_ID and src_sys_id = 72;




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

