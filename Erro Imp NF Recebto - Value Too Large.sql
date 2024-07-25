-- Erro ORA-20200: ORA-01438: value larger than specified precision allowed for this column
-- PKG PKG_MLF_IMPNFERECEBIMENTO

-- Antes da chamada, precisei mudar na PKG as variaveis pnExcluiOphos e pnImpOK para não precisar ser tipo IN

create or replace package body PKG_MLF_IMPNFERECEBIMENTO is
  -- ##### Importa as notas das tabelas de Integração #########
  PROCEDURE SP_IMPORTA_TMP(
              pnIDNFe              IN        TMP_M000_NF.M000_ID_NF%TYPE,
              pnCodGeralOper       IN        MAX_CODGERALOPER.CODGERALOPER%TYPE,
              pnNroEmpresa         IN        MAX_EMPRESA.NROEMPRESA%TYPE,
              pdDtaHorLancto       IN        MLF_AUXNOTAFISCAL.DTAHORLANCTO%TYPE,
              psUsuLancto          IN        MLF_AUXNOTAFISCAL.USULANCTO%TYPE,
             
              pnChaveNFe           IN        TMP_M000_NF.M000_NR_CHAVE_ACESSO%TYPE)
  IS
      pnExcluiOphos INTEGER;
      pnImpOk       INTEGER;
      (...)

-- Chamda da Proc:

BEGIN PKG_MLF_IMPNFERECEBIMENTO.SP_IMPORTA_TMP('21722331','1','501',SYSDATE,'GIGOMES','35240728784450000131550010000826931000437674');
 END; 

-- Executando, retorna erro na linha 2139 (no Exception)
-- Para descobrir a linha causadora do erro, alterei a PKG inserindo DBMS_OUTPUT.PUT_LINEs e inseri no exception na linha 2139:

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error Code: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Error Stack: ' || DBMS_UTILITY.FORMAT_ERROR_STACK);
        DBMS_OUTPUT.PUT_LINE('Error Backtrace: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        DBMS_OUTPUT.PUT_LINE('Call Stack: ' || DBMS_UTILITY.FORMAT_CALL_STACK);
        RAISE;

-- Feito isso, executando a chamada novamente consegui chegar na linha do Insert que estava causando erro
-- CTRL G > Linha 695 na PKG - Descoberta pelo Backtrace:

INSERT INTO MLF_AUXNFITEM (...)

-- Criei uma tabela paralela com todos os campos da MLF_AUXNFITEM como VARCHAR2(2000) para fazer o Insert sem erro 
-- e descobrir qual a coluna posteriormente
-- Então, alterei na linha 695 e deixei o Insert assim:

INSERT INTO MLF_AUXNFITEM_TESTE (...)

-- Compilado, executei novamente a chamada da Proc com a minha tabela com VARCHAR2(2000) e executou normalmente
-- Com os dados na tabela paralela, criei um bloco para fazer insert (a partir da paralela) na tabela original por SEQAUXNFITEM (como um rowid) para descobrir qual a linha com problema

BEGIN

  INSERT INTO MLF_AUXNFITEM
    SELECT *
      FROM MLF_AUXNFITEM_TESTE 
      --WHERE  SEQAUXNFITEM = 4
     ;
      EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error Code: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Error Stack: ' || DBMS_UTILITY.FORMAT_ERROR_STACK);
        DBMS_OUTPUT.PUT_LINE('Error Backtrace: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        DBMS_OUTPUT.PUT_LINE('Call Stack: ' || DBMS_UTILITY.FORMAT_CALL_STACK);
        RAISE;
END;

-- Descoberto então que o problema está no SEQAUXNFITEM 4, quarto item da NF
-- Comparando alguns campos desta linha, identifiquei que a coluna PERALIQUOTAICMS estava igual a 100.00%
-- A DATA_PRECISION da coluna PERALIQUOTAICMS é 4 e não 5

SELECT *
FROM user_tab_columns
WHERE table_name = 'MLF_AUXNFITEM' AND COLUMN_NAME = 'PERALIQUOTAICMS'

-- Pesquisando na tabela MLF_AUXNFITEM por itens com a aliquota = a 100.00%, não encontrei nenhum item
-- Questionando ao Fiscal, o pICMS correto deveria ser 18% e não 100% (<pICMS>18.00</pICMS>)
-- Ajustei em homologação de 100% para 18%, retornei a tabela original na PKG e fiz a chamada da Proc novamente
-- Proc executou com sucesso.
