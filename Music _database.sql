use Music_database
--/* Q1: Who is the senior most employee based on job title? */
select top 1 *
from employee
order by levels desc

/* Q2: Which countries have the most Invoices? */
select billing_country, count(invoice_id)
from invoice
group by billing_country
order by count(invoice_id) desc

/* Q3: What are top 3 values of total invoice? */
select top 3 billing_country, sum(total)
from invoice
group by billing_country
order by sum(total) desc

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select top 3 billing_city, sum(total) as total_Invoice
from invoice
group by billing_city
order by sum(total) desc

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select top 1 c.first_name,c.last_name,sum(i.total) as total_customer_invoice
from customer c left join invoice i on c.customer_id=i.customer_id
group by c.first_name,c.last_name
order by sum(i.total) desc
------------
/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */
select distinct c.first_name,c.last_name,c.email
from customer c
				left join invoice i on c.customer_id=i.customer_id
				left join invoice_line l on i.invoice_id=l.invoice_id
				left join track t on l.track_id=t.track_id
				left join genre g on t.genre_id = g.genre_id
where g.name ='Rock'
ORDER BY email	

		
/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */
select top 10
		a.artist_id,a.name,count(a.artist_id) as number_as_songs
from artist a 
				left join album b on a.artist_id=b.artist_id
				left join track t on t.album_id=b.album_id 
				left join genre g on t.genre_id = g.genre_id
where g.name = 'Rock'
group by a.name,a.artist_id
order by count(a.artist_id) desc

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
select name,milliseconds
from track
where milliseconds > (select avg(milliseconds) as average_milliseconds
							from track)
order by milliseconds desc

------
/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */
--Finding the are artist has the most sales
--Query customer spend for this artist

with best_artist_selling as (select top 1
				a.artist_id,a.name as Artist_name,sum(il.unit_price*il.Quantity) as total_sales
				from invoice_line il left join track t on il.track_id=t.track_id
									left join album alb on alb.album_id=t.album_id
									left join artist a on a.artist_id=alb.artist_id
				group by a.artist_id,a.name
				order by total_sales desc
)
select  c.customer_id,c.first_name,c.last_name,a.Artist_name,sum(il.unit_price*il.Quantity) as total_spend
from best_artist_selling a  left join  album b on a.artist_id=b.artist_id
							left join track t on b.album_id=t.album_id
							left join invoice_line il on il.track_id=t.track_id
							left join invoice i on i.invoice_id=il.invoice_id
							left join customer c on c.customer_id=i.customer_id
group by c.customer_id,c.first_name,c.last_name,a.Artist_name
order by total_spend desc
				

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */
---Create temporary table to find the genre have the most popular each country based on the number of quantity of track
--- Filter the genre ranked top 1 in each country
with popular_genre as (
	select g.name, i.billing_country,g.genre_id,count(il.quantity) as purchases,
		ROW_NUMBER() over(partition by i.billing_country  order by count(il.quantity) desc) as Row_num
	from invoice i left join invoice_line il on il.invoice_id=i.invoice_id
				 left join track t  on il.track_id=t.track_id
				 left join genre g on g.genre_id=t.genre_id
	group by g.name, i.billing_country,g.genre_id
	--order by i.billing_country asc,sum(i.total) desc
)

	select *
	from popular_genre
	where Row_num = 1

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */
---- Create the temporary table to take top 1 that was ranked by country and bill total
with Customter_with_country as (
	select c.first_name,c.last_name,c.customer_id, i.billing_country,sum(i.total) as total_spending, 
		ROW_NUMBER() over(partition by i.billing_country  order by sum(i.total) desc) as Row_num
	from invoice i left join customer c on c.customer_id=i.customer_id
	group by c.first_name,c.last_name,c.customer_id, i.billing_country
			)

select * 
from Customter_with_country	
where Row_num=1

			


