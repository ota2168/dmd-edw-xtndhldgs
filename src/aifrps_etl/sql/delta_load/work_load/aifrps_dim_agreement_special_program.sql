/*
		FILENAME:       AifRps_Dim_Agreement_Special_Program.Sql
		AUTHOR:         Sai K
		SUBJECT AREA :  Agreement
		SOURCE:         AIF - RPS
		TERADATA SOURCE CODE: 72
		DESCRIPTION:    Attr_Agreement_Special_Program TABLE POPULATION

		===============================================================================================================
		VERSION/JIRA STORY#			CREATED BY          LAST_MODIFIED_DATE		DESCRIPTION
		---------------------------------------------------------------------------------------------------------------
		JIRA# TERSUN-####           Sai                 08/02/2021			First Version of Delta Load for Tier-2

		---------------------------------------------------------------------------------------------------------------
*/


/* TRUNCATE STAGING PRE WORK TABLE */
truncate table EDW_STAGING.AIFRPS_DIM_AGREEMENT_SPECIAL_PROGRAM_PRE_WORK;

/*TRUNCATE WORK TABLE */
truncate table EDW_WORK.AIFRPS_DIM_AGREEMENT_SPECIAL_PROGRAM;


/*Insert Script for Pre-Work Table - All records from Stg*/
--STEP1-> EDW_STAGING.SOURCE => EDW_STAGING.PRE_WORK, BUSINESS LOGIC DONE HERE.

INSERT INTO EDW_STAGING.AIFRPS_DIM_AGREEMENT_SPECIAL_PROGRAM_PRE_WORK
(DIM_AGREEMENT_SPECIAL_PROGRAM_NATURAL_KEY_HASH_UUID,
 DIM_AGREEMENT_NATURAL_KEY_HASH_UUID,
 SPECIAL_PROGRAM_KEY_ID,
 AGREEMENT_NR_PFX,
 AGREEMENT_NR,
 AGREEMENT_NR_SFX,
 AGREEMENT_SOURCE_CDE,
 AGREEMENT_TYPE_CDE,
 SPECIAL_PROGRAM_TYPE_CDE,
 SPECIAL_PROGRAM_COUNTER_NR,
 SPECIAL_PROGRAM_FEATURE_TYPE_CDE,
 ADMIN_FUND_CDE,
 PRODUCT_ID,
 COMPANY_CDE,
 PT1_KIND_CDE,
 PRODUCT_TIER_CDE,
 DIM_FUND_NATURAL_KEY_HASH_UUID,
 SOURCE_SPECIAL_PROGRAM_TYPE_CDE,
 PROGRAM_BUSINESS_START_DT,
 PROGRAM_BUSINESS_END_DT,
 PROGRAM_MODE_CDE,
 SOURCE_PROGRAM_MODE_CDE,
 PROGRAM_MODE_NR,
 PROGRAM_DURATION_NR,
 PROGRAM_AMT,
 PROGRAM_CALCULATION_TYPE_CDE,
 SOURCE_PROGRAM_CALCULATION_TYPE_CDE,
 PROGRAM_AMT_TYPE_CDE,
 SOURCE_PROGRAM_AMT_TYPE_CDE,
 DETAIL_AMT,
 DETAIL_PCT,
 PROGRAM_INTEREST_RT,
 NEXT_RUN_DT,
 FIRST_PAYMENT_DT,
 FIRST_PAYMENT_YEAR_NR,
 PRIOR_MRD_AMT,
 PRIOR_MRD_AMT_TYPE_CDE,
 SOURCE_PRIOR_MRD_AMT_TYPE_CDE,
 EXCLUSION_AMT,
 BEGIN_DT,
 BEGIN_DTM,
 ROW_PROCESS_DTM,
 CHECK_SUM,
 END_DT,
 END_DTM,
 RESTRICTED_ROW_IND,
 CURRENT_ROW_IND,
 LOGICAL_DELETE_IND,
 SOURCE_SYSTEM_ID,
 AUDIT_ID,
 UPDATE_AUDIT_ID,
 SOURCE_DELETE_IND)
SELECT UUID_GEN
           (
               CLEAN_STRING('RPS'),
               CLEAN_STRING('IPA'),
               UDF_ISNUM_LPAD(AGREEMENT_NR_PFX, 20, '0', TRUE),
               LPAD(AGREEMENT_NR::VARCHAR, 20, '0'),
               UDF_ISNUM_LPAD(AGREEMENT_NR_SFX, 20, '0', TRUE),
               CLEAN_STRING(SPECIAL_PROGRAM_TYPE_CDE),
               CLEAN_STRING(SPECIAL_PROGRAM_COUNTER_NR::VARCHAR)
           )::UUID
                   AS DIM_AGREEMENT_SPECIAL_PROGRAM_NATURAL_KEY_HASH_UUID,
       UUID_GEN
           (
               CLEAN_STRING('RPS'),
               CLEAN_STRING('IPA'),
               UDF_ISNUM_LPAD(AGREEMENT_NR_PFX, 20, '0', TRUE),
               LPAD(AGREEMENT_NR::VARCHAR, 20, '0'),
               UDF_ISNUM_LPAD(AGREEMENT_NR_SFX, 20, '0', TRUE)
           )::UUID
                   AS DIM_AGREEMENT_NATURAL_KEY_HASH_UUID,
       PREHASH_VALUE
           (
               CLEAN_STRING(SPECIAL_PROGRAM_TYPE_CDE),
               CLEAN_STRING(SPECIAL_PROGRAM_COUNTER_NR::varchar)
           )       AS SPECIAL_PROGRAM_KEY_ID, 
       AGREEMENT_NR_PFX,
       AGREEMENT_NR,
       AGREEMENT_NR_SFX,
       AGREEMENT_SOURCE_CDE,
       AGREEMENT_TYPE_CDE,
       SPECIAL_PROGRAM_TYPE_CDE,
       SPECIAL_PROGRAM_COUNTER_NR,
       SPECIAL_PROGRAM_FEATURE_TYPE_CDE,
       ADMIN_FUND_CDE,
       PRODUCT_ID,
       COMPANY_CDE,
       PT1_KIND_CDE,
       PRODUCT_TIER_CDE,
       UUID_GEN
           (
               NULL
           )::UUID
                   AS DIM_FUND_NATURAL_KEY_HASH_UUID,

       SOURCE_SPECIAL_PROGRAM_TYPE_CDE,
       PROGRAM_BUSINESS_START_DT,
       PROGRAM_BUSINESS_END_DT,
       PROGRAM_MODE_CDE,
       SOURCE_PROGRAM_MODE_CDE,
       PROGRAM_MODE_NR::int, --Conversion applied to handle Null Values.
       PROGRAM_DURATION_NR,
       PROGRAM_AMT,
       PROGRAM_CALCULATION_TYPE_CDE,
       SOURCE_PROGRAM_CALCULATION_TYPE_CDE,
       PROGRAM_AMT_TYPE_CDE,
       SOURCE_PROGRAM_AMT_TYPE_CDE,
       DETAIL_AMT,
       DETAIL_PCT,
       PROGRAM_INTEREST_RT,
       NEXT_RUN_DT,
       FIRST_PAYMENT_DT,
       FIRST_PAYMENT_YEAR_NR,
       PRIOR_MRD_AMT,
       PRIOR_MRD_AMT_TYPE_CDE,
       SOURCE_PRIOR_MRD_AMT_TYPE_CDE,
       EXCLUSION_AMT,
       BEGIN_DT,
       BEGIN_DTM,
       ROW_PROCESS_DTM,
       UUID_GEN
           (
            SOURCE_DELETE_IND::Boolean,
            SOURCE_SPECIAL_PROGRAM_TYPE_CDE,
            SPECIAL_PROGRAM_FEATURE_TYPE_CDE,
            PROGRAM_BUSINESS_START_DT,
            PROGRAM_BUSINESS_END_DT,
            PROGRAM_MODE_CDE,
            SOURCE_PROGRAM_MODE_CDE,
            PROGRAM_MODE_NR
           )::UUID AS CHECK_SUM,
       END_DT,
       END_DTM,
       RESTRICTED_ROW_IND,
       CURRENT_ROW_IND,
       LOGICAL_DELETE_IND,
       SOURCE_SYSTEM_ID,
       AUDIT_ID,
       UPDATE_AUDIT_ID,
       SOURCE_DELETE_IND
