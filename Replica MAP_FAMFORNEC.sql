ALTER SESSION SET CURRENT_SCHEMA = CONSINCO;

-- Replica Fornec 501 para 507

-- Primeiro, Segmento Fornec para nao dar erro na constrant

       SELECT * FROM MAF_FORNECSEGTO Z WHERE SEQFORNECEDOR = 501 FOR UPDATE -- e copia pra 507
       
-- Depois, replica FamFornec

INSERT INTO MAP_FAMFORNEC Z (

SELECT X.SEQFAMILIA,
       507,
       'N',
       X.INDREPLICACAO,
       X.INDGEROUREPLICACAO,
       X.NROSEGFORNEC,
       X.INDINDENIZAVARIA,
       X.TIPFORNECEDORFAM,
       X.PADRAOEMBCOMPRAFORNEC,
       X.CALCDESCSUFRAMAPISCOFINS,
       X.INDCONTROLAFLEX,
       X.INDMEDIDAMETADISTRIB,
       X.NROBASEEXPORTACAO,
       X.EMBPADRAOIMPXML,
       X.USUARIOALTERACAO,
       X.INDBUSCANFAUTODEVFORNEC,
       X.FATORCONVEMBXML,
       'N',
       X.INDCOBRAIPIRECEB,
       X.DATAHORAALTERACAO,
       X.INDCONSIDTIPFORNCGO FROM MAP_FAMFORNEC X 
      
      WHERE SEQFORNECEDOR = 501
        AND NOT EXISTS (SELECT 1 FROM MAP_FAMFORNEC Z WHERE Z.SEQFAMILIA = X.SEQFAMILIA AND Z.SEQFORNECEDOR = 507)
        
        );

COMMIT;
