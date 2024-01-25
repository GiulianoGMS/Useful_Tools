-- Lotes Gerados por Abast/Comprador

ALTER SESSION SET CURRENT_SCHEMA = CONSINCO;

SELECT * FROM MAC_GERCOMPRA G
 WHERE 1=1
   AND G.DTAHORINCLUSAO > TRUNC(SYSDATE)
   AND EXISTS (SELECT 1 FROM (

SELECT
  DISTINCT  X.SEQGERCOMPRA, X.DESCRITIVO, X.SITUACAOLOTE
  FROM NAGT_CONTROLEABASTAUTO A INNER JOIN MAC_GERCOMPRA X ON A.SEQLOTEMODELO = X.SEQGERCOMPRA
                                       
                                      WHERE 1=1
                                        AND X.TIPOLOTE != 'C'
                                       -- Busca os lotes que possuem o comprador parametrizado
                                        AND (EXISTS (SELECT 1 FROM CONSINCO.MAC_GERCOMPRAFILTRO Z
                                                             WHERE Z.SEQGERCOMPRA = A.SEQLOTEMODELO
                                                               AND Z.COMPRADORSEL LIKE '%'||(SELECT SEQCOMPRADOR FROM MAX_COMPRADOR MC WHERE MC.COMPRADOR = UPPER('&APELIDO_COMPRADOR'))||'%'
                                                     )
                                       -- Ou busca os lotes que possuem categorias que tem as familias vinculadas ao comprador
                                         OR  EXISTS (SELECT 1
                                                       FROM CONSINCO.MAC_GERCOMPRAFILTRO Z
                                                       WHERE Z.SEQGERCOMPRA = A.SEQLOTEMODELO
                                                         AND EXISTS (
                                                             SELECT 1
                                                             FROM MAP_FAMDIVCATEG FC INNER JOIN MAP_FAMDIVISAO FD ON FD.SEQFAMILIA = FC.SEQFAMILIA
                                                             WHERE FD.SEQCOMPRADOR =        (SELECT SEQCOMPRADOR FROM MAX_COMPRADOR MC WHERE MC.COMPRADOR = UPPER('&APELIDO_COMPRADOR'))
                                                               AND Z.CATEGORIASSEL LIKE '%' || FC.SEQCATEGORIA || '%'
                                                               AND(Z.COMPRADORSEL IS NULL 
                                                                OR Z.COMPRADORSEL LIKE '%'||(SELECT SEQCOMPRADOR FROM MAX_COMPRADOR MC WHERE MC.COMPRADOR = UPPER('&APELIDO_COMPRADOR'))||'%')
                                                          )
                                                    
                                             ))
                                             ) XX WHERE XX.SEQGERCOMPRA = G.SEQGERCOMPORIGEM)


-- Lotes por Comprador 

SELECT
  DISTINCT  X.SEQGERCOMPRA, X.DESCRITIVO, X.SITUACAOLOTE
  FROM NAGT_CONTROLEABASTAUTO A INNER JOIN MAC_GERCOMPRA X ON A.SEQLOTEMODELO = X.SEQGERCOMPRA
                                       
                                      WHERE 1=1
                                        AND X.TIPOLOTE != 'C'
                                       -- Busca os lotes que possuem o comprador parametrizado
                                        AND (EXISTS (SELECT 1 FROM CONSINCO.MAC_GERCOMPRAFILTRO Z
                                                             WHERE Z.SEQGERCOMPRA = A.SEQLOTEMODELO
                                                               AND Z.COMPRADORSEL LIKE '%'||(SELECT SEQCOMPRADOR FROM MAX_COMPRADOR MC WHERE MC.COMPRADOR = UPPER('&APELIDO_COMPRADOR'))||'%'
                                                     )
                                       -- Ou busca os lotes que possuem categorias que tem as familias vinculadas ao comprador
                                         OR  EXISTS (SELECT 1
                                                       FROM CONSINCO.MAC_GERCOMPRAFILTRO Z
                                                       WHERE Z.SEQGERCOMPRA = A.SEQLOTEMODELO
                                                         AND EXISTS (
                                                             SELECT 1
                                                             FROM MAP_FAMDIVCATEG FC INNER JOIN MAP_FAMDIVISAO FD ON FD.SEQFAMILIA = FC.SEQFAMILIA
                                                             WHERE FD.SEQCOMPRADOR =        (SELECT SEQCOMPRADOR FROM MAX_COMPRADOR MC WHERE MC.COMPRADOR = UPPER('&APELIDO_COMPRADOR'))
                                                               AND Z.CATEGORIASSEL LIKE '%' || FC.SEQCATEGORIA || '%'
                                                               AND(Z.COMPRADORSEL IS NULL 
                                                                OR Z.COMPRADORSEL LIKE '%'||(SELECT SEQCOMPRADOR FROM MAX_COMPRADOR MC WHERE MC.COMPRADOR = UPPER('&APELIDO_COMPRADOR'))||'%')
                                                          )
                                                    
                                             ))
                                             )
