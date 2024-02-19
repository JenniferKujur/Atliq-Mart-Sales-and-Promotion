
-- Q1) List of products with base price greater than 500 and Promo_type is "BOGOF".

SELECT fe.product_code, base_price, dp.product_name FROM fact_events fe
INNER JOIN dim_products dp ON fe.product_code=dp.product_code 
WHERE base_price > 500 and promo_type='BOGOF'
GROUP BY fe.product_code, base_price;
   
-- Q2) No. of stores in each city in descending order.

SELECT city, COUNT(DISTINCT(store_id)) as Count_Stores From dim_stores
GROUP BY city
Order by Count_Stores DESC;

-- Q3) Calcualte the total revenue before and after promotion by campaign name.

SELECT 
    dc.campaign_name,
    SUM(fe.base_price * fe.quantity_sold(before_promo)) AS total_revenue_before_promotion,
    SUM((CASE 
        WHEN promo_type LIKE '50% OFF' THEN (base_price * (100 - 50) / 100)
        WHEN promo_type LIKE '25% OFF' THEN (base_price * (100 - 25) / 100)
        WHEN promo_type LIKE 'BOGOF' THEN (base_price/2)
        WHEN promo_type LIKE '500 Cashback' THEN (base_price-500)
	    WHEN promo_type LIKE '33% OFF' THEN (base_price* (100-33)/100)
        ELSE fe.base_price 
    END)* quantity_sold(after_promo)) AS total_revenue_after_promotion
FROM 
    fact_events fe
JOIN 
    dim_campaigns dc ON fe.campaign_id = dc.campaign_id
GROUP BY 
    dc.campaign_name;
    
-- Q4) Incremental Sold Units % for each category during Diwali Campaign along with Ranking.
    
SELECT 
p.category,
   ROUND(((SUM(f.quantity_sold(after_promo)) - SUM(f.quantity_sold(before_promo))) / SUM(f.quantity_sold(before_promo))) * 100,2) AS ISU_percentage,
    RANK() OVER (ORDER BY ((SUM(f.quantity_sold(after_promo)) - SUM(f.quantity_sold(before_promo))) / SUM(f.quantity_sold(before_bromo))) DESC) AS rank_order
FROM 
    fact_events f
JOIN 
    dim_products p ON f.product_code = p.product_code
WHERE 
    f.campaign_id = 'CAMP_DIW_01'
GROUP BY 
    p.category
ORDER BY 
    ISU_percentage DESC;
    
-- Q5) Top 5 products ranked by Incremental Revenue %.

SELECT p.product_name,p.category,
   round((Sum((CASE 
        WHEN promo_type LIKE '50% OFF' THEN (base_price * (100 - 50) / 100)
        WHEN promo_type LIKE '25% OFF' THEN (base_price * (100 - 25) / 100)
        WHEN promo_type LIKE 'BOGOF' THEN (base_price/2)
        WHEN promo_type LIKE '500 Cashback' THEN (base_price-500)
	    WHEN promo_type LIKE '33% OFF' THEN (base_price* (100-33)/100)
        ELSE base_price
    END) *(quantity_sold(after_promo)))- sum(base_price * (quantity_sold(before_promo))))/sum(base_price *quantity_sold(before_promo)) * 100,2) AS IR_percentage
FROM 
    fact_events f 
 JOIN dim_products p ON p.product_code=f.product_code
GROUP BY campaign_id,f.product_code
ORDER BY 
IR_percentage DESC
LIMIT 5;

 ---- End----