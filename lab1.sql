-- Лабораторная работа №1. Создание таблиц
-- Иванова Соня, группа 25ИС2-1, вариант 11
-- СУБД: PostgreSQL
-- Создайте в pgAdmin базу university_v11 (один раз), откройте Query Tool.
-- Например, из базы postgres отдельно можно выполнить:
-- CREATE DATABASE university_v11;
-- Затем подключитесь к university_v11 и выполните данный файл один раз.

BEGIN; -- Начинаем транзакцию: изменения сохранятся после COMMIT.

CREATE SCHEMA IF NOT EXISTS sonya_v11; -- Отдельная схема для работы.
SET search_path TO sonya_v11, public; -- Указываем, где искать таблицы.

-- Вариант 11 требует таблицы преподавателей и групп.
-- Факультеты и кафедры — дополнительные справочники для запросов ЛР №2.
-- Курс добавлен в группы, так как он нужен в первом запросе ЛР №2.

CREATE TABLE faculties (
    faculty_id SERIAL PRIMARY KEY, -- Уникальный код, создаётся автоматически.
    faculty_name VARCHAR(100) NOT NULL UNIQUE -- Название факультета.
);

CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY, -- Уникальный номер кафедры.
    department_name VARCHAR(100) NOT NULL UNIQUE, -- Название кафедры.
    faculty_id INTEGER NOT NULL REFERENCES faculties(faculty_id)
        ON UPDATE CASCADE ON DELETE RESTRICT -- Кафедра относится к факультету.
);

CREATE TABLE teachers (
    teacher_id SERIAL PRIMARY KEY, -- Код преподавателя с автоинкрементом.
    last_name VARCHAR(50) NOT NULL, -- Фамилия.
    first_name VARCHAR(50) NOT NULL, -- Имя.
    patronymic VARCHAR(50), -- Отчество может отсутствовать (NULL).
    education VARCHAR(50) NOT NULL CHECK (education IN
        ('Высшее', 'Среднее профессиональное')), -- Допустимые виды образования.
    experience INTEGER NOT NULL CHECK (experience >= 0), -- Стаж в полных годах.
    department_id INTEGER NOT NULL REFERENCES departments(department_id)
        ON UPDATE CASCADE ON DELETE RESTRICT, -- Номер существующей кафедры.
    phone VARCHAR(20) -- Телефон хранится как строка, чтобы сохранить знак +.
);

CREATE TABLE student_groups (
    group_number VARCHAR(20) PRIMARY KEY, -- Номер группы, например М-101.
    max_students INTEGER NOT NULL CHECK (max_students > 0), -- Вместимость группы.
    faculty_id INTEGER NOT NULL REFERENCES faculties(faculty_id)
        ON UPDATE CASCADE ON DELETE RESTRICT, -- Код факультета.
    curator_id INTEGER, -- NULL означает, что куратор не назначен.
    course INTEGER NOT NULL CHECK (course BETWEEN 1 AND 6), -- Номер курса.
    CONSTRAINT fk_groups_curator FOREIGN KEY (curator_id)
        REFERENCES teachers(teacher_id)
        ON UPDATE CASCADE -- Изменение кода преподавателя изменит ссылку в группе.
        ON DELETE SET NULL -- При удалении преподавателя группа останется без куратора.
);

-- INSERT INTO добавляет строки. Коды SERIAL не указываем:
-- в новой схеме они автоматически получат значения от 1 до 10.
-- Все записи ниже — учебные тестовые данные.
INSERT INTO faculties (faculty_name) VALUES
    ('Математический факультет'),
    ('Физический факультет'),
    ('Факультет информационных технологий'),
    ('Экономический факультет'),
    ('Гуманитарный факультет'),
    ('Химический факультет'),
    ('Биологический факультет'),
    ('Юридический факультет'),
    ('Инженерный факультет'),
    ('Факультет иностранных языков');

