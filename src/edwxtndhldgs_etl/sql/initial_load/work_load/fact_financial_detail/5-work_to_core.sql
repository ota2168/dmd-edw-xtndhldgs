insert into edw_work.fact_financial_detail_aifrps
(
    fact_financial_detail_natural_key_hash_uuid,
    dim_financial_transaction_natural_key_hash_uuid,
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
)

select DISTINCT
UUID_GEN(
               PREHASH_VALUE(
               Clean_String(SRC.agreement_source_cde),
               Clean_String('Ipa'),
               Clean_String(SRC.agreement_nr_pfx),
               SRC.agreement_nr,
               Clean_String(SRC.agreement_nr_sfx),
               Clean_String(SRC.source_transaction_key_txt),
               SRC.transaction_dt),
				SRC.transaction_dt,
                Clean_String(financial_transaction_source),
                Clean_String(financial_transaction_type),
                reversal_dt,
                effective_dt,
                system_dt,
                Clean_String(transaction_cde),
                Clean_String(source_transaction_cde),
                Clean_String(transaction_reversal_cde),
                Clean_String(admin_fund_cde),
                Clean_String(product_id),
                Clean_String(company_cde),
                Clean_String(pt1_kind_cde),
				Clean_String(product_tier_cde),
                Clean_String(fund_type_cde),
                Clean_String(coverage_type_cde),
                coverage_occurance_nr,
                SRC.calendar_dt,
                Clean_String(SRC.transaction_detail_type_cde),
                Clean_String(SRC.credit_debit_type_cde),
                SRC.Transaction_sequence_nr
        )::UUID		                                                as fact_financial_transaction_natural_key_hash_uuid,
UUID_GEN(
                PREHASH_VALUE(
               Clean_String(SRC.agreement_source_cde),
               Clean_String('Ipa'),
               Clean_String(SRC.agreement_nr_pfx),
               SRC.agreement_nr,
               Clean_String(SRC.agreement_nr_sfx),
               Clean_String(SRC.source_transaction_key_txt),
               SRC.transaction_dt),
				SRC.transaction_dt,
                Clean_String(financial_transaction_source),
                Clean_String(financial_transaction_type),
                reversal_dt,
                effective_dt,
                system_dt,
                Clean_String(transaction_cde),
                Clean_String(source_transaction_cde),
                Clean_String(transaction_reversal_cde),
                Clean_String(admin_fund_cde),
                Clean_String(product_id),
                Clean_String(company_cde),
                Clean_String(pt1_kind_cde),
				Clean_String(product_tier_cde),
                Clean_String(fund_type_cde),
                Clean_String(coverage_type_cde),
                coverage_occurance_nr
         )::UUID                                                       as dim_financial_transaction_natural_key_hash_uuid,
            SRC.calendar_dt,
            SRC.transaction_detail_type_cde,
            SRC.transaction_detail_category_cde,
            SRC.transaction_detail_method_cde,
            SRC.source_transaction_detail_category_cde,
            SRC.source_transaction_detail_method_cde,
            SRC.source_transaction_detail_type_cde,
            SRC.transaction_amt,
            SRC.row_process_dtm,
            SRC.audit_id,
            SRC.logical_delete_ind,
            SRC.check_sum,
            SRC.source_system_id,
            SRC.restricted_row_ind,
            --row_sid,
            SRC.update_audit_id,
            SRC.source_delete_ind,
            SRC.credit_debit_type_cde,
            SRC.source_credit_debit_type_cde,
            SRC.transaction_sequence_nr,
            SRC.waiver_reason_cde,
            SRC.source_waiver_reason_cde,
            SRC.money_source_cde,
            SRC.source_money_source_cde,
            SRC.bill_mode_cde,
            SRC.source_bill_mode_cde,
            SRC.premium_paid_dt,
            SRC.premium_due_dt,
            SRC.transaction_duration_nr,
            SRC.deposits_tax_year_nr,
            SRC.fund_units_cnt,
            SRC.fund_unit_val_rt,
            SRC.fund_declared_interest_rt,
            SRC.basis_points_val,
            SRC.commission_overdue_pct,
            SRC.bonus_rt,
            SRC.post_tefra_cost_basis_amt,
            SRC.pre_tefra_cost_basis_amt,
            SRC.rollover_amt,
            SRC.new_money_amt,
            SRC.exchange_1035_amt,
            SRC.transfer_amt,
            SRC.premium_due_amt,
            SRC.interest_due_amt,
            SRC.premium_payment_cash_amt,
            SRC.waiver_premium_payment_cash_amt,
            SRC.premium_payment_loan_amt,
            SRC.premium_payment_dividend_amt,
            SRC.premium_payment_abr_dividend_amt
