********************************************************************************
* Title: Clean Data
* Author: Joe Bronstein
* Purpose: To run all do files required to produce the clean dataset used for analysis
* Last Modified: 2/2/2024
* Assumes: Have requied do files and data on computer 
********************************************************************************
	di c(hostname) 

		if "`c(hostname)'" == "AREC-ATHNOS" {
				cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein\Code"
				}


		if "`c(hostname)'" == "JBRON-DESKTOP" {
				cd "\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Thesis-Code"
				}
				
********************************************************************************
* 1. Running do files in necessary order 
********************************************************************************
// Arranging tech variables 
	do "Data Arranging.do"
	
	
// NASS Data (must have this data downloaded)
	do "NASS Data Arranging.do"