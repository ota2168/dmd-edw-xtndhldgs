/*
		FILENAME: AIFRPS_DIM_UNDERWRITING.SQL
		AUTHOR: Sai K
		SUBJECT AREA : AGREEMENT
		SOURCE: AIF-RPS
		TERADATA SOURCE CODE: 72
		DESCRIPTION: DIM_UNDERWRITING TABLE POPULATION
		JIRA: 
		CREATE DATE:2021-07-10
		===============================================================================================================
		VERSION/JIRA STORY#			CREATED BY          LAST_MODIFIED_DATE		DESCRIPTION
		---------------------------------------------------------------------------------------------------------------
		J						    AGREEMENT TIER-2    2021-06-24			FIRST VERSION OF DDL FOR TIER-2
		---------------------------------------------------------------------------------------------------------------
*/


/* TRUNCATE STAGING PRE WORK TABLE */
TRUNCATE TABLE edw_staging.aifrps_dim_underwriting_pre_work;

/*TRUNCATE WORK TABLE */
TRUNCATE TABLE edw_work.aifrps_dim_underwriting;

/*create temp table to join coverage,contract and product translator*/

CREATE LOCAL TEMPORARY TABLE CNRT_ID_FIL ON
COMMIT PRESERVE ROWS AS
SELECT distinct contract_ident FROM
			(SELECT DISTINCT aifclw_contract_ident as contract_ident FROM edw_staging.aif_rps_edw_client_delta
		
			UNION
		
			SELECT DISTINCT aifrpa_contract_ident as contract_ident FROM edw_staging.aif_rps_edw_payee_delta WHERE process_ind <> 'D'
			)tmp
		    /* this join is added to make sure that orphans are not selected from client file */
INNER JOIN edw_staging.aif_rps_edw_ctrt_full_dedup ctrt
       ON tmp.contract_ident=ctrt.aifcow_policy_id;

-- Step 1 :
-- INSERT SCRIPT FOR PRE WORK TABLE -ALL RECORDS FROM STG

INSERT INTO edw_staging.aifrps_dim_underwriting_pre_work

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
               src.underwriting_sequence_nr) ::UUID AS dim_underwriting_natural_key_hash_uuid,

       uuid_gen(
               clean_string(src.agreement_source_cde),
               clean_string(agreement_type_cde),
               clean_string(src.agreement_nr_pfx),
               clean_string(src.agreement_nr),
               clean_string(src.agreement_nr_sfx))::UUID     AS dim_agreement_natural_key_hash_uuid,

       clean_string(src.agreement_nr_pfx)                    AS agreement_nr_pfx,
       clean_string(src.agreement_nr)                        AS agreement_nr,
       clean_string(src.agreement_nr_sfx)                    AS agreement_nr_sfx,
       clean_string(src.agreement_source_cde)                AS agreement_source_cde,
       clean_string(agreement_type_cde)                      AS agreement_type_cde,
       clean_string(src.participant_role_cde)                AS participant_role_cde,
       src.source_participant_role_cde                       AS source_participant_role_cde,
       src.underwriting_sequence_nr                          AS underwriting_sequence_nr,
       src.source_participant_role_stype_cde                 AS source_participant_role_stype_cde,
       issue_age_nr                                          AS issue_age_nr,
       exclusion_rider_ind                                   AS exclusion_rider_ind,
       source_exclusion_rider_ind                            AS source_exclusion_rider_ind,
       exclusion_rider_form_nr                               AS exclusion_rider_form_nr,
       exclusion_cde                                         AS exclusion_cde,
       source_exclusion_cde                                  AS source_exclusion_cde,
       tobacco_class_cde                                     AS tobacco_class_cde,
       source_tobacco_class_cde                              AS source_tobacco_class_cde,
       clean_string(risk_class_cde)                          AS risk_class_cde,
       source_risk_class_cde                                 AS source_risk_class_cde,
       risk_class_pct                                        AS risk_class_pct,
       unisex_ind                                            AS unisex_ind,
       exclusion_rider_2_form_nr                             AS exclusion_rider_2_form_nr,
       underwriting_key_id                                   AS underwriting_key_id,
