********************************************************************************
* Title: Data Imputation
* Author: Joe Bronstein
* Purpose: To impute missing values and form complete dataset to use for modeling 
* Last Modified: 2/22/2024
* Assumes: All other data arranging files have been run
********************************************************************************
	di c(hostname) 

		if "`c(hostname)'" == "AREC-ATHNOS" {
				cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein\Clean(ish) Datasets"
				}


		if "`c(hostname)'" == "JBRON-DESKTOP" {
				cd "\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data\Clean(ish) Datasets"
				}

********************************************************************************
* 0 Importing dataset and merging
********************************************************************************
	use "Merged_all.dta", clear
	
********************************************************************************
* 1 Imputing USDA data points 
********************************************************************************
// Sort the data
	sort state year
	
// Identifying variables to impute 
	local missings TotalAcres age NumCrop NumAsian NumAfricanAmerican NumHispanic NumMulti NumPacific NumWhite NumMale NumFemale IncomePerOperation NumOffFarm TotalOperations NumPoultry HouseholdSize Experience prop_Asian prop_AfricanAmerican prop_Hispanic prop_Multi prop_Pacific prop_White prop_Male prop_Female prop_crop prop_dairy acres_per_oper prop25_34 prop35_44 prop45_54 prop55_64 prop65_74 propGE_75 avg_hhsize

// Creating a loop to impute missings
	foreach x in `missings'{
		replace `x' = `x'[_n-1] + ((`x'[_n+4] - `x'[_n-1]) / 5) if missing(`x') 
		replace `x' = `x'[_n-3] + ((`x'[_n+1] - `x'[_n-3]) / 4) if missing(`x')
		replace `x' = `x'[_n-2] + ((`x'[_n+1] - `x'[_n-2]) / 3) if missing(`x')
		replace `x' = (`x'[_n-1] + `x'[_n+1]) / 2 if missing(`x')
	}
	save "merged_all_imputed.dta", replace
	
**************************************************************************
* 2 Matching states to census divisions (already in data)
**************************************************************************
// Division grouping pulled from census website 
	replace division = "New England" if state == "CT" | state == "ME" | state == "MA" | state == "NH" | state == "RI" | state == "VT"
	replace division = "Middle Atlantic" if state == "NJ" | state == "NY" | state == "PA"
	replace division = "East North Central" if state == "IL" | state == "IN" | state == "MI" | state == "OH" | state == "WI"
	replace division = "West North Central" if state == "IA" | state == "KS" | state == "MN" | state == "MO" | state == "NE" | state == "ND" | state == "SD"
	replace division = "South Atlantic" if state == "DE" | state == "DC" | state == "FL" | state == "GA" | state == "MD" | state == "NC" | state == "SC" | state == "VA" | state == "WV"
	replace division = "East South Central" if state == "AL" | state == "KY" | state == "MS" | state == "TN"
	replace division = "West South Central" if state == "AR" | state == "LA" | state == "OK" | state == "TX"
	replace division = "Mountain" if state == "AZ" | state == "CO" | state == "ID" | state == "MT" | state == "NV" | state == "NM" | state == "UT" | state == "WY"
	replace division = "Pacific" if state == "AK" | state == "CA" | state == "HI" | state == "OR" | state == "WA"
// Now have divisions associated with all states 

**************************************************************************
* 3 Matching states to census regions (need to create new variable)
**************************************************************************
// Creating region variable
	gen region = " "

// Now using divisons to find associated regions 
	replace region = "Northeast" if division == "New England" | division == "Middle Atlantic"
	replace region = "Midwest" if division == "East North Central" | division == "West North Central"
	replace region = "South" if division == "South Atlantic" | division == "East South Central" | division == "West South Central"
	replace region = "West" if division == "Mountain" | division == "Pacific"
// Now have regions associated with all states 

order state division region

save "merged_all_imputed.dta", replace 	
********************************************************************************
* 4 Filling in missings for tech variables (every other year)
********************************************************************************
// Creating local set called tech to reference variables 
	local tech OwnOrLeaseComputers ComputersForFarmBusiness InternetAccess ComputerAccess SmartPhoneTabletFarmBusiness SmartPhone

// Filling in missing values for tech variables (some will still be missing)
	foreach x in `tech'{
		// average the 2 obs surrounding a missing
		replace `x' = (`x'[_n-1] + `x'[_n+1]) / 2 if missing(`x') 
	}
	
	save "merged_all_imputed.dta", replace

********************************************************************************
* 5 Creating adjusted computer cpi
********************************************************************************
// adjusted CPI = CompCPI/RegionCPI
	gen AdjCompCPI = CompCPI
		replace AdjCompCPI = (CompCPI / WestCPI) * 100 if region == "West"
		replace AdjCompCPI = (CompCPI / SouthCPI) * 100 if region == "South"
		replace AdjCompCPI = (CompCPI / NortheastCPI) * 100 if region == "Northeast"
		replace AdjCompCPI = (CompCPI / MidwestCPI) * 100 if region == "Midwest"

// Adding label
	label variable AdjCompCPI "Regionally adjusted CPI for computers"
	
	save "merged_all_imputed.dta", replace
	
********************************************************************************
* 5 Imputing missing values between 1997 and 2002
********************************************************************************
// Adding a 0 to be able to run regressions 
	replace NumPacific = 0 if state == "NH" & year == 1997 
	replace NumPacific = 0 if state == "DE" & year == 1997 
	save "merged_all_imputed.dta", replace

// Creating locals 
	local missings "TotalAcres age NumCrop DairyOperations NumAsian NumAfricanAmerican NumHispanic NumMulti NumPacific NumWhite NumMale NumFemale IncomePerOperation NumOffFarm TotalOperations NumPoultry HouseholdSize Experience prop65_74 propGE_75" 
	local states "AL AR AZ CA CO CT DE FL GA IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA SC SD TN TX UT VA VT WA WI WV WY"

	foreach x of local states {
		keep if state == "`x'"  // on a state by state basis:
			foreach a of local missings {
				regress `a' year // finding slope of var across time 
				predict pred_`a', xb // Using regr. coeff. to predict values 
				replace `a' = pred_`a' if missing(`a') // Using predicted values to fill missings 
				drop pred_`a' // Dropping prediction variable 
				replace `a' = 0 if `a' < 0 // changing negative counts to 0
			}
    
		merge 1:1 state year using "merged_all_imputed.dta" // merging back to the main dataset 
		drop _merge 
		save "merged_all_imputed.dta", replace  // saving 
		sort state year 
	}

