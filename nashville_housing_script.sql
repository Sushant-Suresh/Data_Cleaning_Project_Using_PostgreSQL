-- Creating Database
CREATE DATABASE nashville_housing_project;

-- Creating `nashville` Table
DROP TABLE IF EXISTS nashville;
CREATE TABLE nashville (uniqueid INT, parcelid VARCHAR(80), landuse VARCHAR(80), address VARCHAR(80), 
                        saledate DATE, saleprice VARCHAR(10), legalreference VARCHAR(80), soldasvacant VARCHAR(5),	
						ownername VARCHAR(80), owneraddress VARCHAR(80), acreage FLOAT, taxdistrict VARCHAR(80), 
						landvalue INT, buildingvalue INT, totalvalue INT, yearbuilt INT, bedrooms INT, fullbath INT, halfbath INT);

-- Imported Data From .csv file

-- Querying the Table to See the Table Structure & Data
SELECT * FROM nashville;

-- Checking for Duplicates in `uniqueid` Column
SELECT COUNT(DISTINCT uniqueid)
FROM nashville;

-- Checking for NULL Values in `uniqueid` Column
SELECT * 
FROM nashville
WHERE uniqueid IS NULL;

-- Converting `uniqueid` Column into Primary Key
ALTER TABLE nashville
ADD CONSTRAINT nashville_pk PRIMARY KEY (uniqueid);

-- While Importing the .csv file `saleprice` Column Couldn't be Imported as INT Datatype. Fixing This Issue:
					
					-- Identifying Rows with Non-Integer Values
					SELECT saleprice
					FROM nashville
					WHERE saleprice ~ '[^0-9]';

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

					-- Deleting the `saleprice` column
					ALTER TABLE nashville
					DROP COLUMN saleprice;

-- Entries With the Same `parcelid` Have the same `address`. I will be Using this Information to Fill up NULL `address` Values:

					-- Identifying Rows With NULL Values in `address` Column
					SELECT *
					FROM nashville
					WHERE address IS NULL;
					 
					-- Using SELF-JOIN to Populate the NULL `address` Values With an `address` Having the Same `parcelid`
				    SELECT a.parcelid, a.address, 
					       b.parcelid, b.address, 
					       COALESCE(a.address, b.address) AS address_notnull
					FROM nashville AS a
					JOIN nashville AS b
					ON a.parcelid = b.parcelid
					AND a.uniqueid <> b.uniqueid
					WHERE a.address IS NULL;
					
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

					-- Deleting the `address` column
					ALTER TABLE nashville
					DROP COLUMN address;

-- Splitting Data Stored in the `owneraddress` Column Using the ',' Delimiter. This column has NULL values also:

					-- Identifying NULL Values in `owneraddress` column
					SELECT * FROM nashville
					WHERE owneraddress IS NULL;
					
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
                                            WHEN owneraddress IS NOT NULL THEN TRIM(SPLIT_PART(owneraddress, ' ', -1))  -- Get the last part for state
                                            ELSE NULL
                                        END;

					-- Checking the Results
					SELECT owneraddress, owner_address, owner_city, owner_state
					FROM nashville;

					-- Deleting the `owneraddress` column
					ALTER TABLE nashville
					DROP COLUMN owneraddress;

-- In `soldasvacant` Column, There are 4 Values — Y, N, Yes, No — Instead of 2 - Yes and No. Fixing This Issue:

					-- Checking the Data Stored in `soldasvacant` Column
					SELECT soldasvacant, COUNT(*)
					FROM nashville
					GROUP BY soldasvacant;

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

/*
If `parcelid`, `address`, `saleprice_int`, `saledate`, & `legalreference` are the Same for Multiple Rows, Then it is a Duplicate.
I will be Uing This Information to Remove Duplicates:
*/

					-- Identifying Duplicate Records
					WITH ranked_rows AS (SELECT uniqueid, parcelid, address_, saleprice_int, saledate, legalreference,
					                            ROW_NUMBER() OVER (PARTITION BY parcelid, address_, saleprice_int, saledate, legalreference
					                                               ORDER BY uniqueid) AS row_num
					                     FROM nashville)
					SELECT uniqueid, parcelid, address_, saleprice_int, saledate, legalreference
					FROM ranked_rows
					WHERE row_num > 1;

					-- Deleting Duplicate Records
					WITH ranked_rows AS (SELECT uniqueid, parcelid, address_, saleprice_int, saledate, legalreference,
					                            ROW_NUMBER() OVER (PARTITION BY parcelid, address_, saleprice_int, saledate, legalreference
					                                               ORDER BY uniqueid) AS row_num
					                     FROM nashville)
					DELETE FROM nashville
					USING ranked_rows
					WHERE nashville.uniqueid = ranked_rows.uniqueid
 					      AND ranked_rows.row_num > 1;

-- Done!
						  
				
					
										


  



					
