-- Insere lista de empresas no cadastro de CFOP no modulo FISCAL

INSERT INTO CONSINCO.RF_CFOPEMPRESA (

    SELECT CFOP, B.NROEMPRESA, A.INDSISTAPURRESSAR
      FROM CONSINCO.RF_CFOPEMPRESA A, CONSINCO.MAX_EMPRESA B
     WHERE CFOP = 5934 AND NOT EXISTS (SELECT 1 FROM CONSINCO.RF_CFOPEMPRESA C WHERE C.NROEMPRESA = B.NROEMPRESA 
     AND C.CFOP = 5934)
     );

COMMIT;
