-- Aplicacao de Gerenciador de Precos lenta ao alterar preco base
-- Problema no INSERT que a aplicacao faz, no subselect do select:

"... (SELECT MAX(BB.PRECOBASENORMAL)
            FROM MAP_PRODUTO AA, MRL_PRODEMPSEG BB, MAD_FAMSEGMENTO CC
           WHERE AA.SEQPRODUTO = BB.SEQPRODUTO
                 AND AA.SEQFAMILIA = CC.SEQFAMILIA
                 AND AA.SEQPRODUTO = MAP_PRODUTO.SEQPRODUTO
                 AND AA.SEQFAMILIA = MAP_PRODUTO.SEQFAMILIA
                 AND BB.QTDEMBALAGEM = MRL_PRODEMPSEG.QTDEMBALAGEM
                 AND BB.NROEMPRESA = MRL_PRODEMPSEG.NROEMPRESA
                 AND BB.NROSEGMENTO = MRL_PRODEMPSEG.NROSEGMENTO
                 AND CC.NROSEGMENTO = MRL_PRODEMPSEG.NROSEGMENTO),..."
  
-- Ao executar o insert pelo PLSQL, notei que aplicando um HINT no select faz funcionar sem lentidão. (/*+ OPTIMIZER_FEATURES_ENABLE(''11.2.0.4'') */)
-- Tentativa 1.: Criar PATCHS para aplicar o HINT por trás
  
  -- Descobre SLQ_ID
SELECT sql_id, sql_text 
FROM v$sql 
WHERE UPPER(sql_text) LIKE '%MAD_PRODLOGPRECO%' AND UPPER(sql_text) LIKE '%PRECOBASENORMAL%';

-- Cria o PATCH, com conteudo ou sql_id
DECLARE
  v_patch_name VARCHAR2(100);
BEGIN
  v_patch_name := DBMS_SQLDIAG.CREATE_SQL_PATCH(
    --sql_id    => 'seu_sql_id_aqui', -- OU
    sql_text    => '
(SELECT max( bb.PRECOBASENORMAL)
 from map_produto aa,
 mrl_prodempseg bb,
 mad_famsegmento cc
 where aa.seqproduto = bb.seqproduto
 and aa.seqfamilia = cc.SEQFAMILIA
 and aa.seqproduto = map_produto.seqproduto
 and aa.seqfamilia = map_produto.seqfamilia
 and bb.qtdembalagem = mrl_prodempseg.qtdembalagem
 and bb.nroempresa = Mrl_Prodempseg.Nroempresa
 and bb.nrosegmento = Mrl_Prodempseg.Nrosegmento
 and cc.NROSEGMENTO = Mrl_Prodempseg.Nrosegmento),', 
    hint_text   => '/*+ OPTIMIZER_FEATURES_ENABLE(''11.2.0.4'') */',
    name        => 'PATCH_NAG_GIULIANO'
  );
END;

-- Dropar o PATCH, se for preciso
BEGIN
  DBMS_SQLDIAG.DROP_SQL_PATCH(name => 'PATCH_NAG_GIULIANO');
END;

-- Problema: O SQL_ID ou o SLQ_TEXT pode mudar, então o PATCH não sera aplicado se não conter o mesmo VSQL do SQL_ID.

-- Tentativa 2.: Aplicar o OPTIMIZER direto na sessão do usuário no processo que está sendo realizado.
  -- Procurar uma Procedure que é executada antes da chamada do insert
  -- No caso, encontrei a SP_MRL_VALIDAPRECOMONITORADO
  -- Dentro dela, adicionei:

  -- 30/05/25 - Giuliano
  -- Esse otimizador ira alterar o otimizador da sessao no gerenciador de precos para melhorar a performance
  vSQL := 'ALTER SESSION SET OPTIMIZER_FEATURES_ENABLE = ''11.2.0.4''';
  EXECUTE IMMEDIATE vSQL;

-- Ao executar o processo novamente, a aplicação chamou o objeto alterado e alterou diretamente a sessao, aplicando o optimizer, funcionando sem lentidao :)
