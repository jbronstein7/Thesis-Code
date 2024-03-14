**************************************************************************
* Title: Region and division variables
* Authors: Joe Bronstein
* Last Updated: 2-1-2024
* Objective: To add variables for census regions and divisons
* Assumes: Data merging file has been run
**************************************************************************

di c(hostname) 

    if "`c(hostname)'" == "AREC-ATHNOS" {
            cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein\Clean(ish) Datasets"
            }


    if "`c(hostname)'" == "JBRON-DESKTOP" {
            cd "\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data\Clean(ish) Datasets"
            }
			
**************************************************************************
* 0 - Selecting desired data
**************************************************************************
// Using fully merged dataset, with all variables added 
	use "merged_all.dta", clear
	
	
**************************************************************************
* 1 - Matching states to census divisions (already in data)
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
* 2 - Matching states to census regions (need to create new variable)
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

save "merged_all.dta", replace 