ALTER SESSION SET CURRENT_SCHEMA = CONSINCO;

-- Descobre qual o produto com a verba maior que o custo final no lote causando erro na geração do pedido de compras

SELECT SEQGERCOMPRA, NROEMPRESA, X.SEQPRODUTO, X.TFVLRCUSTOBASE, X.QTDPEDIDA,
       X.VLRUNITVERBA * QTDEMBALAGEM VERBA, X.TFVLRVERBABONIF

  FROM MAC_GERCOMPRAITEM X
 WHERE SEQGERCOMPRA = 311435
   AND TFVLRVERBABONIF > TFVLRCUSTOBASE
