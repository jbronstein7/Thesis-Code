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
	
// Creating local lists for key variables 
	local bin_age "prop25_34 prop35_44 prop45_54 prop65_74 propGE_75"
	// Using the 55 to 64 age group as baseline, since that encompasses the avg. age 
	
	local ethnicity "prop_Asian prop_AfricanAmerican prop_Hispanic prop_Multi prop_Pacific"
	// Using prop_white as baseline 
	
	local controls "prop_crop avg_hhsize prop_poultry prop_OffFarm `ethnicity'"
	// Variables that seem important to control for, but were not mentioned as determinants of adoption in the literature 
	
	local var_interest "prop_dairy acres_per_oper prop_Female InternetAccess IncomePerOperation AdjCompCPI year age"
	// variables mentioned as singificant in the literaure 
/*
********************************************************************************
* 1. TWFE - Comparing 4 models
********************************************************************************
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
	outreg2 [OLS state_fixed year_fixed twfe] using "Results\twfe_regression_results", word excel replace
*/
	capture log close
	log using "event study April 3_28_24", replace	
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
		
	// Dropping all 2001, to omit base period
		local base "prop_dairy_2001 acres_per_oper_2001 prop_Female_2001 InternetAccess_2001 IncomePerOperation_2001 AdjCompCPI_2001 prop25_34_2001 prop35_44_2001 prop45_54_2001 prop65_74_2001 propGE_75_2001"
		
/*
		// Setting 2001 interactions = 0
		foreach y in `base'{ 
			forval x=1997/2023{
				replace `y' = 0 if year == `x'
			}
		}
		// now 2001 interactions are present, but always = 0 
*/		
		
