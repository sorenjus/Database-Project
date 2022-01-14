SPOOL project.txt
SET ECHO ON
/*
CIS 353 01 Database Project
Jake Christy
Alec DeVries
Justin Sorensen
Brian Turnbo
*/
-- Drop tables if they exist (for testing purposes)
DROP TABLE customer CASCADE CONSTRAINTS;
DROP TABLE orders CASCADE CONSTRAINTS;
DROP TABLE products CASCADE CONSTRAINTS;
DROP TABLE inventoryPurchases CASCADE CONSTRAINTS;
DROP TABLE orderLines CASCADE CONSTRAINTS;
DROP TABLE states CASCADE CONSTRAINTS;
DROP TABLE productPurchases CASCADE CONSTRAINTS;
--
-- Create the tables
--
-- Create the customer table
CREATE TABLE customer (
    custID      number(8) PRIMARY KEY,
    name        varchar2(25) NOT NULL
);
--
-- Create order table
CREATE TABLE orders (
    orderID     number(8) PRIMARY KEY,
    orderDate   varchar2(15),
    custID      number(8)
);
--
-- Create product table
CREATE TABLE products (
    productID   number(8) PRIMARY KEY,
    name        varchar2(25) NOT NULL,
    price       number(8, 2),
    qtyInStock  number(8),
    prodSize    varchar2(15),
    CONSTRAINT prodIC1 CHECK (price > 0),
    CONSTRAINT prodIC2 CHECK (qtyInStock >= 0),
    CONSTRAINT prodIC3 CHECK (prodSize IN ('small', 'medium', 'large')),
    CONSTRAINT prodIC4 CHECK (NOT(prodSize = 'medium' AND (price <= 30))),
    CONSTRAINT prodIC5 CHECK (NOT(prodSize = 'large' AND (price <= 100)))
);
--
-- Create inventoryPurchases table
CREATE TABLE inventoryPurchases (
    purchaseID  number(8) PRIMARY KEY,
    purchDate   varchar2(15)
);
--
-- Create orderLines table
CREATE TABLE orderLines (
    orderID     number(8),
    productID   number(8),
    quantity    number(8),
    PRIMARY KEY (orderID, productID),
    CONSTRAINT lineIC1 CHECK (quantity > 0)
);
--
-- Create states table
CREATE TABLE states (
    custID      number(8),
    state       varchar2(20),
    PRIMARY KEY (custID, state)
);
--
-- Create productPurchases table
CREATE TABLE productPurchases (
    purchaseID  number(8),
    productID   number(8),
    quantity    number(8),
    PRIMARY KEY (purchaseID, productID)
);
--
-- Add foreign keys
ALTER TABLE orders
ADD FOREIGN KEY (custID) references customer(custID)
Deferrable initially deferred;
ALTER TABLE orderLines
ADD FOREIGN KEY (orderID) references orders(orderID)
Deferrable initially deferred;
ALTER TABLE orderLines
ADD FOREIGN KEY (productID) references products(productID)
Deferrable initially deferred;
ALTER TABLE states
ADD FOREIGN KEY (custID) references customer(custID)
Deferrable initially deferred;
ALTER TABLE productPurchases
ADD FOREIGN KEY (purchaseID) references inventoryPurchases(purchaseID)
Deferrable initially deferred;
ALTER TABLE productPurchases
ADD FOREIGN KEY (productID) references products(productID)
Deferrable initially deferred;
--
-- DONE creating tables
--
SET FEEDBACK OFF
--
-- INSERTING DATA
--
INSERT INTO customer VALUES (100, 'John Smith');
INSERT INTO customer VALUES (101, 'Jane Doe');
INSERT INTO customer VALUES (102, 'Mike Fisher');
INSERT INTO customer VALUES (103, 'Mary Sue');
--
INSERT INTO orders VALUES (2001, '10-08-2020', 100);
INSERT INTO orders VALUES (2002, '10-23-2020', 101);
INSERT INTO orders VALUES (2003, '01-30-2021', 102);
INSERT INTO orders VALUES (2004, '03-22-2021', 100);
INSERT INTO orders VALUES (2005, '06-02-2021', 102);
INSERT INTO orders VALUES (2006, '09-17-2021', 100);
--
INSERT INTO products VALUES (3001, 'candy', 3.50, 10, 'small');
INSERT INTO products VALUES (3002, 'milk', 3.00, 35, 'small');
INSERT INTO products VALUES (3003, 'bread', 1.50, 23, 'small');
INSERT INTO products VALUES (3004, 'shirt', 32.99, 12, 'medium');
INSERT INTO products VALUES (3005, 'jeans', 34.99, 42, 'medium');
INSERT INTO products VALUES (3006, '40 inch TV', 249.99, 25, 'large');
INSERT INTO products VALUES (3007, 'Laptop', 999.99, 30, 'large');
--
INSERT INTO inventoryPurchases VALUES (401, '01-02-2020');
INSERT INTO inventoryPurchases VALUES (402, '07-19-2020');
INSERT INTO inventoryPurchases VALUES (403, '02-07-2021');
--
INSERT INTO orderLines VALUES (2001, 3001, 2);
INSERT INTO orderLines VALUES (2002, 3004, 1);
INSERT INTO orderLines VALUES (2002, 3005, 1);
INSERT INTO orderLines VALUES (2003, 3007, 1);
INSERT INTO orderLines VALUES (2004, 3002, 3);
INSERT INTO orderLines VALUES (2004, 3003, 3);
INSERT INTO orderLines VALUES (2005, 3006, 2);
INSERT INTO orderLines VALUES (2006, 3007, 2);
--
INSERT INTO states VALUES (100, 'Texas');
INSERT INTO states VALUES (100, 'Mississippi');
INSERT INTO states VALUES (101, 'California');
INSERT INTO states VALUES (102, 'Florida');
--
INSERT INTO productPurchases VALUES (401, 3004, 50);
INSERT INTO productPurchases VALUES (401, 3005, 50);
INSERT INTO productPurchases VALUES (401, 3006, 10);
INSERT INTO productPurchases VALUES (402, 3001, 100);
INSERT INTO productPurchases VALUES (402, 3002, 200);
INSERT INTO productPurchases VALUES (402, 3003, 150);
INSERT INTO productPurchases VALUES (403, 3006, 20);
INSERT INTO productPurchases VALUES (403, 3007, 15);
--
-- DONE INSERTING DATA
--
SET FEEDBACK ON
COMMIT;
--
-- LIST OF TABLES
--
SELECT * FROM customer;
SELECT * FROM orders;
SELECT * FROM products;
SELECT * FROM inventoryPurchases;
SELECT * FROM orderLines;
SELECT * FROM states;
SELECT * FROM productPurchases;
--
-- DONE LISTING TABLES
--
-- OTHER QUERIES
--
-- QUERY01
-- Demonstrates:
--  - join with 4 relation
--  - using SUM()
--  - group by, having, order by in one query
-- Description: Find the custID and cost of customer orders that have a total cost of at least $1000
SELECT C.custID, SUM(P.price * L.quantity) AS Total_cost
FROM customer C, orders O, orderLines L, products P
WHERE C.custID = O.custID AND
        O.orderID =  L.orderID AND
        L.productID = P.productID
