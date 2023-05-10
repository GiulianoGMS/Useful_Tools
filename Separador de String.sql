-- Separa String para Coluna por ','

 SELECT DISTINCT TRIM(REGEXP_SUBSTR('ticket, cardeb, ticket, teste', '[^,]+', 1, LEVEL)) AS SEPARA_ESPECIE
   FROM DUAL
CONNECT BY REGEXP_SUBSTR('ticket, cardeb, ticket, teste', '[^,]+', 1, LEVEL) IS NOT NULL
