SELECT DISTINCT M.SEQPRODUTO PLU, DESCCOMPLETA, DECODE(M.STATUSCOMPRA, 'A', 'Ativo', 'I', 'Inativo', 'S', 'Suspenso') STATUS_COMPRA,
       CASE WHEN B.SEQPRODUTO IS NOT NULL THEN 'Existia no mix selecionado' ELSE 'Não Existia - Alterado posteriormente' END BASE_SELECIONADA,
       CASE WHEN B.SEQPRODUTO IS NOT NULL THEN 'TI - Solicitação Inicial' ELSE A.USUAUDITORIA END USU_ALTERACAO, 
       CASE WHEN B.SEQPRODUTO IS NOT NULL THEN DATE '2025-04-24' ELSE A.DTAAUDITORIA END DTA_ATIVACAO,
       FD.DESCRICAO DESC_FINALIDADE

  FROM MRL_PRODUTOEMPRESA M INNER JOIN MAP_PRODUTO P  ON P.SEQPRODUTO = M.SEQPRODUTO
                            INNER JOIN MAP_FAMDIVISAO F ON F.SEQFAMILIA = P.SEQFAMILIA
                            INNER JOIN MAP_FINALIDADEFAMILIA FD ON FD.FINALIDADEFAMILIA = F.FINALIDADEFAMILIA
                             LEFT JOIN NAGT_BASE_56 B ON B.SEQPRODUTO = M.SEQPRODUTO
                             LEFT JOIN (SELECT * FROM (
                                        SELECT NVL(CASE WHEN USUAUDITORIA IN ('USUARIOAD','AD_WALLACE') THEN 'TI - Solicitacao Posterior' ELSE USUAUDITORIA END, 
                                                                              'INTEGRACAO') USUAUDITORIA, A.SEQIDENTIFICA, A.DTAAUDITORIA,
                                               ROW_NUMBER() OVER(PARTITION BY SEQIDENTIFICA ORDER BY A.DTAHORAUDITORIA DESC) ODR
                                          FROM MAP_AUDITORIA A WHERE A.CAMPO = 'STATUSCOMPRA' ORDER BY A.DTAHORAUDITORIA DESC)
                                         WHERE ODR = 1
                                       ) A ON A.SEQIDENTIFICA = M.SEQPRODUTO
                             
 WHERE M.NROEMPRESA   = 56
   AND M.STATUSCOMPRA = 'A'
   
   ORDER BY 2;                                      