INSERT INTO departments (department_name, faculty_id) VALUES
    ('Высшая математика', 1),
    ('Прикладная математика', 1),
    ('Теоретическая физика', 2),
    ('Информатика', 3),
    ('Экономика', 4),
    ('История', 5),
    ('Химия', 6),
    ('Биология', 7),
    ('Право', 8),
    ('Иностранные языки', 10);

-- Каждая строка содержит ФИО, образование, стаж, кафедру и телефон.
INSERT INTO teachers
    (last_name, first_name, patronymic, education, experience, department_id, phone)
VALUES
    ('Иванов', 'Алексей', 'Петрович', 'Высшее', 5, 1, '+7-000-000-00-01'),
    ('Петрова', 'Мария', 'Ивановна', 'Высшее', 12, 2, '+7-000-000-00-02'),
    ('Смирнов', 'Дмитрий', 'Олегович', 'Высшее', 8, 1, '+7-000-000-00-03'),
    ('Кузнецова', 'Анна', 'Сергеевна', 'Высшее', 15, 3, '+7-000-000-00-04'),
    ('Орлова', 'Елена', 'Викторовна', 'Среднее профессиональное', 4, 4, '+7-000-000-00-05'),
    ('Соколов', 'Игорь', 'Андреевич', 'Высшее', 9, 4, '+7-000-000-00-06'),
    ('Васильева', 'Ольга', 'Павловна', 'Высшее', 20, 5, '+7-000-000-00-07'),
    ('Морозов', 'Павел', 'Романович', 'Среднее профессиональное', 3, 6, '+7-000-000-00-08'),
    ('Волкова', 'Наталья', 'Юрьевна', 'Высшее', 11, 7, NULL),
    ('Громов', 'Сергей', 'Ильич', 'Высшее', 6, 8, '+7-000-000-00-10');

-- Есть группы с куратором и без него, в том числе на 1 курсе матфака.
INSERT INTO student_groups
    (group_number, max_students, faculty_id, curator_id, course)
VALUES
    ('М-101', 25, 1, NULL, 1),
    ('М-102', 30, 1, 1, 1),
    ('М-103', 24, 1, NULL, 1),
    ('М-201', 28, 1, 2, 2),
    ('Ф-101', 25, 2, 4, 1),
    ('ИТ-101', 30, 3, 5, 1),
    ('ИТ-201', 26, 3, 6, 2),
    ('Э-101', 22, 4, 7, 1),
    ('Г-301', 20, 5, NULL, 3),
    ('М-202', 25, 1, 1, 2);

COMMIT; -- Сохраняем создание таблиц и учебные данные.

-- Проверка: в каждой таблице должно быть 10 строк.
SELECT 'Факультеты' AS table_name, COUNT(*) AS row_count FROM faculties
UNION ALL SELECT 'Кафедры', COUNT(*) FROM departments
UNION ALL SELECT 'Преподаватели', COUNT(*) FROM teachers
UNION ALL SELECT 'Группы', COUNT(*) FROM student_groups;

-- Проверка работы внешнего ключа и каскадного обновления.
-- Временные изменения отменяем, чтобы сохранить исходные данные.
BEGIN;
UPDATE teachers SET teacher_id = 1001 WHERE teacher_id = 1;
SELECT * FROM student_groups WHERE curator_id = 1001; -- Две группы с новым кодом.
DELETE FROM teachers WHERE teacher_id = 1001;
SELECT * FROM student_groups WHERE group_number IN ('М-102', 'М-202');
-- После DELETE куратор этих групп станет NULL, а группы не удалятся.
ROLLBACK; -- Отменяем проверочные изменения.

-- Итог: показываем исходные группы и ФИО их кураторов.
SELECT g.*, t.last_name, t.first_name, t.patronymic
FROM student_groups AS g
LEFT JOIN teachers AS t ON g.curator_id = t.teacher_id
ORDER BY g.group_number;
