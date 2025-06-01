-- Заполнение справочных таблиц

INSERT INTO regions(region_name)
SELECT DISTINCT store_state FROM mock_data;

INSERT INTO categories_product(label)
SELECT DISTINCT product_category FROM mock_data;

INSERT INTO categories_pet(label)
SELECT DISTINCT pet_category FROM mock_data;

INSERT INTO types_pet(type_name)
SELECT DISTINCT customer_pet_type FROM mock_data;

INSERT INTO municipalities(name)
SELECT DISTINCT store_city FROM mock_data
UNION
SELECT DISTINCT supplier_city FROM mock_data;

INSERT INTO nations(name)
SELECT DISTINCT customer_country FROM mock_data
UNION
SELECT DISTINCT seller_country FROM mock_data
UNION
SELECT DISTINCT store_country FROM mock_data
UNION
SELECT DISTINCT supplier_country FROM mock_data;

INSERT INTO colors_product(color_name)
SELECT DISTINCT product_color FROM mock_data;

INSERT INTO brands_product(brand)
SELECT DISTINCT product_brand FROM mock_data;

-- Измерения

INSERT INTO pets_dim(pet_category, pet_type, name, breed)
SELECT DISTINCT 
    pc.id, 
    pt.id, 
    md.customer_pet_name, 
    md.customer_pet_breed
FROM mock_data md
JOIN categories_pet pc ON md.pet_category = pc.label
JOIN types_pet pt ON md.customer_pet_type = pt.type_name;

INSERT INTO vendors_dim(vendor_name, contact_person, email_address, phone_number, street_address, city_ref, country_ref)
SELECT DISTINCT 
    md.supplier_name, 
    md.supplier_contact, 
    md.supplier_email, 
    md.supplier_phone, 
    md.supplier_address, 
    ct.id, 
    cn.id
FROM mock_data md
JOIN municipalities ct ON md.supplier_city = ct.name
JOIN nations cn ON md.supplier_country = cn.name;

INSERT INTO clients_dim(given_name, family_name, years_old, email, country_ref, postal_zone)
SELECT DISTINCT 
    md.customer_first_name, 
    md.customer_last_name, 
    md.customer_age, 
    md.customer_email, 
    cn.id, 
    md.customer_postal_code
FROM mock_data md
JOIN nations cn ON md.customer_country = cn.name;

INSERT INTO agents_dim(given_name, family_name, email, nation_ref, zip_code)
SELECT DISTINCT 
    md.seller_first_name, 
    md.seller_last_name, 
    md.seller_email, 
    cn.id, 
    md.seller_postal_code
FROM mock_data md
JOIN nations cn ON md.seller_country = cn.name;

INSERT INTO stores_dim(store_label, address, municipality_ref, region_ref, nation_ref, phone, contact_email)
SELECT DISTINCT 
    md.store_name, 
    md.store_location, 
    m.id, 
    r.id, 
    n.id, 
    md.store_phone, 
    md.store_email
FROM mock_data md
JOIN municipalities m ON md.store_city = m.name
JOIN regions r ON md.store_state = r.region_name
JOIN nations n ON md.store_country = n.name;

INSERT INTO items_dim(
    title, product_cat, unit_price, available_qty, net_weight,
    color_ref, dimension, brand_ref, material_desc, long_description,
    average_rating, total_reviews, release_dt, expire_dt
)
SELECT DISTINCT
    md.product_name,
    cp.id,
    md.product_price,
    md.product_quantity,
    md.product_weight,
    clr.id,
    md.product_size,
    br.id,
    md.product_material,
    md.product_description,
    md.product_rating,
    md.product_reviews,
    md.product_release_date,
    md.product_expiry_date
FROM mock_data md
JOIN categories_product cp ON md.product_category = cp.label
JOIN colors_product clr ON md.product_color = clr.color_name
JOIN brands_product br ON md.product_brand = br.brand;

-- Факт таблица

INSERT INTO transactions_fact (
    client_ref, agent_ref, item_ref, store_ref, vendor_ref,
    pet_ref, transaction_date, quantity_sold, total_value
)
SELECT
    cl.id,
    ag.id,
    it.id,
    st.id,
    vd.id,
    pt.id,
    md.sale_date,
    md.sale_quantity,
    md.sale_total_price
FROM mock_data md
JOIN clients_dim cl ON cl.email = md.customer_email
JOIN agents_dim ag ON ag.email = md.seller_email
JOIN items_dim it ON it.title = md.product_name AND it.release_dt = md.product_release_date
JOIN stores_dim st ON st.store_label = md.store_name AND st.contact_email = md.store_email
JOIN vendors_dim vd ON vd.email_address = md.supplier_email
LEFT JOIN pets_dim pt ON pt.name = md.customer_pet_name AND pt.breed = md.customer_pet_breed;
