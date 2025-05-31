BEGIN;

-- Загрузка покупателей
INSERT INTO customer_dim
(fname, lname, customer_age, contact_email, region, zip_code,
 animal_type, animal_name, breed)
SELECT DISTINCT
  customer_first_name,
  customer_last_name,
  customer_age,
  customer_email,
  customer_country,
  customer_postal_code,
  customer_pet_type,
  customer_pet_name,
  customer_pet_breed
FROM public.mock_data
WHERE customer_email IS NOT NULL
ON CONFLICT (contact_email) DO NOTHING;

-- Загрузка продавцов
INSERT INTO seller_dim
(fname, lname, email_address, region, zip_code)
SELECT DISTINCT
  seller_first_name,
  seller_last_name,
  seller_email,
  seller_country,
  seller_postal_code
FROM public.mock_data
WHERE seller_email IS NOT NULL
ON CONFLICT (email_address) DO NOTHING;

-- Загрузка магазинов
INSERT INTO store_dim
(name, address, city_name, state_name, country_name, phone_number, email_contact)
SELECT DISTINCT
  store_name,
  store_location,
  store_city,
  store_state,
  store_country,
  store_phone,
  store_email
FROM public.mock_data
WHERE store_name IS NOT NULL
ON CONFLICT (name) DO NOTHING;

-- Загрузка поставщиков
INSERT INTO supplier_dim
(supplier_name, contact_person, email_supplier, phone_contact,
 location_address, location_city, location_country)
SELECT DISTINCT
  supplier_name,
  supplier_contact,
  supplier_email,
  supplier_phone,
  supplier_address,
  supplier_city,
  supplier_country
FROM public.mock_data
WHERE supplier_name IS NOT NULL
ON CONFLICT (supplier_name) DO NOTHING;

-- Загрузка товаров
INSERT INTO product_dim
(name, type_category, pet_group, brand_label, product_desc,
 color_variant, size_spec, fabric_type, item_weight, unit_price,
 avg_rating, review_count, available_since, valid_until)
SELECT DISTINCT
  product_name,
  product_category,
  pet_category,
  product_brand,
  product_description,
  product_color,
  product_size,
  product_material,
  product_weight,
  product_price,
  product_rating,
  product_reviews,
  product_release_date,
  product_expiry_date
FROM public.mock_data
WHERE product_name IS NOT NULL
ON CONFLICT (name, brand_label) DO NOTHING;

-- Загрузка календаря
INSERT INTO calendar_dim
(date_value, year_val, quarter_val, month_val, day_val,
 week_number, weekday_number, is_weekend_day)
SELECT DISTINCT
  sale_date,
  EXTRACT(YEAR    FROM sale_date)::SMALLINT,
  EXTRACT(QUARTER FROM sale_date)::SMALLINT,
  EXTRACT(MONTH   FROM sale_date)::SMALLINT,
  EXTRACT(DAY     FROM sale_date)::SMALLINT,
  EXTRACT(WEEK    FROM sale_date)::SMALLINT,
  EXTRACT(DOW     FROM sale_date)::SMALLINT,
  CASE
    WHEN EXTRACT(DOW FROM sale_date) IN (0, 6) THEN TRUE
    ELSE FALSE
  END
FROM public.mock_data
WHERE sale_date IS NOT NULL
ON CONFLICT (date_value) DO NOTHING;

COMMIT;

-- Загрузка фактов продаж
INSERT INTO sales_fact
(calendar_id, customer_ref, seller_ref, product_ref,
 store_ref, supplier_ref, items_sold, total_amount)
SELECT
  dt.id,
  cu.id,
  se.id,
  pr.id,
  st.id,
  su.id,
  md.sale_quantity,
  md.sale_total_price
FROM public.mock_data md
JOIN calendar_dim dt ON dt.date_value = md.sale_date
JOIN customer_dim cu ON cu.contact_email = md.customer_email
JOIN seller_dim   se ON se.email_address = md.seller_email
JOIN product_dim  pr ON pr.name = md.product_name
                      AND (pr.brand_label = md.product_brand OR md.product_brand IS NULL)
JOIN store_dim    st ON st.name = md.store_name
JOIN supplier_dim su ON su.supplier_name = md.supplier_name;
