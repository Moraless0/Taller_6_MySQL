-- =====================================================================
-- Taller de normalización - Universidad
-- =====================================================================
USE universidad;

-- Días de la semana
INSERT INTO dia_semana (dia_id, nombre) VALUES
  (1, 'lunes'), (2, 'martes'), (3, 'miércoles'), (4, 'jueves'),
  (5, 'viernes'), (6, 'sábado'), (7, 'domingo');

-- Estudiantes
INSERT INTO estudiante (estudiante_id, nombre, apellido) VALUES
  (1, 'Juan',     'Pérez'),
  (2, 'María',    'Gómez'),
  (3, 'Luis',     'Ramírez'),
  (4, 'Ana',      'Morales'),
  (5, 'Laura',    'Rodríguez'),
  (6, 'Daniel',   'Hernández'),
  (7, 'Carolina', 'Sánchez'),
  (8, 'Mario',    'López');

-- Docentes
INSERT INTO docente (docente_id, nombre, apellido) VALUES
  (1, 'Carlos', 'Gómez'),
  (2, 'María',  'Martínez'),
  (3, 'José',   'Rodríguez');

-- Aulas
INSERT INTO aula (aula_id, codigo) VALUES
  (1, '101'),
  (2, '102'),
  (3, '103');

-- Cursos
INSERT INTO curso (curso_id, nombre) VALUES
  (1, 'Algoritmos'),
  (2, 'Redes'),
  (3, 'Bases de Datos');

-- Relación N:M curso-docente (4FN: permite varios docentes por curso y viceversa)
INSERT INTO curso_docente (curso_id, docente_id) VALUES
  (1, 1),  -- Algoritmos     <-> Carlos Gómez
  (2, 2),  -- Redes          <-> María Martínez
  (3, 3);  -- Bases de Datos <-> José Rodríguez

-- Horarios 
INSERT INTO horario (horario_id, curso_id, aula_id, dia_id, hora_inicio, hora_fin) VALUES
  (1, 1, 1, 2, '10:00:00', '12:00:00'),  -- Algoritmos, Aula 101, martes 10-12
  (2, 2, 2, 2, '14:00:00', '16:00:00'),  -- Redes, Aula 102, martes 14-16
  (3, 3, 3, 2, '08:00:00', '10:00:00');  -- Bases de Datos, Aula 103, martes 8-10

-- Inscripciones (estudiante -> curso)
INSERT INTO inscripcion (estudiante_id, curso_id, fecha) VALUES
  (1, 1, '2025-02-03'),  -- Juan Pérez         -> Algoritmos
  (2, 1, '2025-02-03'),  -- María Gómez        -> Algoritmos
  (3, 2, '2025-02-03'),  -- Luis Ramírez       -> Redes
  (4, 2, '2025-02-03'),  -- Ana Morales        -> Redes
  (5, 3, '2025-02-03'),  -- Laura Rodríguez    -> Bases de Datos
  (6, 1, '2025-02-03'),  -- Daniel Hernández   -> Algoritmos
  (7, 2, '2025-02-03'),  -- Carolina Sánchez   -> Redes
  (8, 3, '2025-02-03');  -- Mario López        -> Bases de Datos
