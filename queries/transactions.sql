-- Транзакции (BEGIN / ROLLBACK), UPDATE, ALTER TABLE с CHECK.
-- задание 3

BEGIN TRANSACTION;
INSERT INTO ingredients (short_description, ingredient_name) VALUES
('Рафинированное масло для жарки', 'Подсолнечное масло');
INSERT INTO dishes_ingredients (dish_id, ingredient_id, quantity, unit_id)
VALUES (2, 13, 20.00, 1);

DELETE FROM dishes_ingredients
WHERE ingredient_id = (
    SELECT ingredient_id FROM ingredients WHERE ingredient_name = 'Подсолнечное масло'
)
AND dish_id IN (
    SELECT di.dish_id
    FROM dishes_ingredients di
    JOIN ingredients i ON di.ingredient_id = i.ingredient_id
    WHERE i.ingredient_name = 'Оливковое масло'
)
RETURNING *;
ROLLBACK;

SELECT i.ingredient_name
FROM dishes d
JOIN dishes_ingredients di ON d.dish_id = di.dish_id
JOIN ingredients i ON di.ingredient_id = i.ingredient_id
WHERE d.dish_name = 'Жареная курица с картофелем';

-- задание 4

BEGIN TRANSACTION;
UPDATE dishes_ingredients 
SET unit_id = (SELECT unit_id FROM units WHERE unit_name = 'чайная ложка')
WHERE dish_id = 3 AND ingredient_id = 10;
UPDATE dishes_ingredients
SET 
    quantity = quantity * 8,
    unit_id = (SELECT unit_id FROM units WHERE unit_name = 'грамм')
WHERE unit_id = (SELECT unit_id FROM units WHERE unit_name = 'чайная ложка');
ROLLBACK;

SELECT d.dish_name, i.ingredient_name, di.quantity, u.unit_name
FROM dishes_ingredients di
JOIN dishes d ON di.dish_id = d.dish_id
JOIN ingredients i ON di.ingredient_id = i.ingredient_id
JOIN units u ON di.unit_id = u.unit_id
WHERE di.dish_id = 3 AND di.ingredient_id = 10;


-- задание 5 
BEGIN TRANSACTION;
ALTER TABLE dishes
ADD COLUMN health_type varchar(64);


-- задание 6 

ALTER TABLE dishes
ADD CONSTRAINT check_health_type
CHECK (health_type IS NULL OR health_type IN (
    'диетическое',
    'вегетарианское',
    'для диабетиков',
    'с низким уровнем холестерина'
));
ROLLBACK;
