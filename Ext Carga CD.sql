-- Script para retornar carga para separacao no CD

-- Remova a CargaPalete

DELETE FROM CONSINCO.MLO_CARGAEPALETE CP
 WHERE CP.NROCARGA   = '1747502'
   AND CP.NROEMPRESA = '501';
 COMMIT;

-- Remova a Carga Param Geracao

DELETE FROM CONSINCO.MLO_CARGAEXPPARAMGERACAO A
 WHERE A.NROCARGA   = 1747502
   AND A.NROEMPRESA = 501;
   AND COMMIT;

-- Remova a CargaExped

DELETE FROM CONSINCO.MLO_CARGAEXPED B
 WHERE B.NROCARGA   = 1747502
   AND B.NROEMPRESA = 501;
 COMMIT;
 
-- Carga volta para aplicacao 
-- Geracao de Cargas de Expedicao por Linha de Separacao - Logistica WMS
