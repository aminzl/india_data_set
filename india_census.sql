-- 01/ first of all lets create our data base and use it
create database india_census;
use india_census;

-- 02/ next we import the data sets and explore them
select * from dataset1;
describe dataset1;
/* we need to set district and state as a composed primery key
select distinct district from dataset1 634 rows that means there are duplicated values;
select distinct state from dataset1 34 rows that means there are duplicated value ;
select distinct district,state from dataset1 ; 640 rows that means all rows are unique */
alter table dataset1 add primary key (district,state);
-- show table status;
-- show keys in TableName;
select * from dataset2;
describe dataset2;
/* we need to set the primery key from the table above dataset1 
as a foreign key in dataset2 */
-- SET FOREIGN_KEY_CHECKS=0 if you get error 1452 execute this line than run the querry;
alter table dataset2 add foreign key (district,state) references dataset1(district,state)
on delete no action on update no action ;

-- 03/ number of entities (rows) into our data sets :
select count(*) as nomber_of_rows from dataset1 ; -- the result is 640.
select count(*) as nomber_of_rows from dataset2 ; -- the result is 640.

-- 04/ dataset for jharkhand and bihar
select * from dataset1 where state in ('jharkhand','bihar'); -- 62 rows returned

-- 05/ calculating the total population of india from table dataset2 
select sum(population) as total_population from dataset2 ; -- '1 210 854 977'

-- 06/ next we want to know the average growth of india
select concat(format(avg(growth)*100,2),'%') as average_growth from dataset1; -- the average growth is'19.25%'
/* we calculated the average growth using avg() function and we passed the column growth as its argument
then we multiped the result by 100 to convert the result to percentage , after that we used the format() 
function to round the number with two decimal places , lastely using concat() function we added 
the '%' sign the the result */

-- 07/ now we want to know the average growth of each state
select state , concat(format(avg(growth)*100,2),'%') as average_growth_per_state from dataset1 group by state;

-- 08/ next we want to know the average sex ratio in each state and order it from the highest to the lowest
select state , round(avg(sex_ratio),0) as average_sex_ratio from dataset1
group by state order by average_sex_ratio desc ;

/* 09/moving on lets calculate the average literacy rate and display the states
where the average literacy is greater than 90 */
select state , round(avg(literacy),0) as average_literacy_rate from dataset1
group by state having average_literacy_rate>90 order by average_literacy_rate desc;

-- 10/ top 3 state showing highest average growth ratio
select state , round(avg(growth)*100,0) as average_growth_rate from dataset1
group by state order by average_growth_rate desc limit 3;

-- 11/ bottom 3 state showing lowest average sex ratio
select state , round(avg(sex_ratio),0) as average_sex_ratio from dataset1
group by state order by average_sex_ratio asc limit 3;

/* 12/ next lets say we want to display top and bottom 3 states in literacy rate state in 
in the same table using union command,
we begin by creating two tables each one hold two columns one for states and the other for the average literacy , than we sort the
result in an ascending way for the first table and descending way for the second table, lastly we join them with union */
drop table if exists top_state;
create table top_state (
state varchar(255),
topstate float
);
insert into top_state
select state , round(avg(literacy),0) as average_literacy_ratio from dataset1
group by state order by average_literacy_ratio desc;
select * from top_state order by topstate desc limit 3;

drop table if exists bottom_state;
create table bottom_state (
state varchar(255),
bottomstate float
);
insert into bottom_state
select state , round(avg(literacy),0) as average_literacy_ratio from dataset1
group by state order by average_literacy_ratio desc;
select * from bottom_state order by bottomstate asc limit 3;

-- combining the result of two queries in one table using union
select * from (select * from top_state order by topstate desc limit 3) as a
union 
select * from (select * from bottom_state order by bottomstate asc limit 3) as b;

-- 13/ states starting with letter a or b
select distinct state from dataset1 where lower(state) like 'a%'or lower(state) like 'b%';
-- states starting with letter a and ending with letter m 
select distinct state from dataset1 where lower(state) like 'a%'and lower(state) like '%m';

-- 14/ next we will try to determine the total males and females using tables sub_queries and joins
-- first of all let's join the two data sets as one table and call it 'c'
select ds1.district,ds1.state,ds1.sex_ratio/1000 as sex_ratio,ds2.population
from dataset1 as ds1 inner join dataset2 as ds2
on ds1.district=ds2.district
/* next we will be displaying the total number of females and males by doing
some calculation and using columns from table c, 
you can find the detailed formulas used in this query in the file "statistics and logic.txt" within this repository */
select d.state, sum(d.males) as total_males, sum(d.females) as total_females from
(select c.district, c.state, round(c.population/(c.sex_ratio+1),0) as males, 
round((c.population*c.sex_ratio)/(c.sex_ratio + 1),0) as females from 
(select ds1.district,ds1.state,ds1.sex_ratio/1000 as sex_ratio,ds2.population
from dataset1 as ds1 inner join dataset2 as ds2
on ds1.district=ds2.district) as c) as d
group by d.state;

-- 15/ total literacy rate (using the same logic from the query above)
select d.state, sum(d.lliterate_people) as total_lliterate , sum(d.illiterate_people) as total_illiterate from
(select c.district, c.state, round(c.literacy_ratio*c.population,0) as lliterate_people,
round((1-c.literacy_ratio)*c.population,0) as illiterate_people from
(select ds1.district, ds1.state, ds1.literacy/100 as literacy_ratio, ds2.population
from dataset1 as ds1 inner join dataset2 as ds2
on ds1.district=ds2.district) as c) as d 
group by d.state;

-- 16/ population in previous census  (using the same logic from the querys above)
select sum(e.previous_census_population) as previous_census_population, sum(e.current_census_population) as current_census_population from
(select d.state, sum(d.previous_census_population) as previous_census_population, 
sum(d.current_census_population) as current_census_population from
(select c.district ,c.state, round(c.population/1+c.growth,0) as previous_census_population  , 
c.population as current_census_population from 
(select ds1.district, ds1.state, ds1.growth, ds2.population from dataset1 as ds1 inner join dataset2 as ds2
on ds1.district=ds2.district) as c) as d 
group by d.state) as e;

/* 17/ population vs area : here we'll be joining the resulting table above with the area column from dataset2 on a new column
that we created and named it "key", than devide the area by the previous and curent census population */
select (g.total_area/g.previous_census_population) as previous_census_population_vs_area,
(g.total_area/g.current_census_population) as current_census_population_vs_area from
(select g.*, e.total_area from
(select '1' as keyy, f.* from
(select sum(e.previous_census_population) as previous_census_population, sum(e.current_census_population) as current_census_population from
(select d.state, sum(d.previous_census_population) as previous_census_population, 
sum(d.current_census_population) as current_census_population from
(select c.district ,c.state, round(c.population/1+c.growth,0) as previous_census_population  , 
c.population as current_census_population from 
(select ds1.district, ds1.state, ds1.growth, ds2.population from dataset1 as ds1 inner join dataset2 as ds2
on ds1.district=ds2.district) as c) as d 
group by d.state) as e) as f) as g
inner join  
(select '1' as keyy ,e0.*, sum(e0.area_km2) as total_area from dataset2 as e0) as e on g.keyy=e.keyy)as g;

/* 18/window function : the task is to output top 3 districts from each state with highest literacy rate , so here we'll be 
using the rank() function along with partition */
select z.* from
(select district , state , literacy , rank() over(partition by state order by literacy desc ) as rnk from dataset1) as z where rnk in (1,2,3) order by state;



 