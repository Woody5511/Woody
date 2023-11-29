## 首購通路是否會影響新客回購率

- 資料提取、彙整：
-- 解題思路
-- 第一步創立一張新的表Orders_Count，為了找出回訪客戶而創立的(在主表可以select)
-- 第二步創立一張新的表first_trade，為了找出客戶在這間店的第一筆交易資料，使用只記錄新客行為的customers表的數值建立並且left join orders 表，只有customers表上有ID的，才會顯示orders.channel，channel使用涵式min，找出最早的渠道          
--第三步創立一張新的表repurchase，為了找出有再次購買的customersID
--第四步，將上面創立的表串在一起
--第五步，使用Group By用購買年跟渠道聚合出答案


~~~~sql
WITH Orders_Count AS (
  -- 計算不同年份每位用戶各別有幾張訂單
SELECT customerid, transactionyear, COUNT( orderid) AS order_cnt
FROM Orders
GROUP BY customerid, transactionyear
),

--第一次購買的渠道
first_trade AS (
SELECT Customers.customerid, Customers.FirstTransactionDate, MIN(Orders.channel) AS FirstChannel
FROM Customers
LEFT JOIN Orders
ON Customers.customerid = Orders.customerid
AND Customers.FirstTransactionDate = Orders.TransactionDate
GROUP BY Customers.customerid, Customers.FirstTransactionDate
),
--計算出訂單數大於1的
repurchase AS (
SELECT customerid
FROM Orders
GROUP BY customerid
HAVING COUNT(orderid) > 1
)
-- 將上面創立的表串在一起
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
-- 使用Group By用購買年跟渠道聚合出答案
GROUP BY Customers.FirstTransactionYear,Channels.ChannelType;
~~~~


## 首購通路 + 首購產品分類哪種組合回購率最高

- 資料提取、彙整 ( SQL 語法) ：基本上跟上一段程式碼雷同，只是在首購訂單資料中加入 FirstChannel 欄位，以跟 Channels table 連結 ；最後在提取資料時加入channels tyoe 欄位

~~~~sql
WITH Orders_Count AS (
SELECT customerid, transactionyear, COUNT( orderid) AS order_cnt
FROM Orders
GROUP BY customerid, transactionyear
),
--第一次購買的渠道
first_trade AS (
SELECT Customers.customerid, Customers.FirstTransactionDate, MIN(Orders.channel) AS FirstChannel
FROM Customers
LEFT JOIN Orders
ON Customers.customerid = Orders.customerid
AND Customers.FirstTransactionDate = Orders.TransactionDate
GROUP BY Customers.customerid, Customers.FirstTransactionDate
),
--訂單數大於1
repurchase AS (
SELECT customerid
FROM Orders
GROUP BY customerid
HAVING COUNT(orderid) > 1
),
--有買核心 
Customer_Core AS(
SELECT Customers.customerid,Customers.FirstTransactionDate
FROM Customers
LEFT JOIN Orders
ON Customers.customerid = Orders.customerid
AND Customers.FirstTransactionDate = Orders.TransactionDate
LEFT JOIN OrderDetails
ON Orders.orderid = OrderDetails.orderid
LEFT JOIN Products 
ON OrderDetails.productid = Products.productid
LEFT JOIN (SELECT * FROM Products WHERE ProductType ='核心產品') AS Products_Core
ON OrderDetails.productid = Products_Core.productid
WHERE Products_Core.productid IS NOT NULL 
),

--有買帶路
Customer_Road AS(
SELECT Customers.customerid,Customers.FirstTransactionDate
FROM Customers
LEFT JOIN Orders
ON Customers.customerid = Orders.customerid
AND Customers.FirstTransactionDate = Orders.TransactionDate
LEFT JOIN OrderDetails
ON Orders.orderid = OrderDetails.orderid
LEFT JOIN Products 
ON OrderDetails.productid = Products.productid
LEFT JOIN (SELECT * FROM Products WHERE ProductType ='帶路產品') AS Products_Road
ON OrderDetails.productid = Products_Road.productid
WHERE Products_Road.productid IS NOT NULL 
)


SELECT 
Customers.firsttransactionyear,
Channels.channeltype
,COUNT(DISTINCT Customers.customerid) AS YCNR_new_customer 
,COUNT(DISTINCT Orders_T.customerid) AS YCNR_repurchase_customer 
FROM Customers
LEFT JOIN (select * from Orders_Count where order_cnt>1) AS Orders_T
ON Customers.customerid = Orders_T.customerid
AND Customers.firsttransactionyear = Orders_T.transactionyear
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
LEFT JOIN Customer_Core 
On Customers.customerid = Customer_Core.customerid 
LEFT JOIN Customer_Road 
On Customers.customerid = Customer_Road.customerid 
WHERE Customer_Core.customerid IS NOT NULL --有買核心
AND Customer_Road.customerid IS NULL --沒買帶路
GROUP BY Customers.FirstTransactionYear,Channels.ChannelType;
~~~~
