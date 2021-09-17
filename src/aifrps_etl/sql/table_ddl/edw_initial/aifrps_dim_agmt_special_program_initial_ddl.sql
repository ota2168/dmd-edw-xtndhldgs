-- 1.0 Historical Staging Table for Dim_Agreement_Special_Program:

CREATE TABLE EDW_STAGING.AIFRPS_DIM_AGMT_SPCL_PRGM_VW
     (
      agmt_id                                               int,
      spcl_pgm_typ                                          varchar(40),
      spcl_pgm_cntr                                         int,
      agmt_spcl_pgm_fr_dt                                   timestamp,
      agmt_spcl_pgm_to_dt                                   timestamp,
      hldg_key_pfx                                          varchar(20),
      hldg_key                                              varchar(40),
      hldg_key_sfx                                          varchar(20),
      carr_admin_sys_cd                                     varchar(20),
      pgm_buss_strt_dt                                      timestamp,
      pgm_buss_end_dt                                       timestamp,
      src_spcl_pgm_typ                                      varchar(100),
      pgm_mode_cd                                           varchar(20),
      src_pgm_mode_cd                                       varchar(40),
      pgm_mode_nr                                           smallint,
      pgm_dur                                               int,
      pgm_amt                                               numeric(17,2),
      pgm_calc_typ                                          varchar(20),
      src_pgm_calc_typ                                      varchar(40),
      pgm_amt_typ_cd                                        varchar(20),
      src_pgm_amt_typ_cd                                    varchar(40),
      detail_amt                                            numeric(17,2),
      detail_pct                                            numeric(15,5),
      pgm_int_rt                                            numeric(15,6),
      next_run_dt                                           date,
      fnd_id                                                int,
      admin_fnd_nr                                          char(5),
      prod_tier_cd                                          char(5),
      agmt_data_fr_dt                                       timestamp,
      src_del_ind                                           char(1),
      curr_ind                                              char(1),
      src_sys_id                                            int,
      run_id                                                int,
      updt_run_id                                           int,
      trans_dt                                              timestamp,
      first_pymt_dt                                         date,
      first_pymt_yr                                         int,
      src_prior_mrd_amt_typ_cd                              varchar(10),
      prior_mrd_amt_typ_cd                                  varchar(20),
      prior_mrd_amt                                         numeric(38,2),
      exclusion_amt                                         numeric(38,2)
);

-- 2.0 Pre_Work Table for Dim_Agreement_Special_Program:

CREATE TABLE EDW_STAGING.AIFRPS_DIM_AGMT_SPCL_PRGM_INIT_LOAD_PREWORK
(
    dim_agreement_special_program_natural_key_hash_uuid     uuid NOT NULL,
    dim_agreement_natural_key_hash_uuid                     uuid NOT NULL,
    special_program_key_id                                  varchar(600) NOT NULL,
    agreement_nr_pfx                                        varchar(50),
    agreement_nr                                            varchar(150) NOT NULL,
    agreement_nr_sfx                                        varchar(50),
    agreement_source_cde                                    varchar(50) NOT NULL,
    agreement_type_cde                                      varchar(50) NOT NULL,
    special_program_type_cde                                varchar(50) NOT NULL,
    special_program_counter_nr                              int NOT NULL,
    special_program_feature_type_cde                        varchar(50),
    admin_fund_cde                                          varchar(50),
    product_id                                              varchar(200),
    company_cde                                             varchar(50),
    pt1_kind_cde                                            varchar(50),
    product_tier_cde                                        varchar(50),
    dim_fund_natural_key_hash_uuid                          uuid NOT NULL,
    source_special_program_type_cde                         varchar(50),
    program_business_start_dt                               timestamp,
    program_business_end_dt                                 timestamp,
    program_mode_cde                                        varchar(50),
    source_program_mode_cde                                 varchar(50),
    program_mode_nr                                         int,
    program_duration_nr                                     int,
    program_amt                                             numeric(17,4),
    program_calculation_type_cde                            varchar(50),
    source_program_calculation_type_cde                     varchar(50),
    program_amt_type_cde                                    varchar(50),
    source_program_amt_type_cde                             varchar(50),
    detail_amt                                              numeric(17,4),
    detail_pct                                              numeric(15,5),
    program_interest_rt                                     numeric(15,6),
    next_run_dt                                             date,
    first_payment_dt                                        date,
    first_payment_year_nr                                   int,
    prior_mrd_amt                                           numeric(17,4),
    prior_mrd_amt_type_cde                                  varchar(50),
    source_prior_mrd_amt_type_cde                           varchar(50),
    exclusion_amt                                           numeric(17,4),
    begin_dt                                                date NOT NULL DEFAULT '0001-01-01'::date,
    begin_dtm                                               timestamp(6) NOT NULL,
    row_process_dtm                                         timestamp(6) NOT NULL,
    check_sum                                               uuid NOT NULL,
    end_dt                                                  date NOT NULL DEFAULT '9999-12-31'::date,
    end_dtm                                                 timestamp(6) NOT NULL,
    restricted_row_ind                                      boolean NOT NULL DEFAULT false,
    --row_sid  IDENTITY ,
    current_row_ind                                         boolean NOT NULL,
    logical_delete_ind                                      boolean NOT NULL,
    source_system_id                                        varchar(50) NOT NULL,
    audit_id                                                int NOT NULL,
    update_audit_id                                         int NOT NULL,
    source_delete_ind                                       boolean NOT NULL
);



