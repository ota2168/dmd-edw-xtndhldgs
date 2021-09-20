insert into edw_work.rel_financial_transaction_aifrps
(dim_financial_transaction_natural_key_hash_uuid,
 dim_party_natural_key_hash_uuid,
 dim_agreement_natural_key_hash_uuid,
 begin_dt,
 begin_dtm,
 row_process_dtm,
 audit_id,
 logical_delete_ind,
 check_sum,
 current_row_ind,
 end_dt,
 end_dtm,
 source_system_id,
 restricted_row_ind,
 update_audit_id,
 source_delete_ind,
 dim_fund_natural_key_hash_uuid
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
				transaction_dt,
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
       uuid_gen(null)::uuid                                            as dim_party_natural_key_hash_uuid,
       uuid_gen(clean_string(src.agreement_source_cde),
                clean_string('Ipa'),
                clean_string(src.agreement_nr_pfx),
                clean_string(src.agreement_nr),
                clean_string(src.agreement_nr_sfx)
           ) ::uuid                                                    as dim_agreement_natural_key_hash_uuid,
       src.begin_dt,
       src.begin_dt ::timestamp                                        as begin_dtm,
       current_timestamp(6)                                            as row_process_dtm,
       src.audit_id,
       false                                                           as logical_delete_ind,
       uuid_gen(NULL)::uuid                                            as check_sum,
       src.current_row_ind,
       src.end_dt,
       src.end_dt :: timestamp                                         as end_dtm,
       src.source_system_id,
       false                                                           as restricted_row_ind,
       src.update_audit_id,
       src.source_delete_ind,
	case when UPPER(txn_amt_typ_cd)<>'FTA'
	            then uuid_gen(null)::UUID
	     else
		uuid_gen(
                Clean_String(agreement_source_cde),
                Clean_String(admin_fund_cde),
                Clean_String(Product_id),
                Clean_String(Company_cde),
                Clean_String(pt1_kind_cde),
                Clean_String(product_tier_cde)
				)::uuid
	end                                                                as dim_fund_natural_key_hash_uuid


from (
         select
                rel_txn.carr_admin_sys_cd       as agreement_source_cde,
                rel_txn.hldg_key_pfx            as agreement_nr_pfx,
                rel_txn.hldg_key                as agreement_nr,
                rel_txn.hldg_key_sfx            as agreement_nr_sfx,
                rel_txn.src_txn_nr              as source_transaction_key_txt,
                rel_txn.carr_admin_sys_cd       as financial_transaction_source,
                'Financial Transaction'         as financial_transaction_type,
                rel_txn.cycle_dt                as transaction_dt,
                rel_txn.rvrsl_dt                as reversal_dt,
                rel_txn.eff_dt                  as effective_dt,
                rel_txn.sys_dt                  as system_dt,
                rel_txn.txn_cd                  as transaction_cde,
                rel_txn.src_txn_cd              as source_transaction_cde,
                rel_txn.rvrsl_ind               as transaction_reversal_cde,
                rel_txn.admin_fnd_nr            as admin_fund_cde,
                rel_txn.prod_id                 as product_id,
                --rel_txn.prod_tier_cd            as product_tier_cde,
                CASE
                    when trim(rel_txn.prod_tier_cd)='' then '0'
                    when rel_txn.prod_tier_cd is null then '0'
                    when regexp_ilike(rel_txn.prod_tier_cd, '[A-Z]')
                        then rel_txn.prod_tier_cd
                ELSE
                    ((rel_txn.prod_tier_cd::int)::Varchar)
                END                             as product_tier_cde,
                rel_txn.carrier_cd              as company_cde,
                rel_txn.kind_cd                 as pt1_kind_cde,
                rel_txn.fnd_typ_cd              as fund_type_cde,
                rel_txn.cvg_typ_cd              as coverage_type_cde,
                case
                    when rel_txn.cvg_occur_nr is null then NULL::int
                    --when rel_txn.cvg_occur_nr = ''    then NULL::int
                        else
                         rel_txn.cvg_occur_nr::int
                end                              as coverage_occurance_nr,
                rel_txn.trans_dt :: date        as begin_dt,
                rel_txn.run_id                  as audit_id,
                true::boolean                   as current_row_ind,
                '9999-12-31':: date             as end_dt,
                266                             as source_system_id,
                rel_txn.updt_run_id             as update_audit_id,
                false::boolean                  as source_delete_ind,
				rel_txn.txn_amt_typ_cd          as txn_amt_typ_cd
         from
		 (
		  SELECT * FROM (
			SELECT FIN_TX.*,
			ROW_NUMBER() OVER (PARTITION BY AGMT_ID,CARR_ADMIN_SYS_CD,HLDG_KEY_PFX,HLDG_KEY,HLDG_KEY_SFX,SRC_TXN_NR,TXN_CD,SRC_TXN_CD,EFF_DT,RVRSL_DT,RVRSL_IND,CREDIT_DEBIT_IND,TXN_AMT_TYP_CD,FND_ID,TRANS_DT ORDER BY TXN_ID DESC) AS RNO
		FROM  PROD_STND_VW_TERSUN.AGMT_FIN_TXN_VW_AIF_RPS FIN_TX WHERE FIN_TX.SRC_SYS_ID=72
			)A
			WHERE RNO=1
		)rel_txn
     ) src;


