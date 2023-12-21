USE music;
-- Problem 1
-- Who is the senior most employee based on job title?
SELECT 
    employee_id , last_name , first_name , title ,email
FROM
    employee
    order by levels desc
    limit 1;
    
-- Problem 2 
-- Which countries  has the most invoices ?

SELECT 
    count(billing_country) as No_of_invoice , billing_country
FROM
    invoice
    group by billing_country
    order by No_of_invoice desc;   
    
--  Problem 3
-- What are top investing countries ?
SELECT 
    sum(total) as Top_values , billing_country
FROM
    invoice
    group by billing_country;    
    
--  Problem 4 
-- What are the top 3 values of total invoice ?
SELECT 
    total,billing_city,billing_country
FROM
    invoice
ORDER BY total DESC
LIMIT 3;    
    
--  Problem 5    
--  Which city has the best customers ? we would like to throw a promotional music festival in the city we made the most money.
--  Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals.

SELECT 
    c.city, c.state,sum(i.total) as MONEY_SPENT
FROM
    customer AS c
        JOIN
    invoice AS i ON c.customer_id = i.customer_id
    group by c.city
    order by MONEY_SPENT desc;   
    
-- PROBLEM NO 6
-- Who is the best customer ? The customer who has spent the most money will be declared as the best customer. 
-- Write a query that return the person who has spent the most money .
SELECT 
    c.customer_id, c.first_name, c.last_name, sum(i.total) as money_spent
FROM
    customer AS c
        JOIN
    invoice AS i ON i.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY money_spent DESC
LIMIT 1;

-- Problem 7
-- Write a query to return the email,first_name,last_name,& Genre of all Rock Music listners.
-- Return your list ordered alphabetically by email starting with A.
SELECT DISTINCT
    c.first_name, c.last_name, c.email
FROM
    customer AS c
        JOIN invoice AS i ON c.customer_id = i.customer_id
        JOIN invoice_line AS il ON il.invoice_id = i.invoice_id
        JOIN track AS t ON t.track_id = il.track_id
        JOIN genre AS g ON g.genre_id = t.genre_id
WHERE g.name like 'rock';

-- -------------------------------------------------------------------------
SELECT DISTINCT
    c.first_name, c.last_name, c.email
FROM
    customer AS c
        JOIN invoice AS i ON c.customer_id = i.customer_id
        JOIN invoice_line AS il ON il.invoice_id = i.invoice_id
        where il.track_id in (
                 select track_id from track
                 join genre on track.genre_id =genre.genre_id
                 where genre.name  like  'Rock'
)
order by email;

-- Problem 8
-- Let's invite the artist who has written the most rock music in our dataset. 
-- Write a query that return the artist name and total track count of the top ten rock bands.
select artist.artist_id , artist.name  , count(album2.artist_id) as Number_of_Songs from artist
join album2 on album2.artist_id = artist.artist_id
join track on track.album_id = album2.album_id 
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist_id
order by  Number_of_Songs desc ;

-- Problem 9
-- Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track.
-- Order by the song length with the longest songs listed first.


SELECT 
    name, milliseconds
FROM
    track
WHERE
    milliseconds > (SELECT 
            AVG(milliseconds) AS avg_time
        FROM
            track)
ORDER BY milliseconds DESC;

-- Find how much amount spent by each customer on artist ?
-- write a query to return a customer name , artist name , and total spent ?
-- Step 1 
-- Get the best selling artist

-- WITH best_selling_artist AS (
			SELECT 
   artist.name,
    SUM(invoice_line.unit_price * invoice_line.quantity) AS total_spent
FROM
    artist
        JOIN
    album2 ON album2.artist_id = artist.artist_id
        JOIN
    track ON album2.album_id = track.album_id
        JOIN
    invoice_line ON invoice_line.track_id = track.track_id
GROUP BY artist.name
order by total_spent desc
LIMIT 1; 

-- -----------------------------------------------------------
with best_selling_artist as (
select artist.artist_id as artist_id , artist.name as artist_name , sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from invoice_line
join track on track.track_id = invoice_line.invoice_id
join album2 on album2.album_id = track.album_id
join artist on artist.artist_id = album2.artist_id
group by 1 
order by 3 desc
limit 1
)
 select  c.customer_id , c.first_name , c.last_name ,  bsa.artist_name , sum(il.quantity*il.unit_price) as amount_spent
from invoice  as i 
join customer as  c on c.customer_id = i.customer_id
join invoice_line  as il on il.invoice_id = i.invoice_id
join track as t on t.track_id = il.track_id 
join album2 as alb on alb.album_id = t.album_id
join best_selling_artist as bsa on bsa.artist_id = alb.artist_id
group  by c.customer_id  
order by 5 desc;




select artist.artist_id as artist_id , artist.name as artist_name , sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from invoice_line
join track on track.track_id = invoice_line.invoice_id
join album2 on album2.album_id = track.album_id
join artist on artist.artist_id = album2.artist_id
group by 1 
order by 3 desc
limit 1;

-- Problem
-- Write a query that determine the customer that has spent the most on music for each country
-- Write a query that returns the country along with the top customer how much they spent.
-- for countries where the top amount spent is shared , provide all customers who spent this amount.
WITH recursive
CUSTOMER_WITH_COUNTRY AS (
select customer.customer_id , first_name , last_name , billing_country , sum(total) as Total_spending
from invoice
join customer on customer.customer_id = invoice.customer_id
group by 1,2,3,4
order by 2,3 desc ) ,
COUNTRY_MAX_SPENDING AS (
   SELECT BILLING_COUNTRY , MAX(TOTAL_SPENDING) AS MAX_SPENDING
   FROM CUSTOMER_WITH_COUNTRY
   group by BILLING_COUNTRY 
)
SELECT cc.billing_country , cc.total_spending , cc.first_name , cc.last_name , cc.customer_id
from customer_with_country cc
join country_max_spending ms 
on cc.billing_country = ms.billing_country
where cc.total_spending = ms.max_spending
order by 1;

-- One more way to solve the same problem using cte's
with customer_with_country as (
select customer.customer_id , first_name , last_name , billing_country , sum(total) as total_spending,
row_number() over(partition by billing_country order by sum(total) desc) as Row_no
from invoice
join customer
on customer.customer_id = invoice.customer_id
group by 1 ,2,3 , 4
order by 4 asc , 5 desc
) 
select * from customer_with_country where Row_no <=1;