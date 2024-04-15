**************************************************************************
* Title: Data Visualization
* Authors: April Athnos & Joe Bronstein
* Last Updated: 3-27-2024
* Objective: To effectively visualize aggregated data
* Assumes: Data Arranging do file has already been run
**************************************************************************

**************************************************************************
* 0 - Selecting desired data
**************************************************************************

di c(hostname) 

    if "`c(hostname)'" == "AREC-ATHNOS" {
            cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein"
            }


    if "`c(hostname)'" == "JBRON-DESKTOP" {
            cd "\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data"
            }
			
// Selecting aggregated dataset
	use "Clean(ish) Datasets\merged_all_imputed.dta", clear
	
// Creating new variables for better aggregation
	gen state_1 = state

// Creating new variables to get data aggregated for combined states 
	egen avg_InternetAccess = mean(InternetAccess), by(state_1 year)
	egen avg_OwnOrLeaseComputers = mean(OwnOrLeaseComputers), by(state_1 year)
	egen avg_ComputersForFarmBusiness = mean(ComputersForFarmBusiness), by(state_1 year)
	
// Creating new variables to get regional averages for each year 
	egen reg_avg_InternetAccess = mean(InternetAccess), by(region year)
	egen reg_avg_OwnOrLeaseComputers = mean(OwnOrLeaseComputers), by(region year)
	egen reg_avg_ComputersForFarmBusiness = mean(ComputersForFarmBusiness), by(region year)
	
********************************************************************************
* 1 - Graphing Data
********************************************************************************
// Graphing OwnOrLeaseComputers and InternetAccess by state, with years on the x-axis 
// Dropping duplicate observations 
	duplicates report state_1 year
	duplicates drop state_1 year, force
	sort state_1 year

// Charting the graph	
	twoway (line reg_avg_OwnOrLeaseComputers year) (line reg_avg_InternetAccess year), by(state_1) ytitle("Share of Farms") xtitle("Year") xlabel(1997(4)2023) legend(order(1 "Own Or Lease Computers" 2 "Internet Access") position(6) ring(3) rows(1) cols(2))

// Graphing OwnOrLeaseComputers and InternetAccess by region, with years on the x-axis

*RE-RUN LINES 26-53

// For regional level graph:	
// Dropping duplicate observations 
	duplicates report region year
	duplicates drop region year, force
	sort region year
 
	twoway (line avg_OwnOrLeaseComputers year) (line avg_InternetAccess year), by(region) ytitle("Share of Farms") xtitle("Year") xlabel(1997(4)2023) legend(order(1 "Own Or Lease Computers" 2 "Internet Access") position(6) ring(3) rows(1) cols(2))

// Graphing OwnOrLeaseComputers and ComputersForFarmBusiness by state, with years on the x-axis

*RE-RUN LINES 26-53

// Drop missing values 
	drop if missing(avg_ComputersForFarmBusiness)

// Dropping duplicate observations 
	duplicates report state_1 year
	duplicates drop state_1 year, force
	sort state_1 year
 
	twoway (line avg_OwnOrLeaseComputers year) (line avg_ComputersForFarmBusiness year), by(state_1) ytitle("Share of Farms") xtitle("Year") xlabel(1997(4)2023) legend(order(1 "Own Or Lease Computers" 2 "Computers For Farm Business") position(6) ring(3) rows(1) cols(2))
	
// For Regional Level:

*RE-RUN LINES 26-53

// Drop missing values 
	drop if missing(reg_avg_ComputersForFarmBusiness)

// Dropping duplicate observations 
	duplicates report region year
	duplicates drop region year, force
	sort region year
 
	twoway (line reg_avg_OwnOrLeaseComputers year) (line reg_avg_ComputersForFarmBusiness year), by(region) ytitle("Share of Farms") xtitle("Year") xlabel(1997(4)2023) legend(order(1 "Own Or Lease Computers" 2 "Computers For Farm Business") position(6) ring(3) rows(1) cols(2))
	
********************************************************************************
* 2 - Graphing change in own or lease by region
********************************************************************************
	use "Clean(ish) Datasets\merged_all_imputed.dta", clear


// local list
	local region "West South Midwest Northeast"
	
// generating aggregated variables for each region
	foreach x in `region' {
		egen avg_`x'_OwnOrLease = mean(OwnOrLeaseComputers) if region == "`x'", by (year) 
		
	}
	
// trimming dataset
	keep year avg_West_OwnOrLease avg_South_OwnOrLease avg_Midwest_OwnOrLease avg_Northeast_OwnOrLease
// copied data to excel file to finish graphing, see average own or lease by region.xlsx

********************************************************************************
* 3 - Graphing change in CPI
********************************************************************************
	use "Clean(ish) Datasets\merged_all_imputed.dta", clear

// getting the cpi by year 
	keep if state == "AL" // same for every state, so doesn't matter, just need '97-'23
	keep year CompCPI
// Now using excel to graph, see cpi.xlsx

********************************************************************************
* 4 - Graphing change in internet access 
********************************************************************************
	use "Clean(ish) Datasets\merged_all_imputed.dta", clear


// local list
	local region "West South Midwest Northeast"
	
// generating aggregated variables for each region
	foreach x in `region' {
		egen avg_`x'_Internet = mean(InternetAccess) if region == "`x'", by (year) 
	}
	
// trimming dataset
	keep year avg_West_Internet avg_South_Internet avg_Midwest_Internet avg_Northeast_Internet
// copied data to excel file to finish graphing, see internet access over time.xlsx

********************************************************************************
* 5 - Solve for number who own or lease (% OwnOrLease * Total Operations)
********************************************************************************
	use "Clean(ish) Datasets\merged_all_imputed.dta", clear

// Aggregating total operations and % own or lease
	local important "OwnOrLeaseComputers TotalOperations"
	
	foreach x in `important'{
			egen avg_`x' = mean(`x'), by (year)
	}
	
// keeping only one time series of observations 
	keep if state == "AL"
	keep year avg_OwnOrLeaseComputers avg_TotalOperations
	
// Scale OwnOrLease to be between 0 and 1 (%)
	gen avg_OwnOrLeaseComputers_sca = avg_OwnOrLeaseComputers/100
	drop avg_OwnOrLeaseComputers
	
// Now calculating num own or lease 
	gen num_OwnOrLease = avg_OwnOrLeaseComputers_sca * avg_TotalOperations
	drop avg_TotalOperations avg_OwnOrLeaseComputers_sca
	
// export to excel to graph 

********************************************************************************
* 6 - Looking at how age bins change across time
********************************************************************************
	use "Clean(ish) Datasets\merged_all_imputed.dta", clear
	
// Calculating averages for each age bin
	local bin "prop25_34 prop35_44 prop45_54 prop55_64 prop65_74 propGE_75"
		foreach x in `bin'{
			egen avg_`x' = mean(`x'), by (year)
		}
		
// trimming the data for graphing purposes 
	keep if state == "AL"
	keep if year == 2023 | year == 2022 | year == 1997
	keep year avg_prop25_34 avg_prop35_44 avg_prop45_54 avg_prop55_64 avg_prop65_74 avg_propGE_75
	
// moving to excel to graph
