/*
		FILENAME:               AIFRPS_DIM_FINANCIAL_TRANSACTION.SQL
		AUTHOR:                 CP45213 / MM23717
		SUBJECT AREA :          AGREEMENT
		SOURCE:                 AIF-RPS
		TERADATA SOURCE CODE:   72
		DESCRIPTION:            DIM_FINANCIAL_TRANSACTION TABLE POPULATION FOR TRANSACTIONS
		JIRA:
		CREATE DATE:            2021-07-23 

		===============================================================================================================
		VERSION/JIRA STORY#			CREATED BY          LAST_MODIFIED_DATE		DESCRIPTION
		---------------------------------------------------------------------------------------------------------------

		---------------------------------------------------------------------------------------------------------------
*/

/* TRUNCATE STAGING PRE WORK TABLE */
TRUNCATE TABLE EDW_STAGING.AIFRPS_DIM_FINANCIAL_TRANSACTION_PRE_WORK;

/*TRUNCATE WORK TABLE */
TRUNCATE TABLE EDW_WORK.AIFRPS_DIM_FINANCIAL_TRANSACTION;


/*CREATE TEMP TABLE FOR SOURCE_DATA_TRANSLATOR*/
CREATE LOCAL TEMPORARY TABLE SRC_DATA_TRNSLT_TEMP_RPS ON
    COMMIT PRESERVE ROWS AS
SELECT *
FROM EDW_REF.SRC_DATA_TRNSLT
WHERE UPPER(SRC_CDE) IN ('TERSUN', 'ANN', 'RPS');


/*CREATE TEMP TABLE FOR PRODUCT_TRANSLATOR*/
CREATE LOCAL TEMPORARY TABLE PRODUCT_TRANSLATOR_TEMP_RPS ON
    COMMIT PRESERVE ROWS AS
SELECT DISTINCT SRC.PLAN_CODE AS TXN_PLAN_CODE, CTRT.AIFCOW_PLAN_CODE AS CTRT_PLAN_CODE, PT.*
FROM EDW_REF.PRODUCT_TRANSLATOR PT
         JOIN
     EDW_STAGING.AIF_RPS_EDW_FINTXN_DELTA SRC
         JOIN EDW_STAGING.AIF_RPS_EDW_CTRT_FULL_DEDUP CTRT
              ON CTRT.AIFCOW_POLICY_ID = SRC.POLICY_ID
              ON ADMN_SYS_GRP_CDE = '02'
                  AND UPPER(TRIM(ADMN_SYS_CDE)) = UPPER(TRIM(SRC.CARR_ADMIN_SYS_CD))
                  AND
                 UPPER(TRIM(PT.KND_MIN_CDE)) <= COALESCE(UPPER(TRIM(SRC.PLAN_CODE)), UPPER(TRIM(CTRT.AIFCOW_PLAN_CODE)))
                  AND
                 UPPER(TRIM(PT.KND_MAX_CDE)) >= COALESCE(UPPER(TRIM(SRC.PLAN_CODE)), UPPER(TRIM(CTRT.AIFCOW_PLAN_CODE)))
                  AND PT.BSIS_MIN_CDE <= '00' AND PT.BSIS_MAX_CDE >= '00'
                  AND CLEAN_STRING(UPPER(PT.RATE_MIN_CDE)) <= '0000' AND CLEAN_STRING(UPPER(PT.RATE_MAX_CDE)) >= '0000'
;


-- STEP 1 :
-- INSERT SCRIPT FOR PRE WORK TABLE -ALL RECORDS FROM STG
INSERT INTO EDW_STAGING.AIFRPS_DIM_FINANCIAL_TRANSACTION_PRE_WORK


(DIM_FINANCIAL_TRANSACTION_NATURAL_KEY_HASH_UUID,
 FINANCIAL_TRANSACTION_UNIQUE_ID,
 REF_FINANCIAL_TRANSACTION_SOURCE_NATURAL_KEY_HASH_UUID,
 REF_FINANCIAL_TRANSACTION_TYPE_NATURAL_KEY_HASH_UUID,
 PAY_GROUP_NR_TXT,
 CHECK_FORM_ID,
 TRANSACTION_DT,
 CHECK_STATUS_CDE,
 ACCOUNT_NR_TXT,
 TAX_REPORTING_CDE,
 ORIGINAL_CHECK_NR,
 DISTRIBUTION_CDE,
 SOURCE_PAYEE_UNIQUE_ID,
 CLEAR_DT,
 CLEAR_REFERENCE_NR_TXT,
 REVERSAL_DT,
 BEGIN_DT,
 BEGIN_DTM,
 ROW_PROCESS_DTM,
 AUDIT_ID,
 LOGICAL_DELETE_IND,
 CHECK_SUM,
 CURRENT_ROW_IND,
 END_DT,
 END_DTM,
 SOURCE_SYSTEM_ID,
 RESTRICTED_ROW_IND,
 UPDATE_AUDIT_ID,
 SOURCE_DELETE_IND,
 SOURCE_TRANSACTION_KEY_TXT,
 ROUTING_NR_TXT,
 PAYMENT_METHOD_CDE,
 PREVIOUS_SOURCE_TRANSACTION_KEY_TXT,
 EFFECTIVE_DT,
 SYSTEM_DT,
 TRANSACTION_CDE,
 SOURCE_TRANSACTION_CDE,
 TRANSACTION_REVERSAL_CDE,
 ADMIN_FUND_CDE,
 PRODUCT_ID,
 COMPANY_CDE,
 SOURCE_COMPANY_CDE,
 PT1_KIND_CDE,
 PRODUCT_TIER_CDE,
 FUND_TYPE_CDE,
 SOURCE_FUND_TYPE_CDE,
 COVERAGE_TYPE_CDE,
 COVERAGE_OCCURANCE_NR,
 TRANSACTION_SOURCE_ID,
 TRANSACTION_MEMO_CDE,
 ROLLOVER_CDE,
 SOURCE_ROLLOVER_CDE,
 GMIB_STATUS_CDE,
 ADMINISTRATION_CDE,
 SOURCE_ADMINISTRATION_CDE,
 DISBURSEMENT_TRANSACTION_NR_TXT,
 REPLACEMENT_TRANSACTION_NR_TXT,
 TRANSACTION_DESC,
 SOURCE_TRANSACTION_DESC,
 TRANSACTION_REPORTING_DESC,
 TRANSACTION_REPORTING_DETAIL_DESC)


