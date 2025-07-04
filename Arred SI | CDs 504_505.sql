-- Altera a forma de arredondamento da SI quando a quantidade é menor nas empresas 504 e 505
-- Inicialmente, precisa alterar apenas na trigger abaixo

tai_wm_mad_cargarecprod
Linha 94
         -- Giuliano 04/07/2025
         -- CDs 504 e 505 arredondam qtd expedir cortada na x
         CASE WHEN PEDEXP.NROEMPRESA IN (504,505) THEN ROUND(X.QTDEEXPEDIR)
            ELSE X.QTDEEXPEDIR END,
         ITEMEXP.TMPQTDEEXPEDIR)), 0) QUANTIDADE,
--
-- Talvez:
PKG_MLF_RECEBIMENTO.SP_CALCSELINVERSA
Linha 14848
        (D.PESAVEL = 'N' or vtItem.NROEMPRESA IN (504,505)))
Linha 14188
        (vsPesavelSIN = 'N' 
        -- Giuliano 04/07/2025
        -- CDs 504/505 consideram qtd faltante no rateio como quantidade fechada e nao cracionada pela variavel vsPesavelSIN
        OR vtItem.NROEMPRESA IN (504,505))

--
