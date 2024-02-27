-- 1. Count the customer base based on customer type to identify current customer preferences and sort them in descending order.

Select C_ID ,C_NAME, C_TYPE
From LogisticsBase.dbo.Customers
Group by C_ID ,C_NAME, C_TYPE
Order by C_TYPE desc



-- 2. Count the customer base based on their status of payment in descending order. 

Select Cust.C_ID ,Pay.C_ID, Cust.C_NAME, Pay.Payment_Status
From LogisticsBase..Customers as Cust
Full Outer Join LogisticsBase..Payment_Details as Pay
On Cust.C_ID = Pay.C_ID
Group by Cust.C_ID , Cust.C_NAME, Pay.Payment_Status,Pay.C_ID
Order by Pay.Payment_Status desc

-- 3. Count the customer base based on their payment mode in descending order of count

Select Cust.C_ID , Cust.C_NAME, Pay.Payment_Status, Pay.Payment_Mode
From LogisticsBase..Customers as Cust
Inner Join LogisticsBase..Payment_Details as Pay
On Cust.C_ID = Pay.C_ID
Group by Cust.C_ID , Cust.C_NAME, Pay.Payment_Status,Pay.Payment_Mode
Order by Pay.Payment_Mode desc


-- 4. Count the customers as per shipment domain in descending order. 

Select Distinct(Ship.SH_DOMAIN),  Count (Cust.C_ID) OVER (Partition by Ship.SH_DOMAIN) as CustomersAmount
From LogisticsBase..Customers as Cust
Right Join LogisticsBase..Shipment_Details as Ship
On Cust.C_ID = Ship.C_ID
Order by CustomersAmount desc


Select Distinct(Ship.SH_DOMAIN),  Count (DISTINCT Cust.C_ID) as CustomersAmount
From LogisticsBase..Customers as Cust
Right Join LogisticsBase..Shipment_Details as Ship
On Cust.C_ID = Ship.C_ID
Group by Ship.SH_DOMAIN
Order by CustomersAmount desc


-- 5. Count the customer according to service type in descending order of count.

Select Distinct(Ship.SER_TYPE),  Count (Cust.C_ID) as CustomersPerService
From LogisticsBase..Customers as Cust
Right Join LogisticsBase..Shipment_Details as Ship
On Cust.C_ID = Ship.C_ID
Group by Ship.SER_TYPE
Order by CustomersPerService desc

-- 6. Explore employee count based on the designation-wise count of employees' IDs in descending order. 

Select *
From Employee_Details

Select Distinct E_DESIGNATION, Count (E_ID)  as EmployeePerPosition
From Employee_Details
Group by E_DESIGNATION
Order by Count (E_ID) desc

-- 7. Branch-wise count of employees for efficiency of deliveries in descending order.

Select *
From Status

Select Delivery_date, Sent_date, Convert(Date,Delivery_date)  as DeliveryDateConverted, Convert(Date,Sent_date) as SentDateConverted 
From Status

ALTER TABLE Status
Add SentDateConverted Date,
	DeliveryDateConverted Date;

UPDATE Status
SET SentDateConverted = Convert(Date, Sent_date),
	DeliveryDateConverted = Convert(Date, Delivery_date);

ALTER TABLE Status
DROP COLUMN  Delivery_date, Sent_date


Select *
From Employee_manages_shipment


With CTE_Efficiency as (
Select Manage.Employee_E_ID, Status.Current_Status,
Case
When Current_Status = 'Delivered' then 1
Else 0
END AS CountStatus
From LogisticsBase..Status as Status
Inner Join LogisticsBase..employee_manages_shipment as Manage
On Status.SH_ID = Manage.Shipment_Sh_ID
)

Select Distinct Employee_E_ID, Sum (CountStatus) as DeliveryAmount
From CTE_Efficiency
Group by Employee_E_ID
Having Sum (CountStatus)>=0
Order by Sum (CountStatus) desc


-- 8. Finding C_ID, M_ID, and tenure for those customers whose membership is over 10 years. 

