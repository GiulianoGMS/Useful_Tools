SELECT /*+OPTIMIZER_FEATURES_ENABLE('11.2.0.4')*/
  DISTINCT A.SEQLOTEMODELO, X.SEQGERCOMPRA, X.DESCRITIVO, X.SITUACAOLOTE
  FROM NAGT_CONTROLEABASTAUTO A INNER JOIN MAC_GERCOMPRA X ON A.SEQLOTEMODELO = X.SEQGERCOMPRA
                                       
                                      WHERE 1=1
                                       -- Busca os lotes que possuem o comprador parametrizado
                                        AND (EXISTS (SELECT 1 FROM CONSINCO.MAC_GERCOMPRAFILTRO Z
                                                             WHERE Z.SEQGERCOMPRA = A.SEQLOTEMODELO
                                                               AND Z.COMPRADORSEL LIKE '%'||(SELECT SEQCOMPRADOR FROM MAX_COMPRADOR MC WHERE MC.COMPRADOR = 'SANDRA')||'%'
                                                     )
                                       -- Ou busca os lotes que possuem categorias que tem as familias vinculadas ao comprador
                                         OR  EXISTS (SELECT 1
                                                       FROM CONSINCO.MAC_GERCOMPRAFILTRO Z
                                                       WHERE Z.SEQGERCOMPRA = A.SEQLOTEMODELO
                                                         AND EXISTS (
                                                             SELECT 1
                                                             FROM MAP_FAMDIVCATEG FC INNER JOIN MAP_FAMDIVISAO FD ON FD.SEQFAMILIA = FC.SEQFAMILIA
                                                             WHERE FD.SEQCOMPRADOR =        (SELECT SEQCOMPRADOR FROM MAX_COMPRADOR MC WHERE MC.COMPRADOR = 'SANDRA')
                                                               AND Z.CATEGORIASSEL LIKE '%' || FC.SEQCATEGORIA || '%'
                                                          )
                                                    
                                             ));
                                             
