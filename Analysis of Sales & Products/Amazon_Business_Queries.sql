create database Amazon_Dataset ;
USE  Amazon_dataset;
-- If exist these columns it will removed
Alter table date_table 
drop  column timeofday,
drop  column dayname, 
drop column monthname;

-- Adding date table with columns timeofday, dayname, monthname
select  * from date_table;
Alter table date_table 
add column timeofday varchar (10),
add column dayname varchar (10),
add column monthname varchar (10);

select * from date_table;

set sql_safe_updates = 0

/*using conditional formate to adding timeofday */

update date_table 
set timeofday = case
      when extract(hour from time) between 6 and 11 then "Morning"
      when extract(hour from time) between 12 and 17 then "Afternoon"
      when extract(hour from time) between 18 and 23 then "Evening"
      else "Night"
end;
 
 select  * from date_table;
 
 Update date_table
 set monthname = monthname(date);
 
  Update date_table
 set dayname = dayname(date);
 
 /* All Business Problems */ 
 
 #1  What is the count of distinct cities in the dataset?
select distinct city,count(city) as City_count from amazon
group by city
order by city;

#2 For each branch, what is the corresponding city?
select distinct branch ,city from amazon;

#3 What is the count of distinct product lines in the dataset?
SELECT COUNT(*) as produt_count
FROM (SELECT `product line` FROM amazon GROUP BY `product line`) AS distinct_product_lines;

#4 Which payment method occurs most frequently? 
select distinct payment,count(payment) as Payment_count from amazon 
group  by  payment
order by count(payment) desc ;

 #5 Which product line has the highest sales?
SELECT `Product line`,round(sum(`Unit price`*quantity),2) as Total_sales from  amazon
group by `product line`
order by sum(`Unit price`*quantity) desc  ;

#6 How much revenue is generated each month?
select year(a.date) as Year, monthname,round(sum(`Unit price`*quantity),2) as Total_revenue from 
amazon a left join date_table d using(`invoice id`)
group by year(a.date), monthname,month(a.date)
order by month(a.date)asc ;

#7 In which month did the cost of goods sold reach its peak?
select year(a.date) as Year ,monthname,round(sum(cogs),2) as Total_cost from amazon a join date_table d using(`invoice id`)
group by year(a.date), monthname,month(a.date)
order by Total_cost desc 
limit 1;

#8 Which product line generated the highest revenue?
SELECT `Product line`,round(sum(total),2) as Total_revenue from  amazon
group by `product line`
order by sum(total) desc
limit 1  ;

#9 In which city was the highest revenue recorded?
SELECT city,round(sum(total),2) as Total_revenue from  amazon
group by city
order by sum(total) desc
limit 1  ;

#10 Which product line incurred the highest Value Added Tax?
SELECT `Product line`,round(sum(`tax 5%`),2) as high_tax from  amazon
group by `product line`
order by sum(`tax 5%`) desc
limit 1  ;

#11 For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."

SELECT `product line`, round(SUM(total),2) AS total_sales,CASE 
 WHEN SUM(total) > (SELECT AVG(total_sales) FROM (SELECT `product line`, SUM(total) AS total_sales
                   FROM amazon 
                   GROUP BY `product line`) AS subquery) THEN 'Good'
ELSE 'Bad' END AS performance
FROM amazon 
GROUP BY `product line`;

#12 Identify the branch that exceeded the average number of products sold.
select branch,sum(quantity) as total_qtySold from amazon group by branch 
having total_qtySold > (select avg(total_qtySold) from (select branch,sum(quantity) as total_qtySold from amazon
 group by branch)as avt  );

#13 Which product line is most frequently associated with each gender?
select gender, `product line`, max(total_sales) as most_frequent 
from ( select gender, `product line`,count(*) as total_sales from amazon 
 group by gender, `product line`) as subquery
 group by gender, `product line`
 order by most_frequent desc;

#14 Calculate the average rating for each product line.
select `product line`,round(avg(rating),2) as avg_rating from amazon 
group by `product line`
order by avg(rating);

#15 Count the sales occurrences for each time of day on every weekday.
select monthname, dayname,timeofday,count(*) as total_sales from amazon a join date_table using(`invoice id`)
group by  monthname,dayname,timeofday,day(a.date)
ORDER BY  monthname,day(a.date),field(timeofday,"Morning","Afternoon","Evening","Night");

#16 Identify the customer type contributing the highest revenue.
select `customer type`, round(max(totals),2) as max_revenue from (
select `customer type`, sum(total) as totals from amazon group by   `customer type`
) as sub
group by `customer type` ;

#17 Determine the city with the highest VAT percentage.
select city,max(`tax 5%`) as max_percentage from amazon
group by city 
order by max(`tax 5%`) desc ;

#18 Identify the customer type with the highest VAT payments.
select `customer type`, round(max(total_tax),2) as max_payment from (
select `customer type`, sum(`tax 5%`) as total_tax from amazon group by   `customer type`
) as sub
group by `customer type` ;

#19 What is the count of distinct customer types in the dataset?
select `customer type`,count(*) as Numbers from amazon 
group by `customer type`;

#20 What is the count of distinct payment methods in the dataset?
select `payment`,count(*) as Numbers from amazon 
group by `payment`;

#21 Which customer type occurs most frequently?
select `customer type`,count(*) as occurence from amazon 
group by `customer type`
order by occurence desc
limit 1;

#22 Identify the customer type with the highest purchase frequency.
select `customer type`,round(sum(total),2) as high_purchase from amazon 
group by `customer type`
order by high_purchase desc
limit 1;

#23 Determine the predominant gender among customers.
select Gender,count(*) as occurence from amazon 
group by gender
order by occurence desc;

#24 Examine the distribution of genders within each branch.
select branch,count(Gender) as Gender_distribution from amazon 
group by  branch
order by  branch asc ;

#25 Identify the time of day when customers provide the most ratings.
select timeofday,count(rating) as rating_count from amazon join date_table using(`invoice id`)
where rating is not null
group by timeofday
order by rating_count desc ;

#26 Determine the time of day with the highest customer ratings for each branch.
select timeofday,branch,round(avg(rating),2) as rating_high from amazon join date_table using(`invoice id`)
where rating is not null
group by timeofday,branch
having avg(rating) = (select max(avg(rating)) from (select timeofday,branch,avg(rating) as rating_high from amazon join date_table using(`invoice id`)
where rating is not null
group by timeofday,branch) as sub
where sub.branch = amazon.branch)
order by branch,rating_high desc ;

#27 Identify the day of the week with the highest average ratings.
select dayname,round(avg(rating),2) as rating_high from amazon join date_table using(`invoice id`)
where rating is not null
group by dayname
having avg(rating) = (select max(avg(rating)) from (select dayname,round(avg(rating),2) as rating_high from amazon join date_table using(`invoice id`)
where rating is not null
group by dayname) as sub
 )
order by  rating_high desc;

#28 Determine the day of the week with the highest average ratings for each branch.
select branch,dayname,round(avg(rating),2) as rating_high from amazon join date_table using(`invoice id`)
where rating is not null
group by branch,dayname
having avg(rating) = (select max(avg(rating)) from (select branch,dayname,round(avg(rating),2) as rating_high from amazon join date_table using(`invoice id`)
where rating is not null
group by branch,dayname) as sub WHERE sub.branch = amazon.branch
 )
order by  branch,rating_high desc;

