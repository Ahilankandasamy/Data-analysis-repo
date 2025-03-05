use modelcarsdb;
-- Customer data analysis
-- task1
-- t1 1)
select customernumber,customerName, creditLimit from customers order by creditLimit desc limit 10;
-- used select query to find the top 10 customers by creditlimit

-- t1)2)
select country,avg(creditLimit) as AverageCreditLimit from customers group by country;
-- used select query to find country wise average credit

-- t1)3)
select count(customernumber) Number_of_customers,state from customers group by state order by count(*);
-- There are 73 customers who don't have a state

-- T1)4)
select customerNumber as OCN from orders;
select customerName,customerNumber from customers where customerNumber not in (select customerNumber as OCN from orders);
-- There are 24 customers who did not place any order

-- T1)5)
select customers.customerNumber,customers.customerName,sum(amount) as total_sales from customers
inner join payments on
customers.customerNumber=payments.customerNumber group by customerNumber order by total_sales desc;
-- 141,Euro+ Shopping Channel has the highest totalsales among the customers
-- 219,Boards & Toys Co. has the least totalsales among customers

-- T1)6)

select customerName,concat(firstname,' ',lastname) as sales_representative from customers
inner join employees on
customers.salesRepEmployeeNumber=employees.employeeNumber;
-- Displayed the customers along with their sales representative

-- t1)7)
select payments.customernumber,customers.customerName, payments.paymentDate
from customers inner join payments on customers.customerNumber = payments.customerNumber
where payments.paymentDate = (select MAX(paymentDate) from payments where payments.customerNumber = customers.customerNumber);
-- Displayed the customers with most recent orders 

-- t1)8)
select payments.customernumber,customers.customerName,sum(payments.amount) as amount_spent,customers.creditlimit
from customers inner join payments
 ON customers.customerNumber = payments.customerNumber group by payments.customernumber,customers.customerName,customers.creditlimit
having sum(payments.amount) >customers.creditlimit; 
-- There are 46 customers who have exceded their credit limit and purchased products 
-- t1)9)
select customers.customerName from customers
join orders on customers.customerNumber = orders.customerNumber join orderdetails ON orders.orderNumber = orderdetails.orderNumber
join products ON orderdetails.productCode = products.productCode where products.productLine = 'classic cars'
GROUP BY customers.customerName;
-- There are 94 customers who have placed orders in classic cars product line
-- t1)10)
select customerName, max(priceEach) as expensive_order_amount from customers
inner join orders inner join orderdetails on
customers.customerNumber=orders.customerNumber and orders.orderNumber=orderdetails.orderNumber group by customerName order by max(priceEach) desc limit 3;
-- There are 3 customers who have placed orders for the most expensive product
-- The price of the most expensive product ordered is 214 dollars

-- TASK 2
-- Office data analysis
select * from employees;
select * from offices;

-- t2)1
select offices.officeCode, count(*) as Number_of_employees from employees
inner join offices on
employees.officeCode=offices.officeCode group by employees.officeCode;
-- there are total of 6 offices with office1 having the most number of employees ie)6

-- t2)2
select employees.officeCode from offices
inner join employees on
employees.officeCode=offices.officeCode
group by employees.officeCode
having count(employeeNumber) < 5;
-- There are 5 offices with least number of employees .The count is 2

-- t2)3)
select officecode,territory from offices;
-- There are 3 offices which do not have a territory

-- t2)4)
select * from offices;
select * from employees;
select employeeNumber,employees.officeCode from employees
inner join offices on
employees.officeCode=offices.officeCode where offices.officeCode is NULL;
-- All the offices have atleast one employee so there is no office which has no employees

-- t2)5)
select offices.officeCode, sum(amount) as total_sales from offices
inner join employees  inner join customers inner join payments on
offices.officeCode=employees.officeCode and customers.salesRepEmployeeNumber=employees.employeeNumber and payments.customerNumber=customers.customerNumber group by officeCode order by total_sales desc limit 1;

