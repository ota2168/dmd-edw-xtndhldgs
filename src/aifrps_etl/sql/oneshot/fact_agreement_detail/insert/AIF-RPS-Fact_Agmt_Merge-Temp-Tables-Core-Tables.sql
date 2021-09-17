--Take backups before merging for dim and fact agmt
select copy_table ('edw_tdsunset.fact_agreement_detail', 'edw_tdsunset.fact_agreement_detail_08222021_before_aifrps_initial_merge');

insert into edw_tdsunset.fact_agreement_detail
(
    fact_agreement_detail_natural_key_hash_uuid,
    dim_agreement_natural_key_hash_uuid,
    pay7_period_premium_amt,
    pay7_period_premium_end_dt,
    pay7_period_premium_end_dt_quality_cde,
    pay7_period_premium_quality_cde,
    pay7_period_premium_start_dt,
    pay7_period_premium_start_dt_quality_cde,
    tcc_amt,
    total_monthly_benefit_amt,
    ultimate_face_amt,
    grace_period_payment_amt,
    grace_period_payment_quality_cde,
    policy_unit_face_amt,
    policy_income_amt,
    agreement_dividend_year_nr,
    current_dividend_amt,
    accumulated_dividend_amt,
    accumulated_dividend_quality_cde,
    rp_current_dividend_month_txt,
    rp_current_dividend_year_txt,
    rp_current_dividend_amt,
    rp_dividend_amt,
    rp_dividend_amt_quality_cde,
    ri_dividend_amt_quality_cde,
    ri_dividend_amt,
    applied_dividend_amt,
    applied_dividend_quality_cde,
    base_dividend_amt,
    base_dividend_quality_cde,
    previous_year_dividend_amt,
    previous_year_dividend_quality_cde,
    dividend_accumulated_available_amt,
    dividend_accumulated_available_quality_cde,
    dividend_available_amt,
    dividend_available_quality_cde,
    last_dividend_credit_amt,
    last_dividend_credit_quality_cde,
    ltcir_dividend_benefit_pool_amt,
    ltcir_dividend_benefit_pool_quality_cde,
    interest_on_dividend_accumulated_to_dt_amt,
    interest_on_dividend_accumulated_to_dt_quality_cde,
    settlement_dividend_amt,
    settlement_dividend_quality_cde,
    dividend_accumulated_tax_amt,
    dividend_accumulated_tax_quality_cde,
    dividend_mo_da,
    bill_mode_cde,
    ebill_preference_cde,
    no_bill_reason_cde,
    bill_frequency_txt,
    premium_tax_state_cde,
    returned_check_cde,
    sdo_mpo_apo_cde,
    paid_in_advance_year_cnt,
    sdo_payment_type_cde,
    policy_fee_ind,
    first_year_ind,
    ipo_ind,
    ltc_activity_cde,
    ltc_premium_adjustment_ind,
    late_payment_offer_end_dt,
    vanishing_premium_effective_dt,
    alir_bill_premium_amt,
    alir_bill_premium_quality_cde,
    al_sup_termination_amt,
    mpo_apo_net_payment_due_amt,
    mpo_apo_net_payment_quality_cde,
    mpo_apo_paid_amt,
    apo_credit_amt,
    annual_premium_amt,
    annual_premium_quality_cde,
    base_rider_monthly_premium_amt,
    base_rider_monthly_premium_quality_cde,
    base_rider_annual_premium_amt,
    bill_premium_amt,
    bill_premium_quality_cde,
    cli_premium_bill_cde,
    cost_due_amt,
    cost_basis_amt,
    cost_basis_quality_cde,
    current_premium_credit_base_amt,
    current_year_payment_amt,
    current_premium_credit_ltc_amt,
    current_premium_credit_ltc_quality_cde,
    next_year_premium_credit_ltc_amt,
    next_year_premium_credit_ltc_quality_cde,
    ewl_deficit_premium_payup_amt,
    ewl_deficit_paid_to_year_month_txt,
    fraction_premium_credit_base_amt,
    fraction_premium_credit_ltc_amt,
    fraction_premium_credit_ltc_quality_cde,
    gross_annual_premium_amt,
    gross_annual_premium_quality_cde,
    gross_premium_fpdup_addns_amt,
    ltcir_return_premium_amt,
    ltcir_return_premium_quality_cde,
    ltcir_reduced_addns_amt,
    ltcir_reduced_addns_quality_cde,
    ltc_extended_benefit_pool_amt,
    ltc_extended_benefit_pool_quality_cde,
    max_annual_payment_year_nr,
    new_business_premium_paid_amt,
    next_year_premium_credit_base_amt,
    target_premium_amt,
    target_premium_quality_cde,
    total_monthly_premium_amt,
    total_monthly_premium_quality_cde,
    unearned_past_due_premium_amt,
    unearned_past_due_premium_quality_cde,
    vanish_bill_amt,
    mpo_apo_paid_amt_quality_cde,
    apo_credit_amt_quality_cde,
    base_rider_annual_premium_quality_cde,
    current_premium_credit_base_quality_cde,
    fraction_premium_credit_base_quality_cde,
    gross_premium_fpdup_addns_quality_cde,
    next_year_premium_credit_base_quality_cde,
    lisr_disability_cost_amt,
    payment_draft_dy_cde,
    ytd_premium_amt,
    invoice_account_id_txt,
    group_account_type_cde,
    group_account_nr_txt,
    last_bill_method_cde,
    pac_account_id_txt,
    pac_account_type_cde,
    bank_nm,
    billing_arrangement_id_txt,
    bill_method_type_cde,
    consolidated_bill_type_cde,
    annualized_premium_amt,
    alir_bill_amt,
    alir_bill_amt_quality_cde,
    bank_id,
    permenant_flat_extra_premium_amt,
    temperory_flat_extra_premium_amt,
    permenant_flat_extra_cost_amt,
    temperory_flat_extra_cost_amt,
    total_annual_premium_amt,
    total_annual_premium_quality_cde,
    source_bill_mode_cde,
    initial_premium_amt,
    pytd_premium_amt,
    premium_refund_amt,
    premium_refund_quality_cde,
    pro_rata_refund_amt,
    pro_rata_refund_quality_cde,
    advance_premium_refund_amt,
    advance_premium_refund_quality_cde,
    paid_to_dt,
    paid_to_dt_txt,
    last_premium_adjustment_dt,
    last_premium_collection_dt,
    last_premium_paid_dt,
    last_transaction_dt,
    premium_accumulated_amt_quality_cde,
    premium_accumulated_amt,
    source_delete_ind,
    last_deposit_dt,
    last_deposit_amt,
    last_deposit_amt_quality_cde,
    administration_charge_amt,
    minus_1_tax_rt,
    bill_to_dt,
    apm_next_bill_dt,
    last_premium_paid_amt,
    begin_dt,
    begin_dtm,
    row_process_dtm,
    audit_id,
    update_audit_id,
    logical_delete_ind,
    check_sum,
    current_row_ind,
    end_dt,
    end_dtm,
    source_system_id,
    restricted_row_ind,
    transaction_dt,
    transaction_dtm
)
select
    fact_agreement_detail_natural_key_hash_uuid,
    dim_agreement_natural_key_hash_uuid,
    pay7_period_premium_amt,
    pay7_period_premium_end_dt,
    pay7_period_premium_end_dt_quality_cde,
    pay7_period_premium_quality_cde,
    pay7_period_premium_start_dt,
    pay7_period_premium_start_dt_quality_cde,
    tcc_amt,
    total_monthly_benefit_amt,
    ultimate_face_amt,
    grace_period_payment_amt,
    grace_period_payment_quality_cde,
    policy_unit_face_amt,
    policy_income_amt,
    agreement_dividend_year_nr,
    current_dividend_amt,
    accumulated_dividend_amt,
    accumulated_dividend_quality_cde,
    rp_current_dividend_month_txt,
    rp_current_dividend_year_txt,
    rp_current_dividend_amt,
    rp_dividend_amt,
    rp_dividend_amt_quality_cde,
    ri_dividend_amt_quality_cde,
    ri_dividend_amt,
    applied_dividend_amt,
    applied_dividend_quality_cde,
    base_dividend_amt,
    base_dividend_quality_cde,
    previous_year_dividend_amt,
    previous_year_dividend_quality_cde,
    dividend_accumulated_available_amt,
    dividend_accumulated_available_quality_cde,
    dividend_available_amt,
    dividend_available_quality_cde,
    last_dividend_credit_amt,
    last_dividend_credit_quality_cde,
    ltcir_dividend_benefit_pool_amt,
    ltcir_dividend_benefit_pool_quality_cde,
    interest_on_dividend_accumulated_to_dt_amt,
    interest_on_dividend_accumulated_to_dt_quality_cde,
    settlement_dividend_amt,
    settlement_dividend_quality_cde,
    dividend_accumulated_tax_amt,
    dividend_accumulated_tax_quality_cde,
    dividend_mo_da,
    bill_mode_cde,
    ebill_preference_cde,
    no_bill_reason_cde,
    bill_frequency_txt,
    premium_tax_state_cde,
    returned_check_cde,
    sdo_mpo_apo_cde,
    paid_in_advance_year_cnt,
    sdo_payment_type_cde,
    policy_fee_ind,
    first_year_ind,
    ipo_ind,
    ltc_activity_cde,
    ltc_premium_adjustment_ind,
    late_payment_offer_end_dt,
    vanishing_premium_effective_dt,
    alir_bill_premium_amt,
    alir_bill_premium_quality_cde,
    al_sup_termination_amt,
    mpo_apo_net_payment_due_amt,
    mpo_apo_net_payment_quality_cde,
    mpo_apo_paid_amt,
    apo_credit_amt,
    annual_premium_amt,
    annual_premium_quality_cde,
    base_rider_monthly_premium_amt,
    base_rider_monthly_premium_quality_cde,
    base_rider_annual_premium_amt,
    bill_premium_amt,
    bill_premium_quality_cde,
    cli_premium_bill_cde,
    cost_due_amt,
    cost_basis_amt,
    cost_basis_quality_cde,
    current_premium_credit_base_amt,
    current_year_payment_amt,
    current_premium_credit_ltc_amt,
    current_premium_credit_ltc_quality_cde,
    next_year_premium_credit_ltc_amt,
    next_year_premium_credit_ltc_quality_cde,
    ewl_deficit_premium_payup_amt,
    ewl_deficit_paid_to_year_month_txt,
    fraction_premium_credit_base_amt,
    fraction_premium_credit_ltc_amt,
    fraction_premium_credit_ltc_quality_cde,
    gross_annual_premium_amt,
    gross_annual_premium_quality_cde,
    gross_premium_fpdup_addns_amt,
    ltcir_return_premium_amt,
    ltcir_return_premium_quality_cde,
    ltcir_reduced_addns_amt,
    ltcir_reduced_addns_quality_cde,
    ltc_extended_benefit_pool_amt,
    ltc_extended_benefit_pool_quality_cde,
    max_annual_payment_year_nr,
    new_business_premium_paid_amt,
    next_year_premium_credit_base_amt,
    target_premium_amt,
    target_premium_quality_cde,
    total_monthly_premium_amt,
    total_monthly_premium_quality_cde,
    unearned_past_due_premium_amt,
    unearned_past_due_premium_quality_cde,
    vanish_bill_amt,
    mpo_apo_paid_amt_quality_cde,
    apo_credit_amt_quality_cde,
    base_rider_annual_premium_quality_cde,
    current_premium_credit_base_quality_cde,
    fraction_premium_credit_base_quality_cde,
    gross_premium_fpdup_addns_quality_cde,
    next_year_premium_credit_base_quality_cde,
    lisr_disability_cost_amt,
    payment_draft_dy_cde,
    ytd_premium_amt,
    invoice_account_id_txt,
    group_account_type_cde,
    group_account_nr_txt,
    last_bill_method_cde,
    pac_account_id_txt,
    pac_account_type_cde,
    bank_nm,
    billing_arrangement_id_txt,
    bill_method_type_cde,
    consolidated_bill_type_cde,
    annualized_premium_amt,
    alir_bill_amt,
    alir_bill_amt_quality_cde,
    bank_id,
    permenant_flat_extra_premium_amt,
    temperory_flat_extra_premium_amt,
    permenant_flat_extra_cost_amt,
    temperory_flat_extra_cost_amt,
    total_annual_premium_amt,
    total_annual_premium_quality_cde,
    source_bill_mode_cde,
    initial_premium_amt,
    pytd_premium_amt,
    premium_refund_amt,
    premium_refund_quality_cde,
    pro_rata_refund_amt,
    pro_rata_refund_quality_cde,
    advance_premium_refund_amt,
    advance_premium_refund_quality_cde,
    paid_to_dt,
    paid_to_dt_txt,
    last_premium_adjustment_dt,
    last_premium_collection_dt,
    last_premium_paid_dt,
    last_transaction_dt,
    premium_accumulated_amt_quality_cde,
    premium_accumulated_amt,
    source_delete_ind,
    last_deposit_dt,
    last_deposit_amt,
    last_deposit_amt_quality_cde,
    administration_charge_amt,
    minus_1_tax_rt,
    bill_to_dt,
    apm_next_bill_dt,
    last_premium_paid_amt,
    begin_dt,
    begin_dtm,
    row_process_dtm,
    audit_id,
    update_audit_id,
    logical_delete_ind,
    check_sum,
    current_row_ind,
    end_dt,
    end_dtm,
    source_system_id,
    restricted_row_ind,
    transaction_dt,
    transaction_dtm
from edw_tdsunset.fact_agreement_detail_initial_aifrps;

commit;