---------------------
       src.begin_dt,
       src.begin_dtm,
       CURRENT_TIMESTAMP(6)                                  AS row_process_dtm,
       uuid_gen
           (
               source_delete_ind,
               clean_string(src.participant_role_cde),
               underwriting_sequence_nr,
               issue_age_nr,
               exclusion_rider_ind,
               source_exclusion_rider_ind,
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
           ) :: UUID                                         AS check_sum,
       '9999-12-31'::DATE                                    AS end_dt,
       '9999-12-31'::TIMESTAMP                               AS end_dtm,
       FALSE                                                 AS restricted_row_ind,
       TRUE                                                  AS current_row_ind,
       FALSE                                                 AS logical_delete_ind,
       '72'                                                  AS source_system_id,
       src.audit_id,
       src.update_audit_id,
       source_delete_ind,
       process_ind
FROM (

SELECT          udf_aif_hldg_key_format(undw.aifclw_contract_ident,'PFX')	 AS agreement_nr_pfx,
				udf_aif_hldg_key_format(undw.aifclw_contract_ident,'KEY')    AS agreement_nr,
                udf_aif_hldg_key_format(undw.aifclw_contract_ident,'SFX')	 AS agreement_nr_sfx,
                agreement_sdt.trnslt_fld_val                                 AS agreement_source_cde,
                'Ipa'                                                        AS agreement_type_cde,
                'Annt'			                                             AS participant_role_cde,
                undw.aifclw_annuitant_role_ind                               AS source_participant_role_cde,
                1			                                                 AS underwriting_sequence_nr,
                'Annt'                                                       AS source_participant_role_stype_cde,
                aifclw_issue_age::INTEGER                                    AS issue_age_nr,
                NULL										                 AS exclusion_rider_ind,
                NULL				                                         AS source_exclusion_rider_ind,
                NULL							                             AS exclusion_rider_form_nr,
                NULL						                                 AS exclusion_cde,
                NULL				                                         AS source_exclusion_cde,
                NULL				                                         AS tobacco_class_cde,
                NULL					                                     AS source_tobacco_class_cde,
                NULL                                                         AS risk_class_cde,
                NULL                                                         AS source_risk_class_cde,
                NULL                                                         AS risk_class_pct,
                NULL								                         AS unisex_ind,
                NULL							                             AS exclusion_rider_2_form_nr,
                prehash_value('Annt',1)				                         AS underwriting_key_id,
                CASE
                    WHEN process_ind = 'D' THEN TRUE
                    ELSE FALSE
                    END                                                      AS source_delete_ind,
                process_ind                                                  AS process_ind,
                to_date(to_char(undwcnt.cycle_date), 'yyyymmdd')             AS begin_dt,
                to_date(to_char(undwcnt.cycle_date), 'yyyymmdd'):: TIMESTAMP AS begin_dtm,
                :audit_id                                                    AS audit_id,
                :audit_id                                                    AS update_audit_id
         FROM edw_staging.aif_rps_edw_client_full undw
                  INNER JOIN edw_staging.aif_rps_edw_client_full_count undwcnt --Only current batch audit will be used to join
                             ON undwcnt.audit_id = undw.audit_id
                                 AND undwcnt.source_system_id = 72
                  LEFT JOIN (SELECT DISTINCT trnslt_fld_val, src_cde, src_fld_nm, src_fld_val, src_tbl_nm, trnslt_fld_nm
                             FROM edw_ref.src_data_trnslt) agreement_sdt
                            ON UPPER(BTRIM(agreement_sdt.src_cde)) = 'ANN'
                                AND UPPER(BTRIM(agreement_sdt.src_fld_nm)) = 'ADMN_SYS_CDE'
                                AND UPPER(BTRIM(agreement_sdt.trnslt_fld_nm)) = 'ADMIN OR SOURCE SYSTEM CODE'
                                AND UPPER(BTRIM(agreement_sdt.src_fld_val)) =
                                    UPPER(BTRIM(udf_replaceemptystr(undw.aifclw_source_system_id, 'SPACE')))
         WHERE aifclw_contract_ident IN (SELECT contract_ident FROM CNRT_ID_FIL)
		       and aifclw_annuitant_role_ind = 'Y'
		--and undw.current_batch = TRUE

UNION

SELECT          udf_aif_hldg_key_format(undw.aifclw_contract_ident,'PFX')	 AS agreement_nr_pfx,
				udf_aif_hldg_key_format(undw.aifclw_contract_ident,'KEY')    AS agreement_nr,
                udf_aif_hldg_key_format(undw.aifclw_contract_ident,'SFX')	 AS agreement_nr_sfx,
                agreement_sdt.trnslt_fld_val                                 AS agreement_source_cde,
                'Ipa'                                                        AS agreement_type_cde,
                'Annt'			                                             AS participant_role_cde,
                undw.aifclw_contingent_ann_role_ind                          AS source_participant_role_cde,
                2			                                                 AS underwriting_sequence_nr,
                'Ctannt'                                                     AS source_participant_role_stype_cde,
                aifclw_issue_age::INTEGER                                    AS issue_age_nr,
                NULL										                 AS exclusion_rider_ind,
                NULL				                                         AS source_exclusion_rider_ind,
                NULL							                             AS exclusion_rider_form_nr,
                NULL						                                 AS exclusion_cde,
                NULL				                                         AS source_exclusion_cde,
                NULL				                                         AS tobacco_class_cde,
                NULL					                                     AS source_tobacco_class_cde,
                NULL                                                         AS risk_class_cde,
                NULL                                                         AS source_risk_class_cde,
                NULL                                                         AS risk_class_pct,
                NULL								                         AS unisex_ind,
                NULL							                             AS exclusion_rider_2_form_nr,
                prehash_value('Annt',2)				                         AS underwriting_key_id,
                CASE
                    WHEN process_ind = 'D' THEN TRUE
                    ELSE FALSE
                    END                                                      AS source_delete_ind,
                process_ind                                                  AS process_ind,
                to_date(to_char(undwcnt.cycle_date), 'yyyymmdd')             AS begin_dt,
                to_date(to_char(undwcnt.cycle_date), 'yyyymmdd'):: TIMESTAMP AS begin_dtm,
                :audit_id                                                    AS audit_id,
                :audit_id                                                    AS update_audit_id
         FROM edw_staging.aif_rps_edw_client_full undw
                  INNER JOIN edw_staging.aif_rps_edw_client_full_count undwcnt --Only current batch audit will be used to join
                             ON undwcnt.audit_id = undw.audit_id
                                 AND undwcnt.source_system_id = 72
                  LEFT JOIN (SELECT DISTINCT trnslt_fld_val, src_cde, src_fld_nm, src_fld_val, src_tbl_nm, trnslt_fld_nm
                             FROM edw_ref.src_data_trnslt) agreement_sdt
                            ON UPPER(BTRIM(agreement_sdt.src_cde)) = 'ANN'
                                AND UPPER(BTRIM(agreement_sdt.src_fld_nm)) = 'ADMN_SYS_CDE'
                                AND UPPER(BTRIM(agreement_sdt.trnslt_fld_nm)) = 'ADMIN OR SOURCE SYSTEM CODE'
                                AND UPPER(BTRIM(agreement_sdt.src_fld_val)) =
                                    UPPER(BTRIM(udf_replaceemptystr(undw.aifclw_source_system_id, 'SPACE')))
         WHERE aifclw_contract_ident IN (SELECT contract_ident FROM CNRT_ID_FIL) 
			   and aifclw_contingent_ann_role_ind = 'Y'
		--and undw.current_batch = TRUE

UNION

SELECT          udf_aif_hldg_key_format(undw.aifclw_contract_ident,'PFX')	 AS agreement_nr_pfx,
				udf_aif_hldg_key_format(undw.aifclw_contract_ident,'KEY')    AS agreement_nr,
                udf_aif_hldg_key_format(undw.aifclw_contract_ident,'SFX')	 AS agreement_nr_sfx,
                agreement_sdt.trnslt_fld_val                                 AS agreement_source_cde,
                'Ipa'                                                        AS agreement_type_cde,
                'Annt'			                                             AS participant_role_cde,
                undw.aifclw_co_annuitant_role_ind                            AS source_participant_role_cde,
                3			                                                 AS underwriting_sequence_nr,
                'Coannt'                                                     AS source_participant_role_stype_cde,
                aifclw_issue_age::INTEGER                                    AS issue_age_nr,
                NULL										                 AS exclusion_rider_ind,
                NULL				                                         AS source_exclusion_rider_ind,
                NULL							                             AS exclusion_rider_form_nr,
                NULL						                                 AS exclusion_cde,
                NULL				                                         AS source_exclusion_cde,
                NULL				                                         AS tobacco_class_cde,
                NULL					                                     AS source_tobacco_class_cde,
                NULL                                                         AS risk_class_cde,
                NULL                                                         AS source_risk_class_cde,
                NULL                                                         AS risk_class_pct,
                NULL								                         AS unisex_ind,
                NULL							                             AS exclusion_rider_2_form_nr,
                prehash_value('Annt',3)				                         AS underwriting_key_id,
                CASE
                    WHEN process_ind = 'D' THEN TRUE
                    ELSE FALSE
                    END                                                      AS source_delete_ind,
                process_ind                                                  AS process_ind,
                to_date(to_char(undwcnt.cycle_date), 'yyyymmdd')             AS begin_dt,
                to_date(to_char(undwcnt.cycle_date), 'yyyymmdd'):: TIMESTAMP AS begin_dtm,
                :audit_id                                                    AS audit_id,
                :audit_id                                                    AS update_audit_id
         FROM edw_staging.aif_rps_edw_client_full undw
                  INNER JOIN edw_staging.aif_rps_edw_client_full_count undwcnt --Only current batch audit will be used to join
                             ON undwcnt.audit_id = undw.audit_id
                                 AND undwcnt.source_system_id = 72
                  LEFT JOIN (SELECT DISTINCT trnslt_fld_val, src_cde, src_fld_nm, src_fld_val, src_tbl_nm, trnslt_fld_nm
                             FROM edw_ref.src_data_trnslt) agreement_sdt
                            ON UPPER(BTRIM(agreement_sdt.src_cde)) = 'ANN'
                                AND UPPER(BTRIM(agreement_sdt.src_fld_nm)) = 'ADMN_SYS_CDE'
                                AND UPPER(BTRIM(agreement_sdt.trnslt_fld_nm)) = 'ADMIN OR SOURCE SYSTEM CODE'
                                AND UPPER(BTRIM(agreement_sdt.src_fld_val)) =
                                    UPPER(BTRIM(udf_replaceemptystr(undw.aifclw_source_system_id, 'SPACE')))
         WHERE aifclw_contract_ident IN (SELECT contract_ident FROM CNRT_ID_FIL)
			  and aifclw_co_annuitant_role_ind = 'Y'
		--and undw.current_batch = TRUE

UNION

SELECT          udf_aif_hldg_key_format(undw.aifclw_contract_ident,'PFX')	 AS agreement_nr_pfx,
				udf_aif_hldg_key_format(undw.aifclw_contract_ident,'KEY')    AS agreement_nr,
                udf_aif_hldg_key_format(undw.aifclw_contract_ident,'SFX')	 AS agreement_nr_sfx,
                agreement_sdt.trnslt_fld_val                                 AS agreement_source_cde,
                'Ipa'                                                        AS agreement_type_cde,
                'Annt'			                                             AS participant_role_cde,
                undw.aifclw_jt_annuitant_role_ind                            AS source_participant_role_cde,
                4			                                                 AS underwriting_sequence_nr,
                'Jtannt'                                                     AS source_participant_role_stype_cde,
                aifclw_issue_age::INTEGER                                    AS issue_age_nr,
                NULL										                 AS exclusion_rider_ind,
                NULL				                                         AS source_exclusion_rider_ind,
                NULL							                             AS exclusion_rider_form_nr,
                NULL						                                 AS exclusion_cde,
                NULL				                                         AS source_exclusion_cde,
                NULL				                                         AS tobacco_class_cde,
                NULL					                                     AS source_tobacco_class_cde,
                NULL                                                         AS risk_class_cde,
                NULL                                                         AS source_risk_class_cde,
                NULL                                                         AS risk_class_pct,
                NULL								                         AS unisex_ind,
                NULL							                             AS exclusion_rider_2_form_nr,
                prehash_value('Annt',4)				                         AS underwriting_key_id,
                CASE
                    WHEN process_ind = 'D' THEN TRUE
                    ELSE FALSE
                    END                                                      AS source_delete_ind,
                process_ind                                                  AS process_ind,
                to_date(to_char(undwcnt.cycle_date), 'yyyymmdd')             AS begin_dt,
                to_date(to_char(undwcnt.cycle_date), 'yyyymmdd'):: TIMESTAMP AS begin_dtm,
                :audit_id                                                    AS audit_id,
                :audit_id                                                    AS update_audit_id
         FROM edw_staging.aif_rps_edw_client_full undw
                  INNER JOIN edw_staging.aif_rps_edw_client_full_count undwcnt --Only current batch audit will be used to join
                             ON undwcnt.audit_id = undw.audit_id
                                 AND undwcnt.source_system_id = 72
                  LEFT JOIN (SELECT DISTINCT trnslt_fld_val, src_cde, src_fld_nm, src_fld_val, src_tbl_nm, trnslt_fld_nm
                             FROM edw_ref.src_data_trnslt) agreement_sdt
                            ON UPPER(BTRIM(agreement_sdt.src_cde)) = 'ANN'
                                AND UPPER(BTRIM(agreement_sdt.src_fld_nm)) = 'ADMN_SYS_CDE'
                                AND UPPER(BTRIM(agreement_sdt.trnslt_fld_nm)) = 'ADMIN OR SOURCE SYSTEM CODE'
                                AND UPPER(BTRIM(agreement_sdt.src_fld_val)) =
                                    UPPER(BTRIM(udf_replaceemptystr(undw.aifclw_source_system_id, 'SPACE')))
         WHERE aifclw_contract_ident IN (SELECT contract_ident FROM CNRT_ID_FIL)
			   and aifclw_jt_annuitant_role_ind = 'Y'
   ) src;




