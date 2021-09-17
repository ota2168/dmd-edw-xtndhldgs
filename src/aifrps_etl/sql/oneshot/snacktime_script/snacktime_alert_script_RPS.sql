insert into edw_audit.tbl_deltajobs_schedule
(
Batch_Name,
Project_ID,
Used_By,
Active_job_Ind,
ScheduledDays
)
select
'AIF_RPS'
,(select id from edap_mdc.etl_project where name='AIF_RPS')
,'TDSunset Agreement'
,True
,'Tue,Wed,Thu,Fri,Sat';

COMMIT;