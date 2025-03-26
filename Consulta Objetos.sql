-- Fiz CTE pra nao ter que ficar passando o texto 2x em cada select :)
WITH cteText AS (SELECT UPPER(TRIM(
                'INSERT INTO MAC_GERCOMPRAITEM' -- <<<< Texto a ser buscado nos objetos
                )) TEXTO 
                   FROM DUAL)

SELECT /*+OPTIMIZER_FEATURES_ENABLE('11.2.0.4')*/
       OWNER, 'VIEW' OBJECT_TYPE, VIEW_NAME NAME, TEXT_VC
  FROM ALL_VIEWS  AV LEFT JOIN cteText ON 1=1
 WHERE UPPER(TEXT_VC) LIKE '%'||cteText.TEXTO||'%' 
    -- o OR abaixo deixa a consulta demorada, só tira se for precisar realmente buscar no CLOB
    -- Transforma a col TEXT LONG para CLOB pra poder buscar a string
    -- OR NAGF_GETLONG_GLN('ALL_VIEWS', 'TEXT', AV.VIEW_NAME) LIKE '%'||cteText.TEXTO||'%' 
 
UNION

SELECT OWNER, TYPE, NAME, TEXT     
  FROM ALL_SOURCE AC LEFT JOIN cteText ON 2=2
 WHERE UPPER(TEXT) LIKE '%'||cteText.TEXTO||'%';

-- Versao antiga

-- SELECT NAME, Text FROM ALL_SOURCE B WHERE UPPER(TEXT) LIKE '%TEXTO_DO_OBJETO%'
