********************************************************************************
* Title: USDA Data Arranging 
* Author: Joe Bronstein
* Purpose: To clean and aggregate USDA NASS data to merge into larger dataset
* Last Modified: 1/23/2024
* Assumes: All USDA NASS files have been downloaded, and are in a directory 
********************************************************************************
	di c(hostname) 

		if "`c(hostname)'" == "AREC-ATHNOS" {
				cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein"
				}


		if "`c(hostname)'" == "JBRON-DESKTOP" {
				cd "\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data"
				}
				
*************************************
* Age 
*************************************
// Importing first Age dataset
	import delimited "USDA Raw Datasets/1997_2012_AvgAge.csv", clear 
	save "USDA Raw Datasets/1997_2012_AvgAge.dta", replace

// Importing second dataset
	import delimited "USDA Raw Datasets/2017_AvgAge.csv", clear
	save "USDA Raw Datasets/2017_AvgAge.dta", replace

// Appending datasets and dropping unecessary variables 
	append using "USDA Raw Datasets/1997_2012_AvgAge.dta"
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
	save "Clean(ish) Datasets/clean_age.dta", replace
	
*************************************
* Dairy Operations
*************************************
// Importing first Age dataset
	import delimited "USDA Raw Datasets/1970_2022_DairyOperations.csv", clear 
	save "USDA Raw Datasets/1970_2022_DairyOperations.dta", replace

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
	save "Clean(ish) Datasets/clean_dairy.dta", replace
	
*************************************
* Ethnicity and Gender 
*************************************
// Importing first dataset
	import delimited "USDA Raw Datasets/1997_2012_EthnicityGender.csv", clear 
	save "USDA Raw Datasets/1997_2012_EthnicityGender.dta", replace

// Importing second dataset
	import delimited "USDA Raw Datasets/2017_EthnicityGender.csv", clear
	save "USDA Raw Datasets/2017_EthnicityGender.dta", replace

// Importing third dataset
	import delimited "USDA Raw Datasets/22_EthnicityGender.csv", clear
	save "USDA Raw Datasets/22_EthnicityGender.dta", replace
	
// Appending datasets and dropping unecessary variables 
	append using "USDA Raw Datasets/1997_2012_EthnicityGender.dta"
	append using "USDA Raw Datasets/2017_EthnicityGender.dta"
	keep if domain == "TOTAL"
	destring dataitem, replace
	keep year state dataitem value
	destring value, replace ignore (",")
	drop if dataitem == "PRODUCERS, AMERICAN INDIAN OR ALASKA NATIVE, DAY TO DAY DECISIONMAKING - NUMBER OF PRODUCERS"

