********************************************************************************
* Title: Final Estimations
* Author: Joe Bronstein
*		  April Athnos
* Purpose: To estimate final models for paper/presentation
*		   To investigate the shapes of the event study output
* Last Modified: 3/28/2024
* Assumes: All other data arranging files have been run, and imputed dataset is available 
********************************************************************************
	di c(hostname) 

		if "`c(hostname)'" == "AREC-ATHNOS" {
				cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein"
				}


		if "`c(hostname)'" == "JBRON-DESKTOP" {
				cd "\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data"
				}

// Installing required packages
/*
	ssc install estout	
	ssc install outreg2
	ssc install coefplot
*/

********************************************************************************
* 0. Loading in cleaned, imputed dataset, and creating local lists 
********************************************************************************
// use cleaned imputed dataset
	use "clean(ish) datasets\merged_all_imputed.dta", clear 
	
// dropping 2023 
	drop if year == 2023 // comment out if want to see results with 2023
	// 47 obs deleted
	
// Creating local lists for key variables 
	local bin_age "prop25_34 prop35_44 prop45_54 prop65_74 propGE_75"
	// Using the 55 to 64 age group as baseline, since that encompasses the avg. age 
	
	local ethnicity "prop_Asian prop_AfricanAmerican prop_Hispanic prop_Multi prop_Pacific"
	// Using prop_white as baseline 
	
	local controls "prop_crop avg_hhsize prop_poultry prop_OffFarm `ethnicity'"
	// Variables that seem important to control for, but were not mentioned as determinants of adoption in the literature 
	
	local var_interest "prop_dairy acres_per_oper prop_Female InternetAccess IncomePerOperation AdjCompCPI age"
	// variables mentioned as singificant in the literaure 

********************************************************************************
* 1. TWFE - Comparing 4 models
********************************************************************************
log using "twfe model 2022", replace
// Starting with a basic OLS model, no fixed effects
	xi: qui regress OwnOrLeaseComputers `var_interest' `controls', vce(cluster state)
	estimates store OLS
	
// Now looking at only state fixed effects
	xi: qui regress OwnOrLeaseComputers `var_interest' `controls' i.state, vce(cluster state)
	estimates store state_fixed
	
// Looking at just time fixed effects 
	xi: qui regress OwnOrLeaseComputers `var_interest' `controls' ib2001.year, vce(cluster state) // 2001 as the base year 
	estimates store year_fixed
	
// The full twfe model 
	xi: qui regress OwnOrLeaseComputers `var_interest' `controls' i.state ib2001.year, vce(cluster state)
	estimates store twfe