FROM (
         SELECT PUBLIC.UDF_AIF_HLDG_KEY_FORMAT(CTRT_DELTA.aifcow_policy_id, 'PFX')		AS AGREEMENT_NR_PFX,
                PUBLIC.UDF_AIF_HLDG_KEY_FORMAT(CTRT_DELTA.aifcow_policy_id, 'KEY')		AS AGREEMENT_NR,
                PUBLIC.UDF_AIF_HLDG_KEY_FORMAT(CTRT_DELTA.aifcow_policy_id, 'SFX')		AS AGREEMENT_NR_SFX,
                CLEAN_STRING(AGMT_AIFCOW_SDT.TRNSLT_FLD_VAL)							AS AGREEMENT_SOURCE_CDE,
                'Ipa'                                                                   AS AGREEMENT_TYPE_CDE,
                'AR'	                                                                 AS SPECIAL_PROGRAM_TYPE_CDE,
                1                                                                        AS SPECIAL_PROGRAM_COUNTER_NR,
                NULL                                                                     AS SPECIAL_PROGRAM_FEATURE_TYPE_CDE,
                NULL                                                                     AS ADMIN_FUND_CDE,
                NULL                                                                     AS PRODUCT_ID,
                NULL                                                                     AS COMPANY_CDE,
                NULL                                                                     AS PT1_KIND_CDE,
                NULL                                                                     AS PRODUCT_TIER_CDE,
                NULL	                                                                 AS SOURCE_SPECIAL_PROGRAM_TYPE_CDE,
                CASE WHEN
                      TO_CHAR(CTRT_DELTA.aifcow_rebal_start_yyyy) ||
                      LPAD(TO_CHAR(CTRT_DELTA.aifcow_rebal_start_mm), 2, '0') ||
                      LPAD(TO_CHAR(CTRT_DELTA.aifcow_rebal_start_dd), 2, '0') = 99999999
                          OR 
					  TO_CHAR(CTRT_DELTA.aifcow_rebal_start_yyyy) ||
                      LPAD(TO_CHAR(CTRT_DELTA.aifcow_rebal_start_mm), 2, '0') ||
                      LPAD(TO_CHAR(CTRT_DELTA.aifcow_rebal_start_dd), 2, '0') > 52000000
                 
				THEN 
					  TO_DATE('9999-12-31', 'YYYY-MM-DD')
                ELSE
                      public.isdate((TO_CHAR(CTRT_DELTA.aifcow_rebal_start_yyyy)) ||
                      LPAD(TO_CHAR(CTRT_DELTA.aifcow_rebal_start_mm), 2, '0') ||
                      LPAD(TO_CHAR(CTRT_DELTA.aifcow_rebal_start_dd), 2, '0'))
                END																		 AS PROGRAM_BUSINESS_START_DT,
                TO_DATE('9999-12-31', 'YYYY-MM-DD')									     AS PROGRAM_BUSINESS_END_DT,
                CASE WHEN PRGM_MODECDE_SDT.TRNSLT_FLD_VAL IS NULL THEN 'UNK' 
					ELSE PRGM_MODECDE_SDT.TRNSLT_FLD_VAL  END                            AS PROGRAM_MODE_CDE,
                CTRT_DELTA.aifcow_port_rebal_freq_code                                   AS SOURCE_PROGRAM_MODE_CDE,
                CASE WHEN PRGM_MODENR_SDT.TRNSLT_FLD_VAL IS NULL OR clean_string(PRGM_MODENR_SDT.TRNSLT_FLD_VAL)='Unk' THEN '0' 
					ELSE  PRGM_MODENR_SDT.TRNSLT_FLD_VAL  END                            AS PROGRAM_MODE_NR,
                NULL                                                                     AS PROGRAM_DURATION_NR,
                NULL                                                                     AS PROGRAM_AMT,
                NULL                                                                     AS PROGRAM_CALCULATION_TYPE_CDE,
                NULL                                                                     AS SOURCE_PROGRAM_CALCULATION_TYPE_CDE,
                NULL                                                                     AS PROGRAM_AMT_TYPE_CDE,
                NULL                                                                     AS SOURCE_PROGRAM_AMT_TYPE_CDE,
                NULL                                                                     AS DETAIL_AMT,
                NULL                                                                     AS DETAIL_PCT,
                NULL                                                                     AS PROGRAM_INTEREST_RT,
                CASE WHEN
                      TO_CHAR(CTRT_DELTA.aifcow_next_port_rebal_yyyy) ||
                      LPAD(TO_CHAR(CTRT_DELTA.aifcow_next_port_rebal_mm), 2, '0') ||
                      LPAD(TO_CHAR(CTRT_DELTA.aifcow_next_port_rebal_dd), 2, '0') = 99999999
                          OR 
					  TO_CHAR(CTRT_DELTA.aifcow_next_port_rebal_yyyy) ||
                      LPAD(TO_CHAR(CTRT_DELTA.aifcow_next_port_rebal_mm), 2, '0') ||
                      LPAD(TO_CHAR(CTRT_DELTA.aifcow_next_port_rebal_dd), 2, '0') > 52000000
                 
				THEN 
					  TO_DATE('9999-12-31', 'YYYY-MM-DD')
                ELSE
                      public.isdate((TO_CHAR(CTRT_DELTA.aifcow_next_port_rebal_yyyy)) ||
                      LPAD(TO_CHAR(CTRT_DELTA.aifcow_next_port_rebal_mm), 2, '0') ||
                      LPAD(TO_CHAR(CTRT_DELTA.aifcow_next_port_rebal_dd), 2, '0'))
                END																		 AS NEXT_RUN_DT,
                NULL                                                                     AS FIRST_PAYMENT_DT,
                NULL                                                                     AS FIRST_PAYMENT_YEAR_NR,
                NULL                                                                     AS PRIOR_MRD_AMT,
                NULL                                                                     AS PRIOR_MRD_AMT_TYPE_CDE,
                NULL                                                                     AS SOURCE_PRIOR_MRD_AMT_TYPE_CDE,
                NULL                                                                     AS EXCLUSION_AMT,
                TO_DATE(TO_CHAR(CTRT_DELTA_CNT.CYCLE_DATE), 'YYYYMMDD')                  AS BEGIN_DT,
                TO_DATE(TO_CHAR(CTRT_DELTA_CNT.CYCLE_DATE), 'YYYYMMDD')::TIMESTAMP       AS BEGIN_DTM,
                CURRENT_TIMESTAMP(6)                                                     AS ROW_PROCESS_DTM,
                '9999-12-31'::DATE                                                       AS END_DT,
                '9999-12-31'::TIMESTAMP                                                  AS END_DTM,
                FALSE                                                                    AS RESTRICTED_ROW_IND,
                TRUE                                                                     AS CURRENT_ROW_IND,
                FALSE                                                                    AS LOGICAL_DELETE_IND,
                72                                                                       AS SOURCE_SYSTEM_ID,
                :audit_id                                                                AS AUDIT_ID,
                :audit_id                                                                AS UPDATE_AUDIT_ID,
                FALSE                                                                    AS SOURCE_DELETE_IND
         FROM 	( SELECT * FROM EDW_STAGING.AIF_RPS_EDW_CTRT_FULL_DEDUP 
                  UNION
				  SELECT * FROM EDW_STAGING.AIF_RPS_EDW_CTRT_DELTA_DEDUP WHERE PROCESSED_IND='D' ) CTRT_DELTA

                  INNER JOIN EDW_STAGING.AIF_RPS_EDW_CTRT_DELTA_COUNT CTRT_DELTA_CNT
                             ON CTRT_DELTA.AUDIT_ID = CTRT_DELTA_CNT.AUDIT_ID
                                 AND CTRT_DELTA_CNT.source_system_id = 72

                  LEFT JOIN (SELECT DISTINCT TRNSLT_FLD_VAL, SRC_CDE, SRC_FLD_NM, SRC_FLD_VAL, SRC_TBL_NM, TRNSLT_FLD_NM
                             FROM EDW_REF.SRC_DATA_TRNSLT) AGMT_AIFCOW_SDT
                            ON UPPER(BTRIM(AGMT_AIFCOW_SDT.SRC_CDE)) = 'ANN'
                                AND UPPER(BTRIM(AGMT_AIFCOW_SDT.SRC_FLD_NM)) = 'ADMN_SYS_CDE'
                                AND UPPER(BTRIM(AGMT_AIFCOW_SDT.TRNSLT_FLD_NM)) = 'ADMIN OR SOURCE SYSTEM CODE'
                                AND UPPER(BTRIM(AGMT_AIFCOW_SDT.SRC_FLD_VAL)) =
                                    UPPER(UDF_REPLACEEMPTYSTR(CTRT_DELTA.AIFCOW_SOURCE_SYSTEM_ID, 'SPACE'))
             
                  LEFT JOIN (SELECT DISTINCT TRNSLT_FLD_VAL, SRC_CDE, SRC_FLD_NM, SRC_FLD_VAL, SRC_TBL_NM, TRNSLT_FLD_NM
                             FROM EDW_REF.SRC_DATA_TRNSLT) PRGM_MODECDE_SDT
                            ON UPPER(BTRIM(PRGM_MODECDE_SDT.SRC_CDE)) = 'ANN'
                                AND UPPER(BTRIM(PRGM_MODECDE_SDT.SRC_FLD_NM)) = 'BILL_FREQ'
                                AND UPPER(BTRIM(PRGM_MODECDE_SDT.TRNSLT_FLD_NM)) = 'BILLING FREQUENCY'
                                AND UPPER(BTRIM(PRGM_MODECDE_SDT.SRC_FLD_VAL)) =
                                    UPPER(UDF_REPLACEEMPTYSTR(CTRT_DELTA.AIFCOW_ATS_FREQ, 'SPACE'))

                  LEFT JOIN (SELECT DISTINCT TRNSLT_FLD_VAL, SRC_CDE, SRC_FLD_NM, SRC_FLD_VAL, SRC_TBL_NM, TRNSLT_FLD_NM
                             FROM EDW_REF.SRC_DATA_TRNSLT) PRGM_MODENR_SDT
                            ON UPPER(BTRIM(PRGM_MODENR_SDT.SRC_CDE)) = 'ANN'
                                AND UPPER(BTRIM(PRGM_MODENR_SDT.SRC_FLD_NM)) = 'BILL_FREQ'
                                AND UPPER(BTRIM(PRGM_MODENR_SDT.TRNSLT_FLD_NM)) = 'BILLING FREQUENCY NUMBER'
                                AND UPPER(BTRIM(PRGM_MODENR_SDT.SRC_FLD_VAL)) =
                                    UPPER(UDF_REPLACEEMPTYSTR(CTRT_DELTA.AIFCOW_ATS_FREQ, 'SPACE'))
				  
				  WHERE CTRT_DELTA.AIFCOW_PORTFOLIO_REBAL_IND='Y'
     ) STG;


