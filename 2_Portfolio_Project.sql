 
-- 1. Count the customer base based on customer type to identify current customer preferences and sort them in descending order.
Select Count(C_ID)as CountC_ID,C_TYPE
FROM LogisticsBase..Customers 
Group by C_TYPE
Order by Count(C_ID) desc

-- 2. Count the customer base based on their status of payment in descending order.

Select Count (C_ID)as CountC_ID,Payment_Status
FROM LogisticsBase.[dbo].[Payment_Details]
Group by [Payment_Status]
Order by Count(C_ID) desc

Select [Payment_Status], Count (C_ID), OVER (Partition by [Payment_Status]) as CustomersAmount
FROM LogisticsBase.[dbo].[Payment_Details] as Cust
Order by CustomersAmount desc

-- 3. Count the customer base based on their payment mode in descending order of count. 
Select Count (C_ID)as CountC_ID,[Payment_Mode]
FROM LogisticsBase.[dbo].[Payment_Details]
Group by [Payment_Mode]
Order by Count(C_ID) desc

-- 4. Count the customers as per shipment domain in descending order. 
Select Count (C_ID)as CountC_ID,[SH_DOMAIN]
from [LogisticsBase].[dbo].[Shipment_Details]
group by [SH_DOMAIN]
Order by Count(C_ID) desc


-- 5. Count the customer according to service type in descending order of count. 

Select Count (C_ID)as CountC_ID,[SER_TYPE]
from [LogisticsBase].[dbo].[Shipment_Details]
group by [SER_TYPE]
Order by Count(C_ID) desc

-- 6. Explore employee count based on the designation-wise count of employees' IDs in descending order. 
Select Count([E_ID])as CountE_ID,[E_DESIGNATION]
from [LogisticsBase].[dbo].[Employee_Details]
group by[E_DESIGNATION]
Order by Count([E_ID]) desc


-- 7. Branch-wise count of employees for efficiency of deliveries in descending order. 

With CTE_Employee as (
Select [E_ID],[E_BRANCH],[Employee_E_ID],[Shipment_Sh_ID]
From [LogisticsBase].[dbo].[Employee_Details]
Inner Join [LogisticsBase].[dbo].[employee_manages_shipment]
On [Employee_Details].[E_ID]=[employee_manages_shipment].[Employee_E_ID]
)

Select [Shipment_Sh_ID],[E_BRANCH],COUNT(CASE WHEN [Current_Status] = 'DELIVERED' THEN 1 ELSE NULL END) AS DeliveredCount
From [LogisticsBase].[dbo].[Status]
Inner Join [CTE_Employee]
On [Status].[SH_ID] = CTE_Employee.[Shipment_Sh_ID]
Group by [E_BRANCH],[Shipment_Sh_ID]
Order by DeliveredCount desc



-- 8. Finding C_ID, M_ID, and tenure for those customers whose membership is over 10 years. 

Select c.[C_ID],m.[M_ID], DATEDIFF(YEAR, Start_date, End_date) AS YearsDifference
From [LogisticsBase].[dbo].[Customers]as c
Inner Join [LogisticsBase].[dbo].[Membership] as m
On c.[M_ID]=m.[M_ID]
Group by c.C_ID, m.M_ID,Start_date, End_date
Having DATEDIFF(YEAR, Start_date, End_date) > 10
Order by DATEDIFF(YEAR, Start_date, End_date) desc


-- 9. Considering average payment amount based on customer type having payment mode as COD in descending order. 

Select Distinct Cus.[C_TYPE],P.[Payment_Mode], AVG (P.[AMOUNT])as AVG_AMOUNT
From [LogisticsBase].[dbo].[Customers]as Cus
Inner Join [LogisticsBase].[dbo].[Payment_Details]as P
On Cus.[C_ID]=P.[C_ID]
Group by Cus.[C_TYPE],P.[Payment_Mode]
HAVING MAX(CASE WHEN P.[Payment_Mode] = 'COD' THEN 1 ELSE 0 END) = 1
Order by AVG_AMOUNT desc



-- 10. Calculate the average payment amount based on payment mode where the payment date is not null.

Select [Payment_Mode],[PaymentDateConverted],AVG ([AMOUNT])as AVG_AMOUNT
From [LogisticsBase].[dbo].[Payment_Details]
Where [PaymentDateConverted] is not null
Group by[Payment_Mode],[PaymentDateConverted]
Order by AVG_AMOUNT desc

ALTER TABLE [LogisticsBase].[dbo].[Payment_Details]
Add PaymentDateConverted Date

UPDATE [LogisticsBase].[dbo].[Payment_Details]
SET PaymentDateConverted = Convert(Date, Payment_date)
	





-- 11. Calculate the average shipment weight based on payment_status where shipment content does not start with "H."
-- 12. Retrieve the names and designations of all employees in the 'NY' E_Branch.
-- 13. Calculate the total number of customers in each C_TYPE (Wholesale, Retail, Internal Goods).
-- 14. Find the membership start and end dates for customers with 'Paid' payment status.
-- 15. List the clients who have made 'Card Payment' and have a 'Regular' service type.
-- 16. Calculate the average shipment weight for each shipment domain (International and Domestic).
-- 17. Identify the shipment with the highest charges and the corresponding client's name.
-- 18. Count the number of shipments with the 'Express' service type that are yet to be delivered.
-- 19. List the clients who have 'Not Paid' payment status and are based in 'CA'.
-- 20. Retrieve the current status and delivery date of shipments managed by employees with the designation 'Delivery Boy'.
-- 21. Find the membership start and end dates for customers whose 'Current Status' is 'Not Delivered'.
[dbo].[Membership]
[dbo].[Customers]
[dbo].[Shipment_Details]
[dbo].[Status]
SELECT
    M.[M_ID],CAST(GETDATE([Start_date],[End_date]) AS DATE) AS DateWithoutTime;
    --C.*,
    --Sh.*,
    St.[Current_Status]
FROM
    [LogisticsBase].[dbo].[Membership] AS M
INNER JOIN
    [LogisticsBase].[dbo].[Customers] AS C ON M.[M_ID] = C.[M_ID]
INNER JOIN
    [LogisticsBase].[dbo].[Shipment_Details] AS Sh ON C.[C_ID] = Sh.[C_ID]
INNER JOIN
    [LogisticsBase].[dbo].[Status] AS St ON Sh.[SH_ID] = St.[SH_ID]
	where St.[Current_Status] ='not DELIVERED'


	SELECT
    M.[M_ID],
    CAST(M.[Start_date] AS DATE) AS StartDateWithoutTime,
    CAST(M.[End_date] AS DATE) AS EndDateWithoutTime,
    -- Other columns from Membership, Customers, Shipment_Details, and Status tables as needed
    St.[Current_Status]
FROM
    [LogisticsBase].[dbo].[Membership] AS M
INNER JOIN
    [LogisticsBase].[dbo].[Customers] AS C ON M.[M_ID] = C.[M_ID]
INNER JOIN
    [LogisticsBase].[dbo].[Shipment_Details] AS Sh ON C.[C_ID] = Sh.[C_ID]
INNER JOIN
    [LogisticsBase].[dbo].[Status] AS St ON Sh.[SH_ID] = St.[SH_ID]
WHERE
    St.[Current_Status] = 'not DELIVERED';

	;--______________________________________________



	--_______________________________________

Create table #temp_sheet (
EmployeeID int,
Jobtitle varchar (100),
Salary int   
)
Select *
From #temp_sheet

Insert into #temp_sheet Values 
(95,'text',2000),
(93,'text',2430)