-- Importacao Dados SuperTroco

SELECT * FROM ALL_DIRECTORIES WHERE DIRECTORY_NAME = 'SUPERTROCO';

GRANT READ, WRITE ON DIRECTORY SUPERTROCO TO ADMGIULIANO;

SELECT * FROM CONSINCO.NAGT_SUPERTROCO_SALES_IMP

-- Tab que sobe os dados

CREATE TABLE CONSINCO.NAGT_SUPERTROCO_SALES_IMP
(
  "DATA"              VARCHAR2(100),
  HORA                VARCHAR2(100),
  PDV                 VARCHAR2(100),
  OPERADOR            VARCHAR2(100),
  "MEIO DE PAGAMENTO" VARCHAR2(100),
  "NSU ST"            VARCHAR2(100),
  "NSU PDV"           VARCHAR2(100),
  VALOR               VARCHAR2(100),
  LOJA                VARCHAR2(100),
  CNPJ                VARCHAR2(100)
)
ORGANIZATION EXTERNAL
(
  TYPE ORACLE_LOADER
  DEFAULT DIRECTORY SUPERTROCO
  ACCESS PARAMETERS 
  (
    RECORDS DELIMITED BY NEWLINE
    CHARACTERSET WE8MSWIN1252
    STRING SIZES ARE IN BYTES
    NOBADFILE
    NODISCARDFILE
    NOLOGFILE
    SKIP 1
    FIELDS TERMINATED BY ';' RTRIM
    REJECT ROWS WITH ALL NULL FIELDS
    (
       "DATA"              CHAR,
       HORA                CHAR,
       PDV                 CHAR,
       OPERADOR            CHAR,
       "MEIO DE PAGAMENTO" CHAR,
       "NSU ST"            CHAR,
       "NSU PDV"           CHAR,
       VALOR               CHAR,
       LOJA                CHAR,
       CNPJ                CHAR
    )
  )
  LOCATION (SUPERTROCO:'salesasync.csv')
)
REJECT LIMIT UNLIMITED;


-- View com a formatação dos dados

CREATE OR REPLACE VIEW CONSINCO.NAGV_SUPERTROCO_SALES_IMP AS

SELECT TO_DATE(TO_DATE("DATA",'YYYY/MM/DD'), 'DD/MM/YY') DATA,
       HORA,
       TO_DATE(TO_DATE("DATA", 'YYYY/MM/DD')||' '||HORA, 'DD/MM/YY HH24:MI:SS') DTA_HORA,
       TO_NUMBER(PDV)                                 PDV,
       TO_NUMBER(OPERADOR)                            OPERADOR,
       REPLACE("MEIO DE PAGAMENTO",'Ã£','ã')          MEIO_DE_PAGAMENTO,
       TO_NUMBER("NSU ST")                            NSU_ST,
       TO_NUMBER("NSU PDV")                           NSU_PDV,
       TO_NUMBER(REPLACE(VALOR,',','.'))              VALOR,
       TO_NUMBER(SUBSTR(LOJA,INSTR(LOJA, 'LJ')+2,2))  LOJA,
       TO_NUMBER(CNPJ)                                CNPJ                

 FROM  CONSINCO.NAGT_SUPERTROCO_SALES_IMP X
 
 WHERE 1=1;


-- Tabela Final

CREATE TABLE CONSINCO.NAGT_SUPERTROCO_SALES AS

-- View

SELECT src.DATA,
       src.HORA,
       src.DTA_HORA,
       src.PDV,
       src.OPERADOR,
       src.MEIO_DE_PAGAMENTO,
       src.NSU_ST,
       src.NSU_PDV,
       src.VALOR,
       src.LOJA,
       src.CNPJ FROM CONSINCO.NAGV_SUPERTROCO_SALES_IMP src;

-- Apagando pois so usoa view para criar a tabela formatada

DELETE FROM CONSINCO.NAGT_SUPERTROCO_SALES WHERE 1=1;

-- Procedure | Merge com Update
-- Chamada
BEGIN
  CONSINCO.NAGP_SUPERTROCO_SALES_IMP(1);
END;

-- Procedure 

 CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_SUPERTROCO_SALES_IMP (t IN NUMBER) AS

BEGIN

MERGE INTO CONSINCO.NAGT_SUPERTROCO_SALES tgt

USING NAGV_SUPERTROCO_SALES_IMP src
   ON (tgt."DTA_HORA"              = src."DTA_HORA"
  AND  tgt.PDV                 = src.PDV
  AND  tgt.OPERADOR            = src.OPERADOR
  AND  tgt.MEIO_DE_PAGAMENTO   = src.MEIO_DE_PAGAMENTO
  AND  tgt.NSU_ST              = src.NSU_ST
  AND  tgt.NSU_PDV             = src.NSU_PDV
  AND  tgt.LOJA                = src.LOJA
  AND  tgt.CNPJ                = src.CNPJ
  )

WHEN MATCHED THEN
  UPDATE SET
  tgt.VALOR = src.VALOR

WHEN NOT MATCHED THEN

  INSERT (
    "DATA"              ,
    HORA                ,
    DTA_HORA            ,
    PDV                 ,
    OPERADOR            ,
    MEIO_DE_PAGAMENTO   ,
    NSU_ST              ,
    NSU_PDV             ,
    VALOR               ,
    LOJA                ,
    CNPJ
  )
  VALUES (
    src.DATA,
    src.HORA,
    src.DTA_HORA,
    src.PDV,
    src.OPERADOR,
    src.MEIO_DE_PAGAMENTO,
    src.NSU_ST,
    src.NSU_PDV,
    src.VALOR,
    src.LOJA,
    src.CNPJ
  );

  COMMIT;

  /*BEGIN
    CONSINCO.NAGP_MOVEARQ_SUPERTROCO_MANUAl;
    END;*/

 END;


