create database music_store;
use music_store;
select * from employee;

-- Question Set 1 - Easy
-- 1. Who is the senior most employee based on job title?
select distinct(title) from employee ;
select * from employee where title='Senior General Manager';


-- 2. Which countries have the most Invoices?
select billing_country,count(billing_country) as 'total_invoices' from invoice group by billing_country order by total_invoices desc limit 1;

select * from invoice_line
select * from invoice



-- 3. What are top 3 values of total invoice?
select * from(
select *,dense_rank() over(ORDER BY total DESC) as total_ran from invoice )t
where total_ran<=3;


-- 4. Which city has the best customers? We would like to throw a promotional Music Festival in the city
-- we made the most money. Write a query that returns one city that has the highest sum of invoice totals.
-- Return both the city name & sum of all invoice totals 5. Who is the best customer? The customer who
-- has spent the most money will be declared the best customer. Write a query that returns the person
-- who has spent the most money

-- best person spend most money(best customer)
WITH temp1 AS (
    SELECT c.last_name,c.first_name,i.total
    FROM customer as c
    JOIN invoice  as i
      ON c.customer_id = i.customer_id
      
)
SELECT last_name,first_name, SUM(total) AS total
FROM temp1
GROUP BY first_name,last_name
order by total desc
limit 1
;


-- city which has highest sum of total invoice
WITH temp1 AS (
    SELECT c.city,i.customer_id,i.total
    FROM customer as c
    JOIN invoice  as i
      ON c.customer_id = i.customer_id
)
SELECT city, SUM(total) AS total
FROM temp1
GROUP BY city
order by total desc
limit 1
;



-- Question Set 2 – Moderate
-- 1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return
-- your list ordered alphabetically by email starting with A

WITH temp1
     AS (SELECT il.invoice_id,
                il.track_id,
                t.genre_id,
                i.customer_id
         FROM   invoice_line AS il
                JOIN track AS t
                  ON il.track_id = t.track_id
                JOIN invoice AS i
                  ON il.invoice_id = i.invoice_id),
     temp2
     AS (SELECT g.NAME AS 'genre',
                c.first_name,
                c.last_name,
                c.email
         FROM   temp1 AS t1
                JOIN customer AS c
                  ON t1.customer_id = c.customer_id
                JOIN genre AS g
                  ON g.genre_id = t1.genre_id)
SELECT DISTINCT first_name,
                email,
                last_name,
                genre
FROM   temp2
ORDER  BY email; 



-- 2. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns
-- the Artist name and total track count of the top 10 rock bands
WITH temp1 AS
(
       SELECT il.invoice_id,
              il.track_id,
              t.genre_id,
              t.album_id
       FROM   invoice_line AS il
       JOIN   track        AS t
       ON     il.track_id=t.track_id
       JOIN   invoice AS i
       ON     il.invoice_id=i.invoice_id) , temp2 AS
(
       SELECT ar.NAME,
              g.NAME AS 'genre',
              t1.genre_id,
              t1.album_id,
              a.artist_id,
              a.title
       FROM   temp1 AS t1
       JOIN   album AS a
       ON     a.album_id=t1.album_id
       JOIN   genre AS g
       ON     g.genre_id=t1.genre_id
       JOIN   artist AS ar
       ON     a.artist_id=ar.artist_id ), temp3 AS
(
       SELECT *
       FROM   temp2
       WHERE  genre='Rock' )
SELECT   NAME,
         Count(title) AS 'count_title'
FROM     temp2
GROUP BY NAME
ORDER BY count_title DESC limit 10;


-- 3. Return all the track names that have a song length longer than the average song length. Return the
-- Name and Milliseconds for each track. Order by the song length with the longest songs listed first
set @avg_song=(select avg(milliseconds) from track);
select @avg_song;
select name,milliseconds from track where @avg_song>milliseconds order by milliseconds desc;


3
-- Question Set 3 – Advance
-- 1. Find how much amount spent by each customer on artists? Write a query to return customer name,
-- artist name and total spent

WITH temp1
     AS (SELECT c.customer_id,
                Concat(c.first_name, '_', c.last_name) AS 'full_name',
                i.invoice_id,
                i.total,
                il.track_id,
                t.album_id,
                a.artist_id,
                ar.NAME
         FROM   customer AS c
                JOIN invoice AS i
                  ON c.customer_id = i.customer_id
                JOIN invoice_line AS il
                  ON i.invoice_id = il.invoice_id
                JOIN track AS t
                  ON t.track_id = il.track_id
                JOIN album AS a
                  ON a.album_id = t.album_id
                JOIN artist AS ar
                  ON ar.artist_id = a.artist_id)
SELECT DISTINCT *
FROM   temp1 

select * from track
-- 2. We want to find out the most popular music Genre for each country. We determine the most popular
-- genre as the genre with the highest amount of purchases. Write a query that returns each country along
-- with the top Genre. For countries where the maximum number of purchases is shared return all Genres.
select * from track
select * from track
WITH temp1
     AS (SELECT c.customer_id,
                Concat(c.first_name, '_',c.last_name) AS 'full_name',
                c.country,
                i.invoice_id,
                i.total,
                il.track_id,
                t.album_id,
                t.genre_id,
                g.name as 'genre'
         FROM   customer AS c
                JOIN invoice AS i
                  ON c.customer_id = i.customer_id
                JOIN invoice_line AS il
                  ON i.invoice_id = il.invoice_id
                JOIN track AS t
                  ON t.track_id = il.track_id
                JOIN genre AS g
				on g.genre_id=t.genre_id
    ),
    temp2 as(
    SELECT  country,total,genre
FROM   temp1 
    )
select country,genre,sum(total) as 'total' from temp2 group by country,genre order by total desc



-- 3. Write a query that determines the customer that has spent the most on music for each country. Write
-- a query that returns the country along with the top customer and how much they spent. For countries
-- where the top amount spent is shared, provide all customers who spent this amount

WITH temp1
     AS (SELECT c.customer_id,
                Concat(c.first_name, '_',c.last_name) AS 'full_name',
                c.country,
                i.invoice_id,
                i.total,
                il.track_id,
                t.album_id,
                t.genre_id,
                g.name as 'genre'
         FROM   customer AS c
                JOIN invoice AS i
                  ON c.customer_id = i.customer_id
                JOIN invoice_line AS il
                  ON i.invoice_id = il.invoice_id
                JOIN track AS t
                  ON t.track_id = il.track_id
                JOIN genre AS g
				on g.genre_id=t.genre_id
    ),
    temp2 as(
    SELECT  country,total,full_name
FROM   temp1 
    )
select country,full_name,round(sum(total),2) as 'total' from temp2 group by country,full_name order by total desc
    