select analyze_statistics('edw_staging.aifrps_dim_agreement_special_program_pre_work');

-- Step 2: THIS SCRIPT IS USED TO LOAD THE RECORDS THAT DON'T HAVE A RECORD IN TARGET

INSERT INTO edw_work.aifrps_dim_agreement_special_program
(DIM_AGREEMENT_SPECIAL_PROGRAM_NATURAL_KEY_HASH_UUID,
 DIM_AGREEMENT_NATURAL_KEY_HASH_UUID,
 SPECIAL_PROGRAM_KEY_ID,
 AGREEMENT_NR_PFX,
 AGREEMENT_NR,
 AGREEMENT_NR_SFX,
 AGREEMENT_SOURCE_CDE,
 AGREEMENT_TYPE_CDE,
 SPECIAL_PROGRAM_TYPE_CDE,
 SPECIAL_PROGRAM_COUNTER_NR,
 SPECIAL_PROGRAM_FEATURE_TYPE_CDE,
 ADMIN_FUND_CDE,
 PRODUCT_ID,
 COMPANY_CDE,
 PT1_KIND_CDE,
 PRODUCT_TIER_CDE,
 DIM_FUND_NATURAL_KEY_HASH_UUID,
 SOURCE_SPECIAL_PROGRAM_TYPE_CDE,
 PROGRAM_BUSINESS_START_DT,
 PROGRAM_BUSINESS_END_DT,
 PROGRAM_MODE_CDE,
 SOURCE_PROGRAM_MODE_CDE,
 PROGRAM_MODE_NR,
 PROGRAM_DURATION_NR,
 PROGRAM_AMT,
 PROGRAM_CALCULATION_TYPE_CDE,
 SOURCE_PROGRAM_CALCULATION_TYPE_CDE,
 PROGRAM_AMT_TYPE_CDE,
 SOURCE_PROGRAM_AMT_TYPE_CDE,
 DETAIL_AMT,
 DETAIL_PCT,
 PROGRAM_INTEREST_RT,
 NEXT_RUN_DT,
 FIRST_PAYMENT_DT,
 FIRST_PAYMENT_YEAR_NR,
 PRIOR_MRD_AMT,
 PRIOR_MRD_AMT_TYPE_CDE,
 SOURCE_PRIOR_MRD_AMT_TYPE_CDE,
 EXCLUSION_AMT,
 BEGIN_DT,
 BEGIN_DTM,
 ROW_PROCESS_DTM,
 CHECK_SUM,
 END_DT,
 END_DTM,
 RESTRICTED_ROW_IND,
 CURRENT_ROW_IND,
 LOGICAL_DELETE_IND,
 SOURCE_SYSTEM_ID,
 AUDIT_ID,
 UPDATE_AUDIT_ID,
 SOURCE_DELETE_IND)
