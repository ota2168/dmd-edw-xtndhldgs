/*
		FILENAME:               AIFRPS_FACT_FINANCIAL_DETAIL.SQL
		AUTHOR:                 CP45213 / MM23717
		SUBJECT AREA :          AGREEMENT
		SOURCE:                 AIF-RPS
		TERADATA SOURCE CODE:   72
		DESCRIPTION:            FACT_FINANCIAL_DETAIL TABLE POPULATION FOR TRANSACTIONS
		CODE DETAILS:           --Step1 >   Creating the temp tables for EDW_REF.SRC_DATA_TRNSLT and EDW_REF.PRODUCT_TRANSLATOR for
		                                    restricting the data volume.
		                        --Step2 >   Using the above temp tables data creating the temp data from line #112. Inside the temp query
		                        --          calculating the TGA_AMT for the Fin txn
		                        --Step3 >   Using the above temp query calculating the different TXN_TYPEs. Starting individual TXN_TYPE
		                        --          calculations from line #544. Any changes to txn type specific amounts/code fields are calculated here.
		JIRA:
		CREATE DATE:            2021-08-02

		===============================================================================================================
		VERSION/JIRA STORY#			CREATED BY          LAST_MODIFIED_DATE		DESCRIPTION
		---------------------------------------------------------------------------------------------------------------

		---------------------------------------------------------------------------------------------------------------
*/

/* TRUNCATE STAGING PRE WORK TABLE */
TRUNCATE TABLE EDW_STAGING.AIFRPS_FACT_FINANCIAL_DETAIL_PRE_WORK;

/*TRUNCATE WORK TABLE */
TRUNCATE TABLE EDW_WORK.AIFRPS_FACT_FINANCIAL_DETAIL;


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



-- Step 1 :
-- INSERT SCRIPT FOR PRE WORK TABLE -ALL RECORDS FROM STG

INSERT INTO EDW_STAGING.AIFRPS_FACT_FINANCIAL_DETAIL_PRE_WORK
(FACT_FINANCIAL_DETAIL_NATURAL_KEY_HASH_UUID,
 DIM_FINANCIAL_TRANSACTION_NATURAL_KEY_HASH_UUID,
 CALENDAR_DT,
 TRANSACTION_DETAIL_TYPE_CDE,
 TRANSACTION_DETAIL_CATEGORY_CDE,
 TRANSACTION_DETAIL_METHOD_CDE,
 SOURCE_TRANSACTION_DETAIL_CATEGORY_CDE,
 SOURCE_TRANSACTION_DETAIL_METHOD_CDE,
 SOURCE_TRANSACTION_DETAIL_TYPE_CDE,
 TRANSACTION_AMT,
 ROW_PROCESS_DTM,
 AUDIT_ID,
 LOGICAL_DELETE_IND,
 CHECK_SUM,
 SOURCE_SYSTEM_ID,
 RESTRICTED_ROW_IND,
 UPDATE_AUDIT_ID,
 SOURCE_DELETE_IND,
 CREDIT_DEBIT_TYPE_CDE,
 SOURCE_CREDIT_DEBIT_TYPE_CDE,
 TRANSACTION_SEQUENCE_NR,
 WAIVER_REASON_CDE,
 SOURCE_WAIVER_REASON_CDE,
 MONEY_SOURCE_CDE,
 SOURCE_MONEY_SOURCE_CDE,
 BILL_MODE_CDE,
 SOURCE_BILL_MODE_CDE,
 PREMIUM_PAID_DT,
 PREMIUM_DUE_DT,
 TRANSACTION_DURATION_NR,
 DEPOSITS_TAX_YEAR_NR,
 FUND_UNITS_CNT,
 FUND_UNIT_VAL_RT,
 FUND_DECLARED_INTEREST_RT,
 BASIS_POINTS_VAL,
 COMMISSION_OVERDUE_PCT,
 BONUS_RT,
 POST_TEFRA_COST_BASIS_AMT,
 PRE_TEFRA_COST_BASIS_AMT,
 ROLLOVER_AMT,
 NEW_MONEY_AMT,
 EXCHANGE_1035_AMT,
 TRANSFER_AMT,
 PREMIUM_DUE_AMT,
 INTEREST_DUE_AMT,
 PREMIUM_PAYMENT_CASH_AMT,
 WAIVER_PREMIUM_PAYMENT_CASH_AMT,
 PREMIUM_PAYMENT_LOAN_AMT,
 PREMIUM_PAYMENT_DIVIDEND_AMT,
 PREMIUM_PAYMENT_ABR_DIVIDEND_AMT)


