********************************************************************************
* Title: CPI Data Arranging 
* Author: Joe Bronstein
* Purpose: To clean and aggregate Computer CPI data to merge into larger dataset
* Last Modified: 1/18/2024
* Assumes: CPI data has been downloaded, and are in a directory 
********************************************************************************
	di c(hostname) 

		if "`c(hostname)'" == "AREC-ATHNOS" {
				cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein\Other Raw Data\"
				}


		if "`c(hostname)'" == "JBRON-DESKTOP" {
				cd "\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data\Other Raw Data"
				}
				
*****************************
* Cleaning CPI Dataset
*****************************
// Importing CPI Data
	import delimited "CPI_Computers_1997_2023.csv", clear 
	save "CPI_Raw.dta", replace 

// Only want to have values that match with dependent variable (June of odd numbered years)
	gen month = month(date)
	gen year = year(date)

// Keep observations where the month is June and the year is an odd number between 1997 and 2023
	keep if month == 6 & mod(year, 2) == 1 & year >= 1997 & year <= 2023

// Drop the temporary variables
	drop month year
