-- Схема БД «Электронная поваренная книга» 

CREATE TABLE IF NOT EXISTS dishcategories(
    category_id serial PRIMARY KEY,
    category_name character varying(64) NOT NULL UNIQUE CHECK (LENGTH(category_name) > 0),
    parent_id integer,
    vertical_order integer,
    horizontal_order integer,
    FOREIGN KEY (parent_id) REFERENCES dishcategories(category_id)
);

CREATE TABLE IF NOT EXISTS dishes(
    dish_id serial PRIMARY KEY,
    category_id integer NOT NULL,
    dish_name character varying(64) NOT NULL CHECK (LENGTH(dish_name) > 0),
    total_time interval NOT NULL CHECK (total_time > interval '0 seconds'),
    instruction text NOT NULL CHECK (LENGTH(instruction) > 0),
    UNIQUE (dish_name, category_id),
    FOREIGN KEY (category_id) REFERENCES dishcategories(category_id)
);

CREATE TABLE IF NOT EXISTS ingredients(
    ingredient_id serial PRIMARY KEY,
    ingredient_name character varying(64) NOT NULL UNIQUE CHECK (LENGTH(ingredient_name) > 0),
    short_description text NOT NULL CHECK (LENGTH(short_description) > 0)
);

CREATE TABLE IF NOT EXISTS units(
    unit_id serial PRIMARY KEY,
    unit_name character varying(32) NOT NULL UNIQUE CHECK (LENGTH(unit_name) > 0),
    is_standard boolean NOT NULL
);

CREATE TABLE IF NOT EXISTS conversions(
    conversion_id serial PRIMARY KEY,
    ingredient_id integer NOT NULL,
    standard_unit_id integer NOT NULL,
    not_standard_unit_id integer NOT NULL,
    standard_quantity numeric(6, 2) NOT NULL CHECK (standard_quantity > 0),
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id),
    FOREIGN KEY (not_standard_unit_id) REFERENCES units(unit_id),
    FOREIGN KEY (standard_unit_id) REFERENCES units(unit_id),
    CONSTRAINT unique_conversion UNIQUE (ingredient_id, standard_unit_id, not_standard_unit_id)
);

CREATE TABLE IF NOT EXISTS dishes_ingredients(
    id serial PRIMARY KEY,
    dish_id integer NOT NULL,
    ingredient_id integer NOT NULL,
    quantity numeric(6, 2) NOT NULL CHECK (quantity > 0),
    unit_id integer NOT NULL,
    UNIQUE (dish_id, ingredient_id),
    FOREIGN KEY (dish_id) REFERENCES dishes(dish_id),
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id),
    FOREIGN KEY (unit_id) REFERENCES units(unit_id)
);

CREATE TABLE IF NOT EXISTS techniques(
    technique_id serial PRIMARY KEY,
    technique_name character varying(64) NOT NULL UNIQUE CHECK (LENGTH(technique_name) > 0)
);

CREATE TABLE IF NOT EXISTS dishes_techniques(
    technique_id integer NOT NULL,
    dish_id integer NOT NULL,
    PRIMARY KEY (technique_id, dish_id),
    FOREIGN KEY (dish_id) REFERENCES dishes(dish_id),
    FOREIGN KEY (technique_id) REFERENCES techniques(technique_id)
);

CREATE TABLE IF NOT EXISTS dishphotos(
    photo_id serial PRIMARY KEY,
    dish_id integer NOT NULL,
    photo_path character varying(64) NOT NULL CHECK (LENGTH(photo_path) > 0),
    FOREIGN KEY (dish_id) REFERENCES dishes(dish_id)
);

CREATE TABLE IF NOT EXISTS ingredientphotos(
    photo_id serial PRIMARY KEY,
    ingredient_id integer NOT NULL,
    photo_path character varying(64) NOT NULL CHECK (LENGTH(photo_path) > 0),
    UNIQUE (ingredient_id, photo_path),
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id)
);

CREATE TABLE IF NOT EXISTS synonyms(
    synonym_id serial PRIMARY KEY,
    ingredient_id integer NOT NULL,
    synonym character varying(64) NOT NULL CHECK (LENGTH(synonym) > 0),
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id),
    UNIQUE (ingredient_id, synonym)
);