/* EDW_WORK.AIFRPS_DIM_UNDERWRITING - INSERTS
 * 
 * THIS SCRIPT IS USED TO LOAD THE RECORDS THAT DON'T HAVE A RECORD IN TARGET
 * */

SELECT ANALYZE_STATISTICS('EDW_STAGING.AIFRPS_DIM_UNDERWRITING_PRE_WORK');
INSERT INTO edw_work.aifrps_dim_underwriting
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
FROM edw_staging.aifrps_dim_underwriting_pre_work
--insert when either no records in target table
WHERE dim_underwriting_natural_key_hash_uuid NOT IN
      (SELECT DISTINCT dim_underwriting_natural_key_hash_uuid
       FROM {{target_schema}}.dim_underwriting
       WHERE source_system_id in ('72','266')
      )
--AND UPPER(process_ind) IN ('A', 'C')
;


/* EDW_WORK.AIFRPS_DIM_UNDERWRITING WORK TABLE - UPDATE TGT RECORD
 * 
 * THIS SCRIPT FINDS RECORDS WHERE THE NEW RECORD FROM THE SOURCE HAS A DIFFERENT CHECK_SUM THAN THE CURRENT TARGET RECORD. 
 * THE CURRENT RECORD IN THE TARGET WILL BE ENDED SINCE THE SOURCE RECORD WILL BE INSERTED IN THE NEXT STEP.
 * */
