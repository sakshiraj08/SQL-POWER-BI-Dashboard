create database music
select *from [dbo].[album2]
select * from [dbo].[artist]
select *from [dbo].[customer]
select *from [dbo].[employee]
select *from genre
select *from [dbo].[invoice]
select *from [dbo].[invoice_line]
select *from [dbo].[media_type]
select *from [dbo].[music store data]
select * from [dbo].[playlist]
select* from playlist_track
select * from [dbo].[track]


--Questiion set-1
--Q1: Who is the senior most employee based on job title? 

select top 1 first_name,last_name,title from employee
order by levels desc

--Q2: Which countries have the most Invoices?
select billing_country,count(invoice_id) as no_of_invoice from invoice
group by billing_country
order by no_of_invoice desc

--Q3: What are top 3 values of total invoice?
select top 3 * from invoice
order by total desc

-- Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
--Write a query that returns one city that has the highest sum of invoice totals. 
--Return both the city name & sum of all invoice totals

select top 1 billing_city,sum(total) as total_invoice from invoice
group by billing_city
order by total_invoice desc

--Q5.Who is the best customer? The customer who has spent the most money will be declared the best customer. 
--Write a query that returns the person who has spent the most money.

select top 1 first_name,last_name,sum(total)as total_money from invoice
join customer on invoice.customer_id=customer.customer_id
group by first_name,last_name
order by total_money desc

--Question Set 2 

-- Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
--Return your list ordered alphabetically by email starting with A.

select distinct first_name,last_name,email from customer c
join invoice i on c.customer_id=i.customer_id
join invoice_line l on i.invoice_id=l.invoice_id
join track t on l.track_id=t.track_id
join genre g on t.genre_id=g.genre_id
where g.name LIKE 'Rock'
order by email

--Q.2 Let's invite the artists who have written the most rock music in our dataset. 
--Write a query that returns the Artist name and total track count of the top 10 rock bands.

alter table artist
alter column name varchar(250)

select distinct a.name, count(track_id) as total_track_count from artist a
join [music store data] m on a.artist_id=m.artist_id
join track t on m.album_id=t.album_id
JOIN genre g ON t.genre_id = g.genre_id
where g.name LIKE 'Rock'
group by a.name
order by total_track_count

--Q3: Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

alter table track
alter column name varchar(250)

SELECT name,milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track )
ORDER BY milliseconds DESC


--4. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

select distinct c.first_name,a.name,sum(l.unit_price*l.quantity) as total_spent from invoice
join customer c on invoice.customer_id=invoice.customer_id
join invoice_line l on invoice.invoice_id=l.invoice_id
join track t on l.track_id=t.track_id
join [music store data] m on t.album_id=m.album_id
join artist a on m.artist_id=a.artist_id
group by c.first_name,a.name
order by total_spent desc

--5.We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
--with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
--the maximum number of purchases is shared return all Genres.

with highest_genre as
(
       select sum(invoice_line.unit_price*invoice_line.quantity)as purchase,customer.country ,genre.name,
       row_number() over(partition by customer.country order by sum(invoice_line.unit_price*invoice_line.quantity) desc) as rowno
       from invoice_line
       JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	   JOIN customer ON customer.customer_id = invoice.customer_id
	   JOIN track ON track.track_id = invoice_line.track_id
	   JOIN genre ON genre.genre_id = track.genre_id
	   group by customer.country ,genre.name
	   
)
	select * from highest_genre 

--6.Write a query that determines the customer that has spent the most on music for each country. 
--Write a query that returns the country along with the top customer and how much they spent. 
--For countries where the top amount spent is shared, provide all customers who spent this amount.

with customer_most as
(
   select sum(total) as total_spent,customer.first_name,invoice.billing_country,
   row_number()over(partition by invoice.billing_country order by sum(total)desc) as rownum
   from customer
   join invoice on customer.customer_id=invoice.customer_id
   group by customer.first_name,invoice.billing_country
)
   select* from customer_most