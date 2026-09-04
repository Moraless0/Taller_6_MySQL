-- =====================================================================
-- Taller de normalización - Universidad
-- =====================================================================

CREATE DATABASE IF NOT EXISTS universidad
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE universidad;

-- ---------------------------------------------------------------------
-- Entidades independientes
-- ---------------------------------------------------------------------
CREATE TABLE estudiante (
  estudiante_id INT          NOT NULL AUTO_INCREMENT,
  nombre        VARCHAR(50)  NOT NULL,
  apellido      VARCHAR(50)  NOT NULL,
  PRIMARY KEY (estudiante_id)
);

CREATE TABLE docente (
  docente_id INT         NOT NULL AUTO_INCREMENT,
  nombre     VARCHAR(50) NOT NULL,
  apellido   VARCHAR(50) NOT NULL,
  PRIMARY KEY (docente_id),
  UNIQUE KEY uq_docente_nombre (nombre, apellido)
);

CREATE TABLE aula (
  aula_id INT         NOT NULL AUTO_INCREMENT,
  codigo  VARCHAR(10) NOT NULL,          -- '101', '102', ...
  PRIMARY KEY (aula_id),
  UNIQUE KEY uq_aula_codigo (codigo)
);

CREATE TABLE dia_semana (
  dia_id  TINYINT     NOT NULL,          -- 1 = lunes ... 7 = domingo
  nombre  VARCHAR(10) NOT NULL,
  PRIMARY KEY (dia_id),
  UNIQUE KEY uq_dia_nombre (nombre)
);

-- ---------------------------------------------------------------------
-- Curso: atributos propios de la asignatura
-- ---------------------------------------------------------------------
CREATE TABLE curso (
  curso_id   INT         NOT NULL AUTO_INCREMENT,
  nombre     VARCHAR(80) NOT NULL,
  PRIMARY KEY (curso_id),
  UNIQUE KEY uq_curso_nombre (nombre)
);

-- ---------------------------------------------------------------------
-- Docentes que dictan cada curso (N:M, necesaria para 4FN)
-- Un curso puede tener varios docentes y un docente puede dictar varios cursos.
-- También permite varios horarios independientes de los docentes.
-- ---------------------------------------------------------------------
CREATE TABLE curso_docente (
  curso_id    INT NOT NULL,
  docente_id  INT NOT NULL,
  PRIMARY KEY (curso_id, docente_id),
  CONSTRAINT fk_cd_curso
    FOREIGN KEY (curso_id) REFERENCES curso (curso_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_cd_docente
    FOREIGN KEY (docente_id) REFERENCES docente (docente_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

-- ---------------------------------------------------------------------
-- Horario: bloque (día, hora inicio, hora fin) de un curso en un aula
-- ---------------------------------------------------------------------
CREATE TABLE horario (
  horario_id  INT     NOT NULL AUTO_INCREMENT,
  curso_id    INT     NOT NULL,
  aula_id     INT     NOT NULL,
  dia_id      TINYINT NOT NULL,
  hora_inicio TIME    NOT NULL,
  hora_fin    TIME    NOT NULL,
  PRIMARY KEY (horario_id),
  -- un aula no puede tener dos cursos a la misma hora del mismo día
  UNIQUE KEY uq_aula_dia_hora (aula_id, dia_id, hora_inicio),
  CONSTRAINT chk_horario_rango CHECK (hora_fin > hora_inicio),
  CONSTRAINT fk_horario_curso
    FOREIGN KEY (curso_id) REFERENCES curso (curso_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_horario_aula
    FOREIGN KEY (aula_id) REFERENCES aula (aula_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_horario_dia
    FOREIGN KEY (dia_id) REFERENCES dia_semana (dia_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ---------------------------------------------------------------------
-- Inscripción: relación N:M entre estudiante y curso
-- ---------------------------------------------------------------------
CREATE TABLE inscripcion (
  estudiante_id INT  NOT NULL,
  curso_id      INT  NOT NULL,
  fecha         DATE NOT NULL DEFAULT (CURRENT_DATE),
  PRIMARY KEY (estudiante_id, curso_id),
  CONSTRAINT fk_insc_estudiante
    FOREIGN KEY (estudiante_id) REFERENCES estudiante (estudiante_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_insc_curso
    FOREIGN KEY (curso_id) REFERENCES curso (curso_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

