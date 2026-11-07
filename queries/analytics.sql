-- Аналитические запросы к БД «Поваренная книга»: JOIN, GROUP BY/HAVING, подзапросы, CTE,
-- оконные функции, STRING_AGG. Запускать после папки setup/ (каждый запрос можно выполнять отдельно).

-- задание 0 

SELECT i.ingredient_name, COUNT(DISTINCT di.dish_id) as count_ing
FROM ingredients i
JOIN dishes_ingredients di ON i.ingredient_id = di.ingredient_id
GROUP BY i.ingredient_id, i.ingredient_name
HAVING COUNT(DISTINCT di.dish_id) = (
    SELECT MAX(cnt) FROM (
        SELECT COUNT(DISTINCT dish_id) AS cnt
        FROM dishes_ingredients
        GROUP BY ingredient_id
    ) counts
);

-- задание 1 

WITH totals AS (
    SELECT d.dish_id,
           d.dish_name,
           SUM(
               CASE
                   WHEN u.is_standard THEN di.quantity
                   ELSE di.quantity * c.standard_quantity
               END
           ) AS total
    FROM dishes d
    JOIN dishes_ingredients di ON d.dish_id = di.dish_id
    JOIN units u ON di.unit_id = u.unit_id
    LEFT JOIN conversions c 
      ON di.ingredient_id = c.ingredient_id 
     AND di.unit_id = c.not_standard_unit_id
    GROUP BY d.dish_id, d.dish_name
)
SELECT dish_name
FROM totals
WHERE total = (SELECT MAX(total) FROM totals);

-- задание 2 

SELECT d.dish_name
FROM dishes d
JOIN dishes_ingredients di ON d.dish_id = di.dish_id
JOIN ingredients i ON di.ingredient_id = i.ingredient_id
GROUP BY d.dish_id, d.dish_name
HAVING COUNT(*) = COUNT(
    CASE 
        WHEN i.ingredient_name IN ('Мука', 'Яйцо', 'Сахар') 
        THEN 1 
    END
);

-- Оконные функции и STRING_AGG

-- Сколько раз ингредиент встречается во всех блюдах и сколько ингредиентов в каждом блюде
SELECT 
    d.dish_name,
    i.ingredient_name,
    COUNT(*) OVER (PARTITION BY i.ingredient_id) AS global_ingredient_count,
    COUNT(*) OVER (PARTITION BY d.dish_id) AS ingredients_in_this_dish
FROM dishes d
JOIN dishes_ingredients di ON d.dish_id = di.dish_id
JOIN ingredients i ON di.ingredient_id = i.ingredient_id
ORDER BY d.dish_name, i.ingredient_name;

-- Список блюд каждой категории в одной строке
SELECT 
    c.category_name,
    STRING_AGG(d.dish_name, ', ' ORDER BY d.dish_name DESC) AS dishes_list
FROM dishcategories c
JOIN dishes d ON d.category_id = c.category_id
GROUP BY c.category_id, c.category_name
ORDER BY c.category_name;