from (
         select
                fact_txn.carr_admin_sys_cd              as agreement_source_cde,
                fact_txn.carr_admin_sys_cd              as financial_transaction_source,
                'Financial Transaction'                 as financial_transaction_type,
                fact_txn.src_txn_nr                     as source_transaction_key_txt,
                fact_txn.hldg_key_pfx                   as agreement_nr_pfx,
                fact_txn.hldg_key                       as agreement_nr,
                fact_txn.hldg_key_sfx                   as agreement_nr_sfx,
                fact_txn.rvrsl_dt                       as reversal_dt,
                fact_txn.eff_dt                         as effective_dt,
                fact_txn.sys_dt                         as system_dt,
                fact_txn.txn_cd                         as transaction_cde,
                fact_txn.src_txn_cd                     as source_transaction_cde,
                fact_txn.cycle_dt                       as transaction_dt,
                fact_txn.rvrsl_ind                      as transaction_reversal_cde,
                fact_txn.admin_fnd_nr                   as admin_fund_cde,
                fact_txn.prod_id                        as product_id,
              --fact_txn.prod_tier_cd                   as product_tier_cde,
                CASE
                    when trim(fact_txn.prod_tier_cd)='' then '0'
                    when fact_txn.prod_tier_cd is null then '0'
                    when regexp_ilike(fact_txn.prod_tier_cd, '[A-Z]')
                        then fact_txn.prod_tier_cd
                ELSE
                    ((fact_txn.prod_tier_cd::int)::Varchar)
                END                                     as product_tier_cde,
                fact_txn.carrier_cd                     as company_cde,
                fact_txn.kind_cd                        as pt1_kind_cde,
                fact_txn.fnd_typ_cd                     as fund_type_cde,
                fact_txn.cvg_typ_cd                     as coverage_type_cde,
                case
                    when fact_txn.cvg_occur_nr is null then NULL::int
                    --when fact_txn.cvg_occur_nr = ''    then NULL::int
                        else
                         fact_txn.cvg_occur_nr::int
                end                                     as coverage_occurance_nr,
                fact_txn.cycle_dt                       as calendar_dt,
                fact_txn.txn_amt_typ_cd                 as transaction_detail_type_cde,
                NULL                                    as transaction_detail_category_cde,
                NULL                                    as transaction_detail_method_cde,
                NULL                                    as source_transaction_detail_category_cde,
                NULL                                    as source_transaction_detail_method_cde,
                fact_txn.src_txn_amt_typ_cd             as source_transaction_detail_type_cde,
                fact_txn.txn_amt                        as transaction_amt,
                current_timestamp(6)                    as row_process_dtm,
                fact_txn.run_id                         as audit_id,
                false::boolean                          as logical_delete_ind,
                uuid_gen
                        (
                        null::varchar
                        )::uuid                         as check_sum,
                266                                     as source_system_id,
                'false'::boolean                        as restricted_row_ind,
                fact_txn.updt_run_id                    as update_audit_id,
                false::boolean                          as source_delete_ind,
                fact_txn.credit_debit_ind               as credit_debit_type_cde,
                fact_txn.src_credit_debit_ind           as source_credit_debit_type_cde,
                fact_txn.RNO                            as transaction_sequence_nr,
                fact_txn.waiver_rsn_cd                  as waiver_reason_cde,
                fact_txn.src_waiver_rsn_cd              as source_waiver_reason_cde,
                fact_txn.money_src_cd                   as money_source_cde,
                fact_txn.src_money_src_cd               as source_money_source_cde,
                fact_txn.bill_mode_cd                   as bill_mode_cde,
                fact_txn.src_bill_mode_cd               as source_bill_mode_cde,
                fact_txn.paid_to_dt                     as premium_paid_dt,
                fact_txn.premium_due_dt                 as premium_due_dt,
                fact_txn.txn_duration                   as transaction_duration_nr,
                case
                when fact_txn.tax_year is null then NULL::int
                when fact_txn.tax_year = ''    then NULL::int
                    else
                     fact_txn.tax_year::int
                end                                     as deposits_tax_year_nr,
                fact_txn.fnd_nr_units                   as fund_units_cnt,
                fact_txn.fnd_unit_val_amt               as fund_unit_val_rt,
                fact_txn.deposit_perd_int_rt            as fund_declared_interest_rt,
                fact_txn.basis_points                   as basis_points_val,
                fact_txn.comm_ovrd_rt                   as commission_overdue_pct,
                fact_txn.bonus_rt                       as bonus_rt,
                fact_txn.post_tef_cb                    as post_tefra_cost_basis_amt,
                fact_txn.pre_tef_cb                     as pre_tefra_cost_basis_amt,
                fact_txn.txn_rollover_amt               as rollover_amt,
                fact_txn.txn_new_money_amt              as new_money_amt,
                fact_txn.txn_1035_xchg_amt              as exchange_1035_amt,
                fact_txn.txn_transfer_amt               as transfer_amt,
                fact_txn.premium_due_amt                as premium_due_amt,
                fact_txn.interest_due_amt               as interest_due_amt,
                fact_txn.premium_payment_cash           as premium_payment_cash_amt,
                fact_txn.pw_prem_payment_cash           as waiver_premium_payment_cash_amt,
                fact_txn.premium_payment_loan           as premium_payment_loan_amt,
                fact_txn.preimum_payment_dividend       as premium_payment_dividend_amt,
                fact_txn.premium_payment_abr            as premium_payment_abr_dividend_amt
from
		 (
		  SELECT * FROM (
			SELECT FIN_TX.*,
			ROW_NUMBER() OVER (PARTITION BY AGMT_ID,CARR_ADMIN_SYS_CD,HLDG_KEY_PFX,HLDG_KEY,HLDG_KEY_SFX,SRC_TXN_NR,TXN_CD,SRC_TXN_CD,EFF_DT,RVRSL_DT,RVRSL_IND,CREDIT_DEBIT_IND,TXN_AMT_TYP_CD,FND_ID,TRANS_DT ORDER BY TXN_ID DESC) AS RNO
		FROM  PROD_STND_VW_TERSUN.AGMT_FIN_TXN_VW_AIF_RPS FIN_TX WHERE FIN_TX.SRC_SYS_ID=72
			)A
			--WHERE RNO=1
		)fact_txn
) SRC;