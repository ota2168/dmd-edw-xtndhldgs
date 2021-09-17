-- create project for aif_rps
INSERT INTO EDAP_MDC.ETL_PROJECT (
	NAME,
	SHORT_NAME,
	BATCH_USER,
	DESCRIPTION
)
SELECT
'AIF_RPS',
'aifrps',
'edw_core_batch',
'TDSunset Agreement aif_rps ETL';
	
commit;