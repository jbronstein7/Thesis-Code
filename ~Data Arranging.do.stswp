**************************************************************************
*
* Title: Data Management Working Example 10_2_2023
* Authors: April Athnos & Joe Bronstein
* Date: 10-2-2023
* Objective: to demonstrate one method of formatting raw data into useable form
* 
**************************************************************************



di c(hostname) 

    if "`c(hostname)'" == "AREC-ATHNOS" {
            cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein\Code"
            }


    if "`c(hostname)'" == "JBRON-DESKTOP" {
            cd "\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data"
            }

local y = 2023

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

// For 2001 data arranging:

use "2001\all_tables_2001.dta", clear

drop if _n > 59

forval x = 4/15 {

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

drop if _n < 15
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

foreach g in OwnOrLeaseComputers ComputersForFarmBusiness InternetAccess {

gen `g' = `g'1997 

	foreach n in 1999 2001 {

	replace `g' =  `g'`n' if year == `n'
	
	}
	
	}
	
keep state year ComputerAccess OwnOrLeaseComputers ComputersForFarmBusiness InternetAccess	
	
// Repeating this for every year

// For 2003 Data Arranging:
use "2003\all_tables_2003.dta", clear

// To get comp access and own/lease %'s

drop if _n > 58

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

drop if _n < 14
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

foreach g in OwnOrLeaseComputers {

gen `g' = `g'1997 

	foreach n in 1999 2001 2003 {

	replace `g' =  `g'`n' if year == `n'
	
	}
	
	}
	
keep state year ComputerAccess OwnOrLeaseComputers

