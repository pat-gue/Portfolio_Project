-- Cleaning Data in SQL Queries
SELECT
	*
FROM dbo.NashvilleHousing;


-- Standardize date format
SELECT
	SaleDate,
	CAST(SaleDate AS DATE) AS Date
FROM dbo.NashvilleHousing;


UPDATE dbo.NashvilleHousing
SET SaleDate = CAST(SaleDate AS DATE); -- Didn't work


ALTER TABLE dbo.NashvilleHousing
ADD SaleDateConvert DATE;

UPDATE dbo.NashvilleHousing
SET SaleDateConvert = CAST(SaleDate AS DATE);


SELECT
	SaleDateConvert
FROM dbo.NashvilleHousing;

-- Populate Property Address Data
-- Maglagay ng Data sa mga NULL Values

SELECT
	*
FROM dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelId;

SELECT
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress) -- gamit ISNULL to populate columns using info from same column with the infos
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) -- can even write ISNULL(a.PropertyAddress, 'No Address')
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;



-- Breaking out address into individual Columns(Address, City, State)

SELECT
	PropertyAddress
FROM dbo.NashvilleHousing;

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,  -- SUBSTRING gamitin para ihiwalay, 1(index 1 = start)
	-- CHARINDEX para maghanap ng delimiter kung san ihiwalay. -1, para sabihin sa SQL na wag isama ang delimiter sa query result.
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City -- same pero yung index, nagstart sa 
	-- CHARINDEX, copypaste pero imbes na -1 use +1. -1 for delimiter u c after, +1 delimiter u c before.
	-- Gamit ang LEN() kasi di mo alam ang index after
FROM dbo.NashvilleHousing;

ALTER TABLE dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);



UPDATE dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);



ALTER TABLE dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);



UPDATE dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));


SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress, -- PARSENAME mas madaling maghiwalay sa string. use REPLACE pag 
	-- hindi period ang delimiter. bale PARSENAME(REPLACE("STRING", 'yung ipapalit(,)', 'period'(.)), 1) pagmadami  3, 2, 1 basta 
	-- baliktad ang result kaya baliktad din paglagay ng number
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerCity,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerState
FROM dbo.NashvilleHousing;

ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);


ALTER TABLE dbo.NashvilleHousing
ADD OwnerCity NVARCHAR(255);

UPDATE dbo.NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);


ALTER TABLE dbo.NashvilleHousing
ADD OwnerState NVARCHAR(255);

UPDATE dbo.NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);



-- Change Y and N to Yes and No to SoldasVacant column

SELECT
	SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM dbo.NashvilleHousing;

--
UPDATE dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END;


-- REMOVE DUPLICATES

WITH RowNumCTE AS (
SELECT
	*,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelId, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueId
					) row_num
FROM dbo.NashvilleHousing
)
DELETE				
FROM RowNumCTE
WHERE row_num > 1
;


-- DELETE UNUSED COLUMNS

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

