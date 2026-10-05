---
procedimiento: "Feature 00001 – Motor de reglas MG"
lang: es-CO
---

## 1. INFORMACIÓN DEL PROYECTO

|                          |                                    |
| ------------------------ | ---------------------------------- |
| Área Desarrollo          | Fábrica - Modulo de Gestión        |
| Proyecto                 | Feature 00001 – Motor de reglas MG |

## 2. ARCHIVOS MODIFICADOS

Dentro del proyecto **MODULO_GESTION_V8**:

1. JavaScript/agendamiento/Validacion_TT.js
2. MGW/MGW/Agendamiento/protected/Controller/AgendamientoController.php
3. MGW/MGW/Agendamiento/protected/Controller/TipoTrabajoController.php
4. MGW/MGW/Agendamiento/protected/Controller/ValidacionController.php
5. MGW/MGW/Agendamiento/protected/Controller/ValidacionTipoTrabajoController.php
6. MGW/MGW/Model/TipoProgramacionModel.class.php
7. MGW/MGW/Model/TipoTrabajoModel.class.php

## 3. DETALLE ARCHIVOS MODIFICADOS

El cambio ajusta el motor de reglas de validación de tipos de trabajo:

- En la **parametrización de validaciones**, solo se muestran las validaciones/restricciones configuradas y activas (`ESTADO = 1`) en `MGW_TT_MASTER` / `MGW_TT_MASTERTEST` para el tipo o subtipo de trabajo seleccionado.
- En el **simulador**, el tipo y subtipo de trabajo se toman de los datos de la orden (OT) y no de lo que el usuario selecciona en pantalla.
- Se corrige la unión de validaciones y restricciones por cada tipo/subtipo de trabajo.
- Se agregan parámetros opcionales de filtro por tipo/subtipo en controladores y modelos. Si llegan vacíos o en 0, el comportamiento es el mismo de antes.

### 1. Validacion_TT.js

En el evento clic del botón `#validar_orden`, la primera petición AJAX a `ajax_simulador_tipos_trabajos.php` ahora envía también el parámetro `tipoTrabajo` (valor del select `#tipo_trabajo_padre`), junto con `TBorden`, `Rbot` y `Env`.

**[POR CONFIRMAR: el método `SimuladorTipoTrabajo()` que atiende esta petición no lee el parámetro `tipoTrabajo`; llama a `getDataOrdenSimulador()` sin `$idTtp`, por lo que el valor enviado no se usa. Validar si es el comportamiento esperado.]**

### 2. AgendamientoController.php

- `getDataProcessOrden()`: se agrega el parámetro opcional `$idTtp = 0` (id del tipo de trabajo padre). Se envía a `TipoTrabajoController::getTrabajosByOrdenTrabajo()` al consultar los tipos de trabajo válidos de la orden, para calcular la hora estimada de llegada del técnico.
- `getDataOrdenSimulador()`: se agrega el parámetro opcional `$idTtp = 0` y se pasa a `getDataProcessOrden()`. Retorna en JSON la información de la orden.

### 3. TipoTrabajoController.php

`getTrabajosByOrdenTrabajo()`: se agrega el parámetro opcional `$idTTVal = 0`, que se envía a `ValidacionController::getInfo()` para que las validaciones de la orden se ejecuten solo para ese tipo de trabajo. Si llega en 0, el comportamiento es el mismo de antes.

### 4. ValidacionController.php

- `getInfo()`: se agregan los parámetros opcionales `$idTTVal = 0` (tipo de trabajo) e `$idSubtipoVal = 0` (subtipo de trabajo):
  - `$idTTVal` se envía a `TipoTrabajoModel::findTiposTrabajosHomologo()` para filtrar los tipos de trabajo.
  - `$idSubtipoVal` se envía a `TipoTrabajoModel::findTiposSubTipoTrabajosHomologo()` para filtrar los subtipos.
- **Corrección en la unión de validaciones y restricciones:** antes, las validaciones (`CLASE = 1`) y restricciones (`CLASE = 0`) se consultaban una sola vez y, por la asignación `$validationArray = $validationArray`, las restricciones nunca se agregaban. Ahora, por cada tipo/subtipo de trabajo (`$this->jobs`) se consultan ambas con `findValidationsHomologa()`, se unen en un solo arreglo (`$validationArray = $array`) y se ejecuta `executeValidationForJob()`.
- Se eliminan las variables `$array` e `$i` del inicio de `getInfo()`; ahora se inicializan dentro del ciclo de cada trabajo.

### 5. ValidacionTipoTrabajoController.php

- `get()` (consulta de validaciones parametrizadas): se calcula `$codigoJob`. Si llega `clase_trabajo` se usa ese valor; si no, se usa `tipo_trabajo_padre`. Se envía a `TipoProgramacionModel::findValidationParam()` para que solo retorne las validaciones configuradas para ese tipo/subtipo de trabajo. Retorna en JSON los subtipos, las validaciones agrupadas y los grupos.
- `SimuladorTipoTrabajo()`: se elimina la variable sin uso `$getdataOt`.
- `EjecutarSimulador()`: el tipo y subtipo de trabajo se toman de los datos de la OT (`info_adicional_tipo_trabajo`), no del formulario:
  - `$idTtp` = `id_tipo_trabajo_padre` de la OT.
  - `$idSubtipo` = `id_tipo_trabajo` de la OT.
  - Si la OT no tiene subtipo, se consulta `ValidacionModel::findHpCiudadActivo($idTtp)` para definir si la validación "HP Ciudad" es opcional (antes se usaban `$post['subTipoTrabajo']` y `$post['tipoTrabajo']`).
  - Retorna en JSON el resultado de la validación (`ERROR`, `TIPOTRABAJO`, `SUBTIPOTRABAJO`).

