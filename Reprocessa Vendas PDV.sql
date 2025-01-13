BEGIN
-- Empresas e periodo no primeiro Loop
FOR EMP IN(SELECT NROEMPRESA, DTA FROM DWNAGT_DADOSEMPRESA A INNER JOIN DIM_TEMPO D ON 1=1
           WHERE D.DTA BETWEEN DATE '2024-11-01' AND DATE '2025-01-05'
           AND A.TIPO = 'LOJA'
           AND A.OPERACAOINICIADA = 'S'
           ORDER BY 1,2)
  
   LOOP
   -- Cupons no segundo loop (neste caso tambem o produto, pois preciso saber o que vou dar update)
   FOR T IN  (SELECT DISTINCT X.SEQDOCTO, XI.SEQPRODUTO
                 FROM PDV_DOCTO X INNER JOIN PDV_DOCTOITEM XI ON X.SEQDOCTO = XI.SEQDOCTO
                                  INNER JOIN MAP_PRODUTO P ON SUBSTR(P.SEQPRODUTO,2) = XI.SEQPRODUTOFINAL
                        
                WHERE X.DTAMOVIMENTO = EMP.DTA
                  AND X.NROEMPRESA   = EMP.NROEMPRESA
                  AND P.INDPROCFABRICACAO = 'V'
                  AND X.TIPODOCTO         = 'CF'
									AND X.STATUSDOCTO       = 'V'
                  AND EXISTS (SELECT 1
                                FROM MAP_PRODUTO X 
                               WHERE DESCCOMPLETA LIKE '%CESTA%NAT%ALIANZA%' 
                                 AND SUBSTR(SEQPRODUTO,2) = XI.SEQPRODUTOFINAL)
              )
   
   LOOP
   -- Atualiza para 'r' para reprocessar posteriormente e arruma o bo que neste caso falta o digito 2 no começo do seqprodutofinal
   UPDATE PDV_DOCTOITEM XI SET XI.INDREPLICACAO = 'r',
                               XI.SEQPRODUTOFINAL = CASE WHEN XI.SEQPRODUTO = T.SEQPRODUTO 
                                                          AND LENGTH(NVL(XI.SEQPRODUTOFINAL,1)) = 5 
                                                         THEN TO_NUMBER(2||XI.SEQPRODUTOFINAL) ELSE XI.SEQPRODUTOFINAL END
                         WHERE XI.SEQDOCTO = T.SEQDOCTO;
                       
   COMMIT;
  END LOOP;
  -- Reprocessa
  PKG_PDVACRUXINTERFACE.SP_ESTORNAMOVIMENTO(EMP.NROEMPRESA,EMP.DTA,'R','','S');
  -- Importa
  CONSINCO.PKG_PDVACRUXINTERFACE.SP_PROCIMPORTACAO(EMP.NROEMPRESA,EMP.DTA,'CONSINCO','N');
  COMMIT;
    
 END LOOP;
END;