INSERT INTO edw_work.aifrps_dim_underwriting
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
SELECT dim.dim_underwriting_natural_key_hash_uuid
     , dim.dim_agreement_natural_key_hash_uuid
     , dim.agreement_nr_pfx
     , dim.agreement_nr
     , dim.agreement_nr_sfx
     , dim.agreement_source_cde
     , dim.agreement_type_cde
     , dim.participant_role_cde
     , dim.source_participant_role_cde
     , dim.underwriting_sequence_nr
     , dim.source_participant_role_stype_cde
     , dim.issue_age_nr
     , dim.exclusion_rider_ind
     , dim.source_exclusion_rider_ind
     , dim.exclusion_rider_form_nr
     , dim.exclusion_cde
     , dim.source_exclusion_cde
     , dim.tobacco_class_cde
     , dim.source_tobacco_class_cde
     , dim.risk_class_cde
     , dim.source_risk_class_cde
     , dim.risk_class_pct
     , dim.unisex_ind
     , dim.exclusion_rider_2_form_nr
     , dim.underwriting_key_id
     , dim.begin_dt
     , dim.begin_dtm
     , CURRENT_TIMESTAMP(6)                    AS row_process_dtm
     , dim.check_sum
     , prework.begin_dt - INTERVAL '1' DAY     AS end_dt
     , prework.begin_dtm - INTERVAL '1' SECOND AS end_dtm
     , dim.restricted_row_ind
     , FALSE                                   AS current_row_ind
     , dim.logical_delete_ind
     , dim.source_system_id
     , dim.audit_id
     , :audit_id                               AS update_audit_id
     , dim.source_delete_ind
