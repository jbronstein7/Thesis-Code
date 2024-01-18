********************************************************************************
* Title: USDA Data Arranging 
* Author: Joe Bronstein
* Purpose: To clean and aggregate USDA NASS data to merge into larger dataset
* Last Modified: 1/18/2024
* Assumes: All USDA NASS files have been downloaded, and are in a directory 
********************************************************************************
	di c(hostname) 

		if "`c(hostname)'" == "AREC-ATHNOS" {
				cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein\USDA Raw Datasets\"
				}


		if "`c(hostname)'" == "JBRON-DESKTOP" {
				cd "\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data\USDA Raw Datasets"
				}
				
*************************************
* Age 
*************************************
// Importing first Age dataset
	import delimited "1997_2012_AvgAge.csv", clear 
	save "1997_2012_AvgAge.dta", replace

// Importing second dataset
	import delimited "2017_AvgAge.csv", clear
	save "2017_AvgAge.dta", replace

// Appending datasets and dropping unecessary variables 
	append using "1997_2012_AvgAge.dta"
	keep year state value 

// Formatting state variable to get abbreviation
	statastates, name(state)
	
// Changing state to str# for merging purposes
	gen str20 state_str = state_abbrev
	keep year value state_str
	rename state_str state
	order state year value 

// Changing value to avg age
	rename value age 
	sort state year
	save "clean_age.dta", replace
	
*************************************
* Dairy Operations
*************************************
// Importing first Age dataset
	import delimited "1970_2022_DairyOperations.csv", clear 
	save "1970_2022_DairyOperations.dta", replace

// Formatting state variable to get abbreviation
	statastates, name(state)
	
// Changing state to str# for merging purposes
	gen str20 state_str = state_abbrev
	keep year value state_str
	rename state_str state
	order state year value 

// Dropping years we don't need 
	drop if year < 1997

// Changing value to avg age
	rename value DairyOperations 
	sort state year
	save "clean_dairy.dta", replace
	
*************************************
* Ethnicity and Gender 
*************************************
// Importing first dataset
	import delimited "1997_2012_EthnicityGender.csv", clear 
	save "1997_2012_EthnicityGender.dta", replace

// Importing second dataset
	import delimited "2017_EthnicityGender.csv", clear
	save "2017_EthnicityGender.dta", replace

// Appending datasets and dropping unecessary variables 
	append using "1997_2012_EthnicityGender.dta"
	keep if domain == "TOTAL"
	destring dataitem, replace
	keep year state dataitem value

// New Variables
	gen NumAsian = value if dataitem == "PRODUCERS, PRINCIPAL, ASIAN - NUMBER OF OPERATIONS" | dataitem == "OPERATORS, PRINCIPAL, ASIAN - NUMBER OF OPERATIONS"
	gen NumAfricanAmerican = value if dataitem == "PRODUCERS, PRINCIPAL, BLACK OR AFRICAN AMERICAN - NUMBER OF OPERATIONS" | dataitem == "OPERATORS, PRINCIPAL, BLACK OR AFRICAN AMERICAN - NUMBER OF OPERATIONS"
	gen NumHispanic = value if dataitem == "PRODUCERS, PRINCIPAL, HISPANIC - NUMBER OF OPERATIONS" | dataitem == "OPERATORS, PRINCIPAL, HISPANIC - NUMBER OF OPERATIONS"
	gen NumMulti = value if dataitem == "PRODUCERS, PRINCIPAL, MULTI-RACE - NUMBER OF OPERATIONS" | dataitem == "OPERATORS, PRINCIPAL, MULTI-RACE - NUMBER OF OPERATIONS"
	gen NumPacific = value if dataitem == "PRODUCERS, PRINCIPAL, NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER - NUMBER OF OPERATIONS" | dataitem == "OPERATORS, PRINCIPAL, NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER - NUMBER OF OPERATIONS"
	gen NumWhite = value if dataitem == "PRODUCERS, PRINCIPAL, WHITE - NUMBER OF OPERATIONS" | dataitem == "OPERATORS, PRINCIPAL, WHITE - NUMBER OF OPERATIONS"
	gen NumMale = value if dataitem == "PRODUCERS, PRINCIPAL, MALE - NUMBER OF OPERATIONS" | dataitem == "OPERATORS, PRINCIPAL, MALE - NUMBER OF OPERATIONS"
	gen NumFemale = value if dataitem == "PRODUCERS, PRINCIPAL, FEMALE - NUMBER OF OPERATIONS" | dataitem == "OPERATORS, PRINCIPAL, FEMALE - NUMBER OF OPERATIONS"
	
	drop dataitem value 
	
// Reshaping dataset		


// Formatting state variable to get abbreviation
	statastates, name(state)
	
