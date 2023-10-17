**************************************************************************
*
* Title: Data Management Working Example 10_9_2023
* Authors: April Athnos & Joe Bronstein
* Date: 10-9-2023
* Objective: to demonstrate how use expand, rename variables, and save files
*
**************************************************************************

di c(hostname) 

    if "`c(hostname)'" == "AREC-ATHNOS" {
            cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein\Code"
            }


    if "`c(hostname)'" == "JBRON-DESKTOP" {
            cd "Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data"
            }
			
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

rename v3 state

expand 3
sort state

bysort state: gen n = _n
replace n = 1997 if n == 1
replace n = 1999 if n == 2
replace n = 2001 if n == 3
rename n year

foreach g in ComputerAccess OwnOrLeaseComputers ComputersForFarmBusiness InternetAccess {

gen `g' = `g'1997 

	foreach n in 1999 2001 {

	replace `g' =  `g'`n' if year == `n'
	
	}
	
	}

	drop ComputerAccess1997 ComputerAccess1999 ComputerAccess2001 OwnOrLeaseComputers1997 OwnOrLeaseComputers1999 OwnOrLeaseComputers2001 ComputersForFarmBusiness1997 ComputersForFarmBusiness1999 ComputersForFarmBusiness2001 InternetAccess1997 InternetAccess1999 InternetAccess2001
	
	gen state_ = substr(state, 1, 3)
	drop state
	order state_
	rename state_ state
	
rename ComputerAccess CompAcc
label var CompAcc "Farmer Computer Access"

save FarmAccess_2001.dta, replace

drop if _n < 60 | _n > 105
	