### 6. TipoProgramacionModel.class.php

- `findValidationParam()`: se agrega el parámetro opcional `$codigoTipoSubtipo = null`. Cuando llega con valor, se convierte a entero y la consulta solo trae las validaciones (`MGW_PAR_NIVEL_AGENDA`) asociadas a ese código y activas en las tablas maestras de producción y de pruebas. Retorna `IDPNAG`, `DESCRIPCION` y `CAMPOVAL`.

Filtro agregado a la consulta:

```sql
AND PNA.IDPNAG IN (
    SELECT DISTINCT M.IDPNAG FROM MGW_TT_MASTER M
    WHERE M.CODIGO_TIPO_SUBTIPO = {codigoTipoSubtipo} AND M.ESTADO = 1
    UNION
    SELECT DISTINCT MT.IDPNAG FROM MGW_TT_MASTERTEST MT
    WHERE MT.CODIGO_TIPO_SUBTIPO = {codigoTipoSubtipo} AND MT.ESTADO = 1
)
```

- `findValidationsHomologa()`: se agrega el parámetro opcional `$codigoTipoSubtipo = null`, que aplica el mismo filtro anterior sobre la consulta de validaciones/restricciones. Retorna `IDPNAG`, `IDTP`, `DESCRIPCION`, `DESCRIPCION_PAR`, `CAMPOVAL`, `TIPO` (VALIDACION/RESTRICCION) y `CORDEN`.

**[POR CONFIRMAR: actualmente ningún llamado a `findValidationsHomologa()` envía `$codigoTipoSubtipo`, por lo que este filtro no se está aplicando.]**

### 7. TipoTrabajoModel.class.php

- `findTiposTrabajosHomologo()`: se agrega el parámetro opcional `$idTtp = null`. Si llega con valor, filtra por ese tipo de trabajo padre. Retorna los tipos de trabajo (`ID_TT`, `TRABAJO`).

```sql
SELECT DISTINCT ID_TTP AS ID_TT, NOMBRE AS TRABAJO
  FROM MGW_TIPO_TRABAJO_PADRE
 WHERE ESTADO = 'A'
   AND IDTP = {ttp}
   AND ID_TTP = {idTtp}
```

- `findTiposSubTipoTrabajosHomologo()`: se agrega el parámetro opcional `$idSubtipo = 0`. Si llega con valor, filtra por ese subtipo. Retorna los subtipos de trabajo (`ID_TT`, `TRABAJO`).

```sql
SELECT TTPS.ID_TTS AS ID_TT, TTPS.NOMBRE TRABAJO
  FROM MGW_TIPO_TRABAJO_SUBTIPO TTPS
 WHERE ESTADO = 'A'
   AND TTPS.ID_TT = {id_ttp}
   AND TTPS.ID_TTS = {idSubtipo}
```

En ambos métodos el filtro nuevo solo se aplica cuando el parámetro tiene valor; si no, la consulta es la misma de antes.

## 4. RESULTADOS ESPERADOS

- En la parametrización de validaciones por tipo de trabajo, al seleccionar la programación y el tipo o subtipo de trabajo, solo se listan las validaciones configuradas y activas para ese tipo/subtipo en `MGW_TT_MASTER` / `MGW_TT_MASTERTEST`.
- En el simulador de validación de tipos de trabajo, al ingresar una orden y dar clic en **Validar orden**, la validación de "HP Ciudad" se define con el tipo y subtipo de trabajo de la OT, sin importar lo seleccionado en pantalla.
- Por cada tipo/subtipo se ejecutan tanto las validaciones como las restricciones parametrizadas.
- El resultado muestra el mensaje (`ERROR`), el tipo de trabajo y el subtipo de trabajo, y se habilita el log de la validación.

**[INSERTAR CAPTURA: parametrización con las validaciones filtradas por tipo/subtipo de trabajo]**

**[INSERTAR CAPTURA: simulador con el número de orden ingresado]**

**[INSERTAR CAPTURA: resultado de la validación con tipo y subtipo de trabajo]**

**[INSERTAR CAPTURA: log de la validación]**

## 5. ANOTACIONES Y COMENTARIOS ADICIONALES

Las pruebas se realizaron en el servidor de desarrollo el cual es una réplica de los servidores productivos.

| Ambiente QA        | Valor                | Bases de Datos     | Valor                         |
| :----------------- | :------------------- | :----------------- | :---------------------------- |
| **Servidor**       | http://10.244.143.67 | **Servidor**       | bogexavm1-devqa-scan.claro.co |
| **Puerto**         | 8007                 | **Servicio**       | GESTREP                       |
| **Usuario (s)**    | EUO8237A             | **Usuario (s)**    | GESTIONNEW                    |
| **Contraseña (s)** | 123456               | **Contraseña (s)** | GESTIONNEW123                 |

## 6. REVISIONES Y APROBACIONES

| Fecha      | Versión | Descripción                         | Autor           |
| :--------- | :------ | :---------------------------------- | :-------------- |
| 2026/10/01 | 1.0     | Creación del documento              | Cristian Torres |
| 2026/10/01 | 1.0     | Revisión y aprobación del documento |                 |
| 2026/10/01 | 1.1     | Actualización del documento         | Cristian Torres |
| 2026/10/01 | 1.1     | Revisión y aprobación del documento |                 |
