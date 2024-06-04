ALTER SESSION SET CURRENT_SCHEMA = CONSINCO;

SELECT P.NROEMPRESA, P.SEQPRODUTO, QTDRESERVADAVDA, DP.QTD_PEDVENDA 

  FROM MRL_PRODUTOEMPRESA P INNER JOIN (SELECT SUM(XI.QTDATENDIDA) QTD_PEDVENDA, X.NROEMPRESA, SEQPRODUTO
                                          FROM MAD_PEDVENDA X INNER JOIN MAD_PEDVENDAITEM XI ON X.NROPEDVENDA = XI.NROPEDVENDA
                                                                                            AND X.NROEMPRESA  = XI.NROEMPRESA
                                         WHERE 1=1
                                           AND XI.QTDATENDIDA > 0
                                           -- Atualizacao foi em Abril 04
                                           AND X.DTAINCLUSAO  > DATE '2024-04-01'
                                           AND X.TIPPEDIDO    NOT IN ('L', 'C')
                                           AND X.SITUACAOPED  IN     ( 'L', 'A', 'D', 'S', 'P', 'W','R' )
                                           AND XI.NUMERODF    IS NULL
                                           AND ((X.SEQPALETECARREG IS NULL AND  X.GERALTERACAOESTQ = 'S') OR X.SEQPALETECARREG IS NOT NULL)
                                           AND XI.NROEMPRESAESTQ IS NULL
                                           -- Retira pend
                                           AND NOT EXISTS (SELECT 1
                                                             FROM MAD_PEDVENDAFATPEND FAT
                                                            WHERE FAT.NROPEDVENDAPEND = X.NROPEDVENDA
                                                              AND FAT.NROEMPRESAPEND  = X.NROEMPRESA
                                                              AND FAT.NROCARGA        = X.NROCARGA)
                                           
                                       GROUP BY X.NROEMPRESA, SEQPRODUTO) DP ON DP.NROEMPRESA  = P.NROEMPRESA
                                                                            AND DP.SEQPRODUTO = P.SEQPRODUTO
  
 WHERE 1=1
   -- AND P.SEQPRODUTO = 293303
   AND P.NROEMPRESA = 501
   -- Somente divergentes 
   AND QTDRESERVADAVDA != DP.QTD_PEDVENDA 
   
