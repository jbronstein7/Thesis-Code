********************************************************************************
* Title: Clean Data Arranging 
* Author: Joe Bronstein
* Purpose: To merge cleaned datasets into a larger one 
* Last Modified: 1/23/2024
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
