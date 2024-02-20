********************************************************************************
* Title: Clean Data Arranging 
* Author: Joe Bronstein
* Purpose: To merge cleaned datasets into a larger one 
* Last Modified: 1/24/2024
* Assumes: Data Arranging file and USDA and CPI cleaning files have been run
********************************************************************************
	di c(hostname) 

		if "`c(hostname)'" == "AREC-ATHNOS" {
				cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein\Clean(ish) Datasets"
				}


		if "`c(hostname)'" == "JBRON-DESKTOP" {
				cd "\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data\Clean(ish) Datasets"
				}

*************************************
* 1. Starting with USDA NASS data
*************************************
// Selecting acres as first dataset
	use "clean_acres.dta", clear 
	
// Merge the age dataset using state and year
	merge 1:1 state year using "clean_age.dta"
	drop _merge

// Merge crop data
	merge 1:1 state year using "clean_crop.dta"
	drop _merge

// Merge dairy data
	merge 1:1 state year using "clean_dairy.dta"
	drop _merge	
	sort state year

// Merge ethnicity and gender data
	merge 1:1 state year using "clean_ethnicitygender.dta"
	drop _merge	
	sort state year

// Merge income data
	merge 1:1 state year using "clean_income.dta"
	destring IncomePerOperation, replace ignore(",")
	drop _merge	
	sort state year

// Merge Off-Farm Labor data
	merge 1:1 state year using "clean_OffFarm.dta"
	destring NumOffFarm, replace ignore(",")
	drop _merge	
	sort state year
	
// Merge operations data
	merge 1:1 state year using "clean_operations.dta"
	destring TotalOperations, replace ignore(",")
	drop _merge	
	sort state year
	
// Merge poultry data
	merge 1:1 state year using "clean_poultry.dta"
	destring NumPoultry, replace ignore(",")
	drop _merge	
	sort state year

// Merge experience and persons in household 
	merge 1:1 state year using "clean_HouseSize_Experience.dta"
	drop _merge	
	sort state year
	
// Adding labels
// For ethnicity 
	local ethnicity Asian AfricanAmerican Hispanic Multi Pacific White
		foreach x in `ethnicity'{
		label variable Num`x' "Count of `x' farmers"
	}
	
// For operation type 
	local other Poultry Crop
	foreach x in `other'{
		label variable Num`x' "Count of `x' farms"
	}
	label variable DairyOperation "Count of dairy operations" // dairy count 
	label variable NumOffFarm "Number of primary producers/operatiors who have primary occupation off farm"
	label variable TotalOperations "Total number of operations"
	label variable TotalAcres "Total acreage of all operations"
	label variable IncomePerOperation "Farm related income per operation ($)"
	
// Now have singular dataset with all USDA NASS data
	save "USDA_merged.dta", replace
	
***********************************************
* 1a Converting Counts To Proportions  
***********************************************
// Sum up total 
	egen sum_demographics = rowtotal(NumAsian NumAfricanAmerican NumHispanic NumMulti NumPacific NumWhite)
	
// Creating a local set of variables for ethnicity
	local demographics Asian AfricanAmerican Hispanic Multi Pacific White
	
// Creating a loop to generate new proportion variables for each ethnicity category 
	foreach x in `demographics'{
		gen prop_`x' = (Num`x' / sum_demographics) * 100
		label variable prop_`x' "Proportion of `x' farms"
	}
	drop sum_demographics
	
// For gender 
	local gender Male Female
	foreach x in `gender'{
		gen prop_`x' = (Num`x' / (NumMale + NumFemale)) * 100
		label variable prop_`x' "Proportion of `x' farms"
		label variable Num`x' "Count of `x' farms"
	}

// Commodities 
	gen prop_crop = (NumCrop / TotalOperations) * 100
	gen prop_dairy = (DairyOperations / TotalOperations) * 100
	gen acres_per_oper = (TotalAcres / TotalOperations) * 100
	// Adding labels 
	label variable prop_crop "Proportion of Crop Operations"
	label variable prop_dairy "Proportion of dairy operations"
	label variable acres_per_oper "Acres Per Operation"
	
// Household size 
	gen avg_hhsize = (HouseholdSize / TotalOperations)
	label variable avg_hhsize "Average Household Size"

// Label age 
	label variable age "average age"
*************************************
* 2. Merging grouped age data
*************************************
// merging one to one by state year 
	merge 1:1 state year using "Clean_Age_PropByGroup.dta"
	drop _merge	
	sort state year
	
*************************************
* 3. Merging tech data
*************************************
// merging one to one by state year 
	merge 1:1 state year using "all_data.dta"
	drop _merge	
	sort state year

// labels 
	label variable OwnOrLeaseComputers "Proportion who own or lease computers"
	label variable ComputersForFarmBusiness "Proportion who use computers for farm business"
	label variable InternetAccess "Proportion with internet access"
	label variable ComputerAccess "Proportion with computer access"
	label variable SmartPhoneTabletFarmBusiness "Proportion who use smart phones or tablets for farm business"
	label variable SmartPhone "Proporiton who have a smart phone"

*************************************
* 4. Next merging CPI data
*************************************
// Merging one to many by year (will have duplicates)
	merge m:m year using "cpi_merged.dta"
	drop _merge	
	sort state year
	
*************************************
* 5. General modifications
*************************************	
// Ordering 
	order state region year OwnOrLeaseComputers
	rename region division // to be consistent with census definition
	
// Dropping Alaska, Hawaii, and DC, they are not present in dependent variable
	drop if state == "AK" | state == "HI" | state == "DC"
	*48 obs deleted

	
save "merged_all.dta", replace