SELECT Cust.C_ID, Memb.M_ID, DATEDIFF(YEAR, Start_date, End_date) AS YearsDifference
From LogisticsBase..Customers as Cust
Inner Join  LogisticsBase..Membership as Memb
On Cust.M_ID = Memb.M_ID
Group by Cust.C_ID, Memb.M_ID,Start_date, End_date
Having DATEDIFF(YEAR, Start_date, End_date) > 10 
Order by DATEDIFF(YEAR, Start_date, End_date) desc


-- 9. Considering average payment amount based on customer type having payment mode as COD in descending order.

Select  Distinct Cust.C_TYPE, Pay.Payment_Mode, Avg(Pay.Amount) OVER (Partition by Cust.C_TYPE) as AverageSalary 
From LogisticsBase..Payment_Details as Pay
Inner Join LogisticsBase..Customers as Cust
On Pay.C_ID = Cust.C_ID
Where Pay.Payment_Mode = 'COD'


-- 10. Calculate the average payment amount based on payment mode where the payment date is not null. 

Select Payment_Mode,Payment_Date, Avg (AMOUNT) as AveragePay
From LogisticsBase..Payment_Details
Where Payment_date is not null
Group by Payment_Mode,Payment_Date, AMOUNT
Order by AveragePay desc


-- 11. Calculate the average shipment weight based on payment_status where shipment content does not start with "H."

Select *
From LogisticsBase..Payment_Details

Select *
From LogisticsBase..Shipment_Details

Select Ship.SH_CONTENT, Pay.Payment_Status, Avg (Ship.SH_WEIGHT) as AvgWeight
From LogisticsBase..Shipment_Details as Ship
Inner Join LogisticsBase..Payment_Details as Pay
On Ship.SH_ID = Pay.SH_ID
WHERE NOT LTRIM(RTRIM(Ship.SH_CONTENT)) LIKE 'H%'
Group by Pay.Payment_Status, Ship.SH_CONTENT
Order by Avg (SH_WEIGHT) desc 

-- 12. Retrieve the names and designations of all employees in the 'NY' E_Branch.

Select E_NAME, E_DESIGNATION, E_BRANCH
From LogisticsBase..Employee_Details
Where E_BRANCH = 'NY'

-- 13. Calculate the total number of customers in each C_TYPE (Wholesale, Retail, Internal Goods).

Select Distinct C_TYPE,  Count (C_ID) OVER (Partition by C_TYPE ) as Customers_Amount 
From LogisticsBase..Customers

-- 14. Find the membership start and end dates for customers with 'Paid' payment status.

With CTE_Status_Date as (
Select Cust.C_ID, Memb.Start_date, Memb.End_date
From LogisticsBase..Customers as Cust
Inner Join  LogisticsBase..Membership as Memb
On Cust.M_ID = Memb.M_ID
)
Select CTE.C_ID, CTE.Start_date, CTE.End_date, Pay.Payment_Status
From CTE_Status_Date as CTE
Inner Join LogisticsBase..Payment_Details as Pay
ON CTE.C_ID = Pay.C_ID
Where Pay.Payment_Status = 'Paid' 

-- 15. List the clients who have made 'Card Payment' and have a 'Regular' service type.

Create table #temp_sheet (
Cust_C_ID varchar (100),
Cust_C_NAME varchar (100),
Pay_Payment_Mode varchar (100) 
)
Insert into #temp_sheet
Select Cust.C_ID, Cust.C_NAME, Pay.Payment_Mode
From LogisticsBase..Customers as Cust
Inner Join LogisticsBase..Payment_Details as Pay
On Cust.C_ID = Pay.C_ID

Select Cust_C_ID, Cust_C_NAME, Pay_Payment_Mode, ship.SER_TYPE
From #temp_sheet as temp
Inner Join LogisticsBase..Shipment_Details as ship
On temp.Cust_C_ID = ship.C_ID
Where ship.SER_TYPE = 'Regular'
AND Pay_Payment_Mode = 'CARD PAYMENT'


