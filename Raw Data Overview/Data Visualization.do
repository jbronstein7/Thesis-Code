**************************************************************************
*
* Title: Data Visualization
* Authors: April Athnos & Joe Bronstein
* Last Updated: 10-29-2023
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
	gen region = ""
		replace region = "New England" if state == "CT" | state == "ME" | state == "MA" | state == "NH" | state == "RI" | state == "VT"
		replace region = "Middle Atlantic" if state == "NJ" | state == "NY" | state == "PA"
		replace region = "East North Central" if state == "IL" | state == "IN" | state == "MI" | state == "OH" | state == "WI"
		replace region = "West North Central" if state == "IA" | state == "KS" | state == "MN" | state == "MO" | state == "NE" | state == "ND" | state == "SD"
		replace region = "South Atlantic" if state == "DE" | state == "DC" | state == "FL" | state == "GA" | state == "MD" | state == "NC" | state == "SC" | state == "VA" | state == "WV"
		replace region = "East South Central" if state == "AL" | state == "KY" | state == "MS" | state == "TN"
		replace region = "West South Central" if state == "AR" | state == "LA" | state == "OK" | state == "TX"
		replace region = "Mountain" if state == "AZ" | state == "CO" | state == "ID" | state == "MT" | state == "NV" | state == "NM" | state == "UT" | state == "WY"
		replace region = "Pacific" if state == "AK" | state == "CA" | state == "HI" | state == "OR" | state == "WA"

// Now combining states that were combined in USDA data to improve comprability 
	replace state_1 = "CO" if state_1 == "AZ" | state_1 == "NV" | state_1 == "NM" | state_1 == "UT" | state_1 == "WY"
	replace state_1 = "NH" if state_1 == "CT" | state_1 == "ME" | state_1 == "MA" | state_1 == "RI" | state_1 == "VT"
	replace state_1 = "PA" if state_1 == "NJ"
	replace state_1 = "VA" if state_1 == "DE" | state_1 == "MD" | state_1 == "WV"

// Creating new variables to get data aggregated for combined states 
	egen avg_InternetAccess = mean(InternetAccess), by(state_1 year)
	egen avg_OwnOrLeaseComputers = mean(OwnOrLeaseComputers), by(state_1 year)
	egen avg_ComputersForFarmBusiness = mean(ComputersForFarmBusiness), by(state_1 year)
	
// Creating new variables to get regional averages for each year 
	egen reg_avg_InternetAccess = mean(InternetAccess), by(region year)
	egen reg_avg_OwnOrLeaseComputers = mean(OwnOrLeaseComputers), by(region year)
	egen reg_avg_ComputersForFarmBusiness = mean(ComputersForFarmBusiness), by(region year)
	
**************************************************************************
* 1 - Graphing Data
**************************************************************************
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
	