// Now need to re run proportions code to fill in missing proportions (copying from clean data merging file)
// Sum up total 
	egen sum_demographics = rowtotal(NumAsian NumAfricanAmerican NumHispanic NumMulti NumPacific NumWhite)
	
// Creating a local set of variables for ethnicity
	local demographics Asian AfricanAmerican Hispanic Multi Pacific White
	
// Creating a loop to generate new proportion variables for each ethnicity category 
	foreach x in `demographics'{
		gen prop_`x'_1 = (Num`x' / sum_demographics) * 100
		label variable prop_`x' "Proportion of `x' farms"
		replace prop_`x' = prop_`x'_1  // Using predicted values to fill missings 
		drop prop_`x'_1
	}
	drop sum_demographics
	
// For gender 
	local gender Male Female
	foreach x in `gender'{
		gen prop_`x'_1 = (Num`x' / (NumMale + NumFemale)) * 100
		label variable prop_`x' "Proportion of `x' farms"
		label variable Num`x' "Count of `x' farms"
		replace prop_`x' = prop_`x'_1
		drop prop_`x'_1
	}

// Commodities proportions
	gen prop_crop_1 = (NumCrop / TotalOperations) * 100
	gen prop_dairy_1 = (DairyOperations / TotalOperations) * 100
	gen acres_per_oper_1 = (TotalAcres / TotalOperations) * 100
	gen prop_poultry = (NumPoultry / TotalOperations) * 100
	// Adding labels 
	label variable prop_crop "Proportion of Crop Operations"
	label variable prop_dairy "Proportion of dairy operations"
	label variable acres_per_oper "Acres Per Operation"
	
	replace prop_crop = prop_crop_1
	replace prop_dairy = prop_dairy_1
	replace acres_per_oper = acres_per_oper_1
	 drop prop_crop_1 prop_dairy_1 acres_per_oper_1
	
// Household size proportion
	gen avg_hhsize_1 = (HouseholdSize / TotalOperations)
	replace avg_hhsize = avg_hhsize_1
	label variable avg_hhsize "Average Household Size"
	drop avg_hhsize_1
	save "merged_all_imputed.dta", replace 

// Off-farm employment proportion
	gen prop_OffFarm = (NumOffFarm / TotalOperations) * 100
	label variable prop_OffFarm "Proportion of Farmers who have off-farm as primary employment"
	
	save "merged_all_imputed.dta", replace 	