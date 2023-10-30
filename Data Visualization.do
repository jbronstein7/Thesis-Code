**************************************************************************
*
* Title: Data Visualization
* Authors: April Athnos & Joe Bronstein
* Last Updated: 10-29-2023
* Objective: To effectively visualize aggregated data
* 
**************************************************************************

**************************************************************************
* 0 - Selecting desired data
**************************************************************************

di c(hostname) 

    if "`c(hostname)'" == "AREC-ATHNOS" {
            cd "\Users\athnos\OneDrive - University of Arizona\Advising\Joe Bronstein\Code"
            }


    if "`c(hostname)'" == "JBRON-DESKTOP" {
            cd "\Users\jbron\OneDrive - University of Arizona\Documents\School\Thesis\Raw Data"
            }
			
// Selecting aggregated dataset
	use "Clean(ish) Datasets\all_data.dta"
	

**************************************************************************
* 1 - Graphing Data
**************************************************************************
// Graphing OwnOrLeaseComputers by state, with years on the x-axis 
	twoway (line OwnOrLeaseComputers year), by(state) title("Own or Lease Computers by State") xtitle("Year") ytitle("Own or Lease Computers")
	
// Exporting Graph
graph export "own_or_lease_computers.png", replace
