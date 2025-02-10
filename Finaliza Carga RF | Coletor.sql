UPDATE MRF_ATIVIDADEUSUARIO A SET DTAINICIOATV              = SYSDATE,
                                  DTAFIMATV                 = SYSDATE,
                                  A.DTAHORFINALIZAATIVIDADE = SYSDATE,
                                  SITUACAO = 'F'
                                  
 WHERE SEQLOTE = &NroLote AND NROEMPRESA = &NroEmpresa AND SITUACAO != 'F';

SELECT A.*
  FROM MRF_ATIVIDADEUSUARIO A
 WHERE A.SEQLOTE = 1088
       AND A.NROEMPRESA = 25
       AND SITUACAO != 'F'
