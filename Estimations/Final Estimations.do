********************************************************************************
* Title: Final Estimations
* Author: Joe Bronstein
*		  April Athnos
* Purpose: To estimate final models for paper/presentation
*		   To investigate the shapes of the event study output
* Last Modified: 4/22/2024
* Assumes: All other data arranging files have been run, and imputed dataset is available 
********************************************************************************
	di c(hostname) 

		if "`c(hostname)'" == "AREC-ATHNOS" {
				cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein"
				}


		if "`c(hostname)'" == "JBRON-DESKTOP" {
				cd "\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data"
				}

// Installing required packages (un-comment to install if not already)
/*
	ssc install estout	
	ssc install *outreg2
	ssc install coefplot
*/

********************************************************************************
* 0. Loading in cleaned, imputed dataset, and creating local lists 
********************************************************************************
// use cleaned imputed dataset
	use "clean(ish) datasets\merged_all_imputed.dta", clear 
	
// dropping 2023 
	drop if year == 2023 // comment out if want to see results with 2023
	// 42 obs deleted
	
// Dividing income by 1,000
	replace IncomePerOperation = IncomePerOperation/1000
	
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
*log using "twfe model 2022", replace
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
	*outreg2 [OLS state_fixed year_fixed twfe] using "Results\twfe_results_22", word excel replace

	capture log close
	
********************************************************************************
* 2. Second model - Event Study 
********************************************************************************
*log using "event study 2022", replace	

	local var_interest "prop_dairy acres_per_oper prop_Female InternetAccess IncomePerOperation AdjCompCPI age"
// Generating interaction terms

	foreach y in `var_interest'{
		forval x=1997/2022 {
			gen `y'_`x' = `y' if year == `x'
			replace `y'_`x' = 0 if year != `x'
			capture drop `y'_2001
			}
		}

*By including the wildcard, i.e InternetAccess* I am including InternetAccess and every year interaction except 2001 which I forcibly dropped.
*2001 is your base year. Everything else is normalized to that. 		
	
	// Internet
	xi: regress OwnOrLeaseComputers  `controls'  prop_dairy acres_per_oper prop_Female IncomePerOperation AdjCompCPI age InternetAccess*  i.year i.state, vce(cluster state)	
		estimates store es_InternetAccess
		esttab es_InternetAccess, drop(`controls' _Istate_*  _Iyear_*) stats (r2 N)	
			outreg2 using "Results\esInt_results_22", word excel replace
			local base_InternetAccess = round(_b[InternetAccess], 0.0001)

						
	// Age 	
	xi: regress OwnOrLeaseComputers  `controls'  prop_dairy acres_per_oper prop_Female IncomePerOperation AdjCompCPI  InternetAccess age*  i.year i.state, vce(cluster state)	
		estimates store es_age
		esttab es_age, drop(`controls' _Istate_*  _Iyear_*) stats (r2 N)	
			outreg2 using "Results\esAge_results_22", word excel replace
				local base_age = round(_b[age], 0.0001)

	// Gender
	xi: regress OwnOrLeaseComputers  `controls' prop_dairy InternetAccess acres_per_oper IncomePerOperation AdjCompCPI age prop_Female* i.year i.state, vce(cluster state)
		estimates store es_prop_Female
		esttab es_prop_Female, drop(`controls' _Istate_*  _Iyear_*) stats (r2 N)	
			outreg2 using "Results\esFem_results_22", word excel replace
				local base_prop_Female = round(_b[prop_Female], 0.0001)
	
	// Dairy
	xi: regress OwnOrLeaseComputers  `controls' InternetAccess acres_per_oper prop_Female IncomePerOperation AdjCompCPI age prop_dairy*  i.year i.state, vce(cluster state)
		estimates store es_prop_dairy
		esttab es_prop_dairy, drop(`controls' _Istate_*  _Iyear_*) stats (r2 N)	
			outreg2 using "Results\esDairy_results_22", word excel replace
			local base_prop_dairy = round(_b[prop_dairy], 0.0001)
	
	// CPI
	xi: regress OwnOrLeaseComputers  `controls' prop_dairy InternetAccess acres_per_oper prop_Female IncomePerOperation age AdjCompCPI*  i.year i.state, vce(cluster state)
		estimates store es_AdjCompCPI
	esttab es_AdjCompCPI, drop(`controls' _Istate_*  _Iyear_*) stats (r2 N)	
			outreg2 using "Results\esCPI_results_22", word excel replace
			local base_AdjCompCPI = round(_b[AdjCompCPI], 0.0001)		
	
	// Acres
	xi: regress OwnOrLeaseComputers  `controls' prop_dairy InternetAccess prop_Female IncomePerOperation AdjCompCPI age acres_per_oper*  i.year i.state, vce(cluster state)
		estimates store es_acres_per_oper
		esttab es_acres_per_oper, drop(`controls' _Istate_*  _Iyear_*) stats (r2 N)	
			outreg2 using "Results\esAcres_results_22", word excel replace
			local base_acres_per_oper = round(_b[acres_per_oper], 0.0001)
	
	// Income
	xi: regress OwnOrLeaseComputers  `controls' prop_dairy InternetAccess acres_per_oper prop_Female AdjCompCPI age IncomePerOperation* i.year i.state, vce(cluster state)
		estimates store es_IncomePerOperation
	esttab es_IncomePerOperation, drop(`controls' _Istate_*  _Iyear_*) stats (r2 N)	
			outreg2 using "Results\esInc_results_22", word excel replace
			local base_IncomePerOperation = round(_b[IncomePerOperation], 0.0001)

	
********************************************************************************
* 3. Charting the coefficients 
********************************************************************************
// For 2023 included:
// Looping to generate coefficient charts for each of the key variables 
	local var_interest "InternetAccess age prop_Female prop_dairy AdjCompCPI acres_per_oper IncomePerOperation"	
	
	foreach x in `var_interest'{
		local y "`x'_*"
	
	coefplot es_`x', recast(connected)  keep(`y' _Istate_6  ) ///
		ciopts(recast(rarea) color(emerald%25)) vertical  ///
		coeflabels(`x'_1997 = "97" `x'_1998 = "98" ///
		`x'_1999 = "99" `x'_2000 = "00" ///
		_Istate_6   = "01" ///
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
		order(`x'_1997	`x'_1998	`x'_1999	`x'_2000	_Istate_6 	`x'_2002	`x'_2003	`x'_2004	`x'_2005	`x'_2006	`x'_2007	`x'_2008	`x'_2009	`x'_2010	`x'_2011	`x'_2012	`x'_2013	`x'_2014	`x'_2015	`x'_2016	`x'_2017	`x'_2018	`x'_2019	`x'_2020	`x'_2021	`x'_2022) title({bf:Effect of `x' Across Time}) ///
		xtitle({bf:Event Year}) ytitle({bf:Marginal Effect}) caption("This graph presents the estimated slope coefficients and 95% confidence intervals of" "`x' interacted with year as well as a full set of controls, state FE, and year FE." "Presented estimates are relative to base year 2001, when {&beta}{subscript:`x',2001} = `base_`x''", size(small) )
			graph export "C:\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data\Charts\ES_`x'_22.png", as(png) name("Graph") replace
		sleep 10000
}
exit
	log close 


		
		
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
