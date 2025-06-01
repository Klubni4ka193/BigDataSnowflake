-- 1. Подсчёт записей с отсутствующим email клиента
SELECT COUNT(*) 
FROM raw_dataset 
WHERE cust_email IS NULL;

-- 2. Частота встречаемости категорий товаров
SELECT item_category, COUNT(*) 
FROM raw_dataset
GROUP BY item_category
ORDER BY COUNT(*) DESC;

-- 3. Частота по странам клиентов
SELECT cust_country, COUNT(*) 
FROM raw_dataset
GROUP BY cust_country
ORDER BY COUNT(*) DESC;

-- 4. Количество продаж по месяцам
SELECT 
  EXTRACT(MONTH FROM tx_date) AS sale_month, 
  COUNT(*) 
FROM raw_dataset
GROUP BY sale_month
ORDER BY sale_month;

-- 5. Средний возраст клиентов
SELECT AVG(cust_age) 
FROM raw_dataset;
