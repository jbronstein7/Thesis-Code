********************************************************************************
* Title: Estimating
* Author: Joe Bronstein
* Purpose: To estimate models  
* Last Modified: 2/7/2024
* Assumes: All other data arranging files have been run, and imputed dataset is available 
********************************************************************************
	di c(hostname) 

		if "`c(hostname)'" == "AREC-ATHNOS" {
				cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein"
				}


		if "`c(hostname)'" == "JBRON-DESKTOP" {
				cd "\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data"
				}
			
		log using "estimation log.smcl"
********************************************************************************
* 0. Loading in cleaned, imputed dataset, and creating global lists 
********************************************************************************
// use cleaned imputed dataset
	use "clean(ish) datasets\merged_all_imputed.dta", clear 
	
// Creating global lists for key variables 
	global bin_age "prop25_34 prop35_44 prop45_54 prop65_74 propGE_75"
	// Using the 55 to 64 age group as baseline, since that encompasses the avg. age 
	
	global ethnicity "prop_Asian prop_AfricanAmerican prop_Hispanic prop_Multi prop_Pacific"
	// Using prop_white as baseline 
********************************************************************************
* 1. First model - Basic linear model, no fixed effects (location/year dummies)
********************************************************************************
// Using average age
	regress OwnOrLeaseComputers age DairyOperations IncomePerOperation prop_Female acres_per_oper Experience, robust 

// Dropping experience to increase sample size 
	regress OwnOrLeaseComputers age DairyOperations IncomePerOperation prop_Female acres_per_oper, robust // sample size more than doubles, much higher R-sq as well
	
// Using binned age
	regress OwnOrLeaseComputers $bin_age DairyOperations IncomePerOperation prop_Female acres_per_oper, robust
	// R-squared about the same as previous iteration
	
// Adding ethnicity and computer price (not regionally adjusted)
	regress OwnOrLeaseComputers $bin_age $ethnicity DairyOperations IncomePerOperation prop_Female acres_per_oper CompCPI, robust // CompCPI is very significant 
	
// Replacing CompCPI with regionally adjusted CPI
	regress OwnOrLeaseComputers $bin_age $ethnicity DairyOperations IncomePerOperation prop_Female acres_per_oper AdjCompCPI, robust
	
// Adding internet access
	regress OwnOrLeaseComputers $bin_age $ethnicity DairyOperations IncomePerOperation prop_Female acres_per_oper AdjCompCPI InternetAccess, robust
	
	
********************************************************************************
* 2. Second model - Adding fixed effects for location
********************************************************************************
// first with state 
	xi: regress OwnOrLeaseComputers $bin_age $ethnicity DairyOperations IncomePerOperation prop_Female acres_per_oper AdjCompCPI InternetAccess i.state, vce(cluster state)
	// R-squared: 0.95, really shot up
	
// Replacing state with census division
	xi: regress OwnOrLeaseComputers $bin_age $ethnicity DairyOperations IncomePerOperation prop_Female acres_per_oper AdjCompCPI InternetAccess i.division, vce(cluster division)
	// R-squared drops to 0.91
	
// Replacing divisions with regions
	xi: regress OwnOrLeaseComputers $bin_age $ethnicity DairyOperations IncomePerOperation prop_Female acres_per_oper AdjCompCPI InternetAccess i.region, vce(cluster region)
	// R-squared drops to 0.91
	
********************************************************************************
* 3. Third model - Adding fixed effects for time 
********************************************************************************
// controlling for states and year 
	xi: regress OwnOrLeaseComputers $bin_age $ethnicity DairyOperations IncomePerOperation prop_Female acres_per_oper AdjCompCPI InternetAccess i.state i.year, vce(cluster state year)
	
********************************************************************************
* 4. Fourth model - Adding interactions 
********************************************************************************	
		xi: regress OwnOrLeaseComputers $bin_age $ethnicity DairyOperations IncomePerOperation prop_Female acres_per_oper (i.year*AdjCompCPI) InternetAccess i.state, vce(cluster state year)