// exporting the results 
	esttab OLS state_fixed year_fixed twfe, keep(`var_interest') stats (r2 N)	
	outreg2 [OLS state_fixed year_fixed twfe] using "Results\twfe_results_22", word excel replace

	capture log close
	
********************************************************************************
* 2. Second model - Event Study 
********************************************************************************
log using "event study 2022", replace	

	local var_interest "prop_dairy acres_per_oper prop_Female InternetAccess IncomePerOperation AdjCompCPI year age"
// Generating interaction terms
	forval x=1997/2022 {
		foreach y in `var_interest'{
			gen `y'_`x' = `y' if year == `x'
			replace `y'_`x' = 0 if year != `x'

			}
		}

// I want to decompose each of the variables of interest individually (with 2023)
	local CPI_decomp "AdjCompCPI_1997  AdjCompCPI_1998	AdjCompCPI_1999	AdjCompCPI_2000 	AdjCompCPI_2002	AdjCompCPI_2003	AdjCompCPI_2004	AdjCompCPI_2005	AdjCompCPI_2006	AdjCompCPI_2007	AdjCompCPI_2008	AdjCompCPI_2009	AdjCompCPI_2010	AdjCompCPI_2011	AdjCompCPI_2012	AdjCompCPI_2013	AdjCompCPI_2014	AdjCompCPI_2015	AdjCompCPI_2016	AdjCompCPI_2017	AdjCompCPI_2018	AdjCompCPI_2019	AdjCompCPI_2020	AdjCompCPI_2021	AdjCompCPI_2022"
	local prop_dairy_decomp "prop_dairy_1997 prop_dairy_1998	prop_dairy_1999	prop_dairy_2000 prop_dairy_2002	prop_dairy_2003	prop_dairy_2004	prop_dairy_2005	prop_dairy_2006	prop_dairy_2007	prop_dairy_2008	prop_dairy_2009	prop_dairy_2010	prop_dairy_2011	prop_dairy_2012	prop_dairy_2013	prop_dairy_2014	prop_dairy_2015	prop_dairy_2016	prop_dairy_2017	prop_dairy_2018	prop_dairy_2019	prop_dairy_2020	prop_dairy_2021	prop_dairy_2022"
	local year "year_1997	year_1998	year_1999	year_2000 year_2001 year_2002	year_2003	year_2004	year_2005	year_2006	year_2007	year_2008	year_2009	year_2010	year_2011	year_2012	year_2013	year_2014	year_2015	year_2016	year_2017	year_2018	year_2019	year_2020	year_2021	year_2022"
	local gender_decomp	"prop_Female_1997	prop_Female_1998	prop_Female_1999	prop_Female_2000		prop_Female_2002	prop_Female_2003	prop_Female_2004	prop_Female_2005	prop_Female_2006	prop_Female_2007	prop_Female_2008	prop_Female_2009	prop_Female_2010	prop_Female_2011	prop_Female_2012	prop_Female_2013	prop_Female_2014	prop_Female_2015	prop_Female_2016	prop_Female_2017	prop_Female_2018	prop_Female_2019	prop_Female_2020	prop_Female_2021	prop_Female_2022"
	local age_decomp "age_1997	age_1998	age_1999	age_2000		age_2002	age_2003	age_2004	age_2005	age_2006	age_2007	age_2008	age_2009	age_2010	age_2011	age_2012	age_2013	age_2014	age_2015	age_2016	age_2017	age_2018	age_2019	age_2020	age_2021	age_2022"
	local internet_decomp "InternetAccess_1997	InternetAccess_1998	InternetAccess_1999	InternetAccess_2000		InternetAccess_2002	InternetAccess_2003	InternetAccess_2004	InternetAccess_2005	InternetAccess_2006	InternetAccess_2007	InternetAccess_2008	InternetAccess_2009	InternetAccess_2010	InternetAccess_2011	InternetAccess_2012	InternetAccess_2013	InternetAccess_2014	InternetAccess_2015	InternetAccess_2016	InternetAccess_2017	InternetAccess_2018	InternetAccess_2019	InternetAccess_2020	InternetAccess_2021	InternetAccess_2022"
	local acres_decomp "acres_per_oper_1997	acres_per_oper_1998	acres_per_oper_1999	acres_per_oper_2000		acres_per_oper_2002	acres_per_oper_2003	acres_per_oper_2004	acres_per_oper_2005	acres_per_oper_2006	acres_per_oper_2007	acres_per_oper_2008	acres_per_oper_2009	acres_per_oper_2010	acres_per_oper_2011	acres_per_oper_2012	acres_per_oper_2013	acres_per_oper_2014	acres_per_oper_2015	acres_per_oper_2016	acres_per_oper_2017	acres_per_oper_2018	acres_per_oper_2019	acres_per_oper_2020	acres_per_oper_2021	acres_per_oper_2022"
	local income_decomp "IncomePerOperation_1997	IncomePerOperation_1998	IncomePerOperation_1999	IncomePerOperation_2000		IncomePerOperation_2002	IncomePerOperation_2003	IncomePerOperation_2004	IncomePerOperation_2005	IncomePerOperation_2006	IncomePerOperation_2007	IncomePerOperation_2008	IncomePerOperation_2009	IncomePerOperation_2010	IncomePerOperation_2011	IncomePerOperation_2012	IncomePerOperation_2013	IncomePerOperation_2014	IncomePerOperation_2015	IncomePerOperation_2016	IncomePerOperation_2017	IncomePerOperation_2018	IncomePerOperation_2019	IncomePerOperation_2020	IncomePerOperation_2021	IncomePerOperation_2022"
	
	local var_interest "prop_dairy acres_per_oper prop_Female InternetAccess IncomePerOperation AdjCompCPI age"
	
	// Internet
	xi: regress OwnOrLeaseComputers  prop_dairy acres_per_oper prop_Female IncomePerOperation AdjCompCPI age `controls' `internet_decomp'  `year' i.state, vce(cluster state)
		estimates store es_InternetAccess
		esttab es_InternetAccess, drop(`controls' _Istate_* year_*) stats (r2 N)	
			outreg2 using "Results\esInt_results_22", word excel replace
	// Age 	
	xi: regress OwnOrLeaseComputers  prop_dairy acres_per_oper prop_Female InternetAccess IncomePerOperation AdjCompCPI `controls' `age_decomp'  `year' i.state, vce(cluster state)
		estimates store es_age
		esttab es_age, drop(`controls' _Istate_* year_*) stats (r2 N)	
			outreg2 using "Results\esAge_results_22", word excel replace
	// Gender
	xi: regress OwnOrLeaseComputers  prop_dairy acres_per_oper InternetAccess IncomePerOperation AdjCompCPI age `controls' `gender_decomp'  `year' i.state, vce(cluster state)
		estimates store es_prop_Female
		esttab es_prop_Female, drop(`controls' _Istate_* year_*) stats (r2 N)	
			outreg2 using "Results\esFem_results_22", word excel replace
	// Dairy
	xi: regress OwnOrLeaseComputers acres_per_oper prop_Female InternetAccess IncomePerOperation AdjCompCPI age `controls' `prop_dairy_decomp'  `year' i.state, vce(cluster state)
		estimates store es_prop_dairy
		esttab es_prop_dairy, drop(`controls' _Istate_* year_*) stats (r2 N)	
			outreg2 using "Results\esDairy_results_22", word excel replace
	// CPI
	xi: regress OwnOrLeaseComputers  prop_dairy acres_per_oper prop_Female InternetAccess IncomePerOperation age `controls' `CPI_decomp'  `year' i.state, vce(cluster state)
		estimates store es_AdjCompCPI
	esttab es_AdjCompCPI, drop(`controls' _Istate_* year_*) stats (r2 N)	
			outreg2 using "Results\esCPI_results_22", word excel replace
	// Acres
	xi: regress OwnOrLeaseComputers prop_dairy prop_Female InternetAccess IncomePerOperation AdjCompCPI age  `controls' `acres_decomp'  `year' i.state, vce(cluster state)
		estimates store es_acres_per_oper
		esttab es_acres_per_oper, drop(`controls' _Istate_* year_*) stats (r2 N)	
			outreg2 using "Results\esAcres_results_22", word excel replace
	// Income
	xi: regress OwnOrLeaseComputers prop_dairy acres_per_oper prop_Female InternetAccess AdjCompCPI age `controls' `income_decomp'  `year' i.state, vce(cluster state)
		estimates store es_IncomePerOperation
	esttab es_IncomePerOperation, drop(`controls' _Istate_* year_*) stats (r2 N)	
			outreg2 using "Results\esInc_results_22", word excel replace

	
********************************************************************************
* 3. Charting the coefficients 
********************************************************************************
// For 2023 included:
// Looping to generate coefficient charts for each of the key variables 
	local var_interest "InternetAccess age prop_Female prop_dairy AdjCompCPI acres_per_oper IncomePerOperation"	
	
	foreach x in `var_interest'{
		local y "`x'_*"
	
	coefplot es_`x', recast(connected)  keep(`y' year_1997  ) ///
		ciopts(recast(rarea) color(emerald%25)) vertical  ///
		coeflabels(`x'_1997 = "97" `x'_1998 = "98" ///
		`x'_1999 = "99" `x'_2000 = "00" ///
		year_1997   = "01" ///
		`x'_2002   = "02" ///
		`x'_2003   = "03" ///
		`x'_2004   = "04" ///
		`x'_2005   = "05" ///
		`x'_2006   = "06" ///
		`x'_2007   = "07" ///
		`x'_2008   = "08" ///
		`x'_2009   = "09" ///
		`x'_2010   = "10" ///
		`x'_2011   = "11" ///
		`x'_2012   = "12" ///
		`x'_2013   = "13" ///
		`x'_2014   = "14" ///
		`x'_2015   = "15" ///
		`x'_2016   = "16" ///
		`x'_2017   = "17" ///
		`x'_2018   = "18" ///
		`x'_2019   = "19" ///
		`x'_2020   = "20" ///
		`x'_2021   = "21" ///
		`x'_2022   = "22" ///
		) ///
		omitted baselevels	///
		order(`x'_1997	`x'_1998	`x'_1999	`x'_2000	year_1997  	`x'_2002	`x'_2003	`x'_2004	`x'_2005	`x'_2006	`x'_2007	`x'_2008	`x'_2009	`x'_2010	`x'_2011	`x'_2012	`x'_2013	`x'_2014	`x'_2015	`x'_2016	`x'_2017	`x'_2018	`x'_2019	`x'_2020	`x'_2021	`x'_2022) title(Effect of `x' Across Time) ///
		xtitle(Event Year) ytitle(Marginal Effect)
			graph export "C:\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data\Charts\ES_`x'_22.png", as(png) name("Graph") replace
		
}

	log close 
exit

		
		
********************************************************************************
* 3. Generating Scatter Plots For Dairy Farms 
********************************************************************************
// Want to look at just 1997 and 2022, comparing start to end  (excl. 2023, because all of those values are imputed)
	keep if year == 1997 | year == 2022
	sort year
	keep state year OwnOrLeaseComputers prop_dairy
	drop if OwnOrLeaseComputers == .
	drop if state == "US"
	
// Copying to excel to create scatter plots 
