BEGIN
  FOR t IN (SELECT *
  FROM MAP_FAMILIA F WHERE SEQFAMILIA IN (124948,124975,181471,676519,58600,58597,686976,123338,572163)
 
 AND NOT EXISTS(SELECT 1 FROM MAP_FAMDIVCATEG ZZ WHERE ZZ.SEQFAMILIA = F.SEQFAMILIA AND ZZ.SEQCATEGORIA = 46747))   
  LOOP
      INSERT INTO MAP_FAMDIVCATEG V  (SELECT T.SEQFAMILIA,
                                                   VL.SEQCATEGORIA,
                                                   VL.NRODIVISAO,
                                                   'A',
                                                   VL.INDREPLICACAO,
                                                   VL.INDGEROUREPLICACAO,
                                                   VL.DTABASEEXPORTACAO,
                                                   VL.NROBASEEXPORTACAO,
                                                   VL.DATAHORAALTERACAO,
                                                   VL.DATAHORAINTEGRAECOMMERCE,
                                                   'SELOS',
                                                   VL.SEQCORRESPONDENCIA, NULL FROM MAP_FAMDIVCATEG VL WHERE VL.SEQCATEGORIA = 46747 AND VL.SEQFAMILIA = 20407);
     COMMIT;
     END LOOP;
END;
