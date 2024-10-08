-- Replica Parametros de Importação da 503 para 502
-- Insert simples msm por preguica e falta de tempo

ALTER SESSION SET CURRENT_SCHEMA = CONSINCO;

-- Replicando Parametros de Importacao | Gerais 

INSERT INTO CONSINCO.MAD_PIPARAMGERAL B (

SELECT 502,
       B.UTZALCALIBERACAO,
       B.PERCTOLLIBERACAO,
       B.INDGERASEQPROCAUTO,
       B.TIPOMEDVDA,
       B.INDCONSPENDRECEBE,
       B.INDCONSPENDEXPED,
       B.VALORTOLERLIB,
       B.INDGERANFCOMP,
       B.SEQPRODNFCOMP,
       B.INDAJUSTACUSTOPROD,
       B.UTZCONCPROCESSO,
       B.INDCONTABILPOSDI,
       B.PMTALTERPEDIMPPROC,
       B.LOTECONTABIL,
       B.CONTADBADT,
       B.TIPOENTDBADT,
       B.CTROCUSTODBADT,
       B.CONTACRADT,
       B.TIPOENTCRADT,
       B.CTROCUSTOCRADT,
       B.INDCONSESTOQUE,
       B.PMTALTERDESPAPOSPEDIDO,
       B.INDTODASEMPRESASDIVISAO,
       B.INDUTILIZAPREVIAADICOES
  FROM CONSINCO.MAD_PIPARAMGERAL B
 WHERE NROEMPRESA IN (503)
       AND B.NROEMPRESA IN (503));
       
       COMMIT;
       
       
-- Replicando Parametros de Adiantamentos

INSERT INTO CONSINCO.MAD_PITIPOADIANTAMENTO (

SELECT A.SEQTIPOADIANT + 200,
       502,
       A.DESCTIPOADIANT,
       A.INCIDECUSTOPROD,
       A.INDDESPESATRIBUTO,
       A.INCIDEBASETRIB,
       A.INDGERAFINANCEIRO,
       A.INDFORMARATEIO,
       A.NROPZOMINPAGTO,
       A.CODESPECIEINCTITFIN,
       A.NROEMPRESAMAEINCTIT,
       A.CODOPERINCTITFIN,
       A.CODOPERABATRECFIN,
       A.TIPODESTINATARIO,
       A.SEQPESSOAFISCAL,
       A.STATUSTIPOAD,
       A.LOTECONTABIL,
       A.CONTADBADT,
       A.TIPOENTDBADT,
       A.CTROCUSTODBADT,
       A.CONTACRADT,
       A.TIPOENTCRADT,
       A.CTROCUSTOCRADT,
       A.INDRATEIOPROCESSO,
       A.INDABATPROC,
       A.INDDIFERCAMBIO,
       A.INDGERAFINANCEIROPEDBONIF,
       A.INCIDEBASETRIBIIMP,
       A.INCIDEBASETRIBIPI,
       A.INCIDEBASETRIBPIS,
       A.INCIDEBASETRIBCOFINS,
       A.INCIDEBASETRIBICMS,
       A.CODESPECIEINCTITFINREC,
       A.CODOPERINCTITFINREC
  FROM MAD_PITIPOADIANTAMENTO A

 WHERE NROEMPRESA IN (503));
 
 COMMIT;
 
