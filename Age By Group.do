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
	import delimited "USDA Raw Datasets\97_12_AgeByGroup.csv", clear
	save "97_12_AgeByGroup.dta", replace
	
	import delimited "USDA Raw Datasets\17_AgeByGroup.csv", clear
	save "17_AgeByGroup.dta", replace
	
	import delimited "USDA Raw Datasets\22_AgeByGroup.csv", clear
	save "22_AgeByGroup.dta", replace
	
	append using "97_12_AgeByGroup.dta"
	append using "17_AgeByGroup.dta"
	
// Keeping only variables we care about 
	keep year state dataitem value

// Getting numeric value 
	destring value, replace ignore (",")
	
**********************************************************
* 1 Re-formatting dataset
**********************************************************
// Creating new variables
	gen count25_34 = value if dataitem == "OPERATORS, PRINCIPAL, AGE 25 TO 34 - NUMBER OF OPERATORS" | dataitem == "PRODUCERS, PRIMARY, AGE 25 TO 34 - NUMBER OF PRODUCERS" | dataitem == "PRODUCERS, AGE 25 TO 34, DAY TO DAY DECISIONMAKING - NUMBER OF PRODUCERS"
	gen count35_44 = value if dataitem == "OPERATORS, PRINCIPAL, AGE 35 TO 44 - NUMBER OF OPERATORS" | dataitem == "PRODUCERS, PRIMARY, AGE 35 TO 44 - NUMBER OF PRODUCERS" | dataitem == "PRODUCERS, AGE 35 TO 44, DAY TO DAY DECISIONMAKING - NUMBER OF PRODUCERS"
	gen count45_54 = value if dataitem == "OPERATORS, PRINCIPAL, AGE 45 TO 54 - NUMBER OF OPERATORS" | dataitem == "PRODUCERS, PRIMARY, AGE 45 TO 54 - NUMBER OF PRODUCERS" | dataitem == "PRODUCERS, AGE 45 TO 54, DAY TO DAY DECISIONMAKING - NUMBER OF PRODUCERS"
	gen count55_64 = value if dataitem == "OPERATORS, PRINCIPAL, AGE 25 TO 34 - NUMBER OF OPERATORS" | dataitem == "PRODUCERS, PRIMARY, AGE 55 TO 64 - NUMBER OF PRODUCERS" | dataitem == "PRODUCERS, AGE 55 TO 64, DAY TO DAY DECISIONMAKING - NUMBER OF PRODUCERS"
	gen count65_74 = value if dataitem == "OPERATORS, PRINCIPAL, AGE 65 TO 74 - NUMBER OF OPERATORS" | dataitem == "PRODUCERS, PRIMARY, AGE 65 TO 74 - NUMBER OF PRODUCERS" | dataitem == "PRODUCERS, AGE 65 TO 74, DAY TO DAY DECISIONMAKING - NUMBER OF PRODUCERS"
	gen countGE_75 = value if dataitem == "OPERATORS, PRINCIPAL, AGE GE 75 - NUMBER OF OPERATORS" | dataitem == "PRODUCERS, PRIMARY, AGE GE 75 - NUMBER OF PRODUCERS" | dataitem == "PRODUCERS, AGE GE 75, DAY TO DAY DECISIONMAKING - NUMBER OF PRODUCERS"
	
	drop dataitem value
	
// Merging new variables to one observation 
// Reshaping dataset		
	collapse (sum) count25_34 count35_44 count45_54 count55_64 count65_74 countGE_75 , by(year state)
	
// Formatting state variable to get abbreviation
	statastates, name(state)
	
// Changing state to str# for merging purposes
	gen str20 state_str = state_abbrev
	drop state state_abbrev state_fips _merge
	rename state_str state
	order state year 

// Saving 
	sort state year
	save "Clean(ish) Datasets\Clean_Age_CountByGroup.dta", replace 
	
**********************************************************
* 3 Normalizing counts to count per operation
**********************************************************
// Creating total variable
	gen sum_of_counts = count25_34 + count35_44 + count45_54 + count55_64 + count65_74 + countGE_75 
	
// Now dividing count variables by total operations 
	gen prop25_34 = (count25_34 / sum_of_counts) * 100
	gen prop35_44 = (count35_44 / sum_of_counts) * 100
	gen prop45_54 = (count45_54 / sum_of_counts) * 100
	gen prop55_64 = (count55_64 / sum_of_counts) * 100
	gen prop65_74 = (count65_74 / sum_of_counts) * 100
	gen propGE_75 = (countGE_75 / sum_of_counts) * 100

// Only keeping variables we care about 
	keep state year prop25_34 prop35_44 prop45_54 prop55_64 prop65_74 propGE_75
	sort state year

// Convert 0's to missing's
	replace prop25_34 = . if prop25_34 == 0
	replace prop35_44 = . if prop35_44 == 0
	replace prop45_54 = . if prop45_54 == 0
	replace prop55_64 = . if prop55_64 == 0
	replace prop65_74 = . if prop65_74 == 0
	replace propGE_75 = . if propGE_75 == 0

// Labelling
	label variable prop25_34 "Proportion of farmers in the 25-34 age range"
	label variable prop35_44 "Proportion of farmers in the 35-44 age range"
	label variable prop45_54 "Proportion of farmers in the 45-54 age range"
	label variable prop55_64 "Proportion of farmers in the 55-64 age range"
	label variable prop65_74 "Proportion of farmers in the 65-74 age range"
	label variable propGE_75 "Proportion of farmers older than 75"
	
	save "Clean(ish) Datasets\Clean_Age_PropByGroup.dta", replace