SELECT JOB_NAME,
       REQ_START_DATE,
       ACTUAL_START_DATE,
       EXTRACT(HOUR FROM(ACTUAL_START_DATE - REQ_START_DATE)) || 'h ' ||
       EXTRACT(MINUTE FROM(ACTUAL_START_DATE - REQ_START_DATE)) || 'm ' ||
       EXTRACT(SECOND FROM(ACTUAL_START_DATE - REQ_START_DATE)) || 's' AS ATRASO,
       STATUS
       
  FROM USER_SCHEDULER_JOB_RUN_DETAILS A
 WHERE TRUNC(REQ_START_DATE) >= TRUNC(SYSDATE) -1 
   AND EXTRACT(HOUR FROM(ACTUAL_START_DATE - REQ_START_DATE)) > 0
   
 ORDER BY (ACTUAL_START_DATE - REQ_START_DATE) * 24 * 60 DESC; -- Ordenando pelo maior atraso
 
