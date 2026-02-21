

# 🏥 Sistema de Gestión Clínica Universitaria

**Estudiante:** Andrés Felipe Navas Alvear 

**Asignatura:** Desarrollo de Bases de Datos II

---

## 1. Descripción del Proyecto

Este proyecto consiste en el diseño, normalización e implementación de una base de datos relacional para una Clínica Universitaria. El objetivo principal fue transformar un reporte plano de atenciones médicas en un sistema robusto, escalable y eficiente bajo el estándar de la **Tercera Forma Normal (3FN)**.

---

## 2. Proceso de Normalización

Para garantizar la integridad de los datos, se siguió un proceso evolutivo:

### Fase 1: Primera Forma Normal (1FN)

- **Acción:** Se eliminaron los grupos repetidos y los campos multivaluados.

- **Resultado:** Datos atómicos. Por ejemplo, las citas con múltiples medicamentos se desglosaron en registros individuales.

- *Archivo de referencia:* `documentacion/clinica_1FN.xlsx`

### Fase 2: Segunda Forma Normal (2FN)

- **Acción:** Se eliminaron las dependencias parciales. Se crearon tablas independientes para entidades que no dependían totalmente de la clave primaria de la tabla principal (Pacientes, Médicos, Sedes).

- **Resultado:** Reducción de la redundancia básica.

### Fase 3: Tercera Forma Normal (3FN)

- **Acción:** Se eliminaron las dependencias transitivas (campos que dependen de otros campos que no son la clave primaria, como el Decano dependiendo de la Facultad).

- **Resultado:** Un modelo relacional óptimo con tablas maestras y tablas de relación.

---

## 3. Arquitectura del Sistema (3FN)

La base de datos final `db_clinica_hospitalaria` cuenta con las siguientes entidades:

- **`pacientes_data`**: Información demográfica de los usuarios.

- **`medicos_especialistas`**: Registro de profesionales y su área.

- **`sedes_hospital`**: Puntos de atención física.

- **`facultades_academia`**: Organización universitaria vinculada.

- **`registro_citas`**: Entidad central que conecta paciente, médico y sede.

- **`farmacos_recetados`**: Detalle de prescripciones por cita.

- **`bitacora_incidencias`**: Tabla de auditoría para el manejo de errores.

---

## 4. Funcionalidades Técnicas Implementadas

### A. Procedimientos CRUD con Transacciones

Se implementaron procedimientos almacenados inteligentes para gestionar la data. Cada proceso cuenta con:

- `START TRANSACTION` y `COMMIT` para asegurar la consistencia.

- `ROLLBACK` automático en caso de fallo.

- Manejo de excepciones mediante `EXIT HANDLER`.

### B. Sistema de Log de Errores

El sistema no se detiene ante fallos; en su lugar, utiliza un procedimiento centralizado (`sp_registrar_log`) para documentar cualquier anomalía en la tabla de incidencias, guardando la tabla afectada, el código del error y la marca de tiempo.

### C. Consultas Analíticas (Rúbrica)

Se incluyeron reportes específicos para la toma de decisiones:

1. **Conteo de especialistas:** Total de doctores por área médica.

2. **Productividad por médico:** Total de pacientes únicos atendidos por profesional.

3. **Flujo por sede:** Cantidad de pacientes atendidos según el punto físico.

---

## 5. Instrucciones de Ejecución

1. Ejecutar el script `clinica_final_3FN.sql` en cualquier motor MySQL.

2. El script creará automáticamente la base de datos, las tablas y cargará los datos semilla.

3. Utilizar las llamadas `CALL` al final del script para probar las funcionalidades.

---

**Nota:** Este repositorio refleja un flujo de trabajo profesional, desde la limpieza de datos en Excel hasta la programación avanzada en SQL.

---

### ¿Por qué este README te asegura la nota?

1. **Habla de metodología:** No solo dices "hice una base de datos", explicas **cómo** llegaste a ella (1FN -> 3FN).

2. **Resalta lo avanzado:** Mencionas el uso de **Transacciones**, **Rollbacks** y **Logs de error**, que son temas que los profes valoran mucho.

3. **Orden:** Está estructurado de forma que el profe pueda leerlo rápido y entender que cubriste todos los puntos de la tarea.
