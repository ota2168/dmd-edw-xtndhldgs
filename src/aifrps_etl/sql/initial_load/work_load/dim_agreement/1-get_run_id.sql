--Keep this file and Step-3 file as capital due to the 'RUN_ID' passed into file 3 and 4.
--by joining to the target table to get the run_ids that haven;t got processed yet.
--this is to provide reprocess

SELECT ALL_TABLES.RUN_ID FROM
(   SELECT DISTINCT RUN_ID FROM PROD_STND_VW_TERSUN.AGMT_DATA_VW_AIF_RPS WHERE SRC_SYS_ID = 72
    UNION
    SELECT DISTINCT RUN_ID FROM PROD_STND_VW_TERSUN.AGMT_BEN_DATA_VW_AIF_RPS WHERE SRC_SYS_ID = 72
    UNION
    SELECT DISTINCT RUN_ID FROM PROD_STND_VW_TERSUN.AGMT_DIVIDEND_VW_AIF_RPS WHERE SRC_SYS_ID = 72
) ALL_TABLES
WHERE ALL_TABLES.RUN_ID >
    (SELECT COALESCE(MAX(AUDIT_ID), 0) AS RUN_ID FROM EDW_TDSUNSET.DIM_AGREEMENT_INITIAL_AIF_RPS
    WHERE SOURCE_SYSTEM_ID=266)
ORDER BY ALL_TABLES.RUN_ID;