WITH /*+ENABLE_WITH_CLAUSE_MATERIALIZATION*/
    FINTXN_SOURCE_HASH as
        (
            SELECT SRC.policy_id,
                   clean_string(sdt_agmt_src_cd.trnslt_fld_val) as                                 agreement_source_cde,
                   'Ipa' as                                                                        agreement_type_cde,
                   udf_aif_hldg_key_format(SRC.policy_id, 'PFX') as                                agreement_nr_pfx,
                   udf_aif_hldg_key_format(SRC.policy_id, 'KEY') as                                agreement_nr,
                   udf_aif_hldg_key_format(SRC.policy_id, 'SFX') as                                agreement_nr_sfx,
                   clean_string(trim(fin_sdt_src.trnslt_fld_val)) as                               financial_transcation_source,
                   clean_string(trim(fin_sdt_type.trnslt_fld_val))                                 financial_transcation_type,
                   COMPANY_CODE as                                                                 source_company_cde,
                   COALESCE(SRC.PLAN_CODE, CTRT.AIFCOW_PLAN_CODE) AS                               pt1_kind_cde,
                   PDT1.PROD_ID AS                                                                 product_id,
                   FUND_ID as                                                                      admin_fund_cde,
                   AIFFI_INTERNAL_TXN_ID::varchar as                                               source_transaction_key_txt,
                   AIFFI_DSTRBTR_TXN_ID::VARCHAR as                                                disbursement_transaction_nr_txt,
                   TRIM(AIFFI_FUND_TYPE) as                                                        source_fund_type_cde,
                   PAYMENT_DURATION as                                                             transaction_duration_nr,
                   TRIM(COALESCE(AIFFI_FAV_CODE, '00')) as                                         product_tier_cde,
                   AIFFI_IRA_TAX_YEAR as                                                           deposits_tax_year_nr,
                   case when UPPER(TRIM(TXN_REVERSE_IND)) = 'R' THEN 'Y' else 'N' end as           transaction_reversal_cde,
                   case
                       when UPPER(TRIM(TXN_REVERSE_IND)) = 'R' THEN ISDATE(TO_CHAR(TXN_CYCLE_DATE))
                       else NULL end as                                                            reversal_dt,
                   SRC.SRC_CD   as                                                      transaction_source_id,
                   SRC.MEMO_CD as                                                       transaction_memo_cde,
				   SRC.TRAN_CD as 														TRAN_CD,
                   TRIM(TXN_TYPE) as                                                               source_transaction_cde,
                   AIFFI_DEBIT_CREDIT_IND as                                                       source_credit_debit_type_cde,
                   --TXN_CYCLE_DATE as                                                               transaction_dt,
                   ISDATE(TO_CHAR(TXN_CYCLE_DATE)) 					                               AS TRANSACTION_DT,
                   --TXN_EFF_DATE as                                                                 effective_dt,
                   ISDATE(TO_CHAR(TXN_EFF_DATE)) 					                               AS EFFECTIVE_DT,
                   TRIM(SDT.TRNSLT_FLD_VAL) as                                                     company_cde,
                   SDT1.TRNSLT_FLD_VAL as                                                          fund_type_cde,
                   TRIM(NVL2(CTC.transaction_cde, CTC.alternate_admin_transaction_desc,
                             CTC1.alternate_admin_transaction_desc)) AS                            alternate_admin_transaction_desc,
                   TRIM(NVL2(CTC.transaction_cde, CTC.admin_transaction_desc,
                             CTC1.admin_transaction_desc)) AS                                      admin_transaction_desc,
                   TRIM(NVL2(CTC.transaction_cde, CTC.transaction_reporting_desc,
                             CTC1.transaction_reporting_desc)) AS                                  transaction_reporting_desc,
                   TRIM(NVL2(CTC.transaction_cde, CTC.transaction_reporting_detail_desc,
                             CTC1.transaction_reporting_detail_desc)) AS                           transaction_reporting_detail_desc,
                   TRIM(COALESCE(CTC.transaction_cde, CTC1.transaction_cde)) AS                    transaction_cde,
                   CASE WHEN TRIM(AIFFI_DEBIT_CREDIT_IND)='T' THEN 'C'
						WHEN TRIM(AIFFI_DEBIT_CREDIT_IND)='F' THEN 'D'
						ELSE TRIM(NVL2(CTC.transaction_cde, CTC.DEBIT_CREDIT_CDE,
                             CTC1.DEBIT_CREDIT_CDE)) END AS                                            credit_debit_type_cde, /*applicable only for FTA*/
                   ISDATE(TO_CHAR(ctrt_count.cycle_date))                                          as system_dt,
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
                     left join EDW_STAGING.AIF_RPS_EDW_CTRT_FULL_DEDUP CTRT
                               on SRC.policy_id = CTRT.aifcow_policy_id
                     left join
                 (select distinct trnslt_fld_val, src_cde, src_fld_nm, src_fld_val, src_tbl_nm, trnslt_fld_nm
                  from SRC_DATA_TRNSLT_TEMP_RPS
                  where upper(TRIM(src_cde)) = 'ANN'
                    and upper(TRIM(src_fld_nm)) = 'ADMN_SYS_CDE'
                    and upper(TRIM(trnslt_fld_nm)) = 'ADMIN OR SOURCE SYSTEM CODE'
                 ) sdt_agmt_src_cd
                 on upper(TRIM(udf_replaceemptystr(clean_string(SRC.aiffi_source_system_id), 'SPACE'))) =
                    upper(TRIM(sdt_agmt_src_cd.src_fld_val))
                     CROSS JOIN EDW_STAGING.AIF_RPS_EDW_CTRT_FULL_COUNT ctrt_count
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
                    and end_dt = TO_DATE('99991231', 'YYYYMMDD') --and ADMN_SYS_CDE='Asia'
                 ) PDT1
                 ON
                             upper(TRIM(sdt_agmt_src_cd.trnslt_fld_val)) = upper(TRIM(PDT1.ADMN_SYS_CDE)) AND
                             CLEAN_STRING(upper(COALESCE(PLAN_CODE, AIFCOW_PLAN_CODE))) =
                             CLEAN_STRING(upper(PDT1.KND_MIN_CDE)) AND
                             CLEAN_STRING(upper(COALESCE(PLAN_CODE, AIFCOW_PLAN_CODE))) =
                             CLEAN_STRING(upper(PDT1.KND_MAX_CDE))
                             --AND
                             --CLEAN_STRING(upper(PDT1.RATE_MIN_CDE)) <= '0000' AND
                             --CLEAN_STRING(upper(PDT1.RATE_MAX_CDE)) >= '0000' AND
                             --CLEAN_STRING(upper(PDT1.BSIS_MIN_CDE)) <= '00' AND
                             --CLEAN_STRING(upper(PDT1.BSIS_MAX_CDE)) >= '00'
                         AND PDT1.end_dt = TO_DATE('99991231', 'YYYYMMDD')
                     LEFT JOIN SRC_DATA_TRNSLT_TEMP_RPS SDT
                               ON upper(TRIM(SDT.SRC_FLD_VAL)) = upper(TRIM(SRC.COMPANY_CODE))
                                   AND upper(TRIM(SDT.SRC_FLD_NM)) = 'COMPANY-CD'
                                   AND upper(TRIM(SDT.SRC_CDE)) = upper(TRIM(sdt_agmt_src_cd.trnslt_fld_val))
                                   AND upper(TRIM(SDT.TRNSLT_FLD_NM)) = 'COMPANY NUMERICAL CODE'

                     LEFT JOIN SRC_DATA_TRNSLT_TEMP_RPS SDT1
                               ON upper(TRIM(SDT1.SRC_FLD_VAL)) = upper(TRIM(SRC.AIFFI_FUND_TYPE))
                                   AND upper(TRIM(SDT1.SRC_CDE)) = upper(TRIM(sdt_agmt_src_cd.trnslt_fld_val))
                                   AND upper(TRIM(SDT1.SRC_FLD_NM)) = 'FUND_TYPE'
                                   AND upper(TRIM(SDT1.TRNSLT_FLD_NM)) = 'FUND TYPE'
								   
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
/*LEFT JOIN edw_ref.REF_FUND FND
ON  upper(TRIM(FND.COMPANY_CDE)) = upper(TRIM(SDT.TRNSLT_FLD_VAL))
		AND upper(TRIM(FND.source_system_cde)) = upper(TRIM(sdt_agmt_src_cd.trnslt_fld_val))
		AND UPPER(TRIM(FND.product_tier_cde)) = COALESCE(UPPER(TRIM(SRC.AIFFI_FAV_CODE)),'00')
		AND upper(trim(FND.pt1_kind_cde))= upper(trim(COALESCE(PLAN_CODE,AIFCOW_PLAN_CODE)))
		AND upper(TRIM(FND.product_id))= upper(TRIM(PDT1.PROD_ID))
		AND upper(trim(FND.admin_fund_cde)) = upper(trim(SRC.FUND_ID))
		AND FND.end_dt = TO_DATE('99991231',  'YYYYMMDD')*/

                     LEFT JOIN SRC_DATA_TRNSLT_TEMP_RPS fin_sdt_src
                               ON upper(TRIM(fin_sdt_src.SRC_FLD_VAL)) = upper(TRIM(sdt_agmt_src_cd.trnslt_fld_val))
                                   AND upper(TRIM(fin_sdt_src.SRC_FLD_NM)) = UPPER(TRIM('Carr_admin_sys_cd'))
                                   AND upper(TRIM(fin_sdt_src.SRC_CDE)) = UPPER(TRIM('TERSUN'))
                                   AND upper(TRIM(fin_sdt_src.TRNSLT_FLD_NM)) =
                                       UPPER(TRIM('Financial Transaction Source Cde'))

                     LEFT JOIN SRC_DATA_TRNSLT_TEMP_RPS fin_sdt_type
                               ON upper(TRIM(fin_sdt_type.SRC_FLD_VAL)) = UPPER(TRIM('Financial Transaction'))
                                   AND upper(TRIM(fin_sdt_type.SRC_CDE)) = UPPER(TRIM('TERSUN'))
                                   AND upper(TRIM(fin_sdt_type.SRC_FLD_NM)) = UPPER(TRIM('Financial Transaction Type'))
                                   AND upper(TRIM(fin_sdt_type.TRNSLT_FLD_NM)) =
                                       UPPER(TRIM('Financial Transaction Type Cde'))
        )

