-- Roda o SELECT * FROM GLN_LOG_PROCESSO_LOOP em outra sessao para acompanhar o count do update
SELECT * FROM GLN_LOG_PROCESSO_LOOP;

/* Primeiro Loop para Ativar o "INDUTILVENDA' na MAP_PRODCODIGO */

BEGIN
DECLARE 
    i INTEGER := 0;
    total INTEGER := 0;
    /* Criei para registrar o log do loop enquanto está executando */
    /* Pode consultar na tabela GLN_LOG_PROCESSO_LOOP o andamento */
    PROCEDURE ATUALIZAR_LOG(p_total NUMBER) IS
    PRAGMA AUTONOMOUS_TRANSACTION; -- acho que nao precisa mas ta ai
    
    BEGIN
        MERGE INTO GLN_LOG_PROCESSO_LOOP L
        USING (SELECT 'TOTAL_ALTERADO' AS ID FROM DUAL) D
        ON (L.MENSAGEM = D.ID)
        WHEN MATCHED THEN 
            UPDATE SET L.DATA_LOG = SYSTIMESTAMP, L.TOTAL = p_total
        WHEN NOT MATCHED THEN 
            INSERT (MENSAGEM, DATA_LOG, TOTAL) 
            VALUES ('TOTAL_ALTERADO', SYSTIMESTAMP, p_total);

        COMMIT;
    END ATUALIZAR_LOG;
    /*******/
    
BEGIN
     FOR atv IN (SELECT A.SEQPRODUTO, C.QTDEMBALAGEM, C.CODACESSO, C.DATAHORAALTERACAO 
                   FROM NAGV_MIX56 A INNER JOIN MAP_PRODCODIGO C ON C.SEQPRODUTO = A.SEQPRODUTO AND C.TIPCODIGO IN ('D','E') AND QTDEMBALAGEM > 1 AND NVL(C.INDUTILVENDA, 'N') != 'S'
                )
     LOOP
        i := i + 1;
        total := total + 1;
        
        UPDATE MAP_PRODCODIGO C SET C.INDUTILVENDA = 'S',
                                C.USUARIOALTERACAO = 'MIX_DUN',
                                C.DATAHORAALTERACAO = SYSDATE
                          WHERE C.SEQPRODUTO   = atv.SEQPRODUTO 
                            AND C.CODACESSO    = atv.CODACESSO
                            AND C.QTDEMBALAGEM = atv.QTDEMBALAGEM
                            AND C.TIPCODIGO IN ('E','D');
                                    
        IF i = 100 THEN -- Define o Commit por quantidade de linhas
            COMMIT;
            ATUALIZAR_LOG(total);  -- Atualiza o total no log
            i := 0;
        END IF;
    END LOOP;

    COMMIT;
    ATUALIZAR_LOG(total); -- Atualiza o total final
 END;
END;

/* Segundo Loop para replicar o preço da emb3 para a embalagem >3, ou alterar o status de venda para 'A' da embalagem */

BEGIN
  FOR rep IN (

SELECT DISTINCT B.STATUSVENDA STATUS_D, B1.STATUSVENDA STATUS_U, B.NROSEGMENTO,
       A.SEQPRODUTO, B.NROEMPRESA, B.QTDEMBALAGEM,ROUND( B.PRECOVALIDNORMAL/B.QTDEMBALAGEM,2) PRECO_EMB, ROUND(B1.PRECOVALIDNORMAL/ B1.QTDEMBALAGEM,2) PRECO_UNIT3, 
       B.PRECOVALIDNORMAL PR_ATUAL, ROUND(B1.PRECOVALIDNORMAL/ B1.QTDEMBALAGEM,2) * B.QTDEMBALAGEM PR_NOVO,
      (ROUND(B1.PRECOVALIDNORMAL/ B1.QTDEMBALAGEM,2) * B.QTDEMBALAGEM) - B.PRECOVALIDNORMAL PDIF
  FROM NAGV_MIX56 A INNER JOIN MRL_PRODEMPSEG B ON B.SEQPRODUTO = A.SEQPRODUTO
                    INNER JOIN MAP_PRODCODIGO PC ON PC.SEQPRODUTO = A.SEQPRODUTO AND PC.QTDEMBALAGEM = B.QTDEMBALAGEM AND PC.TIPCODIGO IN ('D','E')
                    INNER JOIN MRL_PRODEMPSEG B1 ON B1.SEQPRODUTO = B.SEQPRODUTO AND B1.NROEMPRESA = B.NROEMPRESA AND B1.NROSEGMENTO = B.NROSEGMENTO AND B1.QTDEMBALAGEM = 3 AND B1.PRECOVALIDNORMAL > 0 
                      
 WHERE B.NROEMPRESA IN (31,53,56) AND B.NROSEGMENTO = 4
   AND (B.PRECOVALIDNORMAL = 0 OR B.STATUSVENDA != 'A') --(B.QTDEMBALAGEM > 3 OR B.QTDEMBALAGEM = 1 AND B.PRECOVALIDNORMAL = 0)
   
    )
   
   LOOP
     UPDATE MRL_PRODEMPSEG G SET G.PRECOVALIDNORMAL = rep.PR_NOVO,
                                 G.PRECOBASENORMAL  = rep.PR_NOVO,
                                 G.PRECOGERNORMAL   = rep.PR_NOVO,
                                 G.STATUSVENDA = 'A'
     
                           WHERE G.QTDEMBALAGEM  = rep.QTDEMBALAGEM
                             AND G.NROEMPRESA    = rep.NROEMPRESA
                             AND G.SEQPRODUTO    = rep.SEQPRODUTO
                             AND G.NROSEGMENTO   = rep.NROSEGMENTO;
    END LOOP;
    
END;