SELECT
        Staging.DIM_AGREEMENT_SPECIAL_PROGRAM_NATURAL_KEY_HASH_UUID,
        Staging.DIM_AGREEMENT_NATURAL_KEY_HASH_UUID,
        Staging.SPECIAL_PROGRAM_KEY_ID,
        Staging.AGREEMENT_NR_PFX,
        Staging.AGREEMENT_NR,
        Staging.AGREEMENT_NR_SFX,
        Staging.AGREEMENT_SOURCE_CDE,
        Staging.AGREEMENT_TYPE_CDE,
        Staging.SPECIAL_PROGRAM_TYPE_CDE,
        Staging.SPECIAL_PROGRAM_COUNTER_NR,
        Staging.SPECIAL_PROGRAM_FEATURE_TYPE_CDE,
        Staging.ADMIN_FUND_CDE,
        Staging.PRODUCT_ID,
        Staging.COMPANY_CDE,
        Staging.PT1_KIND_CDE,
        Staging.PRODUCT_TIER_CDE,
        Staging.DIM_FUND_NATURAL_KEY_HASH_UUID,
        Staging.SOURCE_SPECIAL_PROGRAM_TYPE_CDE,
        Staging.PROGRAM_BUSINESS_START_DT,
        Staging.PROGRAM_BUSINESS_END_DT,
        Staging.PROGRAM_MODE_CDE,
        Staging.SOURCE_PROGRAM_MODE_CDE,
        Staging.PROGRAM_MODE_NR,
        Staging.PROGRAM_DURATION_NR,
        Staging.PROGRAM_AMT,
        Staging.PROGRAM_CALCULATION_TYPE_CDE,
        Staging.SOURCE_PROGRAM_CALCULATION_TYPE_CDE,
        Staging.PROGRAM_AMT_TYPE_CDE,
        Staging.SOURCE_PROGRAM_AMT_TYPE_CDE,
        Staging.DETAIL_AMT,
        Staging.DETAIL_PCT,
        Staging.PROGRAM_INTEREST_RT,
        Staging.NEXT_RUN_DT,
        Staging.FIRST_PAYMENT_DT,
        Staging.FIRST_PAYMENT_YEAR_NR,
        Staging.PRIOR_MRD_AMT,
        Staging.PRIOR_MRD_AMT_TYPE_CDE,
        Staging.SOURCE_PRIOR_MRD_AMT_TYPE_CDE,
        Staging.EXCLUSION_AMT,
        Staging.BEGIN_DT,
        Staging.BEGIN_DTM,
        Staging.ROW_PROCESS_DTM,
        Staging.CHECK_SUM,
        Staging.END_DT,
        Staging.END_DTM,
        Staging.RESTRICTED_ROW_IND,
        Staging.CURRENT_ROW_IND,
        Staging.LOGICAL_DELETE_IND,
        Staging.SOURCE_SYSTEM_ID,
        Staging.AUDIT_ID,
        Staging.UPDATE_AUDIT_ID,
        Staging.SOURCE_DELETE_IND
FROM edw_staging.aifrps_dim_agreement_special_program_pre_work Staging
WHERE (Staging.DIM_AGREEMENT_NATURAL_KEY_HASH_UUID,Staging.DIM_AGREEMENT_SPECIAL_PROGRAM_NATURAL_KEY_HASH_UUID) NOT IN
      (SELECT DIM_AGREEMENT_NATURAL_KEY_HASH_UUID,
              DIM_AGREEMENT_SPECIAL_PROGRAM_NATURAL_KEY_HASH_UUID
       FROM {{target_schema}}.dim_agreement_special_program);

-- Step3
/* edw_work.aifrps_dim_agreement_special_program WORK TABLE - UPDATE TGT RECORD
 *
 * THIS SCRIPT FINDS RECORDS WHERE THE NEW RECORD FROM THE SOURCE HAS A DIFFERENT CHECK_SUM THAN THE CURRENT TARGET RECORD.
 * THE CURRENT RECORD IN THE TARGET WILL BE ENDED SINCE THE SOURCE RECORD WILL BE INSERTED IN THE NEXT STEP.
 *
*/