SELECT uuid_gen(
               prehash_value(
               clean_string(agreement_source_cde),
               clean_string(agreement_type_cde),
               clean_string(agreement_nr_pfx),
               agreement_nr,
               clean_string(agreement_nr_sfx),
               clean_string(source_transaction_key_txt),
               transaction_dt),
			   transaction_dt,
               clean_string(financial_transcation_source),
               clean_string(financial_transcation_type),
               reversal_dt,
               effective_dt,
               system_dt,
               clean_string(transaction_cde),
               clean_string(source_transaction_cde),
               clean_string(transaction_reversal_cde),
               clean_string(admin_fund_cde),
               clean_string(product_id),
               clean_string(company_cde),
               clean_string(pt1_kind_cde),
			   clean_string(case
                          when trim(product_tier_cde) = '' then '0'
                          when product_tier_cde is null then '0'
                          when regexp_ilike(product_tier_cde, '[A-Z]') then product_tier_cde
                          else ((product_tier_cde::int)::Varchar) END),
               clean_string(fund_type_cde),
               clean_string(coverage_type_cde),
               clean_string(coverage_occurance_nr),
               calendar_dt,
               clean_string(transaction_detail_type_cde),
               clean_string(credit_debit_type_cde),
               transaction_sequence_nr)::uuid as fact_financial_detail_natural_key_hash_uuid,
       uuid_gen(
               prehash_value(
               clean_string(agreement_source_cde),
               clean_string(agreement_type_cde),
               clean_string(agreement_nr_pfx),
               agreement_nr,
               clean_string(agreement_nr_sfx),
               clean_string(source_transaction_key_txt),
               transaction_dt),
			   transaction_dt,
               clean_string(financial_transcation_source),
               clean_string(financial_transcation_type),
               reversal_dt,
               effective_dt,
               system_dt,
               clean_string(transaction_cde),
               clean_string(source_transaction_cde),
               clean_string(transaction_reversal_cde),
               clean_string(admin_fund_cde),
               clean_string(product_id),
               clean_string(company_cde),
               clean_string(pt1_kind_cde),
			   clean_string(case
                          when trim(product_tier_cde) = '' then '0'
                          when product_tier_cde is null then '0'
                          when regexp_ilike(product_tier_cde, '[A-Z]') then product_tier_cde
                          else ((product_tier_cde::int)::Varchar) END),
               clean_string(fund_type_cde),
               clean_string(coverage_type_cde),
               clean_string(coverage_occurance_nr)
           )::uuid                            as dim_financial_transaction_natural_key_hash_uuid,
       calendar_dt,
       transaction_detail_type_cde,
       transaction_detail_category_cde,
       transaction_detail_method_cde,
       source_transaction_detail_category_cde,
       source_transaction_detail_method_cde,
       source_transaction_detail_type_cde,
       transaction_amt,
       row_process_dtm,
       audit_id,
       logical_delete_ind,
       check_sum,
       source_system_id,
       restricted_row_ind,
       --row_sid,
       update_audit_id,
       source_delete_ind,
       credit_debit_type_cde,
       source_credit_debit_type_cde,
       transaction_sequence_nr,
       waiver_reason_cde,
       source_waiver_reason_cde,
       money_source_cde,
       source_money_source_cde,
       bill_mode_cde,
       source_bill_mode_cde,
       premium_paid_dt,
       premium_due_dt,
       transaction_duration_nr,
       deposits_tax_year_nr,
       fund_units_cnt,
       fund_unit_val_rt,
       fund_declared_interest_rt,
       basis_points_val,
       commission_overdue_pct,
       bonus_rt,
       post_tefra_cost_basis_amt,
       pre_tefra_cost_basis_amt,
       rollover_amt,
       new_money_amt,
       exchange_1035_amt,
       transfer_amt,
       premium_due_amt,
       interest_due_amt,
       premium_payment_cash_amt,
       waiver_premium_payment_cash_amt,
       premium_payment_loan_amt,
       premium_payment_dividend_amt,
       premium_payment_abr_dividend_amt
       --process_ind
