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
	ssc install outreg2
********************************************************************************
* 0. Loading in cleaned, imputed dataset, and creating global lists 
********************************************************************************
// use cleaned imputed dataset
	use "clean(ish) datasets\merged_all_imputed.dta", clear 
	
// Creating global lists for key variables 
	local bin_age "prop25_34 prop35_44 prop45_54 prop65_74 propGE_75"
	// Using the 55 to 64 age group as baseline, since that encompasses the avg. age 
	
	local ethnicity "prop_Asian prop_AfricanAmerican prop_Hispanic prop_Multi prop_Pacific"
	// Using prop_white as baseline 
	
	local controls "prop_crop avg_hhsize prop_poultry prop_OffFarm `ethnicity'"
	// Variables that seem important to control for, but were not mentioned as determinants of adoption in the literature 
	
	local var_interest "prop_dairy acres_per_oper prop_Female InternetAccess IncomePerOperation AdjCompCPI `bin_age'"
	// variables mentioned as singificant in the literaure 

********************************************************************************
* 1. Naive Model - Basic Linear Regression with Fixed effects for time and state
********************************************************************************
	xi: qui regress OwnOrLeaseComputers `var_interest' `controls' i.state ib2001.year, vce(cluster state)
	estimates store naive

	esttab naive, keep(`var_interest') stats (r2 N)	
	outreg2 using "basic_regression_results", word excel replace
********************************************************************************
* 2. Second model - Event Study 
********************************************************************************
// Generating interaction terms
	forval x=1997/2023 {
		foreach y in `var_interest'{
			gen `y'_`x' = `y' if year == `x'
			replace `y'_`x' = 0 if year != `x'

			}
		}
		
// Creating a local to refer to interaction terms (2001 removed)
	local var_interactions "prop_dairy_1997 acres_per_oper_1997 prop_Female_1997 InternetAccess_1997 IncomePerOperation_1997 AdjCompCPI_1997 prop25_34_1997 prop35_44_1997 prop45_54_1997 prop65_74_1997 propGE_75_1997 prop_dairy_1998 acres_per_oper_1998 prop_Female_1998 InternetAccess_1998 IncomePerOperation_1998 AdjCompCPI_1998 prop25_34_1998 prop35_44_1998 prop45_54_1998 prop65_74_1998 propGE_75_1998 prop_dairy_1999 acres_per_oper_1999 prop_Female_1999 InternetAccess_1999 IncomePerOperation_1999 AdjCompCPI_1999 prop25_34_1999 prop35_44_1999 prop45_54_1999 prop65_74_1999 propGE_75_1999 prop_dairy_2000 acres_per_oper_2000 prop_Female_2000 InternetAccess_2000 IncomePerOperation_2000 AdjCompCPI_2000 prop25_34_2000 prop35_44_2000 prop45_54_2000 prop65_74_2000 propGE_75_2000 prop_dairy_2002 acres_per_oper_2002 prop_Female_2002 InternetAccess_2002 IncomePerOperation_2002 AdjCompCPI_2002 prop25_34_2002 prop35_44_2002 prop45_54_2002 prop65_74_2002 propGE_75_2002 prop_dairy_2003 acres_per_oper_2003 prop_Female_2003 InternetAccess_2003 IncomePerOperation_2003 AdjCompCPI_2003 prop25_34_2003 prop35_44_2003 prop45_54_2003 prop65_74_2003 propGE_75_2003 prop_dairy_2004 acres_per_oper_2004 prop_Female_2004 InternetAccess_2004 IncomePerOperation_2004 AdjCompCPI_2004 prop25_34_2004 prop35_44_2004 prop45_54_2004 prop65_74_2004 propGE_75_2004 prop_dairy_2005 acres_per_oper_2005 prop_Female_2005 InternetAccess_2005 IncomePerOperation_2005 AdjCompCPI_2005 prop25_34_2005 prop35_44_2005 prop45_54_2005 prop65_74_2005 propGE_75_2005 prop_dairy_2006 acres_per_oper_2006 prop_Female_2006 InternetAccess_2006 IncomePerOperation_2006 AdjCompCPI_2006 prop25_34_2006 prop35_44_2006 prop45_54_2006 prop65_74_2006 propGE_75_2006 prop_dairy_2007 acres_per_oper_2007 prop_Female_2007 InternetAccess_2007 IncomePerOperation_2007 AdjCompCPI_2007 prop25_34_2007 prop35_44_2007 prop45_54_2007 prop65_74_2007 propGE_75_2007 prop_dairy_2008 acres_per_oper_2008 prop_Female_2008 InternetAccess_2008 IncomePerOperation_2008 AdjCompCPI_2008 prop25_34_2008 prop35_44_2008 prop45_54_2008 prop65_74_2008 propGE_75_2008 prop_dairy_2009 acres_per_oper_2009 prop_Female_2009 InternetAccess_2009 IncomePerOperation_2009 AdjCompCPI_2009 prop25_34_2009 prop35_44_2009 prop45_54_2009 prop65_74_2009 propGE_75_2009 prop_dairy_2010 acres_per_oper_2010 prop_Female_2010 InternetAccess_2010 IncomePerOperation_2010 AdjCompCPI_2010 prop25_34_2010 prop35_44_2010 prop45_54_2010 prop65_74_2010 propGE_75_2010 prop_dairy_2011 acres_per_oper_2011 prop_Female_2011 InternetAccess_2011 IncomePerOperation_2011 AdjCompCPI_2011 prop25_34_2011 prop35_44_2011 prop45_54_2011 prop65_74_2011 propGE_75_2011 prop_dairy_2012 acres_per_oper_2012 prop_Female_2012 InternetAccess_2012 IncomePerOperation_2012 AdjCompCPI_2012 prop25_34_2012 prop35_44_2012 prop45_54_2012 prop65_74_2012 propGE_75_2012 prop_dairy_2013 acres_per_oper_2013 prop_Female_2013 InternetAccess_2013 IncomePerOperation_2013 AdjCompCPI_2013 prop25_34_2013 prop35_44_2013 prop45_54_2013 prop65_74_2013 propGE_75_2013 prop_dairy_2014 acres_per_oper_2014 prop_Female_2014 InternetAccess_2014 IncomePerOperation_2014 AdjCompCPI_2014 prop25_34_2014 prop35_44_2014 prop45_54_2014 prop65_74_2014 propGE_75_2014 prop_dairy_2015 acres_per_oper_2015 prop_Female_2015 InternetAccess_2015 IncomePerOperation_2015 AdjCompCPI_2015 prop25_34_2015 prop35_44_2015 prop45_54_2015 prop65_74_2015 propGE_75_2015 prop_dairy_2016 acres_per_oper_2016 prop_Female_2016 InternetAccess_2016 IncomePerOperation_2016 AdjCompCPI_2016 prop25_34_2016 prop35_44_2016 prop45_54_2016 prop65_74_2016 propGE_75_2016 prop_dairy_2017 acres_per_oper_2017 prop_Female_2017 InternetAccess_2017 IncomePerOperation_2017 AdjCompCPI_2017 prop25_34_2017 prop35_44_2017 prop45_54_2017 prop65_74_2017 propGE_75_2017 prop_dairy_2018 acres_per_oper_2018 prop_Female_2018 InternetAccess_2018 IncomePerOperation_2018 AdjCompCPI_2018 prop25_34_2018 prop35_44_2018 prop45_54_2018 prop65_74_2018 propGE_75_2018 prop_dairy_2019 acres_per_oper_2019 prop_Female_2019 InternetAccess_2019 IncomePerOperation_2019 AdjCompCPI_2019 prop25_34_2019 prop35_44_2019 prop45_54_2019 prop65_74_2019 propGE_75_2019 prop_dairy_2020 acres_per_oper_2020 prop_Female_2020 InternetAccess_2020 IncomePerOperation_2020 AdjCompCPI_2020 prop25_34_2020 prop35_44_2020 prop45_54_2020 prop65_74_2020 propGE_75_2020 prop_dairy_2021 acres_per_oper_2021 prop_Female_2021 InternetAccess_2021 IncomePerOperation_2021 AdjCompCPI_2021 prop25_34_2021 prop35_44_2021 prop45_54_2021 prop65_74_2021 propGE_75_2021 prop_dairy_2022 acres_per_oper_2022 prop_Female_2022 InternetAccess_2022 IncomePerOperation_2022 AdjCompCPI_2022 prop25_34_2022 prop35_44_2022 prop45_54_2022 prop65_74_2022 propGE_75_2022 prop_dairy_2023 acres_per_oper_2023 prop_Female_2023 InternetAccess_2023 IncomePerOperation_2023 AdjCompCPI_2023 prop25_34_2023 prop35_44_2023 prop45_54_2023 prop65_74_2023 propGE_75_2023"

	xi: qui regress OwnOrLeaseComputers `var_interactions' `controls' i.state, vce(cluster state)
	estimates store event_study
	
	esttab event_study, drop(`controls' _Istate_*) stats (r2 N)	
	outreg2 using "event_study_results", word excel replace

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
	xi: qui regress OwnOrLeaseComputers c.prop_dairy#ib2001.year c.acres_per_oper#ib2001.year c.InternetAccess#ib2001.year c.AdjCompCPI#ib2001.year c.(`bin_age')#ib2001.year `controls' i.state, vce(cluster state)
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