---
documento: pruebas-unitarias
procedimiento: "Feature {{numero_feature}} – {{titulo_feature}}"
fecha: "{{DD/MM/AAAA}}"
lang: es-CO
---

## INFORMACIÓN DEL PROYECTO

|                       |                                                 |
| --------------------- | ----------------------------------------------- |
| Área Desarrollo:      | Módulo de Gestión                               |
| Autor de las pruebas: | {{autor}}                                       |
| Proyecto:             | Feature {{numero_feature}} – {{titulo_feature}} |

## 1. ALCANCE DE LA PRUEBA

{{Qué se ajustó, explicado en lenguaje sencillo para un usuario sin conocimientos técnicos: qué hacía antes la pantalla o el proceso y qué hace ahora.}}

**Resultado esperado:** {{qué debe ver o poder hacer el usuario una vez aplicado el ajuste.}}

Acceso al módulo:

**{{Menú Claro >> Módulo >> Opción}}**

## 2. CASOS Y ESCENARIOS DE PRUEBA

**DESCRIPCIÓN DE CASOS Y ESCENARIOS DE PRUEBA**

| ID  | ESCENARIO                                         | RESULTADO OBTENIDO                           | OBSERVACIONES                                       |
| --- | ------------------------------------------------- | -------------------------------------------- | --------------------------------------------------- |
| 1   | {{En la pantalla X se realiza la acción Y con Z}} | {{Se realiza Y y se muestra/actualiza Z}}    | {{Servicio, tabla o validación que interviene}}     |

## 3. PANTALLAS Y SOPORTES DE LAS PRUEBAS

### 1. Ingreso a la aplicación

Se ingresa al Módulo de Gestión con el usuario y la contraseña asignados:

![](docs-automation/assets/mg-login.png){width=100%}

Se muestra la página de inicio del Módulo de Gestión:

![](docs-automation/assets/mg-inicio.png){width=100%}

En el menú se selecciona la opción **{{Módulo}}** y en el submenú **{{Opción}}**:

**[INSERTAR CAPTURA: menú {{Módulo}} >> {{Opción}} desplegado]**

### 2. {{Nombre del escenario 1}}

{{Paso a paso en frases cortas: qué se digita, en qué botón se da clic y qué se muestra.}}

**[INSERTAR CAPTURA: {{qué debe mostrar}}]**

{{Siguiente paso.}}

**[INSERTAR CAPTURA: {{resultado del escenario}}]**

## 4. ANOTACIONES Y COMENTARIOS ADICIONALES

{{Comportamientos que el usuario debe conocer, limitaciones o aclaraciones. Si no hay, escribir: "No aplica."}}

## 5. REVISIONES Y APROBACIONES

| Versión | Fecha          | Autor     | Estado | Revisado por | Aprobado por | Descripción modificación |
| ------- | -------------- | --------- | ------ | ------------ | ------------ | ------------------------ |
| 1.0     | {{DD/MM/AAAA}} | {{autor}} |        |              |              | Versión preliminar       |
