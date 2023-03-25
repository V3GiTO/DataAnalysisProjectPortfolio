/*

Cleaning Data in SQL Queries

*/


Select *
From PortfolioProjectNashvilleHousing.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
Select SaleDateConverted, CONVERT(date,SaleDate) as Date
From PortfolioProjectNashvilleHousing..NashvilleHousing

ALTER table NashVilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(date, SaleDate)

-----------------------------------------------------------------------------------------------------------------------------------------

-- Poulate Property Address data
Select *
From PortfolioProjectNashvilleHousing.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjectNashvilleHousing.dbo.NashvilleHousing a
JOIN PortfolioProjectNashvilleHousing.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjectNashvilleHousing.dbo.NashvilleHousing a
JOIN PortfolioProjectNashvilleHousing.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null

-----------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProjectNashvilleHousing.dbo.NashvilleHousing


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
From PortfolioProjectNashvilleHousing.dbo.NashvilleHousing

ALTER Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


Select OwnerAddress
From PortfolioProjectNashvilleHousing.dbo.NashvilleHousing


Select
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
From PortfolioProjectNashvilleHousing.dbo.NashvilleHousing


ALTER Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

ALTER Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

ALTER Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)


-----------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProjectNashvilleHousing.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 END
From PortfolioProjectNashvilleHousing.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 END

-----------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER By UniqueID
				 ) row_num
From PortfolioProjectNashvilleHousing.dbo.NashvilleHousing
--Order By ParcelID
)
--Delete
Select *
From RowNumCTE
Where row_num > 1
--Order By PropertyAddress



-----------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProjectNashvilleHousing.dbo.NashvilleHousing


ALTER TABLE PortfolioProjectNashvilleHousing.dbo.NashvilleHousing
DROP Column OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProjectNashvilleHousing.dbo.NashvilleHousing
DROP Column SaleDate