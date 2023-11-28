-- 解題思路
-- 使用WITH建一張新表 Orders_Count 後面主查詢時使用
-- 此表的數據來源是orders表
WITH Orders_Count AS (
SELECT customerid, transactionyear, COUNT( orderid) AS order_cnt
FROM Orders
GROUP BY customerid, transactionyear
),
-- 建一張新的表，取名為第一次交易first_trade，顧名思義，找出客戶的第一筆交易
-- 使用第一次交易日來找出客戶的第一筆交易
-- firsttransactiondate就只有放在Customers表；第一次購買的渠道在orders表的Channels
-- 第一次交易的渠道取名為Firstchannel
-- 用left join連結兩張表，得到第一次交易的渠道
-- 這裡除了使用關鍵key，去連結表單以外，還使用了firsttransactiondate，
-- 這個其實很聰明，如果沒有再包一層限定是同一個客戶第一次交易，篩出來的會是同一個客戶有交易的渠道，就會有總數是對的，但是渠道是錯的狀況
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

