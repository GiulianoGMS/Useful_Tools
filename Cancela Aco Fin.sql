UPDATE FI_TITOPERACAO T
   SET T.SITUACAO    = 'C',
       T.OPCANCELADA = 'C',
       T.USUCANCELOU = 'C5_CANC',
       T.DTACANCELOU = SYSDATE
       
 WHERE T.SEQTITULO IN (SELECT SEQTITULO
                         FROM FI_TITULO X
                        WHERE NROTITULO IN
                        
                              (SELECT NROACORDO
                                 FROM MSU_ACORDOPROMOC X
                                WHERE NROACORDO IN (585932, 599709, 589846)
                                      OR SEQPROCESSO IN (211736, 212161, 213131))
                              AND SEQPESSOA = 3186961
                              
                              AND X.CODESPECIE LIKE '%AC%')
  
