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

SELECT TO_DATE("DATA"||HORA, 'YYYY/MM/DD HH24:MI:SS') DATA,
       TO_NUMBER(PDV)                                 PDV,
       TO_NUMBER(OPERADOR)                            OPERADOR,
       REPLACE("MEIO DE PAGAMENTO",'Ã£','ã')          MEIO_DE_PAGAMENTO,
       TO_NUMBER("NSU ST")                            NSU_ST,
       TO_NUMBER("NSU PDV")                           NSU_PDV,
       TO_NUMBER(REPLACE(VALOR,',','.'))              VALOR,
       TO_NUMBER(INSTR(LOJA, 'LJ') + 2)               LOJA,
       TO_NUMBER(CNPJ)                                CNPJ                

 FROM  CONSINCO.NAGT_SUPERTROCO_SALES_IMP X
 
 WHERE 1=1;

-- Tabela Final

CREATE TABLE CONSINCO.NAGT_SUPERTROCO_SALES AS

-- View

SELECT src.DATA,
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
   ON (tgt."DATA"              = src."DATA"
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
  
 END;

-- Chamada da Proc

BEGIN
  CONSINCO.NAGP_SUPERTROCO_SALES_IMP(1);
  END;
  
-- Final
DELETE FROM CONSINCO.NAGT_SUPERTROCO_SALES WHERE 1=1;

SELECT * FROM CONSINCO.NAGT_SUPERTROCO_SALES
