/*---------------Dummy Core table for pre-processing-------------------*/

CREATE TABLE edw_staging.aif_rps_edw_preprocess_temptarget
(
    dim_agreement_natural_key_hash_uuid uuid,
    row_sid  IDENTITY ,
    audit_id int,
    row_process_dtm timestamp
);

/*------------- Dummy work table for pre-processing-----------------*/

CREATE TABLE edw_work.aifrps_aif_rps_edw_preprocess_temptarget
(
    dim_agreement_natural_key_hash_uuid uuid,
    row_sid  IDENTITY ,
    audit_id int,
    row_process_dtm timestamp
);
