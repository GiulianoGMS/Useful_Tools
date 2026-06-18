
BEGIN
  FOR op IN (SELECT *
               FROM FI_TITOPERACAO K
              WHERE 1 = 1
                and k.opcancelada is null
                and k.codoperacao in (36, 37)
                AND EXISTS (SELECT 1
                       FROM FI_TITULO X
                      WHERE X.SEQTITULO = K.SEQTITULO
                        AND X.SITUACAO = 'N'
                        AND ABERTOQUITADO = 'A'
                        AND CODESPECIE LIKE 'AC%'
                        AND DTAEMISSAO >= DATE '2025-09-01'))
      LOOP
        UPDATE FI_TITOPERACAO K SET
               K.SITUACAO = 'X',
               K.OPCANCELADA = 'C',
               K.USUCANCELOU = K.USUALTERACAO,
               K.DTACANCELOU = SYSDATE,
               K.JUSTCANCEL = 'Lancto Indevido Ajuste Ped',
               K.DTAHORACANCELOU = SYSDATE
         WHERE K.SEQTITOPERACAO = op.SEQTITOPERACAO;
               
     --  COMMIT;
       
     END LOOP;
     END;
