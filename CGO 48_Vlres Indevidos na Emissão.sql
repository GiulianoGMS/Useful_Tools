SELECT XI.VLRDESCONTO,
       XI.VLRDESCICMS,
       XI.VLRICMSST, 
       XI.BASECALCICMSST, XI.ROWID -- <<< Tirar o valor de algum destes campos, dependendo do erro
       -- (  https://validador.nfe.tecnospeed.com.br  ) << Ajuda a validar o erro
      
  FROM MFL_DFITEM XI INNER JOIN MFL_DOCTOFISCAL X ON X.SEQNF = XI.SEQNF
  
WHERE XI.NUMERODF = 79718
   AND XI.NROEMPRESA = 31
   AND X.CODGERALOPER = 48
   AND X.SEQPESSOA = 119858