WITH /*+ENABLE_WITH_CLAUSE_MATERIALIZATION*/
    FINTXN_SOURCE_HASH AS
        (
            SELECT SRC.POLICY_ID,
                   CLEAN_STRING(SDT_AGMT_SRC_CD.TRNSLT_FLD_VAL)                       AS AGREEMENT_SOURCE_CDE,
                   'Ipa'                                                              AS AGREEMENT_TYPE_CDE,
                   UDF_AIF_HLDG_KEY_FORMAT(SRC.POLICY_ID, 'PFX')                      AS AGREEMENT_NR_PFX,
                   UDF_AIF_HLDG_KEY_FORMAT(SRC.POLICY_ID, 'KEY')                      AS AGREEMENT_NR,
                   UDF_AIF_HLDG_KEY_FORMAT(SRC.POLICY_ID, 'SFX')                      AS AGREEMENT_NR_SFX,
                   CLEAN_STRING(TRIM(FIN_SDT_SRC.TRNSLT_FLD_VAL))                     AS FINANCIAL_TRANSCATION_SOURCE,
                   CLEAN_STRING(TRIM(FIN_SDT_TYPE.TRNSLT_FLD_VAL))                    AS FINANCIAL_TRANSCATION_TYPE,
                   COMPANY_CODE                                                       AS SOURCE_COMPANY_CDE,
                   COALESCE(SRC.PLAN_CODE, CTRT.AIFCOW_PLAN_CODE)                     AS PT1_KIND_CDE,
                   PDT1.PROD_ID                                                       AS PRODUCT_ID,
                   FUND_ID                                                            AS ADMIN_FUND_CDE,
                   AIFFI_INTERNAL_TXN_ID::VARCHAR                                     AS SOURCE_TRANSACTION_KEY_TXT,
                   AIFFI_DSTRBTR_TXN_ID::VARCHAR                                      AS DISBURSEMENT_TRANSACTION_NR_TXT,
                   TRIM(AIFFI_FUND_TYPE)                                              AS SOURCE_FUND_TYPE_CDE,
                   PAYMENT_DURATION                                                   AS TRANSACTION_DURATION_NR,
                   TRIM(COALESCE(AIFFI_FAV_CODE, '00'))                               AS PRODUCT_TIER_CDE,
                   AIFFI_IRA_TAX_YEAR                                                 AS DEPOSITS_TAX_YEAR_NR,
                   CASE WHEN UPPER(TRIM(TXN_REVERSE_IND)) = 'R' THEN 'Y' ELSE 'N' END AS TRANSACTION_REVERSAL_CDE,
                   CASE
                       WHEN UPPER(TRIM(TXN_REVERSE_IND)) = 'R'
                           THEN ISDATE(TO_CHAR(TXN_CYCLE_DATE))
                       ELSE NULL END                                                  AS REVERSAL_DT,
                   SRC.SRC_CD                                                         AS TRANSACTION_SOURCE_ID,
                   SRC.MEMO_CD                                                        AS TRANSACTION_MEMO_CDE,
				   SRC.TRAN_CD as 														TRAN_CD,
                   TRIM(TXN_TYPE)                                                     AS SOURCE_TRANSACTION_CDE,
                   AIFFI_DEBIT_CREDIT_IND                                             AS SOURCE_CREDIT_DEBIT_TYPE_CDE,
                   ISDATE(TO_CHAR(TXN_CYCLE_DATE))                                    AS TRANSACTION_DT,
                   --TXN_CYCLE_DATE                                                   AS TRANSACTION_DT,
                   ISDATE(TO_CHAR(TXN_EFF_DATE))                                      AS EFFECTIVE_DT,
                   --TXN_EFF_DATE                                                     AS EFFECTIVE_DT,
                   TRIM(SDT.TRNSLT_FLD_VAL)                                           AS COMPANY_CDE,
                   SDT1.TRNSLT_FLD_VAL                                                AS FUND_TYPE_CDE,
                   TRIM(NVL2(CTC.TRANSACTION_CDE,
                             CTC.ALTERNATE_ADMIN_TRANSACTION_DESC,
                             CTC1.ALTERNATE_ADMIN_TRANSACTION_DESC))                  AS ALTERNATE_ADMIN_TRANSACTION_DESC,
                   TRIM(NVL2(CTC.TRANSACTION_CDE, CTC.ADMIN_TRANSACTION_DESC,
                             CTC1.ADMIN_TRANSACTION_DESC))                            AS ADMIN_TRANSACTION_DESC,
                   TRIM(NVL2(CTC.TRANSACTION_CDE,
                             CTC.TRANSACTION_REPORTING_DESC,
                             CTC1.TRANSACTION_REPORTING_DESC))                        AS TRANSACTION_REPORTING_DESC,
                   TRIM(NVL2(CTC.TRANSACTION_CDE,
                             CTC.TRANSACTION_REPORTING_DETAIL_DESC,
                             CTC1.TRANSACTION_REPORTING_DETAIL_DESC))                 AS TRANSACTION_REPORTING_DETAIL_DESC,
                   TRIM(COALESCE(CTC.TRANSACTION_CDE, CTC1.TRANSACTION_CDE))          AS TRANSACTION_CDE,
					CASE WHEN TRIM(AIFFI_DEBIT_CREDIT_IND)='T' THEN 'C'
						WHEN TRIM(AIFFI_DEBIT_CREDIT_IND)='F' THEN 'D'
						ELSE TRIM(NVL2(CTC.TRANSACTION_CDE, CTC.DEBIT_CREDIT_CDE,
                             CTC1.DEBIT_CREDIT_CDE)) END AS                           CREDIT_DEBIT_TYPE_CDE, /*applicable only for FTA*/
                   ISDATE(TO_CHAR(CTRT_COUNT.CYCLE_DATE))                             AS SYSTEM_DT,
                   TXN_REVERSE_IND,
                   TXN_GROSS_AMT,
                   AIFFI_TOTAL_TXN_AMT,
				   AIFFI_STATE_TAX,
                   AIFFI_FED_TAX_WITHHOLDING,
                   AIFFI_STATE_TAX_WITHHOLDING,
                   AIFFI_SURRENDER_PENALTY,
                   AIFFI_TRANSFER_AMT,
                   AIFFI_1035_EXCH_AMT,
                   AIFFI_NEW_MONEY_AMT,
                   AIFFI_ROLLOVER_AMT,
                   AIFFI_DECLARED_RATE,
                   AIFFI_FUND_UNIT_VAL,
                   AIFFI_TXN_FUND_UNITS,
                   AIFFI_INTERNAL_TXN_ID
            FROM EDW_STAGING.AIF_RPS_EDW_FINTXN_DELTA SRC
                     LEFT JOIN EDW_STAGING.AIF_RPS_EDW_CTRT_FULL_DEDUP CTRT
                               ON SRC.POLICY_ID = CTRT.AIFCOW_POLICY_ID
                     LEFT JOIN
                 (SELECT DISTINCT TRNSLT_FLD_VAL,
                                  SRC_CDE,
                                  SRC_FLD_NM,
                                  SRC_FLD_VAL,
                                  SRC_TBL_NM,
                                  TRNSLT_FLD_NM
                  FROM SRC_DATA_TRNSLT_TEMP_RPS
                  WHERE UPPER(TRIM(SRC_CDE)) = 'ANN'
                    AND UPPER(TRIM(SRC_FLD_NM)) = 'ADMN_SYS_CDE'
                    AND UPPER(TRIM(TRNSLT_FLD_NM)) = 'ADMIN OR SOURCE SYSTEM CODE'
                 ) SDT_AGMT_SRC_CD
                 ON UPPER(TRIM(UDF_REPLACEEMPTYSTR(
                         CLEAN_STRING(SRC.AIFFI_SOURCE_SYSTEM_ID), 'SPACE'))) =
                    UPPER(TRIM(SDT_AGMT_SRC_CD.SRC_FLD_VAL))
                     CROSS JOIN EDW_STAGING.AIF_RPS_EDW_CTRT_FULL_COUNT CTRT_COUNT
                     LEFT JOIN
                 (SELECT PROD_ID,
                         KND_MIN_CDE,
                         KND_MAX_CDE,
                         RATE_MIN_CDE,
                         RATE_MAX_CDE,
                         BSIS_MIN_CDE,
                         BSIS_MAX_CDE,
                         ADMN_SYS_CDE,
                         END_DT
                  FROM PRODUCT_TRANSLATOR_TEMP_RPS
                  WHERE ADMN_SYS_GRP_CDE = '02'
                    AND END_DT = TO_DATE('99991231', 'YYYYMMDD') --AND ADMN_SYS_CDE='ASIA'
                 ) PDT1
                 ON
                             UPPER(TRIM(SDT_AGMT_SRC_CD.TRNSLT_FLD_VAL)) =
                             UPPER(TRIM(PDT1.ADMN_SYS_CDE)) AND
                             CLEAN_STRING(UPPER(COALESCE(PLAN_CODE, AIFCOW_PLAN_CODE))) =
                             CLEAN_STRING(UPPER(PDT1.KND_MIN_CDE)) AND
                             CLEAN_STRING(UPPER(COALESCE(PLAN_CODE, AIFCOW_PLAN_CODE))) =
                             CLEAN_STRING(UPPER(PDT1.KND_MAX_CDE))
                             --AND
                             --CLEAN_STRING(UPPER(PDT1.RATE_MIN_CDE)) <= '0000' AND
                             --CLEAN_STRING(UPPER(PDT1.RATE_MAX_CDE)) >= '0000' AND
                             --CLEAN_STRING(UPPER(PDT1.BSIS_MIN_CDE)) <= '00' AND
                             --CLEAN_STRING(UPPER(PDT1.BSIS_MAX_CDE)) >= '00'
                         AND PDT1.END_DT = TO_DATE('99991231', 'YYYYMMDD')
                     LEFT JOIN SRC_DATA_TRNSLT_TEMP_RPS SDT
                               ON UPPER(TRIM(SDT.SRC_FLD_VAL)) = UPPER(TRIM(SRC.COMPANY_CODE))
                                   AND
                                  UPPER(TRIM(SDT.SRC_FLD_NM)) = 'COMPANY-CD'
                                   AND UPPER(TRIM(SDT.SRC_CDE)) =
                                       UPPER(TRIM(SDT_AGMT_SRC_CD.TRNSLT_FLD_VAL))
                                   AND
                                  UPPER(TRIM(SDT.TRNSLT_FLD_NM)) = 'COMPANY NUMERICAL CODE'
                     LEFT JOIN SRC_DATA_TRNSLT_TEMP_RPS SDT1
                               ON UPPER(TRIM(SDT1.SRC_FLD_VAL)) =
                                  UPPER(TRIM(SRC.AIFFI_FUND_TYPE))
                                   AND UPPER(TRIM(SDT1.SRC_CDE)) =
                                       UPPER(TRIM(SDT_AGMT_SRC_CD.TRNSLT_FLD_VAL))
                                   AND
                                  UPPER(TRIM(SDT1.SRC_FLD_NM)) = 'FUND_TYPE'
                                   AND
                                  UPPER(TRIM(SDT1.TRNSLT_FLD_NM)) = 'FUND TYPE'
								  
					LEFT JOIN EDW_REF.TRANSACTION_CODE_TRNSLT CTC
                               ON UPPER(TRIM(COALESCE(CTC.ADMIN_SOURCE_CDE,' '))) =
                                  UPPER(TRIM(SDT_AGMT_SRC_CD.TRNSLT_FLD_VAL))
                                   AND
                                  UPPER(TRIM(COALESCE(CTC.SOURCE_TRANSACTION_CDE,' '))) =
                                  UPPER(TRIM(COALESCE(SRC.TRAN_CD,' ')))
                                   AND
                                  UPPER(TRIM(COALESCE(CTC.LOOKUP_DATA_1_TXT,' '))) = CASE
                                                                           WHEN UPPER(TRIM(COALESCE(SRC.TRAN_CD,' '))) = 'GC'
                                                                               THEN UPPER(TRIM(COALESCE(SRC_CD,' ')))
                                                                           ELSE TRIM(' ') END
                                   AND
                                  UPPER(TRIM(COALESCE(CTC.LOOKUP_DATA_2_TXT,' '))) = TRIM(' ')
                                   AND UPPER(TRIM(COALESCE(CTC.REVERSAL_CDE,' '))) = CASE
                                                                           WHEN UPPER(TRIM(TXN_REVERSE_IND)) = 'R'
                                                                               THEN 'R'
                                                                           ELSE TRIM(' ') END

                     LEFT JOIN EDW_REF.TRANSACTION_CODE_TRNSLT CTC1
                               ON UPPER(TRIM(COALESCE(CTC1.ADMIN_SOURCE_CDE,' '))) =
                                  UPPER(TRIM(SDT_AGMT_SRC_CD.TRNSLT_FLD_VAL))
                                   AND
                                  UPPER(TRIM(COALESCE(CTC1.SOURCE_TRANSACTION_CDE,' '))) =
                                  UPPER(TRIM(COALESCE(TRAN_CD,' ')))
                                   AND TRIM(COALESCE(CTC1.LOOKUP_DATA_1_TXT,' ')) = TRIM(' ')
                                   AND TRIM(COALESCE(CTC1.LOOKUP_DATA_2_TXT,' ')) = TRIM(' ')
                                   AND UPPER(TRIM(COALESCE(CTC1.REVERSAL_CDE,' '))) = CASE
                                                                            WHEN UPPER(TRIM(TXN_REVERSE_IND)) = 'R'
                                                                                THEN 'R'
                                                                            ELSE TRIM(' ') END
								 

/*LEFT JOIN EDW_REF.REF_FUND FND
ON  UPPER(TRIM(FND.COMPANY_CDE)) = UPPER(TRIM(SDT.TRNSLT_FLD_VAL))
		AND UPPER(TRIM(FND.SOURCE_SYSTEM_CDE)) = UPPER(TRIM(SDT_AGMT_SRC_CD.TRNSLT_FLD_VAL))
		AND UPPER(TRIM(FND.PRODUCT_TIER_CDE)) = COALESCE(UPPER(TRIM(SRC.AIFFI_FAV_CODE)),'00')
		AND UPPER(TRIM(FND.PT1_KIND_CDE))= UPPER(TRIM(COALESCE(PLAN_CODE,AIFCOW_PLAN_CODE)))
		AND UPPER(TRIM(FND.PRODUCT_ID))= UPPER(TRIM(PDT1.PROD_ID))
		AND UPPER(TRIM(FND.ADMIN_FUND_CDE)) = UPPER(TRIM(SRC.FUND_ID))
		AND FND.END_DT = TO_DATE('99991231',  'YYYYMMDD')*/

                     LEFT JOIN SRC_DATA_TRNSLT_TEMP_RPS FIN_SDT_SRC
                               ON UPPER(TRIM(FIN_SDT_SRC.SRC_FLD_VAL)) =
                                  UPPER(TRIM(SDT_AGMT_SRC_CD.TRNSLT_FLD_VAL))
                                   AND UPPER(TRIM(FIN_SDT_SRC.SRC_FLD_NM)) =
                                       UPPER(TRIM('CARR_ADMIN_SYS_CD'))
                                   AND
                                  UPPER(TRIM(FIN_SDT_SRC.SRC_CDE)) = UPPER(TRIM('TERSUN'))
                                   AND UPPER(TRIM(FIN_SDT_SRC.TRNSLT_FLD_NM)) =
                                       UPPER(TRIM('FINANCIAL TRANSACTION SOURCE CDE'))

                     LEFT JOIN SRC_DATA_TRNSLT_TEMP_RPS FIN_SDT_TYPE
                               ON UPPER(TRIM(FIN_SDT_TYPE.SRC_FLD_VAL)) =
                                  UPPER(TRIM('FINANCIAL TRANSACTION'))
                                   AND
                                  UPPER(TRIM(FIN_SDT_TYPE.SRC_CDE)) = UPPER(TRIM('TERSUN'))
                                   AND UPPER(TRIM(FIN_SDT_TYPE.SRC_FLD_NM)) =
                                       UPPER(TRIM('FINANCIAL TRANSACTION TYPE'))
                                   AND
                                  UPPER(TRIM(FIN_SDT_TYPE.TRNSLT_FLD_NM)) =
                                  UPPER(TRIM('FINANCIAL TRANSACTION TYPE CDE'))
        )

