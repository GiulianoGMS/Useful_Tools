-- Script para replicar os produtos prox da validade do banco SatelitSky para Consinco

-- Select no banco SatelitSky com os campos precisos para inserir na tabela da Consinco:

SELECT NULL SEQPROMOCESPECIAL,  
       NULL SEQPRODUTO,
       1 QTDEMBALAGEM,
       TO_NUMBER(SUBSTR(A.USUARIO,5,2)) NROEMPRESA,
       CODIGO_BARRAS CODACESSOESPECIAL,
       A.PRECO_REBAIXA VLRPRECOPROMOC,
       A.QUANTIDADE QTDESOLICITADA,
       A.QUANTIDADE QTDEETIQEMITIDA,
       TRUNC(SYSDATE) DATAINICIO,
       TO_DATE(TO_CHAR(A.DATA_VENCIMENTO, 'DD-MON-YY')) DTAFIM,
       'P' STATUS,
       'REPLICACAO CONTROLEDATAS SATELITSKY' MOTIVOACAOPROMOC,
       SYSDATE DTAHORALTERACAO,
       'AUTOMATICO' USUALTERACAO,
       SYSDATE DTAHORAPROVACAO,
       'AUTOMATICO' USUAPROVACAO,
       NULL MOVITOREPROVA,
       NULL INDLIBERACAO,
       NULL USULIBERACAO,
       NULL DTAHORALIBERACAO,
       NULL INDEMIETIQUETA,
       NULL SEQPROMOCESPECIALORIGEM,
       NULL INDREPLICAFAMILIA,
       NULL INDREPLICAASSOCIADO,
       NULL INDREPLICARELACIONADO,
       A.EAN EANBASE
       
       FROM CONTROLEDATAS.PRODUTO_VENCIMENTO A
       
 WHERE 1=1
 
   AND TO_DATE(TO_CHAR(A.DATA_VENCIMENTO, 'DD-MON-YY')) >= SYSDATE
   AND FL_RECUSADO   = 0
   AND PRECO_REBAIXA > 0
   AND JUSTIICATIVA  IS NULL
   AND DATA_RECUSA   IS NULL

-- Criando a tabela que será utilizada como base para inserir os dados do banco SatelitSky:

CREATE TABLE CONSINCO.NAGT_BASE_MRL_PROMOCESPECIAL AS 

SELECT X.SEQPROMOCESPECIAL,
       X.SEQPRODUTO,
       X.QTDEMBALAGEM,
       X.NROEMPRESA,
       X.CODACESSOESPECIAL,
       X.VLRPRECOPROMOC,
       X.QTDESOLICITADA,
       X.QTDEETIQEMITIDA,
       X.DTAINICIO,
       X.DTAFIM,
       X.STATUS,
       X.MOTIVOACAOPROMOC,
       X.DTAHORALTERACAO,
       X.USUALTERACAO,
       X.DTAHORAPROVACAO,
       X.USUAPROVACAO,
       X.MOTIVOREPROVA,
       X.INDLIBERACAO,
       X.USULIBERACAO,
       X.DTAHORALIBERACAO,
       X.INDEMIETIQUETA,
       X.SEQPROMOCESPECIALORIGEM,
       X.INDREPLICAFAMILIA,
       X.INDREPLICAASSOCIADO,
       X.INDREPLICARELACIONADO FROM MRL_PROMOCESPECIALHIST X WHERE SEQPROMOCESPECIAL = 4;
       
TRUNCATE TABLE NAGT_BASE_MRL_PROMOCESPECIAL;
SELECT * FROM NAGT_BASE_MRL_PROMOCESPECIAL FOR UPDATE;

-- View para buscar o SEQPRODUTO com base na coluna EANBASE acrescida posteriormente na tabela base:

CREATE OR REPLACE VIEW NAGV_BASE_MRL_PROMOCESPECIAL AS

SELECT NULL SEQPROMOCESPECIAL,
       B.SEQPRODUTO,
       A.QTDEMBALAGEM,
       A.NROEMPRESA,
       A.CODACESSOESPECIAL,
       A.VLRPRECOPROMOC,
       A.QTDESOLICITADA,
       A.QTDEETIQEMITIDA,
       A.DTAINICIO,
       A.DTAFIM,
       A.STATUS,
       A.MOTIVOACAOPROMOC,
       A.DTAHORALTERACAO,
       A.USUALTERACAO,
       A.DTAHORAPROVACAO,
       A.USUAPROVACAO,
       A.MOTIVOREPROVA,
       A.INDLIBERACAO,
       A.USULIBERACAO,
       A.DTAHORALIBERACAO,
       A.INDEMIETIQUETA,
       A.SEQPROMOCESPECIALORIGEM,
       A.INDREPLICAFAMILIA,
       A.INDREPLICAASSOCIADO,
       A.INDREPLICARELACIONADO,
       A.EANBASE FROM NAGT_BASE_MRL_PROMOCESPECIAL A INNER JOIN MAP_PRODCODIGO B ON TO_CHAR(A.EANBASE) = B.CODACESSO;

-- Insert na tabela oficial com base na view que pega também o SEQPROMOCESPECIAL, por linha:

BEGIN
  FOR t IN (SELECT * FROM NAGV_BASE_MRL_PROMOCESPECIAL)
    LOOP
      
    INSERT INTO MRL_PROMOCESPECIALHIST I VALUES ( (SELECT MAX(C.SEQPROMOCESPECIAL) +1 FROM MRL_PROMOCESPECIALHIST C),
                                                   T.SEQPRODUTO,
                                                   T.QTDEMBALAGEM,
                                                   T.NROEMPRESA,
                                                   T.CODACESSOESPECIAL,
                                                   T.VLRPRECOPROMOC,
                                                   T.QTDESOLICITADA,
                                                   T.QTDEETIQEMITIDA,
                                                   T.DTAINICIO,
                                                   T.DTAFIM,
                                                   T.STATUS,
                                                   T.MOTIVOACAOPROMOC,
                                                   T.DTAHORALTERACAO,
                                                   T.USUALTERACAO,
                                                   T.DTAHORAPROVACAO,
                                                   T.USUAPROVACAO,
                                                   T.MOTIVOREPROVA,
                                                   T.INDLIBERACAO,
                                                   T.USULIBERACAO,
                                                   T.DTAHORALIBERACAO,
                                                   T.INDEMIETIQUETA,
                                                   T.SEQPROMOCESPECIALORIGEM,
                                                   T.INDREPLICAFAMILIA,
                                                   T.INDREPLICAASSOCIADO,
                                                   T.INDREPLICARELACIONADO);
      COMMIT;
      END LOOP;
      
   END;
                                                
SELECT * FROM MRL_PROMOCESPECIALHIST 
   
