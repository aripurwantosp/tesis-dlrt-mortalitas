log close _all
clear all
macro drop _all
cls
*dir & log file
cd 				"D:\RESEARCH & WRITING\master thesis_child mortality\stata\"
loc idhs 		"idhs17"
loc dfn 		"log_8_data_model_`idhs'"
log using 		"log\8_data_model_`idhs'", name(`dfn') text replace

/*
================================================================================
********************************************************************************
PROJECT:
PENELITIAN TESIS
HUBUNGAN ANTARA DEPRIVASI LINGKUNGAN RUMAH TANGGA DENGAN KEMATIAN BAYI DAN ANAK
DI INDONESIA: BUKTI DARI MODEL LOGISTIK MULTILEVEL HAZARD DISKRIT

SYNTAX:
8-MENYIAPKAN DATA UNTUK PEMODELAN-ANAK PERIODE

PENULIS:
ARI PURWANTO SARWO PRASOJO (2006500321)
MAGISTER EKONOMI KEPENDUDUKAN DAN KETENAGAKERJAAN
FAKULTAS EKONOMI DAN BISNIS, UNIVERSITAS INDONESIA
2022
********************************************************************************
================================================================================
*/



/*
================================================================================
PENYIAPAN
================================================================================
*/

set maxvar 10000

*tag
loc date = c(current_date)
loc time = c(current_time)
loc time_date = "`date'" + "_" + "`time'"
loc tag "`dfn'.do Ari Prasojo `time_date'"

*data
loc dta			"dta\6-chmort-`idhs'.dta"
loc savenm		"dta\8-data-model-`idhs'.dta"

*set sampel
loc sett  		"precsvy10==1 & nomisvaruse==1"

*vars
#delimit ;
glo vars
	/*lokasi*/
	psu
		
	/*bobot*/
	wweight hhweight
	
	/*var terikat*/
	nndeath agenndeath
	ideath ageideathd
	u5death ageu5deathd
	
	/*var bebas*/
	impdrinkwat impsan cookfldr
	depriv chsex bordin
	mageb pareduc wealth reside pwdisthfac
	;
#delimit cr

*id
#delimit ;
glo id
	/*id*/
	bidx_str clust_str hid_str mid_str birthid
	;
#delimit cr


/*
================================================================================
EKSPANSI DATA ANAK -> ANAK-PERIODE - NNDEATH
================================================================================
*/

/*
******************************************************************
Set															[done]
******************************************************************
*/

use `dta'

*cek missing
foreach p in $vars {
	nmissing `p'
}

*\Birth id
tostring(bidx), g(bidx_str)
tostring(v001), g(clust_str)
tostring(v002), g(hid_str)
tostring(v003), g(mid_str)
gen birthid = clust_str + "_" + hid_str + "_" + mid_str + "_" + bidx_str

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

/*
******************************************************************
Ekspansi													[done]
******************************************************************
*/

*\Diskritisasi
egen agedis = cut(agenndeath), at(0 7 29) icodes
	replace agedis = agedis + 1
	lab var agedis "Umur (periods)"
	lab def agedis 1 "0-6 hari"			///
					2 "7-28 hari"			///
					3 "29 hari-5 bulan" 	///
					4 "6-11 bulan"			///
					5 "12-23 bulan"			///
					6 "24-59 bulan"	
	lab val agedis agedis
	*table agedis, c(min agenndeath max agenndeath)
	table agedis, stat(min agenndeath) stat(max agenndeath)
	
*\Ekspansi data	
expand agedis
bysort birthid: gen periods = _n
lab val periods agedis
replace nndeath = 0 if nndeath == 1 & agedis != periods 
tab periods nndeath, row m

*\Simpan sementara
keep periods agedis $vars $id
gen data = 1

quietly compress
save "data-mdl-a.dta", replace



/*
================================================================================
EKSPANSI DATA ANAK -> ANAK-PERIODE - IDEATH
================================================================================
*/

/*
******************************************************************
Set															[done]
******************************************************************
*/

clear all
use `dta'

*cek missing
foreach p in $vars {
	nmissing `p'
}

*\Birth id
tostring(bidx), g(bidx_str)
tostring(v001), g(clust_str)
tostring(v002), g(hid_str)
tostring(v003), g(mid_str)
gen birthid = clust_str + "_" + hid_str + "_" + mid_str + "_" + bidx_str

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

/*
******************************************************************
Ekspansi													[done]
******************************************************************
*/

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
	
*\Ekspansi data	
expand agedis
bysort birthid: gen periods = _n
lab val periods agedis
replace ideath = 0 if ideath == 1 & agedis != periods 
tab periods ideath, row m

*\Simpan sementara
keep periods agedis $vars $id
gen data = 2

quietly compress
save "data-mdl-b.dta", replace



/*
================================================================================
EKSPANSI DATA ANAK -> ANAK-PERIODE - U5DEATH
================================================================================
*/

/*
******************************************************************
Set															[done]
******************************************************************
*/

clear all
use `dta'

*cek missing
foreach p in $vars {
	nmissing `p'
}

*\Birth id
tostring(bidx), g(bidx_str)
tostring(v001), g(clust_str)
tostring(v002), g(hid_str)
tostring(v003), g(mid_str)
gen birthid = clust_str + "_" + hid_str + "_" + mid_str + "_" + bidx_str

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

/*
******************************************************************
Ekspansi													[done]
******************************************************************
*/

*\Diskritisasi umur
egen agedis = cut(ageu5deathd), at(0 7 29 180 360 720 1800) icodes
	replace agedis = agedis + 1
	lab var agedis "Umur (periods)"
	lab def agedis 1 "0-6 hari"			///
					2 "7-28 hari"			///
					3 "29 hari-5 bulan" 	///
					4 "6-11 bulan"			///
					5 "12-23 bulan"			///
					6 "24-59 bulan"
	lab val agedis agedis
	*table agedis, c(min ageu5deathd max ageu5deathd)
	table agedis, stat(min ageu5deathd) stat(max ageu5deathd)
	
*\Ekspansi data	
expand agedis
bysort birthid: gen periods = _n
lab val periods agedis
replace u5death = 0 if u5death == 1 & agedis != periods 
tab periods u5death, row m

*\Simpan sementara
keep periods agedis $vars $id
gen data = 3

quietly compress
save "data-mdl-c.dta", replace



/*
================================================================================
FINALISASI
================================================================================
*/

clear all
use "data-mdl-a.dta"
append using "data-mdl-b.dta"
append using "data-mdl-c.dta"

lab var birthid "id kelahiran"
lab var periods "Periode/interval umur"

lab var data "Untuk pemodelan"
lab def data 1 "Neonatal" 2 "Bayi" 3 "Di bawah 5 tahun"
lab val data data

quietly compress
datasignature set, reset
lab data "Dataset pemodelan \ `time_date'"
note: `idhs'-mortstudy-data-model.dta \ `tag'
save "`savenm'", replace

erase "data-mdl-a.dta"
erase "data-mdl-b.dta"
erase "data-mdl-c.dta"

drop agenndeath ageideathd ageu5deathd
describe


*close log-file
log close _all