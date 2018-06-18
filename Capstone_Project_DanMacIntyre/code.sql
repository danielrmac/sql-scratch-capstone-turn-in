--What columns does the table have?
SELECT *
FROM survey
LIMIT 10;

--are there any garbage Null values?
SELECT *
FROM survey
WHERE response IS NULL OR
   question IS NULL OR
   user_id IS NULL;

--how many unique users entered the funnel
SELECT COUNT(DISTINCT user_id)
FROM survey;

--how many answered each question
SELECT question,
   COUNT(response) as 'answered'
FROM survey
GROUP BY 1;
   
/*Create a quiz funnel using GROUP BY command
add temp table to store # of quiz takers entering funnel for percentage calculation*/
WITH temp AS(
   SELECT MAX(x.total) AS 'max'
   FROM (SELECT question,COUNT(response) AS total
         FROM survey
         GROUP BY question) x)
SELECT question,
   COUNT(response) AS answered,
   (COUNT(response)* 100.0)/temp.max AS percent
FROM survey,temp
GROUP BY question;

--Home Try on Funnel, 3 tables
SELECT *
FROM quiz
LIMIT 5;

SELECT *
FROM home_try_on
LIMIT 5;

SELECT *
FROM purchase
LIMIT 5;

--create new table with all three
SELECT DISTINCT q.user_id,
   h.user_id IS NOT NULL AS 'is_home_try_on',
   h.number_of_pairs,
   p.user_id IS NOT NULL AS 'is_purchase'
FROM quiz q
LEFT JOIN home_try_on h
ON q.user_id = h.user_id
LEFT JOIN purchase p
on q.user_id = p.user_id
LIMIT 10;

--calculate overall conversion rates
WITH funnel AS(
   SELECT DISTINCT q.user_id,
      h.user_id IS NOT NULL AS 'is_home_try_on',
      h.number_of_pairs,
      p.user_id IS NOT NULL AS 'is_purchase'
   FROM quiz q
   LEFT JOIN home_try_on h
      ON q.user_id = h.user_id
   LEFT JOIN purchase p
      ON q.user_id = p.user_id)
SELECT COUNT(*) AS 'Quiz',
   COUNT(CASE
         WHEN is_home_try_on = 1 THEN user_id
         ELSE NULL
         END) AS 'Home Try On',
   COUNT(CASE
        WHEN is_purchase = 1 THEN user_id
        ELSE NULL
        END) AS 'Purchase',
   SUM(is_home_try_on)*1.0/COUNT(user_id) AS 'Quiz to Home',
   SUM(is_purchase)*1.0/SUM(is_home_try_on) AS 'Home to Purchase'
FROM funnel;
         
--looking at 3 vs 5 pairs for home try on 
WITH funnel AS(
   SELECT DISTINCT q.user_id,
      h.user_id IS NOT NULL AS 'is_home_try_on',
      h.number_of_pairs,
      p.user_id IS NOT NULL AS 'is_purchase'
   FROM quiz q
   LEFT JOIN home_try_on h
      ON q.user_id = h.user_id
   LEFT JOIN purchase p
      ON q.user_id = p.user_id)
SELECT number_of_pairs AS "Pairs",
   COUNT(CASE
         WHEN is_home_try_on = 1 THEN user_id
         ELSE NULL
         END) AS 'Home Try On',
   COUNT(CASE
        WHEN is_purchase = 1 THEN user_id
        ELSE NULL
        END) AS 'Purchase',
   ROUND(SUM(is_purchase)*100.0/SUM(is_home_try_on),1) AS 'Conversion %'
FROM funnel
WHERE number_of_pairs IS NOT NULL
GROUP BY 1
ORDER BY 1;
  
 --Most common color results of style quiz
SELECT color as 'Color',
   COUNT(user_id) as 'Quiz Results'
FROM quiz
GROUP BY 1
ORDER BY 2 DESC;

--What is the best selling color
SELECT 
   CASE
      WHEN color LIKE '%Tortoise%' THEN 'Tortoise'
      WHEN color LIKE '%Crystal%' THEN 'Crystal'
      WHEN color LIKE '%Black%' THEN 'Black'
      ELSE color
   END AS 'Color Group',
   COUNT(user_id) AS 'Purchases'
FROM purchase
GROUP BY 1
ORDER BY 2 DESC;

--Which product had highest sales?
SELECT product_id AS 'Product',
   model_name as 'Model',
   color as 'Color',
   price as "Price/ea",
   COUNT(*) as "Qty",
   SUM(price) AS 'Total Sales'
FROM purchase
GROUP BY 1
ORDER BY 6 DESC;