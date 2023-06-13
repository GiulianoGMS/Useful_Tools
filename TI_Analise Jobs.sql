SELECT * 

FROM ALL_SCHEDULER_JOB_RUN_DETAILS X

WHERE X.job_name = 'SM_GERA_ABC_SINTETICA'

ORDER BY 2 DESC

---------------------------
-- Jobs com Erros:

SELECT DISTINCT TO_CHAR(LOG_DATE, 'DD/MM/YYYY') LOG_DATE, OWNER, JOB_NAME, STATUS, ERRORS

FROM ALL_SCHEDULER_JOB_RUN_DETAILS X

WHERE STATUS = 'FAILED'

ORDER BY TO_DATE(LOG_DATE, 'DD/MM/YYYY') DESC