// Creating a local to refer to interaction terms
	local var_interactions "AdjCompCPI_1997 prop25_34_1997 prop35_44_1997 prop45_54_1997 prop65_74_1997 propGE_75_1997 prop_dairy_1998 acres_per_oper_1998 prop_Female_1998 InternetAccess_1998 IncomePerOperation_1998 AdjCompCPI_1998 prop25_34_1998 prop35_44_1998 prop45_54_1998 prop65_74_1998 propGE_75_1998 prop_dairy_1999 acres_per_oper_1999 prop_Female_1999 InternetAccess_1999 IncomePerOperation_1999 AdjCompCPI_1999 prop25_34_1999 prop35_44_1999 prop45_54_1999 prop65_74_1999 propGE_75_1999 prop_dairy_2000 acres_per_oper_2000 prop_Female_2000 InternetAccess_2000 IncomePerOperation_2000 AdjCompCPI_2000 prop25_34_2000 prop35_44_2000 prop45_54_2000 prop65_74_2000 propGE_75_2000 prop_dairy_2001 acres_per_oper_2001 prop_Female_2001 InternetAccess_2001 IncomePerOperation_2001 AdjCompCPI_2001 prop25_34_2001 prop35_44_2001 prop45_54_2001 prop65_74_2001 propGE_75_2001 prop_dairy_2002 acres_per_oper_2002 prop_Female_2002 InternetAccess_2002 IncomePerOperation_2002 AdjCompCPI_2002 prop25_34_2002 prop35_44_2002 prop45_54_2002 prop65_74_2002 propGE_75_2002 prop_dairy_2003 acres_per_oper_2003 prop_Female_2003 InternetAccess_2003 IncomePerOperation_2003 AdjCompCPI_2003 prop25_34_2003 prop35_44_2003 prop45_54_2003 prop65_74_2003 propGE_75_2003 prop_dairy_2004 acres_per_oper_2004 prop_Female_2004 InternetAccess_2004 IncomePerOperation_2004 AdjCompCPI_2004 prop25_34_2004 prop35_44_2004 prop45_54_2004 prop65_74_2004 propGE_75_2004 prop_dairy_2005 acres_per_oper_2005 prop_Female_2005 InternetAccess_2005 IncomePerOperation_2005 AdjCompCPI_2005 prop25_34_2005 prop35_44_2005 prop45_54_2005 prop65_74_2005 propGE_75_2005 prop_dairy_2006 acres_per_oper_2006 prop_Female_2006 InternetAccess_2006 IncomePerOperation_2006 AdjCompCPI_2006 prop25_34_2006 prop35_44_2006 prop45_54_2006 prop65_74_2006 propGE_75_2006 prop_dairy_2007 acres_per_oper_2007 prop_Female_2007 InternetAccess_2007 IncomePerOperation_2007 AdjCompCPI_2007 prop25_34_2007 prop35_44_2007 prop45_54_2007 prop65_74_2007 propGE_75_2007 prop_dairy_2008 acres_per_oper_2008 prop_Female_2008 InternetAccess_2008 IncomePerOperation_2008 AdjCompCPI_2008 prop25_34_2008 prop35_44_2008 prop45_54_2008 prop65_74_2008 propGE_75_2008 prop_dairy_2009 acres_per_oper_2009 prop_Female_2009 InternetAccess_2009 IncomePerOperation_2009 AdjCompCPI_2009 prop25_34_2009 prop35_44_2009 prop45_54_2009 prop65_74_2009 propGE_75_2009 prop_dairy_2010 acres_per_oper_2010 prop_Female_2010 InternetAccess_2010 IncomePerOperation_2010 AdjCompCPI_2010 prop25_34_2010 prop35_44_2010 prop45_54_2010 prop65_74_2010 propGE_75_2010 prop_dairy_2011 acres_per_oper_2011 prop_Female_2011 InternetAccess_2011 IncomePerOperation_2011 AdjCompCPI_2011 prop25_34_2011 prop35_44_2011 prop45_54_2011 prop65_74_2011 propGE_75_2011 prop_dairy_2012 acres_per_oper_2012 prop_Female_2012 InternetAccess_2012 IncomePerOperation_2012 AdjCompCPI_2012 prop25_34_2012 prop35_44_2012 prop45_54_2012 prop65_74_2012 propGE_75_2012 prop_dairy_2013 acres_per_oper_2013 prop_Female_2013 InternetAccess_2013 IncomePerOperation_2013 AdjCompCPI_2013 prop25_34_2013 prop35_44_2013 prop45_54_2013 prop65_74_2013 propGE_75_2013 prop_dairy_2014 acres_per_oper_2014 prop_Female_2014 InternetAccess_2014 IncomePerOperation_2014 AdjCompCPI_2014 prop25_34_2014 prop35_44_2014 prop45_54_2014 prop65_74_2014 propGE_75_2014 prop_dairy_2015 acres_per_oper_2015 prop_Female_2015 InternetAccess_2015 IncomePerOperation_2015 AdjCompCPI_2015 prop25_34_2015 prop35_44_2015 prop45_54_2015 prop65_74_2015 propGE_75_2015 prop_dairy_2016 acres_per_oper_2016 prop_Female_2016 InternetAccess_2016 IncomePerOperation_2016 AdjCompCPI_2016 prop25_34_2016 prop35_44_2016 prop45_54_2016 prop65_74_2016 propGE_75_2016 prop_dairy_2017 acres_per_oper_2017 prop_Female_2017 InternetAccess_2017 IncomePerOperation_2017 AdjCompCPI_2017 prop25_34_2017 prop35_44_2017 prop45_54_2017 prop65_74_2017 propGE_75_2017 prop_dairy_2018 acres_per_oper_2018 prop_Female_2018 InternetAccess_2018 IncomePerOperation_2018 AdjCompCPI_2018 prop25_34_2018 prop35_44_2018 prop45_54_2018 prop65_74_2018 propGE_75_2018 prop_dairy_2019 acres_per_oper_2019 prop_Female_2019 InternetAccess_2019 IncomePerOperation_2019 AdjCompCPI_2019 prop25_34_2019 prop35_44_2019 prop45_54_2019 prop65_74_2019 propGE_75_2019 prop_dairy_2020 acres_per_oper_2020 prop_Female_2020 InternetAccess_2020 IncomePerOperation_2020 AdjCompCPI_2020 prop25_34_2020 prop35_44_2020 prop45_54_2020 prop65_74_2020 propGE_75_2020 prop_dairy_2021 acres_per_oper_2021 prop_Female_2021 InternetAccess_2021 IncomePerOperation_2021 AdjCompCPI_2021 prop25_34_2021 prop35_44_2021 prop45_54_2021 prop65_74_2021 propGE_75_2021 prop_dairy_2022 acres_per_oper_2022 prop_Female_2022 InternetAccess_2022 IncomePerOperation_2022 AdjCompCPI_2022 prop25_34_2022 prop35_44_2022 prop45_54_2022 prop65_74_2022 propGE_75_2022 prop_dairy_2023 acres_per_oper_2023 prop_Female_2023 InternetAccess_2023 IncomePerOperation_2023 AdjCompCPI_2023 prop25_34_2023 prop35_44_2023 prop45_54_2023 prop65_74_2023 propGE_75_2023"
	local var_interest "acres_per_oper prop_Female prop_dairy InternetAccess IncomePerOperation  prop25_34 prop35_44 prop45_54 prop65_74 propGE_75"
	