FROM {{target_schema}}.dim_underwriting dim
         JOIN
     edw_staging.aifrps_dim_underwriting_pre_work prework
ON dim.dim_underwriting_natural_key_hash_uuid = prework.dim_underwriting_natural_key_hash_uuid
    AND dim.current_row_ind = TRUE
    --AND UPPER(prework.process_ind) IN ('A', 'C')
WHERE
    --CHANGE IN CHECK_SUM
    (dim.check_sum <> prework.check_sum);

/* EDW_WORK.AIFRPS_DIM_UNDERWRITING WORK TABLE WORK TABLE - UPDATE WHERE RECORD ALREADY EXISTS IN TARGET 
 * 
 * 
 * */


INSERT INTO edw_work.aifrps_dim_underwriting
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
SELECT prework.dim_underwriting_natural_key_hash_uuid
     , prework.dim_agreement_natural_key_hash_uuid
     , prework.agreement_nr_pfx
     , prework.agreement_nr
     , prework.agreement_nr_sfx
     , prework.agreement_source_cde
     , prework.agreement_type_cde
     , prework.participant_role_cde
     , prework.source_participant_role_cde
     , prework.underwriting_sequence_nr
     , prework.source_participant_role_stype_cde
     , prework.issue_age_nr
     , prework.exclusion_rider_ind
     , prework.source_exclusion_rider_ind
     , prework.exclusion_rider_form_nr
     , prework.exclusion_cde
     , prework.source_exclusion_cde
     , prework.tobacco_class_cde
     , prework.source_tobacco_class_cde
     , prework.risk_class_cde
     , prework.source_risk_class_cde
     , prework.risk_class_pct
     , prework.unisex_ind
     , prework.exclusion_rider_2_form_nr
     , prework.underwriting_key_id
     , prework.begin_dt
     , prework.begin_dtm
     , CURRENT_TIMESTAMP(6) AS row_process_dtm
     , prework.check_sum
     , prework.end_dt
     , prework.end_dtm
     , prework.restricted_row_ind
     , prework.current_row_ind
     , prework.logical_delete_ind
     , prework.source_system_id
     , prework.audit_id
     , prework.update_audit_id
     , prework.source_delete_ind
