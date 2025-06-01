-- Географические справочники
CREATE TABLE regions (
    id SERIAL PRIMARY KEY,
    region_name TEXT
);

CREATE TABLE nations (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE
);

CREATE TABLE municipalities (
    id SERIAL PRIMARY KEY,
    name TEXT
);

-- Категории
CREATE TABLE categories_product (
    id SERIAL PRIMARY KEY,
    label TEXT
);

CREATE TABLE categories_pet (
    id SERIAL PRIMARY KEY,
    label TEXT UNIQUE
);

CREATE TABLE types_pet (
    id SERIAL PRIMARY KEY,
    type_name TEXT UNIQUE
);

-- Характеристики товара
CREATE TABLE colors_product (
    id SERIAL PRIMARY KEY,
    color_name TEXT
);

CREATE TABLE brands_product (
    id SERIAL PRIMARY KEY,
    brand TEXT
);

-- Измерения
CREATE TABLE pets_dim (
    id SERIAL PRIMARY KEY,
    pet_category INT REFERENCES categories_pet(id),
    pet_type INT REFERENCES types_pet(id),
    name TEXT,
    breed TEXT
);

CREATE TABLE vendors_dim (
    id SERIAL PRIMARY KEY,
    vendor_name TEXT,
    contact_person TEXT,
    email_address TEXT,
    phone_number TEXT,
    street_address TEXT,
    city_ref INT REFERENCES municipalities(id) ON DELETE CASCADE,
    country_ref INT REFERENCES nations(id) ON DELETE CASCADE
);

CREATE TABLE clients_dim (
    id SERIAL PRIMARY KEY,
    given_name TEXT,
    family_name TEXT,
    years_old INT,
    email TEXT UNIQUE,
    country_ref INT REFERENCES nations(id) ON DELETE CASCADE,
    postal_zone TEXT
);

CREATE TABLE agents_dim (
    id SERIAL PRIMARY KEY,
    given_name TEXT,
    family_name TEXT,
    email TEXT,
    nation_ref INT REFERENCES nations(id) ON DELETE CASCADE,
    zip_code TEXT
);

CREATE TABLE stores_dim (
    id SERIAL PRIMARY KEY,
    store_label TEXT,
    address TEXT,
    municipality_ref INT REFERENCES municipalities(id) ON DELETE CASCADE,
    nation_ref INT REFERENCES nations(id) ON DELETE CASCADE,
    phone TEXT,
    contact_email TEXT,
    region_ref INT REFERENCES regions(id) ON DELETE CASCADE
);

CREATE TABLE items_dim (
    id SERIAL PRIMARY KEY,
    title TEXT,
    product_cat INT REFERENCES categories_product(id) ON DELETE CASCADE,
    unit_price NUMERIC(10,2),
    available_qty INT,
    net_weight NUMERIC(10,2),
    color_ref INT REFERENCES colors_product(id) ON DELETE CASCADE,
    dimension TEXT,
    brand_ref INT REFERENCES brands_product(id) ON DELETE CASCADE,
    material_desc TEXT,
    long_description TEXT,
    average_rating NUMERIC(3,2),
    total_reviews INT,
    release_dt DATE,
    expire_dt DATE
);

-- Факт таблица
CREATE TABLE transactions_fact (
    id SERIAL PRIMARY KEY,
    client_ref INT REFERENCES clients_dim(id) ON DELETE CASCADE,
    agent_ref INT REFERENCES agents_dim(id) ON DELETE CASCADE,
    item_ref INT REFERENCES items_dim(id) ON DELETE CASCADE,
    store_ref INT REFERENCES stores_dim(id) ON DELETE CASCADE,
    vendor_ref INT REFERENCES vendors_dim(id) ON DELETE CASCADE,
    pet_ref INT REFERENCES pets_dim(id) ON DELETE CASCADE,
    transaction_date DATE,
    quantity_sold INT,
    total_value NUMERIC(10,2)
);
