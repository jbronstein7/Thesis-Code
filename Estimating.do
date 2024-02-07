********************************************************************************
* Title: Estimating
* Author: Joe Bronstein
* Purpose: To estimate models  
* Last Modified: 2/7/2024
* Assumes: All other data arranging files have been run, and imputed dataset is available 
********************************************************************************
	di c(hostname) 

		if "`c(hostname)'" == "AREC-ATHNOS" {
				cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein\Clean(ish) Datasets"
				}


		if "`c(hostname)'" == "JBRON-DESKTOP" {
				cd "\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data\Clean(ish) Datasets"
				}
				
********************************************************************************
* 0. Loading in cleaned, imputed dataset
********************************************************************************
// use cleaned imputed dataset
	use "merged_all_imputed.dta", clear 
	
********************************************************************************
* 1. First model - Basic linear model, no fixed effects (location/year dummies)
********************************************************************************
// Using average age
	regress OwnOrLeaseComputers age DairyOperations IncomePerOperation prop_Female acres_per_oper Experience

// Dropping experience to increase sample size 
	regress OwnOrLeaseComputers age DairyOperations IncomePerOperation prop_Female acres_per_oper // sample size more than doubles, much higher R-sq as well
	
// Using binned age
	regress OwnOrLeaseComputers prop25_34 prop35_44 prop45_54 prop55_64 prop65_74 propGE_75 DairyOperations IncomePerOperation prop_Female acres_per_oper
	// R-squared about the same as previous iteration
	
// Adding ethnicity and computer price (not regionally adjusted)
	regress OwnOrLeaseComputers prop25_34 prop35_44 prop45_54 prop55_64 prop65_74 propGE_75 prop_Asian prop_AfricanAmerican prop_Hispanic prop_Multi prop_Pacific prop_White DairyOperations IncomePerOperation prop_Female acres_per_oper CompCPI // CompCPI is very significant 
	
// Replacing CompCPI with regionally adjusted CPI
	regress OwnOrLeaseComputers prop25_34 prop35_44 prop45_54 prop55_64 prop65_74 propGE_75 prop_Asian prop_AfricanAmerican prop_Hispanic prop_Multi prop_Pacific prop_White DairyOperations IncomePerOperation prop_Female acres_per_oper AdjCompCPI
	
********************************************************************************
* 1. Second model - Adding fixed effects for location
********************************************************************************
	
	
	