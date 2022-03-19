-- selecting database to work on.
use projectportfolio;

-- Reviewing data
select * 
from HousingDC;

-- Standerdised date format we want for data cleaning
select convert(date, SaleDate) 
from HousingDC;

-- Added column in existing table
alter table HousingDC
add SaleDateConverted date;

-- Updated standerdised dates in the created column.
update HousingDC
set SaleDateConverted = convert(date, SaleDate)

-- Property address data
select *
from HousingDC
where PropertyAddress is null;

-- Checking if parcel id and property address has interconnection and are same address is used according to parcel id.
-- Observation: Yes, property address and property id are interconnected.
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from HousingDC a
join HousingDC b
	on a.ParcelID = b.ParcelID -- getting same parcel id
	AND a.[UniqueID] <> b.[UniqueID] -- unique id should be distinct
where a.PropertyAddress is null

-- Filling NULL property address using selfjoin. Updated null values using isnull where property address is null. 
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from HousingDC a
join HousingDC b
	on a.ParcelID = b.ParcelID -- getting same parcel id
	and a.UniqueID <> b.UniqueID -- unique id should be distinct
where a.PropertyAddress is null;

-- Creating column with updated property address to get zero null values in address coulmn.
update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from HousingDC a
join HousingDC b
	on a.ParcelID = b.ParcelID -- getting same parcel id
	and a.UniqueID <> b.UniqueID -- unique id should be distinct
where a.PropertyAddress is null;

-- Checking where property address is null
select PropertyAddress
from HousingDC
where PropertyAddress is null;

-- Breaking address in the different fields to work on as Address, City and State.
	-- Used substring to get desired output from string.
	-- Used Charindex to define on what number delimeter(comma) is to get output
	-- Used -1 to remove delimeter (comma) from the output
	-- Used +1 to get to two delimeter (comma)
	-- Used len for getting length of property address
select PropertyAddress,
-- To seperate address
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as address, 
-- To separate city
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as City
from HousingDC;

-- Adding columns for property address in existing table
alter table HousingDC
add property_address nvarchar(100);

update HousingDC
set property_address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

-- Adding columns for city in existing table
alter table HousingDC
add Property_City nvarchar(100);

update HousingDC
set Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress));

-- Seperating owners address.
-- Used parsename amd replace to seperate by delimeter(,) and replace weith period(.).
select 
PARSENAME(replace(OwnerAddress, ',', '.'), 3) as owner_address,
PARSENAME(replace(OwnerAddress, ',', '.'), 2) as owner_city,
PARSENAME(replace(OwnerAddress, ',', '.'), 1) as owner_state
from HousingDC;

-- adding columns for owner address
alter table HousingDC
add 
owner_address nvarchar(100),
owner_city nvarchar(50),
owner_state nvarchar(50);

update HousingDC
set 
owner_address = PARSENAME(replace(OwnerAddress, ',', '.'), 3),
owner_city = PARSENAME(replace(OwnerAddress, ',', '.'), 2),
owner_state = PARSENAME(replace(OwnerAddress, ',', '.'), 1);

-- Checking count of Y/N and Yes/No for SoldAsVacant for selection
select distinct SoldAsVacant, count(SoldAsVacant)
from HousingDC
group by SoldAsVacant
order by 2;

-- For uniformity changing soldasvacant feild from Y/N to Yes/No because count is higher.
select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
	end
from HousingDC

-- Updating existing coulmn to add update changes of Soldasvacant feild
update HousingDC
set SoldAsVacant = 
	case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
	end;

-- Removing duplicates by writing CTE and few windows functions.
with RowNumCTE as
(select *,
ROW_NUMBER() over(partition by ParcelID, PropertyAddress,SalePrice, SaleDate, LegalReference
Order by UniqueID) row_num
from HousingDC)
-- 104 duplicate rows deleted
delete
from RowNumCTE
where row_num > 1;

-- Deleting unuseful columns from data
alter table HousingDC
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

-- Standerdised data for analysis
select *
from HousingDC;
