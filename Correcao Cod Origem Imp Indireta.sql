Ajuste na PKG para correção do codigo origem na operação de Importação Indireta
Objetos criados (estao no git):
-- NAGF_EMPIMPORTADORA
-- NAGF_BUSCATIPDOCTOFGO
-- NAGF_BUSCAUFFORNEC (nao utilizar ja que precisa armazenar ambas importacoes)
Correcao na PKG:
-- PKG_MLF_CONTROLE_TRIGGERS
Linha 3029

IF pRegistro.TIPNOTAFISCAL = 'E' AND (tParametrosDinamicos.CONTROLA_ORIG_PROD_ULT_ENT = 'S' 
          -- Paliativo Giuliano - 10/07/2025
          -- Tratativa Cod Origem Importacao INDIRETA
          OR 1=1 -- NVL(NAGF_BUSCAUFFORNEC(pRegistro.SEQNF), 'XX') != 'EX' -- Se a entrada nao for de fornecedor EX
             AND NAGF_EMPIMPORTADORA(pRegistro.NROEMPRESA) = 'I'  -- Apenas aciona quando é no CD Importador pois nas lojas o PD CONTROLA_ORIG_PROD_ULT_ENT ja esta como "S'
             AND NAGF_BUSCATIPDOCTOFGO(pRegistro.SEQNF) NOT IN ('O','D'))  -- Nao entra na regra quando o CGO esta como Outras entradas/saidas, criado para tratar REMESSA/Entrada Simbolica
                                                                           -- Pois a entrada simbólica não deve alterar a origem para 2
                                                                           -- Nem Devolucoes
       THEN
          SP_GRAVAULTENTRADACODORIGTRIB(pRegistro.SITUACAONF, pRegistro.SEQPESSOA, pRegistro.SEQPRODUTO, pRegistro.NROEMPRESA);
       END IF;
