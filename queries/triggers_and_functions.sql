-- Триггеры и функции на PL/pgSQL, агрегатная функция, представление с INSTEAD OF.

--задание 0
DROP TRIGGER IF EXISTS check_dish_number_trigger ON dishes;
DROP TRIGGER IF EXISTS check_ingredient_number_trigger ON dishes_ingredients;
BEGIN;
ROLLBACK;
CREATE OR REPLACE FUNCTION check_dish_number()
RETURNS TRIGGER AS $$
DECLARE
    dish_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO dish_count
    FROM dishes
    WHERE category_id = NEW.category_id;
    IF dish_count >= 50 THEN
        RAISE EXCEPTION 'В категорию нельзя добавить более 50 блюд.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_dish_number_trigger
BEFORE INSERT ON dishes
FOR EACH ROW
EXECUTE FUNCTION check_dish_number();

CREATE OR REPLACE FUNCTION check_ingredient_number()
RETURNS TRIGGER AS $$
DECLARE
    ingredient_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO ingredient_count
    FROM dishes_ingredients
    WHERE dish_id = NEW.dish_id;
    IF ingredient_count >= 50 THEN
        RAISE EXCEPTION 'В блюдо нельзя добавить более 50 ингредиентов.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_ingredient_number_trigger
BEFORE INSERT ON dishes_ingredients
FOR EACH ROW
EXECUTE FUNCTION check_ingredient_number();
SELECT COUNT(*) FROM dishes WHERE category_id = 6;
DO $$
BEGIN
    FOR i IN 1..(50 - (SELECT COUNT(*) FROM dishes WHERE category_id = 6)) LOOP
        INSERT INTO dishes (category_id, dish_name, total_time, instruction)
        VALUES (6, 'Тест блюдо ' || i, interval '30 minutes', 'Тест');
    END LOOP;
END $$;

INSERT INTO dishes (category_id, dish_name, total_time, instruction)
VALUES (6, 'Тестовый десерт', interval '30 minutes', 'Тестовая инструкция');

-- Очистка тестовых блюд после проверки лимита
DELETE FROM dishes WHERE dish_name LIKE 'Тест блюдо %' OR dish_name = 'Тестовый десерт';

--задание 1

CREATE OR REPLACE FUNCTION count_dishes_by_substring(substr TEXT)
RETURNS INTEGER AS $$
DECLARE
    dish_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO dish_count
    FROM dishes
    WHERE dish_name ILIKE '%' || substr || '%';    
    RETURN dish_count;
END;
$$ LANGUAGE plpgsql;

SELECT count_dishes_by_substring('Карт');

--задание 2

CREATE OR REPLACE FUNCTION aggregate_ingredients_state(state TEXT[], current_dish_id INTEGER)
RETURNS TEXT[] AS $$
DECLARE
    new_ingredients TEXT[];
BEGIN
    SELECT ARRAY_AGG(DISTINCT i.ingredient_name ORDER BY i.ingredient_name)
    INTO new_ingredients
    FROM dishes_ingredients di
    JOIN ingredients i ON di.ingredient_id = i.ingredient_id
    WHERE di.dish_id = current_dish_id;    
    RETURN state || new_ingredients;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION aggregate_ingredients_final(state TEXT[])
RETURNS TEXT AS $$
BEGIN
    RETURN (
        SELECT STRING_AGG(DISTINCT ingredient_name, ', ' ORDER BY ingredient_name)
        FROM UNNEST(state) AS ingredient_name
    );
END;
$$ LANGUAGE plpgsql;

CREATE AGGREGATE aggregate_ingredients(INTEGER) (
    INITCOND = '{}',
    SFUNC = aggregate_ingredients_state,
    STYPE = TEXT[],
    FINALFUNC = aggregate_ingredients_final);

SELECT aggregate_ingredients(dish_id) FROM dishes;

 ----задание 3
 
CREATE OR REPLACE VIEW dishes_with_ingredients AS
SELECT 
    d.dish_id,
    d.dish_name,
    d.instruction,
    STRING_AGG(DISTINCT i.ingredient_name, ', ') AS ingredients