-- Chamada da Proc

BEGIN
  CONSINCO.NAGP_SUPERTROCO_SALES_IMP(1);
  END;
  
-- Movimentando arquivos
-- Manual
CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_MOVEARQ_SUPERTROCO_MANUAL (t NUMBER) AS

BEGIN
  
DECLARE
  src_file  UTL_FILE.FILE_TYPE;
  dest_file UTL_FILE.FILE_TYPE;
  buffer    VARCHAR2(32767);
  vDta VARCHAR2(50);
BEGIN
  vDta := REPLACE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'),'/','');
  -- Abrir o arquivo original para leitura
  src_file := UTL_FILE.FOPEN('SUPERTROCO', 'salesasync.csv', 'R');

  -- Abrir um novo arquivo para escrita com o novo nome
  dest_file := UTL_FILE.FOPEN('/u02/dados/SUPERTROCO/Sales/BKP', 'SalesAsync_Manual.csv', 'W');

  -- Loop para ler cada linha do arquivo original e escrever no novo arquivo
  LOOP
    BEGIN
      UTL_FILE.GET_LINE(src_file, buffer);
      UTL_FILE.PUT_LINE(dest_file, buffer);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        EXIT;
    END;
  END LOOP;

  -- Fechar ambos os arquivos
  UTL_FILE.FCLOSE(src_file);
  UTL_FILE.FCLOSE(dest_file);

  -- Remover o arquivo original
  UTL_FILE.FREMOVE('SUPERTROCO', 'salesasync.csv');

END;
END;
  
-- Movimentando os arquivos pelo job
CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_MOVEARQ_SUPERTROCO AS

BEGIN
  
DECLARE
  src_file  UTL_FILE.FILE_TYPE;
  dest_file UTL_FILE.FILE_TYPE;
  buffer    VARCHAR2(32767);
  vDta VARCHAR2(50);
BEGIN
  vDta := REPLACE(TO_CHAR(SYSDATE -1, 'DD/MM/YYYY'),'/','');
  -- Abrir o arquivo original para leitura
  src_file := UTL_FILE.FOPEN('SUPERTROCO', 'salesasync.csv', 'R');

  -- Abrir um novo arquivo para escrita com o novo nome
  dest_file := UTL_FILE.FOPEN('/u02/dados/SUPERTROCO/Sales/BKP', 'SalesAsync_'||vDta||'.csv', 'W');

  -- Loop para ler cada linha do arquivo original e escrever no novo arquivo
  LOOP
    BEGIN
      UTL_FILE.GET_LINE(src_file, buffer);
      UTL_FILE.PUT_LINE(dest_file, buffer);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        EXIT;
    END;
  END LOOP;

  -- Fechar ambos os arquivos
  UTL_FILE.FCLOSE(src_file);
  UTL_FILE.FCLOSE(dest_file);

  -- Remover o arquivo original
  UTL_FILE.FREMOVE('SUPERTROCO', 'salesasync.csv');

END;
END;


-- Final
-- Apaga
DELETE FROM CONSINCO.NAGT_SUPERTROCO_SALES WHERE DATA = '06-jun-2024';
-- Checa
SELECT *
  FROM CONSINCO.NAGT_SUPERTROCO_SALES X WHERE DATA = '07-jun-2024'
  
-- Rotina automatica | JOB
  
BEGIN
  -- Importa o arquivo salesasyc.csv para a tabela
  CONSINCO.NAGP_SUPERTROCO_SALES_IMP(1);
  -- Movimenta o arquivo ajustado para a pasta de bkp
  CONSINCO.NAGP_MOVEARQ_SUPERTROCO;
  
END;

-- Job NAGJ_SUPERTROCO_SALES

DECLARE
  vPassou VARCHAR2(1);
  vErro   VARCHAR2(400);
BEGIN
  -- Importa o arquivo salesasyc.csv para a tabela
  vPassou := 'N';
  BEGIN
  CONSINCO.NAGP_SUPERTROCO_SALES_IMP(1);
  vPassou := 'S';
  
  EXCEPTION
    WHEN OTHERS THEN
  vPassou := 'N';
  vErro   := SQLERRM;
    INSERT INTO CONSINCO.NAGT_SUPERTROCO_SALES_IMP_LOG VALUES(SYSDATE, vErro);
  END;
  
  IF vPassou = 'S' THEN
  -- Se a importação der certo, movimenta o arquivo
  -- Movimenta o arquivo ajustado para a pasta de bkp
  CONSINCO.NAGP_MOVEARQ_SUPERTROCO;
  END IF;
  
END;

-- Tabela de log de erros

CREATE TABLE CONSINCO.NAGT_SUPERTROCO_SALES_IMP_LOG (DATA DATE,
                                                     ERRO_MSG VARCHAR2(400));
                                                     
SELECT * FROM CONSINCO.NAGT_SUPERTROCO_SALES_IMP_LOG 

TRUNCATE TABLE CONSINCO.NAGT_SUPERTROCO_SALES_IMP_LOG;
