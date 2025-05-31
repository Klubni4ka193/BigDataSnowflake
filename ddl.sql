CREATE SCHEMA IF NOT EXISTS retail_analytics;
SET search_path TO retail_analytics, public;

CREATE TABLE customer_dim (
  id               BIGSERIAL PRIMARY KEY,
  fname            TEXT NOT NULL,
  lname            TEXT NOT NULL,
  customer_age     INTEGER,
  contact_email    TEXT NOT NULL,
  region           TEXT,
  zip_code         TEXT,
  animal_type      TEXT,
  animal_name      TEXT,
  breed            TEXT,
  CONSTRAINT uq_customer_dim_email UNIQUE (contact_email)
);

CREATE TABLE seller_dim (
  id               BIGSERIAL PRIMARY KEY,
  fname            TEXT NOT NULL,
  lname            TEXT NOT NULL,
  email_address    TEXT NOT NULL,
  region           TEXT,
  zip_code         TEXT,
  CONSTRAINT uq_seller_dim_email UNIQUE (email_address)
);

CREATE TABLE store_dim (
  id               BIGSERIAL PRIMARY KEY,
  name             TEXT NOT NULL,
  address          TEXT,
  city_name        TEXT,
  state_name       TEXT,
  country_name     TEXT,
  phone_number     TEXT,
  email_contact    TEXT,
  CONSTRAINT uq_store_dim_name UNIQUE (name)
);

CREATE TABLE supplier_dim (
  id               BIGSERIAL PRIMARY KEY,
  supplier_name    TEXT NOT NULL,
  contact_person   TEXT,
  email_supplier   TEXT,
  phone_contact    TEXT,
  location_address TEXT,
  location_city    TEXT,
  location_country TEXT,
  CONSTRAINT uq_supplier_dim_name UNIQUE (supplier_name)
);

CREATE TABLE product_dim (
  id               BIGSERIAL PRIMARY KEY,
  name             TEXT NOT NULL,
  type_category    TEXT,
  pet_group        TEXT,
  brand_label      TEXT,
  product_desc     TEXT,
  color_variant    TEXT,
  size_spec        TEXT,
  fabric_type      TEXT,
  item_weight      NUMERIC(10,2),
  unit_price       NUMERIC(10,2),
  avg_rating       NUMERIC(3,2),
  review_count     INTEGER,
  available_since  DATE,
  valid_until      DATE,
  CONSTRAINT uq_product_dim_name_brand UNIQUE (name, brand_label)
);

CREATE TABLE calendar_dim (
  id               BIGSERIAL PRIMARY KEY,
  date_value       DATE NOT NULL UNIQUE,
  year_val         SMALLINT NOT NULL,
  quarter_val      SMALLINT NOT NULL,
  month_val        SMALLINT NOT NULL,
  day_val          SMALLINT NOT NULL,
  week_number      SMALLINT NOT NULL,
  weekday_number   SMALLINT NOT NULL,
  is_weekend_day   BOOLEAN NOT NULL
);

CREATE TABLE sales_fact (
  id               BIGSERIAL PRIMARY KEY,
  calendar_id      BIGINT NOT NULL REFERENCES calendar_dim(id),
  customer_ref     BIGINT NOT NULL REFERENCES customer_dim(id),
  seller_ref       BIGINT NOT NULL REFERENCES seller_dim(id),
  product_ref      BIGINT NOT NULL REFERENCES product_dim(id),
  store_ref        BIGINT NOT NULL REFERENCES store_dim(id),
  supplier_ref     BIGINT NOT NULL REFERENCES supplier_dim(id),
  items_sold       INTEGER NOT NULL,
  total_amount     NUMERIC(10,2) NOT NULL
);

CREATE INDEX idx_sales_fact_date     ON sales_fact (calendar_id);
CREATE INDEX idx_sales_fact_customer ON sales_fact (customer_ref);
CREATE INDEX idx_sales_fact_product  ON sales_fact (product_ref);
