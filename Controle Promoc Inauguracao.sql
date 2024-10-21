ALTER SESSION SET CURRENT_SCHEMA = CONSINCO;

-- Necessidade 58:
-- Inativar as promocoes da loja que terminarem antes da inauguracao em 24/10/24, pois nao faz sentido imprimir e reimprimir no dia antes da inauguracao
-- Suspender todas as promocoes validas e reativar no dia anterior da inauguracao

-- Inativando promocoes que terminam no dia anterior da inauguracao:

BEGIN
  FOR t IN (

BEGIN
  FOR t IN (

SELECT DISTINCT B.STATUS,
                X.SEQPROMOCAO,
                X.NROEMPRESA,
                PROMOCAO,
                DTAINICIO,
                DTAFIM,
                DTAINICIOPROM,
                DTAFIMPROM,
                SEQPRODUTO,
                B.QTDEMBALAGEM
  FROM MRL_PROMOCAO X INNER JOIN MRL_PROMOCAOITEM B ON B.SEQPROMOCAO = X.SEQPROMOCAO AND X.NROEMPRESA = B.NROEMPRESA
 WHERE X.NROEMPRESA = 58
   AND (TRUNC(SYSDATE) BETWEEN DTAINICIO AND DTAFIM AND DTAFIM >= DATE '2024-10-24'    
    OR  TRUNC(SYSDATE) BETWEEN B.DTAINICIOPROM AND B.DTAFIMPROM AND DTAFIMPROM >= DATE '2024-10-24')
   AND STATUS = 'A'
   
   )
   
     LOOP
     
   UPDATE MRL_PROMOCAOITEM B SET B.STATUS = 'S',
                                 B.DTAINICIOPROM = DATE '2024-10-23'
                           WHERE B.SEQPROMOCAO = T.SEQPROMOCAO
                             AND B.NROEMPRESA  = T.NROEMPRESA
                             AND B.SEQPRODUTO  = T.SEQPRODUTO;
                             
   UPDATE MRL_PROMOCAO C     SET C.DTAINICIO   = DATE '2024-10-23'
                           WHERE C.SEQPROMOCAO = T.SEQPROMOCAO
                             AND C.NROEMPRESA  = T.NROEMPRESA;
                             
   COMMIT;
   
     END LOOP;
   
END;

-- Reativando as ofertas suspensas:

   UPDATE MRL_PROMOCAOITEM B SET B.STATUS = 'A'
                           WHERE B.NROEMPRESA = 58
                             AND B.STATUS = 'S';
   COMMIT;

-- Validando 

SELECT COUNT (DISTINCT SEQPRODUTO) FROM MRL_PRODEMPSEG XX WHERE XX.NROEMPRESA = 58 AND XX.NROSEGMENTO = 2 AND XX.PRECOVALIDPROMOC > 0
