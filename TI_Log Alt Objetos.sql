SELECT * FROM ge_auditoriaddl X WHERE X.NOMEOBJETO IN (   
SELECT NAME FROM ALL_SOURCE B WHERE TEXT LIKE '%Pedido sem verba em seus produtos%')

ORDER BY 1 DESC
