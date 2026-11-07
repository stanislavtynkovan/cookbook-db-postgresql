-- Начальные данные для БД «Поваренная книга» 
INSERT INTO ingredients (ingredient_name, short_description) VALUES
('Мука', 'Пшеничная мука высшего сорта'),
('Яйцо', 'Куриное яйцо категории С0'),
('Сахар', 'Белый свекловичный сахар'),
('Сливочное масло', 'Масло 82.5%, несоленое'),
('Пармезан', 'Твердый итальянский сыр'),
('Куриное филе', 'Грудка без кости'),
('Картофель', 'Молодой картофель'),
('Чеснок', 'Свежий чеснок'),
('Соль', 'Морская соль'),
('Чай', 'Черный листовой чай'),
('Оливковое масло', 'Extra Virgin'),
('Вода', 'Питьевая очищенная');

INSERT INTO units (unit_name, is_standard) VALUES
('грамм', true),
('миллилитр', true),
('штука', true),
('литр', true),
('килограмм', true),
('щепотка', false),
('стакан', false),
('зубчик', false),
('чайная ложка', false),
('столовая ложка', false);

INSERT INTO conversions (ingredient_id, standard_unit_id, not_standard_unit_id, standard_quantity) VALUES
-- стакан
(1, 1, 7, 160.00),
(3, 1, 7, 200.00),
(4, 1, 7, 200.00),
(12, 2, 7, 250.00),

-- щепотка
(9, 1, 6, 2.00),

-- зубчик
(8, 1, 8, 5.00),

-- чайная ложка
(3, 1, 9, 5.00),
(9, 1, 9, 6.00),
(10, 1, 9, 2.00),
(1, 1, 9, 3.00),
(11, 2, 9, 5.00),

-- столовая ложка
(3, 1, 10, 15.00),
(9, 1, 10, 18.00),
(10, 1, 10, 6.00),
(1, 1, 10, 9.00),
(11, 2, 10, 15.00);

INSERT INTO dishcategories (category_name, parent_id, vertical_order, horizontal_order) VALUES
('Супы', NULL, 1, 1),
('Горячие супы', 1, 2, 1),
('Вторые блюда', NULL, 1, 2),
('Гарниры', 3, 2, 1),
('Напитки', NULL, 1, 3),
('Десерты', NULL, 1, 4);

INSERT INTO dishes (category_id, dish_name, total_time, instruction) VALUES
(6, 'Бисквит', interval '1 hour', 'Смешать яйца, сахар и муку. Выпекать'),
(3, 'Жареная курица с картофелем', interval '45 minutes', 'Обжарить курицу и картофель'),
(5, 'Чай черный', interval '5 minutes', 'Заварить чай'),
(1, 'Куриный суп', interval '2 hours', 'Сварить бульон'),
(4, 'Картофельное пюре', interval '30 minutes', 'Размять картофель'),
(4, 'Картофель по-деревенски', interval '40 minutes', 'Запечь в духовке');

INSERT INTO dishes_ingredients (dish_id, ingredient_id, quantity, unit_id) VALUES
(1, 1, 200, 1),
(1, 2, 4, 3),
(1, 3, 150, 1),

(2, 6, 500, 1),
(2, 11, 10, 2),
(2, 7, 600, 1),
(2, 9, 6, 1),

(3, 10, 4, 1),
(3, 12, 250, 2),

(4, 6, 300, 1),
(4, 7, 200, 1),
(4, 8, 10, 1),
(4, 9, 6, 1),
(4, 12, 1500, 2),

(5, 7, 800, 1),
(5, 4, 50, 1),
(5, 9, 6, 1),
(5, 12, 100, 2),

(6, 7, 700, 1),
(6, 8, 15, 1),
(6, 4, 40, 1),
(6, 9, 6, 1);

INSERT INTO techniques (technique_name) VALUES
('Варка'),
('Духовка'),
('Миксер'),
('Чайник'),
('Сковорода'),
('Кастрюля');

INSERT INTO dishes_techniques (dish_id, technique_id) VALUES
(1, 2),
(1, 3),
(2, 5),
(2, 1),
(3, 4),
(4, 6),
(4, 1),
(5, 1),
(6, 2);

INSERT INTO dishphotos (dish_id, photo_path) VALUES
(1, '/images/dishes/biscuit.jpg'),
(2, '/images/dishes/chicken.jpg'),
(3, '/images/dishes/tea.jpg'),
(4, '/images/dishes/soup.jpg'),
(5, '/images/dishes/puree.jpg'),
(6, '/images/dishes/potato.jpg');

INSERT INTO ingredientphotos (ingredient_id, photo_path) VALUES
(1, '/images/ingredients/flour.jpg'),
(2, '/images/ingredients/egg.jpg'),
(3, '/images/ingredients/sugar.jpg'),
(4, '/images/ingredients/butter.jpg'),
(5, '/images/ingredients/parmesan.jpg');

INSERT INTO synonyms (ingredient_id, synonym) VALUES
(1, 'Мука пшеничная'),
(2, 'Куриное яйцо'),
(3, 'Сахар-песок'),
(4, 'Масло сливочное'),
(5, 'Итальянский сыр');


