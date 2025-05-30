ALTER SESSION SET CURRENT_SCHEMA = CONSINCO;

SELECT DISTINCT 'CONSINCO_API' USU_INCLUSAO, F.SEQFAMILIA, SUBSTR( fNomeCompletoCategoria( F.SEQFAMILIA, 1), 0, 240 ) CATEG, FAMILIA, FF.DTAHORALTERACAO
       --Z.SEQFAMILIA, FAMILIA, C.SEQCATEGORIA, CAMINHOCOMPLETO, STATUS, 'Consinco_API' USUINCLUSAO
  FROM MAP_FAMDIVCATEG Z INNER JOIN MAP_CATEGORIA C ON C.SEQCATEGORIA = Z.SEQCATEGORIA
                         INNER JOIN MAP_FAMILIA F ON F.SEQFAMILIA = Z.SEQFAMILIA
                         INNER JOIN (SELECT SEQFAMILIA, MAX(ZZ.DTABASEEXPORTACAO) DTAHORALTERACAO
                                       FROM MAP_FAMDIVCATEG ZZ INNER JOIN MAP_CATEGORIA CC ON CC.SEQCATEGORIA = ZZ.SEQCATEGORIA
                                      WHERE STATUS = 'A'
                                        AND CC.SEQCATEGORIA IN (20003,20004)
                                        AND USUARIOALTERACAO = 'Consinco_API'
                                   GROUP BY SEQFAMILIA) FF ON FF.SEQFAMILIA = F.SEQFAMILIA
      
     WHERE STATUS = 'A'
       AND C.SEQCATEGORIA NOT IN (20003,20004)
--=========================================================================================================================================--

       -- Old

SELECT DISTINCT 'CONSINCO_API' USU_INCLUSAO, F.SEQFAMILIA, SUBSTR( fNomeCompletoCategoria( F.SEQFAMILIA, 1), 0, 240 ) CATEG, FAMILIA   
       --Z.SEQFAMILIA, FAMILIA, C.SEQCATEGORIA, CAMINHOCOMPLETO, STATUS, 'Consinco_API' USUINCLUSAO
  FROM MAP_FAMDIVCATEG Z INNER JOIN MAP_CATEGORIA C ON C.SEQCATEGORIA = Z.SEQCATEGORIA
                         INNER JOIN MAP_FAMILIA F ON F.SEQFAMILIA = Z.SEQFAMILIA
      
     WHERE STATUS = 'A'
       AND C.SEQCATEGORIA NOT IN (20003,20004) 
       AND EXISTS (
        
        SELECT 1
          FROM MAP_FAMDIVCATEG ZZ INNER JOIN MAP_CATEGORIA CC ON CC.SEQCATEGORIA = ZZ.SEQCATEGORIA
              
             WHERE STATUS = 'A'
               AND CC.SEQCATEGORIA IN (20003,20004)
               AND USUARIOALTERACAO = 'Consinco_API'
               AND ZZ.SEQFAMILIA = Z.SEQFAMILIA)
