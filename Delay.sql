-- DBMS que segura a proxima chamada em determinados segundos

EXECUTE DBMS_LOCK.SLEEP(60); -- Setado 60 seg

SELECT 'Retorno após delay' FROM DUAL;