SELECT  UUID_GEN(
				PREHASH_VALUE(
               CLEAN_STRING(AGREEMENT_SOURCE_CDE),
               CLEAN_STRING(AGREEMENT_TYPE_CDE),
               CLEAN_STRING(AGREEMENT_NR_PFX),
               AGREEMENT_NR,
               CLEAN_STRING(AGREEMENT_NR_SFX),
               CLEAN_STRING(SOURCE_TRANSACTION_KEY_TXT),
               TRANSACTION_DT),
			   TRANSACTION_DT,
               CLEAN_STRING(FINANCIAL_TRANSCATION_SOURCE),
               CLEAN_STRING(FINANCIAL_TRANSCATION_TYPE),
               REVERSAL_DT,
               EFFECTIVE_DT,
               SYSTEM_DT,
               CLEAN_STRING(TRANSACTION_CDE),
               CLEAN_STRING(SOURCE_TRANSACTION_CDE),
               CLEAN_STRING(TRANSACTION_REVERSAL_CDE),
               CLEAN_STRING(ADMIN_FUND_CDE),
               CLEAN_STRING(PRODUCT_ID),
               CLEAN_STRING(COMPANY_CDE),
               CLEAN_STRING(PT1_KIND_CDE),
			   CLEAN_STRING(CASE
                    WHEN TRIM(PRODUCT_TIER_CDE) = '' THEN '0'
                    WHEN PRODUCT_TIER_CDE IS NULL THEN '0'
                    WHEN REGEXP_ILIKE(PRODUCT_TIER_CDE, '[A-Z]') THEN PRODUCT_TIER_CDE
                    ELSE ((PRODUCT_TIER_CDE::INT)::VARCHAR) END),
               CLEAN_STRING(FUND_TYPE_CDE),
               CLEAN_STRING(COVERAGE_TYPE_CDE),
               CLEAN_STRING(COVERAGE_OCCURANCE_NR)
           )::UUID                                                AS DIM_FINANCIAL_TRANSACTION_NATURAL_KEY_HASH_UUID,
       PREHASH_VALUE(
               CLEAN_STRING(AGREEMENT_SOURCE_CDE),
               CLEAN_STRING(AGREEMENT_TYPE_CDE),
               CLEAN_STRING(AGREEMENT_NR_PFX),
               AGREEMENT_NR,
               CLEAN_STRING(AGREEMENT_NR_SFX),
               CLEAN_STRING(SOURCE_TRANSACTION_KEY_TXT),
               TRANSACTION_DT)                      AS FINANCIAL_TRANSACTION_UNIQUE_ID,
       UUID_GEN(CLEAN_STRING(FINANCIAL_TRANSCATION_SOURCE))::UUID AS REF_FINANCIAL_TRANSACTION_SOURCE_NATURAL_KEY_HASH_UUID,
       UUID_GEN(CLEAN_STRING(FINANCIAL_TRANSCATION_TYPE))::UUID   AS REF_FINANCIAL_TRANSACTION_TYPE_NATURAL_KEY_HASH_UUID,
       NULL                                                       AS PAY_GROUP_NR_TXT,
       NULL                                                       AS CHECK_FORM_ID,
       TRANSACTION_DT,
       NULL                                                       AS CHECK_STATUS_CDE,
       NULL                                                       AS ACCOUNT_NR_TXT,
       NULL                                                       AS TAX_REPORTING_CDE,
       NULL                                                       AS ORIGINAL_CHECK_NR,
       NULL                                                       AS DISTRIBUTION_CDE,
       NULL                                                       AS SOURCE_PAYEE_UNIQUE_ID,
       NULL                                                       AS CLEAR_DT,
       NULL                                                       AS CLEAR_REFERENCE_NR_TXT,
       REVERSAL_DT,
       SYSTEM_DT                    							  AS BEGIN_DT,
       SYSTEM_DT:: TIMESTAMP       								  AS BEGIN_DTM,
       CURRENT_TIMESTAMP(6)                                       AS ROW_PROCESS_DTM,
       :audit_id                                                  AS AUDIT_ID,
       FALSE                                                      AS LOGICAL_DELETE_IND,
       UUID_GEN(NULL)::UUID                                       AS CHECK_SUM,--NEED TO CHECK
       TRUE                                                       AS CURRENT_ROW_IND,
       '9999-12-31'::DATE                                         AS END_DT,
       '9999-12-31'::TIMESTAMP                                    AS END_DTM,
       72                                                         AS SOURCE_SYSTEM_ID,
       FALSE                                                      AS RESTRICTED_ROW_IND,