FROM edw_staging.aifrps_dim_underwriting_pre_work prework
         LEFT JOIN
    {{target_schema}}.DIM_UNDERWRITING DIM
ON DIM.DIM_UNDERWRITING_NATURAL_KEY_HASH_UUID = PREWORK.DIM_UNDERWRITING_NATURAL_KEY_HASH_UUID
    AND DIM.CURRENT_ROW_IND = TRUE
    --AND UPPER(prework.process_ind) IN ('A', 'C')
WHERE
--handle when there isn't a current record in target but there are historical records and a delta coming through
    (DIM.ROW_SID IS NULL
  AND PREWORK.DIM_UNDERWRITING_NATURAL_KEY_HASH_UUID IN 
 (SELECT DISTINCT DIM_UNDERWRITING_NATURAL_KEY_HASH_UUID FROM {{target_schema}}.DIM_UNDERWRITING where source_system_id in ('72','266')) )

--handle when there is a current target record and either the check_sum has changed or record is being logically deleted.
   OR
    (DIM.ROW_SID IS NOT NULL
--CHECKSUM CHANGED
  AND (DIM.CHECK_SUM <> PREWORK.CHECK_SUM)
    )
;


/* WORK TABLE - DELETE TGT RECORDS 
 * 
 * This script finds records where the source has no records present for a corresponding current target record. 
 * The current record in the target will be ended and a copy of the current target record will be created and inserted as DELETE record.
 * */