-- 3.0 Work Table for Dim_Agreement_Special_Program: Needed ?

CREATE TABLE EDW_WORK.AIFRPS_DIM_AGMT_SPCL_PRGM_INIT_LOAD
(
    dim_agreement_special_program_natural_key_hash_uuid     uuid NOT NULL,
    dim_agreement_natural_key_hash_uuid                     uuid NOT NULL,
    special_program_key_id                                  varchar(600) NOT NULL,
    agreement_nr_pfx                                        varchar(50),
    agreement_nr                                            varchar(150) NOT NULL,
    agreement_nr_sfx                                        varchar(50),
    agreement_source_cde                                    varchar(50) NOT NULL,
    agreement_type_cde                                      varchar(50) NOT NULL,
    special_program_type_cde                                varchar(50) NOT NULL,
    special_program_counter_nr                              int NOT NULL,
    special_program_feature_type_cde                        varchar(50),
    admin_fund_cde                                          varchar(50),
    product_id                                              varchar(200),
    company_cde                                             varchar(50),
    pt1_kind_cde                                            varchar(50),
    product_tier_cde                                        varchar(50),
    dim_fund_natural_key_hash_uuid                          uuid NOT NULL,
    source_special_program_type_cde                         varchar(50),
    program_business_start_dt                               timestamp,
    program_business_end_dt                                 timestamp,
    program_mode_cde                                        varchar(50),
    source_program_mode_cde                                 varchar(50),
    program_mode_nr                                         int,
    program_duration_nr                                     int,
    program_amt                                             numeric(17,4),
    program_calculation_type_cde                            varchar(50),
    source_program_calculation_type_cde                     varchar(50),
    program_amt_type_cde                                    varchar(50),
    source_program_amt_type_cde                             varchar(50),
    detail_amt                                              numeric(17,4),
    detail_pct                                              numeric(15,5),
    program_interest_rt                                     numeric(15,6),
    next_run_dt                                             date,
    first_payment_dt                                        date,
    first_payment_year_nr                                   int,
    prior_mrd_amt                                           numeric(17,4),
    prior_mrd_amt_type_cde                                  varchar(50),
    source_prior_mrd_amt_type_cde                           varchar(50),
    exclusion_amt                                           numeric(17,4),
    begin_dt                                                date NOT NULL DEFAULT '0001-01-01'::date,
    begin_dtm                                               timestamp(6) NOT NULL,
    row_process_dtm                                         timestamp(6) NOT NULL,
    check_sum                                               uuid NOT NULL,
    end_dt                                                  date NOT NULL DEFAULT '9999-12-31'::date,
    end_dtm                                                 timestamp(6) NOT NULL,
    restricted_row_ind                                      boolean NOT NULL DEFAULT false,
    --row_sid  IDENTITY ,
    current_row_ind                                         boolean NOT NULL,
    logical_delete_ind                                      boolean NOT NULL,
    source_system_id                                        varchar(50) NOT NULL,
    audit_id                                                int NOT NULL,
    update_audit_id                                         int NOT NULL,
    source_delete_ind                                       boolean NOT NULL
);