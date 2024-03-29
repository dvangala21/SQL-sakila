use sakila; 

-- Display the first and last names of all actors from the table actor.
SELECT first_name, last_name from actor; 

-- Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT concat(first_name, last_name) as "Actor Name" from actor; 

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_ID, first_name, last_name from actor
WHERE first_name = "Joe"; 

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT first_name, last_name from actor
WHERE last_name like "%GEN%"; 

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT first_name, last_name from actor
WHERE last_name like "%LI%"
ORDER BY last_name, first_name; 

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country from country 
WHERE country in ('Afghanistan', 'Bangladesh', 'China'); 

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor 
ADD COLUMN description BLOB AFTER last_update; 

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description; 

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(last_name) as "Count" from actor
GROUP BY last_name; 

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, count(last_name) as "Count" from actor
WHERE "Count" > 1
GROUP BY last_name; 

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" and last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor 
SET first_name = "GROUCHO"
WHERE first_name = "HARPO";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE address; 

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT first_name, last_name, address from staff
JOIN address on staff.address_id = address.address_id; 

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT last_name, sum(amount) from staff
JOIN payment on payment.staff_id = staff.staff_id
GROUP BY last_name; 

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select film.film_id, film.title, count(film_actor.actor_id) as 'Actor_Count'
from film 
inner join film_actor
on film.film_id = film_actor.film_id
group by film.film_id
order by Actor_Count desc;


-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT Count(title) from inventory
JOIN film on film.film_id = inventory.film_id
WHERE title = "Hunchback Impossible"
Group By title; 

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT last_name, sum(amount) from customer
JOIN payment on payment.customer_id = customer.customer_id
GROUP BY last_name; 

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title FROM film
WHERE language_id = (SELECT language_id FROM language WHERE name = 'English')
AND (title like 'K%' or title like 'Q%');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name FROM actor
WHERE actor_id in (
SELECT actor_id FROM film_actor WHERE film_id = (
				SELECT film_id FROM film WHERE title = upper('Alone Trip')
				  )
        );
        
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email from customer
JOIN address USING (address_id)
JOIN city USING (city_id) 
JOIN country USING (country_id)
WHERE country.country = "Canada"; 

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT * from film
WHERE film_id IN (
		SELECT film_id from film_category where category_id in (
				SELECT category_id FROM category WHERE name = 'Family')
        );
        
-- 7e. Display the most frequently rented movies in descending order.
SELECT title, count(rental_date) as "rental_count" from film
JOIN inventory using (film_id)
JOIN rental using (inventory_id)
GROUP BY title
ORDER BY rental_count desc; 

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store_id, sum(payment.amount) as "revenue" from store
JOIN staff USING (store_id) 
JOIN payment USING (staff_id) 
GROUP BY store_id; 

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country from store
JOIN address USING (address_id)
JOIN city USING (city_id)
JOIN country USING (country_id)
GROUP BY store_id; 

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT name, sum(amount) as 'gross_revenue'
FROM payment 
JOIN rental USING (rental_id)
JOIN inventory USING (inventory_id)
JOIN film_category USING (film_id)
JOIN category USING (category_id)
group by category_id
order by gross_revenue desc
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres as 
	SELECT name, sum(amount) as 'gross_revenue'
	FROM payment 
	JOIN rental USING (rental_id)
	JOIN inventory USING (inventory_id)
	JOIN film_category USING (film_id)
	JOIN category USING (category_id)
	group by category_id
	order by gross_revenue desc
	limit 5;
	
-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres; 

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres; 





