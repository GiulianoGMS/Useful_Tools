SELECT DISTINCT SEQAUXNOTAFISCAL, NUMERONF, NROEMPRESA EMP, DECODE(OPERACAO, 'INS','Inclusão','DEL','Exclusão') OPERACAO, USUALTERACAO, DTHRALTERACAO, 
       CASE WHEN NVL(APPORIGEM,0) = 9 THEN 'Automatica' ELSE 'Manual' END TIPO_IMP
 FROM MLF_AUXNOTAFISCAL_LOG 
WHERE SEQAUXNOTAFISCAL = 5033239 
  AND OPERACAO != 'UPD'
 ORDER BY DTHRALTERACAO DESC
