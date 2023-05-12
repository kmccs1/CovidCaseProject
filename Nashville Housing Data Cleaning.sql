/*  

Cleaning Data in SQL Queries

*/


SELECT * 
FROM PortfolioProject..NashvilleHousing

-------------------------------------------------------------


-- Standardize Date Format

SELECT saledate, CONVERT(date,saledate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET saledate = CONVERT(date,saledate)



--Alternative Method

ALTER TABLE Nashvillehousing
ADD SaleDateConverted date; 

UPDATE NashvilleHousing
SET saledateconverted = CONVERT(date,saledate)



-- Populate Property Address Data

SELECT *
FROM portfolioproject..NashvilleHousing
--WHERE propertyaddress IS NULL 
ORDER BY parcelid


--ParcelIds Have Same Address

SELECT t1.parcelID, t1.PropertyAddress, t2.ParcelID, t2.PropertyAddress, ISNULL (t1.propertyaddress, t2.PropertyAddress)
FROM portfolioproject..NashvilleHousing t1
JOIN portfolioproject..NashvilleHousing t2
	ON t1.parcelID = t2.parcelID
	AND t1.[UniqueID ] <> t2.[UniqueID ]
WHERE t1.PropertyAddress IS NULL


UPDATE t1
SET PropertyAddress = ISNULL (t1.propertyaddress, t2.PropertyAddress)
FROM portfolioproject..NashvilleHousing t1
JOIN portfolioproject..NashvilleHousing t2
	ON t1.parcelID = t2.parcelID
	AND t1.[UniqueID ] <> t2.[UniqueID ]
WHERE t1.PropertyAddress IS NULL



-- Breaking Out Address into Individual Columns  (Address, City, State)

SELECT 
SUBSTRING(propertyaddress, 1, CHARINDEX(',',propertyaddress)-1) as Address,
SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress)+1, LEN(propertyaddress)) as Address
FROM portfolioproject..NashvilleHousing

--Need to add 2 columns for split data

ALTER TABLE Nashvillehousing
ADD propertysplitaddress nvarchar(255); 

UPDATE NashvilleHousing
SET propertysplitaddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',',propertyaddress)-1)


ALTER TABLE Nashvillehousing
ADD propertysplitcity nvarchar(255); 

UPDATE NashvilleHousing
SET propertysplitcity = SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress)+1, LEN(propertyaddress))



SELECT *
FROM portfolioproject..NashvilleHousing

--Altering OwnerAddress

SELECT owneraddress
FROM  PortfolioProject..NashvilleHousing


SELECT
PARSENAME(REPLACE(owneraddress,',','.'),3),
PARSENAME(REPLACE(owneraddress,',','.'),2),
PARSENAME(REPLACE(owneraddress,',','.'),1)
FROM  PortfolioProject..NashvilleHousing


ALTER TABLE Nashvillehousing
ADD Ownersplitaddress nvarchar(255); 

UPDATE NashvilleHousing
SET Ownersplitaddress = PARSENAME(REPLACE(owneraddress,',','.'),3)


ALTER TABLE Nashvillehousing
ADD Ownersplitcity nvarchar(255); 

UPDATE NashvilleHousing
SET Ownersplitcity = PARSENAME(REPLACE(owneraddress,',','.'),2)


ALTER TABLE Nashvillehousing
ADD Ownersplitstate nvarchar(255); 

UPDATE NashvilleHousing
SET Ownersplitstate = PARSENAME(REPLACE(owneraddress,',','.'),1)

SELECT *
FROM PortfolioProject..NashvilleHousing


--Change Y and N to Yes/No in Sold as Vacant Field

SELECT DISTINCT (soldasvacant), COUNT(soldasvacant)
FROM  PortfolioProject..NashvilleHousing
GROUP BY soldasvacant
ORDER BY 2


SELECT soldasvacant,
	CASE WHEN soldasvacant = 'N' THEN 'No'
	WHEN soldasvacant = 'Y' THEN 'Yes'
	ELSE soldasvacant
	END
FROM PortfolioProject..NashvilleHousing


UPDATE PortfolioProject..NashvilleHousing
SET soldasvacant = CASE WHEN soldasvacant = 'N' THEN 'No'
	WHEN soldasvacant = 'Y' THEN 'Yes'
	ELSE soldasvacant
	END


-- Remove Duplicates

WITH rownumcte AS (
	SELECT *, 
	ROW_NUMBER() OVER (PARTITION BY parcelID, propertyaddress, saleprice, saledate, legalreference ORDER BY uniqueid) row_num
	FROM PortfolioProject..NashvilleHousing
	)

DELETE
FROM rownumcte
where row_num >1 



-- Delete Unused Columns


SELECT *
FROM portfolioproject..NashvilleHousing


ALTER TABLE portfolioproject..NashvilleHousing
DROP COLUMN owneraddress, taxdistrict, propertyaddress

ALTER TABLE portfolioproject..NashvilleHousing
DROP COLUMN saledate
