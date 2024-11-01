-- Script para executar a troca de famílias

/* Tabela Auxiliar */

SELECT *
  FROM MAP_ALTERAFAMILIAPRODUTO
 WHERE INDALTERACAO = 'P';

/* Chamada da PKG que faz o processo de troca de família de acordo com as familias na tabela auxiliar com status 'P' */

EXECUTE CONSINCO.PKG_ADM_PRODUTO.SP_TROCAFAMILIASJOB('S');
COMMIT;

/* Chamada do Update apenas para ativar a venda da embalagem 1 na familia replicada, apenas na empresa/segto ativos
   De acordo com o produto que existe na auxiliar e que foi alterado - status 'A' - no dia atual */

UPDATE CONSINCO.MRL_PRODEMPSEG X SET X.STATUSVENDA = 'A',
                                     X.USUALTERACAO = 'TROCAFAMILIA',
                                     X.DTAALTERACAO = SYSDATE
                                     
                               WHERE X.SEQPRODUTO IN (SELECT SEQPRODUTO
                                                        FROM MAP_ALTERAFAMILIAPRODUTO
                                                       WHERE INDALTERACAO = 'A'
                                                         AND TRUNC(DTAALTERACAO) = TRUNC(SYSDATE))
                                 AND X.QTDEMBALAGEM = 1
                                 AND NVL(X.STATUSVENDA,'I') = 'I'
                                 AND EXISTS (SELECT 1 FROM MON_EMPRESASEGMENTO E WHERE E.NROEMPRESA = X.NROEMPRESA 
                                                            AND E.NROSEGMENTO = X.NROSEGMENTO
                                                            AND E.ATIVO = 'S');
COMMIT;

SELECT 'Execução Finalizada!' STATUS FROM DUAL;