--ROW_SID,
       :audit_id                                                  AS UPDATE_AUDIT_ID,
       FALSE                                                      AS SOURCE_DELETE_IND,
       SOURCE_TRANSACTION_KEY_TXT,
       NULL                                                       AS ROUTING_NR_TXT,
       NULL                                                       AS PAYMENT_METHOD_CDE,
       NULL                                                       AS PREVIOUS_SOURCE_TRANSACTION_KEY_TXT,
       EFFECTIVE_DT,
       SYSTEM_DT,
       TRANSACTION_CDE,
       SOURCE_TRANSACTION_CDE,
       TRANSACTION_REVERSAL_CDE,
       ADMIN_FUND_CDE,
       PRODUCT_ID,
       COMPANY_CDE,
       SOURCE_COMPANY_CDE,
       PT1_KIND_CDE,
       PRODUCT_TIER_CDE,
       FUND_TYPE_CDE,
       SOURCE_FUND_TYPE_CDE,
       COVERAGE_TYPE_CDE,
       COVERAGE_OCCURANCE_NR,
       TRANSACTION_SOURCE_ID,
       TRANSACTION_MEMO_CDE,
       NULL                                                       AS ROLLOVER_CDE,
       NULL                                                       AS SOURCE_ROLLOVER_CDE,
       NULL                                                       AS GMIB_STATUS_CDE,
       NULL                                                       AS ADMINISTRATION_CDE,
       NULL                                                       AS SOURCE_ADMINISTRATION_CDE,
       DISBURSEMENT_TRANSACTION_NR_TXT                            AS DISBURSEMENT_TRANSACTION_NR_TXT,
       NULL                                                       AS REPLACEMENT_TRANSACTION_NR_TXT,
       ALTERNATE_ADMIN_TRANSACTION_DESC                           AS TRANSACTION_DESC,
       ADMIN_TRANSACTION_DESC                                     AS SOURCE_TRANSACTION_DESC,
       TRANSACTION_REPORTING_DESC,
       TRANSACTION_REPORTING_DETAIL_DESC
