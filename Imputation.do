********************************************************************************
* Title: Data Imputation
* Author: Joe Bronstein
* Purpose: To impute missing values and form complete dataset to use for modeling 
* Last Modified: 2/1/2024
* Assumes: All other data arranging files have been run
********************************************************************************
	di c(hostname) 

		if "`c(hostname)'" == "AREC-ATHNOS" {
				cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein\Clean(ish) Datasets"
				}


		if "`c(hostname)'" == "JBRON-DESKTOP" {
				cd "\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data\Clean(ish) Datasets"
				}

********************************************************************************
* 0 Importing dataset and merging
********************************************************************************
	use "Merged_all.dta", clear
	
	
********************************************************************************
* 1 Filling in missings for tech variables (every other year)
********************************************************************************
// Creating local set called tech to reference variables 
	local tech OwnOrLeaseComputers ComputersForFarmBusiness InternetAccess ComputerAccess SmartPhoneTabletFarmBusiness SmartPhone

// Filling in missing values for tech variables (some will still be missing)
	foreach x in `tech'{
		// average the 2 obs surrounding a missing
		replace `x' = (`x'[_n-1] + `x'[_n+1]) / 2 if missing(`x') 
	}
	
	save "merged_all_imputed.dta", replace

********************************************************************************
* 2 Creating adjusted computer cpi
********************************************************************************
// adjusted CPI = CompCPI/RegionCPI
	gen AdjCompCPI = CompCPI
		replace AdjCompCPI = (CompCPI / WestCPI) * 100 if region == "West"
		replace AdjCompCPI = (CompCPI / SouthCPI) * 100 if region == "South"
		replace AdjCompCPI = (CompCPI / NortheastCPI) * 100 if region == "Northeast"
		replace AdjCompCPI = (CompCPI / MidwestCPI) * 100 if region == "Midwest"

// Adding label
	label variable AdjCompCPI "Regionally adjusted CPI for computers"
	
	save "merged_all_imputed.dta", replace