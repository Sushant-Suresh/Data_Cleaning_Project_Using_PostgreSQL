# Data Cleaning Project
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
CREATE TABLE nashville (uniqueid INT, parcelid VARCHAR(80), landuse VARCHAR(80), address VARCHAR(80), 
                        saledate DATE, saleprice VARCHAR(10), legalreference VARCHAR(80), soldasvacant VARCHAR(5),	
                        ownername VARCHAR(80), owneraddress VARCHAR(80), acreage FLOAT, taxdistrict VARCHAR(80),
                        landvalue INT, buildingvalue INT, totalvalue INT, yearbuilt INT, bedrooms INT, fullbath INT, halfbath INT);
```

## Overview of data
```sql
-- Querying the Table to See the Table Structure & Data
SELECT * FROM nashville;
```
