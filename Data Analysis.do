**************************************************************************
*
* Title: Data Analysis
* Authors: Joe Bronstein
* Last Updated: 11-20-2023
* Objective: Analyze thesis data and create new variables 
* Assumes: Have run Data Arranging code, and have all_data dataset 
**************************************************************************

di c(hostname) 

    if "`c(hostname)'" == "AREC-ATHNOS" {
            cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein"
            }


    if "`c(hostname)'" == "JBRON-DESKTOP" {
            cd "\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data"
            }

***********************************************************************************
* 0 - Is there a significant difference between beginning and end of time period?
***********************************************************************************
// Selecting raw data
	use "Clean(ish) Datasets\all_data.dta"
	
// Creating new variables 
// Create a new variable for 1997
	gen us_avg_OwnLease97 = .
	gen NewEngland_avg_OwnLease97 = .
	gen MiddleAtlantic_avg_OwnLease97 = .
	gen EastNorthCentral_avg_OwnLease97 = .
	gen WestNorthCentral_avg_OwnLease97 = .
	gen SouthAtlantic_avg_OwnLease97 = .
	gen EastSouthCentral_avg_OwnLease97 = .	
	gen WestSouthCentral_avg_OwnLease97 = .
	gen Mountain_avg_OwnLease97 = .
	gen Pacific_avg_OwnLease97 = .
// For 2023
	gen us_avg_OwnLease23 = .
	gen NewEngland_avg_OwnLease23 = .
	gen MiddleAtlantic_avg_OwnLease23 = .
	gen EastNorthCentral_avg_OwnLease23 = .
	gen WestNorthCentral_avg_OwnLease23 = .
	gen SouthAtlantic_avg_OwnLease23 = .
	gen EastSouthCentral_avg_OwnLease23 = .	
	gen WestSouthCentral_avg_OwnLease23 = .
	gen Mountain_avg_OwnLease23 = .
	gen Pacific_avg_OwnLease23 = .

// 1997 avg for entire country and each region 

