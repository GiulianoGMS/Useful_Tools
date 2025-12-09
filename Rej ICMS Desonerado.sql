-- Correção emissao com rejeicao ICMS DESONERADO
-- Loja 39
-- Descobre o SEQNF da nota pra buscar depois na tabela de item 
-- Apagar os valores de INDMOTIVODESOICMS, VLRDESCICMS
 
SELECT ROWID, VLRDESCICMS, INDMOTIVODESOICMS
  FROM MFL_DFITEM XI
 WHERE XI.SEQNF = (SELECT DISTINCT X.SEQNF
                     FROM MFL_DOCTOFISCAL X
                    WHERE X.NUMERODF = 32964
                          AND X.NROEMPRESA = 39
                          AND X.CODGERALOPER = 37);