GROUP BY C.custID
HAVING SUM(P.price) >= 1000
ORDER BY custID;
--
-- QUERY02
-- Demonstrates: outer join
-- Description: Find the custID of each customer. Also find each orderID for all of their orders if they have any.
SELECT C.custID, O.orderID
from customer C LEFT OUTER JOIN orders O ON C.custID = O.custID
order by c.custID;
--
-- QUERY03
-- Demonstrates: DIVISION, MINUS
-- Description: Find the custID and name of every customer who has ordered EVERY product that is size 'medium'
SELECT C.custID, C.name
FROM customer C
WHERE NOT EXISTS
    ((SELECT P.productID
    FROM products P
    WHERE P.prodSize = 'medium')
    MINUS
    (SELECT P.productID
    FROM orders O, orderlines L, products P
    where C.custID = O.custID AND
    O.orderID = L.orderId AND
    L.productID = P.productID AND
    P.prodSize = 'medium'));
--
-- QUERY04
-- Demonstrates: self-join
-- Description: Find pairs of customers by id and name that have ordered the same products and the product
SELECT C1.custID, C1.name, C2.custID, C2.name, OL1.productID
FROM customer C1, customer C2, orders O1, orders O2, orderLines OL1, orderLines OL2
WHERE C1.custID = O1.custID AND
    O1.orderID = OL1.orderID AND
    C2.custID = O2.custID AND
    O2.orderID = OL2.orderID AND
    OL1.productID = OL2.productID AND
    C1.custID > C2.custID;
--
-- QUERY05
-- Demonstrates: correlated subquery
-- Description: Find most expensive order of each customer and list the customer id, name, and order cost
SELECT C.custID, SUM(P.price * L.quantity)
FROM customer C, orders O, orderLines L, products P
WHERE C.custID = O.custID AND
    O.orderID = L.orderID AND
    L.productID = P.productID
GROUP BY C.custID, O.orderID
HAVING SUM(P.price * L.quantity) = (
    SELECT MAX(SUM(PP.price * LL.quantity))
    FROM orders OO, orderLines LL, products PP
    WHERE OO.orderID = LL.orderID AND
        LL.productID = PP.productID AND
        OO.custID = C.custID
    GROUP BY OO.custID, OO.orderID
)
ORDER BY C.custID;
--
-- QUERY06
-- Demonstrates: noncorrelated subquery
-- Description: Find customers that have multiple states (locations) on file
SELECT C.custID
FROM customer C
WHERE C.custID IN (
    SELECT S.custID
    FROM states S
    GROUP BY S.custID
    HAVING COUNT(S.state) > 1
);
--
--
--TESTING INTEGRITY CONSTRAINTS
--
--Testing : custC1
--Should fail because 100 already exists
INSERT INTO customer VALUES (100, 'Jane Smith');
--
--Testing : ordIC2
--Should fail because 99 doesnt exist in customers
--Will insert but cause commit to fail because deferred constraints apply
INSERT INTO orders VALUES (2007, '11-25-2021', 99);
--
--Testing : prodIC1
--Should fail because -1.99 is less than or equal to 0
INSERT INTO products VALUES (3008, 'juice', -1.99, 5, 'small');
--
--Testing : prodIC4
--Should fail because medium products must be 30 or greater and 28.89 is less than 30
INSERT INTO products VALUES (3008, 'Khakis', 28.89, 42, 'medium');
--
-- DONE WITH QUERIES
--
COMMIT;
SPOOL OFF
