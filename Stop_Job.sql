BEGIN
    DBMS_SCHEDULER.STOP_JOB (job_name => 'NOME_DO_JOB', force => TRUE);
END;