from (
         select agreement_source_cde,
                agreement_nr_pfx,
                agreement_nr,
                agreement_nr_sfx,
                source_transaction_key_txt,
                transaction_dt,
                agreement_type_cde,
                financial_transcation_source,
                financial_transcation_type,
                reversal_dt,
                effective_dt,
                system_dt,
                transaction_dt                                                                                                                            as calendar_dt,
                transaction_cde,
                source_transaction_cde,
                transaction_reversal_cde,
                admin_fund_cde,
                product_id,
                company_cde,
                pt1_kind_cde,
                product_tier_cde,
                fund_type_cde,
                transaction_detail_type_cde,
                NULL                                                                                                                                      as transaction_detail_category_cde,
                NULL                                                                                                                                      as transaction_detail_method_cde,
                NULL                                                                                                                                      as source_transaction_detail_category_cde,
                NULL                                                                                                                                      as source_transaction_detail_method_cde,
                transaction_detail_type_cde                                                                                                               as source_transaction_detail_type_cde,
                transaction_amt,
                current_timestamp(6)                                                                                                                      as row_process_dtm,
                :audit_id                                                                                                                                 as audit_id,--need to check
                false                                                                                                                                     as logical_delete_ind, --need to check
                uuid_gen(NULL)::uuid                                                                                                                                     as check_sum, --need to check
                72                                                                                                                                        as source_system_id,
                false                                                                                                                                     as restricted_row_ind,--need to check
                null                                                                                                                                      as row_sid,--need to check
                :audit_id                                                                                                                                 as update_audit_id,--need to check
                false                                                                                                                                     as source_delete_ind,--need to check
                credit_debit_type_cde,
                source_credit_debit_type_cde,
                ROW_NUMBER() over (partition by agreement_nr_pfx,agreement_nr,agreement_nr_sfx,source_transaction_key_txt,
                    transaction_dt,reversal_dt,effective_dt,system_dt,transaction_cde,source_transaction_cde,transaction_reversal_cde,
                    admin_fund_cde,product_id,company_cde,pt1_kind_cde,product_tier_cde,fund_type_cde, transaction_detail_type_cde,credit_debit_type_cde) as transaction_sequence_nr,
                null                                                                                                                                      as waiver_reason_cde,
                null                                                                                                                                      as source_waiver_reason_cde,
                null                                                                                                                                      as money_source_cde,
                null                                                                                                                                      as source_money_source_cde,
                null                                                                                                                                      as bill_mode_cde,
                null                                                                                                                                      as source_bill_mode_cde,
                null                                                                                                                                      as premium_paid_dt,
                null                                                                                                                                      as premium_due_dt,
                transaction_duration_nr,
                TO_NUMBER(deposits_tax_year_nr) as deposits_tax_year_nr ,
                fund_units_cnt,
                fund_unit_val_rt,
                fund_declared_interest_rt,
                null                                                                                                                                      as basis_points_val,
                null                                                                                                                                      as commission_overdue_pct,
                null                                                                                                                                      as bonus_rt,
                null                                                                                                                                      as post_tefra_cost_basis_amt,
                null                                                                                                                                      as pre_tefra_cost_basis_amt,
                rollover_amt,
                new_money_amt,
                exchange_1035_amt,
                transfer_amt,
                null                                                                                                                                      as premium_due_amt,
                null                                                                                                                                      as interest_due_amt,
                null                                                                                                                                      as premium_payment_cash_amt,
                null                                                                                                                                      as waiver_premium_payment_cash_amt,
                null                                                                                                                                      as premium_payment_loan_amt,
                null                                                                                                                                      as premium_payment_dividend_amt,
                null                                                                                                                                      as premium_payment_abr_dividend_amt,
                null                                                                                                                                      as coverage_type_cde,
                null                                                                                                                                      as coverage_occurance_nr,
                null                                                                                                                                      as PROCESS_IND
         FROM (
                  select agreement_type_cde,
                         financial_transcation_source,
                         financial_transcation_type,
                         agreement_source_cde,
                         agreement_nr_pfx,
                         agreement_nr,
                         agreement_nr_sfx,
                         source_company_cde,
                         pt1_kind_cde,
                         product_id,
                         admin_fund_cde,
                         source_transaction_key_txt,
                         disbursement_transaction_nr_txt,
                         source_fund_type_cde,
                         transaction_duration_nr,
                         transfer_amt,
                         exchange_1035_amt,
                         new_money_amt,
                         rollover_amt,
                         product_tier_cde,
                         deposits_tax_year_nr,
                         fund_declared_interest_rt,
                         fund_unit_val_rt,
                         fund_units_cnt,
                         transaction_reversal_cde,
                         reversal_dt,
                         transaction_source_id,
                         transaction_memo_cde,
                         source_transaction_cde,
                         source_credit_debit_type_cde,
                         transaction_dt,
                         effective_dt,
                         CASE
                             WHEN UPPER(TRIM(TXN_REVERSE_IND)) = 'R' THEN ABS(transaction_amt) * -1
                             ELSE ABS(transaction_amt) END as transaction_amt,
                         transaction_detail_type_cde,
                         company_cde,
                         fund_type_cde,
                         alternate_admin_transaction_desc,
                         admin_transaction_desc,
                         transaction_reporting_desc,
                         transaction_reporting_detail_desc,
                         transaction_cde,
                         credit_debit_type_cde,
                         system_dt
                  from (
                           SELECT agreement_type_cde,
                                  financial_transcation_source,
                                  financial_transcation_type,
                                  agreement_source_cde,
                                  agreement_nr_pfx,
                                  agreement_nr,
                                  agreement_nr_sfx,
                                  NULL                                                                     as source_company_cde,
                                  NULL                                                                     as pt1_kind_cde,
                                  NULL                                                                     as product_id,
                                  NULL                                                                     as admin_fund_cde,
                                  source_transaction_key_txt,
                                  disbursement_transaction_nr_txt,
                                  NULL                                                                     as source_fund_type_cde,
                                  transaction_duration_nr,
                                  NULL::NUMERIC(17, 4)                                                     as transfer_amt,
                                  NULL::NUMERIC(17, 4)                                                     as exchange_1035_amt,
                                  NULL::NUMERIC(17, 4)                                                     as new_money_amt,
                                  NULL::NUMERIC(17, 4)                                                     as rollover_amt,
                                  NULL                                                                     as product_tier_cde,
                                  deposits_tax_year_nr,
                                  NULL::NUMERIC(9, 6)                                                      as fund_declared_interest_rt,
                                  NULL::NUMERIC(15, 8)                                                     as fund_unit_val_rt,
                                  NULL::NUMERIC(11, 6)                                                     as fund_units_cnt,
                                  transaction_reversal_cde,
                                  reversal_dt,
                                  transaction_source_id,
                                  transaction_memo_cde,
                                  source_transaction_cde,
                                  source_credit_debit_type_cde,
                                  transaction_dt,
                                  effective_dt,
                                  TXN_REVERSE_IND,
                                  SUM(AIFFI_FED_TAX_WITHHOLDING)
                                  over (PARTITION BY AIFFI_INTERNAL_TXN_ID)                                as transaction_amt,
                                  'HL'                                                                     as transaction_detail_type_cde,
                                  NULL                                                                     as company_cde,
                                  NULL                                                                     as fund_type_cde,
                                  alternate_admin_transaction_desc,
                                  admin_transaction_desc,
                                  transaction_reporting_desc,
                                  transaction_reporting_detail_desc,
                                  SOURCES.transaction_cde,
                                  TRIM(CD.transaction_debit_credit_cde)                                    as credit_debit_type_cde,
                                  system_dt,
                                  ROW_NUMBER() over (PARTITION BY AIFFI_INTERNAL_TXN_ID)                   as ROWNO
                           FROM FINTXN_SOURCE_HASH SOURCES
                                    LEFT JOIN edw_work.ref_transaction_credit_debit CD
                                              ON TRIM(CD.transaction_amt_type_cde) = 'HL'
                                                  AND TRIM(SOURCES.transaction_cde) = TRIM(CD.transaction_cde)
                           where AIFFI_FED_TAX_WITHHOLDING <> 0) SOURCE_HL
                  where ROWNO = 1
                    and transaction_amt <> 0

                  UNION ALL

                  select agreement_type_cde,
                         financial_transcation_source,
                         financial_transcation_type,
                         agreement_source_cde,
                         agreement_nr_pfx,
                         agreement_nr,
                         agreement_nr_sfx,
                         source_company_cde,
                         pt1_kind_cde,
                         product_id,
                         admin_fund_cde,
                         source_transaction_key_txt,
                         disbursement_transaction_nr_txt,
                         source_fund_type_cde,
                         transaction_duration_nr,
                         transfer_amt,
                         exchange_1035_amt,
                         new_money_amt,
                         rollover_amt,
                         product_tier_cde,
                         deposits_tax_year_nr,
                         fund_declared_interest_rt,
                         fund_unit_val_rt,
                         fund_units_cnt,
                         transaction_reversal_cde,
                         reversal_dt,
                         transaction_source_id,
                         transaction_memo_cde,
                         source_transaction_cde,
                         source_credit_debit_type_cde,
                         transaction_dt,
                         effective_dt,
                         CASE
                             WHEN UPPER(TRIM(TXN_REVERSE_IND)) = 'R' THEN ABS(transaction_amt) * -1
                             ELSE ABS(transaction_amt) END as transaction_amt,
                         transaction_detail_type_cde,
                         company_cde,
                         fund_type_cde,
                         alternate_admin_transaction_desc,
                         admin_transaction_desc,
                         transaction_reporting_desc,
                         transaction_reporting_detail_desc,
                         transaction_cde,
                         credit_debit_type_cde,
                         system_dt
                  from (
                           SELECT agreement_type_cde,
                                  financial_transcation_source,
                                  financial_transcation_type,
                                  agreement_source_cde,
                                  agreement_nr_pfx,
                                  agreement_nr,
                                  agreement_nr_sfx,
                                  NULL                                                                       as source_company_cde,
                                  NULL                                                                       as pt1_kind_cde,
                                  NULL                                                                       as product_id,
                                  NULL                                                                       as admin_fund_cde,
                                  source_transaction_key_txt,
                                  disbursement_transaction_nr_txt,
                                  NULL                                                                       as source_fund_type_cde,
                                  transaction_duration_nr,
                                  NULL::NUMERIC(17, 4)                                                       as transfer_amt,
                                  NULL::NUMERIC(17, 4)                                                       as exchange_1035_amt,
                                  NULL::NUMERIC(17, 4)                                                       as new_money_amt,
                                  NULL::NUMERIC(17, 4)                                                       as rollover_amt,
                                  NULL                                                                       as product_tier_cde,
                                  deposits_tax_year_nr,
                                  NULL::NUMERIC(9, 6)                                                        as fund_declared_interest_rt,
                                  NULL::NUMERIC(15, 8)                                                       as fund_unit_val_rt,
                                  NULL::NUMERIC(11, 6)                                                       as fund_units_cnt,
                                  transaction_reversal_cde,
                                  reversal_dt,
                                  transaction_source_id,
                                  transaction_memo_cde,
                                  source_transaction_cde,
                                  source_credit_debit_type_cde,
                                  transaction_dt,
                                  effective_dt,
                                  TXN_REVERSE_IND,
                                  SUM(AIFFI_STATE_TAX_WITHHOLDING)
                                  over (PARTITION BY AIFFI_INTERNAL_TXN_ID)                                  as transaction_amt,
                                  'ST'                                                                       as transaction_detail_type_cde,
                                  NULL                                                                       as company_cde,
                                  NULL                                                                       as fund_type_cde,
                                  alternate_admin_transaction_desc,
                                  admin_transaction_desc,
                                  transaction_reporting_desc,
                                  transaction_reporting_detail_desc,
                                  SOURCES.transaction_cde,
                                  TRIM(CD.transaction_debit_credit_cde)                                      as credit_debit_type_cde,
                                  system_dt,
                                  ROW_NUMBER() over (PARTITION BY AIFFI_INTERNAL_TXN_ID)                     as ROWNO
                           FROM FINTXN_SOURCE_HASH SOURCES
                                    LEFT JOIN edw_work.ref_transaction_credit_debit CD
                                              ON TRIM(CD.transaction_amt_type_cde) = 'ST'
                                                  AND TRIM(SOURCES.transaction_cde) = TRIM(CD.transaction_cde)
                           where AIFFI_STATE_TAX_WITHHOLDING <> 0) SOURCE_ST
                  where ROWNO = 1
                    and transaction_amt <> 0

                  UNION ALL

                  select agreement_type_cde,
                         financial_transcation_source,
                         financial_transcation_type,
                         agreement_source_cde,
                         agreement_nr_pfx,
                         agreement_nr,
                         agreement_nr_sfx,
                         source_company_cde,
                         pt1_kind_cde,
                         product_id,
                         admin_fund_cde,
                         source_transaction_key_txt,
                         disbursement_transaction_nr_txt,
                         source_fund_type_cde,
                         transaction_duration_nr,
                         transfer_amt,
                         exchange_1035_amt,
                         new_money_amt,
                         rollover_amt,
                         product_tier_cde,
                         deposits_tax_year_nr,
                         fund_declared_interest_rt,
                         fund_unit_val_rt,
                         fund_units_cnt,
                         transaction_reversal_cde,
                         reversal_dt,
                         transaction_source_id,
                         transaction_memo_cde,
                         source_transaction_cde,
                         source_credit_debit_type_cde,
                         transaction_dt,
                         effective_dt,
                         CASE
                             WHEN UPPER(TRIM(TXN_REVERSE_IND)) = 'R' THEN ABS(transaction_amt) * -1
                             ELSE ABS(transaction_amt) END as transaction_amt,
                         transaction_detail_type_cde,
                         company_cde,
                         fund_type_cde,
                         alternate_admin_transaction_desc,
                         admin_transaction_desc,
                         transaction_reporting_desc,
                         transaction_reporting_detail_desc,
                         transaction_cde,
                         credit_debit_type_cde,
                         system_dt
                  from (
                           SELECT agreement_type_cde,
                                  financial_transcation_source,
                                  financial_transcation_type,
                                  agreement_source_cde,
                                  agreement_nr_pfx,
                                  agreement_nr,
                                  agreement_nr_sfx,
                                  NULL                                                                   as source_company_cde,
                                  NULL                                                                   as pt1_kind_cde,
                                  NULL                                                                   as product_id,
                                  NULL                                                                   as admin_fund_cde,
                                  source_transaction_key_txt,
                                  disbursement_transaction_nr_txt,
                                  NULL                                                                   as source_fund_type_cde,
                                  transaction_duration_nr,
                                  NULL::NUMERIC(17, 4)                                                   as transfer_amt,
                                  NULL::NUMERIC(17, 4)                                                   as exchange_1035_amt,
                                  NULL::NUMERIC(17, 4)                                                   as new_money_amt,
                                  NULL::NUMERIC(17, 4)                                                   as rollover_amt,
                                  NULL                                                                   as product_tier_cde,
                                  deposits_tax_year_nr,
                                  NULL::NUMERIC(9, 6)                                                    as fund_declared_interest_rt,
                                  NULL::NUMERIC(15, 8)                                                   as fund_unit_val_rt,
                                  NULL::NUMERIC(11, 6)                                                   as fund_units_cnt,
                                  transaction_reversal_cde,
                                  reversal_dt,
                                  transaction_source_id,
                                  transaction_memo_cde,
                                  source_transaction_cde,
                                  source_credit_debit_type_cde,
                                  transaction_dt,
                                  effective_dt,
                                  TXN_REVERSE_IND,
                                  SUM(AIFFI_SURRENDER_PENALTY) over (PARTITION BY AIFFI_INTERNAL_TXN_ID) as transaction_amt,
                                  '62'                                                                   as transaction_detail_type_cde,
                                  NULL                                                                   as company_cde,
                                  NULL                                                                   as fund_type_cde,
                                  alternate_admin_transaction_desc,
                                  admin_transaction_desc,
                                  transaction_reporting_desc,
                                  transaction_reporting_detail_desc,
                                  SOURCES.transaction_cde,
                                  TRIM(CD.transaction_debit_credit_cde)                                  as credit_debit_type_cde,
                                  system_dt,
                                  ROW_NUMBER() over (PARTITION BY AIFFI_INTERNAL_TXN_ID)                 as ROWNO
                           FROM FINTXN_SOURCE_HASH SOURCES
                                    LEFT JOIN edw_work.ref_transaction_credit_debit CD
                                              ON TRIM(CD.transaction_amt_type_cde) = '62'
                                                  AND TRIM(SOURCES.transaction_cde) = TRIM(CD.transaction_cde)
                           where AIFFI_SURRENDER_PENALTY <> 0) SOURCE_62
                  where ROWNO = 1
                    and transaction_amt <> 0
					
				  UNION ALL
				  
				  select agreement_type_cde,
                         financial_transcation_source,
                         financial_transcation_type,
                         agreement_source_cde,
                         agreement_nr_pfx,
                         agreement_nr,
                         agreement_nr_sfx,
                         source_company_cde,
                         pt1_kind_cde,
                         product_id,
                         admin_fund_cde,
                         source_transaction_key_txt,
                         disbursement_transaction_nr_txt,
                         source_fund_type_cde,
                         transaction_duration_nr,
                         transfer_amt,
                         exchange_1035_amt,
                         new_money_amt,
                         rollover_amt,
                         product_tier_cde,
                         deposits_tax_year_nr,
                         fund_declared_interest_rt,
                         fund_unit_val_rt,
                         fund_units_cnt,
                         transaction_reversal_cde,
                         reversal_dt,
                         transaction_source_id,
                         transaction_memo_cde,
                         source_transaction_cde,
                         source_credit_debit_type_cde,
                         transaction_dt,
                         effective_dt,
                         CASE
                             WHEN UPPER(TRIM(TXN_REVERSE_IND)) = 'R' THEN ABS(transaction_amt) * -1
                             ELSE ABS(transaction_amt) END as transaction_amt,
                         transaction_detail_type_cde,
                         company_cde,
                         fund_type_cde,
                         alternate_admin_transaction_desc,
                         admin_transaction_desc,
                         transaction_reporting_desc,
                         transaction_reporting_detail_desc,
                         transaction_cde,
                         credit_debit_type_cde,
                         system_dt
                  from (
                           SELECT agreement_type_cde,
                                  financial_transcation_source,
                                  financial_transcation_type,
                                  agreement_source_cde,
                                  agreement_nr_pfx,
                                  agreement_nr,
                                  agreement_nr_sfx,
                                  NULL                                                                   as source_company_cde,
                                  NULL                                                                   as pt1_kind_cde,
                                  NULL                                                                   as product_id,
                                  NULL                                                                   as admin_fund_cde,
                                  source_transaction_key_txt,
                                  disbursement_transaction_nr_txt,
                                  NULL                                                                   as source_fund_type_cde,
                                  transaction_duration_nr,
                                  NULL::NUMERIC(17, 4)                                                   as transfer_amt,
                                  NULL::NUMERIC(17, 4)                                                   as exchange_1035_amt,
                                  NULL::NUMERIC(17, 4)                                                   as new_money_amt,
                                  NULL::NUMERIC(17, 4)                                                   as rollover_amt,
                                  NULL                                                                   as product_tier_cde,
                                  deposits_tax_year_nr,
                                  NULL::NUMERIC(9, 6)                                                    as fund_declared_interest_rt,
                                  NULL::NUMERIC(15, 8)                                                   as fund_unit_val_rt,
                                  NULL::NUMERIC(11, 6)                                                   as fund_units_cnt,
                                  transaction_reversal_cde,
                                  reversal_dt,
                                  transaction_source_id,
                                  transaction_memo_cde,
                                  source_transaction_cde,
                                  source_credit_debit_type_cde,
                                  transaction_dt,
                                  effective_dt,
                                  TXN_REVERSE_IND,
                                  SUM(AIFFI_STATE_TAX) over (PARTITION BY AIFFI_INTERNAL_TXN_ID) as transaction_amt,
                                  '68'                                                                   as transaction_detail_type_cde,
                                  NULL                                                                   as company_cde,
                                  NULL                                                                   as fund_type_cde,
                                  alternate_admin_transaction_desc,
                                  admin_transaction_desc,
                                  transaction_reporting_desc,
                                  transaction_reporting_detail_desc,
                                  SOURCES.transaction_cde,
                                  TRIM(CD.transaction_debit_credit_cde)                                  as credit_debit_type_cde,
                                  system_dt,
                                  ROW_NUMBER() over (PARTITION BY AIFFI_INTERNAL_TXN_ID)                 as ROWNO
                           FROM FINTXN_SOURCE_HASH SOURCES
                                    LEFT JOIN edw_work.ref_transaction_credit_debit CD
                                              ON TRIM(CD.transaction_amt_type_cde) = '68'
                                                  AND TRIM(SOURCES.transaction_cde) = TRIM(CD.transaction_cde)
                           where AIFFI_STATE_TAX <> 0) SOURCE_68
                  where ROWNO = 1
                    and transaction_amt <> 0

                  UNION ALL

                  --TNA Amount Type
                  SELECT agreement_type_cde,
                         financial_transcation_source,
                         financial_transcation_type,
                         agreement_source_cde,
                         agreement_nr_pfx,
                         agreement_nr,
                         agreement_nr_sfx,
                         source_company_cde,
                         pt1_kind_cde,
                         product_id,
                         admin_fund_cde,
                         source_transaction_key_txt,
                         disbursement_transaction_nr_txt,
                         source_fund_type_cde,
                         transaction_duration_nr,
                         CASE
                             WHEN UPPER(TRIM(TXN_REVERSE_IND)) = 'R' THEN ABS(transfer_amt) * -1
                             ELSE ABS(transfer_amt) END      as transfer_amt,
                         CASE
                             WHEN UPPER(TRIM(TXN_REVERSE_IND)) = 'R' THEN ABS(exchange_1035_amt) * -1
                             ELSE ABS(exchange_1035_amt) END as exchange_1035_amt,
                         CASE
                             WHEN UPPER(TRIM(TXN_REVERSE_IND)) = 'R' THEN ABS(new_money_amt) * -1
                             ELSE ABS(new_money_amt) END     as new_money_amt,
                         CASE
                             WHEN UPPER(TRIM(TXN_REVERSE_IND)) = 'R' THEN ABS(rollover_amt) * -1
                             ELSE ABS(rollover_amt) END      as rollover_amt,
                         product_tier_cde,
                         deposits_tax_year_nr,
                         fund_declared_interest_rt,
                         fund_unit_val_rt,
                         fund_units_cnt,
                         transaction_reversal_cde,
                         reversal_dt,
                         transaction_source_id,
                         transaction_memo_cde,
                         source_transaction_cde,
                         source_credit_debit_type_cde,
                         transaction_dt,
                         effective_dt,
                         CASE
                             WHEN UPPER(TRIM(TXN_REVERSE_IND)) = 'R' THEN ABS(transaction_amt) * -1
                             ELSE ABS(transaction_amt) END   as transaction_amt,
                         transaction_detail_type_cde,
                         company_cde,
                         fund_type_cde,
                         alternate_admin_transaction_desc,
                         admin_transaction_desc,
                         transaction_reporting_desc,
                         transaction_reporting_detail_desc,
                         transaction_cde,
                         credit_debit_type_cde,
                         system_dt
                  FROM (
                           SELECT agreement_type_cde,
                                  financial_transcation_source,
                                  financial_transcation_type,
                                  agreement_source_cde,
                                  agreement_nr_pfx,
                                  agreement_nr,
                                  agreement_nr_sfx,
                                  NULL                                                               as source_company_cde,
                                  NULL                                                               as pt1_kind_cde,
                                  NULL                                                               as product_id,
                                  NULL                                                               as admin_fund_cde,
                                  source_transaction_key_txt,
                                  disbursement_transaction_nr_txt,
                                  NULL                                                               as source_fund_type_cde,
                                  transaction_duration_nr,
                                  SUM(AIFFI_TRANSFER_AMT) over (PARTITION BY AIFFI_INTERNAL_TXN_ID)  as transfer_amt,
                                  SUM(AIFFI_1035_EXCH_AMT) over (PARTITION BY AIFFI_INTERNAL_TXN_ID) as exchange_1035_amt,
                                  SUM(AIFFI_NEW_MONEY_AMT) over (PARTITION BY AIFFI_INTERNAL_TXN_ID) as new_money_amt,
                                  SUM(AIFFI_ROLLOVER_AMT) over (PARTITION BY AIFFI_INTERNAL_TXN_ID)  as rollover_amt,
                                  NULL                                                               as product_tier_cde,
                                  deposits_tax_year_nr,
                                  NULL::NUMERIC(5, 3)                                                as fund_declared_interest_rt,
                                  NULL::NUMERIC(9, 6)                                                as fund_unit_val_rt,
                                  NULL::NUMERIC(11, 4)                                               as fund_units_cnt,
                                  transaction_reversal_cde,
                                  reversal_dt,
                                  transaction_source_id,
                                  transaction_memo_cde,
                                  source_transaction_cde,
                                  NULL as source_credit_debit_type_cde,
                                  transaction_dt,
                                  effective_dt,
                                  SUM(TXN_GROSS_AMT) over (PARTITION BY AIFFI_INTERNAL_TXN_ID)       as transaction_amt,
                                  'TNA'                                                              as transaction_detail_type_cde,
                                  NULL                                                               as company_cde,
                                  NULL                                                               as fund_type_cde,
                                  alternate_admin_transaction_desc,
                                  admin_transaction_desc,
                                  transaction_reporting_desc,
                                  transaction_reporting_detail_desc,
                                  SOURCES.transaction_cde,
                                  SOURCES.credit_debit_type_cde,
                                  system_dt,
                                  TXN_REVERSE_IND,
                                  ROW_NUMBER() over (PARTITION BY AIFFI_INTERNAL_TXN_ID)             as ROWNO
                           FROM FINTXN_SOURCE_HASH SOURCES) SOURCE_TNA
                  WHERE 1 = 1
                    and ROWNO = 1


                  UNION ALL
                  --TGA Amount Type
                  SELECT agreement_type_cde,
                         financial_transcation_source,
                         financial_transcation_type,
                         agreement_source_cde,
                         agreement_nr_pfx,
                         agreement_nr,
                         agreement_nr_sfx,
                         source_company_cde,
                         pt1_kind_cde,
                         product_id,
                         admin_fund_cde,
                         source_transaction_key_txt,
                         disbursement_transaction_nr_txt,
                         source_fund_type_cde,
                         transaction_duration_nr,
                         CASE
                             WHEN UPPER(TRIM(TXN_REVERSE_IND)) = 'R' THEN ABS(transfer_amt) * -1
                             ELSE ABS(transfer_amt) END      as transfer_amt,
                         CASE
                             WHEN UPPER(TRIM(TXN_REVERSE_IND)) = 'R' THEN ABS(exchange_1035_amt) * -1
                             ELSE ABS(exchange_1035_amt) END as exchange_1035_amt,
                         CASE
                             WHEN UPPER(TRIM(TXN_REVERSE_IND)) = 'R' THEN ABS(new_money_amt) * -1
                             ELSE ABS(new_money_amt) END     as new_money_amt,
                         CASE
                             WHEN UPPER(TRIM(TXN_REVERSE_IND)) = 'R' THEN ABS(rollover_amt) * -1
                             ELSE ABS(rollover_amt) END      as rollover_amt,
                         product_tier_cde,
                         deposits_tax_year_nr,
                         fund_declared_interest_rt,
                         fund_unit_val_rt,
                         fund_units_cnt,
                         transaction_reversal_cde,
                         reversal_dt,
                         transaction_source_id,
                         transaction_memo_cde,
                         source_transaction_cde,
                         source_credit_debit_type_cde,
                         transaction_dt,
                         effective_dt,
                         CASE
                             WHEN UPPER(TRIM(TXN_REVERSE_IND)) = 'R' THEN ABS(transaction_amt) * -1
                             ELSE ABS(transaction_amt) END   as transaction_amt,
                         transaction_detail_type_cde,
                         company_cde,
                         fund_type_cde,
                         alternate_admin_transaction_desc,
                         admin_transaction_desc,
                         transaction_reporting_desc,
                         transaction_reporting_detail_desc,
                         transaction_cde,
                         credit_debit_type_cde,
                         system_dt
                  FROM (
                           SELECT agreement_type_cde,
                                  financial_transcation_source,
                                  financial_transcation_type,
                                  agreement_source_cde,
                                  agreement_nr_pfx,
                                  agreement_nr,
                                  agreement_nr_sfx,
                                  NULL                                                               as source_company_cde,
                                  NULL                                                               as pt1_kind_cde,
                                  NULL                                                               as product_id,
                                  NULL                                                               as admin_fund_cde,
                                  source_transaction_key_txt,
                                  disbursement_transaction_nr_txt,
                                  NULL                                                               as source_fund_type_cde,
                                  transaction_duration_nr,
                                  SUM(AIFFI_TRANSFER_AMT) over (PARTITION BY AIFFI_INTERNAL_TXN_ID)  as transfer_amt,
                                  SUM(AIFFI_1035_EXCH_AMT) over (PARTITION BY AIFFI_INTERNAL_TXN_ID) as exchange_1035_amt,
                                  SUM(AIFFI_NEW_MONEY_AMT) over (PARTITION BY AIFFI_INTERNAL_TXN_ID) as new_money_amt,
                                  SUM(AIFFI_ROLLOVER_AMT) over (PARTITION BY AIFFI_INTERNAL_TXN_ID)  as rollover_amt,
                                  NULL                                                               as product_tier_cde,
                                  deposits_tax_year_nr,
                                  NULL::NUMERIC(9, 6)                                                as fund_declared_interest_rt,
                                  NULL::NUMERIC(15, 8)                                               as fund_unit_val_rt,
                                  NULL::NUMERIC(11, 6)                                               as fund_units_cnt,
                                  transaction_reversal_cde,
                                  reversal_dt,
                                  transaction_source_id,
                                  transaction_memo_cde,
                                  source_transaction_cde,
                                  NULL as source_credit_debit_type_cde,
                                  transaction_dt,
                                  effective_dt,
                                  CASE WHEN TRIM(TRAN_CD) IN ('GH','GHA','GHD','GHE','GHP','GHR','GHU','GHV') THEN 0
								  ELSE 
								  SUM(AIFFI_TOTAL_TXN_AMT) over (PARTITION BY AIFFI_INTERNAL_TXN_ID) END as transaction_amt,
                                  'TGA'                                                              as transaction_detail_type_cde,
                                  NULL                                                               as company_cde,
                                  NULL                                                               as fund_type_cde,
                                  alternate_admin_transaction_desc,
                                  admin_transaction_desc,
                                  transaction_reporting_desc,
                                  transaction_reporting_detail_desc,
                                  SOURCES.transaction_cde,
                                  SOURCES.credit_debit_type_cde,
                                  system_dt,
                                  TXN_REVERSE_IND,
                                  ROW_NUMBER() over (PARTITION BY AIFFI_INTERNAL_TXN_ID)             as ROWNO
                           FROM FINTXN_SOURCE_HASH SOURCES) SOURCE_TGA
                  WHERE 1 = 1
                    and ROWNO = 1

                  UNION ALL

--FTA amount type

                  SELECT agreement_type_cde,
                         financial_transcation_source,
                         financial_transcation_type,
                         agreement_source_cde,
                         agreement_nr_pfx,
                         agreement_nr,
                         agreement_nr_sfx,
                         source_company_cde,
                         pt1_kind_cde,
                         product_id,
                         admin_fund_cde,
                         source_transaction_key_txt,
                         disbursement_transaction_nr_txt,
                         source_fund_type_cde,
                         transaction_duration_nr,
                         transfer_amt,
                         exchange_1035_amt,
                         new_money_amt,
                         rollover_amt,
                         product_tier_cde,
                         deposits_tax_year_nr,
                         fund_declared_interest_rt,
                         fund_unit_val_rt,
                         fund_units_cnt,
                         transaction_reversal_cde,
                         reversal_dt,
                         transaction_source_id,
                         transaction_memo_cde,
                         source_transaction_cde,
                         source_credit_debit_type_cde,
                         transaction_dt,
                         effective_dt,
                         CASE
                             WHEN UPPER(TRIM(TXN_REVERSE_IND)) = 'R' THEN ABS(transaction_amt) * -1
                             ELSE ABS(transaction_amt) END as transaction_amt,
                         transaction_detail_type_cde,
                         company_cde,
                         fund_type_cde,
                         alternate_admin_transaction_desc,
                         admin_transaction_desc,
                         transaction_reporting_desc,
                         transaction_reporting_detail_desc,
                         transaction_cde,
                         credit_debit_type_cde,
                         system_dt
                  FROM (
                           SELECT agreement_type_cde,
                                  financial_transcation_source,
                                  financial_transcation_type,
                                  agreement_source_cde,
                                  agreement_nr_pfx,
                                  agreement_nr,
                                  agreement_nr_sfx,
                                  source_company_cde,
                                  pt1_kind_cde,
                                  product_id,
                                  admin_fund_cde,
                                  source_transaction_key_txt,
                                  disbursement_transaction_nr_txt,
                                  source_fund_type_cde,
                                  transaction_duration_nr,
                                  NULL::NUMERIC(17, 4) as transfer_amt,
                                  NULL::NUMERIC(17, 4) as exchange_1035_amt,
                                  NULL::NUMERIC(17, 4) as new_money_amt,
                                  NULL::NUMERIC(17, 4) as rollover_amt,
                                  product_tier_cde,
                                  deposits_tax_year_nr,
                                  SUM(AIFFI_DECLARED_RATE)
                                  OVER (PARTITION BY AIFFI_INTERNAL_TXN_ID,POLICY_ID,pt1_kind_cde,product_id,admin_fund_cde,product_tier_cde,fund_type_cde,SOURCES.credit_debit_type_cde)
                                                       as fund_declared_interest_rt,
                                  SUM(AIFFI_FUND_UNIT_VAL)
                                  OVER (PARTITION BY AIFFI_INTERNAL_TXN_ID,POLICY_ID,pt1_kind_cde,product_id,admin_fund_cde,product_tier_cde,fund_type_cde,SOURCES.credit_debit_type_cde)
                                                       as fund_unit_val_rt,
                                  SUM(AIFFI_TXN_FUND_UNITS)
                                  OVER (PARTITION BY AIFFI_INTERNAL_TXN_ID,POLICY_ID,pt1_kind_cde,product_id,admin_fund_cde,product_tier_cde,fund_type_cde,SOURCES.credit_debit_type_cde)
                                                       as fund_units_cnt,
                                  transaction_reversal_cde,
                                  reversal_dt,
                                  transaction_source_id,
                                  transaction_memo_cde,
                                  source_transaction_cde,
                                  source_credit_debit_type_cde,
                                  transaction_dt,
                                  effective_dt,
                                  SUM(TXN_GROSS_AMT)
                                  OVER (PARTITION BY AIFFI_INTERNAL_TXN_ID,POLICY_ID,pt1_kind_cde,product_id,admin_fund_cde,product_tier_cde,fund_type_cde,SOURCES.credit_debit_type_cde)
                                                       as transaction_amt,
                                  'FTA'                as transaction_detail_type_cde,
                                  company_cde,
                                  fund_type_cde,
                                  alternate_admin_transaction_desc,
                                  admin_transaction_desc,
                                  transaction_reporting_desc,
                                  transaction_reporting_detail_desc,
                                  SOURCES.transaction_cde,
                                  SOURCES.credit_debit_type_cde,
                                  TXN_REVERSE_IND,
                                  system_dt,
                                  ROW_NUMBER()
                                  OVER (PARTITION BY AIFFI_INTERNAL_TXN_ID,POLICY_ID,pt1_kind_cde,product_id,admin_fund_cde,product_tier_cde,fund_type_cde,SOURCES.credit_debit_type_cde)
                                                       as ROWNO
                           FROM FINTXN_SOURCE_HASH SOURCES) SOURCE_FTA
                  WHERE ROWNO = 1
                    and transaction_amt <> 0
              ) FACT) FACT_FIN_DETAIL