FROM (SELECT AGREEMENT_TYPE_CDE,
             FINANCIAL_TRANSCATION_SOURCE,
             FINANCIAL_TRANSCATION_TYPE,
             AGREEMENT_SOURCE_CDE,
             AGREEMENT_NR_PFX,
             AGREEMENT_NR,
             AGREEMENT_NR_SFX,
             SOURCE_COMPANY_CDE,
             PT1_KIND_CDE,
             PRODUCT_ID,
             ADMIN_FUND_CDE,
             SOURCE_TRANSACTION_KEY_TXT,
             DISBURSEMENT_TRANSACTION_NR_TXT,
             SOURCE_FUND_TYPE_CDE,
             PRODUCT_TIER_CDE,
             TRANSACTION_REVERSAL_CDE,
             REVERSAL_DT,
             TRANSACTION_SOURCE_ID,
             TRANSACTION_MEMO_CDE,
             SOURCE_TRANSACTION_CDE,
             TRANSACTION_DT,
             EFFECTIVE_DT,
             COMPANY_CDE,
             FUND_TYPE_CDE,
             ALTERNATE_ADMIN_TRANSACTION_DESC,
             ADMIN_TRANSACTION_DESC,
             TRANSACTION_REPORTING_DESC,
             TRANSACTION_REPORTING_DETAIL_DESC,
             TRANSACTION_CDE,
             SYSTEM_DT,
             NULL AS COVERAGE_TYPE_CDE,
             NULL AS COVERAGE_OCCURANCE_NR
      FROM (
               SELECT AGREEMENT_TYPE_CDE,
                      FINANCIAL_TRANSCATION_SOURCE,
                      FINANCIAL_TRANSCATION_TYPE,
                      AGREEMENT_SOURCE_CDE,
                      AGREEMENT_NR_PFX,
                      AGREEMENT_NR,
                      AGREEMENT_NR_SFX,
                      NULL                                                   AS SOURCE_COMPANY_CDE,
                      NULL                                                   AS PT1_KIND_CDE,
                      NULL                                                   AS PRODUCT_ID,
                      NULL                                                   AS ADMIN_FUND_CDE,
                      SOURCE_TRANSACTION_KEY_TXT,
                      DISBURSEMENT_TRANSACTION_NR_TXT,
                      NULL                                                   AS SOURCE_FUND_TYPE_CDE,
                      NULL                                                   AS PRODUCT_TIER_CDE,
                      TRANSACTION_REVERSAL_CDE,
                      REVERSAL_DT,
                      TRANSACTION_SOURCE_ID,
                      TRANSACTION_MEMO_CDE,
                      SOURCE_TRANSACTION_CDE,
                      TRANSACTION_DT,
                      EFFECTIVE_DT,
                      NULL                                                   AS COMPANY_CDE,
                      NULL                                                   AS FUND_TYPE_CDE,
                      ALTERNATE_ADMIN_TRANSACTION_DESC,
                      ADMIN_TRANSACTION_DESC,
                      TRANSACTION_REPORTING_DESC,
                      TRANSACTION_REPORTING_DETAIL_DESC,
                      SOURCES.TRANSACTION_CDE,
                      SYSTEM_DT,
                      TXN_REVERSE_IND,
                      ROW_NUMBER() OVER (PARTITION BY AIFFI_INTERNAL_TXN_ID) AS ROWNO
               FROM FINTXN_SOURCE_HASH SOURCES) TGA_SOURCE
      WHERE 1 = 1
        AND ROWNO = 1

      UNION 

--FTA AMOUNT TYPE

      SELECT AGREEMENT_TYPE_CDE,
             FINANCIAL_TRANSCATION_SOURCE,
             FINANCIAL_TRANSCATION_TYPE,
             AGREEMENT_SOURCE_CDE,
             AGREEMENT_NR_PFX,
             AGREEMENT_NR,
             AGREEMENT_NR_SFX,
             SOURCE_COMPANY_CDE,
             PT1_KIND_CDE,
             PRODUCT_ID,
             ADMIN_FUND_CDE,
             SOURCE_TRANSACTION_KEY_TXT,
             DISBURSEMENT_TRANSACTION_NR_TXT,
             SOURCE_FUND_TYPE_CDE,
             PRODUCT_TIER_CDE,
             TRANSACTION_REVERSAL_CDE,
             REVERSAL_DT,
             TRANSACTION_SOURCE_ID,
             TRANSACTION_MEMO_CDE,
             SOURCE_TRANSACTION_CDE,
             TRANSACTION_DT,
             EFFECTIVE_DT,
             COMPANY_CDE,
             FUND_TYPE_CDE,
             ALTERNATE_ADMIN_TRANSACTION_DESC,
             ADMIN_TRANSACTION_DESC,
             TRANSACTION_REPORTING_DESC,
             TRANSACTION_REPORTING_DETAIL_DESC,
             TRANSACTION_CDE,
             SYSTEM_DT,
             NULL AS COVERAGE_TYPE_CDE,
             NULL AS COVERAGE_OCCURANCE_NR
      FROM (
               SELECT AGREEMENT_TYPE_CDE,
                      FINANCIAL_TRANSCATION_SOURCE,
                      FINANCIAL_TRANSCATION_TYPE,
                      AGREEMENT_SOURCE_CDE,
                      AGREEMENT_NR_PFX,
                      AGREEMENT_NR,
                      AGREEMENT_NR_SFX,
                      SOURCE_COMPANY_CDE,
                      PT1_KIND_CDE,
                      PRODUCT_ID,
                      ADMIN_FUND_CDE,
                      SOURCE_TRANSACTION_KEY_TXT,
                      DISBURSEMENT_TRANSACTION_NR_TXT,
                      SOURCE_FUND_TYPE_CDE,
                      PRODUCT_TIER_CDE,
                      TRANSACTION_REVERSAL_CDE,
                      REVERSAL_DT,
                      TRANSACTION_SOURCE_ID,
                      TRANSACTION_MEMO_CDE,
                      SOURCE_TRANSACTION_CDE,
                      SOURCE_CREDIT_DEBIT_TYPE_CDE,
                      TRANSACTION_DT,
                      EFFECTIVE_DT,
                      SUM(TXN_GROSS_AMT)
                      OVER (PARTITION BY AIFFI_INTERNAL_TXN_ID,POLICY_ID,PT1_KIND_CDE,PRODUCT_ID,ADMIN_FUND_CDE,PRODUCT_TIER_CDE,FUND_TYPE_CDE,SOURCES.CREDIT_DEBIT_TYPE_CDE)
                          AS TRANSACTION_AMT,
                      COMPANY_CDE,
                      FUND_TYPE_CDE,
                      ALTERNATE_ADMIN_TRANSACTION_DESC,
                      ADMIN_TRANSACTION_DESC,
                      TRANSACTION_REPORTING_DESC,
                      TRANSACTION_REPORTING_DETAIL_DESC,
                      SOURCES.TRANSACTION_CDE,
                      SYSTEM_DT,
                      ROW_NUMBER()
                      OVER (PARTITION BY AIFFI_INTERNAL_TXN_ID,POLICY_ID,PT1_KIND_CDE,PRODUCT_ID,ADMIN_FUND_CDE,PRODUCT_TIER_CDE,FUND_TYPE_CDE,SOURCES.CREDIT_DEBIT_TYPE_CDE)
                          AS ROWNO
               FROM FINTXN_SOURCE_HASH SOURCES) FTA_SOURCE
      WHERE ROWNO = 1
        AND TRANSACTION_AMT <> 0) DIM_FIN
