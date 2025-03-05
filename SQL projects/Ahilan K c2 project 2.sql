use modelcarsdb;
-- Task 1
-- Employee analysis
-- 1)product_quantity_log
select count(*) no_of_employees from employees;
-- There are totally 23 employees working in different offices
-- 2)
select employeeNumber, firstName,lastName,email,jobTitle from employees;
-- Displayed the employee details
-- 3)
select jobTitle,count(*) employees_per_jobtitle from employees group by jobTitle;
-- There are 17 sales representatives and everyother job title have 1 employee each
-- 4)
select employeeNumber,concat(firstName,' ',lastName) as employee_name from employees where reportsTo is null;
-- There is 1 employee who do not have manager  (details:1002	Diane Murphy  President)

-- 5)
select employeeNumber,concat(firstName,' ',lastName) as employee_name, sum(quantityOrdered*priceEach) as total_sales from orderdetails
inner join orders inner join customers inner join employees on
orderdetails.orderNumber=orders.orderNumber and orders.customerNumber=customers.customerNumber and employees.employeeNumber=customers.salesRepEmployeeNumber group by  employeeNumber,employee_name ;
-- Dislpayed total sales of each sales representative
-- 6)
select employeeNumber,concat(firstName,' ',lastName) as employee_name, sum(quantityOrdered*priceEach) as total_sales from orderdetails
inner join orders inner join customers inner join employees on
orderdetails.orderNumber=orders.orderNumber and orders.customerNumber=customers.customerNumber and employees.employeeNumber=customers.salesRepEmployeeNumber group by  employeeNumber,employee_name order by total_sales desc;
-- Gerard Hernandez has done the highest sales among all the employees
-- Leslie Thompson has been the least profitable sales representative
-- 7)

select concat(E.firstName," ",E.lastName) as Employee_full_name ,sum(quantityordered*priceEach) as Total_sales,avg(quantityordered*PriceEach) as avg_sales
from  employees AS E
INNER JOIN customers AS C
INNER JOIN orders AS O
INNER JOIN orderdetails AS OD
ON E.employeeNumber=C.salesRepEmployeeNumber 
AND C.customerNumber=O.customerNumber 
AND O.orderNumber=OD.orderNumber 
group by Employee_full_name
having Total_sales > avg_sales;
-- There are 15 employees who have sold more than the average sales in the office

-- Order analysis
-- TASK 2
-- 1)

select o.customerNumber,customerName,avg(quantityOrdered*priceEach) as order_amount from orderdetails
inner join orders o inner join customers on
o.orderNumber=orderdetails.orderNumber and customers.customerNumber=o.customerNumber group by customerNumber;
-- Displayed the average order amount for each customer

-- 2)
select count(*) no_of_orders,month(orderDate) from orders group by month(orderDate) order by no_of_orders  ;
-- November month has the most number of orders
-- March month has the least number of orders
-- 3)
select orderNumber from orders where status='Pending';
-- There are no orders which has pending status

-- 4)
select orderNumber,customerName,orders.customerNumber from customers
inner join orders on
orders.customerNumber=customers.customerNumber group by customerName,orders.customerNumber,orderNumber;
-- displayed the customers based on order number
-- 5)
select max(year(orderDate)) from orders;
select orderNumber,(orderDate) from orders where year(orderDate)=(select max(year(orderDate)) from orders) group by orderNumber order by orderDate desc limit 10;
-- Displayed the most recent orders based on order date

-- 6)
select * from orders;
select * from orderdetails;
select orderNumber,(quantityOrdered*priceEach) as total_sales from orderdetails group by total_sales,orderNumber ;
-- Displayed the total sales for each order 
-- The highest total sales for one order is $11503 ordered by order no:10403
-- 7)
select ordernumber,(quantityOrdered*priceEach) as total_sales from orderdetails group  by total_sales,ordernumber order by total_sales desc limit 1;
-- The highest total sales for one order is $11503 ordered by order no:10403

-- 8)
select orders.orderNumber,productCode,quantityordered,priceEach,orderDate,shippedDate,status from orderdetails
inner join orders on
orders.orderNumber=orderdetails.orderNumber;
-- Displayed the order details 
-- 9)
select productCode from orderdetails group by productCode order by count(*) desc limit 1;

select productline,productName, orderdetails.productCode from orderdetails
inner join products on
orderdetails.productCode=products.productCode
where orderdetails.productCode = (select productCode from orderdetails group by productCode order by count(*) desc limit 1) group by productCode;
-- 1992 Ferrari 360 Spider red is the most fequently ordered product which is in classic cars productline

