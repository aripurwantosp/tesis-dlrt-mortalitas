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

cls
log close _all
clear all
macro drop _all
set maxvar 10000

*direktori kerja
cd 				"D:\RESEARCH & WRITING\master thesis_child mortality\stata\"
loc logdir		"log"
loc dtadir		"dta"

*log file
loc idhs		"idhs17"
loc yearsvy		2017
loc dfn 		"log_6_merge_`idhs'"
log using 		"`logdir'\6_merge_`idhs'", name(`dfn') text replace

*set the date
loc date = c(current_date)
loc time = c(current_time)
loc time_date = "`date'" + "_" + "`time'"
loc tag "`dfn'.do Ari Prasojo `time_date'"

*\dataset disimpan sebagai (nama)
loc savenm		"`dtadir'\6-chmort-`idhs'.dta"



/*
================================================================================
PROSES PENGGABUNGAN
================================================================================
*/

*merge dataset
use	"`dtadir'\4-vars-birth-`idhs'.dta"
merge m:1 v001 v002 v003 using "`dtadir'\3-vars-women-`idhs'.dta", keep(match) keepus() nogen
merge m:1 v001 v002 using "`dtadir'\2-vars-household-`idhs'.dta", keep(match) keepus() nogen
merge m:1 psu using "`dtadir'\5-vars-community-`idhs'.dta", keep(match) keepus() nogen

gen ydhs = `yearsvy'
	lab var ydhs "Tahun survei"

quietly compress
datasignature set, reset
lab data "Data merge\ `time_date'"
note: `idhs'-mortstudy-mergedata.dta \ `tag'
save "`savenm'", replace