// NEW! 
// I want to decompose each of the variables of interest individually (with 2023)
	local CPI_decomp "AdjCompCPI_1997  AdjCompCPI_1998	AdjCompCPI_1999	AdjCompCPI_2000 	AdjCompCPI_2002	AdjCompCPI_2003	AdjCompCPI_2004	AdjCompCPI_2005	AdjCompCPI_2006	AdjCompCPI_2007	AdjCompCPI_2008	AdjCompCPI_2009	AdjCompCPI_2010	AdjCompCPI_2011	AdjCompCPI_2012	AdjCompCPI_2013	AdjCompCPI_2014	AdjCompCPI_2015	AdjCompCPI_2016	AdjCompCPI_2017	AdjCompCPI_2018	AdjCompCPI_2019	AdjCompCPI_2020	AdjCompCPI_2021	AdjCompCPI_2022	AdjCompCPI_2023"
	local prop_dairy_decomp "prop_dairy_1997 prop_dairy_1998	prop_dairy_1999	prop_dairy_2000 prop_dairy_2002	prop_dairy_2003	prop_dairy_2004	prop_dairy_2005	prop_dairy_2006	prop_dairy_2007	prop_dairy_2008	prop_dairy_2009	prop_dairy_2010	prop_dairy_2011	prop_dairy_2012	prop_dairy_2013	prop_dairy_2014	prop_dairy_2015	prop_dairy_2016	prop_dairy_2017	prop_dairy_2018	prop_dairy_2019	prop_dairy_2020	prop_dairy_2021	prop_dairy_2022	prop_dairy_2023"
	local year "year_1997	year_1998	year_1999	year_2000 year_2001 year_2002	year_2003	year_2004	year_2005	year_2006	year_2007	year_2008	year_2009	year_2010	year_2011	year_2012	year_2013	year_2014	year_2015	year_2016	year_2017	year_2018	year_2019	year_2020	year_2021	year_2022	year_2023"
	local gender_decomp	"prop_Female_1997	prop_Female_1998	prop_Female_1999	prop_Female_2000		prop_Female_2002	prop_Female_2003	prop_Female_2004	prop_Female_2005	prop_Female_2006	prop_Female_2007	prop_Female_2008	prop_Female_2009	prop_Female_2010	prop_Female_2011	prop_Female_2012	prop_Female_2013	prop_Female_2014	prop_Female_2015	prop_Female_2016	prop_Female_2017	prop_Female_2018	prop_Female_2019	prop_Female_2020	prop_Female_2021	prop_Female_2022	prop_Female_2023"
	local age_decomp "age_1997	age_1998	age_1999	age_2000		age_2002	age_2003	age_2004	age_2005	age_2006	age_2007	age_2008	age_2009	age_2010	age_2011	age_2012	age_2013	age_2014	age_2015	age_2016	age_2017	age_2018	age_2019	age_2020	age_2021	age_2022	age_2023"
	local internet_decomp "InternetAccess_1997	InternetAccess_1998	InternetAccess_1999	InternetAccess_2000		InternetAccess_2002	InternetAccess_2003	InternetAccess_2004	InternetAccess_2005	InternetAccess_2006	InternetAccess_2007	InternetAccess_2008	InternetAccess_2009	InternetAccess_2010	InternetAccess_2011	InternetAccess_2012	InternetAccess_2013	InternetAccess_2014	InternetAccess_2015	InternetAccess_2016	InternetAccess_2017	InternetAccess_2018	InternetAccess_2019	InternetAccess_2020	InternetAccess_2021	InternetAccess_2022	InternetAccess_2023"
	local acres_decomp "acres_per_oper_1997	acres_per_oper_1998	acres_per_oper_1999	acres_per_oper_2000		acres_per_oper_2002	acres_per_oper_2003	acres_per_oper_2004	acres_per_oper_2005	acres_per_oper_2006	acres_per_oper_2007	acres_per_oper_2008	acres_per_oper_2009	acres_per_oper_2010	acres_per_oper_2011	acres_per_oper_2012	acres_per_oper_2013	acres_per_oper_2014	acres_per_oper_2015	acres_per_oper_2016	acres_per_oper_2017	acres_per_oper_2018	acres_per_oper_2019	acres_per_oper_2020	acres_per_oper_2021	acres_per_oper_2022 acres_per_oper_2023"
	local income_decomp "IncomePerOperation_1997	IncomePerOperation_1998	IncomePerOperation_1999	IncomePerOperation_2000		IncomePerOperation_2002	IncomePerOperation_2003	IncomePerOperation_2004	IncomePerOperation_2005	IncomePerOperation_2006	IncomePerOperation_2007	IncomePerOperation_2008	IncomePerOperation_2009	IncomePerOperation_2010	IncomePerOperation_2011	IncomePerOperation_2012	IncomePerOperation_2013	IncomePerOperation_2014	IncomePerOperation_2015	IncomePerOperation_2016	IncomePerOperation_2017	IncomePerOperation_2018	IncomePerOperation_2019	IncomePerOperation_2020	IncomePerOperation_2021	IncomePerOperation_2022 IncomePerOperation_2023"
