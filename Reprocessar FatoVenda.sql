BEGIN
  CONSINCO.PKG_ETL_GERENCIAL.sp_FatoVenda(psNroEmpresa  => 14,
                                          pdDtaInicial  => DATE '2024-10-19',
                                          pdDtaFinal    => DATE '2024-10-25',
                                          psAtualizaDia => 'S',
                                          psAtualizaMes => 'N');
  END;
