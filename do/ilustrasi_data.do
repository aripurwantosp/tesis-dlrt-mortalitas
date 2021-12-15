cls
log close _all
clear all

*direktori
cd "D:\RESEARCH & WRITING\master thesis_child mortality\stata\"

loc idhs		"idhs17"
loc dta			"chmort-`idhs'.dta"
use "`dta'"

*set regresi
gen nomisvaruse = .
	replace nomisvaruse = 1 if !(chalive == 0 & missing(agedeath)) &		///
							   !missing(envdepriv) &						///
							   !missing(peduc3c)	   
loc sett  "precsvy10==1 & nomisvaruse==1"
keep if `sett'

*cek missing
foreach p of varlist envdepriv envdepriv chsex bordint mageb4c				///
				     meduc3c peduc3c poorstat3c reside {
				nmissing `p'
}


*log file
loc dfn "log_ilustrasi_data"
log using ".\log\ilustrasi_data", name(`dfn') text replace


*\birth id
tostring(bidx), g(bidx_str)
tostring(v001), g(clust_str)
tostring(v002), g(hid_str)
tostring(v003), g(mid_str)
gen birthid = clust_str + "_" + hid_str + "_" + mid_str + "_" + bidx_str

 
*\diskritisasi
egen agedis = cut(ageideathd), at(0 7 29 90 180 360) icodes
	replace agedis = agedis + 1
	lab var agedis "Interval umur"
	lab def agedis 1 "0-6 hari"			///
					2 "7-28 hari"			///
					3 "29 hari-2 bulan" 	///
					4 "3-5 bulan"			///
					5 "6-11 bulan"
	lab val agedis agedis
	table agedis, c(min ageideathd max ageideathd)

keep if inlist(agedis,3,5)
by agedis, sort: gen ids = _n
keep if ids==1
gen id = _n
clonevar umur = ageideath
clonevar umurdis = agedis
gen death = ideath

list id umur umurdis death, noobs

*\expand	
expand agedis
bysort id: gen interval = _n
lab val interval agedis
replace death = 0 if ideath == 1 & agedis != interval

list id umur umurdis interval death, sepby(id) noobs