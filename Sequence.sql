-- Se a sequencia já existir e quiser redefinir
DROP SEQUENCE S_SEQPROMOCPDV;

-- Criar a sequencia com o valor inicial 5000, exemplo
CREATE SEQUENCE S_SEQPROMOCPDV
  START WITH 5000
  INCREMENT BY 1;

-- Objetos podem ficar invalidos!
