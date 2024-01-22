--Cleaning Data in SQL Queries

Select *
From [Portfolio Project]..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, CONVERT(date,saledate)
From [Portfolio Project]..NashvilleHousing

UPDATE Nashvillehousing
SET SaleDate = CONVERT(date,Saledate)

--Above function did not work so, 

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE Nashvillehousing
SET SaleDateConverted = CONVERT(date,Saledate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From [Portfolio Project]..NashvilleHousing
--WHERE PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
From [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
From [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From [Portfolio Project]..NashvilleHousing
--WHERE PropertyAddress is null
--Order by ParcelID

SELECT
SUBSTRING( PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

From [Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE Nashvillehousing
SET PropertySplitAddress = SUBSTRING( PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) 


ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE Nashvillehousing
SET PropertySplitCity =  SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From [Portfolio Project]..NashvilleHousing


Select OwnerAddress
From [Portfolio Project]..NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.') ,3)
,PARSENAME(Replace(OwnerAddress, ',', '.') ,2)
,PARSENAME(Replace(OwnerAddress, ',', '.') ,1)
From [Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE Nashvillehousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.') ,3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE Nashvillehousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.') ,2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE Nashvillehousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.') ,1)


--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select DISTINCT(SoldAsVacant), COUNT(SoldasVacant)
From [Portfolio Project]..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldasVacant 
,CASE when SoldasVacant = 'Y' THEN 'Yes'
	when SoldasVacant = 'N' THEN 'No'
	ELSE SoldasVacant
	END
From [Portfolio Project]..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE when SoldasVacant = 'Y' THEN 'Yes'
	when SoldasVacant = 'N' THEN 'No'
	ELSE SoldasVacant
	END



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_Number() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference 
				 ORDER BY
					UniqueID
					) row_num

From [Portfolio Project].dbo.NashvilleHousing
--order by ParcelID
)
SELECT *
--DELETE
From RowNumCTE
WHERE row_num > 1
ORDER by PropertyAddress


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
GO


