-- =====================================================================
-- Taller de normalización - Universidad
-- =====================================================================
USE universidad;

-- ---------------------------------------------------------------------
-- 1. Reconstruir la vista original (tabla plana) a partir de las tablas
--    normalizadas. Demuestra que no se perdió información.
--    Usamos GROUP_CONCAT para mostrar todos los docentes del curso.
-- ---------------------------------------------------------------------
SELECT
  e.estudiante_id                              AS Estudiante_ID,
  CONCAT(e.nombre, ' ', e.apellido)            AS Nombre_Estudiante,
  c.nombre                                     AS Curso,
  GROUP_CONCAT(DISTINCT CONCAT(d.nombre, ' ', d.apellido)
               ORDER BY d.apellido, d.nombre
               SEPARATOR ', ')                 AS Docentes,
  CONCAT('Aula ', a.codigo)                    AS Aula,
  CONCAT(ds.nombre, ' ',
         HOUR(h.hora_inicio), '-', HOUR(h.hora_fin)) AS Horario
FROM inscripcion i
JOIN estudiante e   ON e.estudiante_id = i.estudiante_id
JOIN curso       c  ON c.curso_id      = i.curso_id
JOIN curso_docente cd ON cd.curso_id   = c.curso_id
JOIN docente     d  ON d.docente_id    = cd.docente_id
JOIN horario     h  ON h.curso_id      = c.curso_id
JOIN aula        a  ON a.aula_id       = h.aula_id
JOIN dia_semana ds  ON ds.dia_id       = h.dia_id
GROUP BY e.estudiante_id, Nombre_Estudiante, c.nombre, Aula, Horario, ds.dia_id
ORDER BY e.estudiante_id;

-- ---------------------------------------------------------------------
-- 2. Número de estudiantes inscritos por curso y por docente.
-- ---------------------------------------------------------------------
SELECT
  c.nombre                                     AS curso,
  GROUP_CONCAT(DISTINCT CONCAT(d.nombre, ' ', d.apellido)
               ORDER BY d.apellido, d.nombre
               SEPARATOR ', ')                AS docentes,
  COUNT(DISTINCT i.estudiante_id)              AS total_estudiantes
FROM curso c
JOIN curso_docente cd ON cd.curso_id = c.curso_id
JOIN docente d        ON d.docente_id = cd.docente_id
LEFT JOIN inscripcion i ON i.curso_id = c.curso_id
GROUP BY c.curso_id, c.nombre
ORDER BY total_estudiantes DESC, curso;

-- ---------------------------------------------------------------------
-- 3. Ocupación de aulas: qué aulas se usan un día dado y en qué
--    franja, y cuáles quedan libres en esa franja.
-- ---------------------------------------------------------------------
SELECT
  a.codigo                                AS aula,
  ds.nombre                               AS dia,
  TIME_FORMAT(h.hora_inicio, '%H:%i')     AS inicio,
  TIME_FORMAT(h.hora_fin,    '%H:%i')     AS fin,
  c.nombre                                AS curso
FROM horario h
JOIN aula a         ON a.aula_id  = h.aula_id
JOIN dia_semana ds  ON ds.dia_id  = h.dia_id
JOIN curso c        ON c.curso_id = h.curso_id
WHERE ds.nombre = 'martes'
ORDER BY h.hora_inicio, a.codigo;

-- Aulas sin ninguna clase asignada el martes entre 10:00 y 12:00
SELECT a.codigo AS aula_libre
FROM aula a
WHERE NOT EXISTS (
  SELECT 1
  FROM horario h
  JOIN dia_semana ds ON ds.dia_id = h.dia_id
  WHERE h.aula_id = a.aula_id
    AND ds.nombre = 'martes'
    AND h.hora_inicio < '12:00:00'
    AND h.hora_fin    > '10:00:00'
);

-- ---------------------------------------------------------------------
-- 4. Detección de choques de horario de un docente (mismo día y
--    franjas que se solapan). Con la tabla plana esto era casi
--    imposible porque el horario era texto libre ("martes 10-12").
--    En 4FN se une curso_docente para saber qué docentes dictan cada curso.
-- ---------------------------------------------------------------------
SELECT
  CONCAT(d.nombre, ' ', d.apellido)       AS docente,
  ds.nombre                               AS dia,
  c1.nombre                               AS curso_1,
  c2.nombre                               AS curso_2,
  TIME_FORMAT(h1.hora_inicio, '%H:%i')    AS inicio_1,
  TIME_FORMAT(h2.hora_inicio, '%H:%i')    AS inicio_2
FROM horario h1
JOIN horario h2     ON h2.horario_id > h1.horario_id
                   AND h2.dia_id     = h1.dia_id
                   AND h2.hora_inicio < h1.hora_fin
                   AND h2.hora_fin    > h1.hora_inicio
JOIN curso c1       ON c1.curso_id = h1.curso_id
JOIN curso c2       ON c2.curso_id = h2.curso_id
                   AND c2.curso_id <> c1.curso_id
JOIN curso_docente cd1 ON cd1.curso_id = c1.curso_id
JOIN curso_docente cd2 ON cd2.curso_id = c2.curso_id
                   AND cd2.docente_id = cd1.docente_id
JOIN docente d      ON d.docente_id = cd1.docente_id
JOIN dia_semana ds  ON ds.dia_id    = h1.dia_id;

-- ---------------------------------------------------------------------
-- 5. Carga académica semanal de cada docente (horas dictadas) y
--    cursos que tiene a cargo. En 4FN los docentes se ligan a cursos
--    a través de curso_docente.
-- ---------------------------------------------------------------------
SELECT
  CONCAT(d.nombre, ' ', d.apellido)                                       AS docente,
  COUNT(DISTINCT c.curso_id)                                              AS cursos,
  GROUP_CONCAT(DISTINCT c.nombre ORDER BY c.nombre SEPARATOR ', ')       AS lista_cursos,
  COALESCE(SUM(TIMESTAMPDIFF(MINUTE, h.hora_inicio, h.hora_fin)) / 60, 0) AS horas_semana
FROM docente d
LEFT JOIN curso_docente cd ON cd.docente_id = d.docente_id
LEFT JOIN curso c          ON c.curso_id    = cd.curso_id
LEFT JOIN horario h        ON h.curso_id    = c.curso_id
GROUP BY d.docente_id, d.nombre, d.apellido
ORDER BY horas_semana DESC, docente;
