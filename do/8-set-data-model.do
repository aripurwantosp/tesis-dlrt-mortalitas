log close _all
cls
*dir & log file
cd 				"D:\RESEARCH & WRITING\master thesis_child mortality\stata\"
loc logdir		"log"
loc idhs 		"idhs17"
loc dfn 		"log_8_data_model_`idhs'"
log using 		"`logdir'\8_data_model_`idhs'", name(`dfn') text replace

/*
================================================================================
********************************************************************************
PROJECT:
PENELITIAN TESIS
DEPRIVASI LINGKUNGAN RUMAH TANGGA DAN KEMATIAN BAYI DAN ANAK DI INDONESIA

SYNTAX:
8a-MENYIAPKAN DATA UNTUK PEMODELAN

PENULIS:
ARI PURWANTO SARWO PRASOJO (2006500321)
MAGISTER EKONOMI KEPENDUDUKAN DAN KETENAGAKERJAAN
FEB, UNIVERSITAS INDONESIA
2021
********************************************************************************
================================================================================
*/



/*
================================================================================
PENYIAPAN
================================================================================
*/

clear all
macro drop _all
set maxvar 10000

*direktori kerja
loc dtadir		"dta"
*loc outdir		"output"

*tag
loc date = c(current_date)
loc time = c(current_time)
loc time_date = "`date'" + "_" + "`time'"
loc tag "`dfn'.do Ari Prasojo `time_date'"

*data
loc dta			"`dtadir'\6-chmort-`idhs'.dta"
loc savenm		"`dtadir'\8-data-model-`idhs'.dta"

*set sampel
loc sett  		"precsvy10==1 & nomisvaruse==1"

*vars
#delimit ;
glo vars
	/*lokasi*/
	psu prov
		
	/*bobot*/
	wweight hhweight
	
	/*var terikat*/
	nndeath agenndeath
	ideath ageideathd
	u5death ageu5deathd
	
	/*var bebas*/
	depriv depriv2c chsex bordin
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
egen survdis = cut(agenndeath), at(0 7 29) icodes
	replace survdis = survdis + 1
	lab var survdis "Interval umur"
	lab def survdis 1 "0-6 hari"			///
					2 "7-28 hari"			///
					3 "29 hari-5 bulan" 	///
					4 "6-11 bulan"			///
					5 "12-23 bulan"			///
					6 "24-59 bulan"	
	lab val survdis survdis
	*table survdis, c(min agenndeath max agenndeath)
	table survdis, stat(min agenndeath) stat(max agenndeath)
	
*\Ekspansi data	
expand survdis
bysort birthid: gen interval = _n
lab val interval survdis
replace nndeath = 0 if nndeath == 1 & survdis != interval 
tab interval nndeath, row m

*\Simpan sementara
keep interval survdis $vars $id chsingle lastbirth
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
egen survdis = cut(ageideathd), at(0 7 29 180 360) icodes
	replace survdis = survdis + 1
	lab var survdis "Interval umur"
	lab def survdis 1 "0-6 hari"			///
					2 "7-28 hari"			///
					3 "29 hari-5 bulan" 	///
					4 "6-11 bulan"			///
					5 "12-23 bulan"			///
					6 "24-59 bulan"
	lab val survdis survdis
	*table survdis, c(min ageideathd max ageideathd)
	table survdis, stat(min ageideathd) stat(max ageideathd)
	
*\Ekspansi data	
expand survdis
bysort birthid: gen interval = _n
lab val interval survdis
replace ideath = 0 if ideath == 1 & survdis != interval 
tab interval ideath, row m

*\Simpan sementara
keep interval survdis $vars $id chsingle lastbirth
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
egen survdis = cut(ageu5deathd), at(0 7 29 180 360 720 1800) icodes
	replace survdis = survdis + 1
	lab var survdis "Interval umur"
	lab def survdis 1 "0-6 hari"			///
					2 "7-28 hari"			///
					3 "29 hari-5 bulan" 	///
					4 "6-11 bulan"			///
					5 "12-23 bulan"			///
					6 "24-59 bulan"
	lab val survdis survdis
	*table survdis, c(min ageu5deathd max ageu5deathd)
	table survdis, stat(min ageu5deathd) stat(max ageu5deathd)
	
*\Ekspansi data	
expand survdis
bysort birthid: gen interval = _n
lab val interval survdis
replace u5death = 0 if u5death == 1 & survdis != interval 
tab interval u5death, row m

*\Simpan sementara
keep interval survdis $vars $id chsingle lastbirth
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
lab var interval "Interval umur"

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