-- first of all lets create our data base and use it
create database india_census;
use india_census;

-- next we import the data sets and explore them
select * from dataset1;
describe dataset1;
/* we need to set district and state as a composed primery key
select distinct district from dataset1 634 rows that means there are duplicated values;
select distinct state from dataset1 34 rows that means there are duplicated value ;
select distinct district,state from dataset1 ; 640 rows that means all rows are unique */

select * from dataset2;
describe dataset2;
/* we need to set the primery key from the table above dataset1 
as a foreign key in dataset2 */



-- number of entities (rows) into our data sets :
select count(*) as nomber_of_rows from dataset1 ; -- the result is 640.
select count(*) as nomber_of_rows from dataset2 ; -- the result is 640.


-- dataset for jharkhand and bihar
select * from dataset1 where state in ('jharkhand','bihar'); -- 62 rows returned


-- calculating the total population of india from table dataset2 
select sum(population) as total_population from dataset2 ; -- '1 210 854 977'

-- next we want to know the average growth of india
select concat(format(avg(growth)*100,2),'%') as average_growth from dataset1; -- the average growth is'19.25%'
/* we calculated the average growth using avg() function and we passed the column growth as its argument
then we multiped the result by 100 to convert the result to percentage , after that we used the format() 
function to round the number with two decimal places , lastely using concat() function we added 
the '%' sign the the result */

-- now we want to know the average growth of each state
select state , concat(format(avg(growth)*100,2),'%') as average_growth_per_state from dataset1 group by state;


-- next we want to know the average sex ratio in each state and order it from the highest to the lowest
select state , round(avg(sex_ratio),0) as average_sex_ratio from dataset1
group by state order by average_sex_ratio desc ;


/*moving on lets calculate the average literacy rate and display the states
where the average literacy is greater than 90 */
select state , round(avg(literacy),0) as average_literacy_rate from dataset1
group by state having average_literacy_rate>90 order by average_literacy_rate desc;


-- top 3 state showing highest average growth ratio
select state , round(avg(growth)*100,0) as average_growth_rate from dataset1
group by state order by average_growth_rate desc limit 3;

-- bottom 3 state showing lowest average sex ratio
select state , round(avg(sex_ratio),0) as average_sex_ratio from dataset1
group by state order by average_sex_ratio asc limit 3;


/*next lets say we want to display top and bottom 3 states in literacy rate state in 
in the same table using union command*/

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


-- states starting with letter a or b
select distinct state from dataset1 where lower(state) like 'a%'or lower(state) like 'b%';

-- states starting with letter a and ending with letter m 
select distinct state from dataset1 where lower(state) like 'a%'and lower(state) like '%m';

-- next we will try to determine the total males and females using tables join

select ds1.district,ds1.state,ds1.sex_ratio,ds2.population
from dataset1 as ds1 inner join dataset2 as ds2
on ds1.district=ds2.district;





 