// Changing state to str# for merging purposes
	gen str20 state_str = state_abbrev
	drop state state_abbrev state_fips _merge
	rename state_str state
	order state year 

// Saving 
	sort state year
	save "clean_EthnicityGender.dta", replace
	
*************************************
* Acres Operated
*************************************
// Importing first dataset
	import delimited "1997_2017_AcresOperated.csv", clear 
	save "1997_2017_AcresOperated.dta", replace

// Formatting state variable to get abbreviation
	statastates, name(state)
	
// Changing state to str# for merging purposes
	gen str20 state_str = state_abbrev
	keep year value state_str domaincategory
	rename state_str state
	order state year domaincategory value 

// Changing value
	rename value TotalAcres 
	sort state year
	save "clean_Acres.dta", replace
	
*************************************
* Crop Operations 
*************************************
// Importing first dataset
	import delimited "1997_2017_CropOperations.csv", clear 
	save "1997_2017_CropOperations.dta", replace

// Formatting state variable to get abbreviation
	statastates, name(state)
	
// Changing state to str# for merging purposes
	gen str20 state_str = state_abbrev
	keep year value state_str
	rename state_str state
	order state year value 

// Changing value
	rename value NumCrop
	sort state year
	save "clean_Crop.dta", replace
	
*************************************
* Income Per Operation
*************************************
// Importing first dataset
	import delimited "1997_2017_FarmIncomePerOper.csv", clear 
	save "1997_2017_FarmIncomePerOper.dta", replace

// Formatting state variable to get abbreviation
	statastates, name(state)
	
// Changing state to str# for merging purposes
	gen str20 state_str = state_abbrev
	keep year value state_str
	rename state_str state
	order state year value 

// Changing value
	rename value IncomePerOperation
	sort state year
	save "clean_income.dta", replace
	
*************************************
* Total Operations
*************************************
// Importing first dataset
	import delimited "1997_2017_AcresOperated.csv", clear 
	save "1997_2017_AcresOperated.dta", replace

// Formatting state variable to get abbreviation
	statastates, name(state)
	
// Changing state to str# for merging purposes
	gen str20 state_str = state_abbrev
	keep year value state_str domaincategory
	rename state_str state
	order state year domaincategory value 

// Changing value
	rename value TotalOperations 
	sort state year
	save "clean_operations.dta", replace

*************************************
* Poultry Operations
*************************************
// Importing first dataset
	import delimited "1997_2017_PoultryOperations.csv", clear 
	save "1997_2017_PoultryOperations.dta", replace

// Formatting state variable to get abbreviation
	statastates, name(state)
	
// Changing state to str# for merging purposes
	gen str20 state_str = state_abbrev
	keep year value state_str
	rename state_str state
	order state year value 

// Changing value
	rename value NumPoultry
	sort state year
	save "clean_poultry.dta", replace
	
*************************************
* Off Farm Occupation
*************************************
// Importing first dataset
	import delimited "1997_2017_PrimaryOccOffFarm.csv", clear 
	save "1997_2017_PrimaryOccOffFarm.dta", replace

// Formatting state variable to get abbreviation
	statastates, name(state)
	
// Changing state to str# for merging purposes
	gen str20 state_str = state_abbrev
	keep year numprimoff state_str
	rename state_str state
	order state year numprimoff 

// Changing value
	rename numprimoff NumOffFarm
	sort state year
	save "clean_OffFarm.dta", replace
	
***********************************************
* Persons in Household and Years on Operation 
***********************************************
// Importing first dataset
	import delimited "2002_2017_PersonsHousehold_YearsOnOperation.csv", clear 
	save "2002_2017_PersonsHousehold_YearsOnOperation.dta", replace

// Appending datasets and dropping unecessary variables 
	destring dataitem, replace
	keep year state dataitem value

// New Variables
	gen HouseholdSize = value if dataitem == "PRODUCERS, PRINCIPAL - PERSONS IN HOUSEHOLD, MEASURED IN PERSONS" | dataitem == "OPERATORS, PRINCIPAL - PERSONS IN HOUSEHOLD, MEASURED IN PERSONS"
	gen Experience = value if dataitem == "OPERATORS, PRINCIPAL - YEARS ON ANY OPERATION, AVG, MEASURED IN YEARS" | dataitem == "PRODUCERS, PRINCIPAL - YEARS ON ANY OPERATION, AVG, MEASURED IN YEARS"
	
	drop dataitem value 
	
// Reshaping dataset		


// Formatting state variable to get abbreviation
	statastates, name(state)
	
// Changing state to str# for merging purposes
	gen str20 state_str = state_abbrev
	drop state state_abbrev state_fips _merge
	rename state_str state
	order state year 

// Saving 
	sort state year
	save "clean_HouseSize_Experience.dta", replace
	
	
	
	
	
	