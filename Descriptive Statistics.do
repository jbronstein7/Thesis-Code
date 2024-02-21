********************************************************************************
* Title: Descriptive Statistics
* Author: Joe Bronstein
* Purpose: To generate descriptive statistics tables and charts   
* Last Modified: 2/21/2024
* Assumes: All other data arranging files have been run, and imputed dataset is available 
********************************************************************************
di c(hostname) 

		if "`c(hostname)'" == "AREC-ATHNOS" {
				cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein\clean(ish) datasets"
				}


		if "`c(hostname)'" == "JBRON-DESKTOP" {
				cd "\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data\clean(ish) datasets"
				}
			
********************************************************************************
* 0. Loading in cleaned, imputed dataset
********************************************************************************
	use "merged_all_imputed.dta"
	
********************************************************************************
* 1. Looking at average by year to determine base year 
********************************************************************************
// Calculate the average by year using egen
	egen avg_value = mean(OwnOrLeaseComputers), by(year)

// Create a line graph
	twoway (line avg_value year), title("Average Value by Year") xtitle("Year") ytitle("Average Value")
// Create a line graph with separate lines for each category
	twoway (line OwnOrLeaseComputers year), title("Value by Year") xtitle("Year") ytitle("Value")
