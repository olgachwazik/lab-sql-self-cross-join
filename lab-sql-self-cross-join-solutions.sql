-- 1. Get all pairs of actors that worked together.

select * from sakila.film_actor fa1
join sakila.film_actor fa2
on fa1.actor_id <> fa2.actor_id
and fa1.film_id = fa2.film_id;

-- 2. Get all pairs of customers that have rented the same film more than 3 times.

-- creating temporary table to have the list of movies with inventory_id
create temporary table films_invent_id1
select f.film_id, i.inventory_id from sakila.film f
join sakila.inventory i 
using (film_id);

select * from films_invent_id1;

-- creating another temporary table to have the list of rentals with film_id 
create temporary table rentals_films1
select r.customer_id, fi.film_id from sakila.rental r
join films_invent_id fi
using (inventory_id); 

select * from rentals_films1;

-- checking in my table customers which rented a movie more than 2 times
create temporary table multiple_rentals1
select customer_id, film_id, count(film_id) from rentals_films
group by customer_id, film_id
having count(film_id) > 2;

select * from multiple_rentals1;

-- from the results received, it seem like the maximum amount that same customer rented out the same film was 3 (and it doesn't seem like there are any customers with the same movie in common). 

-- Still in order to check for those pairs, I'd like to create a self join on this temporary table but it is impossible in MySQL (returning an error: "Can't reopen table").  
select * from multiple_rentals1 m1
join multiple_rentals1 m2
on m1.customer_id <> m2.customer_id
and m1.film_id = m2.film_id;

-- I would imagine it's possible to reach a self join result by using subqueries: 

select * from (select customer_id, film_id, count(film_id) from (select r.customer_id, fi.film_id from sakila.rental r
join (select f.film_id, i.inventory_id from sakila.film f
join sakila.inventory i 
using (film_id))  fi
using (inventory_id)) rf
group by customer_id, film_id
having count(film_id) > 2) m1
join (select customer_id, film_id, count(film_id) from (select r.customer_id, fi.film_id from sakila.rental r
join (select f.film_id, i.inventory_id from sakila.film f
join sakila.inventory i 
using (film_id))  fi
using (inventory_id)) rf
group by customer_id, film_id
having count(film_id) > 2) m2
on m1.customer_id <> m2.customer_id
and m1.film_id = m2.film_id;


-- Carles' solution using multiple inner joins:
select c1.customer_id, c2.customer_id, count(*) as num_films
from sakila.customer c1
inner join rental r1 on r1.customer_id = c1.customer_id
inner join inventory i1 on r1.inventory_id = i1.inventory_id
inner join film f1 on i1.film_id = f1.film_id
inner join inventory i2 on i2.film_id = f1.film_id
inner join rental r2 on r2.inventory_id = i2.inventory_id
inner join customer c2 on r2.customer_id = c2.customer_id
where c1.customer_id <> c2.customer_id
group by c1.customer_id, c2.customer_id
having count(*) > 3
order by num_films desc;

-- I checked the results by looking at the first customer_id 111 to see if indeed this customer rented a movie more than 3 times.
-- If I check it and interpret the results correctly, this doesn't seem to be the case as this customer rented out the same movie max. 2 times (film_id 2). 

select r.rental_id, r.inventory_id, r.customer_id, i.inventory_id, f.film_id from rental r
join inventory i using (inventory_id)
join film f using (film_id)
having customer_id = 111
order by film_id;

-- 3. Get all possible pairs of actors and films.

create temporary table actor_id
select distinct actor_id from sakila.actor;

create temporary table film_id
select distinct film_id from sakila.film;

select * from film_id
cross join actor_id;

