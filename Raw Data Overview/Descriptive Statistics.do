********************************************************************************
* Title: Descriptive Statistics
* Author: Joe Bronstein
* Purpose: To generate descriptive statistics tables and charts   
* Last Modified: 2/21/2024
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