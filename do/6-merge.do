log close _all
clear all
macro drop _all
cls
*dir & log file
cd 				"D:\RESEARCH & WRITING\master thesis_child mortality\stata\"
loc idhs 		"idhs17"
loc dfn 		"log_6_merge_`idhs'"
log using 		"log\6_merge_`idhs'", name(`dfn') text replace

/*
================================================================================
********************************************************************************
PROJECT:
PENELITIAN TESIS
DEPRIVASI LINGKUNGAN RUMAH TANGGA DAN KEMATIAN BAYI DAN ANAK DI INDONESIA

SYNTAX:
6-MENGGABUNGKAN DATASET (1-5)

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

set maxvar 10000

loc yearsvy		2017

*set the date
loc date = c(current_date)
loc time = c(current_time)
loc time_date = "`date'" + "_" + "`time'"
loc tag "`dfn'.do Ari Prasojo `time_date'"

*\dataset disimpan sebagai (nama)
loc savenm		"dta\6-chmort-`idhs'.dta"



/*
================================================================================
PROSES PENGGABUNGAN
================================================================================
*/

*merge dataset
use	"dta\4-vars-birth-`idhs'.dta"
merge m:1 v001 v002 v003 using "dta\3-vars-women-`idhs'.dta", keep(match) keepus() nogen
merge m:1 v001 v002 using "dta\2-vars-household-`idhs'.dta", keep(match) keepus() nogen
merge m:1 psu using "dta\5-vars-community-`idhs'.dta", keep(match) keepus() nogen

gen ydhs = `yearsvy'
	lab var ydhs "Tahun survei"
	
quietly compress
datasignature set, reset
lab data "Data merge\ `time_date'"
note: `idhs'-mortstudy-mergedata.dta \ `tag'
save "`savenm'", replace

describe

*close log-file
log close _all