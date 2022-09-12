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






