********************************************************************************
* Title: CPI Data Arranging 
* Author: Joe Bronstein
* Purpose: To clean and aggregate Computer CPI data to merge into larger dataset
* Last Modified: 1/23/2024
* Assumes: CPI data have been downloaded, and are in a directory 
********************************************************************************
	di c(hostname) 

		if "`c(hostname)'" == "AREC-ATHNOS" {
				cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein\Other Raw Data\"
				}


		if "`c(hostname)'" == "JBRON-DESKTOP" {
				cd "\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data\Other Raw Data"
				}

*************************************
* 0. Importing CPI Dataset
*************************************

// Importing CPI Data
	import delimited "CPI_Computers_1997_2023.csv", clear 
	save "CPI_Raw.dta", replace 
	
*************************************
* 1. Re-formatting date 
*************************************

// Creating an intermediate variable 
	gen date_str = date(date, "MDY")

// Format the intermediate variable
	format date_str %td

// Drop the original date variable and rearranging variable order 
	drop date
	rename date_str date
	order date cpi
	
	save "CPI_Raw.dta", replace 
// Now have date formatted properly

*************************************
* 2. Truncating by month and year 
*************************************

// Keeping only June observations (to match with June ag. survey data)
	keep if month(date) == 6

// Adding year variable for merging later on
	gen year = year(date)
	drop date 
	order year cpi
	
// Now only have obs in June, from 98 to 23
// Years match data (98-23), so no more needs to be done 
	save "CPI_Clean.dta", replace 

