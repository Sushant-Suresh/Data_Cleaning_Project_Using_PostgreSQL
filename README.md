# Data Cleaning Project
![aiimg](https://github.com/user-attachments/assets/142c227c-9629-4060-b6af-114fc05a26b6)

In this project, I was using PostgreSQL to clean [Nashville Housing dataset](https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx). The Dataset has more than 56,000 rows and 19 columns.

The following tasks were performed:
- **Standardize "Sale Price" field into INT datatype**
- **Fill up the  NULL values in "address" field using self-join**
- **Parsing long-formatted address into individual columns (Address, City, State)**
- **Standardize “Sold as Vacant” field (from Y/N to Yes and No)**
- **Remove Duplicates**

## Schema
```sql
-- Creating `nashville` Table
DROP TABLE IF EXISTS nashville;
CREATE TABLE nashville (uniqueid INT, parcelid VARCHAR(80), landuse VARCHAR(80),
                        address VARCHAR(80), saledate DATE, saleprice VARCHAR(10),
                        legalreference VARCHAR(80), soldasvacant VARCHAR(5),	
                        ownername VARCHAR(80), owneraddress VARCHAR(80), acreage FLOAT,
                        taxdistrict VARCHAR(80), landvalue INT, buildingvalue INT, totalvalue INT,
                        yearbuilt INT, bedrooms INT, fullbath INT, halfbath INT);
```

## Overview of data
```sql
-- Querying the Table to See the Table Structure & Data
SELECT * FROM nashville;
```
**Output:**

![1](https://github.com/user-attachments/assets/215afb50-1830-4fc0-88b0-aab74eba5496)

## Standardize 'saleprice' column by converting it into INT datatype
```sql
-- While Importing the .csv file `saleprice` Column Couldn't be Imported as INT Datatype. Fixing This Issue:
					
-- Identifying Rows with Non-Integer Values
SELECT saleprice
FROM nashville
WHERE saleprice ~ '[^0-9]';
```
**Output:**

![3](https://github.com/user-attachments/assets/e04ee72d-9d2f-4c34-9810-b53731c26325)

```sql
-- Creating a New Column `saleprice_int`
ALTER TABLE nashville
ADD COLUMN saleprice_int INT;

-- Converting and Importing Data as INT Datatype
UPDATE nashville
SET saleprice_int = CAST(REGEXP_REPLACE(saleprice, '[^0-9]', '', 'g') AS INT);

-- Checking the output
SELECT saleprice, saleprice_int
FROM nashville
WHERE saleprice ~ '[^0-9]';
```
**Output:**

![5](https://github.com/user-attachments/assets/708d54a7-7b76-4419-8195-9544d2d24786)

```sql
-- Deleting the `saleprice` column
ALTER TABLE nashville
DROP COLUMN saleprice;
```

## Populate missing values in 'address' column
```sql
-- Entries With the Same `parcelid` Have the same `address`. I'll be Using this Information to Fill up NULL `address` Values:

-- Identifying Rows With NULL Values in `address` Column
SELECT *
FROM nashville
WHERE address IS NULL;
```
**Output:**

![6](https://github.com/user-attachments/assets/abe7246b-b702-456c-9a9e-2af15de72557)

```sql
-- Using SELF-JOIN to Populate the NULL `address` Values With an `address` Having the Same `parcelid`
SELECT a.parcelid, a.address,
       b.parcelid, b.address,
       COALESCE(a.address, b.address) AS address_notnull
FROM nashville AS a
JOIN nashville AS b
ON a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
WHERE a.address IS NULL;
```
**Output:**

![7](https://github.com/user-attachments/assets/ead3d7db-300d-4f3a-9e71-bfab7ccce0a9)

```sql
-- Updating the `address` Column
UPDATE nashville AS a
SET address = COALESCE(b.address, a.address)
FROM nashville AS b
WHERE a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
AND a.address IS NULL;
					
-- Checking the output
SELECT COUNT(*) AS address_null_count
FROM nashville
WHERE address IS NULL;
```
**Output:**

![8](https://github.com/user-attachments/assets/5a90c50d-b79a-44df-a620-fb9e1d0466c2)

## Breaking 'address' column into individual columns (address_, city)
```sql
-- Splitting Data Stored in the `address` Column Using the ',' Delimiter:

-- Adding the New Columns
ALTER TABLE nashville
ADD COLUMN address_ VARCHAR(80),
ADD COLUMN city VARCHAR(80);

-- Updating the New Columns
UPDATE nashville
SET address_ = LEFT(address, POSITION(',' IN address) - 1),
    city = TRIM(SUBSTRING(address FROM POSITION(',' IN address) + 1));

-- Checking the Results
SELECT address, address_, city
FROM nashville;
```
**Output:**

![9](https://github.com/user-attachments/assets/f2ccb2b9-c5fe-4aa6-9f07-dd1cc60800e2)

```sql
-- Deleting the `address` column
ALTER TABLE nashville
DROP COLUMN address;
```
## Breaking 'owneraddress' column into individual columns (owner_address, owner_city, owner_state)
```sql
-- Splitting Data Stored in the `owneraddress` Column Using the ',' Delimiter. This column has NULL values also:

-- Identifying NULL Values in `owneraddress` column
SELECT * FROM nashville
WHERE owneraddress IS NULL;
```
**Output:**

![10](https://github.com/user-attachments/assets/41d88997-b822-44dd-b10e-dd6f8a605233)

```sql
-- Adding the New Columns
ALTER TABLE nashville
ADD COLUMN owner_address VARCHAR(80),
ADD COLUMN owner_city VARCHAR(80),
ADD COLUMN owner_state VARCHAR(80);

-- Updating the New Columns
UPDATE nashville
SET owner_address = CASE
                        WHEN owneraddress IS NOT NULL THEN TRIM(SPLIT_PART(owneraddress, ',', 1))
                        ELSE NULL
                     END,
        owner_city = CASE
                         WHEN owneraddress IS NOT NULL THEN TRIM(SPLIT_PART(owneraddress, ',', 2))
                         ELSE NULL
                     END,
       owner_state = CASE
                         WHEN owneraddress IS NOT NULL THEN TRIM(SPLIT_PART(owneraddress, ' ', -1))
                         ELSE NULL
                     END;

-- Checking the Results
SELECT owneraddress, owner_address, owner_city, owner_state
FROM nashville;
```
**Output:**

![11](https://github.com/user-attachments/assets/015fb136-b91e-41ed-99aa-5f6bb73e51f3)

```sql
-- Deleting the `owneraddress` column
ALTER TABLE nashville

DROP COLUMN owneraddress;
```
## Standardize 'soldasvacant' column
```sql
-- In `soldasvacant` Column, There are 4 Values — Y, N, Yes, No — Instead of 2 - Yes and No. Fixing This Issue:

-- Checking the Data Stored in `soldasvacant` Column
SELECT soldasvacant, COUNT(*)
FROM nashville
GROUP BY soldasvacant;
```
**Output:**

![12](https://github.com/user-attachments/assets/b0de4a16-6fd8-479f-9a36-895c64062745)

```sql
-- Formatting Values - Y and N Into Yes and No Respectively. 
UPDATE nashville
SET SoldAsVacant =  CASE
                        WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
                        ELSE SoldAsVacant
                        END;

-- Checking the Results
SELECT soldasvacant, COUNT(*)
FROM nashville
GROUP BY soldasvacant;
```
**Output:**

![13](https://github.com/user-attachments/assets/7a983865-c8ac-4d1a-b01e-b50db859f2d6)

## Removing Duplicate Rows
```sql
/*
If `parcelid`, `address`, `saleprice_int`, `saledate`, & `legalreference` are the Same for Multiple Rows,
Then it is a Duplicate. I will be Uing This Information to Remove Duplicates:
*/

-- Identifying Duplicate Records
WITH ranked_rows AS (SELECT uniqueid, parcelid, address_, saleprice_int, saledate, legalreference,
                     ROW_NUMBER() OVER (PARTITION BY parcelid, address_, saleprice_int, saledate, legalreference
                     ORDER BY uniqueid) AS row_num
                     FROM nashville)
SELECT uniqueid, parcelid, address_, saleprice_int, saledate, legalreference
FROM ranked_rows
WHERE row_num > 1;
```
**Output:**

![14](https://github.com/user-attachments/assets/ad8af2ed-fa59-4699-9b26-ad1982e7ecc1)

```sql
-- Deleting Duplicate Records
WITH ranked_rows AS (SELECT uniqueid, parcelid, address_, saleprice_int, saledate, legalreference,
                     ROW_NUMBER() OVER (PARTITION BY parcelid, address_, saleprice_int, saledate, legalreference
                     ORDER BY uniqueid) AS row_num
                     FROM nashville)
DELETE FROM nashville
USING ranked_rows
WHERE nashville.uniqueid = ranked_rows.uniqueid
AND ranked_rows.row_num > 1;
```

## Results
- **A standard 'saleprice' column having values of only INT datatype**
- **An 'address' column with no NULL values**
- **Long-formatted address parsed into individual columns for both property address and owner address**
- **A standard 'soldasvacant' column (from Y/N to Yes and No)**
- **No duplicate entries**

### Having clean data will ultimately increase overall productivity and allow for the highest quality information in our decision-making.

All the SQL code used in this project can be found in the files above together with the raw dataset.




