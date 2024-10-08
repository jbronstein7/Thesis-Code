********************************************************************************
* Title: Estimating
* Author: Joe Bronstein
* Purpose: To estimate models  
* Last Modified: 3/12/2024
* Assumes: All other data arranging files have been run, and imputed dataset is available 
********************************************************************************
	di c(hostname) 

		if "`c(hostname)'" == "AREC-ATHNOS" {
				cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein"
				}


		if "`c(hostname)'" == "JBRON-DESKTOP" {
				cd "\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data"
				}
			
	ssc install estout	
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
	
	local controls "prop_crop avg_hhsize prop_poultry prop_OffFarm `ethnicity' IncomePerOperation"
	// Variables that seem important to control for, but were not mentioned as determinants of adoption in the literature 
	
	local var_interest "prop_dairy acres_per_oper InternetAccess AdjCompCPI `bin_age'"
	// variables mentioned as singificant in the literaure 

********************************************************************************
* 1. First model - Basic linear model, no fixed effects (location/year dummies)
********************************************************************************
	log using "no fixed effects log.smcl", replace
// Using average age
	regress OwnOrLeaseComputers c.age##c.age prop_dairy acres_per_oper InternetAccess AdjCompCPI `controls', robust 
	estimates store basic_OLS
	esttab basic_OLS, keep(age c.age#c.age prop_dairy acres_per_oper InternetAccess AdjCompCPI) stats (r2 N)
	
// Dropping experience to increase sample size 
	regress OwnOrLeaseComputers age DairyOperations IncomePerOperation prop_Female acres_per_oper, robust // sample size more than doubles, much higher R-sq as well
	estimates store model_1
	esttab model_1, keep(age DairyOperations) stats (r2 N)
	
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
	xi: regress OwnOrLeaseComputers `bin_age' `ethnicity' DairyOperations IncomePerOperation prop_Female acres_per_oper AdjCompCPI InternetAccess i.state ib2001.year, vce(cluster state year)
	
// adding avg age and avg age squared
	xi: regress OwnOrLeaseComputers `bin_age' c.age##c.age `ethnicity' DairyOperations IncomePerOperation prop_Female acres_per_oper AdjCompCPI InternetAccess i.state ib2001.year, vce(cluster state year)
	
	log close 
********************************************************************************
* 4. Fourth model - Adding interactions 
********************************************************************************	
// Log for interaction model
	log using "Interactions log.smcl", replace
//Creating interaction terms 
	xi: regress OwnOrLeaseComputers c.(`bin_age')##ib2001.year `ethnicity' DairyOperations IncomePerOperation c.prop_Female##ib2001.year acres_per_oper c.AdjCompCPI##ib2001.year InternetAccess i.state, vce(cluster state year)

// Replacing binned age with avg. age 
	xi: regress OwnOrLeaseComputers c.age##ib2001.year `ethnicity' DairyOperations IncomePerOperation c.prop_Female##ib2001.year acres_per_oper c.AdjCompCPI##ib2001.year InternetAccess i.state, vce(cluster state year)
		
// Adding age squared 
	xi: regress OwnOrLeaseComputers c.age##c.age c.age##ib2001.year `ethnicity' DairyOperations IncomePerOperation c.prop_Female##year acres_per_oper c.AdjCompCPI##ib2001.year InternetAccess i.state, vce(cluster state year)
	
	log close 
********************************************************************************
* 4. Final TWFE Models
********************************************************************************		
	log using "twfe comparisons log.smcl", replace 
	
// Creating local lists for key variables 
	local bin_age "prop25_34 prop35_44 prop45_54 prop65_74 prop55_64"
	// Using the 55 to 64 age group as baseline, since that encompasses the avg. age 
	
	local ethnicity "prop_Asian prop_AfricanAmerican prop_Hispanic prop_Multi prop_Pacific"
	// Using prop_white as baseline 
	
	local controls "prop_crop avg_hhsize prop_poultry prop_OffFarm `ethnicity' IncomePerOperation"
	// Variables that seem important to control for, but were not mentioned as determinants of adoption in the literature 
	
	local var_interest "prop_dairy acres_per_oper InternetAccess AdjCompCPI `bin_age'"
	// variables mentioned as singificant in the literaure 
	
// Using avg. age 
	xi: qui regress OwnOrLeaseComputers age prop_dairy acres_per_oper InternetAccess AdjCompCPI `controls' i.state ib2001.year, vce(cluster state year) 
	estimates store twfe_AvgAge
	
// Using average age and age squared 
	xi: qui regress OwnOrLeaseComputers age c.age#c.age prop_dairy acres_per_oper InternetAccess AdjCompCPI `controls' i.state ib2001.year, vce(cluster state year)
	estimates store twfe_AvgAgeSq

// Using binned age 
	xi: qui regress OwnOrLeaseComputers `var_interest' `controls' i.state ib2001.year, vce(cluster state year)
	estimates store twfe_BinAge

// Comparing the three models 
	esttab twfe_AvgAge twfe_AvgAgeSq twfe_BinAge, keep(age c.age#c.age `var_interest') stats (r2 N)	
	// R-squared remains about the same for all models, none of the ages are singificant

// Now looking at ethnicity 
	esttab twfe_AvgAge twfe_AvgAgeSq twfe_BinAge, keep(age c.age#c.age `var_interest' `ethnicity') stats (r2 N)	
	// only prop multi is significant 	
	
// replacing ethnicity with avg farm-related income 
	esttab twfe_AvgAge twfe_AvgAgeSq twfe_BinAge, keep(age c.age#c.age `var_interest' IncomePerOperation) stats (r2 N)	
	
	
	log close 	
********************************************************************************
* 5. Final Event Study Models
********************************************************************************		
	log using "event study comparisons log.smcl", replace 	

// Creating local lists for key variables 
	local bin_age "prop25_34 prop35_44 prop45_54 prop65_74 prop55_64"
	// Using the 55 to 64 age group as baseline, since that encompasses the avg. age 
	
	local ethnicity "prop_Asian prop_AfricanAmerican prop_Hispanic prop_Multi prop_Pacific"
	// Using prop_white as baseline 
	
	local controls "prop_crop avg_hhsize prop_poultry prop_OffFarm `ethnicity' IncomePerOperation"
	// Variables that seem important to control for, but were not mentioned as determinants of adoption in the literature 
	
	local var_interest "prop_dairy acres_per_oper InternetAccess AdjCompCPI `bin_age'"
	// variables mentioned as singificant in the literaure 
	
// Using avg. age 
	xi: qui regress OwnOrLeaseComputers c.age#ib2001.year c.prop_dairy#ib2001.year c.acres_per_oper#ib2001.year c.InternetAccess#ib2001.year c.AdjCompCPI#ib2001.year `controls' i.state, vce(cluster state year)
	estimates store es_AvgAge
	
// Using average age and age squared 
	xi: qui regress OwnOrLeaseComputers c.age#ib2001.year c.age#c.age#ib2001.year  c.prop_dairy#ib2001.year c.acres_per_oper#ib2001.year c.InternetAccess#ib2001.year c.AdjCompCPI#ib2001.year  `controls' i.state, vce(cluster state year)
	estimates store es_AvgAgeSq

// Using binned age 
	xi: qui regress OwnOrLeaseComputers c.prop_dairy#ib2001.year c.acres_per_oper#ib2001.year c.InternetAccess#ib2001.year c.AdjCompCPI#ib2001.year c.(`bin_age')#ib2001.year `controls' i.state, vce(cluster state year)
	estimates store es_BinAge

// Comparing the three models 
	esttab es_AvgAge es_AvgAgeSq es_BinAge, drop(_Istate_* `controls') stats (r2 N) nobaselevels
	

// Now looking at ethnicity 
	esttab es_AvgAge es_AvgAgeSq es_BinAge, drop(_Istate_* prop_crop avg_hhsize prop_poultry prop_OffFarm IncomePerOperation) stats (r2 N) nobaselevels
	
	
// replacing ethnicity with avg farm-related income 
	esttab es_AvgAge es_AvgAgeSq es_BinAge, drop(_Istate_* prop_crop avg_hhsize prop_poultry prop_OffFarm `ethnicity' ) stats (r2 N) nobaselevels
		
	
	log close 	
********************************************************************************
* 5. Comparing all models 
********************************************************************************			
log using "all model log.smcl", replace 	
	esttab twfe_AvgAge twfe_AvgAgeSq twfe_BinAge es_AvgAge es_AvgAgeSq es_BinAge, drop(_Istate_* prop_crop avg_hhsize prop_poultry prop_OffFarm `ethnicity' ) stats (r2 N) nobaselevels
	
	log close 	
	

	

********************************************************************************
* 6. Determining causality between internet access and computer ownership
********************************************************************************
log using "internet_computer_causality.smcl", replace 
// Regressing own or lease on lagged internet access
	encode state, generate(state_1)
	tsset state_1 year

// creating a lagged internet access variable 
	gen lag_InternetAccess = L.InternetAccess
	
// regression: 
	regress OwnOrLeaseComputers lag_InternetAccess
	// lag internet access is extremely significant 
	
// Regressing lagged ownorlease on internet access
	gen lag_OwnOrLeaseComputers = L.OwnOrLeaseComputers
	
// regression: 
	regress InternetAccess lag_OwnOrLeaseComputers 
	
	log close 