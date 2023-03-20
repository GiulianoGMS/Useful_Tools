SELECT INITCAP(NVL(GV$SESSION.USERNAME, '{Oracle}')), GV$SESSION.SID, GV$SESSION.SERIAL#, TRIM(TO_CHAR(TRUNC(GV$SESSION.LAST_CALL_ET / 60 / 60))) || ':' || 
        TRIM(TO_CHAR(TRUNC(MOD(GV$SESSION.LAST_CALL_ET, 3600) / 60), '00')) || ':' || 
        TRIM(TO_CHAR(MOD(MOD(GV$SESSION.LAST_CALL_ET, 3600), 60), '00')) LASTCALL, GV$INSTANCE.INST_ID, INITCAP(GV$INSTANCE.INSTANCE_NAME), DECODE(GV$SESSION.BLOCKING_SESSION, NULL, NULL, 'SID ' || GV$SESSION.BLOCKING_SESSION) , INITCAP(GV$SESSION.STATUS) , INITCAP(GV$SESSION.OSUSER), INITCAP(GV$SESSION.MACHINE), INITCAP(GV$SESSION.PROGRAM), INITCAP(DECODE( 
DBA_SCHEDULER_RUNNING_JOBS.JOB_NAME, NULL,  
DECODE(DBA_JOBS_RUNNING.JOB, NULL, GV$SESSION.MODULE, 'Job ' || DBA_JOBS_RUNNING.JOB), 'Sch ' || DBA_SCHEDULER_RUNNING_JOBS.JOB_NAME)), GV$SESSION.LOGON_TIME, GV$SESSION.CLIENT_INFO FROM GV$SESSION, GV$SESS_IO, GV$PROCESS, GV$INSTANCE, DBA_JOBS_RUNNING, DBA_SCHEDULER_RUNNING_JOBS                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          WHERE  GV$SESSION.SID = GV$SESS_IO.SID(+) 
           AND GV$SESSION.INST_ID = GV$SESS_IO.INST_ID(+) 
           AND GV$SESSION.PADDR = GV$PROCESS.ADDR(+) 
           AND GV$SESSION.INST_ID = GV$PROCESS.INST_ID 
           AND GV$SESSION.INST_ID = GV$INSTANCE.INST_ID 
           AND GV$SESSION.SID = DBA_JOBS_RUNNING.SID(+) 
           AND GV$SESSION.SID = DBA_SCHEDULER_RUNNING_JOBS.SESSION_ID(+) AND GV$SESSION.USERNAME IS NOT NULL AND GV$SESSION.STATUS = 'ACTIVE'  ORDER BY LASTCALL DESC
