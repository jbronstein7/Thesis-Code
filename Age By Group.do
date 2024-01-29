********************************************************************************
* Title: USDA Age by Group Data Arranging 
* Author: Joe Bronstein
* Purpose: To clean and look at distribution of age when broken down into groups
* Last Modified: 1/29/2024
* Assumes: USDA NASS age files have been downloaded, NASS data arranging file has been run
********************************************************************************
	di c(hostname) 

		if "`c(hostname)'" == "AREC-ATHNOS" {
				cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein"
				}


		if "`c(hostname)'" == "JBRON-DESKTOP" {
				cd "\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data"
				}
				
**********************************************************
* 0 Importing raw data 
**********************************************************
	import delimited "\USDA Raw Datasets\97_12_AgeByGroup.csv", clear
	save "97_12_AgeByGroup.dta", replace

// Keeping only variables we care about 
	keep year state dataitem value

// Getting numeric value 
	destring value, replace ignore (",")
	
**********************************************************
* 1 Re-formatting dataset
**********************************************************
// Creating new variables
	gen count25_34 = value if dataitem == "OPERATORS, PRINCIPAL, AGE 25 TO 34 - NUMBER OF OPERATORS"
	gen count35_44 = value if dataitem == "OPERATORS, PRINCIPAL, AGE 35 TO 44 - NUMBER OF OPERATORS"
	gen count45_54 = value if dataitem == "OPERATORS, PRINCIPAL, AGE 45 TO 54 - NUMBER OF OPERATORS"
	gen count55_64 = value if dataitem == "OPERATORS, PRINCIPAL, AGE 25 TO 34 - NUMBER OF OPERATORS"
	gen count65_74 = value if dataitem == "OPERATORS, PRINCIPAL, AGE 65 TO 74 - NUMBER OF OPERATORS"
	gen countGE_75 = value if dataitem == "OPERATORS, PRINCIPAL, AGE GE 75 - NUMBER OF OPERATORS"
	
	drop dataitem value
	
// Merging new variables to one observation 
// Reshaping dataset		
	collapse (sum) count25_34 count35_44 count45_54 count55_64 count65_74 countGE_75 , by(year state)

// Changing 0's to missings, checked to confirm there are no zeroes in original dataset
	replace count25_34 = . if count25_34 == 0
	replace count35_44 = . if count35_44 == 0
	replace count45_54 = . if count45_54 == 0
	replace count55_64 = . if count55_64 == 0
	replace count65_74 = . if count65_74 == 0
	replace countGE_75 = . if countGE_75 == 0
	
// Formatting state variable to get abbreviation
	statastates, name(state)
	
// Changing state to str# for merging purposes
	gen str20 state_str = state_abbrev
	drop state state_abbrev state_fips _merge
	rename state_str state
	order state year 

// Saving 
	sort state year
	
**********************************************************
* 3 Normalizing counts to count per operation
**********************************************************
// Merging total operations data 
	merge 1:1 year state using "\Clean(ish) Datasets\clean_operations.dta"
	drop _merge
	
// Now dividing count variables by total operations 
	gen prop25_34 = count25_34 / TotalOperations
	gen prop35_44 = count35_44 / TotalOperations
	gen prop45_54 = count45_54 / TotalOperations
	gen prop55_64 = count55_64 / TotalOperations
	gen prop65_74 = count65_74 / TotalOperations
	gen propGE_75 = countGE_75 / TotalOperations