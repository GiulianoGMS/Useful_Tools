ALTER SESSION SET CURRENT_SCHEMA = CONSINCO;

-- Quantidade e Volume de Notas/Itens recebidos nas lojas por meio do AA - Abastecimento Automático - Sugestoes Mindset

WITH CTE_DTA AS (SELECT DATE '2024-10-01' DTA FROM DUAL)

SELECT DISTINCT A.NROEMPRESA CD, TO_CHAR(A.DTAHOREMISSAO, 'DD/MM/YYYY') DATA_EMISSAO, ROUND(SUM(AI.QUANTIDADE)) QTD_UNI_FAT
  FROM MFL_DOCTOFISCAL A INNER JOIN MFL_DFITEM AI ON A.SEQNF = AI.SEQNF
                         INNER JOIN CTE_DTA CTE ON A.DTAMOVIMENTO >= CTE.DTA

WHERE 1=1 
  /*AND A.NROPEDIDOVENDA IN (SELECT Z.NROPEDVENDA FROM MAD_PEDVENDA Z INNER JOIN MAD_PEDVENDAITEM ZI ON Z.NROPEDVENDA = ZI.NROPEDVENDA
                                         INNER JOIN CTE_DTA CTE ON Z.DTAINCLUSAO >= CTE.DTA                                     
                            WHERE 1=1
                              AND Z.NROEMPRESA IN (502,507,508)
                            --AND Z.USUINCLUSAO = 'AUTOMATICO'
                              AND SITUACAOPED = 'F'
                              AND SEQPESSOA NOT IN (501,502,503,504,505,506,507,508)
                            --AND Z.SEQPESSOA = 8
                              )*/
  AND A.STATUSDF != 'C'
  AND A.NROEMPRESA IN (501,503,502,507,508)
  AND A.SEQPESSOA < 500

GROUP BY A.NROEMPRESA,  TO_CHAR(A.DTAHOREMISSAO, 'DD/MM/YYYY')

ORDER BY 2