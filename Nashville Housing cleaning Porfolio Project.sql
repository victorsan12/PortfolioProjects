/*
Cleaning Data in SQL Queries
*/


Select *
From PortfolioProject..NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
Select saleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data where property address is null

SELECT *
FROM PortfolioProject..NashvilleHousing
Order by parcelID

-- We can use the address that are in duplicate fields with the parcelID and fill the null property address 

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.propertyaddress, b.propertyaddress)
FROM PortfolioProject..NashvilleHousing as A
JOIN PortfolioProject..NashvilleHousing as B ON
	A.ParcelID = B.ParcelID
	AND A.[UniqueID] <> b.[UniqueID]
WHERE A.propertyaddress is null

UPDATE A
SET PropertyAddress = ISNULL(A.propertyaddress, b.propertyaddress)
FROM PortfolioProject..NashvilleHousing as A
JOIN PortfolioProject..NashvilleHousing as B ON
	A.ParcelID = B.ParcelID
	AND A.[UniqueID] <> b.[UniqueID]
WHERE A.propertyaddress is null
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State) using SUBSTRING and PARSENAME

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing

--Split the Owner Address

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

-- Lets use Parsename now
Select
PARSENAME(OwnerAddress, 1)
From PortfolioProject.dbo.NashvilleHousing

--Parsename looks for periods and have to replace "," with periods
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
)
-- Deleted with the following queries

--DELETE
--From RowNumCTE
--Where row_num > 1

SELECT *
FROM RowNumCTE
WHERE row_num > 1
Order by PropertyAddress

-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns
Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


