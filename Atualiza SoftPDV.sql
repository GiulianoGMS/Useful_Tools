UPDATE CONSINCO.MRL_EMPSOFTPDV B SET NOMEVIEW = 'mrlv_etiq_nagumo_varejo_vm4'
 WHERE 1=1
   AND SOFTPDV LIKE '%ETQGONDNORMAL_MN%';
   
   COMMIT;