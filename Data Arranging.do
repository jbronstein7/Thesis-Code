**************************************************************************
*
* Title: Data Management Working Example 10_2_2023
* Authors: April Athnos & Joe Bronstein
* Last Updated: 10-13-2023
* Objective: to demonstrate one method of formatting raw data into useable form
* 
**************************************************************************

**************************************************************************
* 0 - Importing Data to Directory
**************************************************************************

di c(hostname) 

    if "`c(hostname)'" == "AREC-ATHNOS" {
            cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein\Code"
            }


    if "`c(hostname)'" == "JBRON-DESKTOP" {
            cd "\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data"
            }

local y = 2023

// Installing StataStates Package
ssc install statastates, replace

*List all the urls that contain the zipped csv files below

foreach x in 	"https://downloads.usda.library.cornell.edu/usda-esmis/files/h128nd689/4j03fg187/sn00cf56j/fmpc0823.zip" ///	
				"https://downloads.usda.library.cornell.edu/usda-esmis/files/h128nd689/j0990b03m/wp989g941/fmpc0821.zip" ///	
				"https://downloads.usda.library.cornell.edu/usda-esmis/files/h128nd689/8910k592p/gx41mw23p/fmpc0819.zip" ///	
				"https://downloads.usda.library.cornell.edu/usda-esmis/files/h128nd689/fx719q05f/gf06g512f/FarmComp-08-18-2017_correction.zip" ///	
				"https://downloads.usda.library.cornell.edu/usda-esmis/files/h128nd689/3j333490f/7s75df87v/FarmComp-08-19-2015.zip" ///	
				"https://downloads.usda.library.cornell.edu/usda-esmis/files/h128nd689/6d570056c/fj236476c/FarmComp-08-20-2013.zip" ///	
				"https://downloads.usda.library.cornell.edu/usda-esmis/files/h128nd689/m613n128q/pc289m61r/FarmComp-08-12-2011.zip"	///
				"https://downloads.usda.library.cornell.edu/usda-esmis/files/h128nd689/qr46r320c/7m01bp10q/FarmComp-08-14-2009.zip" ///	
				"https://downloads.usda.library.cornell.edu/usda-esmis/files/h128nd689/1r66j363n/d217qr77d/FarmComp-08-10-2007.zip" ///	
				"https://downloads.usda.library.cornell.edu/usda-esmis/files/h128nd689/9w032528k/r207tr80g/FarmComp-08-12-2005.zip" ///	
				"https://downloads.usda.library.cornell.edu/usda-esmis/files/h128nd689/c534fr592/qj72p977r/FarmComp-07-28-2003.zip" ///	
				"https://downloads.usda.library.cornell.edu/usda-esmis/files/h128nd689/q811kn27s/m326m422t/FarmComp-07-30-2001.zip" {	


	*Making sure that there is no folder sharing the name of the year
	*Deleting it if there is
	
	shell rd "`y'" /s /q
	

			if _rc != 0 {
					
					shell rmdir "y" /s /q
					mkdir "`y'"
					cd "`y'"
					di "done"
		}

	*Setting up a folder with the year to hold data	
	
	mkdir "`y'"
	
	cd "`y'" 
	
	copy "`x'" USDA_`y'.zip, replace
	
	unzipfile USDA_`y'.zip, replace
	
	*Erasing files not needed (you can add more to this list if you'd like)
	erase USDA_`y'.zip
	
	if `y' > 2009 {
	
		import delimited  "fmpc_all_tables.csv", clear delimiter(comma)
		save all_tables_`y', replace 
		
		}
		
	if `y' < 2011 & `y' > 2001	{
	
		import delimited  "fmpc_all.csv", clear delimiter(comma)
		save all_tables_`y', replace 
		
		}
		
	if `y' == 2001	{
	
		import delimited  "EMPC_ALL.CSV", clear delimiter(comma)
		save all_tables_`y', replace 
		
		}		
	
	cd ..
	
	local y = `y' - 2
}	

**************************************************************************
* 1 - Organizing Datasets into a Useable Format 
**************************************************************************

***************
* 2001
***************

// For 2001 data arranging:
	use "2001\all_tables_2001.dta", clear

// Dropping values outside the table 
	drop if _n > 59

// Renaming Variables based on table names 
	forval x = 3/15 {

		destring v`x', replace force

}

	rename v4 ComputerAccess1997
	rename v5 ComputerAccess1999
	rename v6 ComputerAccess2001

	rename v7 OwnOrLeaseComputers1997
	rename v8 OwnOrLeaseComputers1999
	rename v9 OwnOrLeaseComputers2001

	rename v10 ComputersForFarmBusiness1997
	rename v11 ComputersForFarmBusiness1999
	rename v12 ComputersForFarmBusiness2001

	rename v13 InternetAccess1997
	rename v14 InternetAccess1999
	rename v15 InternetAccess2001

// Dropping values outisde dataset and not needed variables 
	drop if _n < 15
	drop v1 v2


	forval x = 1/5 {

	replace v3 = subinstr(v3, "`x'/", "",.)

}

	foreach c in rtrim ltrim {

		replace v3 = `c'(v3)
	
	}

// Changing character length of variables
	drop if strlen(v3) == 0 | strlen(v3) > 3	

	reshape long ComputerAccess, i(v3) j(year)	
	
	rename v3 state
	
// Getting obs for each year for each state
	foreach g in OwnOrLeaseComputers ComputersForFarmBusiness InternetAccess {

	gen `g' = `g'1997 

		foreach n in 1999 2001 {

		replace `g' =  `g'`n' if year == `n'
	
	}
	
	}
// Keep variables of interest
	keep state year ComputerAccess OwnOrLeaseComputers ComputersForFarmBusiness InternetAccess	
	
// Save dataset
	save "Clean(ish) Datasets\clean_2001.dta", replace 
	
// Repeat this for every year

**************************************************************************
***************
* 2003
***************
// For 2003 Data Arranging:
	use "2003\all_tables_2003.dta", clear

// To get comp access and own/lease %'s
	drop if _n > 58

// Renaming Variables
	forval x = 4/11 {

		destring v`x', replace force

}
	
	rename v4 ComputerAccess1997
	rename v5 ComputerAccess1999
	rename v6 ComputerAccess2001
	rename v7 ComputerAccess2003

	rename v8 OwnOrLeaseComputers1997
	rename v9 OwnOrLeaseComputers1999
	rename v10 OwnOrLeaseComputers2001
	rename v11 OwnOrLeaseComputers2003

// Dropping values outisde dataset
	drop if _n < 14
	drop v1 v2


	forval x = 1/5 {

	replace v3 = subinstr(v3, "`x'/", "",.)

}

	foreach c in rtrim ltrim {

		replace v3 = `c'(v3)
	
	}
// Changing character length of variables	
	drop if strlen(v3) == 0 | strlen(v3) > 3	

	reshape long ComputerAccess, i(v3) j(year)	

	rename v3 state
	
// Getting obs for each year for each state
	foreach g in OwnOrLeaseComputers {

	gen `g' = `g'1997 

		foreach n in 1999 2001 2003 {

		replace `g' =  `g'`n' if year == `n'
	
	}
	
	}
// Keep variables of interest	
	keep state year ComputerAccess OwnOrLeaseComputers
	
// Changing state to str# for merging purposes
	gen str20 state_str = state
	
// Save dataset
	save "Clean(ish) Datasets\clean_2003.dta", replace 
	
// Gives us dataset with ComputerAccess and OwnOrLeaseComputers for 2003
**************************************************************************
// To get farm business and internet access
	use "2003\all_tables_2003.dta", clear

// Dropping values outisde dataset
	drop if _n > 114

// Renaming Variables
	forval x = 4/11 {

		destring v`x', replace force

}
	
	rename v4 ComputersForFarmBusiness1997
	rename v5 ComputersForFarmBusiness1999
	rename v6 ComputersForFarmBusiness2001
	rename v7 ComputersForFarmBusiness2003

	rename v8 InternetAccess1997
	rename v9 InternetAccess1999
	rename v10 InternetAccess2001
	rename v11 InternetAccess2003

// Dropping values outisde dataset
	drop if _n < 70
	drop v1 v2


	forval x = 1/5 {

	replace v3 = subinstr(v3, "`x'/", "",.)

}

	foreach c in rtrim ltrim {

		replace v3 = `c'(v3)
	
	}
// Changing character length of variables	
	drop if strlen(v3) == 0 | strlen(v3) > 3	

	reshape long ComputersForFarmBusiness, i(v3) j(year)	
	
	rename v3 state

// Getting obs for each year for each state
	foreach g in InternetAccess {

	gen `g' = `g'1997 

		foreach n in 1999 2001 2003 {

		replace `g' =  `g'`n' if year == `n'
	
	}
	
	}
// Keep variables of interest	
	keep state year ComputersForFarmBusiness InternetAccess
	
// Changing state to str# for merging purposes
	gen str20 state_str = state
	
// Save dataset
	save "Clean(ish) Datasets\clean_2003_2.dta", replace 
**************************************************************************	
// Merging 2003 datasets by state_str 
	merge 1:1 state_str year using "Clean(ish) Datasets\clean_2003.dta"

// Rearranging Variables 
	drop state
	drop _merge
	rename state_str state
	order state

// Saving as 2003 Dataset
	save "Clean(ish) Datasets\2003.dta", replace 

**************************************************************************
***************
* 2009
***************
// For 2009 Dataset:
// (Because it already includes data from 2005 and 2007 as well)
	use "2009\all_tables_2009.dta", clear

// Dropping values outisde dataset
	drop if _n > 63

// Renaming Variables
	forval x = 4/9 {

		destring v`x', replace force

}
	
	rename v4 ComputerAccess2005
	rename v5 ComputerAccess2007
	rename v6 ComputerAccess2009
	
	rename v7 OwnOrLeaseComputers2005
	rename v8 OwnOrLeaseComputers2007
	rename v9 OwnOrLeaseComputers2009

// Dropping values outisde dataset
	drop if _n < 13
	drop v1 v2


	forval x = 1/5 {

	replace v3 = subinstr(v3, "`x'/", "",.)

}

	foreach c in rtrim ltrim {

		replace v3 = `c'(v3)
	
	}
	
	drop if strlen(v3) == 0 | strlen(v3) > 3	

	reshape long ComputerAccess, i(v3) j(year)	

	rename v3 state
	
// Getting obs for each year for each state
	foreach g in OwnOrLeaseComputers {

	gen `g' = `g'2005 

		foreach n in 2007 2009 {

		replace `g' =  `g'`n' if year == `n'
	
		}
	
		}
	
// Keep variables of interest	
	keep state year ComputerAccess OwnOrLeaseComputers
	
// Changing state to str# for merging purposes
	gen str20 state_str = state
	
// Save dataset
	save "Clean(ish) Datasets\clean_2009.dta", replace 
	
// Now have 2009 dataset for computeraccess and own/lease
**************************************************************************
// Next need to make a dataset for farm business and internet access
	use "2009\all_tables_2009.dta", clear

// Dropping values outisde dataset
	drop if _n > 123

// Renaming Variables
	forval x = 4/9 {

		destring v`x', replace force

}
	
	rename v4 ComputersForFarmBusiness2005
	rename v5 ComputersForFarmBusiness2007
	rename v6 ComputersForFarmBusiness2009
	
	rename v7 InternetAccess2005
	rename v8 InternetAccess2007
	rename v9 InternetAccess2009

// Dropping values outisde dataset
	drop if _n < 73
	drop v1 v2


	forval x = 1/5 {

	replace v3 = subinstr(v3, "`x'/", "",.)

}

	foreach c in rtrim ltrim {

		replace v3 = `c'(v3)
	
	}
// Reformatting variables	
	drop if strlen(v3) == 0 | strlen(v3) > 3	

	reshape long ComputersForFarmBusiness, i(v3) j(year)	
	
// Renaming state variable
	rename v3 state

// Getting obs for each year for each state
	foreach g in InternetAccess {

	gen `g' = `g'2005 

		foreach n in 2007 2009 {

		replace `g' =  `g'`n' if year == `n'
	
		}
	
		}
	
// Keep variables of interest	
	keep state year ComputersForFarmBusiness InternetAccess
	
// Changing state to str# for merging purposes
	gen str20 state_str = state
	
// Save dataset
	save "Clean(ish) Datasets\clean_2009_2.dta", replace 
	
// Now have 2009 dataset for ComputersForFarmBusiness and internet access
**************************************************************************
// Merging 2009 datasets by state_str 
	merge 1:1 state_str year using "Clean(ish) Datasets\clean_2009.dta"

// Rearranging Variables 
	drop state
	drop _merge
	rename state_str state
	order state

// Saving as 2003 Dataset
	save "Clean(ish) Datasets\2009.dta", replace 
**************************************************************************
***************
* 2015
***************
// For 2015 Dataset:
// (Because it already includes data from 2011 and 2013 as well)
	use "2015\all_tables_2015.dta", clear

// Dropping values outisde dataset
	drop if _n > 62

// Renaming Variables
	forval x = 4/9 {

		destring v`x', replace force

}
	
	rename v4 ComputerAccess2011
	rename v5 ComputerAccess2013
	rename v6 ComputerAccess2015
	
	rename v7 OwnOrLeaseComputers2011
	rename v8 OwnOrLeaseComputers2013
	rename v9 OwnOrLeaseComputers2015

// Dropping values outisde dataset
	drop if _n < 12
	drop v1 v2

	forval x = 1/5 {

	replace v3 = subinstr(v3, "`x'/", "",.)

	}

	drop if strlen(v3) == 0
	drop if _n > 42

	foreach x in ltrim rtrim {

	replace v3 = `x'(v3)

	}

// Formatting Data:
	gen state = substr(v3, 1,20)
	statastates, name(state)

	keep if _merge == 3 | state == "UNITED STATES"

	sort _merge state_abbrev

	drop v10 v11 v12




	foreach c in rtrim ltrim {

		replace v3 = `c'(v3)
	
	}
	
	
// Transposing observations
	reshape long ComputerAccess, i(v3) j(year)	
	drop v3 
	
// Getting obs for each year for each state
	foreach g in OwnOrLeaseComputers {

	gen `g' = `g'2011 

		foreach n in 2013 2015 {

		replace `g' =  `g'`n' if year == `n'
	
		}
	
		}
	
// Keep variables of interest	
	keep state_abbrev year ComputerAccess OwnOrLeaseComputers
	order state_abbrev
	rename state_abbrev state
	
// Changing state to str# for merging purposes
	gen str20 state_str = state
	
// Save dataset
	save "Clean(ish) Datasets\clean_2015.dta", replace 
	
// Now have 2015 dataset for computer access and own/lease
**************************************************************************
// To get 2015 dataset for ComputersForFarmBusiness InternetAccess:
// (Because it already includes data from 2011 and 2013 as well)
	use "2015\all_tables_2015.dta", clear

// Dropping values outisde dataset
	drop if _n > 119

// Renaming Variables
	forval x = 4/9 {

		destring v`x', replace force

}
	
	rename v4 ComputersForFarmBusiness2011
	rename v5 ComputersForFarmBusiness2013
	rename v6 ComputersForFarmBusiness2015
	
	rename v7 InternetAccess2011
	rename v8 InternetAccess2013
	rename v9 InternetAccess2015

// Dropping values outisde dataset
	drop if _n < 74
	drop v1 v2

	forval x = 1/5 {

	replace v3 = subinstr(v3, "`x'/", "",.)

	}

	drop if strlen(v3) == 0
	drop if _n > 42

	foreach x in ltrim rtrim {

	replace v3 = `x'(v3)

	}

// Formatting Data
	gen state = substr(v3, 1,20)
	statastates, name(state)

	keep if _merge == 3 | state == "UNITED STATES"

	sort _merge state_abbrev

	drop v10 v11 v12





	foreach c in rtrim ltrim {

		replace v3 = `c'(v3)
	
	}
	
	
// Transposing observations
	reshape long ComputersForFarmBusiness, i(v3) j(year)	

	drop v3
	
// Getting obs for each year for each state
	foreach g in InternetAccess {

	gen `g' = `g'2011 

		foreach n in 2013 2015 {

		replace `g' =  `g'`n' if year == `n'
	
		}
	
		}
	
// Keep variables of interest	
	keep state_abbrev year ComputersForFarmBusiness InternetAccess
	order state_abbrev
	rename state_abbrev state
	
// Changing state to str# for merging purposes
	gen str20 state_str = state
	
// Save dataset
	save "Clean(ish) Datasets\clean_2015_2.dta", replace 
	
// Now have 2015 dataset for ComputersForFarmBusiness and InternetAccess
**************************************************************************
// Merging 2015 datasets by state_str 
	merge 1:1 state_str year using "Clean(ish) Datasets\clean_2015.dta"

// Rearranging Variables 
	drop state
	drop _merge
	rename state_str state
	order state
	
// Replacing blank state values with US
	replace state = "US" if missing(state) | state == ""

// Saving as 2003 Dataset
	save "Clean(ish) Datasets\2015.dta", replace 
**************************************************************************
***************
* 2019
***************
// For 2019 Dataset:
// (Because it already includes data from 2017 as well)
	use "2019\all_tables_2019.dta", clear

// Dropping values outisde dataset
	drop if _n > 58

// Renaming Variables
	forval x = 4/7 {

		destring v`x', replace force

}
	
	rename v4 ComputerAccess2017
	rename v5 ComputerAccess2019
	
	rename v6 OwnOrLeaseComputers2017
	rename v7 OwnOrLeaseComputers2019

// Dropping values outisde dataset
	drop if _n < 13
	drop v1 v2

	forval x = 1/5 {

	replace v3 = subinstr(v3, "`x'/", "",.)

	}

	drop if strlen(v3) == 0
	drop if _n > 42

	foreach x in ltrim rtrim {

	replace v3 = `x'(v3)

	}

// Reformatting State Variable:
	gen state = substr(v3, 1,20)
	statastates, name(state)

	keep if _merge == 3 | state == "UNITED STATES"
	sort _merge state_abbrev
	drop v8 v9 v10 v11




	foreach c in rtrim ltrim {

		replace v3 = `c'(v3)
	
	}
	
// Transposing observations
	reshape long ComputerAccess, i(v3) j(year)	
	drop v3
	
// Getting obs for each year for each state
	foreach g in OwnOrLeaseComputers {

	gen `g' = `g'2017 

		foreach n in 2019 {

		replace `g' =  `g'`n' if year == `n'
	
		}
	
		}
	
// Keep variables of interest	
	keep state_abbrev year ComputerAccess OwnOrLeaseComputers
	order state_abbrev
	rename state_abbrev state
	
// Changing state to str# for merging purposes
	gen str20 state_str = state
	
// Save dataset
	save "Clean(ish) Datasets\clean_2019.dta", replace 
	
// Now have 2019 dataset for computer access and own/lease
**************************************************************************
// To get 2019 dataset for ComputersForFarmBusiness InternetAccess:
// (Because it already includes data from 2017 and 2019 as well)
	use "2019\all_tables_2019.dta", clear

// Dropping values outisde dataset
	drop if _n > 118

// Renaming Variables
	forval x = 4/9 {

		destring v`x', replace force

}
	
	rename v4 ComputersForFarmBusiness2017
	rename v5 ComputersForFarmBusiness2019
	
	rename v6 SmartPhoneTabletFarmBusiness2017
	rename v7 SmartPhoneTabletFarmBusiness2019
	
	rename v8 InternetAccess2017
	rename v9 InternetAccess2019

// Dropping values outisde dataset
	drop if _n < 73
	drop v1 v2

	forval x = 1/5 {

	replace v3 = subinstr(v3, "`x'/", "",.)

	}

	drop if strlen(v3) == 0
	drop if _n > 42

	foreach x in ltrim rtrim {

	replace v3 = `x'(v3)

	}

// Reformatting State Variable:
	gen state = substr(v3, 1,20)
	statastates, name(state)

	keep if _merge == 3 | state == "UNITED STATES"
	sort _merge state_abbrev
	drop v10 v11




	foreach c in rtrim ltrim {

		replace v3 = `c'(v3)
	
	}
	
// Transposing observations
	reshape long ComputersForFarmBusiness, i(v3) j(year)	
	drop v3
	
// Getting obs for each year for each state
	foreach g in InternetAccess SmartPhoneTabletFarmBusiness {

	gen `g' = `g'2017 

		foreach n in 2019 {

		replace `g' =  `g'`n' if year == `n'
	
		}
	
		}
	
// Keep variables of interest	
	keep state_abbrev year ComputersForFarmBusiness InternetAccess SmartPhoneTabletFarmBusiness
	order state_abbrev
	rename state_abbrev state
	
// Changing state to str# for merging purposes
	gen str20 state_str = state
// Save dataset
	save "Clean(ish) Datasets\clean_2019_2.dta", replace 
	
// Now have 2019 dataset for ComputersForFarmBusiness, SmartPhoneTabletFarmBusiness, and InternetAccess
**************************************************************************
// Merging 2019 datasets by state_str 
	merge 1:1 state_str year using "Clean(ish) Datasets\clean_2019.dta"

// Rearranging Variables 
	drop state
	drop _merge
	rename state_str state
	order state
	
// Replacing blank state values with US
	replace state = "US" if missing(state) | state == ""

// Saving as 2003 Dataset
	save "Clean(ish) Datasets\2019.dta", replace 
**************************************************************************
// NOTE: NEED TO CONFIRM HOW TO HANDLE VARIABLES FOR THIS SET
***************
* 2023
***************
// For 2023 Dataset:
// (Because it already includes data from 2017 as well)
	use "2023\all_tables_2023.dta", clear

// Dropping values outisde dataset
	drop if _n > 58

// Renaming Variables
	forval x = 4/8 {

		destring v`x', replace force

}
	
	rename v4 OwnOrLeaseComputers2021
	rename v5 OwnOrLeaseComputers2023
	
	rename v6 SmartPhone2021
	rename v7 SmartPhone2023
	
	rename v8 TabletPortableComp2023
	
	

// Dropping values outisde dataset
	drop if _n < 13
	drop v1 v2

	forval x = 1/5 {

	replace v3 = subinstr(v3, "`x'/", "",.)

	}

	drop if strlen(v3) == 0
	drop if _n > 42

	foreach x in ltrim rtrim {

	replace v3 = `x'(v3)

	}

// Fromatting Data:
	gen state = substr(v3, 1,20)
	statastates, name(state)

	keep if _merge == 3 | state == "UNITED STATES"
	sort _merge state_abbrev
	drop v9


	foreach c in rtrim ltrim {

		replace v3 = `c'(v3)
	
	}
	
// Transposing observations
	reshape long OwnOrLeaseComputers, i(v3) j(year)	

	drop v3
	
// Getting obs for each year for each state
	foreach g in SmartPhone {

	gen `g' = `g'2021 

		foreach n in 2023 {

		replace `g' =  `g'`n' if year == `n'
	
		}
	
		}
	
// Keep variables of interest	
	keep state_abbrev year OwnOrLeaseComputers SmartPhone 
	order state_abbrev
	rename state_abbrev state
	
// Changing state to str# for merging purposes
	gen str20 state_str = state
	
// Save dataset
	save "Clean(ish) Datasets\clean_2023.dta", replace
	
// Now have 2023 dataset for computer access and own/lease
**************************************************************************
// To get 2023 dataset for ComputersForFarmBusiness InternetAccess:
// (Because it already includes data from 2017 and 2019 as well)
	use "2023\all_tables_2023.dta", clear

// Dropping values outisde dataset
	drop if _n > 118

// Renaming Variables
	forval x = 4/5 {

		destring v`x', replace force

}
	
	rename v4 InternetAccess2021
	rename v5 InternetAccess2023

// Dropping values outisde dataset
	drop if _n < 79
	drop v1 v2

	forval x = 1/5 {

	replace v3 = subinstr(v3, "`x'/", "",.)

	}

	drop if strlen(v3) == 0
	drop if _n > 124

	foreach x in ltrim rtrim {

	replace v3 = `x'(v3)

	}

// Fromatting Data:
	gen state = substr(v3, 1,20)
	statastates, name(state)

	keep if _merge == 3 | state == "UNITED STATES"

	sort _merge state_abbrev
	drop v6 v7 v8 v9

	foreach c in rtrim ltrim {

		replace v3 = `c'(v3)
	
	}
	
// Transposing observations
	reshape long InternetAccess, i(v3) j(year)	

	drop v3
	order state_abbrev
	
// Keep variables of interest	
	keep state_abbrev year  InternetAccess
	order state_abbrev
	rename state_abbrev state
	
// Changing state to str# for merging purposes
	gen str20 state_str = state
	
// Save dataset
	save "Clean(ish) Datasets\clean_2023_2.dta", replace 
	
// Now have 2023 dataset for InternetAccess

**************************************************************************
// Merging 2023 datasets by state_str 
	merge 1:1 state_str year using "Clean(ish) Datasets\clean_2023.dta"

// Rearranging Variables 
	drop state
	drop _merge
	rename state_str state
	order state
	
// Replacing blank state values with US
	replace state = "US" if missing(state) | state == ""

// Saving as 2003 Dataset
	save "Clean(ish) Datasets\2023.dta", replace 
**************************************************************************
* 2 - Appending merged datasets to create one large set for all years
**************************************************************************
// For data sets clean_year: 
// Load first dataset
	use "Clean(ish) Datasets\2003.dta"
	
// Append with sets of same variables for other years
	append using "Clean(ish) Datasets\2009.dta"
	append using "Clean(ish) Datasets\2015.dta"
	append using "Clean(ish) Datasets\2019.dta"
	append using "Clean(ish) Datasets\2023.dta"
	
	sort state year 

// Save appended dataset
	save "Clean(ish) Datasets\all_data.dta", replace
	
**************************************************************************
* Now have all states, years, and variables in one table and can begin visualization
**************************************************************************
