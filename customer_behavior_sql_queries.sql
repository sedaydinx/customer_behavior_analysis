SELECT *
FROM customer
LIMIT 20;

-- Q1: Gesamtumsatz nach Geschlecht
SELECT gender, SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY gender;

-- Q2: Kunden mit Rabatt, die über dem Durchschnitt ausgeben
SELECT customer_id, purchase_amount
FROM customer
WHERE discount_applied = 'Yes'
  AND purchase_amount >= (
      SELECT AVG(purchase_amount)
      FROM customer);

-- Q3: Top 5 Produkte mit höchster durchschnittlicher Bewertung
SELECT item_purchased,
       ROUND(AVG(review_rating::NUMERIC), 2) AS avg_review_rating
FROM customer
GROUP BY item_purchased
ORDER BY AVG(review_rating) DESC
LIMIT 5;

-- Q4: Durchschnittlicher Kaufbetrag nach Versandart
SELECT shipping_type,
       ROUND(AVG(purchase_amount), 2) AS avg_purchase_amount
FROM customer
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type;

-- Q5: Vergleich Ausgaben von Abonnenten vs. Nicht-Abonnenten
SELECT subscription_status,
       COUNT(customer_id) AS total_customers,
       ROUND(AVG(purchase_amount), 2) AS avg_spend,
       ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM customer
GROUP BY subscription_status
ORDER BY total_revenue DESC, avg_spend DESC;

-- Q6: Top 5 Produkte mit höchstem Rabattanteil
SELECT item_purchased,
       ROUND(
           100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
           2
       ) AS discount_rate
FROM customer
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;

-- Q7: Kundensegmente nach Anzahl früherer Käufe
WITH customer_type AS (
    SELECT customer_id,
           CASE
               WHEN previous_purchases = 1 THEN 'New'
               WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
               ELSE 'Loyal'
           END AS customer_segment
    FROM customer
)
SELECT customer_segment,
       COUNT(*) AS customer_count
FROM customer_type
GROUP BY customer_segment;

-- Q8: Top 3 meistgekaufte Produkte pro Kategorie
WITH item_counts AS (
    SELECT category,
           item_purchased,
           COUNT(customer_id) AS total_orders,
           ROW_NUMBER() OVER (
               PARTITION BY category
               ORDER BY COUNT(customer_id) DESC
           ) AS item_rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT item_rank,
       category,
       item_purchased,
       total_orders
FROM item_counts
WHERE item_rank <= 3;

-- Q9: Abonnementstatus von Vielkäufern
SELECT subscription_status,
       COUNT(customer_id) AS repeat_buyers
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;

-- Q10: Umsatz nach Altersgruppe
SELECT age_group,
       SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue DESC;