-- task 2)10
select ordernumber,(quantityOrdered*priceeach) as sales_rate ,(o.quantityOrdered*buyPrice)as buy_rate from orderdetails as o
inner join products as p on o.productCode=p.productCode group by orderNumber,sales_rate,buy_rate;

create view abc as select ordernumber,(quantityOrdered*priceeach) as sales_rate ,(o.quantityOrdered*buyPrice)as buy_rate from orderdetails as o
inner join products as p on o.productCode=p.productCode group by orderNumber,sales_rate,buy_rate;
-- actual query
select ordernumber,sales_rate,buy_rate,(sales_rate-buy_rate) as revenue from abc group by ordernumber,revenue,sales_rate,buy_rate;
-- Displayed the revenue genreated for each order

-- task 2)11
select ordernumber,sales_rate,buy_rate,(sales_rate-buy_rate) as revenue from abc group by ordernumber,revenue,sales_rate,buy_rate order by revenue desc limit 10;
-- ordernumbers 10312,10403 has been the top 2 revenue generator among all the orders

-- task 2)12
select * from orderdetails;
select * from orders;
select * from products;
select ordernumber,o.productCode,p.productname,productLine,productdescription,productVendor,quantityInStock,MSRP from products as p 
inner join orderdetails as o on o.productCode=p.productCode group by
 ordernumber,productCode,productname,productline,productdescription,productVendor,quantityInStock,MSRP;
 -- displayed the product details for each order
 -- task 2)13
 select orderNumber, shippedDate,requiredDate  from orders where shippeddate=shippedDate>requiredDate ;-- checked with shipped status, there is no delayed shipment
-- All the orders are shipped within the required date
-- task 2)14
select od1.productcode as p1,od2.productcode as p2
FROM orderdetails AS od1
JOIN orderdetails AS od2 ON od1.orderNumber = od2.orderNumber 
where od1.productCode < od2.productCode;
use modelcarsdb;
-- task 2)15
select * from products;
select ordernumber,sales_rate,buy_rate,(sales_rate-buy_rate) as revenue from abc group by ordernumber,revenue,sales_rate,buy_rate order by revenue desc limit 10;
-- Displayed the order numbers that generated the top 10 revenue among all the orders

-- task 2)16
select * from customers;
select * from orderdetails;
select * from orders;
select * from products;
DELIMITER $$
USE modelcarsdb$$
CREATE DEFINER = CURRENT_USER TRIGGER modelcarsdb.climit_after_od_update AFTER INSERT ON orderdetails FOR EACH ROW
BEGIN
declare custNo int;
select customerNumber into custNo from orders where orderNumber = new.orderNumber;
update customers set creditLimit = creditLimit - (new.quantityOrdered*new.priceEach) where customerNumber = custNo;
END$$
DELIMITER ;
INSERT INTO orders (orderNumber, orderDate, requiredDate, shippedDate, status, customerNumber)
VALUES (4, '2024-09-27', '2024-10-05', NULL, 'In Process', 103);

INSERT INTO orderdetails (orderNumber, productCode, quantityOrdered, priceEach, orderLineNumber)
VALUES (4, 'S18_1749', 30, 136.00, 1),
       (4, 'S18_2248', 50, 55.00, 2);
select * from customers;

-- Used triggers to automatically update the customer's credit limt based on the order amount when ever an order is placed using the customer number

-- task 2)17
CREATE TABLE product_quantity_log (
    
    productCode VARCHAR(20),
    new_quantity_ordered INT,
    orderdate date
);

DELIMITER $$
CREATE TRIGGER TR_Orderdetails_QuantityChange
AFTER INSERT ON orderdetails
FOR EACH ROW
BEGIN
INSERT INTO product_quantity_log (productCode,new_quantity_ordered,orderdate )
VALUES (NEW.productCode,new.quantityordered,curdate());
END; $$
drop trigger TR_Orderdetails_QuantityChange;
desc orderdetails;

set sql_safe_updates=0;
insert into orders(orderNumber,orderDate,requiredDate,shippedDate,status,comments,customerNumber) value(3,'2024-10-02','2024-10-05',null,'pending',null,112);
insert into orderdetails values(3,'S18_2248',100 , 55, 2);
select * from orderdetails;
select * from product_quantity_log;
-- used triggers to automate entry into product log table after an insert event is performed in orderdetails table