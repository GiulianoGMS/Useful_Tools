ALTER SESSION SET CURRENT_SCHEMA = CONSINCO;

-- Produtos na Loja 58 no Segmento MIXTER que nao existem no Segmento NAGUMO SP

SELECT COUNT(CASE WHEN EXISTS (SELECT 1
         FROM MRL_PRODEMPSEG B
        WHERE B.SEQPRODUTO = A.SEQPRODUTO
          AND B.NROEMPRESA = A.NROEMPRESA
          AND B.NROSEGMENTO = (SELECT NROSEGMENTOPRINC FROM MAX_EMPRESA  X WHERE NROEMPRESA = B.NROEMPRESA)
          AND B.QTDEMBALAGEM = A.QTDEMBALAGEM)
      THEN 1 ELSE NULL END) QTD_EXISTE,
         
       COUNT(CASE WHEN NOT EXISTS (SELECT 1
         FROM MRL_PRODEMPSEG B
        WHERE B.SEQPRODUTO = A.SEQPRODUTO
          AND B.NROEMPRESA = A.NROEMPRESA
          AND B.NROSEGMENTO = (SELECT NROSEGMENTOPRINC FROM MAX_EMPRESA  X WHERE NROEMPRESA = B.NROEMPRESA)
          AND B.QTDEMBALAGEM = A.QTDEMBALAGEM)
      THEN 1 ELSE NULL END) QTD_NAO_EXISTE
               
  FROM MRL_PRODEMPSEG A
 WHERE A.NROEMPRESA IN (58)
       AND NROSEGMENTO = 4 
       