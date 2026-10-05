---
documento: pruebas-unitarias
procedimiento: "Feature 00001 – Motor de reglas MG"
fecha: "01/10/2026"
lang: es-CO
---

## INFORMACIÓN DEL PROYECTO

|                       |                                    |
| --------------------- | ---------------------------------- |
| Área Desarrollo:      | Módulo de Gestión                  |
| Autor de las pruebas: | Cristian Torres                    |
| Proyecto:             | Feature 00001 – Motor de reglas MG |

## 1. ALCANCE DE LA PRUEBA

El alcance de la prueba es evidenciar el ajuste realizado al motor de reglas en la pantalla **Setup Validaciones TT**, donde se configuran las validaciones y restricciones de cada tipo de trabajo.

Antes, al seleccionar un tipo de trabajo, la pantalla mostraba validaciones que no estaban configuradas para ese tipo de trabajo. Ahora solo se muestran las validaciones y restricciones que están configuradas y activas para el tipo de trabajo seleccionado.

En el **Simulador**, al validar una orden, el sistema toma el tipo y subtipo de trabajo directamente de la orden (no de lo que esté seleccionado en pantalla) y revisa tanto las validaciones como las restricciones que le aplican.

**Resultado esperado:** al seleccionar un tipo de trabajo solo se listan las validaciones o restricciones que le corresponden, y al simular una orden se muestra el resultado de la validación con el tipo y subtipo de trabajo de la orden.

Acceso al módulo:

**Menú Claro >> MGW::Modulo gestion workforce >> Setup agenda >> MGW::Modulo gestion workforce::Setup Validaciones TT**

## 2. CASOS Y ESCENARIOS DE PRUEBA

**DESCRIPCIÓN DE CASOS Y ESCENARIOS DE PRUEBA**

| ID  | ESCENARIO | RESULTADO OBTENIDO | OBSERVACIONES |
| --- | --------- | ------------------ | ------------- |
| 1   | En Setup Validaciones TT se selecciona la Programación, en Acciones la opción VALIDACIONES y un Tipo de Trabajo | Se listan solo las validaciones configuradas y activas para el tipo de trabajo seleccionado | Las validaciones se toman de la configuración de tipos y subtipos de trabajo (producción y pruebas) |
| 2   | En Setup Validaciones TT se selecciona la Programación, en Acciones la opción RESTRICCIONES y un Tipo de Trabajo | Se listan solo las restricciones configuradas y activas para el tipo de trabajo seleccionado | Mismo filtro del escenario 1, aplicado a las restricciones |
| 3   | En la pestaña Simulador se digita el número de una orden de trabajo y se da clic en Validar | Se muestra el resultado de la validación con el tipo y subtipo de trabajo de la orden | El tipo y subtipo se toman de los datos de la orden; se evalúan validaciones y restricciones |
| 4   | En la pestaña Simulador se valida una orden que no tiene subtipo de trabajo | Se realiza la validación usando el tipo de trabajo de la orden, definiendo si aplica la validación de HP Ciudad | Si el tipo de trabajo no tiene HP Ciudad activo, esta validación se toma como opcional |

## 3. PANTALLAS Y SOPORTES DE LAS PRUEBAS

### 1. Ingreso a la aplicación

Se ingresa al Módulo de Gestión con el usuario y la contraseña asignados:

![](docs-automation/assets/mg-login.png){width=100%}

Se muestra la página de inicio del Módulo de Gestión:

![](docs-automation/assets/mg-inicio.png){width=100%}

En el menú se selecciona la opción **MGW::Modulo gestion workforce**, luego **Setup agenda** y en el submenú **MGW::Modulo gestion workforce::Setup Validaciones TT**:

**[INSERTAR CAPTURA: menú MGW::Modulo gestion workforce >> Setup agenda >> Setup Validaciones TT desplegado]**

Se muestra la pantalla **Validación Tipo de Trabajo**:

**[INSERTAR CAPTURA: pantalla Validación Tipo de Trabajo sin datos seleccionados]**

### 2. Consulta de validaciones por tipo de trabajo

Se selecciona la **Programación** (por ejemplo, la de órdenes de trabajo):

**[INSERTAR CAPTURA: lista de Programación con la opción seleccionada]**

En **Acciones** se selecciona la opción **VALIDACIONES**:

**[INSERTAR CAPTURA: lista de Acciones con VALIDACIONES seleccionado]**

Se selecciona el **Tipo de Trabajo** que se desea revisar:

**[INSERTAR CAPTURA: lista de Tipo de Trabajo con la opción seleccionada]**

Se cargan las validaciones en la pestaña **Validaciones**. Solo aparecen las que están configuradas para el tipo de trabajo seleccionado:

**[INSERTAR CAPTURA: pestaña Validaciones con el listado de validaciones del tipo de trabajo]**

### 3. Consulta de restricciones por tipo de trabajo

Con la misma Programación y Tipo de Trabajo, en **Acciones** se selecciona la opción **RESTRICCIONES**:

**[INSERTAR CAPTURA: lista de Acciones con RESTRICCIONES seleccionado]**

Se cargan solo las restricciones configuradas para el tipo de trabajo seleccionado:

**[INSERTAR CAPTURA: pestaña Validaciones con el listado de restricciones del tipo de trabajo]**

### 4. Validación de una orden en el Simulador

Se da clic en la pestaña **Simulador**:

**[INSERTAR CAPTURA: pestaña Simulador con el campo N° Orden de Trabajo]**

Se digita el número de la orden de trabajo en el campo **N° Orden de Trabajo** y se da clic en el botón **Validar**:

**[INSERTAR CAPTURA: número de orden digitado y botón Validar]**

Se muestra el **Resultado** de la validación, junto con el **Tipo Trabajo** y el **SubTipo Trabajo** de la orden:

**[INSERTAR CAPTURA: resultado de la validación con Tipo Trabajo y SubTipo Trabajo]**

Se habilita el log de la validación, donde se pueden revisar las validaciones y restricciones evaluadas:

**[INSERTAR CAPTURA: log de la validación]**

### 5. Validación de una orden sin subtipo de trabajo

En la pestaña **Simulador** se digita el número de una orden que no tenga subtipo de trabajo y se da clic en **Validar**:

**[INSERTAR CAPTURA: número de orden sin subtipo digitado]**

Se muestra el resultado de la validación con el tipo de trabajo de la orden:

**[INSERTAR CAPTURA: resultado de la validación de la orden sin subtipo]**

## 4. ANOTACIONES Y COMENTARIOS ADICIONALES

- En la pestaña Simulador, el tipo y subtipo de trabajo que se evalúan son los de la orden digitada, aunque en la parte superior de la pantalla esté seleccionado otro tipo de trabajo.
- Al seleccionar un **SubTipo de Trabajo** en la parte superior, el listado de validaciones se carga con el proceso existente; este ajuste aplica al seleccionar el **Tipo de Trabajo**.
- **[POR CONFIRMAR: en el código actual, el filtro por tipo y subtipo de trabajo dentro del Simulador no se está aplicando al cálculo de las validaciones (los valores llegan en 0); validar en la prueba si el resultado del escenario 3 muestra solo las reglas del tipo/subtipo de la orden.]**

## 5. REVISIONES Y APROBACIONES

| Versión | Fecha      | Autor           | Estado | Revisado por | Aprobado por | Descripción modificación |
| ------- | ---------- | --------------- | ------ | ------------ | ------------ | ------------------------ |
| 1.0     | 01/10/2026 | Cristian Torres |        |              |              | Versión preliminar       |