// I used this to display the entire list of interactions so I could do some transposing and find and replace to get lists more quickly
/*	
	forval x = 1997/2023 {
	di "AdjCompCPI_`x'"
	}
*/	

// 	encode state, gen(State)
// 	drop state
// 	rename State state
// 	*xtset state year, yearly
	*xi: regress OwnOrLeaseComputers  `controls' `var_interest' `prop_dairy_decomp'  `year' i.state, vce(cluster state)
	*xi: regress OwnOrLeaseComputers  `controls' `var_interest' `gender_decomp'  `year' i.state, vce(cluster state)
	*xi: regress OwnOrLeaseComputers  `controls' `var_interest' `age_decomp'  `year' i.state, vce(cluster state)
	
	// Internet
	xi: regress OwnOrLeaseComputers  `controls' `var_interest' `internet_decomp'  `year' i.state, vce(cluster state)
		estimates store es_InternetAccess
		
	// Age 	
	xi: regress OwnOrLeaseComputers  `controls' `var_interest' `age_decomp'  `year' i.state, vce(cluster state)
		estimates store es_age
		
	// Gender
	xi: regress OwnOrLeaseComputers  `controls' `var_interest' `gender_decomp'  `year' i.state, vce(cluster state)
		estimates store es_prop_Female
		
	// Dairy
	xi: regress OwnOrLeaseComputers  `controls' `var_interest' `prop_dairy_decomp'  `year' i.state, vce(cluster state)
		estimates store es_prop_dairy
		
	// CPI
	xi: regress OwnOrLeaseComputers  `controls' `var_interest' `CPI_decomp'  `year' i.state, vce(cluster state)
		estimates store es_AdjCompCPI
	
	// Acres
	xi: regress OwnOrLeaseComputers  `controls' `var_interest' `acres_decomp'  `year' i.state, vce(cluster state)
		estimates store es_acres_per_oper
		
	// Income
	xi: regress OwnOrLeaseComputers  `controls' `var_interest' `income_decomp'  `year' i.state, vce(cluster state)
		estimates store es_IncomePerOperation
		
	*xtreg  OwnOrLeaseComputers  `controls' `var_interest' `prop_dairy_decomp'  `year' , vce(cluster state) fe allbase	
	*xtreg  OwnOrLeaseComputers  `controls' `var_interest' `gender_decomp'  `year' , vce(cluster state) fe allbase	
	*xtreg  OwnOrLeaseComputers  `controls' `var_interest' `CPI_decomp'  `year', vce(cluster state) fe allbase

	
	*esttab event_study, drop(`controls' _Istate_*) stats (r2 N)	
	*outreg2 using "Results\event_study_results_april", word excel replace

	
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
		`x'_2023   = "23" ///
		) ///
		omitted baselevels	///
		order(`x'_1997	`x'_1998	`x'_1999	`x'_2000	year_1997  	`x'_2002	`x'_2003	`x'_2004	`x'_2005	`x'_2006	`x'_2007	`x'_2008	`x'_2009	`x'_2010	`x'_2011	`x'_2012	`x'_2013	`x'_2014	`x'_2015	`x'_2016	`x'_2017	`x'_2018	`x'_2019	`x'_2020	`x'_2021	`x'_2022	`x'_2023) title(Effect of `x' Across Time) ///
		xtitle(Event Year) ytitle(Marginal Effect)
			graph export "C:\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data\Charts\ES_`x'_23.png", as(png) name("Graph") replace
		
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