;


/* EDW_WORK.AIFRPS_DIM_FINANCIAL_TRANSACTION_REPLACEMENT - INSERTS
 *
 * THIS SCRIPT IS USED TO LOAD THE RECORDS THAT DON'T HAVE A RECORD IN TARGET
 *
 */

select analyze_statistics('EDW_STAGING.AIFRPS_FACT_FINANCIAL_DETAIL_PRE_WORK');


INSERT INTO EDW_WORK.AIFRPS_FACT_FINANCIAL_DETAIL

(FACT_FINANCIAL_DETAIL_NATURAL_KEY_HASH_UUID,
 DIM_FINANCIAL_TRANSACTION_NATURAL_KEY_HASH_UUID,
 CALENDAR_DT,
 TRANSACTION_DETAIL_TYPE_CDE,
 TRANSACTION_DETAIL_CATEGORY_CDE,
 TRANSACTION_DETAIL_METHOD_CDE,
 SOURCE_TRANSACTION_DETAIL_CATEGORY_CDE,
 SOURCE_TRANSACTION_DETAIL_METHOD_CDE,
 SOURCE_TRANSACTION_DETAIL_TYPE_CDE,
 TRANSACTION_AMT,
 ROW_PROCESS_DTM,
 AUDIT_ID,
 LOGICAL_DELETE_IND,
 CHECK_SUM,
 SOURCE_SYSTEM_ID,
 RESTRICTED_ROW_IND,
 UPDATE_AUDIT_ID,
 SOURCE_DELETE_IND,
 CREDIT_DEBIT_TYPE_CDE,
 SOURCE_CREDIT_DEBIT_TYPE_CDE,
 TRANSACTION_SEQUENCE_NR,
 WAIVER_REASON_CDE,
 SOURCE_WAIVER_REASON_CDE,
 MONEY_SOURCE_CDE,
 SOURCE_MONEY_SOURCE_CDE,
 BILL_MODE_CDE,
 SOURCE_BILL_MODE_CDE,
 PREMIUM_PAID_DT,
 PREMIUM_DUE_DT,
 TRANSACTION_DURATION_NR,
 DEPOSITS_TAX_YEAR_NR,
 FUND_UNITS_CNT,
 FUND_UNIT_VAL_RT,
 FUND_DECLARED_INTEREST_RT,
 BASIS_POINTS_VAL,
 COMMISSION_OVERDUE_PCT,
 BONUS_RT,
 POST_TEFRA_COST_BASIS_AMT,
 PRE_TEFRA_COST_BASIS_AMT,
 ROLLOVER_AMT,
 NEW_MONEY_AMT,
 EXCHANGE_1035_AMT,
 TRANSFER_AMT,
 PREMIUM_DUE_AMT,
 INTEREST_DUE_AMT,
 PREMIUM_PAYMENT_CASH_AMT,
 WAIVER_PREMIUM_PAYMENT_CASH_AMT,
 PREMIUM_PAYMENT_LOAN_AMT,
 PREMIUM_PAYMENT_DIVIDEND_AMT,
 PREMIUM_PAYMENT_ABR_DIVIDEND_AMT)

