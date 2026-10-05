---
procedimiento: "Feature {{numero_feature}} – {{titulo_feature}}"
lang: es-CO
---

## 1. INFORMACIÓN DEL PROYECTO

|                          |                                                |
| ------------------------ | ---------------------------------------------- |
| Área Desarrollo          | Fábrica - Modulo de Gestión                    |
| Proyecto                 | Feature {{numero_feature}} – {{titulo_feature}} |

## 2. ARCHIVOS NUEVOS

Dentro del proyecto **{{nombre_proyecto}}**:

1. {{ruta\Archivo_nuevo1}}
2. {{ruta\Archivo_nuevo2}}

## 3. DETALLE ARCHIVOS NUEVOS

### 1. {{Archivo_nuevo1}}

Descripción detallada del archivo: métodos nuevos (nombre, funcionalidad y qué retorna). Si consulta constantes, tablas o servicios, incluir la consulta de BD:

```sql
SELECT * FROM GESTIONNEW.MGW_CONSTANTES WHERE NOMBRE = '{{NOMBRE_CONSTANTE}}'
```

## 4. ARCHIVOS MODIFICADOS

Dentro del proyecto **{{nombre_proyecto}}**:

1. {{ruta\Archivo_modificado1}}
2. {{ruta\Archivo_modificado2}}

## 5. DETALLE ARCHIVOS MODIFICADOS

### 1. {{Archivo_modificado1}}

Descripción detallada de la modificación: métodos nuevos o modificados (nombre, funcionalidad y qué retorna). Si consulta constantes, tablas o servicios, incluir la consulta de BD:

```sql
SELECT * FROM GESTIONNEW.MGW_CONSTANTES WHERE NOMBRE = '{{NOMBRE_CONSTANTE}}'
```

## 6. RESULTADOS ESPERADOS

Descripción de lo que el usuario o el sistema debe ver una vez desplegado el cambio.

**[INSERTAR CAPTURA: {{descripción de la pantalla}}]**

## 7. ANOTACIONES Y COMENTARIOS ADICIONALES

Las pruebas se realizaron en el servidor de desarrollo el cual es una réplica de los servidores productivos.

| Ambiente QA        | Valor                | Bases de Datos     | Valor                         |
| :----------------- | :------------------- | :----------------- | :---------------------------- |
| **Servidor**       | http://10.244.143.67 | **Servidor**       | bogexavm1-devqa-scan.claro.co |
| **Puerto**         | 8007                 | **Servicio**       | GESTREP                       |
| **Usuario (s)**    | EUO8237A             | **Usuario (s)**    | GESTIONNEW                    |
| **Contraseña (s)** | 123456               | **Contraseña (s)** | GESTIONNEW123                 |

## 8. REVISIONES Y APROBACIONES

| Fecha        | Versión | Descripción                         | Autor       |
| :----------- | :------ | :---------------------------------- | :---------- |
| {{AAAA/MM/DD}} | 1.0     | Creación del documento              | {{autor}}   |
| {{AAAA/MM/DD}} | 1.0     | Revisión y aprobación del documento |             |
