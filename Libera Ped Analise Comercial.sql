ALTER SESSION SET CURRENT_SCHEMA = CONSINCO;

-- Altera status de 'A Analise Comercial' Para 'L Liberado', mas antes é preciso alterar para 'D Digitação' :)
-- Pq se nao o Vinicios vai ter que entrar um a um

BEGIN
  FOR t IN (SELECT DISTINCT E.NROPEDVENDA, E.NROEMPRESA
              FROM MSU_PSITEMEXPEDIR X INNER JOIN MSU_PEDIDOSUPRIM Y ON (X.NROPEDIDOSUPRIM = Y.NROPEDIDOSUPRIM AND X.NROEMPRESA = Y.NROEMPRESA AND X.CENTRALLOJA = Y.CENTRALLOJA)
                                        LEFT JOIN MSU_PSITEMEXPEDIDO Z ON (X.NROPEDIDOSUPRIM = Z.NROPEDIDOSUPRIM AND X.NROEMPRESA = Z.NROEMPRESA AND X.CENTRALLOJA = Z.CENTRALLOJA AND X.SEQPRODUTO = Z.SEQPRODUTO AND X.NROEMPDESTINO = Z.NROEMPDESTINO)
                                        LEFT JOIN MAD_PEDVENDA E ON (E.NROPEDVENDA = Z.NROPEDVENDA AND E.NROEMPRESA = Z.NROEMPRESA)
                                       INNER JOIN MAP_PRODUTO K  ON (K.SEQPRODUTO = X.SEQPRODUTO)
             WHERE 1 = 1
               AND NVL(Y.NEGOCIACAO, 'N') = 'N'
               AND EXISTS (SELECT 1
                             FROM DWNAGT_DADOSEMPRESA@BI R
                            WHERE Z.NROEMPRESA = R.NROEMPRESA
                              AND R.TIPO IN ('CD'))
               AND E.DTAINCLUSAO >= TRUNC(SYSDATE) - 30
               AND NVL((Z.QTDTRANSITO), 0) > 0
               AND E.SITUACAOPED = 'A'
               AND E.NROEMPRESA = 502)
  LOOP

  UPDATE MAD_PEDVENDA D SET SITUACAOPED = 'D'
                      WHERE D.NROPEDVENDA = T.NROPEDVENDA
                        AND D.NROEMPRESA =  T.NROEMPRESA;
  UPDATE MAD_PEDVENDA D SET SITUACAOPED = 'L'
                      WHERE D.NROPEDVENDA = T.NROPEDVENDA
                        AND D.NROEMPRESA =  T.NROEMPRESA;
                        
  COMMIT;
  
  END LOOP;
  
END;
