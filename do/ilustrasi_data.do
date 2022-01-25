cls
log close _all
clear all

*log file
loc dfn "log_ilustrasi_data"
log using ".\log\ilustrasi_data", name(`dfn') text replace

*direktori
cd "D:\RESEARCH & WRITING\master thesis_child mortality\stata\"

loc idhs		"idhs17"
loc dta			"dta\6-chmort-`idhs'.dta"
use "`dta'"

*set sampel
loc sett  "precsvy10==1 & nomisvaruse==1"

*set sampel
gen nomisvaruse = .
	replace nomisvaruse = 1 if !(chalive == 0 & missing(agedeath)) &	///
							   !missing(depriv) &						///
							   !missing(pareduc)	   
keep if `sett'

*cek missing
foreach p in $vars $id {
	nmissing `p'
}

keep if `sett'


*\birth id
tostring(bidx), g(bidx_str)
tostring(v001), g(clust_str)
tostring(v002), g(hid_str)
tostring(v003), g(mid_str)
gen birthid = clust_str + "_" + hid_str + "_" + mid_str + "_" + bidx_str

 
*\Diskritisasi
egen agedis = cut(ageideathd), at(0 7 29 180 360) icodes
	replace agedis = agedis + 1
	lab var agedis "Umur (periods)"
	lab def agedis 1 "0-6 hari"			///
					2 "7-28 hari"			///
					3 "29 hari-5 bulan" 	///
					4 "6-11 bulan"			///
					5 "12-23 bulan"			///
					6 "24-59 bulan"
	lab val agedis agedis
	*table agedis, c(min ageideathd max ageideathd)
	table agedis, stat(min ageideathd) stat(max ageideathd)

keep if inlist(agedis,3,4)
by agedis, sort: gen ids = _n
keep if ids==1
gen id = _n
clonevar umur = ageideath
clonevar umurdis = agedis
gen death = ideath

list id umur umurdis death, noobs

*\expand	
expand agedis
bysort id: gen periods = _n
lab val periods agedis
replace death = 0 if ideath == 1 & agedis != periods

list id umur umurdis periods death, sepby(id) noobs


*close log-file
log close _all