// New Variables
	gen NumAsian = value if dataitem == "PRODUCERS, PRINCIPAL, ASIAN - NUMBER OF OPERATIONS" | dataitem == "OPERATORS, PRINCIPAL, ASIAN - NUMBER OF OPERATIONS" | dataitem == "PRODUCERS, ASIAN, DAY TO DAY DECISIONMAKING - NUMBER OF PRODUCERS" 
	gen NumAfricanAmerican = value if dataitem == "PRODUCERS, PRINCIPAL, BLACK OR AFRICAN AMERICAN - NUMBER OF OPERATIONS" | dataitem == "OPERATORS, PRINCIPAL, BLACK OR AFRICAN AMERICAN - NUMBER OF OPERATIONS" | dataitem == "PRODUCERS, BLACK OR AFRICAN AMERICAN, DAY TO DAY DECISIONMAKING - NUMBER OF PRODUCERS"
	gen NumHispanic = value if dataitem == "PRODUCERS, PRINCIPAL, HISPANIC - NUMBER OF OPERATIONS" | dataitem == "OPERATORS, PRINCIPAL, HISPANIC - NUMBER OF OPERATIONS" | dataitem == "PRODUCERS, HISPANIC, DAY TO DAY DECISIONMAKING - NUMBER OF PRODUCERS"
	gen NumMulti = value if dataitem == "PRODUCERS, PRINCIPAL, MULTI-RACE - NUMBER OF OPERATIONS" | dataitem == "OPERATORS, PRINCIPAL, MULTI-RACE - NUMBER OF OPERATIONS" | dataitem == "PRODUCERS, MULTI-RACE, DAY TO DAY DECISIONMAKING - NUMBER OF PRODUCERS"
	gen NumPacific = value if dataitem == "PRODUCERS, PRINCIPAL, NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER - NUMBER OF OPERATIONS" | dataitem == "OPERATORS, PRINCIPAL, NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER - NUMBER OF OPERATIONS" | dataitem == "PRODUCERS, NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER, DAY TO DAY DECISIONMAKING - NUMBER OF PRODUCERS"
	gen NumWhite = value if dataitem == "PRODUCERS, PRINCIPAL, WHITE - NUMBER OF OPERATIONS" | dataitem == "OPERATORS, PRINCIPAL, WHITE - NUMBER OF OPERATIONS" | dataitem == "PRODUCERS, WHITE, DAY TO DAY DECISIONMAKING - NUMBER OF PRODUCERS"
	gen NumMale = value if dataitem == "PRODUCERS, PRINCIPAL, MALE - NUMBER OF OPERATIONS" | dataitem == "OPERATORS, PRINCIPAL, MALE - NUMBER OF OPERATIONS"
	gen NumFemale = value if dataitem == "PRODUCERS, PRINCIPAL, FEMALE - NUMBER OF OPERATIONS" | dataitem == "OPERATORS, PRINCIPAL, FEMALE - NUMBER OF OPERATIONS" | dataitem == "PRODUCERS, FEMALE, DAY TO DAY DECISIONMAKING - NUMBER OF PRODUCERS"
	
	drop dataitem value 
	
// Reshaping dataset		
	collapse (sum) NumAsian NumAfricanAmerican NumHispanic NumMulti NumPacific NumWhite NumMale NumFemale, by(year state)

// Changing 0's to missings, checked to confirm there are no zeroes in original dataset
	replace NumAsian = . if NumAsian == 0
	replace NumAfricanAmerican = . if NumAfricanAmerican == 0
	replace NumHispanic = . if NumHispanic == 0
	replace NumMulti = . if NumMulti == 0
	replace NumPacific = . if NumPacific == 0
	replace NumWhite = . if NumWhite == 0
	replace NumMale = . if NumMale == 0
	replace NumFemale = . if NumFemale == 0
	

// Formatting state variable to get abbreviation
	statastates, name(state)
	
// Changing state to str# for merging purposes
	gen str20 state_str = state_abbrev
	drop state state_abbrev state_fips _merge
	rename state_str state
	order state year 

// Saving 
	sort state year
	save "Clean(ish) Datasets/clean_EthnicityGender.dta", replace
	
*************************************
* Acres Operated
*************************************
// Importing first dataset
	import delimited "USDA Raw Datasets/1997_2017_AcresOperated.csv", clear 
	save "USDA Raw Datasets/1997_2017_AcresOperated.dta", replace

// Imprting second dataset
	import delimited "USDA Raw Datasets/2022_AcresOperated.csv", clear 
	save "USDA Raw Datasets/2022_AcresOperated.dta", replace

	append using "USDA Raw Datasets/1997_2017_AcresOperated.dta"
// Formatting state variable to get abbreviation
	statastates, name(state)
	
// Changing state to str# for merging purposes
	gen str20 state_str = state_abbrev
	keep year value state_str domaincategory
	rename state_str state
	order state year domaincategory value 
	sort state year

// Getting numeric values 
	drop if value == " (D)"
	destring value, gen(value1) ignore(",")
	
// Summing by state year to get totals, instead of break down by category 
	egen totals = sum (value1), by (state year)

// Dropping unecessary variables
	keep state year totals

// De-duping 
	duplicates report state year
	duplicates drop state year, force
	
// Changing value
	rename totals TotalAcres 
	drop if state == "DC"

	save "Clean(ish) Datasets/clean_Acres.dta", replace
	
*************************************
* Crop Operations 
*************************************
// Importing first dataset
	import delimited "USDA Raw Datasets/1997_2017_CropOperations.csv", clear 
	save "USDA Raw Datasets/1997_2017_CropOperations.dta", replace

