ALTER SESSION SET CURRENT_SCHEMA = CONSINCO;

SELECT XI.NUMERODF, X.SEQPRODUTO, X.CODACESSO, NAGF_VALIDA_EAN13(X.CODACESSO) EAN_VALIDO
  FROM MFL_DFITEM XI INNER JOIN MAP_PRODCODIGO X ON X.SEQPRODUTO = XI.SEQPRODUTO AND X.TIPCODIGO = 'E'
 WHERE XI.NUMERODF = 6191
   AND NROEMPRESA = 507;
 