INSERT INTO edw_work.aifrps_dim_underwriting
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
SELECT dim.dim_underwriting_natural_key_hash_uuid
     , dim.dim_agreement_natural_key_hash_uuid
     , dim.agreement_nr_pfx
     , dim.agreement_nr
     , dim.agreement_nr_sfx
     , dim.agreement_source_cde
     , dim.agreement_type_cde
     , dim.participant_role_cde
     , dim.source_participant_role_cde
     , dim.underwriting_sequence_nr
     , dim.source_participant_role_stype_cde
     , dim.issue_age_nr
     , dim.exclusion_rider_ind
     , dim.source_exclusion_rider_ind
     , dim.exclusion_rider_form_nr
     , dim.exclusion_cde
     , dim.source_exclusion_cde
     , dim.tobacco_class_cde
     , dim.source_tobacco_class_cde
     , dim.risk_class_cde
     , dim.source_risk_class_cde
     , dim.risk_class_pct
     , dim.unisex_ind
     , dim.exclusion_rider_2_form_nr
     , dim.underwriting_key_id
     , dim.begin_dt
     , dim.begin_dtm
     , CURRENT_TIMESTAMP(6)                    AS row_process_dtm
     , dim.check_sum
     , (CNT.CNT_CYCLE_DATE - INTERVAL '1' DAY)::DATE         AS END_DT
     , (CNT.CNT_CYCLE_DATE - INTERVAL '1' SECOND)::TIMESTAMP AS END_DTM
     , dim.restricted_row_ind
     , FALSE                                   AS current_row_ind
     , dim.logical_delete_ind
     , dim.source_system_id
     , dim.audit_id
     , :audit_id                               AS update_audit_id
     , dim.source_delete_ind
FROM {{target_schema}}.dim_underwriting dim

    --Added the below join to restrict the delete record calculation
    join
     CNRT_ID_FIL clnt
     on dim.agreement_nr = udf_aif_hldg_key_format(contract_ident,'KEY')      
	 and COALESCE(dim.agreement_nr_pfx,'') = COALESCE(clean_string(udf_aif_hldg_key_format(contract_ident,'PFX')),'') 
     and COALESCE(dim.agreement_nr_sfx,'') = COALESCE(clean_string(udf_aif_hldg_key_format(contract_ident,'SFX')),'')

	join
      (SELECT TO_DATE(TO_CHAR(CYCLE_DATE), 'YYYYMMDD') AS CNT_CYCLE_DATE, AUDIT_ID
      FROM edw_staging.aif_rps_edw_client_full_count) CNT
      ON 1 = 1
    LEFT JOIN
     edw_staging.aifrps_dim_underwriting_pre_work prework
	 ON dim.dim_underwriting_natural_key_hash_uuid = prework.dim_underwriting_natural_key_hash_uuid
    
