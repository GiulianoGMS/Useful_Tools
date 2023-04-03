SELECT * FROM CONSINCO.NAGV_DBMONITOR; -- VIEW com o select abaixo

SELECT  DECODE(GV$SESSION.SID || GV$SESSION.INST_ID, NULL, 1, NULL) FIRSTROW, 
        INITCAP(NVL(GV$SESSION.USERNAME, '{Oracle}')) SESSION_USERNAME, GV$SESSION.SID, GV$SESSION.SERIAL#, 
        INITCAP(GV$INSTANCE.INSTANCE_NAME) AMBIENTE, GV$SESSION.AUDSID, GV$PROCESS.SPID, INITCAP(GV$SESSION.SERVER) TIP_SV, 
        (SELECT ROUND( (VALUE / 100 ) / ROUND( GREATEST( SYSDATE - GV$SESSION.LOGON_TIME, 0.001 ) * 1440 * 60) * 100) FROM GV$SESSTAT SS WHERE SS.INST_ID = GV$SESSION.INST_ID AND SS.SID = GV$SESSION.SID AND SS.STATISTIC# = 19) COL_ND,  
        NVL(( SELECT ROUND(S.VALUE / GREATEST((SELECT SUM(T.VALUE) 
                           FROM GV$SESSTAT T
                          WHERE T.INST_ID = S.INST_ID 
                            AND T.STATISTIC# = S.STATISTIC#), 1) * 100, 2) CPU_PERC
                FROM GV$SESSTAT S
              WHERE S.STATISTIC# = 19
                AND S.SID = GV$SESSION.SID
                AND S.INST_ID = GV$SESSION.INST_ID ), 0) COL_ND, 
        ROUND( NVL( GV$PROCESS.PGA_ALLOC_MEM, 0) / 1024 / 1024 ) COL_ND,  ROUND( NVL( TMP.USAGE_MB, 0) ) COL_ND,  ROUND( NVL( UND.USAGE_MB, 0) ) COL_ND, CAST(TRIM(TO_CHAR(TRUNC(GV$SESSION.LAST_CALL_ET / 60 / 60))) || ':' ||
        TRIM(TO_CHAR(TRUNC(MOD(GV$SESSION.LAST_CALL_ET, 3600) / 60), '00')) || ':' ||
        TRIM(TO_CHAR(MOD(MOD(GV$SESSION.LAST_CALL_ET, 3600), 60), '00')) AS VARCHAR2(250)) SESSION_TIME, GV$INSTANCE.INST_ID, 
        INITCAP(DECODE(GV$SESSION.LAST_CALL_ET, 0, 'ACTIVE', GV$SESSION.STATUS)) STATUS,  DECODE( GV$SESSION.BLOCKING_SESSION, NULL, NULL, 
        DECODE( GV$SESSION.BLOCKING_SESSION_STATUS, 'VALID', 'SID ' || GV$SESSION.BLOCKING_SESSION || '.' || GV$SESSION.BLOCKING_INSTANCE, NULL ) ) COL_ND, 
        INITCAP( GV$SESSION.EVENT || DECODE(DBA_OBJECTS.OBJECT_NAME, NULL, '', ' \ ' || DBA_OBJECTS.OBJECT_NAME) || DECODE(PL.OBJECT_NAME, NULL, '', ' \ ' || PL.OBJECT_NAME )) PROCESS_DESC, 
        INITCAP(GV$SESSION.OSUSER) USUARIO_OS, INITCAP(GV$SESSION.TERMINAL) TERMINAL_OS, INITCAP(GV$SESSION.PROGRAM) PROGRAMA, GV$SESSION.LOGON_TIME, GV$SESSION.CLIENT_INFO, GV$SESSION.CLIENT_IDENTIFIER, INITCAP(DECODE(DBA_SCHEDULER_RUNNING_JOBS.JOB_NAME, NULL,
        DECODE(DBA_JOBS_RUNNING.JOB, NULL, GV$SESSION.MODULE, 'Job ' || DBA_JOBS_RUNNING.JOB), 'Sch ' || DBA_SCHEDULER_RUNNING_JOBS.JOB_NAME)) JOB_NAME, 
        INITCAP(GV$SESSION.ACTION) ACTION, NVL(INFO.CLIENT_VERSION, 'Unknown') CLIENT_VERSION, NVL(INFO.CLIENT_CHARSET, 'Unknown')  CHARSET
        
        FROM GV$SESSION, GV$PROCESS, GV$INSTANCE, 
        (SELECT V.SID, V.ID2 JOB, 
             J.FAILURES, 
             LAST_DATE, 
             SUBSTR(TO_CHAR(LAST_DATE, 'HH24:MI:SS'), 1, 8) LAST_SEC, 
             THIS_DATE, 
             SUBSTR(TO_CHAR(THIS_DATE, 'HH24:MI:SS'), 1, 8) THIS_SEC,
             V.INST_ID INSTANCE 

          FROM DBA_JOBS J, GV$LOCK V 
           WHERE V.TYPE = 'JQ' 
               AND J.JOB(+) = V.ID2 ) DBA_JOBS_RUNNING, 
          DBA_SCHEDULER_RUNNING_JOBS, DBA_OBJECTS, DBA_OBJECTS PL,
         (SELECT SID, INST_ID, MAX(CLIENT_CHARSET) CLIENT_CHARSET, MAX(CLIENT_VERSION) CLIENT_VERSION           
          FROM  GV$SESSION_CONNECT_INFO
          GROUP BY SID, INST_ID) INFO,
         (SELECT INST_ID, SESSION_ADDR, (SUM(BLOCKS) * 8192          ) / 1024 / 1024 USAGE_MB
          FROM GV$SORT_USAGE
          GROUP BY INST_ID, SESSION_ADDR) TMP,
         (SELECT INST_ID, ADDR, (SUM(USED_UBLK) * 8192          ) / 1024 / 1024 USAGE_MB
          FROM GV$TRANSACTION
          GROUP BY INST_ID, ADDR) UND                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               WHERE  GV$SESSION.PADDR = GV$PROCESS.ADDR(+)
          AND GV$SESSION.INST_ID = GV$PROCESS.INST_ID(+)
          AND GV$SESSION.INST_ID = GV$INSTANCE.INST_ID
          AND GV$SESSION.SID = DBA_JOBS_RUNNING.SID(+)
          AND GV$SESSION.INST_ID = DBA_JOBS_RUNNING.INSTANCE(+)
          AND GV$SESSION.SID = DBA_SCHEDULER_RUNNING_JOBS.SESSION_ID(+)
          AND GV$SESSION.INST_ID = DBA_SCHEDULER_RUNNING_JOBS.RUNNING_INSTANCE(+)
          AND TMP.SESSION_ADDR(+) = GV$SESSION.SADDR
          AND TMP.INST_ID(+) = GV$SESSION.INST_ID
          AND UND.INST_ID(+) = GV$SESSION.INST_ID
          AND UND.ADDR(+) = GV$SESSION.TADDR
          AND INFO.SID(+) = GV$SESSION.SID
          AND INFO.INST_ID(+) = GV$SESSION.INST_ID
          AND DBA_OBJECTS.OBJECT_ID(+) = GV$SESSION.ROW_WAIT_OBJ#
          AND PL.OBJECT_ID(+) = GV$SESSION.PLSQL_ENTRY_OBJECT_ID  
          AND GV$SESSION.TYPE = 'USER' 
          AND GV$SESSION.USERNAME IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM GV$PX_SESSION WHERE GV$PX_SESSION.SID = GV$SESSION.SID AND GV$PX_SESSION.SERIAL# = GV$SESSION.SERIAL# AND GV$PX_SESSION.INST_ID = GV$SESSION.INST_ID)
          AND (GV$SESSION.STATUS = 'ACTIVE' OR GV$SESSION.STATUS = 'KILLED')  ORDER BY FIRSTROW, GV$SESSION.LAST_CALL_ET DESC  
