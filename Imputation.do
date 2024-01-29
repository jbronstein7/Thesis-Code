********************************************************************************
* Title: Data Imputation
* Author: Joe Bronstein
* Purpose: To impute missing vlaues and form complete dataset to use for modeling 
* Last Modified: 1/29/2024
* Assumes: All other data arranging files have been run
********************************************************************************
	di c(hostname) 

		if "`c(hostname)'" == "AREC-ATHNOS" {
				cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein\Clean(ish) Datasets"
				}


		if "`c(hostname)'" == "JBRON-DESKTOP" {
				cd "\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data\Clean(ish) Datasets"
				}

********************************************************************************
* 0 Importing dataset and merging (still missing CPI for now)
********************************************************************************
	use "all_data.dta", clear

// Merge in USDA dataset
	merge 1:1 state year using "USDA_merged.dta"
	sort state year
	drop _merge

// Merge in Age counts by group
	merge 1:1 state year using "clean_age_countbygroup.dta"
	sort state year
	drop _merge
	
	save "Merged_all.dta"
********************************************************************************
* 1 Rearranging data
********************************************************************************
// Combining states which are combined in the june ag survey 
// New intermediate variable 
	gen state_1 = state

// Now combining states
	replace state_1 = "CO" if state_1 == "AZ" | state_1 == "NV" | state_1 == "NM" | state_1 == "UT" | state_1 == "WY"
	replace state_1 = "NH" if state_1 == "CT" | state_1 == "ME" | state_1 == "MA" | state_1 == "RI" | state_1 == "VT"
	replace state_1 = "PA" if state_1 == "NJ"
	replace state_1 = "VA" if state_1 == "DE" | state_1 == "MD" | state_1 == "WV"
	
	drop state 
	rename state_1 state
	sort state year
	order state year
	
// Dropping Alaska and Hawaii
	drop if state == "AK" | state == "HI"
	*47 obs deleted 