INSERT INTO edw_work.aifrps_dim_agreement_special_program
(DIM_AGREEMENT_SPECIAL_PROGRAM_NATURAL_KEY_HASH_UUID,
 DIM_AGREEMENT_NATURAL_KEY_HASH_UUID,
 SPECIAL_PROGRAM_KEY_ID,
 AGREEMENT_NR_PFX,
 AGREEMENT_NR,
 AGREEMENT_NR_SFX,
 AGREEMENT_SOURCE_CDE,
 AGREEMENT_TYPE_CDE,
 SPECIAL_PROGRAM_TYPE_CDE,
 SPECIAL_PROGRAM_COUNTER_NR,
 SPECIAL_PROGRAM_FEATURE_TYPE_CDE,
 ADMIN_FUND_CDE,
 PRODUCT_ID,
 COMPANY_CDE,
 PT1_KIND_CDE,
 PRODUCT_TIER_CDE,
 DIM_FUND_NATURAL_KEY_HASH_UUID,
 SOURCE_SPECIAL_PROGRAM_TYPE_CDE,
 PROGRAM_BUSINESS_START_DT,
 PROGRAM_BUSINESS_END_DT,
 PROGRAM_MODE_CDE,
 SOURCE_PROGRAM_MODE_CDE,
 PROGRAM_MODE_NR,
 PROGRAM_DURATION_NR,
 PROGRAM_AMT,
 PROGRAM_CALCULATION_TYPE_CDE,
 SOURCE_PROGRAM_CALCULATION_TYPE_CDE,
 PROGRAM_AMT_TYPE_CDE,
 SOURCE_PROGRAM_AMT_TYPE_CDE,
 DETAIL_AMT,
 DETAIL_PCT,
 PROGRAM_INTEREST_RT,
 NEXT_RUN_DT,
 FIRST_PAYMENT_DT,
 FIRST_PAYMENT_YEAR_NR,
 PRIOR_MRD_AMT,
 PRIOR_MRD_AMT_TYPE_CDE,
 SOURCE_PRIOR_MRD_AMT_TYPE_CDE,
 EXCLUSION_AMT,
 BEGIN_DT,
 BEGIN_DTM,
 ROW_PROCESS_DTM,
 CHECK_SUM,
 END_DT,
 END_DTM,
 RESTRICTED_ROW_IND,
 CURRENT_ROW_IND,
 LOGICAL_DELETE_IND,
 SOURCE_SYSTEM_ID,
 AUDIT_ID,
 UPDATE_AUDIT_ID,
 SOURCE_DELETE_IND)
SELECT
        TGT.DIM_AGREEMENT_SPECIAL_PROGRAM_NATURAL_KEY_HASH_UUID,
        TGT.DIM_AGREEMENT_NATURAL_KEY_HASH_UUID,
        TGT.SPECIAL_PROGRAM_KEY_ID,
        TGT.AGREEMENT_NR_PFX,
        TGT.AGREEMENT_NR,
        TGT.AGREEMENT_NR_SFX,
        TGT.AGREEMENT_SOURCE_CDE,
        TGT.AGREEMENT_TYPE_CDE,
        TGT.SPECIAL_PROGRAM_TYPE_CDE,
        TGT.SPECIAL_PROGRAM_COUNTER_NR,
        TGT.SPECIAL_PROGRAM_FEATURE_TYPE_CDE,
        TGT.ADMIN_FUND_CDE,
        TGT.PRODUCT_ID,
        TGT.COMPANY_CDE,
        TGT.PT1_KIND_CDE,
        TGT.PRODUCT_TIER_CDE,
        TGT.DIM_FUND_NATURAL_KEY_HASH_UUID,
        TGT.SOURCE_SPECIAL_PROGRAM_TYPE_CDE,
        TGT.PROGRAM_BUSINESS_START_DT,
        TGT.PROGRAM_BUSINESS_END_DT,
        TGT.PROGRAM_MODE_CDE,
        TGT.SOURCE_PROGRAM_MODE_CDE,
        TGT.PROGRAM_MODE_NR,
        TGT.PROGRAM_DURATION_NR,
        TGT.PROGRAM_AMT,
        TGT.PROGRAM_CALCULATION_TYPE_CDE,
        TGT.SOURCE_PROGRAM_CALCULATION_TYPE_CDE,
        TGT.PROGRAM_AMT_TYPE_CDE,
        TGT.SOURCE_PROGRAM_AMT_TYPE_CDE,
        TGT.DETAIL_AMT,
        TGT.DETAIL_PCT,
        TGT.PROGRAM_INTEREST_RT,
        TGT.NEXT_RUN_DT,
        TGT.FIRST_PAYMENT_DT,
        TGT.FIRST_PAYMENT_YEAR_NR,
        TGT.PRIOR_MRD_AMT,
        TGT.PRIOR_MRD_AMT_TYPE_CDE,
        TGT.SOURCE_PRIOR_MRD_AMT_TYPE_CDE,
        TGT.EXCLUSION_AMT,
        TGT.BEGIN_DT,
        TGT.BEGIN_DTM,
        CURRENT_TIMESTAMP(6)                AS ROW_PROCESS_DTM,
        TGT.CHECK_SUM,
        SRC.BEGIN_DT - INTERVAL '1' DAY     AS END_DT,
        SRC.BEGIN_DTM - INTERVAL '1' SECOND AS END_DTM,
        TGT.RESTRICTED_ROW_IND,
        FALSE                               AS CURRENT_ROW_IND,
        TGT.LOGICAL_DELETE_IND,
        TGT.SOURCE_SYSTEM_ID,
        TGT.AUDIT_ID,
        :audit_id                           AS UPDATE_AUDIT_ID,
        TGT.SOURCE_DELETE_IND
FROM {{target_schema}}.dim_agreement_special_program TGT
LEFT JOIN edw_staging.aifrps_dim_agreement_special_program_pre_work SRC
ON      SRC.DIM_AGREEMENT_SPECIAL_PROGRAM_NATURAL_KEY_HASH_UUID = TGT.DIM_AGREEMENT_SPECIAL_PROGRAM_NATURAL_KEY_HASH_UUID
    AND SRC.DIM_AGREEMENT_NATURAL_KEY_HASH_UUID = TGT.DIM_AGREEMENT_NATURAL_KEY_HASH_UUID
    AND TGT.CURRENT_ROW_IND = TRUE
WHERE
    SRC.CHECK_SUM <> TGT.CHECK_SUM;

-- Step4
/* edw_work.aifrps_dim_agreement_special_program
 * WORK TABLE - UPDATE WHERE RECORD ALREADY EXISTS IN TARGET
 *
 *
*/

INSERT INTO edw_work.aifrps_dim_agreement_special_program
(DIM_AGREEMENT_SPECIAL_PROGRAM_NATURAL_KEY_HASH_UUID,
 DIM_AGREEMENT_NATURAL_KEY_HASH_UUID,
 SPECIAL_PROGRAM_KEY_ID,
 AGREEMENT_NR_PFX,
 AGREEMENT_NR,
 AGREEMENT_NR_SFX,
 AGREEMENT_SOURCE_CDE,
 AGREEMENT_TYPE_CDE,
 SPECIAL_PROGRAM_TYPE_CDE,
 SPECIAL_PROGRAM_COUNTER_NR,
 SPECIAL_PROGRAM_FEATURE_TYPE_CDE,
 ADMIN_FUND_CDE,
 PRODUCT_ID,
 COMPANY_CDE,
 PT1_KIND_CDE,
 PRODUCT_TIER_CDE,
 DIM_FUND_NATURAL_KEY_HASH_UUID,
 SOURCE_SPECIAL_PROGRAM_TYPE_CDE,
 PROGRAM_BUSINESS_START_DT,
 PROGRAM_BUSINESS_END_DT,
 PROGRAM_MODE_CDE,
 SOURCE_PROGRAM_MODE_CDE,
 PROGRAM_MODE_NR,
 PROGRAM_DURATION_NR,
 PROGRAM_AMT,
 PROGRAM_CALCULATION_TYPE_CDE,
 SOURCE_PROGRAM_CALCULATION_TYPE_CDE,
 PROGRAM_AMT_TYPE_CDE,
 SOURCE_PROGRAM_AMT_TYPE_CDE,
 DETAIL_AMT,
 DETAIL_PCT,
 PROGRAM_INTEREST_RT,
 NEXT_RUN_DT,
 FIRST_PAYMENT_DT,
 FIRST_PAYMENT_YEAR_NR,
 PRIOR_MRD_AMT,
 PRIOR_MRD_AMT_TYPE_CDE,
 SOURCE_PRIOR_MRD_AMT_TYPE_CDE,
 EXCLUSION_AMT,
 BEGIN_DT,
 BEGIN_DTM,
 ROW_PROCESS_DTM,
 CHECK_SUM,
 END_DT,
 END_DTM,
 RESTRICTED_ROW_IND,
 CURRENT_ROW_IND,
 LOGICAL_DELETE_IND,
 SOURCE_SYSTEM_ID,
 AUDIT_ID,
 UPDATE_AUDIT_ID,
 SOURCE_DELETE_IND)
