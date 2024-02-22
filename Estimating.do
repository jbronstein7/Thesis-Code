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
			
		
********************************************************************************
* 0. Loading in cleaned, imputed dataset, and creating global lists 
********************************************************************************
// use cleaned imputed dataset
	use "clean(ish) datasets\merged_all_imputed.dta", clear 
	
// Creating global lists for key variables 
	local bin_age "prop25_34 prop35_44 prop45_54 prop65_74 prop55_64"
	// Using the 55 to 64 age group as baseline, since that encompasses the avg. age 
	
	local ethnicity "prop_Asian prop_AfricanAmerican prop_Hispanic prop_Multi prop_Pacific"
	// Using prop_white as baseline 
	
	
********************************************************************************
* 1. First model - Basic linear model, no fixed effects (location/year dummies)
********************************************************************************
	log using "no fixed effects log.smcl", replace
// Using average age
	regress OwnOrLeaseComputers age DairyOperations IncomePerOperation prop_Female acres_per_oper Experience, robust 

// Dropping experience to increase sample size 
	regress OwnOrLeaseComputers age DairyOperations IncomePerOperation prop_Female acres_per_oper, robust // sample size more than doubles, much higher R-sq as well
	
// Using binned age
	regress OwnOrLeaseComputers `bin_age' DairyOperations IncomePerOperation prop_Female acres_per_oper, robust
	// R-squared about the same as previous iteration
	
// Adding ethnicity and computer price (not regionally adjusted)
	regress OwnOrLeaseComputers `bin_age' `ethnicity' DairyOperations IncomePerOperation prop_Female acres_per_oper CompCPI, robust // CompCPI is very significant 
	
// Replacing CompCPI with regionally adjusted CPI
	regress OwnOrLeaseComputers `bin_age' `ethnicity' DairyOperations IncomePerOperation prop_Female acres_per_oper AdjCompCPI, robust
	
// Adding internet access
	regress OwnOrLeaseComputers `bin_age' `ethnicity' DairyOperations IncomePerOperation prop_Female acres_per_oper AdjCompCPI InternetAccess, robust
	
		log close 
********************************************************************************
* 2. Second model - Adding fixed effects for location
********************************************************************************
// Setting log for fixed effects models 
	log using "Fixed Effects log.smcl", replace 
// first with state 
	xi: regress OwnOrLeaseComputers `bin_age' `ethnicity' DairyOperations IncomePerOperation prop_Female acres_per_oper AdjCompCPI InternetAccess i.state, vce(cluster state)
	// R-squared: 0.95, really shot up
	
// Replacing state with census division
	xi: regress OwnOrLeaseComputers `bin_age' `ethnicity' DairyOperations IncomePerOperation prop_Female acres_per_oper AdjCompCPI InternetAccess i.division, vce(cluster division)
	// R-squared drops to 0.91
	
// Replacing divisions with regions
	xi: regress OwnOrLeaseComputers `bin_age' `ethnicity' DairyOperations IncomePerOperation prop_Female acres_per_oper AdjCompCPI InternetAccess i.region, vce(cluster region)
	// R-squared drops to 0.91
	
********************************************************************************
* 3. Third model - Adding fixed effects for time 
********************************************************************************
// controlling for states and year 
	xi: regress OwnOrLeaseComputers `bin_age' `ethnicity' DairyOperations IncomePerOperation prop_Female acres_per_oper AdjCompCPI InternetAccess i.state i.year, vce(cluster state year)
	
// adding avg age and avg age squared
	xi: regress OwnOrLeaseComputers `bin_age' c.age##c.age `ethnicity' DairyOperations IncomePerOperation prop_Female acres_per_oper AdjCompCPI InternetAccess i.state i.year, vce(cluster state year)
	
	log close 
********************************************************************************
* 4. Fourth model - Adding interactions 
********************************************************************************	
// Log for interaction model
	log using "Interactions log.smcl", replace
//Creating interaction terms 
	xi: regress OwnOrLeaseComputers c.(`bin_age')##year `ethnicity' DairyOperations IncomePerOperation c.prop_Female##year acres_per_oper c.AdjCompCPI##year InternetAccess i.state, vce(cluster state year)

// Replacing binned age with avg. age 
	xi: regress OwnOrLeaseComputers c.age##year `ethnicity' DairyOperations IncomePerOperation c.prop_Female##year acres_per_oper c.AdjCompCPI##year InternetAccess i.state, vce(cluster state year)
		
// Adding age squared 
	xi: regress OwnOrLeaseComputers c.age##c.age c.age##year `ethnicity' DairyOperations IncomePerOperation c.prop_Female##year acres_per_oper c.AdjCompCPI##year InternetAccess i.state, vce(cluster state year)
	
	log close 
********************************************************************************
* 4. Fifth model - Comparing models going back to 1997
********************************************************************************		
	log using "comparisons log.smcl"
	xi: regress OwnOrLeaseComputers age NumOffFarm DairyOperations IncomePerOperation prop_Female acres_per_oper AdjCompCPI InternetAccess i.state, vce(cluster state)
			
		
		
		
		
		
		
		
		
		
		
		