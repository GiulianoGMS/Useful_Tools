DELETE FROM ADMCIPOLLA.BKP_BASE49 WHERE 1=1;

COMMIT;
-- Replace para retirar caracteres inválidos (Espaços)
INSERT INTO ADMCIPOLLA.BKP_BASE49 (SEQPRODUTO) VALUES (REGEXP_REPLACE('CODPRODUTO', '[^0-9]', ''));

COMMIT;

SELECT COUNT(1) FROM ADMCIPOLLA.BKP_BASE49;
