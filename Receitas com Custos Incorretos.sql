-- Prod/Receitas com custos anormais

SELECT X.SEQPRODUTO, DESCCOMPLETA, NROEMPRESA, X.CMULTCUSLIQUIDOEMP, X.CMULTVLRNF 

  FROM CONSINCO.MRL_PRODUTOEMPRESA X INNER JOIN CONSINCO.MAP_PRODUTO P ON X.SEQPRODUTO = P.SEQPRODUTO

 WHERE (X.CMULTCUSLIQUIDOEMP > 999 OR CMULTVLRNF > 999)
   AND EXISTS (SELECT 1 FROM CONSINCO.MRLV_COMPONENTESRECEITA A WHERE A.SEQPRODUTOFINAL = X.SEQPRODUTO
                                                                   OR A.SEQPRODUTOCOMP  = X.SEQPRODUTO)
                                                                   
                                                                   ORDER BY 2

-- Receitas Com Prod Final Relacionados ao Prod Base/Componente:

SELECT DISTINCT SEQRECEITARENDTO, RECEITARENDTO FROM CONSINCO.MRLV_COMPONENTESRECEITA B
WHERE 1=1 
 AND EXISTS (SELECT SEQPRODUTOBASE FROM MAP_PRODUTO X WHERE X.SEQPRODUTO IN (SELECT SEQPRODUTOFINAL FROM CONSINCO.MRLV_COMPONENTESRECEITA BB WHERE BB.SEQRECEITARENDTO = B.SEQRECEITARENDTO
                                   ) AND SEQPRODUTOBASE = B.SEQPRODUTOCOMP) 
 AND B.STATUS = 'A' AND B.STATUSRECRENDTO = 'A'
 
 ORDER BY 1;
