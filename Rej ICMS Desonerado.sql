Correção emissao com rejeicao ICMS DESONERADO
Loja 39
 
-- Descobre o SEQNF da nota pra buscar depois na tabela de item
 
SELECT DISTINCT X.SEQNF 
  FROM MFL_DOCTOFISCAL
WHERE X.NUMERODF = 32840 
    AND X.NROEMPRESA = 39 
    AND X.CODGERALOPER = 37
-- 381907274 < Codigo
-- Com esse codigo, faz o select na tabela de itens
 
-- Apagar os valores de INDMOTIVODESOICMS, VLRDESCICMS
 
SELECT ROWID, VLRDESCICMS, INDMOTIVODESOICMS FROM MFL_DFITEM XI WHERE XI.SEQNF = 381907274;

-- Depois reenviar a nota