SELECT
        SRC.DIM_AGREEMENT_SPECIAL_PROGRAM_NATURAL_KEY_HASH_UUID,
        SRC.DIM_AGREEMENT_NATURAL_KEY_HASH_UUID,
        SRC.SPECIAL_PROGRAM_KEY_ID,
        SRC.AGREEMENT_NR_PFX,
        SRC.AGREEMENT_NR,
        SRC.AGREEMENT_NR_SFX,
        SRC.AGREEMENT_SOURCE_CDE,
        SRC.AGREEMENT_TYPE_CDE,
        SRC.SPECIAL_PROGRAM_TYPE_CDE,
        SRC.SPECIAL_PROGRAM_COUNTER_NR,
        SRC.SPECIAL_PROGRAM_FEATURE_TYPE_CDE,
        SRC.ADMIN_FUND_CDE,
        SRC.PRODUCT_ID,
        SRC.COMPANY_CDE,
        SRC.PT1_KIND_CDE,
        SRC.PRODUCT_TIER_CDE,
        SRC.DIM_FUND_NATURAL_KEY_HASH_UUID,
        SRC.SOURCE_SPECIAL_PROGRAM_TYPE_CDE,
        SRC.PROGRAM_BUSINESS_START_DT,
        SRC.PROGRAM_BUSINESS_END_DT,
        SRC.PROGRAM_MODE_CDE,
        SRC.SOURCE_PROGRAM_MODE_CDE,
        SRC.PROGRAM_MODE_NR,
        SRC.PROGRAM_DURATION_NR,
        SRC.PROGRAM_AMT,
        SRC.PROGRAM_CALCULATION_TYPE_CDE,
        SRC.SOURCE_PROGRAM_CALCULATION_TYPE_CDE,
        SRC.PROGRAM_AMT_TYPE_CDE,
        SRC.SOURCE_PROGRAM_AMT_TYPE_CDE,
        SRC.DETAIL_AMT,
        SRC.DETAIL_PCT,
        SRC.PROGRAM_INTEREST_RT,
        SRC.NEXT_RUN_DT,
        SRC.FIRST_PAYMENT_DT,
        SRC.FIRST_PAYMENT_YEAR_NR,
        SRC.PRIOR_MRD_AMT,
        SRC.PRIOR_MRD_AMT_TYPE_CDE,
        SRC.SOURCE_PRIOR_MRD_AMT_TYPE_CDE,
        SRC.EXCLUSION_AMT,
        SRC.BEGIN_DT,
        SRC.BEGIN_DTM,
        CURRENT_TIMESTAMP(6)        AS ROW_PROCESS_DTM,
        SRC.CHECK_SUM,
        SRC.END_DT,
        SRC.END_DTM,
        SRC.RESTRICTED_ROW_IND,
        SRC.CURRENT_ROW_IND,
        SRC.LOGICAL_DELETE_IND,
        SRC.SOURCE_SYSTEM_ID,
        SRC.AUDIT_ID,
        SRC.UPDATE_AUDIT_ID,
        SRC.SOURCE_DELETE_IND
from edw_staging.aifrps_dim_agreement_special_program_pre_work SRC
         LEFT JOIN {{target_schema}}.dim_agreement_special_program TGT
ON SRC.dim_agreement_special_program_natural_key_hash_uuid = TGT.dim_agreement_special_program_natural_key_hash_uuid
    AND SRC.dim_agreement_natural_key_hash_uuid = TGT.dim_agreement_natural_key_hash_uuid
    AND TGT.CURRENT_ROW_IND = TRUE
WHERE
--handle when there isn't a current record in target but there are historical records and a delta coming through
    (TGT.ROW_SID IS NULL
        AND (SRC.dim_agreement_natural_key_hash_uuid,SRC.dim_agreement_special_program_natural_key_hash_uuid) IN
  (select DISTINCT dim_agreement_natural_key_hash_uuid,dim_agreement_special_program_natural_key_hash_uuid FROM {{target_schema}}.dim_agreement_special_program) )
--handle when there is a current target record and either the check_sum has changed or record is being logically deleted.
   OR
    (TGT.ROW_SID IS NOT NULL
--CHECKSUM CHANGED
  AND (TGT.CHECK_SUM <> SRC.CHECK_SUM)
    );


/*
 ************ Calculating the Deleted Records *******************
 */


/* EDW_WORK.aifrps_dim_agreement_special_program WORK TABLE - Insert the updated TGT records from dim_agreement_special_program table
 *
 * THIS SCRIPT FINDS RECORDS WHERE THE RECORD IS MISSING IN PREWORK TABLE BUT PRESENT IN Dim_Agreement_Special_Program.
 * THE CURRENT RECORD IN THE TARGET WILL BE ENDED SINCE THE SOURCE RECORD WILL BE CREATED AND INSERTED IN THE NEXT STEP.
 *
 */

