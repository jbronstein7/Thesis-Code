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
