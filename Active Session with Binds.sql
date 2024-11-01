SELECT DISTINCT S.SID,
                S.SERIAL#,
                S.USERNAME,
                S.OSUSER,
                S.MACHINE,
                S.PROGRAM,
                SQL.SQL_TEXT,
                B.NAME,
                B.VALUE_STRING AS BIND_VALUE
 FROM V$SESSION S LEFT JOIN V$SQL SQL            ON S.SQL_ID = SQL.SQL_ID
                  LEFT JOIN V$SQL_BIND_CAPTURE B ON SQL.SQL_ID = B.SQL_ID

 WHERE  1=1
 --AND UPPER(SQL.SQL_TEXT) LIKE '%MAPV_APIPRECOPRODUTO%'
 --AND S.OSUSER = 'Consinco_API_SMProdutosAPIPool'
   AND S.STATUS = 'ACTIVE'
 --AND OSUSER != 'giuliano.gomes'

 ORDER BY USERNAME, SID;
