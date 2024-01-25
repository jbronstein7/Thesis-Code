********************************************************************************
* Title: Clean Data Arranging 
* Author: Joe Bronstein
* Purpose: To merge cleaned datasets into a larger one 
* Last Modified: 1/24/2024
* Assumes: Data Arranging file and USDA and CPI cleaning files have been run
********************************************************************************
	di c(hostname) 

		if "`c(hostname)'" == "AREC-ATHNOS" {
				cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein\Clean(ish) Datasets"
				}


		if "`c(hostname)'" == "JBRON-DESKTOP" {
				cd "\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data\Clean(ish) Datasets"
				}

*************************************
* 1. Starting with USDA NASS data
*************************************
// Selecting acres as first dataset
	use "clean_acres.dta", clear 
	
// Merge the age dataset using state and year
	merge 1:1 state year using "clean_age.dta"
	drop _merge

// Merge crop data
	merge 1:1 state year using "clean_crop.dta"
	drop _merge

// Merge dairy data
	merge 1:1 state year using "clean_dairy.dta"
	drop _merge	
	sort state year

// Merge ethnicity and gender data
	merge 1:1 state year using "clean_ethnicitygender.dta"
	drop _merge	
	sort state year

// Merge income data
	merge 1:1 state year using "clean_income.dta"
	destring IncomePerOperation, replace ignore(",")
	drop _merge	
	sort state year

// Merge Off-Farm Labor data
	merge 1:1 state year using "clean_OffFarm.dta"
	destring NumOffFarm, replace ignore(",")
	drop _merge	
	sort state year
	
// Merge operations data
	merge 1:1 state year using "clean_operations.dta"
	destring IncomePerOperation, replace ignore(",")
	drop _merge	
	sort state year
	
// Merge poultry data
	merge 1:1 state year using "clean_poultry.dta"
	destring NumPoultry, replace ignore(",")
	drop _merge	
	sort state year
// Now have singular dataset with all USDA NASS data
	save "USDA_merged.dta", replace

*************************************
* 2. Next merging CPI data
*************************************
// Merge CPI data*****************************************
	merge 1:1 year using "clean_CPI.dta"
	drop _merge	
	sort state year