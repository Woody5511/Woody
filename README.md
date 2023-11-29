# 作品集背景

綠藤生醫是台灣保養品牌主打身體沐浴、臉部、頭髮保養等商品，銷售通路由線上官網與九間實體門市組成；
公司將產品分為三大類：核心產品、帶路產品、其他產品；在此案例中主要會透過2021年 1-4 月與2022年1-4月兩年的數據差異，探討首購顧客購買類別與購買通路的關係，**目的要了解什麼組合新客回購率最高**。


## 文件和資源

總共有5份表單，名稱和用途：
1. Customers : 顧客首次購買的基本資料
2. Orders : 綠藤所有的訂單紀錄
3. OrderDetails : 訂單上的詳細內容
4. Products : 產品名稱與分類
5. Channels : 通路清單

## SQL查詢文件

<img width="542" alt="螢幕擷取畫面 2023-11-29 124115" src="https://github.com/Woody5511/Woody/assets/134402371/a08744bf-b2b6-4cdd-84b6-be017bb194c0">


#### Portfolio_query.sql
这个SQL脚本用于分析首购通路对新客回购率的影响。它包含了多个子查询和公用表表达式（CTEs），以便从多个维度进行数据分析。

技术栈: SQL, 数据分析。

**主要内容**：
- 统计每个用户每年的订单数量。
- 确定首次购买渠道。
- 分析复购行为和产品类型的影响。

#### data_sample.csv
以下文件為用於分析的樣本數據集，有助於初步理解數據架構。
https://docs.google.com/spreadsheets/d/1T_TTpngbS3CbhIaDxbn8vylgCsnxgQBY57Dptvrvw0Y/edit#gid=806514037



