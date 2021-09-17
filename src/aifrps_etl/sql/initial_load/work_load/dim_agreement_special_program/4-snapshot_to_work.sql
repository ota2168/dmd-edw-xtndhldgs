/* TRUNCATE PRE-WORK TABLE */
TRUNCATE TABLE EDW_STAGING.AIFRPS_DIM_AGMT_SPCL_PRGM_INIT_LOAD_PREWORK;

INSERT INTO EDW_STAGING.AIFRPS_DIM_AGMT_SPCL_PRGM_INIT_LOAD_PREWORK
(
                DIM_AGREEMENT_SPECIAL_PROGRAM_NATURAL_KEY_HASH_UUID,
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
                SOURCE_DELETE_IND
)
SELECT
               UUID_GEN
               (
                       CLEAN_STRING('RPS'),
                       CLEAN_STRING('IPA'),
                       UDF_ISNUM_LPAD(HLDG_KEY_PFX, 20, '0', TRUE),
                       LPAD(HLDG_KEY::VARCHAR, 20, '0'),
                       UDF_ISNUM_LPAD(HLDG_KEY_SFX, 20, '0', TRUE),
                       CLEAN_STRING(SPCL_PGM_TYP),
                       CLEAN_STRING(SPCL_PGM_CNTR::VARCHAR)
               )  ::UUID
                                                    AS DIM_AGREEMENT_SPECIAL_PROGRAM_NATURAL_KEY_HASH_UUID,
               UUID_GEN(
                       CLEAN_STRING('RPS'),
                       CLEAN_STRING('IPA'),
                       UDF_ISNUM_LPAD(HLDG_KEY_PFX, 20, '0', TRUE),
                       LPAD(HLDG_KEY::VARCHAR, 20, '0'),
                       UDF_ISNUM_LPAD(HLDG_KEY_SFX, 20, '0', TRUE)
                       )::UUID
                                                     AS DIM_AGREEMENT_NATURAL_KEY_HASH_UUID,
               PREHASH_VALUE(
                    CLEAN_STRING(SRC_SPCL_PGM_TYP),
                    CLEAN_STRING(SPCL_PGM_CNTR::varchar)
                            )                        AS SPECIAL_PROGRAM_KEY_ID,
               HLDG_KEY_PFX                          AS AGREEMENT_NR_PFX,
               HLDG_KEY                              AS AGREEMENT_NR,
               HLDG_KEY_SFX                          AS AGREEMENT_NR_SFX,
               CLEAN_STRING(CARR_ADMIN_SYS_CD)		 AS AGREEMENT_SOURCE_CDE,
               'Ipa'                                 AS AGREEMENT_TYPE_CDE,
               SPCL_PGM_TYP                          AS SPECIAL_PROGRAM_TYPE_CDE,
               SPCL_PGM_CNTR                         AS SPECIAL_PROGRAM_COUNTER_NR,
               ' '                                   AS SPECIAL_PROGRAM_FEATURE_TYPE_CDE,
               ADMIN_FND_NR                          AS ADMIN_FUND_CDE,
               NULL                                  AS PRODUCT_ID,
               NULL                                  AS COMPANY_CDE,
               NULL                                  AS PT1_KIND_CDE,
               NULL                                  AS PRODUCT_TIER_CDE,
               UUID_GEN(
                        CLEAN_STRING(FND_ID::VARCHAR)
                       )::UUID
                                                     AS DIM_FUND_NATURAL_KEY_HASH_UUID,
               SRC_SPCL_PGM_TYP                      AS SOURCE_SPECIAL_PROGRAM_TYPE_CDE,
               PGM_BUSS_STRT_DT                      AS PROGRAM_BUSINESS_START_DT,
               PGM_BUSS_END_DT                       AS PROGRAM_BUSINESS_END_DT,
               PGM_MODE_CD                           AS PROGRAM_MODE_CDE,
               SRC_PGM_MODE_CD                       AS SOURCE_PROGRAM_MODE_CDE,
               PGM_MODE_NR                           AS PROGRAM_MODE_NR,
               PGM_DUR                               AS PROGRAM_DURATION_NR,
               PGM_AMT                               AS PROGRAM_AMT,
               PGM_CALC_TYP                          AS PROGRAM_CALCULATION_TYPE_CDE,
               SRC_PGM_CALC_TYP                      AS SOURCE_PROGRAM_CALCULATION_TYPE_CDE,
               PGM_AMT_TYP_CD                        AS PROGRAM_AMT_TYPE_CDE,
               SRC_PGM_AMT_TYP_CD                    AS SOURCE_PROGRAM_AMT_TYPE_CDE,
               DETAIL_AMT                            AS DETAIL_AMT,
               DETAIL_PCT                            AS DETAIL_PCT,
               PGM_INT_RT                            AS PROGRAM_INTEREST_RT,
               NEXT_RUN_DT                           AS NEXT_RUN_DT,
               FIRST_PYMT_DT                         AS FIRST_PAYMENT_DT,
               FIRST_PYMT_YR                         AS FIRST_PAYMENT_YEAR_NR,
               PRIOR_MRD_AMT                         AS PRIOR_MRD_AMT,
               PRIOR_MRD_AMT_TYP_CD                  AS PRIOR_MRD_AMT_TYPE_CDE,
               SRC_PRIOR_MRD_AMT_TYP_CD              AS SOURCE_PRIOR_MRD_AMT_TYPE_CDE,
               EXCLUSION_AMT                         AS EXCLUSION_AMT,
               AGMT_SPCL_PGM_FR_DT                   AS BEGIN_DT,
               AGMT_SPCL_PGM_FR_DT::TIMESTAMP        AS BEGIN_DTM,
               CURRENT_TIMESTAMP(6)                  AS ROW_PROCESS_DTM,
               UUID_GEN(
                        SRC_DEL_IND::Boolean,
                        SRC_SPCL_PGM_TYP,
                        PGM_BUSS_STRT_DT,
                        PGM_BUSS_END_DT,
                        PGM_MODE_CD,
                        SRC_PGM_MODE_CD,
                        PGM_MODE_NR
                       )::UUID                       AS CHECK_SUM,
               AGMT_SPCL_PGM_TO_DT                   AS END_DT,
               AGMT_SPCL_PGM_TO_DT::TIMESTAMP        AS END_DTM,
               FALSE                                 AS RESTRICTED_ROW_IND,
               CASE
                   WHEN CURR_IND = 'N' THEN FALSE
                        ELSE TRUE
               END                                   AS CURRENT_ROW_IND,
               FALSE                                 AS LOGICAL_DELETE_IND,
               266                                   AS SOURCE_SYSTEM_ID,
               RUN_ID                                AS AUDIT_ID,
               UPDT_RUN_ID                           AS UPDATE_AUDIT_ID,
               CASE
                   WHEN SRC_DEL_IND = 'N' THEN FALSE
                        ELSE TRUE
               END                                   AS SOURCE_DELETE_IND
FROM EDW_STAGING.AIFRPS_DIM_AGMT_SPCL_PRGM_VW
WHERE SRC_SYS_ID = 72;