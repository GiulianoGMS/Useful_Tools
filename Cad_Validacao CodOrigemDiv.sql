ALTER SESSION SET CURRENT_SCHEMA = CONSINCO;

SELECT /*+OPTIMIZER_FEATURES_ENABLE('11.2.0.4')*/
       DISTINCT B.SEQPRODUTO PLU, E.SEQFAMILIA,
                C.DESCREDUZIDA,
                L.M014_DM_ORIG_ICMS XML,
                D.CODORIGEMTRIB C5,
               (SELECT COUNT(SEQPRODUTO) FROM MAP_PRODUTO Z WHERE Z.SEQFAMILIA = E.SEQFAMILIA) QTD_PROD_FAM,
                MIN(A.DTAEMISSAO) DTAEMISSAO_ULTNOTA

  FROM CONSINCO.MLF_AUXNOTAFISCAL A INNER JOIN CONSINCO.MLF_AUXNFITEM B ON A.SEQAUXNOTAFISCAL = B.SEQAUXNOTAFISCAL
                                    INNER JOIN CONSINCO.MAP_PRODUTO C ON B.SEQPRODUTO = C.SEQPRODUTO
                                    INNER JOIN CONSINCO.MAP_FAMILIA E ON E.SEQFAMILIA = C.SEQFAMILIA
                                    INNER JOIN CONSINCO.MAP_FAMDIVISAO D ON D.SEQFAMILIA = E.SEQFAMILIA
                                    INNER JOIN TMP_M000_NF K ON (K.M000_NR_CHAVE_ACESSO = A.NFECHAVEACESSO)
                                    INNER JOIN TMP_M014_ITEM L ON (L.M000_ID_NF = K.M000_ID_NF AND L.M014_NR_ITEM = B.SEQITEMNFXML)
                                    
WHERE NVL(L.M014_DM_ORIG_ICMS,1) != NVL(D.CODORIGEMTRIB,2)
  AND A.SEQPESSOA > 999
  AND A.DTAEMISSAO > SYSDATE - 50
  AND NOT EXISTS (SELECT 1 FROM DIM_CATEGORIA@CONSINCODW DC WHERE DC.SEQFAMILIA = C.SEQFAMILIA AND DC.CATEGORIAN1 = 'HORTIFRUTI')
   OR EXISTS (SELECT 1 FROM DIM_CATEGORIA@CONSINCODW DC WHERE DC.SEQFAMILIA = C.SEQFAMILIA AND DC.CATEGORIAN1 = 'HORTIFRUTI')
  AND A.SEQPESSOA > 999
  AND A.DTAEMISSAO > SYSDATE - 50
  AND(NVL(L.M014_DM_ORIG_ICMS,1) IN (2,3,8)   AND NVL(D.CODORIGEMTRIB,2) IN (0,4,5,7)
   OR NVL(L.M014_DM_ORIG_ICMS,1) IN (0,4,5,7) AND NVL(D.CODORIGEMTRIB,2) IN (2,3,8))
   
   
   GROUP BY B.SEQPRODUTO, E.SEQFAMILIA, DESCREDUZIDA, L.M014_DM_ORIG_ICMS ,
                D.CODORIGEMTRIB
   ORDER BY 3
