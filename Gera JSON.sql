DECLARE
  v_file     UTL_FILE.FILE_TYPE;
  v_path     VARCHAR2(100) := 'TI';  -- Diretório Oracle
  v_name     VARCHAR2(100) := 'mensagem.json';
  v_owner    VARCHAR2(100);
  v_obj_name VARCHAR2(100);
  v_obj_type VARCHAR2(100);
  v_created  VARCHAR2(100);
  v_lastddl  VARCHAR2(100);
  v_status   VARCHAR2(100);
  
BEGIN

  SELECT OWNER, OBJECT_NAME, OBJECT_TYPE, CREATED, LAST_DDL_TIME, STATUS
    INTO v_owner, v_obj_name, v_obj_type, v_created, v_lastddl, v_status
    FROM NAGV_INVALID_OBJECTS;

  v_file := UTL_FILE.fopen(v_path, v_name, 'W', 32767);
  
  -- JSON completo, linha por linha
  UTL_FILE.put_line(v_file, '{');
  UTL_FILE.put_line(v_file, '  "@type": "MessageCard",');
  UTL_FILE.put_line(v_file, '  "@context": "https://schema.org/extensions",');
  UTL_FILE.put_line(v_file, '  "summary": "Alerta de teste",');
  UTL_FILE.put_line(v_file, '  "themeColor": "0076D7",');
  UTL_FILE.put_line(v_file, '  "title": "Alerta de Objetos Invalidos",');
  UTL_FILE.put_line(v_file, '  "sections": [');
  UTL_FILE.put_line(v_file, '    {');
  UTL_FILE.put_line(v_file, '      "activityTitle": "Owner: '||v_owner||'",');
  UTL_FILE.put_line(v_file, '      "activitySubtitle": "Data: '||TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI')||'",');
  UTL_FILE.put_line(v_file, '      "activityImage": "https://cdn-icons-png.flaticon.com/512/564/564619.png",');
  UTL_FILE.put_line(v_file, '      "text": "Existem objetos invalidos no banco:",');
  UTL_FILE.put_line(v_file, '      "facts": [');
  UTL_FILE.put_line(v_file, '        {"name": "Object Name:", "value": "'  ||v_obj_name||'"},');
  UTL_FILE.put_line(v_file, '        {"name": "Object Type:", "value": "'  ||v_obj_type||'"},');
  UTL_FILE.put_line(v_file, '        {"name": "Created:", "value": "'      ||v_created||'"},');
  UTL_FILE.put_line(v_file, '        {"name": "Last DDL Time:", "value": "'||v_lastddl||'"},');
  UTL_FILE.put_line(v_file, '        {"name": "Status:", "value": "'       ||v_status||'"}');
  UTL_FILE.put_line(v_file, '      ]');
  UTL_FILE.put_line(v_file, '    }');
  UTL_FILE.put_line(v_file, '  ],');
  UTL_FILE.put_line(v_file, '  "potentialAction": [');
  UTL_FILE.put_line(v_file, '    {');
  UTL_FILE.put_line(v_file, '      "@type": "OpenUri",');
  UTL_FILE.put_line(v_file, '      "name": "Ver detalhes",');
  UTL_FILE.put_line(v_file, '      "targets": [{"os": "default", "uri": "https://nagumo.com.br/"}]');
  UTL_FILE.put_line(v_file, '    }');
  UTL_FILE.put_line(v_file, '  ]');
  UTL_FILE.put_line(v_file, '}');

  UTL_FILE.fclose(v_file);
  DBMS_OUTPUT.put_line('Arquivo JSON gerado com sucesso em ' || v_path || '/' || v_name);
END;
/