-- 16. Calculate the average shipment weight for each shipment domain (International and Domestic).

Select Distinct SH_DOMAIN, Avg (SH_WEIGHT) OVER (Partition by SH_DOMAIN) as AvgWeightDomain
From LogisticsBase..Shipment_Details


-- 17. Identify the shipment with the highest charges and the corresponding client's name.

Select Cust_C_ID, Cust_C_NAME, MAX(SH_CHARGES) as HighestCharges
From #temp_sheet as temp
Inner Join LogisticsBase..Shipment_Details as ship
On temp.Cust_C_ID = ship.C_ID
Group by Cust_C_ID, Cust_C_NAME
Order by HighestCharges desc


-- 18. Count the number of shipments with the 'Express' service type that are yet to be delivered.

Select ship.SER_TYPE, Status.Current_Status, Count(ship.SH_ID) as AmountExpress
From LogisticsBase..Shipment_Details as ship
Inner Join LogisticsBase..Status as Status
On ship.SH_ID = Status.SH_ID
Where ship.SER_TYPE = 'Express'
And Status.Current_Status = 'Delivered'
Group by ship.SER_TYPE,Status.Current_Status

-- 19. List the clients who have 'Not Paid' payment status and are based in 'CA'.

--First way
With CTE_ADRESS AS (
Select Manage.Employee_E_ID, Emp.E_BRANCH, Manage.Shipment_Sh_ID
From LogisticsBase..Employee_Details as Emp
Inner Join LogisticsBase..employee_manages_shipment as Manage
On Manage.Employee_E_ID = Emp.E_ID
)
Select Pay.C_ID, Pay.Payment_Status, CTE.E_BRANCH
From CTE_ADRESS as CTE
Inner Join LogisticsBase..Payment_Details as Pay
On CTE.Shipment_Sh_ID = Pay.SH_ID
Where Pay.Payment_Status = 'Not Paid'
And CTE.E_BRANCH = 'CA'

-- Second way we could use data cleaning and split adress and define state, but we do not have noticed state
-- in the column so cannot identify adress 



-- 20. Retrieve the current status and delivery date of shipments managed by employees with the designation 'Delivery Boy'.

With CTE_Designation AS (
Select Manage.Employee_E_ID, Emp.E_DESIGNATION, Manage.Shipment_Sh_ID
From LogisticsBase..Employee_Details as Emp
Inner Join LogisticsBase..employee_manages_shipment as Manage
On Manage.Employee_E_ID = Emp.E_ID
)

Select Status.SH_ID, Status.DeliveryDateConverted, Status.Current_Status, CTE.E_DESIGNATION 
From CTE_Designation as CTE
Inner Join LogisticsBase..Status as Status
On CTE.Shipment_Sh_ID = Status.SH_ID
Where CTE.E_DESIGNATION = 'Delivery Boy'
--And Status.DeliveryDateConverted is not null

-- 21. Find the membership start and end dates for customers whose 'Current Status' is 'Not Delivered'.

Create table #temp_member(
M_ID int,
M_start_date date,
M_end_date date ,
C_ID int 
)
Insert into #temp_member
Select Memb.M_ID, Memb.Start_date, Memb.End_date, Cust.C_ID
From LogisticsBase..Membership as Memb
Inner Join LogisticsBase..Customers as Cust
On Memb.M_ID = Cust.M_ID


Create table #temp_status(
Status_SH_ID int,
Current_Status varchar(100),
Ship_SH_ID	int,
Ship_C_ID int 
)
Insert into #temp_status
Select Status.SH_ID, Status.Current_Status, Ship.SH_ID, Ship.C_ID
From LogisticsBase..Status as Status
Inner Join LogisticsBase..Shipment_Details as Ship
On Status.SH_ID = Ship.SH_ID

Select M.C_ID, M.M_start_date, M.M_end_date, S.Current_Status
From #temp_member M
Inner Join #temp_status S
On M.C_ID = S.Ship_C_ID
Where S.Current_Status = 'Not Delivered'
