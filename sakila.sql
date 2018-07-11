-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(first_name, ' ', last_name) 
AS 'Actor Name'
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
SELECT actor_id, first_name, last_name 
FROM actor
WHERE first_name='JOE';

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT * 
FROM actor
WHERE last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT *
FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country 
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(255)
AFTER first_name;

SELECT * FROM actor;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
ALTER TABLE actor
MODIFY middle_name BLOB;

SELECT * FROM actor;

-- 3c. Now delete the middle_name column.
ALTER TABLE actor
DROP COLUMN middle_name;

SELECT * FROM actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(*)
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, count(*)
FROM actor
GROUP BY last_name
HAVING count(*) > 2;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name='GROUCHO' AND last_name='WILLIAMS';

SELECT * FROM actor WHERE last_name='WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
UPDATE actor
SET first_name = 'GROUCHO'
WHERE actor_id = 172;

SELECT * FROM actor WHERE actor_id=172;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT first_name, last_name, address
FROM staff
LEFT JOIN address
ON address.address_id = staff.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT
	p.staff_id,
	s.first_name,
	s.last_name,
	p.amount
FROM staff AS s
	LEFT JOIN (SELECT 
			staff_id,
			SUM(amount) amount
		FROM payment 
		GROUP BY staff_id) AS p
	ON p.staff_id = s.staff_id
GROUP BY s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT
	film.title,
	fa.film_id,
	actors
FROM film
	INNER JOIN (SELECT 
				film_id,
				count(actor_id)	actors
		FROM film_actor
		GROUP BY film_id) AS fa
	ON fa.film_id = film.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT f.film_id, f.title, copies
FROM film as f
INNER JOIN (SELECT film_id, count(*) copies
			FROM inventory
			GROUP BY film_id) as i
ON i.film_id = f.film_id
WHERE f.title = "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
-- ![Total amount paid](Images/total_payment.png)
SELECT c.customer_id, c.first_name, c.last_name, p.total_paid
FROM customer as c
INNER JOIN (SELECT customer_id, sum(amount) total_paid
			FROM payment
			GROUP BY customer_id) as p
ON p.customer_id = c.customer_id
ORDER BY c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title, language_id
FROM film
WHERE 
	(language_id = 1) AND 
	(title LIKE 'K%' OR title LIKE 'Q%');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT fa.actor_id, fa.film_id, t.title, a.first_name, a.last_name
FROM film_actor as fa
INNER JOIN(
		SELECT film_id, title
		FROM film
			) as t
	ON t.film_id = fa.film_id
INNER JOIN(
		SELECT actor_id, first_name, last_name
		FROM actor_info
			) as a
	ON a.actor_id = fa.actor_id
WHERE title = "Alone Trip";

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT cl.ID, cl.name, cl.country, c.email
FROM customer_list as cl
INNER JOIN(
		SELECT customer_id, first_name, last_name, email, address_id
		FROM customer) as c
	ON c.customer_id = cl.ID
WHERE country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
SELECT fc.film_id, fc.category_id, f.title, `category`
FROM film_category as fc
INNER JOIN(
		SELECT film_id, title
		FROM film) as f
	ON f.film_id = fc.film_id
INNER JOIN(
		SELECT category_id, name category
		FROM category) as c
	ON c.category_id = fc.category_id
WHERE category = "Family";

-- 7e. Display the most frequently rented movies in descending order.
SELECT i.film_id, f.title, sum(rcount) rent_count
FROM inventory as i
INNER JOIN(
		SELECT inventory_id, count(*) rcount
		FROM rental as r
		GROUP BY inventory_id) as r
	ON r.inventory_id = i.inventory_id
INNER JOIN(
		SELECT film_id, title
		FROM film) as f
	ON f.film_id = i.film_id
GROUP BY i.film_id
ORDER BY rent_count DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store, concat('$', format(`total_sales`, 2)) total_sales
FROM sales_by_store;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, c.city, d.country
FROM store AS s
INNER JOIN(
		SELECT address_id, city_id
		FROM address) as a
	ON a.address_id = s.address_id
INNER JOIN(
		SELECT city_id, city, country_id
		FROM city) as c
	ON c.city_id = a.city_id
INNER JOIN(
		SELECT country_id, country
		FROM country) as d
	ON d.country_id = c.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT y.name, concat('$', format(y.gross_revenue, 2)) gross_revenue, y.rank
FROM (SELECT name, gross_revenue, @curRank := @curRank + 1 AS rank
FROM (SELECT t.name, sum(t.total) gross_revenue
	FROM (SELECT fc.film_id, fc.category_id, cat.name, i.inventory_id, p.total
		FROM film_category as fc
		INNER JOIN(SELECT category_id, name 
				FROM category
				) as cat
		ON cat.category_id = fc.category_id
		INNER JOIN(SELECT film_id, inventory_id
				FROM inventory
				) as i
		ON i.film_id = fc.film_id
		Inner JOIN(SELECT inventory_id, sum(total) total
				FROM rental as r
					INNER JOIN(SELECT rental_id, sum(amount) total
							FROM payment
							GROUP BY rental_id
							) as p
					ON p.rental_id = r.rental_id
				GROUP BY inventory_id
				) as p
		ON p.inventory_id = i.inventory_id) AS t
	GROUP BY t.name
	ORDER BY gross_revenue DESC) as z, (SELECT @curRank := 0) r) as y
WHERE y.rank < 6;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW r_rated AS
SELECT film_id, title, rating
FROM film
WHERE rating = 'R';

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM r_rated;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW r_rated;