SELECT FACT_FINANCIAL_DETAIL_NATURAL_KEY_HASH_UUID,
       DIM_FINANCIAL_TRANSACTION_NATURAL_KEY_HASH_UUID,
       CALENDAR_DT,
       TRANSACTION_DETAIL_TYPE_CDE,
       TRANSACTION_DETAIL_CATEGORY_CDE,
       TRANSACTION_DETAIL_METHOD_CDE,
       SOURCE_TRANSACTION_DETAIL_CATEGORY_CDE,
       SOURCE_TRANSACTION_DETAIL_METHOD_CDE,
       SOURCE_TRANSACTION_DETAIL_TYPE_CDE,
       TRANSACTION_AMT,
       ROW_PROCESS_DTM,
       AUDIT_ID,
       LOGICAL_DELETE_IND,
       CHECK_SUM,
       SOURCE_SYSTEM_ID,
       RESTRICTED_ROW_IND,
       UPDATE_AUDIT_ID,
       SOURCE_DELETE_IND,
       CREDIT_DEBIT_TYPE_CDE,
       SOURCE_CREDIT_DEBIT_TYPE_CDE,
       TRANSACTION_SEQUENCE_NR,
       WAIVER_REASON_CDE,
       SOURCE_WAIVER_REASON_CDE,
       MONEY_SOURCE_CDE,
       SOURCE_MONEY_SOURCE_CDE,
       BILL_MODE_CDE,
       SOURCE_BILL_MODE_CDE,
       PREMIUM_PAID_DT,
       PREMIUM_DUE_DT,
       TRANSACTION_DURATION_NR,
       DEPOSITS_TAX_YEAR_NR,
       FUND_UNITS_CNT,
       FUND_UNIT_VAL_RT,
       FUND_DECLARED_INTEREST_RT,
       BASIS_POINTS_VAL,
       COMMISSION_OVERDUE_PCT,
       BONUS_RT,
       POST_TEFRA_COST_BASIS_AMT,
       PRE_TEFRA_COST_BASIS_AMT,
       ROLLOVER_AMT,
       NEW_MONEY_AMT,
       EXCHANGE_1035_AMT,
       TRANSFER_AMT,
       PREMIUM_DUE_AMT,
       INTEREST_DUE_AMT,
       PREMIUM_PAYMENT_CASH_AMT,
       WAIVER_PREMIUM_PAYMENT_CASH_AMT,
       PREMIUM_PAYMENT_LOAN_AMT,
       PREMIUM_PAYMENT_DIVIDEND_AMT,
       PREMIUM_PAYMENT_ABR_DIVIDEND_AMT

FROM EDW_STAGING.AIFRPS_FACT_FINANCIAL_DETAIL_PRE_WORK

--INSERT WHEN NO RECORDS IN TARGET TABLE INSERT ONLY
WHERE FACT_FINANCIAL_DETAIL_NATURAL_KEY_HASH_UUID NOT IN
      (SELECT DISTINCT FACT_FINANCIAL_DETAIL_NATURAL_KEY_HASH_UUID
       FROM edw_financial_transactions.FACT_FINANCIAL_DETAIL WHERE SOURCE_SYSTEM_ID IN ('72','266'))
;

select analyze_statistics('edw_work.aifrps_fact_financial_detail');