**************************************************************************
*
* Title: Other Explanatory Variable Arranging 
* Authors: April Athnos & Joe Bronstein
* Last Updated: 1-11-2024
* Objective: To add other data to main set, all_data
* 
**************************************************************************

**************************************************************************
* 0 - Importing all_data
**************************************************************************
di c(hostname) 

    if "`c(hostname)'" == "AREC-ATHNOS" {
            cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein"
            }


    if "`c(hostname)'" == "JBRON-DESKTOP" {
            cd "\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data"
            }
			
	use "Clean(ish) Datasets\all_data.dta", clear