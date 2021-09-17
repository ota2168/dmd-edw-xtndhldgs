/*
 Log:
    @05/01/2021 :  In Step1&2,Updated current_row_ind,begin_dt,begin_dtm, end_dt and end_dtm as per the updated mapping
 */


--TRUNCATE TABLE edw_staging.aifrps_dim_underwriting_initial_load_pre_work;

DELETE FROM edw_staging.aifrps_dim_underwriting_initial_load_pre_work where 1=1;

--TRUNCATE TABLE edw_work.aifrps_dim_underwriting_initial_load;
DELETE FROM edw_work.aifrps_dim_underwriting_initial_load where 1=1;


/*INSERT SCRIPT FOR PRE WORK TABLE -ALL RECORDS FROM STG*/

-- Step 1:
INSERT INTO edw_staging.aifrps_dim_underwriting_initial_load_pre_work

( dim_underwriting_natural_key_hash_uuid
, dim_agreement_natural_key_hash_uuid
, agreement_nr_pfx
, agreement_nr
, agreement_nr_sfx
, agreement_source_cde
, agreement_type_cde
, participant_role_cde
, source_participant_role_cde
, underwriting_sequence_nr
, source_participant_role_stype_cde
, issue_age_nr
, exclusion_rider_ind
, source_exclusion_rider_ind
, exclusion_rider_form_nr
, exclusion_cde
, source_exclusion_cde
, tobacco_class_cde
, source_tobacco_class_cde
, risk_class_cde
, source_risk_class_cde
, risk_class_pct
, unisex_ind
, exclusion_rider_2_form_nr
, underwriting_key_id
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
, process_ind)
SELECT uuid_gen(
                       clean_string(src.agreement_source_cde),
                       clean_string(agreement_type_cde),
                       clean_string(src.agreement_nr_pfx),
                       clean_string(src.agreement_nr),
                       clean_string(src.agreement_nr_sfx),
					   clean_string(src.participant_role_cde),
					   src.underwriting_sequence_nr) ::UUID				   AS dim_underwriting_natural_key_hash_uuid,

       uuid_gen(
               clean_string(src.agreement_source_cde),
               clean_string(agreement_type_cde),
               clean_string(src.agreement_nr_pfx),
               clean_string(src.agreement_nr),
               clean_string(src.agreement_nr_sfx))::UUID                   AS dim_agreement_natural_key_hash_uuid,

       src.agreement_nr_pfx												   AS agreement_nr_pfx,
       src.agreement_nr													   AS agreement_nr,
       src.agreement_nr_sfx												   AS agreement_nr_sfx,
       clean_string(src.agreement_source_cde)							   AS agreement_source_cde,
       agreement_type_cde												   AS agreement_type_cde,
       src.participant_role_cde											   AS participant_role_cde,
       src.source_participant_role_cde                                     AS source_participant_role_cde,
       src.underwriting_sequence_nr                                        AS underwriting_sequence_nr,
       src.source_participant_role_stype_cde                               AS source_participant_role_stype_cde,
       issue_age_nr                                                        AS issue_age_nr,
       exclusion_rider_ind                                                 AS exclusion_rider_ind,
       source_exclusion_rider_ind                                          AS source_exclusion_rider_ind,
       exclusion_rider_form_nr                                             AS exclusion_rider_form_nr,
       exclusion_cde                                                       AS exclusion_cde,
       source_exclusion_cde                                                AS source_exclusion_cde,
       tobacco_class_cde                                                   AS tobacco_class_cde,
       source_tobacco_class_cde                                            AS source_tobacco_class_cde,
       risk_class_cde                                                      AS risk_class_cde,
       source_risk_class_cde                                               AS source_risk_class_cde,
       risk_class_pct                                                      AS risk_class_pct,
       unisex_ind                                                          AS unisex_ind,
       exclusion_rider_2_form_nr                                           AS exclusion_rider_2_form_nr,
       underwriting_key_id                                                 AS underwriting_key_id,
       src.begin_dt                                                        AS begin_dt,
       src.begin_dtm                                                       AS begin_dtm,
       CURRENT_TIMESTAMP(6)                                                AS row_process_dtm,
       uuid_gen
           (
               source_delete_ind,
               clean_string(src.participant_role_cde),
               underwriting_sequence_nr,
               issue_age_nr,
               exclusion_rider_ind,
               clean_string(source_exclusion_rider_ind),
               exclusion_rider_form_nr,
               clean_string(exclusion_cde),
               clean_string(source_exclusion_cde),
               clean_string(tobacco_class_cde),
               clean_string(source_tobacco_class_cde),
               clean_string(risk_class_cde),
               clean_string(source_risk_class_cde),
               risk_class_pct,
               unisex_ind,
               exclusion_rider_2_form_nr,
               clean_string(underwriting_key_id)
           ) :: UUID                                                       AS check_sum,
       src.end_dt                                                          AS end_dt,
       src.end_dtm                                                         AS end_dtm,
       FALSE                                                               AS restricted_row_ind,
