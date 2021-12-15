/*
================================================================================
********************************************************************************
PROJECT:
PENELITIAN TESIS
DEPRIVASI LINGKUNGAN RUMAH TANGGA DAN KEMATIAN BAYI DAN ANAK DI INDONESIA

SYNTAX:
9-DESKRIPTIF HAZARD-RISK BERDASARKAN UMUR

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

cls
log close _all
clear all
macro drop _all
set maxvar 10000

*direktori kerja
cd 				"D:\RESEARCH & WRITING\master thesis_child mortality\stata\"
loc logdir		"log"
loc dtadir		"dta"
*loc outdir		"output"

*log file
loc dfn 		"log_9_risk_by_age"
log using 		"`logdir'\9_risk_by_age", name(`dfn') text replace


*baca data
loc idhs		"idhs17"
loc dta			"`dtadir'\8-data-model-`idhs'.dta"
use `dta'



/*
================================================================================
CALCULATE													
================================================================================
*/

/*
******************************************************************
Logit Approach												[done]
******************************************************************
*/
		   
logit u5death i.interval i.interval#depriv if data==3
margins i.interval i.interval#depriv
marginsplot, noci															///
	title("") ytitle("Hazard")												///
	xlabel(1 "0-6 hari"   2 "7-28 hari"   3 "29 hari-5 bulan"				///
		   4 "6-11 bulan" 5 "12-23 bulan" 6 "24-59 bulan", angle(45))		///
	legend(order (1 2 3 4) 													///
		   label(1 "Deprivasi-Tidak") 										///
		   label(2 "Deprivasi-Rendah") 										///
		   label(3 "Deprivasi-Tinggi")										///
		   label(4 "Total") 												///
		   position(6) rows(1))												///
	scheme(gg_tableau)
graph export ".\output\risk_by_age.png", replace




/*
/*
******************************************************************
Twoway Table Approach										[done]
******************************************************************
*/

*\Umum
egen hazard = mean(100*u5death), by(data interval)
egen tag = tag(data interval)
twoway connected hazard interval if data==3,sort	///
	xtitle("Interval umur")	ytitle("Hazard (%)")					  		///
	xlabel(1 "0-6 hari"   2 "7-28 hari"   3 "29 hari-5 bulan"      			///
		   4 "6-11 bulan" 5 "12-23 bulan" 6 "24-59 bulan", angle(45))		///
	scheme(white_tableau)
graph export ".\output\risk_by_age.png", replace


*\Berdasarkan Status Deprivasi	
drop hazard tag
egen hazard = mean(100*u5death), by(data depriv interval)
egen tag = tag(data depriv interval)
line hazard interval if data==3 & depriv==0, sort 		///
	|| line hazard interval if data==3 & depriv==1, sort 	///
	|| line hazard interval if data==3 & depriv==2, sort 	///
	xtitle("Interval umur")	ytitle("Hazard (%)")						    ///
	xlabel(1 "0-6 hari"   2 "7-28 hari"   3 "29 hari-5 bulan"     			///
		   4 "6-11 bulan" 5 "12-23 bulan" 6 "24-59 bulan", angle(45))		///
	legend(order(1 "Tidak" 2 "Rendah" 3 "Tinggi") position(6) rows(1))		///
	scheme(white_tableau)
graph export ".\output\risk_by_age_depriv.png", replace
*/


*\Tabel
gen u5death100 = 100*u5death
quietly collect: table (interval) (depriv) if data==3, stat(mean u5death100)
collect style cell, font( Times New Roman, size(8) )
collect style cell border_block, border(right, pattern(nil))
collect style cell result[mean], nformat(%6,3fc)
collect preview
collect export ".\output\risk_by_age.xls", as(xls) replace