WHERE
    -- record not found in source
	dim.current_row_ind = TRUE
	AND dim.source_delete_ind = FALSE
    AND dim.source_system_id IN ('72', '266')
    AND prework.dim_underwriting_natural_key_hash_uuid IS NULL;



/* WORK TABLE - UPDATE CURR RECORDS : DELETE SCENARIO
 * 
 * 
 * */
INSERT INTO edw_work.aifrps_dim_underwriting
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
SELECT dim.dim_underwriting_natural_key_hash_uuid
     , dim.dim_agreement_natural_key_hash_uuid
     , dim.agreement_nr_pfx
     , dim.agreement_nr
     , dim.agreement_nr_sfx
     , dim.agreement_source_cde
     , dim.agreement_type_cde
     , dim.participant_role_cde
     , dim.source_participant_role_cde
     , dim.underwriting_sequence_nr
     , dim.source_participant_role_stype_cde
     , dim.issue_age_nr
     , dim.exclusion_rider_ind
     , dim.source_exclusion_rider_ind
     , dim.exclusion_rider_form_nr
     , dim.exclusion_cde
     , dim.source_exclusion_cde
     , dim.tobacco_class_cde
     , dim.source_tobacco_class_cde
     , dim.risk_class_cde
     , dim.source_risk_class_cde
     , dim.risk_class_pct
     , dim.unisex_ind
     , dim.exclusion_rider_2_form_nr
     , dim.underwriting_key_id
     , CNT.CNT_CYCLE_DATE                                    AS BEGIN_DT
     , CNT.CNT_CYCLE_DATE :: TIMESTAMP                       AS BEGIN_DTM
     , CURRENT_TIMESTAMP(6)									 AS row_process_dtm
     , uuid_gen(TRUE,TO_CHAR(dim.check_sum)) :: UUID         AS check_sum
     , '9999-12-31'::DATE                                    AS END_DT
     , '9999-12-31'::TIMESTAMP                               AS END_DTM
     , FALSE                                                 AS RESTRICTED_ROW_IND
     , TRUE												     AS CURRENT_ROW_IND
     , FALSE                                                 AS LOGICAL_DELETE_IND
     , '72'													 AS SOURCE_SYSTEM_ID
     , dim.audit_id
     , CNT.AUDIT_ID                                          AS UPDATE_AUDIT_ID
     , TRUE													 AS SOURCE_DELETE_IND
FROM {{target_schema}}.dim_underwriting dim

    --Added the below join to restrict the delete record calculation
    join
     CNRT_ID_FIL clnt
     on dim.agreement_nr = udf_aif_hldg_key_format(contract_ident,'KEY')      
	 and COALESCE(dim.agreement_nr_pfx,'') = COALESCE(clean_string(udf_aif_hldg_key_format(contract_ident,'PFX')),'') 
     and COALESCE(dim.agreement_nr_sfx,'') = COALESCE(clean_string(udf_aif_hldg_key_format(contract_ident,'SFX')),'')

	JOIN
      (SELECT TO_DATE(TO_CHAR(CYCLE_DATE), 'YYYYMMDD')		 AS CNT_CYCLE_DATE, AUDIT_ID
      FROM edw_staging.aif_rps_edw_client_full_count) CNT
      ON 1 = 1
    LEFT JOIN
     edw_staging.aifrps_dim_underwriting_pre_work prework
	 ON dim.dim_underwriting_natural_key_hash_uuid = prework.dim_underwriting_natural_key_hash_uuid
    
WHERE
    -- record not found in source
	dim.current_row_ind = TRUE
	AND dim.source_delete_ind = FALSE
    AND dim.source_system_id IN ('72', '266')
    AND prework.dim_underwriting_natural_key_hash_uuid IS NULL;



SELECT ANALYZE_STATISTICS('EDW_WORK.AIFRPS_DIM_UNDERWRITING');