-- Inativa Emb > 1 no Varejo

/*BEGIN
  FOR inat IN (SELECT DISTINCT B.SEQPRODUTO, B.NROEMPRESA, B.NROSEGMENTO, B.QTDEMBALAGEM
                          FROM NAGV_MIX56 A INNER JOIN MRL_PRODEMPSEG B ON B.SEQPRODUTO = A.SEQPRODUTO
                                            INNER JOIN MAP_PRODCODIGO PC ON PC.SEQPRODUTO = A.SEQPRODUTO AND PC.QTDEMBALAGEM = B.QTDEMBALAGEM AND PC.TIPCODIGO IN ('D','E')
                                            INNER JOIN MRL_PRODEMPSEG B1 ON B1.SEQPRODUTO = B.SEQPRODUTO AND B1.NROEMPRESA = B.NROEMPRESA AND B1.NROSEGMENTO = B.NROSEGMENTO AND B1.QTDEMBALAGEM = 3 AND B1.PRECOVALIDNORMAL > 0 AND B1.STATUSVENDA = 'A'
                                              
                         WHERE 1=1
                           AND B.PRECOVALIDNORMAL != ROUND(B1.PRECOVALIDNORMAL/ B1.QTDEMBALAGEM,2) * B.QTDEMBALAGEM
                           AND B.QTDEMBALAGEM > 1
                           AND B.STATUSVENDA = 'A'
                           AND B.NROSEGMENTO NOT IN (4,7,8) AND B.NROEMPRESA NOT IN (31,41,54,56))
  LOOP
    UPDATE MRL_PRODEMPSEG G SET G.STATUSVENDA = 'I'
                          WHERE 2=2
                            AND G.SEQPRODUTO = inat.SEQPRODUTO
                            AND G.NROEMPRESA = inat.NROEMPRESA
                            AND G.NROSEGMENTO = inat.NROSEGMENTO
                            AND G.QTDEMBALAGEM = inat.QTDEMBALAGEM;
  END LOOP;
*/

-- Equipara Embalagens no Varejo

INSERT INTO MAD_PRODLOGPRECO
  (SEQLOGPRECO,
   NROEMPRESA,
   CENTRALLOJA,
   SEQPRODUTO,
   QTDEMBALAGEM,
   NROSEGMENTO,
   PRECO,
   FAIXAACRFINANCEIRO,
   DTAHORALTERACAO,
   INDGERAPRECO,
   USUALTERACAO,
   PROCESSOALTERACAO,
   APROVADOREPROVADO,
   DTAHORAPROVREPROV,
   USUAPROVREPROV,
   TIPOALTPRECO,
   MOTIVOALTMANUAL,
   DTAPROGALTERACAO,
   INDGERAPRODBASE,
   INDGERAPRODSIMILAR,
   INDREPLICACAO,
   INDGEROUREPLICACAO,
   CLASSIFCOMERCABC,
   ORIGEM)
  SELECT NULL,
         X.NROEMPRESA,
         E.INDCENTRALLOJA,
         X.SEQPRODUTO,
         X.QTDEMBALAGEM,
         X.NROSEGMENTO,
         FPRECOEMBPRODEMPSEG(X.SEQPRODUTO,
                             1,
                             X.NROSEGMENTO,
                             X.NROEMPRESA,
                             'B') * X.QTDEMBALAGEM,
         'A',
         SYSDATE,
         'V',
         'AUTOMATICO',
         'M',
         'A',
         SYSDATE,
         'AUTOMATICO',
         'N',
         ' Script Correção Preço de Embalagens',
         TRUNC(SYSDATE),
         'N',
         'N',
         'S',
         NULL,
         NULL,
         'E'
    FROM MRL_PRODEMPSEG X
   INNER JOIN MAP_PRODUTO P
      ON (P.SEQPRODUTO = X.SEQPRODUTO)
    LEFT JOIN QLV_CATEGORIA@BI C
      ON (C.SEQFAMILIA = P.SEQFAMILIA)
   INNER JOIN MAX_EMPRESA E
      ON (E.NROEMPRESA = X.NROEMPRESA)
   INNER JOIN MRL_PRODUTOEMPRESA Z
      ON (Z.SEQPRODUTO = X.SEQPRODUTO AND Z.NROEMPRESA = X.NROEMPRESA)
   WHERE X.NROSEGMENTO IN (2, 5, 3)
         AND X.STATUSVENDA = 'A'
         AND X.QTDEMBALAGEM > 1
         AND (X.PRECOGERNORMAL / X.QTDEMBALAGEM) <> 0
         AND EXISTS (SELECT 1
            FROM MRL_PRODEMPSEG Z
           WHERE Z.SEQPRODUTO = X.SEQPRODUTO
                 AND Z.NROEMPRESA = X.NROEMPRESA
                 AND Z.QTDEMBALAGEM > 1
                 AND X.NROSEGMENTO = Z.NROSEGMENTO
                 AND Z.STATUSVENDA = X.STATUSVENDA)
         AND EXISTS
   (SELECT 1
            FROM MRL_PRODEMPSEG Y
           WHERE X.SEQPRODUTO = Y.SEQPRODUTO
                 AND X.STATUSVENDA = Y.STATUSVENDA
                 AND X.NROSEGMENTO = Y.NROSEGMENTO
                 AND Y.QTDEMBALAGEM = 1
                 AND X.NROEMPRESA = Y.NROEMPRESA
                 AND ROUND((X.PRECOGERNORMAL / X.QTDEMBALAGEM), 2) <>
                 ROUND((Y.PRECOGERNORMAL / Y.QTDEMBALAGEM), 2))
         AND EXISTS (SELECT 2 FROM NAGV_MIX56 XX WHERE XX.SEQPRODUTO = X.SEQPRODUTO);

