********************************************************************************
* Title: Descriptive Statistics
* Author: Joe Bronstein
* Purpose: To generate descriptive statistics tables and charts   
* Last Modified: 4/29/2024
* Assumes: All other data arranging files have been run, and imputed dataset is available 
********************************************************************************
di c(hostname) 

		if "`c(hostname)'" == "AREC-ATHNOS" {
				cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein"
				}


		if "`c(hostname)'" == "JBRON-DESKTOP" {
				cd "\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data"
				}
			
********************************************************************************
* 0. Loading in cleaned, imputed dataset
********************************************************************************
	use "clean(ish) datasets\merged_all_imputed.dta", clear 
	
********************************************************************************
* 1. Looking at average by year to determine base year 
********************************************************************************
// Calculate the average by year
	egen avg_value = mean(OwnOrLeaseComputers), by(year)
	keep year avg_value
// Sort the data by year
	sort year

// Identify and drop year duplicates
	duplicates report year
	duplicates drop year, force

// Create a line graph
	twoway (line avg_value year), title("Average Proportion by Year") xtitle("Year") ytitle("Average Adoption %") name(Avg_prop_by_year)

// Saving graph 
	graph save "Charts\Avg_prop_by_year.png", replace
// 2001 is where the 50% mark is, so likely use 2001 as base year 

********************************************************************************
* 2. Looking at total % change for ownorlease and total operations
********************************************************************************
// aggregate both variables
	egen avg_OwnOrLeaseComputers = mean(OwnOrLeaseComputers), by(year)
	egen avg_TotalOperations = mean(TotalOperations), by(year)
	
// Trimming 
	keep if state == "AL"
	keep if year == 1997 | year == 2022 //2022 is last non-imputed value of total ops, so more accurate
	
// Calculating percent change for both vars
	gen delta_own = (avg_OwnOrLeaseComputers[2]-avg_OwnOrLeaseComputers[1]) // since already a %, just need new - old
	// own or lease increased by 38% on average
	
	gen delta_ops = (avg_TotalOperations[2]-avg_TotalOperations[1])/avg_TotalOperations[1] * 100
	// total operations dropped by 17% on average 
	
********************************************************************************
* 2. Looking at change in numerator of dep. var. (count of own or lease)
********************************************************************************
log using "t-test of count own or lease"
	use "Clean(ish) Datasets\merged_all_imputed.dta", clear

// Aggregating total operations and % own or lease
// 	local important "OwnOrLeaseComputers TotalOperations"
//	
// 	foreach x in `important'{
// 			egen avg_`x' = mean(`x'), by (year)
// 	}
//	
// keeping only one time series of observations 
	keep if year == 2022 | year == 1997  // 2022 is last observed data for total ops, so more accurate than 2023
	keep year OwnOrLeaseComputers TotalOperations
	
// Scale OwnOrLease to be between 0 and 1 (%)
	gen OwnOrLeaseComputers_sca = OwnOrLeaseComputers/100
	drop OwnOrLeaseComputers
	
// Now calculating num own or lease 
	gen num_OwnOrLease = OwnOrLeaseComputers_sca * TotalOperations
	drop TotalOperations OwnOrLeaseComputers_sca
	
// Test for statistical difference in means in 1997 and 2022
// new variables for count in 1997 and count in 2022
	local year "1997 2022"
	foreach x in `year'{
		gen num_OwnOrLease_`x' = num_OwnOrLease if year == `x'
	}
	
// t-test between 2 groups 
	ttest num_OwnOrLease, by (year) //p-value of 0.018, so there is a significant difference
log close 

********************************************************************************
* 3. Generating C.V.'s for variables of interest 
********************************************************************************
	use "clean(ish) datasets\merged_all_imputed.dta", clear 
	drop if year == 2023
	drop if OwnOrLeaseComputers == .
// Creating local for important variables 
	local var_interest "prop_dairy acres_per_oper prop_Female InternetAccess IncomePerOperation AdjCompCPI age"

// Looping to calculate CV for each variable
	foreach x in `var_interest' {
	summarize `x'
	}