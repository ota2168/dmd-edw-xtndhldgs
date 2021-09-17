/*-----------update statement for DAFA to close the end_dt/end_dtm for current_row_ind=false and source_delete_ind=true and end_dt='9999-12-31'*/


delete from edw_tdsunset.dim_agreement_fund_allocation_initial_aifrps
where begin_dt>end_dt; --126 records


UPDATE edw_tdsunset.dim_agreement_fund_allocation_initial_aifrps src
SET end_dt         = (tgt.begin_dt::DATE),
    end_dtm= ((tgt.begin_dt::DATE +INTERVAL '1' DAY)::TIMESTAMP - INTERVAL '1' SECOND),
	business_end_dt=(case when src.business_end_dt='9999-12-31' then (tgt.begin_dt::DATE) else '9999-12-31' end)
	--business_end_dt=(tgt.begin_dt::DATE - 1)  ---CASE WHEN SRC.BUSINESS_END_DT='9999-12-31' THEN (tgt.begin_dt::DATE - 1) ELSE '9999-12-31' END
FROM (SELECT distinct dim_agreement_fund_allocation_natural_key_hash_uuid ,
             audit_id,
             begin_dt
      FROM edw_tdsunset.dim_agreement_fund_allocation_initial_aifrps
       ) tgt
WHERE src.update_audit_id = tgt.audit_id -- To get the begin date of the next record
  AND src.dim_agreement_fund_allocation_natural_key_hash_uuid = tgt.dim_agreement_fund_allocation_natural_key_hash_uuid
  AND src.current_row_ind = FALSE AND src.end_dt='9999-12-31' AND src.source_delete_ind=TRUE; --128 records
  
Commit;