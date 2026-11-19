use TraningYa
go


SELECT   row_number() OVER(ORDER BY amount)as Row,Order_ID, Date, Status, Fulfilment, Sales_Channel, ship_service_level, Style, SKU, Category, Size, ASIN, Courier_Status, Qty, currency, Amount, ship_city, ship_state, ship_postal_code, ship_country, promotion_ids ,[B2B],[fulfilled_by] into #Amazon_Sales FROM [dbo].[Amazon_Sale_Report_sample]


SELECT * FROM  #Amazon_Sales

--  total sales

SELECT sum(Amount) as totalsalles FROM #Amazon_Sales

--  total orders

SELECT count(DISTINCT [order_id]) as total_order FROM  #Amazon_Sales

--  total Qty
SELECT sum(Qty) as total_qty FROM #Amazon_Sales

--  Status wise  total sales

SELECT status,sum(Amount) as Status_Sales FROM #Amazon_Sales
GROUP BY status

--  state  wise total sales

SELECT ship_state,sum(Amount) as totalsales FROM  #Amazon_Sales
GROUP BY ship_state
ORDER BY totalsales DESC

--  shiping service total sales

SELECT [ship_service_level],sum(Amount) as totalsales FROM #Amazon_Sales
GROUP BY [ship_service_level]
ORDER BY totalsales DESC


-- [ship_service_level] wise total sales
SELECT [ship_service_level],sum(Amount) as totalsales FROM #Amazon_Sales
GROUP BY [ship_service_level]
ORDER BY totalsales


--  category wise total sales
SELECT category,sum(Amount) as totalsales FROM #Amazon_Sales
GROUP BY category
ORDER BY totalsales

-- [Courier_Status] wise total sales
SELECT [Courier_Status],sum(Amount) as totalsales FROM #Amazon_Sales
GROUP BY [Courier_Status]
ORDER BY totalsales DESC




--  cleaning the dataset  

SELECT
    row_number() OVER(ORDER BY Amount)as Row,
    [Order_ID],
    [Date],
    [Status],
    [Fulfilment],
    [Sales_Channel],
    [ship_service_level],
    [Style],
    [SKU],
    [Category],
    [Size],
    [ASIN],
    COALESCE([Courier_Status], '') AS [Courier_Status],
    [Qty],
    COALESCE([currency], 'INR') AS [Currency],
    COALESCE([Amount], 0) AS [Amount],
    [ship_city],
    [ship_state],
    [ship_postal_code],
    [ship_country],
    COALESCE([promotion_ids], '') AS [promotion_id],
    COALESCE([fulfilled_by], '') AS [Fulfilled_by]
INTO #Amazon_Sales_Cleaned
FROM #Amazon_Sales;

SELECT *FROM #Amazon_Sales_Cleaned



--  top state wise total sales


WITH ct1 as (
    SELECT ship_state,sum(Amount) as totalsales FROM #Amazon_Sales_Cleaned
    GROUP BY ship_state
),ct2 as(
    SELECT *,row_number() OVER(ORDER BY totalsales DESC) as rk FROM ct1
)
SELECT * FROM ct2
where rk<=5


--  top 5 city wise total sales


WITH ct1 as (
    SELECT ship_city,sum(Amount) as totalsales FROM #Amazon_Sales_Cleaned
    GROUP BY ship_city
),
ct2 as (
    SELECT *,row_number() OVER(ORDER BY totalsales desc) as rk FROM ct1
)
SELECT * FROM ct2
WHERE rk<=5


-- top 5 category wise total sales

WITH ct1 as (
    SELECT category,sum(Amount) as totalsales FROM #Amazon_Sales_Cleaned
    GROUP BY category
),
ct2 as (
    SELECT *,row_number() OVER(ORDER BY totalsales desc)as rk FROM ct1
)
SELECT * FROM ct2
where rk<=5




--  category summary


SELECT 
ship_state,
ISNULL([Bottom],0)  Bottom,
ISNULL([Ethnic Dress],0) Ethnic,
ISNULL([kurta],0)  Kurta ,
ISNULL([Set],0)  Set_,
ISNULL([Top],0)  Top_,
ISNULL([Western Dress],0) as Wasten,
ISNULL([Bottom],0)+ISNULL([Ethnic Dress],0)+ISNULL([kurta],0)+ISNULL([Set],0)+ISNULL([Top],0)+ISNULL([Western Dress],0)as Grand_total

FROM(SELECT ship_state,category,sum(Amount) as totalsales FROM #Amazon_Sales_Cleaned
GROUP BY category,ship_state) as x
pivot (
    sum(totalsales)
    for  category in(
        [Bottom],
        [Ethnic Dress],
        [kurta],
        [Set],
        [Top],
        [Western Dress]
    )
)as p


--  qty  summary wise category and ship  state

SELECT 
ship_state,
ISNULL([Bottom],0)  Bottom,
ISNULL([Ethnic Dress],0) Ethnic,
ISNULL([kurta],0)  Kurta ,
ISNULL([Set],0)  Set_,
ISNULL([Top],0)  Top_,
ISNULL([Western Dress],0) as Wasten,
ISNULL([Bottom],0)+ISNULL([Ethnic Dress],0)+ISNULL([kurta],0)+ISNULL([Set],0)+ISNULL([Top],0)+ISNULL([Western Dress],0)as Grand_total
FROM (
    SELECT ship_state, category,sum(cast(Qty as int )) as totalqty from #Amazon_Sales_Cleaned
    GROUP BY category,ship_state
) as x
pivot(
    sum(totalqty)
    for category in (
        [Bottom],
        [Ethnic Dress],
        [kurta],
        [Set],
        [Top],
        [Western Dress]

    )
)as p1
ORDER BY Grand_total DESC



SELECT * FROM #Amazon_Sales_Cleaned





SELECT category,
ISNULL([3XL],0) AS [3XL],
ISNULL([4XL],0) AS [4XL],
ISNULL([6XL],0) AS [6XL],
ISNULL([L],0) AS [L],
ISNULL([M],0) AS [M],
ISNULL([S],0) AS [S],
ISNULL([XL],0) AS [XL],
ISNULL([XS],0) AS [XS],
ISNULL([3XL],0) +
ISNULL([4XL],0) +
ISNULL([6XL],0) +
ISNULL([L],0) +
ISNULL([M],0) +
ISNULL([S],0) +
ISNULL([XL],0) +
ISNULL([XS],0) AS [Grand_Total]
FROM(
    SELECT category,size,sum(Amount) as totalsales FROM #Amazon_Sales_Cleaned
    GROUP BY category,size
)as x
pivot(
    sum(totalsales)
    for size in (

        [3XL], [4XL], [6XL], [L], [M], [S], [XL], [XS]
    )
)as p



SELECT * FROM #Amazon_Sales_Cleaned

-- top 5 order that generated high sales 


WITH ct1 as (
    SELECT order_id,sum(Amount) as totalsales,sum(CAST(qty as int)) as totalqty FROM #Amazon_Sales_Cleaned
    GROUP BY [order_id]
),
ct2 as (
    SELECT *,row_number() OVER(ORDER BY totalsales desc) as Sales_rk  FROM ct1
)
SELECT * FROM ct2
WHERE Sales_rk<=5