--        TRUE                                                                AS current_row_ind,
       src.current_row_ind                                                 AS current_row_ind,
       FALSE                                                               AS logical_delete_ind,
       '266'                                                               AS source_system_id,
       src.audit_id,
       src.update_audit_id,
       src.source_delete_ind,
       process_ind
FROM (
         SELECT undw.hldg_key_pfx                       AS agreement_nr_pfx,
                undw.hldg_key                           AS agreement_nr,
                undw.hldg_key_sfx                       AS agreement_nr_sfx,
                carr_admin_sys_cd                       AS agreement_source_cde,
                'Ipa'                                   AS agreement_type_cde,
                ptcp_rle_cd                             AS participant_role_cde,
                src_ptcp_rle_cd                         AS source_participant_role_cde,
                undw_seq_nbr::INTEGER                   AS underwriting_sequence_nr,
                src_ptcp_rle_styp_cd                    AS source_participant_role_stype_cde,
                iss_age::INTEGER                        AS issue_age_nr,
                clean_string(excl_rdr_ind)::BOOLEAN     AS exclusion_rider_ind,
                src_excl_rdr_ind 						AS source_exclusion_rider_ind,
                excl_rdr_frm_nbr::INTEGER               AS exclusion_rider_form_nr,
                excl_cd                                 AS exclusion_cde,
                src_excl_cd                             AS source_exclusion_cde,
                tbac_cls_cd                             AS tobacco_class_cde,
                src_tbac_cls_cd                         AS source_tobacco_class_cde,
                risk_cls_cd                             AS risk_class_cde,
                src_risk_cls_cd                         AS source_risk_class_cde,
                risk_cls_pct                            AS risk_class_pct,
                clean_string(unisex_ind)::BOOLEAN       AS unisex_ind,
                excl_rdr_2_frm_nbr::INTEGER             AS exclusion_rider_2_form_nr,
                prehash_value(
                        clean_string(ptcp_rle_cd),
                        undw_seq_nbr)                   AS underwriting_key_id,
				--prehash_value('ANNT','ANNT')			AS underwriting_key_id,
                src_del_ind::BOOLEAN                    AS source_delete_ind,
                src_del_ind                             AS process_ind,
                undw.agmt_undw_fr_dt::DATE              AS begin_dt,
                undw.agmt_undw_fr_dt::DATE              AS begin_dtm,
                run_id                                  AS audit_id,
                updt_run_id                             AS update_audit_id,
                undw.agmt_undw_to_dt::DATE              AS end_dt,
                undw.agmt_undw_to_dt::DATETIME          AS end_dtm,
                undw.curr_ind::BOOLEAN                  AS current_row_ind

         FROM edw_staging.aifrps_agmt_undw_vw_snapshot undw
         WHERE undw.current_batch = TRUE
     ) src;
--------------------------------------------------------------------------
-- Step 2:
INSERT INTO edw_work.aifrps_dim_underwriting_initial_load
( dim_underwriting_natural_key_hash_uuid
, dim_agreement_natural_key_hash_uuid
, agreement_nr_pfx
, agreement_nr
, agreement_nr_sfx
, agreement_source_cde
, agreement_type_cde
, participant_role_cde
, source_participant_role_cde
, underwriting_sequence_nr
, source_participant_role_stype_cde
, issue_age_nr
, exclusion_rider_ind
, source_exclusion_rider_ind
, exclusion_rider_form_nr
, exclusion_cde
, source_exclusion_cde
, tobacco_class_cde
, source_tobacco_class_cde
, risk_class_cde
, source_risk_class_cde
, risk_class_pct
, unisex_ind
, exclusion_rider_2_form_nr
, underwriting_key_id
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
, source_delete_ind)
SELECT dim_underwriting_natural_key_hash_uuid
     , dim_agreement_natural_key_hash_uuid
     , agreement_nr_pfx
     , agreement_nr
     , agreement_nr_sfx
     , agreement_source_cde
     , agreement_type_cde
     , participant_role_cde
     , source_participant_role_cde
     , underwriting_sequence_nr
     , source_participant_role_stype_cde
     , issue_age_nr
     , exclusion_rider_ind
     , source_exclusion_rider_ind
     , exclusion_rider_form_nr
     , exclusion_cde
     , source_exclusion_cde
     , tobacco_class_cde
     , source_tobacco_class_cde
     , risk_class_cde
     , source_risk_class_cde
     , risk_class_pct
     , unisex_ind
     , exclusion_rider_2_form_nr
     , underwriting_key_id
     , begin_dt
     , begin_dtm
     , CURRENT_TIMESTAMP(6) AS row_process_dtm
     , check_sum
     , end_dt::DATE         AS end_dt
     , end_dtm::TIMESTAMP   AS end_dtm
     , restricted_row_ind
     , current_row_ind
     , logical_delete_ind
     , source_system_id
     , audit_id
     , update_audit_id
     , source_delete_ind
FROM edw_staging.aifrps_dim_underwriting_initial_load_pre_work src;

