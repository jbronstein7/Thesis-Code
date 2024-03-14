********************************************************************************
* Title: CPI Data Arranging 
* Author: Joe Bronstein
* Purpose: To clean and aggregate Computer and Regional CPI data to merge into larger dataset
* Last Modified: 2/1/2024
* Assumes: CPI data have been downloaded, and are in a directory 
********************************************************************************
	di c(hostname) 

		if "`c(hostname)'" == "AREC-ATHNOS" {
				cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein"
				}


		if "`c(hostname)'" == "JBRON-DESKTOP" {
				cd "\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data"
				}

*************************************
* 0. Importing CPI Datasets
*************************************

// Importing Computer CPI Data
	import delimited "Other Raw Data/CPI_Computers_1997_2023.csv", clear 
	save "Other Raw Data/CPI_Raw.dta", replace 
	clear
	
// Importing Regional CPI Data, using a loop for 4 regions
// First setting local variables 
	local region West Northeast South Midwest
	
// Creating a loop
	foreach x in `region'{
		// Import the excel file 
			import excel using "Other Raw Data/`x'_CPI_Raw.xlsx", firstrow
		
		// Drop series ID variable and keep only June months (match June ag survey)
			rename Year year
			drop SeriesID
			keep if Period == "M06"
			
		// Changing base to 1997
			gen rebased_CPI = (Value / Value[1]) * 100
			drop Value
			rename rebased_CPI `x'CPI
			
		// Save file in stata format
			save "Clean(ish) Datasets/`x'_CPI_Clean.dta", replace 
			clear
	}
	
*************************************
* 1. Re-formatting date for computer CPI set
*************************************
	use "Other Raw Data/CPI_Raw.dta", clear

// Creating an intermediate variable 
	gen date_str = date(date, "MDY")

// Format the intermediate variable
	format date_str %td

// Drop the original date variable and rearranging variable order 
	drop date
	rename date_str date
	order date cpi
	rename cpi CompCPI
	
	save "Other Raw Data/CPI_Raw.dta", replace 
// Now have date formatted properly

*************************************
* 2. Truncating by month and year 
*************************************

// Keeping only June observations (to match with June ag. survey data)
	keep if month(date) == 6 | year(date) == 1997   // Only Dec. is available for 1997

// Adding year variable for merging later on
	gen year = year(date)
	
// Re-basing CPI to 1997 for consistency
	gen rebase = (CompCPI / CompCPI[1]) * 100
	
// Dropping and ordering variables 
	drop CompCPI
	rename rebase CompCPI
	drop date 
	order year CompCPI
	
// Now only have obs in June, from 98 to 23
// Years match data (98-23), so no more needs to be done 
	save "Clean(ish) Datasets/clean_comp_CPI.dta", replace 
	clear 
	
*************************************
* 3. Merging All CPI data together
*************************************
// Starting with computer data
	use "Clean(ish) Datasets/clean_comp_CPI.dta", clear 

// Looping to merge all 5 sets
	local region West Northeast South Midwest
		foreach x in `region'{
			// Merge 1 to 1 by year
			merge 1:1 year using "Clean(ish) Datasets/`x'_cpi_clean.dta"
		
			// Drop variables 
			drop _merge Period
		}
// Labels 
	foreach x in `region'{
		label variable `x'CPI "CPI for the `x' region"
	}
	label variable CompCPI "CPI for computers"
	save "Clean(ish) Datasets/cpi_merged.dta", replace