-- Office 4 has the most number of sales among the 7 offices with total sales value of $2819168.90 

-- t2)6)

select employees.officeCode,count(*) employees from employees
inner join offices on
employees.officeCode=offices.officeCode group by officeCode order by count(*) desc limit 1;

-- Office 1 has the most number of employees with a count of 6

-- t2)7)

select offices.officeCode,avg(creditlimit) average_credit_limit from customers
inner join employees  inner join offices on
customers.salesRepEmployeeNumber=employees.employeeNumber and employees.officeCode=offices.officeCode group by officeCode order by average_credit_limit;

-- Office 6 has the highest average credit limt value of 89070
-- Office 3 has the least average credit limt value of 74226
-- t2)8)

select country, count(*) no_of_offices from offices group by country;
-- Thre are 5 countries in which the offices are established
-- There are 3 offices in USA and the rest of the countries have one office each

-- Product data analysis
-- Task 3

-- T3)1)
select count(*) no_of_products, productLine from products group by productline;
-- Classic cars have the highest number of products in its productline with 38 products
-- Trains have lowest number of products in its productline with 3 products


-- T3)2)
select productline,avg(MSRP) as average_price from products group by productline order by average_price desc limit 1;
-- Classic cars has the highest average_price of $118

-- T3)3)
select productName,MSRP from products where MSRP between 50 and 100 order by MSRP;
-- There are 51 products which fall between the range of 50 and 100 price range

-- T3)4)

select productline,sum(quantityOrdered*priceEach) as total_sales from products
inner join orderdetails on
products.productCode=orderdetails.productCode group by products.productline order by total_sales ;
-- Classic cars productline has the most number of totalsales
-- Trains has the least number of sales 

-- t3)5)
select productName, quantityInStock from products where quantityInStock< 10;
-- There are no products which has low inventory level of quantityInStock< 10

-- t3)6)
select max(MSRP) from products;
select productName,MSRP from products where MSRP=(select max(MSRP) from products);

-- 1952 Alpine Renault 1300 is the product which has the highest MSRP in products table

-- t3)7)
select productName,sum(quantityOrdered*priceEach) as total_sales from products
inner join orderdetails on
products.productCode=orderdetails.productCode group by products.productName order by total_sales;
-- 1992 Ferrari 360 Spider red has the highest total sales of 276839.98
-- 1939 Chevrolet Deluxe Coupe has the lowest total sales of 28052.94

-- t3)8)
DELIMITER //
CREATE PROCEDURE sp_top_selling_products(in p_no_of_t_selling_products int)
BEGIN
select orderdetails.productcode,productname,sum(quantityOrdered) as total_quantity_ordered from products
inner join orderdetails on
products.productCode=orderdetails.productCode group by products.productName,orderdetails.productcode
order by sum(quantityOrdered) desc limit p_no_of_t_selling_products ;
END; //
call sp_top_selling_products(2);
-- created a stored procedure to show the top selling products based on the count entered by user
-- t3)9)
select productName, quantityInStock,productline from products where quantityInStock< 10 and productline in('Motorcycles','Classic Cars');
-- There are no productline in the products table which has the quantityInStock less than 10 


-- t3)10)

select productName, count(orderdetails.productCode) as no_of_orders from products
inner join orderdetails on
products.productCode=orderdetails.productCode group by  productName having no_of_orders>10;
-- There are 109 products which are ordered by more than 10 customers
use modelcarsdb;
-- t3)11)
select p.productname, p.productline, COUNT(od.ordernumber) as total_orders
from products as p
inner join orderdetails as od on p.productcode = od.productcode
group by p.productname, p.productline
having count(od.ordernumber) > (
    select avg(product_order_count) 
    from (select count(od1.ordernumber) as product_order_count from products as p1
        inner join orderdetails as od1 on p1.productcode = od1.productcode
        where p1.productline = p.productline group by  p1.productname) as avg_orders
);
-- There are 35 products which have been ordered more than the average order count for the productline


        