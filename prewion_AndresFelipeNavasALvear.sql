/* ==============================================================
   PROYECTO: GESTIÓN HOSPITALARIA ACADÉMICA
   ESTUDIANTE: Andrés Felipe Navas Alvear
   ============================================================== */

-- Limpieza inicial del esquema
DROP DATABASE IF EXISTS db_clinica_hospitalaria;
CREATE DATABASE db_clinica_hospitalaria;
USE db_clinica_hospitalaria;

-- 1. SISTEMA DE LOGS Y ERRORES
CREATE TABLE bitacora_incidencias (
    id_incidencia INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tabla VARCHAR(60),
    codigo_error INT,
    mensaje_error VARCHAR(255),
    momento DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Procedimiento general para registrar errores (Evita repetir código)
DELIMITER //
CREATE PROCEDURE sp_registrar_log(IN p_tabla VARCHAR(60), IN p_cod INT, IN p_msg VARCHAR(255))
BEGIN
    INSERT INTO bitacora_incidencias(nombre_tabla, codigo_error, mensaje_error)
    VALUES(p_tabla, p_cod, p_msg);
END //
DELIMITER ;

-- 2. DEFINICIÓN DE TABLAS (ESTRUCTURA RELACIONAL)

CREATE TABLE pacientes_data (
    id_paciente VARCHAR(12) PRIMARY KEY,
    nombre_paciente VARCHAR(100) NOT NULL,
    telefono_paciente VARCHAR(25)
);

CREATE TABLE facultades_academia (
    id_facultad VARCHAR(12) PRIMARY KEY,
    nombre_facultad VARCHAR(100) NOT NULL,
    decano_nombre VARCHAR(100)
);

CREATE TABLE sedes_hospital (
    id_sede VARCHAR(12) PRIMARY KEY,
    nombre_sede VARCHAR(100) NOT NULL,
    direccion_sede VARCHAR(150)
);

CREATE TABLE medicos_especialistas (
    id_medico VARCHAR(12) PRIMARY KEY,
    nombre_medico VARCHAR(100) NOT NULL,
    area_especialidad VARCHAR(100)
);

CREATE TABLE registro_citas (
    id_cita VARCHAR(12) PRIMARY KEY,
    fecha_cita DATE NOT NULL,
    diagnostico_txt VARCHAR(200),
    fk_paciente VARCHAR(12),
    fk_medico VARCHAR(12),
    fk_sede VARCHAR(12),
    CONSTRAINT fk_c_paciente FOREIGN KEY (fk_paciente) REFERENCES pacientes_data(id_paciente),
    CONSTRAINT fk_c_medico FOREIGN KEY (fk_medico) REFERENCES medicos_especialistas(id_medico),
    CONSTRAINT fk_c_sede FOREIGN KEY (fk_sede) REFERENCES sedes_hospital(id_sede)
);

CREATE TABLE farmacos_recetados (
    ref_cita VARCHAR(12),
    medicamento_nom VARCHAR(100),
    dosis_prescrita VARCHAR(50),
    PRIMARY KEY (ref_cita, medicamento_nom),
    FOREIGN KEY (ref_cita) REFERENCES registro_citas(id_cita) ON DELETE CASCADE
);

CREATE TABLE relacion_medico_facultad (
    ref_medico VARCHAR(12),
    ref_facultad VARCHAR(12),
    PRIMARY KEY (ref_medico, ref_facultad),
    FOREIGN KEY (ref_medico) REFERENCES medicos_especialistas(id_medico),
    FOREIGN KEY (ref_facultad) REFERENCES facultades_academia(id_facultad)
);

-- 3. CARGA DE DATOS INICIALES
INSERT INTO pacientes_data VALUES ('P-501', 'Juan Rivas', '600-111'), ('P-502', 'Ana Soto', '600-222'), ('P-503', 'Luis Paz', '600-333');
INSERT INTO facultades_academia VALUES ('F01', 'Medicina', 'Dr. Wilson'), ('F02', 'Ciencias', 'Dr. Palmer');
INSERT INTO sedes_hospital VALUES ('S01', 'Centro Médico', 'Calle 5 #10'), ('S02', 'Clínica Norte', 'Av. Libertador');
INSERT INTO medicos_especialistas VALUES ('M-10', 'Dr. House', 'Infectología'), ('M-22', 'Dra. Grey', 'Cardiología'), ('M-30', 'Dr. Strange', 'Neurocirugía');
INSERT INTO registro_citas VALUES ('C-001', '2024-05-10', 'Gripe Fuerte', 'P-501', 'M-10', 'S01'), ('C-002', '2024-05-11', 'Infección', 'P-502', 'M-10', 'S01'), ('C-003', '2024-05-12', 'Arritmia', 'P-501', 'M-22', 'S02');

-- 4. PROCEDIMIENTOS CRUD COMPLETOS (TODAS LAS ENTIDADES)

DELIMITER //

-- CRUD PACIENTES
CREATE PROCEDURE sp_pacientes_ops(IN op INT, IN p_id VARCHAR(12), IN p_nom VARCHAR(100), IN p_tel VARCHAR(25))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_registrar_log('pacientes_data', 1, 'Error en operación de pacientes');
        ROLLBACK;
    END;
    START TRANSACTION;
    IF op = 1 THEN INSERT INTO pacientes_data VALUES(p_id, p_nom, p_tel);
    ELSEIF op = 2 THEN UPDATE pacientes_data SET nombre_paciente=p_nom, telefono_paciente=p_tel WHERE id_paciente=p_id;
    ELSEIF op = 3 THEN DELETE FROM pacientes_data WHERE id_paciente=p_id;
    END IF;
    COMMIT;
END //

-- CRUD MÉDICOS
CREATE PROCEDURE sp_medicos_ops(IN op INT, IN p_id VARCHAR(12), IN p_nom VARCHAR(100), IN p_esp VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_registrar_log('medicos_especialistas', 2, 'Error en operación de médicos');
        ROLLBACK;
    END;
    START TRANSACTION;
    IF op = 1 THEN INSERT INTO medicos_especialistas VALUES(p_id, p_nom, p_esp);
    ELSEIF op = 2 THEN UPDATE medicos_especialistas SET nombre_medico=p_nom, area_especialidad=p_esp WHERE id_medico=p_id;
    ELSEIF op = 3 THEN DELETE FROM medicos_especialistas WHERE id_medico=p_id;
    END IF;
    COMMIT;
END //

-- CRUD SEDES
CREATE PROCEDURE sp_sedes_ops(IN op INT, IN p_id VARCHAR(12), IN p_nom VARCHAR(100), IN p_dir VARCHAR(150))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CALL sp_registrar_log('sedes_hospital', 3, 'Error en operación de sedes');
        ROLLBACK;
    END;
    START TRANSACTION;
    IF op = 1 THEN INSERT INTO sedes_hospital VALUES(p_id, p_nom, p_dir);
    ELSEIF op = 2 THEN UPDATE sedes_hospital SET nombre_sede=p_nom, direccion_sede=p_dir WHERE id_sede=p_id;
    ELSEIF op = 3 THEN DELETE FROM sedes_hospital WHERE id_sede=p_id;
    END IF;
    COMMIT;
END //

DELIMITER ;

-- 5. FUNCIONES REQUERIDAS POR LA RÚBRICA (REPORTES)

DELIMITER //

-- A. Número de doctores dada una especialidad
CREATE PROCEDURE sp_conteo_especialistas(IN p_especialidad VARCHAR(100))
BEGIN
    SELECT COUNT(*) AS total_doctores 
    FROM medicos_especialistas 
    WHERE area_especialidad = p_especialidad;
END //

-- B. Total pacientes atendidos por un médico
CREATE PROCEDURE sp_total_atenciones_medico(IN p_med_id VARCHAR(12))
BEGIN
    SELECT COUNT(DISTINCT fk_paciente) AS total_pacientes
    FROM registro_citas
    WHERE fk_medico = p_med_id;
END //

-- C. Cantidad de pacientes atendidos dada una sede
CREATE PROCEDURE sp_total_pacientes_sede(IN p_sede_id VARCHAR(12))
BEGIN
    SELECT COUNT(DISTINCT fk_paciente) AS total_pacientes
    FROM registro_citas
    WHERE fk_sede = p_sede_id;
END //

DELIMITER ;

-- 6. PRUEBAS DE FUNCIONAMIENTO
CALL sp_pacientes_ops(1, 'P-900', 'Andrés Navas', '555-999'); 
CALL sp_conteo_especialistas('Cardiología');
CALL sp_total_atenciones_medico('M-10');
CALL sp_total_pacientes_sede('S01');