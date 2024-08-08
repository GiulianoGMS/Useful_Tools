-- Job SP_GERARECEBTOXMLAUTO_NAG

ALTER SESSION SET CURRENT_SCHEMA = CONSINCO;

BEGIN
-- Faz output da empresa com erro e do seqnotafiscal
-- Depois que rodar este pode executar o job normal
FOR X IN (
                 SELECT A.NROEMPRESA
                 FROM DWNAGT_DADOSEMPRESA@BI A
                 WHERE A.TIPO in ('LOJA','CD')
                 AND A.NROEMPRESA NOT IN (502,504,505)
                 order by 1
                 )                 
               LOOP
      CONSINCO.SP_GERARECEBTOXMLAUTO_NAG(X.NROEMPRESA);
      
      COMMIT;
      
      END LOOP;
      END;
      
-- Pega a informação do output da proc acima com base no seqnotafiscal

 SELECT A.SEQNOTAFISCAL, A.CHAVEACESSO, A.SEQPESSOA, G.NROEMPRESA, A.PEDIDO
   FROM (SELECT A.M000_NR_DOCUMENTO NUMERONF, NVL(D.SEQPESSOA, 0) SEQPESSOA,
                 TO_CHAR(A.M000_NR_SERIE) SERIENF, 
                  -- TO_CHAR ADD ERRO INVALID NUMBER
                 A.M000_NR_CHAVE_ACESSO CHAVEACESSO,
                 A.M000_ID_NF SEQNOTAFISCAL, MIN(F.SEQPESSOA) SEQPESSOAEMP,
                 A.M000_DS_PEDIDO PEDIDO
            FROM TMP_M000_NF A, TMP_M001_EMITENTE B, GE_PESSOA D,
                 TMP_M002_DESTINATARIO E, GE_PESSOA F, MAX_EMPRESA G
           WHERE A.M000_DM_TIPO = 1
             AND A.M000_ID_NF = &SeqNotaFiscal
             --AND A.M000_NR_CHAVE_ACESSO = &Chave 35240848508402000128550010002927831003898460
             AND NVL(A.CODOPERMANIFESTDEST, '0') NOT IN ('210220', '210240')
             AND NOT EXISTS
           (SELECT 1
                    FROM MFL_NFELOG
                   WHERE MFL_NFELOG.DESCRICAO LIKE '%OPERAÇÃO NÃO REALIZADA%'
                     AND MFL_NFELOG.NFECHAVEACESSO = A.M000_NR_CHAVE_ACESSO)
             AND A.M000_ID_NF = B.M000_ID_NF
             AND D.NROCGCCPF(+) =
                 TO_NUMBER(SUBSTR(B.M001_NR_CNPJ,
                                  1,
                                  LENGTH(B.M001_NR_CNPJ) - 2))
             AND D.DIGCGCCPF(+) = TO_NUMBER(SUBSTR(B.M001_NR_CNPJ, -2))
             AND E.M000_ID_NF = A.M000_ID_NF
             AND F.FISICAJURIDICA = 'J'
             AND F.NROCGCCPF =
                 TO_NUMBER(SUBSTR(E.M002_NR_CNPJ_CPF,
                                  1,
                                  LENGTH(E.M002_NR_CNPJ_CPF) - 2))
             AND F.DIGCGCCPF = TO_NUMBER(SUBSTR(E.M002_NR_CNPJ_CPF, -2))
             AND F.STATUS = 'A'
             AND G.SEQPESSOAEMP = F.SEQPESSOA
             AND G.STATUS = 'A'
             AND A.DTAHORINCLUSAO >= TRUNC(SYSDATE) - 10
             AND A.M000_ID_NF IN
                 (SELECT MAX(Z.M000_ID_NF)
                    FROM TMP_M000_NF Z
                   WHERE Z.M000_NR_CHAVE_ACESSO = A.M000_NR_CHAVE_ACESSO)
             AND EXISTS
           (SELECT 1
                    FROM MAF_FORNECEDOR H
                   WHERE H.SEQFORNECEDOR = D.SEQPESSOA
                     AND H.STATUSGERAL = 'A')
             AND (('C'= 'C' AND EXISTS
                  (SELECT 1
                      FROM TMP_M014_ITEM H
                     WHERE H.M000_ID_NF = A.M000_ID_NF
                       AND (MOD(H.M014_CD_CFOP, 1000) BETWEEN 100 AND 122 OR
                           MOD(H.M014_CD_CFOP, 1000) BETWEEN 126 AND 128 OR
                           MOD(H.M014_CD_CFOP, 1000) BETWEEN 250 AND 257 OR
                           MOD(H.M014_CD_CFOP, 1000) BETWEEN 401 AND 407 OR
                           MOD(H.M014_CD_CFOP, 1000) BETWEEN 651 AND 653 OR
                           MOD(H.M014_CD_CFOP, 1000) IN (551, 556, 910)))) OR
                 ('T' = 'D' AND EXISTS
                  (SELECT 1
                      FROM TMP_M014_ITEM H
                     WHERE H.M000_ID_NF = A.M000_ID_NF
                       AND (MOD(H.M014_CD_CFOP, 1000) BETWEEN 200 AND 211 OR
                           MOD(H.M014_CD_CFOP, 1000) BETWEEN 660 AND 662 OR
                           MOD(H.M014_CD_CFOP, 1000) BETWEEN 410 AND 411 OR
                           MOD(H.M014_CD_CFOP, 1000) = 553))) OR
                 'x' = 'T')
             AND G.NROEMPRESA = 51
           GROUP BY A.M000_NR_DOCUMENTO, NVL(D.SEQPESSOA, 0),
                    TO_CHAR(A.M000_NR_SERIE), A.M000_NR_CHAVE_ACESSO,
                    A.M000_ID_NF, A.M000_DS_PEDIDO) A, MAX_EMPRESA G
  WHERE A.SEQPESSOAEMP = G.SEQPESSOAEMP
    AND NOT EXISTS (SELECT X.SEQNOTAFISCAL
           FROM MLF_AUXNOTAFISCAL X
          WHERE X.NUMERONF = A.NUMERONF
            AND X.SEQPESSOA = A.SEQPESSOA
            AND TRIM(X.SERIENF) = A.SERIENF
            AND X.NROEMPRESA = G.NROEMPRESA
            AND ISNUMERIC(X.SERIENF) = 'S')
    AND NOT EXISTS (SELECT Y.SEQNOTAFISCAL
           FROM MLF_NOTAFISCAL Y
          WHERE Y.NUMERONF = A.NUMERONF
            AND Y.SEQPESSOA = A.SEQPESSOA
            AND TRIM(Y.SERIENF) = A.SERIENF
            AND Y.NROEMPRESA = G.NROEMPRESA
            AND ISNUMERIC(Y.SERIENF) = 'S'
         UNION
         SELECT YY.SEQNOTAFISCAL
           FROM MLF_NOTAFISCAL YY, MAX_CODGERALOPER PP
          WHERE YY.NFREFERENCIANRO = A.NUMERONF
            AND TRIM(YY.NFREFERENCIASERIE) = A.SERIENF
            AND YY.SEQPESSOA = A.SEQPESSOA
            AND YY.NROEMPRESA = G.NROEMPRESA
            AND YY.TIPNOTAFISCAL = 'E'
            AND ISNUMERIC(YY.NFREFERENCIASERIE) = 'S'
            AND PP.CODGERALOPER = YY.CODGERALOPER
            AND PP.TIPUSO = 'E'
            AND PP.INDNFREFPRODRURAL = 'S')
    AND G.NROEMPRESA = &Loja --51
    
-- Analisa a duplicidade na MRL_NFEIMPPROCESS

-- Descobrindo a constraint do erro

SELECT TABLE_NAME
  FROM ALL_CONS_COLUMNS
 WHERE CONSTRAINT_NAME = 'SYS_C0041662'
 
-- Tabela MRL_NFEIMPPROCESS
 
 DELETE FROM MRL_NFEIMPPROCESS WHERE CHAVE_ACESSO = 35240848508402000128550010002927831003898460
 
  SELECT * FROM MRL_NFEIMPPROCESS WHERE CHAVE_ACESSO = 35240848508402000128550010002927831003898460