;

/* EDW_WORK.AIFRPS_DIM_FINANCIAL_TRANSACTION_REPLACEMENT - INSERTS
 *
 * THIS SCRIPT IS USED TO LOAD THE RECORDS THAT DON'T HAVE A RECORD IN TARGET
 *
 */

SELECT ANALYZE_STATISTICS('EDW_STAGING.AIFRPS_DIM_FINANCIAL_TRANSACTION_PRE_WORK');


INSERT INTO EDW_WORK.AIFRPS_DIM_FINANCIAL_TRANSACTION

(DIM_FINANCIAL_TRANSACTION_NATURAL_KEY_HASH_UUID,
 FINANCIAL_TRANSACTION_UNIQUE_ID,
 REF_FINANCIAL_TRANSACTION_SOURCE_NATURAL_KEY_HASH_UUID,
 REF_FINANCIAL_TRANSACTION_TYPE_NATURAL_KEY_HASH_UUID,
 PAY_GROUP_NR_TXT,
 CHECK_FORM_ID,
 TRANSACTION_DT,
 CHECK_STATUS_CDE,
 ACCOUNT_NR_TXT,
 TAX_REPORTING_CDE,
 ORIGINAL_CHECK_NR,
 DISTRIBUTION_CDE,
 SOURCE_PAYEE_UNIQUE_ID,
 CLEAR_DT,
 CLEAR_REFERENCE_NR_TXT,
 REVERSAL_DT,
 BEGIN_DT,
 BEGIN_DTM,
 ROW_PROCESS_DTM,
 AUDIT_ID,
 LOGICAL_DELETE_IND,
 CHECK_SUM,
 CURRENT_ROW_IND,
 END_DT,
 END_DTM,
 SOURCE_SYSTEM_ID,
 RESTRICTED_ROW_IND,
 UPDATE_AUDIT_ID,
 SOURCE_DELETE_IND,
 SOURCE_TRANSACTION_KEY_TXT,
 ROUTING_NR_TXT,
 PAYMENT_METHOD_CDE,
 PREVIOUS_SOURCE_TRANSACTION_KEY_TXT,
 EFFECTIVE_DT,
 SYSTEM_DT,
 TRANSACTION_CDE,
 SOURCE_TRANSACTION_CDE,
 TRANSACTION_REVERSAL_CDE,
 ADMIN_FUND_CDE,
 PRODUCT_ID,
 COMPANY_CDE,
 SOURCE_COMPANY_CDE,
 PT1_KIND_CDE,
 PRODUCT_TIER_CDE,
 FUND_TYPE_CDE,
 SOURCE_FUND_TYPE_CDE,
 COVERAGE_TYPE_CDE,
 COVERAGE_OCCURANCE_NR,
 TRANSACTION_SOURCE_ID,
 TRANSACTION_MEMO_CDE,
 ROLLOVER_CDE,
 SOURCE_ROLLOVER_CDE,
 GMIB_STATUS_CDE,
 ADMINISTRATION_CDE,
 SOURCE_ADMINISTRATION_CDE,
 DISBURSEMENT_TRANSACTION_NR_TXT,
 REPLACEMENT_TRANSACTION_NR_TXT,
 TRANSACTION_DESC,
 SOURCE_TRANSACTION_DESC,
 TRANSACTION_REPORTING_DESC,
 TRANSACTION_REPORTING_DETAIL_DESC)

