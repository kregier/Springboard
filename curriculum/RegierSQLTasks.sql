/* In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub. */

/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT name
FROM `Facilities`
WHERE membercost > 0;

/* Q2: How many facilities do not charge a fee to members? */
SELECT name
FROM `Facilities`
WHERE membercost = 0;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance 
FROM `Facilities` 
WHERE membercost > 0
AND membercost < monthlymaintenance * 0.2;

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT *
FROM `Facilities`
WHERE facid
IN ( 1, 5 );

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT name,
    CASE WHEN monthlymaintenance >100 THEN 'expensive'
        ELSE 'cheap' END AS monthly_maintenance
FROM `Facilities`;      

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT firstname, surname
FROM `Members`
ORDER BY joindate DESC;

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT f.name,
    CONCAT(m.firstname. " ", m.surname) AS member_name
FROM Bookings AS b
LEFT JOIN Members AS m ON b.memid = m.memid
LEFT JOIN Facilities AS f ON b.facid = f.facid
WHERE f.facid IN (0,1)
ORDER BY member_name;

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f.name, 
    CONCAT (m.firstname, " ", m.surname) as member_name,
    CASE WHEN b.memid = 0 THEN f.guestcost
        ELSE f.membercost END AS cost
FROM Bookings AS b
LEFT JOIN Members AS m ON b.memid = m.memid
LEFT JOIN Facilities AS f ON b.facid = f.facid
WHERE b.starttime LIKE '2012-09-14%' 
AND CASE WHEN b.memid = 0 AND f.guestcost >30 THEN f.guestcost
        WHEN b.memid != 0 AND f.membercost > 30 THEN f.membercost
        ELSE NULL END IS NOT NULL
ORDER BY cost DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT sub.name, 
    CONCAT (m.firstname, " ", m.surname) as member_name,
    sub.cost
FROM ( 
    SELECT b.memid, f.name, b.starttime,
        CASE WHEN b.memid = 0 THEN f.guestcost
            ELSE f.membercost END AS cost
    FROM Bookings AS b
    LEFT JOIN Facilities AS f ON b.facid = f.facid
    WHERE b.starttime LIKE '2012-09-14%' ) AS sub
LEFT JOIN Members AS m ON sub.memid = m.memid
WHERE sub.cost > 30
ORDER BY cost DESC;

/* PART 2: SQLite
Code and answers also available in a Jupyter Notebook on GitHub
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT f.name, 
    SUM(CASE WHEN b.memid =0 THEN guestcost
        ELSE membercost END) AS total_revenue
FROM Bookings AS b
LEFT JOIN Facilities AS f 
ON b.facid = f.facid
GROUP BY f.name
HAVING total_revenue <1000
ORDER BY total_revenue 

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
SELECT
    m.surname||" "||m.firstname AS member,
    r.surname||" "||r.firstname AS recommender
FROM Members as m
LEFT JOIN Members as r
ON r.memid = m.recommendedby
ORDER BY member;

/* Q12: Find the facilities with their usage by member, but not guests */
SELECT
    f.name,
    COUNT (b.memid) AS member_usage
FROM Bookings AS b
LEFT JOIN Facilities AS f
ON b.facid = f.facid
WHERE b.memid != 0
GROUP BY f.name

/* Q13: Find the facilities usage by month, but not guests */
SELECT
    f.name,
    strftime('%m', b.starttime) AS month,
    COUNT (b.memid) AS member_usage
FROM Bookings AS b
LEFT JOIN Facilities AS f
ON b.facid = f.facid
WHERE b.memid != 0
GROUP BY f.name, month
