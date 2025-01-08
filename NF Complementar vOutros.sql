-- Emissao de NF Complementar com valor apenas no campo vOutros
-- Não é possível pela aplicação.
-- Primeiro, setar o campo INDIMPORTEXPORT no CGO para 'S':

SELECT INDIMPORTEXPORT, ROWID
  FROM MAX_CODGERALOPER X
 WHERE CODGERALOPER = 44;
-- Transforme a pessoa para cliente
-- Crie a NF no módulo Expedição (não no recebimento) > Nota Fiscal de Complemento de Impostos  -- CGO 44
-- Vincule a DI do processo pela NF emitida no CGO 43
-- Salve a NF com os itens necessários, CFOP 3102 (EX), sem quantidade nem valor item
-- Após salvar, preencher a tag VLRDESPTRIBUTITEM com o valor que será emitido na tag vOutras (por item) pelo banco:
SELECT XI.ROWID,
       XI.VLRITEM,
       XI.VLRDESPESAAD,
       VLRDESPTRIBUTITEM,
-- É preciso validar se os campos abaixo estão populados com ZERO, se não haverá erro na montagem do arquivo enviado à NDD
-- Se estiverem nulos, preencher com 0 emtodos:
       XI.PERALIQUOTAICMS,
       XI.VLRPIS,
       XI.VLRCOFINS,
       XI.BASCALCOFINS,
       XI.PERALIQUOTACOFINS,
       XI.BASCALCPIS,
       XI.PERALIQUOTAPIS
--
  FROM MLF_NFITEM XI
 INNER JOIN MLF_NOTAFISCAL X
    ON X.SEQNF = XI.SEQNF
 WHERE X.NUMERONF = 8629
   AND X.NROEMPRESA = 503;

-- Commit e Enviar NF :)