FROM dishes d
JOIN dishes_ingredients di ON d.dish_id = di.dish_id
JOIN ingredients i ON di.ingredient_id = i.ingredient_id
GROUP BY d.dish_id, d.dish_name, d.instruction;

CREATE OR REPLACE FUNCTION update_instruction_trigger()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE dishes
    SET instruction = NEW.instruction
    WHERE dish_id = OLD.dish_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_instruction_trigger
INSTEAD OF UPDATE ON dishes_with_ingredients
FOR EACH ROW
EXECUTE FUNCTION update_instruction_trigger();

UPDATE dishes_with_ingredients
SET instruction = 'Новая инструкция: взбить яйца с сахаром, добавить муку. Выпекать 35 минут при 180°C.'
WHERE dish_id = 1;

SELECT * FROM dishes WHERE dish_id = 1;

------задание 4------------

BEGIN;
CREATE OR REPLACE FUNCTION init_set()
RETURNS VOID AS $$
BEGIN
    DROP TABLE IF EXISTS string_set CASCADE;
    CREATE TABLE string_set (
        value VARCHAR(64) PRIMARY KEY
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_to_set(elem VARCHAR(64))
RETURNS VARCHAR(64) AS $$
DECLARE
    inserted VARCHAR(64);
BEGIN
    INSERT INTO string_set (value)
    VALUES (elem)
    ON CONFLICT (value) DO NOTHING
    RETURNING value INTO inserted;
    RETURN inserted;   
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_from_set(elem VARCHAR(64))
RETURNS VARCHAR(64) AS $$
DECLARE
    deleted VARCHAR(64);
BEGIN
    DELETE FROM string_set
    WHERE value = elem
    RETURNING value INTO deleted;
    RETURN deleted;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION empty_set()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO deleted_count FROM string_set;
    TRUNCATE TABLE string_set;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

SELECT init_set();
SELECT add_to_set('яблоко');   
SELECT add_to_set('груша');    
SELECT add_to_set('банан');    
SELECT add_to_set('яблоко');   
SELECT * FROM string_set;
SELECT delete_from_set('груша');   
SELECT delete_from_set('груша');
SELECT * FROM string_set;
SELECT empty_set();
SELECT * FROM string_set;
ROLLBACK;

-- Шейкерная сортировка 

CREATE OR REPLACE FUNCTION shaker_sort(arr INTEGER[])
RETURNS INTEGER[] AS $$
DECLARE
    swapped BOOLEAN;
    start_idx INTEGER;
    end_idx INTEGER;
    i INTEGER;
    temp INTEGER;
    sorted_arr INTEGER[];
BEGIN
    sorted_arr := arr;
    start_idx := 1;
    end_idx := array_length(sorted_arr, 1);
    swapped := TRUE;
    WHILE swapped LOOP
        swapped := FALSE;
        -- Проход слева направо 
        FOR i IN start_idx..end_idx-1 LOOP
            IF sorted_arr[i] > sorted_arr[i+1] THEN
                temp := sorted_arr[i];
                sorted_arr[i] := sorted_arr[i+1];
                sorted_arr[i+1] := temp;
                swapped := TRUE;
            END IF;
        END LOOP;
        IF NOT swapped THEN
            EXIT;
        END IF;
        swapped := FALSE;
        end_idx := end_idx - 1;
        -- Проход справа налево 
        FOR i IN REVERSE end_idx..start_idx+1 LOOP
            IF sorted_arr[i] < sorted_arr[i-1] THEN
                temp := sorted_arr[i];
                sorted_arr[i] := sorted_arr[i-1];
                sorted_arr[i-1] := temp;
                swapped := TRUE;
            END IF;
        END LOOP;
        start_idx := start_idx + 1;
    END LOOP;
    RETURN sorted_arr;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM shaker_sort(ARRAY[64, 34, 25, 12, 12, -11, -90, 5]);