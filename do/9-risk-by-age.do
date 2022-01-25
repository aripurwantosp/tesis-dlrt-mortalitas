log close _all
clear all
macro drop _all
cls
*dir & log file
cd 				"D:\RESEARCH & WRITING\master thesis_child mortality\stata\"
loc idhs 		"idhs17"
loc dfn 		"log_9_risk_by_age_`idhs'"
log using 		"log\9_risk_by_age_`idhs'", name(`dfn') text replace

/*
================================================================================
********************************************************************************
PROJECT:
PENELITIAN TESIS
HUBUNGAN ANTARA DEPRIVASI LINGKUNGAN RUMAH TANGGA DENGAN KEMATIAN BAYI DAN ANAK
DI INDONESIA: BUKTI DARI MODEL LOGISTIK MULTILEVEL HAZARD DISKRIT

SYNTAX:
9-DESKRIPTIF HAZARD-RISK BERDASARKAN UMUR

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

*baca data
loc dta			"dta\8-data-model-`idhs'.dta"
use `dta'



/*
================================================================================
HITUNG												
================================================================================
*/

*\Pendekatan logit	   
logit u5death i.periods i.periods#depriv if data==3
margins i.periods i.periods#depriv
marginsplot, noci															///
	title("") ytitle("Hazard") xtitle("Periode umur")						///
	ylab(0 "0" 0.005 "0.50" 0.01 "1.00" 0.015 "1.50" 0.02 "2.00")			///
	xlab(1 "0-6 hari"   2 "7-28 hari"   3 "29 hari-5 bulan"					///
		   4 "6-11 bulan" 5 "12-23 bulan" 6 "24-59 bulan", angle(45))		///
	legend(order (1 2 3 4) 													///
		   label(1 "Deprivasi-Tidak") 										///
		   label(2 "Deprivasi-Rendah") 										///
		   label(3 "Deprivasi-Tinggi")										///
		   label(4 "Total") 												///
		   position(6) rows(1))												///
	scheme(gg_tableau)
graph export ".\output\risk_by_age.png", replace


*\Tabel
*total
keep if data == 3
gen u5death100 = 100*u5death
collapse (mean) u5death100, by(periods)
rename u5death100 Total
save "risk-total.dta", replace

*by depriv
clear all
use `dta'
keep if data == 3
gen u5death100 = 100*u5death
collapse (mean) u5death100, by(periods depriv)
reshape wide u5death100, i(periods) j(depriv)
rename u5death1000 Tidak
rename u5death1001 Rendah
rename u5death1002 Tinggi
gen Rendah_Tidak = Rendah/Tidak
gen Tinggi_Tidak = Tinggi/Tidak
merge m:1 periods using "risk-total.dta", keep(match) keepus() nogen
export excel ".\output\risk_by_age.xls", firstrow(variables) replace
erase "risk-total.dta"



*close log-file
log close _all