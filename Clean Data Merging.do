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