SELECT DIM_FINANCIAL_TRANSACTION_NATURAL_KEY_HASH_UUID,
       FINANCIAL_TRANSACTION_UNIQUE_ID,
       REF_FINANCIAL_TRANSACTION_SOURCE_NATURAL_KEY_HASH_UUID,
       REF_FINANCIAL_TRANSACTION_TYPE_NATURAL_KEY_HASH_UUID,
       PAY_GROUP_NR_TXT,
       CHECK_FORM_ID,
       TRANSACTION_DT,
       CHECK_STATUS_CDE,
       ACCOUNT_NR_TXT,
       TAX_REPORTING_CDE,
       ORIGINAL_CHECK_NR,
       DISTRIBUTION_CDE,
       SOURCE_PAYEE_UNIQUE_ID,
       CLEAR_DT,
       CLEAR_REFERENCE_NR_TXT,
       REVERSAL_DT,
       BEGIN_DT,
       BEGIN_DTM,
       ROW_PROCESS_DTM,
       AUDIT_ID,
       LOGICAL_DELETE_IND,
       CHECK_SUM,
       CURRENT_ROW_IND,
       END_DT,
       END_DTM,
       SOURCE_SYSTEM_ID,
       RESTRICTED_ROW_IND,
       UPDATE_AUDIT_ID,
       SOURCE_DELETE_IND,
       SOURCE_TRANSACTION_KEY_TXT,
       ROUTING_NR_TXT,
       PAYMENT_METHOD_CDE,
       PREVIOUS_SOURCE_TRANSACTION_KEY_TXT,
       EFFECTIVE_DT,
       SYSTEM_DT,
       TRANSACTION_CDE,
       SOURCE_TRANSACTION_CDE,
       TRANSACTION_REVERSAL_CDE,
       ADMIN_FUND_CDE,
       PRODUCT_ID,
       COMPANY_CDE,
       SOURCE_COMPANY_CDE,
       PT1_KIND_CDE,
       PRODUCT_TIER_CDE,
       FUND_TYPE_CDE,
       SOURCE_FUND_TYPE_CDE,
       COVERAGE_TYPE_CDE,
       COVERAGE_OCCURANCE_NR,
       TRANSACTION_SOURCE_ID,
       TRANSACTION_MEMO_CDE,
       ROLLOVER_CDE,
       SOURCE_ROLLOVER_CDE,
       GMIB_STATUS_CDE,
       ADMINISTRATION_CDE,
       SOURCE_ADMINISTRATION_CDE,
       DISBURSEMENT_TRANSACTION_NR_TXT,
       REPLACEMENT_TRANSACTION_NR_TXT,
       TRANSACTION_DESC,
       SOURCE_TRANSACTION_DESC,
       TRANSACTION_REPORTING_DESC,
       TRANSACTION_REPORTING_DETAIL_DESC

FROM EDW_STAGING.AIFRPS_DIM_FINANCIAL_TRANSACTION_PRE_WORK

--INSERT WHEN NO RECORDS IN TARGET TABLE INSERT ONLY
WHERE DIM_FINANCIAL_TRANSACTION_NATURAL_KEY_HASH_UUID NOT IN
      (SELECT DISTINCT DIM_FINANCIAL_TRANSACTION_NATURAL_KEY_HASH_UUID
       FROM edw_financial_transactions.DIM_FINANCIAL_TRANSACTION WHERE SOURCE_SYSTEM_ID IN ('72','266'))
;

SELECT ANALYZE_STATISTICS('EDW_WORK.AIFRPS_DIM_FINANCIAL_TRANSACTION');