INSERT INTO EDW_WORK.aifrps_dim_agreement_special_program
(DIM_AGREEMENT_SPECIAL_PROGRAM_NATURAL_KEY_HASH_UUID,
 DIM_AGREEMENT_NATURAL_KEY_HASH_UUID,
 SPECIAL_PROGRAM_KEY_ID,
 AGREEMENT_NR_PFX,
 AGREEMENT_NR,
 AGREEMENT_NR_SFX,
 AGREEMENT_SOURCE_CDE,
 AGREEMENT_TYPE_CDE,
 SPECIAL_PROGRAM_TYPE_CDE,
 SPECIAL_PROGRAM_COUNTER_NR,
 SPECIAL_PROGRAM_FEATURE_TYPE_CDE,
 ADMIN_FUND_CDE,
 PRODUCT_ID,
 COMPANY_CDE,
 PT1_KIND_CDE,
 PRODUCT_TIER_CDE,
 DIM_FUND_NATURAL_KEY_HASH_UUID,
 SOURCE_SPECIAL_PROGRAM_TYPE_CDE,
 PROGRAM_BUSINESS_START_DT,
 PROGRAM_BUSINESS_END_DT,
 PROGRAM_MODE_CDE,
 SOURCE_PROGRAM_MODE_CDE,
 PROGRAM_MODE_NR,
 PROGRAM_DURATION_NR,
 PROGRAM_AMT,
 PROGRAM_CALCULATION_TYPE_CDE,
 SOURCE_PROGRAM_CALCULATION_TYPE_CDE,
 PROGRAM_AMT_TYPE_CDE,
 SOURCE_PROGRAM_AMT_TYPE_CDE,
 DETAIL_AMT,
 DETAIL_PCT,
 PROGRAM_INTEREST_RT,
 NEXT_RUN_DT,
 FIRST_PAYMENT_DT,
 FIRST_PAYMENT_YEAR_NR,
 PRIOR_MRD_AMT,
 PRIOR_MRD_AMT_TYPE_CDE,
 SOURCE_PRIOR_MRD_AMT_TYPE_CDE,
 EXCLUSION_AMT,
 BEGIN_DT,
 BEGIN_DTM,
 ROW_PROCESS_DTM,
 CHECK_SUM,
 END_DT,
 END_DTM,
 RESTRICTED_ROW_IND,
 CURRENT_ROW_IND,
 LOGICAL_DELETE_IND,
 SOURCE_SYSTEM_ID,
 AUDIT_ID,
 UPDATE_AUDIT_ID,
 SOURCE_DELETE_IND)
select  TGT.DIM_AGREEMENT_SPECIAL_PROGRAM_NATURAL_KEY_HASH_UUID,
        TGT.DIM_AGREEMENT_NATURAL_KEY_HASH_UUID,
        TGT.SPECIAL_PROGRAM_KEY_ID,
        TGT.AGREEMENT_NR_PFX,
        TGT.AGREEMENT_NR,
        TGT.AGREEMENT_NR_SFX,
        TGT.AGREEMENT_SOURCE_CDE,
        TGT.AGREEMENT_TYPE_CDE,
        TGT.SPECIAL_PROGRAM_TYPE_CDE,
        TGT.SPECIAL_PROGRAM_COUNTER_NR,
        TGT.SPECIAL_PROGRAM_FEATURE_TYPE_CDE,
        TGT.ADMIN_FUND_CDE,
        TGT.PRODUCT_ID,
        TGT.COMPANY_CDE,
        TGT.PT1_KIND_CDE,
        TGT.PRODUCT_TIER_CDE,
        TGT.DIM_FUND_NATURAL_KEY_HASH_UUID,
        TGT.SOURCE_SPECIAL_PROGRAM_TYPE_CDE,
        TGT.PROGRAM_BUSINESS_START_DT,
        TGT.PROGRAM_BUSINESS_END_DT,
        TGT.PROGRAM_MODE_CDE,
        TGT.SOURCE_PROGRAM_MODE_CDE,
        TGT.PROGRAM_MODE_NR,
        TGT.PROGRAM_DURATION_NR,
        TGT.PROGRAM_AMT,
        TGT.PROGRAM_CALCULATION_TYPE_CDE,
        TGT.SOURCE_PROGRAM_CALCULATION_TYPE_CDE,
        TGT.PROGRAM_AMT_TYPE_CDE,
        TGT.SOURCE_PROGRAM_AMT_TYPE_CDE,
        TGT.DETAIL_AMT,
        TGT.DETAIL_PCT,
        TGT.PROGRAM_INTEREST_RT,
        TGT.NEXT_RUN_DT,
        TGT.FIRST_PAYMENT_DT,
        TGT.FIRST_PAYMENT_YEAR_NR,
        TGT.PRIOR_MRD_AMT,
        TGT.PRIOR_MRD_AMT_TYPE_CDE,
        TGT.SOURCE_PRIOR_MRD_AMT_TYPE_CDE,
        TGT.EXCLUSION_AMT,
        TGT.BEGIN_DT,
        TGT.BEGIN_DTM,
        CURRENT_TIMESTAMP(6)                                    AS ROW_PROCESS_DTM,
        TGT.CHECK_SUM,
        (CNT.CNT_CYCLE_DATE - INTERVAL '1' DAY)::DATE           AS END_DT,
        (CNT.CNT_CYCLE_DATE - INTERVAL '1' SECOND)::TIMESTAMP   AS END_DTM,
        TGT.RESTRICTED_ROW_IND,
        FALSE                                                   AS CURRENT_ROW_IND,
        TGT.LOGICAL_DELETE_IND,
        TGT.SOURCE_SYSTEM_ID,
        TGT.AUDIT_ID,
        CNT.AUDIT_ID                                            AS UPDATE_AUDIT_ID,
        TGT.SOURCE_DELETE_IND
FROM {{target_schema}}.dim_agreement_special_program TGT
	LEFT JOIN
	        (SELECT TO_DATE(TO_CHAR(CYCLE_DATE), 'YYYYMMDD') AS CNT_CYCLE_DATE, AUDIT_ID
                FROM EDW_STAGING.AIF_RPS_EDW_CTRT_DELTA_COUNT) CNT
                ON 1 = 1
    LEFT JOIN
    EDW_STAGING.aifrps_dim_agreement_special_program_pre_work PREWORK
    ON      TGT.dim_agreement_special_program_NATURAL_KEY_HASH_UUID = PREWORK.dim_agreement_special_program_NATURAL_KEY_HASH_UUID
WHERE
--RECORDS NOT PRESENT IN PRE-WORK TABLE
    TGT.CURRENT_ROW_IND     = TRUE
  AND TGT.SOURCE_DELETE_IND = FALSE
  AND TGT.SOURCE_SYSTEM_ID IN ('72','266')
  AND PREWORK.dim_agreement_special_program_natural_key_hash_uuid IS NULL
;


/* EDW_WORK.AIFRPS_dim_agreement_special_program WORK TABLE - Create and Insert the deleted SRC records using dim_agreement_special_program and PreWork table
 *
 * THIS SCRIPT FINDS RECORDS WHERE THE RECORD IS MISSING IN PREWORK TABLE BUT PRESENT IN dim_agreement_special_program..
 * THE CURRENT RECORD MISSING IN THE SOURCE WILL BE INSERTED IN THE WORK TABLE AS SOURCE_DELETE_IND=TRUE.
 *
 */