// Formatting state variable to get abbreviation
	statastates, name(state)
	
// Changing state to str# for merging purposes
	gen str20 state_str = state_abbrev
	keep year value state_str
	rename state_str state
	order state year value 
	destring value, replace ignore(",")
	
// Changing value
	rename value NumCrop
	sort state year
	save "Clean(ish) Datasets/clean_Crop.dta", replace
	
*************************************
* Income Per Operation
*************************************
// Importing first dataset
	import delimited "USDA Raw Datasets/1997_2017_FarmIncomePerOper.csv", clear 
	save "USDA Raw Datasets/1997_2017_FarmIncomePerOper.dta", replace

// Import using second dataset 
	import delimited "USDA Raw Datasets/2022_FarmIncomePerOper.csv", clear 
	save "USDA Raw Datasets/2022_FarmIncomePerOper.dta", replace
	
	append using "USDA Raw Datasets/1997_2017_FarmIncomePerOper.dta", force 
	
// Formatting state variable to get abbreviation
	statastates, name(state)
	
// Changing state to str# for merging purposes
	gen str20 state_str = state_abbrev
	keep year value state_str
	rename state_str state
	order state year value 
	destring value, replace ignore(",")
	
// Changing value
	rename value IncomePerOperation
	sort state year
	drop if state == "DC"
	save "Clean(ish) Datasets/clean_income.dta", replace
	
*************************************
* Total Operations
*************************************
// Importing first dataset
	import delimited "USDA Raw Datasets/1997_2017_NumOperations.csv", clear 
	save "USDA Raw Datasets/1997_2017_NumOperations.dta", replace

// Importing second dataset
	import delimited "USDA Raw Datasets/22_NumOperations.csv", clear 
	save "USDA Raw Datasets/2022_NumOperations.dta", replace
	
	append using "USDA Raw Datasets/1997_2017_NumOperations.dta", force
	
// Formatting state variable to get abbreviation
	statastates, name(state)
	
// Changing state to str# for merging purposes
	gen str20 state_str = state_abbrev
	keep year value state_str domaincategory
	rename state_str state
	order state year domaincategory value 

// Getting numeric values 
	drop if value == " (D)"
	destring value, gen(value1) ignore(",")
	
// Summing by state year to get totals, instead of break down by category 
	egen totals = sum (value1), by (state year)
	
// Dropping unecessary variables
	keep state year totals

// De-duping 
	duplicates report state year
	duplicates drop state year, force
	
// Changing value
	rename totals TotalOperations
	sort state year 
	drop if state == "DC"
	save "Clean(ish) Datasets/clean_operations.dta", replace

*************************************
* Poultry Operations
*************************************
// Importing first dataset
	import delimited "USDA Raw Datasets/1997_2017_PoultryOperations.csv", clear 
	save "USDA Raw Datasets/1997_2017_PoultryOperations.dta", replace

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
	save "Clean(ish) Datasets/clean_poultry.dta", replace
	
*************************************
* Off Farm Occupation
*************************************
// Importing first dataset
	import delimited "USDA Raw Datasets/1997_2017_PrimaryOccOffFarm.csv", clear 
	save "USDA Raw Datasets/1997_2017_PrimaryOccOffFarm.dta", replace

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
	save "Clean(ish) Datasets/clean_OffFarm.dta", replace
	
***********************************************
* Persons in Household and Years on Operation 
***********************************************
// Importing first dataset
	import delimited "USDA Raw Datasets/2002_2017_PersonsHousehold_YearsOnOperation.csv", clear 
	save "USDA Raw Datasets/2002_2017_PersonsHousehold_YearsOnOperation.dta", replace

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

// Reshaping dataset
	destring HouseholdSize, replace ignore (",")
	destring Experience, replace
	collapse (sum) HouseholdSize Experience, by(year state)
	replace Experience = . if Experience == 0
// Adding labels 
	label variable HouseholdSize "Total number of people in farm households by state"
	label variable Experience "Avg. Years on any operation of principal operator"
// Saving 
	sort state year
	save "Clean(ish) Datasets/clean_HouseSize_Experience.dta", replace
	

	
	