## 首購通路是否會影響新客回購率

WITH Orders_Count AS (
  -- 統計每個用戶每年的訂單數量
  SELECT customerid, transactionyear, COUNT(orderid) AS order_cnt
  FROM Orders
  GROUP BY customerid, transactionyear
),

first_trade AS (
  -- 查找每個客戶的首次購買渠道
  SELECT Customers.customerid, Customers.FirstTransactionDate, MIN(Orders.channel) AS FirstChannel
  FROM Customers
  LEFT JOIN Orders ON Customers.customerid = Orders.customerid
                    AND Customers.FirstTransactionDate = Orders.TransactionDate
  GROUP BY Customers.customerid, Customers.FirstTransactionDate
),

repurchase AS (
  -- 篩選出訂單數量大於1的客戶ID，表示重複購買
  SELECT customerid
  FROM Orders
  GROUP BY customerid
  HAVING COUNT(orderid) > 1
)

-- 綜合以上各表查詢，新客户的首購渠道與重複購買的情況
SELECT 
  Customers.firsttransactionyear,
  Channels.channeltype,
  COUNT(DISTINCT Customers.customerid) AS NewCustomers, -- 新客戶數量
  COUNT(DISTINCT Orders_Count.customerid) AS Repurchase_Customers -- 重複購買客戶數量
FROM Customers
LEFT JOIN first_trade ON Customers.customerid = first_trade.customerid
LEFT JOIN repurchase ON Customers.customerid = repurchase.customerid
LEFT JOIN Orders_Count ON Customers.customerid = Orders_Count.customerid
                       AND Customers.firsttransactionyear = Orders_Count.transactionyear
                       AND Orders_Count.order_cnt > 1
LEFT JOIN Channels ON first_trade.FirstChannel = Channels.channel
-- 按照購買年份和渠道類型分组，計算各组的新客户和重複購買客户數量
GROUP BY Customers.FirstTransactionYear, Channels.ChannelType;


## 首購通路 + 首購產品分類哪種組合回購率最高

- 首購產品分類組合 ：基本邏輯跟上一段程式碼雷同，只取了不同的表單，因此沒有展示；下方直接展示(其一)，如何將首購通路與首購產品分類程式碼整併

WITH 
Orders_Count AS (
  -- 計算每個用戶每年的訂單數量
  SELECT customerid, transactionyear, COUNT(orderid) AS order_cnt
  FROM Orders
  GROUP BY customerid, transactionyear
),

first_trade AS (
  -- 查找每個客戶的首次購買渠道
  SELECT Customers.customerid, Customers.FirstTransactionDate, MIN(Orders.channel) AS FirstChannel
  FROM Customers
  LEFT JOIN Orders ON Customers.customerid = Orders.customerid
                    AND Customers.FirstTransactionDate = Orders.TransactionDate
  GROUP BY Customers.customerid, Customers.FirstTransactionDate
),

repurchase AS (
  -- 篩選出訂單數量大於1的客戶ID，表示重複購買
  SELECT customerid
  FROM Orders
  GROUP BY customerid
  HAVING COUNT(orderid) > 1
),

Customer_Core AS (
  -- 購買核心產品的客戶
  SELECT Customers.customerid, Customers.FirstTransactionDate
  FROM Customers
  LEFT JOIN Orders ON Customers.customerid = Orders.customerid
                    AND Customers.FirstTransactionDate = Orders.TransactionDate
  LEFT JOIN OrderDetails ON Orders.orderid = OrderDetails.orderid
  LEFT JOIN Products ON OrderDetails.productid = Products.productid
  LEFT JOIN (SELECT * FROM Products WHERE ProductType = '核心產品') AS Products_Core
  ON OrderDetails.productid = Products_Core.productid
  WHERE Products_Core.productid IS NOT NULL
),

Customer_Road AS (
  -- 沒有購買帶路產品的客戶
  SELECT Customers.customerid, Customers.FirstTransactionDate
  FROM Customers
  LEFT JOIN Orders ON Customers.customerid = Orders.customerid
                    AND Customers.FirstTransactionDate = Orders.TransactionDate
  LEFT JOIN OrderDetails ON Orders.orderid = OrderDetails.orderid
  LEFT JOIN Products ON OrderDetails.productid = Products.productid
  LEFT JOIN (SELECT * FROM Products WHERE ProductType = '帶路產品') AS Products_Road
  ON OrderDetails.productid = Products_Road.productid
  WHERE Products_Road.productid IS NOT NULL
)

-- 綜合以上各表查詢，新客户的首購渠道與重複購買的情況
SELECT 
  Customers.firsttransactionyear,
  Channels.channeltype,
  COUNT(DISTINCT Customers.customerid) AS YCNR_new_customer, -- 新客户數量
  COUNT(DISTINCT Orders_T.customerid) AS YCNR_repurchase_customer -- 重複購買客户數量
FROM Customers
LEFT JOIN (SELECT * FROM Orders_Count WHERE order_cnt > 1) AS Orders_T
ON Customers.customerid = Orders_T.customerid
AND Customers.firsttransactionyear = Orders_T.transactionyear
LEFT JOIN first_trade ON Customers.customerid = first_trade.customerid
LEFT JOIN repurchase ON Customers.customerid = repurchase.customerid
LEFT JOIN Customer_Core ON Customers.customerid = Customer_Core.customerid
LEFT JOIN Customer_Road ON Customers.customerid = Customer_Road.customerid
WHERE Customer_Core.customerid IS NOT NULL -- 篩選購買核心產品的客戶
AND Customer_Road.customerid IS NULL -- 篩選沒有購買帶路產品的客戶
GROUP BY Customers.FirstTransactionYear, Channels.ChannelType;
