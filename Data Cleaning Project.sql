/*
Cleaning Data in SQL Queries
*/


select *
from portfolio_project.`nashville housing data for data cleaning (3)`;
-- -------------------------------------------------------

-- Standardize Data Format

Select SaleDate 
from portfolio_project.`nashville housing data for data cleaning (3)`;

Select SaleDate ,DATE_FORMAT(SaleDate, '%Y-%m-%d')
from portfolio_project.`nashville housing data for data cleaning (3)`;


update `nashville housing data for data cleaning (3)`
SET SaleDate = DATE_FORMAT(SaleDate, '%Y-%m-%d');


Alter Table  `nashville housing data for data cleaning (3)`
Add SaleDateConverted Date;

update `nashville housing data for data cleaning (3)`
SET SaleDateConverted = DATE_FORMAT(SaleDate, '%Y-%m-%d');

Select SaleDateConverted ,DATE_FORMAT(SaleDate, '%Y-%m-%d')
from portfolio_project.`nashville housing data for data cleaning (3)`;

-- ------------------------------------------------------
-- Populate Property Address data
Select PropertyAddress
from portfolio_project.`nashville housing data for data cleaning (3)`;


Select PropertyAddress
from portfolio_project.`nashville housing data for data cleaning (3)`
Where PropertyAddress is null;


Select *
from portfolio_project.`nashville housing data for data cleaning (3)`
-- Where PropertyAddress is NULL
order by ParcelID;


Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
from portfolio_project.`nashville housing data for data cleaning (3)` a
join portfolio_project.`nashville housing data for data cleaning (3)` b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID;

-- fill null value in PropertyAddress Column
Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ifnull(a.PropertyAddress,b.PropertyAddress)
from portfolio_project.`nashville housing data for data cleaning (3)` a
join portfolio_project.`nashville housing data for data cleaning (3)` b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;


-- update null value 

UPDATE portfolio_project.`nashville housing data for data cleaning (3)` a
JOIN portfolio_project.`nashville housing data for data cleaning (3)` b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;



-- ----------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from portfolio_project.`nashville housing data for data cleaning (3)`;

-- Split Text by ","

SELECT 
SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress) -1) AS Address
FROM portfolio_project.`nashville housing data for data cleaning (3)`;

SELECT 
SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress) +1) AS City
FROM portfolio_project.`nashville housing data for data cleaning (3)`;

-- Add split columns after update
Alter Table  `nashville housing data for data cleaning (3)`
Add PropertySplitAddress nvarchar(255);

update `nashville housing data for data cleaning (3)`
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress) -1) ;

Alter Table  `nashville housing data for data cleaning (3)`
Add PropertySplitCity nvarchar(255);

update `nashville housing data for data cleaning (3)`
SET PropertySplitCity = SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress) +1);

select *
from portfolio_project.`nashville housing data for data cleaning (3)`;

-- apply spliting in OwnerAddress Column
select OwnerAddress
from portfolio_project.`nashville housing data for data cleaning (3)`;

select 
parsename(replace(OwnerAddress,',','.'),1)
from portfolio_project.`nashville housing data for data cleaning (3)`;


SELECT 
SUBSTRING(OwnerAddress, 1, POSITION(',' IN OwnerAddress) -1) AS Address
,SUBSTRING(OwnerAddress, POSITION(',' IN OwnerAddress) +1 , POSITION(',' IN OwnerAddress)+10) AS City
FROM portfolio_project.`nashville housing data for data cleaning (3)`;

-- Add split columns after update
Alter Table  `nashville housing data for data cleaning (3)`
Add OwnerSplitAddress nvarchar(255);

update `nashville housing data for data cleaning (3)`
SET OwnerSplitAddress = SUBSTRING(OwnerAddress, 1, POSITION(',' IN OwnerAddress) -1);

Alter Table  `nashville housing data for data cleaning (3)`
Add OwnerSplitCity nvarchar(255);

update `nashville housing data for data cleaning (3)`
SET OwnerSplitCity = SUBSTRING(OwnerAddress, POSITION(',' IN OwnerAddress) +1 , POSITION(',' IN OwnerAddress)+10);

SELECT 
SUBSTRING(OwnerSplitCity, 1, POSITION(',' IN OwnerSplitCity) -1) AS City,
SUBSTRING(OwnerSplitCity, POSITION(',' IN OwnerSplitCity) +1 ) AS State
FROM portfolio_project.`nashville housing data for data cleaning (3)`;


Alter Table  `nashville housing data for data cleaning (3)`
Add OwnerSplitCity2 nvarchar(255);

update `nashville housing data for data cleaning (3)`
SET OwnerSplitCity2 = SUBSTRING(OwnerSplitCity, 1, POSITION(',' IN OwnerSplitCity) -1);

Alter Table  `nashville housing data for data cleaning (3)`
Add OwnerSplitState nvarchar(255);

update `nashville housing data for data cleaning (3)`
SET OwnerSplitState = SUBSTRING(OwnerSplitCity, POSITION(',' IN OwnerSplitCity) +1 );

select *
from portfolio_project.`nashville housing data for data cleaning (3)`;
-- -------------------------------------------------
-- Change Y and N  to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant)
from portfolio_project.`nashville housing data for data cleaning (3)`;

select SoldAsVacant
from portfolio_project.`nashville housing data for data cleaning (3)`
WHERE SoldAsVacant = 'Y'
or SoldAsVacant = 'N';


select distinct(SoldAsVacant) , count(SoldAsVacant)
from portfolio_project.`nashville housing data for data cleaning (3)`
group by SoldAsVacant;


select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END
from portfolio_project.`nashville housing data for data cleaning (3)`
WHERE SoldAsVacant = 'Y'
or SoldAsVacant = 'N';

UPDATE portfolio_project.`nashville housing data for data cleaning (3)`
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END;
       
select distinct(SoldAsVacant) , count(SoldAsVacant)
from portfolio_project.`nashville housing data for data cleaning (3)`
group by SoldAsVacant;
-- ------------------------------------------------
-- Remove Duplicates

-- إنشاء جدول مؤقت للصفوف المكررة
CREATE TEMPORARY TABLE temp_duplicate_cte AS
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY ParcelID,
                        PropertyAddress,
                        SalePrice,
                        SaleDate,
                        LegalReference
           ORDER BY UniqueID
       ) AS row_num
FROM portfolio_project.`nashville housing data for data cleaning (3)`;

-- حذف الصفوف المكررة من الجدول الأصلي
DELETE t1
FROM portfolio_project.`nashville housing data for data cleaning (3)` t1
JOIN temp_duplicate_cte t2 ON t1.UniqueID = t2.UniqueID
WHERE t2.row_num > 1;

-- حذف الجدول المؤقت
DROP TEMPORARY TABLE temp_duplicate_cte;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
				 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY UniqueID) AS row_num
FROM portfolio_project.`nashville housing data for data cleaning (3)`
order by ParcelID
)
SELECT *
FROM duplicate_cte
WHERE row_num >1
ORDER BY PropertyAddress;

-- ----------------------------------------------
-- Delete Unused Columns

SELECT *
FROM portfolio_project.`nashville housing data for data cleaning (3)`;

ALTER TABLE portfolio_project.`nashville housing data for data cleaning (3)`
DROP COLUMN SaleDate, DROP COLUMN OwnerAddress, DROP COLUMN TaxDistrict ,DROP COLUMN PropertyAddress,DROP COLUMN OwnerSplitCity;

ALTER TABLE portfolio_project.`nashville housing data for data cleaning (3)`
CHANGE OwnerSplitCity2 OwnerSplitCity varchar(255) ;


