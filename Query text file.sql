
/*Query 1-query used for first insight*/

SELECT   NAME,
         Count(r.rental_id) AS rental_count
FROM  category   AS c
JOIN film_category AS fc
ON  c.category_id=fc.category_id
AND c.NAME IN ('Animation',
                'Music',
                'Children',
                'Classics',
                'Comedy',
                'Family')
JOIN film AS f
ON       (f.film_id=fc.film_id)
JOIN  inventory AS i
ON     (f.film_id=i.film_id)
JOIN   rental AS r
ON       (i.inventory_id=r.inventory_id)

GROUP BY 1
ORDER BY 2,
         1;

/*Query 2-query used for second insight*/

SELECT   t1.NAME,
         t1.standard_quartile ,
         Count (t1.standard_quartile)
FROM     (
            
SELECT   f.title,
         c.NAME,
         f.rental_duration,
         Ntile(4) OVER (ORDER BY f.rental_duration) AS standard_quartile
         FROM  film_category fc
                  JOIN     category c
                  ON       c.category_id=fc.category_id
                  JOIN     film f
                  ON       f.film_id=fc.film_id
                  WHERE    c.NAME IN ('Animation',
                                      'Music',
                                      'Children',
                                      'Classics',
                                      'Comedy',
                                      'Family') )AS t1
GROUP BY 1,
         2
ORDER BY 2,
         1;

/*Query 3-query used for Third insight*/


SELECT   Date_part('MONTH' , r1.rental_date) AS rental_month,
         Date_part('YEAR',r1.rental_date)    AS rental_year,
         ('store' || s1.store_id ) AS store,
         Count(*)
FROM     store AS s1
JOIN     staff AS s2
ON       s1.store_id = s2.store_id
JOIN     rental r1
ON       s2.staff_id=r1.staff_id
GROUP BY 
     1,
     2,
     3
ORDER BY 
     2,
     1;

/*Query 4-query used for fourth insight*/

  WITH t1 AS
(
    SELECT (first_name
                     || ' '
                     || last_name) AS NAME,
              c.customer_id,
              p.amount,
              p.payment_date
       FROM   customer AS c
       JOIN   payment  AS p
       ON     c.customer_id = p.customer_id), t2 AS
(
         SELECT   t1.customer_id
         FROM     t1
         GROUP BY 1
         ORDER BY Sum(t1.amount) DESC limit 10), t3 AS
(
         SELECT   t1.NAME,
                  Date_part('month',t1.payment_date) AS payment_month,
                  Date_part('year',t1.payment_date)  AS payment_year,
                  Count(*),
                  Sum(t1.amount),
                  Sum(t1.amount)                                                                                                AS total,
                  Lead(Sum(t1.amount)) OVER (partition BY t1.NAME ORDER BY Date_part('month',t1.payment_date))                  AS lead,
                  Lead(Sum(t1.amount)) OVER (partition BY t1.NAME ORDER BY Date_part('month',t1.payment_date)) - Sum(t1.amount) AS lead_dif
         FROM     t1
         JOIN     t2
         ON       t1.customer_id= t2.customer_id
         WHERE    t1.payment_date BETWEEN '20070101' AND      '20080101'
         GROUP BY 
            1,
            2,
            3
         ORDER BY 
            1,
            3,
            2)
SELECT   t3.*,
         CASE
                  WHEN t3.lead_dif =
                           (
                                    SELECT   Max (t3.lead_dif)
                                    FROM     t3
                                    ORDER BY 1 DESC limit 1) THEN ' this is the maximum difference '
                  ELSE NULL
         END AS is_max
FROM     t3
ORDER BY 
   1;