INSERT INTO EDW_WORK.aifrps_dim_agreement_special_program
(DIM_AGREEMENT_SPECIAL_PROGRAM_NATURAL_KEY_HASH_UUID,
 DIM_AGREEMENT_NATURAL_KEY_HASH_UUID,
 SPECIAL_PROGRAM_KEY_ID,
 AGREEMENT_NR_PFX,
 AGREEMENT_NR,
 AGREEMENT_NR_SFX,
 AGREEMENT_SOURCE_CDE,
 AGREEMENT_TYPE_CDE,
 SPECIAL_PROGRAM_TYPE_CDE,
 SPECIAL_PROGRAM_COUNTER_NR,
 SPECIAL_PROGRAM_FEATURE_TYPE_CDE,
 ADMIN_FUND_CDE,
 PRODUCT_ID,
 COMPANY_CDE,
 PT1_KIND_CDE,
 PRODUCT_TIER_CDE,
 DIM_FUND_NATURAL_KEY_HASH_UUID,
 SOURCE_SPECIAL_PROGRAM_TYPE_CDE,
 PROGRAM_BUSINESS_START_DT,
 PROGRAM_BUSINESS_END_DT,
 PROGRAM_MODE_CDE,
 SOURCE_PROGRAM_MODE_CDE,
 PROGRAM_MODE_NR,
 PROGRAM_DURATION_NR,
 PROGRAM_AMT,
 PROGRAM_CALCULATION_TYPE_CDE,
 SOURCE_PROGRAM_CALCULATION_TYPE_CDE,
 PROGRAM_AMT_TYPE_CDE,
 SOURCE_PROGRAM_AMT_TYPE_CDE,
 DETAIL_AMT,
 DETAIL_PCT,
 PROGRAM_INTEREST_RT,
 NEXT_RUN_DT,
 FIRST_PAYMENT_DT,
 FIRST_PAYMENT_YEAR_NR,
 PRIOR_MRD_AMT,
 PRIOR_MRD_AMT_TYPE_CDE,
 SOURCE_PRIOR_MRD_AMT_TYPE_CDE,
 EXCLUSION_AMT,
 BEGIN_DT,
 BEGIN_DTM,
 ROW_PROCESS_DTM,
 CHECK_SUM,
 END_DT,
 END_DTM,
 RESTRICTED_ROW_IND,
 CURRENT_ROW_IND,
 LOGICAL_DELETE_IND,
 SOURCE_SYSTEM_ID,
 AUDIT_ID,
 UPDATE_AUDIT_ID,
 SOURCE_DELETE_IND)
select
        TGT.DIM_AGREEMENT_SPECIAL_PROGRAM_NATURAL_KEY_HASH_UUID,
        TGT.DIM_AGREEMENT_NATURAL_KEY_HASH_UUID,
        TGT.SPECIAL_PROGRAM_KEY_ID,
        TGT.AGREEMENT_NR_PFX,
        TGT.AGREEMENT_NR,
        TGT.AGREEMENT_NR_SFX,
        TGT.AGREEMENT_SOURCE_CDE,
        TGT.AGREEMENT_TYPE_CDE,
        TGT.SPECIAL_PROGRAM_TYPE_CDE,
        TGT.SPECIAL_PROGRAM_COUNTER_NR,
        TGT.SPECIAL_PROGRAM_FEATURE_TYPE_CDE,
        TGT.ADMIN_FUND_CDE,
        TGT.PRODUCT_ID,
        TGT.COMPANY_CDE,
        TGT.PT1_KIND_CDE,
        TGT.PRODUCT_TIER_CDE,
        TGT.DIM_FUND_NATURAL_KEY_HASH_UUID,
        TGT.SOURCE_SPECIAL_PROGRAM_TYPE_CDE,
        TGT.PROGRAM_BUSINESS_START_DT,
        TGT.PROGRAM_BUSINESS_END_DT,
        TGT.PROGRAM_MODE_CDE,
        TGT.SOURCE_PROGRAM_MODE_CDE,
        TGT.PROGRAM_MODE_NR,
        TGT.PROGRAM_DURATION_NR,
        TGT.PROGRAM_AMT,
        TGT.PROGRAM_CALCULATION_TYPE_CDE,
        TGT.SOURCE_PROGRAM_CALCULATION_TYPE_CDE,
        TGT.PROGRAM_AMT_TYPE_CDE,
        TGT.SOURCE_PROGRAM_AMT_TYPE_CDE,
        TGT.DETAIL_AMT,
        TGT.DETAIL_PCT,
        TGT.PROGRAM_INTEREST_RT,
        TGT.NEXT_RUN_DT,
        TGT.FIRST_PAYMENT_DT,
        TGT.FIRST_PAYMENT_YEAR_NR,
        TGT.PRIOR_MRD_AMT,
        TGT.PRIOR_MRD_AMT_TYPE_CDE,
        TGT.SOURCE_PRIOR_MRD_AMT_TYPE_CDE,
        TGT.EXCLUSION_AMT,
        CNT.CNT_CYCLE_DATE::DATE                                AS BEGIN_DT,
        CNT.CNT_CYCLE_DATE :: TIMESTAMP                         AS BEGIN_DTM,
        CURRENT_TIMESTAMP(6)                                    AS ROW_PROCESS_DTM,
        UUID_GEN(TRUE, TO_CHAR(TGT.CHECK_SUM))::UUID            AS CHECK_SUM,
        '9999-12-31'::DATE                                      AS END_DT,
        '9999-12-31'::TIMESTAMP                                 AS END_DTM,
        FALSE                                                   AS RESTRICTED_ROW_IND,
        TRUE                                                    AS CURRENT_ROW_IND,
        FALSE                                                   AS LOGICAL_DELETE_IND,
        72                                                      AS SOURCE_SYSTEM_ID,
        :audit_id,
        :audit_id                                               AS UPDATE_AUDIT_ID,
        TRUE                                                    AS SOURCE_DELETE_IND --Making it as True.
from {{target_schema}}.dim_agreement_special_program TGT
	LEFT JOIN
		    (SELECT TO_DATE(TO_CHAR(CYCLE_DATE), 'YYYYMMDD') AS CNT_CYCLE_DATE, AUDIT_ID
                FROM EDW_STAGING.AIF_RPS_EDW_CTRT_DELTA_COUNT) CNT
                ON 1 = 1
    LEFT JOIN
    EDW_STAGING.AIFRPS_dim_agreement_special_program_PRE_WORK PREWORK
    ON      TGT.dim_agreement_special_program_NATURAL_KEY_HASH_UUID = PREWORK.dim_agreement_special_program_NATURAL_KEY_HASH_UUID
        AND TGT.dim_agreement_natural_key_hash_uuid = PREWORK.dim_agreement_natural_key_hash_uuid
WHERE TGT.CURRENT_ROW_IND   = TRUE
  AND TGT.SOURCE_DELETE_IND = FALSE
  AND TGT.SOURCE_SYSTEM_ID IN ('72','266')
  AND PREWORK.dim_agreement_special_program_natural_key_hash_uuid IS NULL
;

select analyze_statistics('edw_work.aifrps_dim_agreement_special_program');