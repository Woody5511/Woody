# greenvines
WITH Orders_Count AS (
SELECT customerid, transactionyear, COUNT( orderid) AS order_cnt
FROM Orders
GROUP BY customerid, transactionyear
),
first_trade AS (
SELECT Customers.customerid, Customers.FirstTransactionDate, MIN(Orders.channel) AS FirstChannel
FROM Customers
LEFT JOIN Orders
ON Customers.customerid = Orders.customerid
AND Customers.FirstTransactionDate = Orders.TransactionDate
GROUP BY Customers.customerid, Customers.FirstTransactionDate
),
repurchase AS (
SELECT customerid
FROM Orders
GROUP BY customerid
HAVING COUNT(orderid) > 1
)

SELECT 
Customers.firsttransactionyear,
Channels.channeltype,
COUNT(DISTINCT Customers.customerid) AS NewCustomers,
COUNT(DISTINCT Orders_Count.customerid) AS Repurchase_Customers
FROM Customers
LEFT JOIN first_trade 
ON Customers.customerid = first_trade.customerid
LEFT JOIN repurchase 
ON Customers.customerid = repurchase.customerid
LEFT JOIN Orders_Count
ON Customers.customerid = Orders_Count.customerid
AND Customers.firsttransactionyear = Orders_Count.transactionyear
AND Orders_Count.order_cnt > 1
LEFT JOIN Channels 
ON first_trade.FirstChannel = Channels.channel
GROUP BY Customers.FirstTransactionYear,Channels.ChannelType;

