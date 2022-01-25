log close _all
clear all
macro drop _all
cls
*dir & log file
cd 				"D:\RESEARCH & WRITING\master thesis_child mortality\stata\"
loc idhs 		"idhs17"
loc dfn 		"log_5_vars_community_`idhs'"
log using 		"log\5_vars_community_`idhs'", name(`dfn') text replace

/*
================================================================================
********************************************************************************
PROJECT:
PENELITIAN TESIS
HUBUNGAN ANTARA DEPRIVASI LINGKUNGAN RUMAH TANGGA DENGAN KEMATIAN BAYI DAN ANAK
DI INDONESIA: BUKTI DARI MODEL LOGISTIK MULTILEVEL HAZARD DISKRIT

SYNTAX:
5-MEMBENTUK VARIABEL TINGKAT KOMUNITAS

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

*set the date
loc date = c(current_date)
loc time = c(current_time)
loc time_date = "`date'" + "_" + "`time'"
loc tag "`dfn'.do Ari Prasojo `time_date'"

*direktori dataset

*\dataset individu perempuan
loc irdata		"dta\3-vars-women-`idhs'.dta"

*\dataset disimpan sebagai (nama)
loc savenm		"dta\5-vars-community-`idhs'.dta"



/*
================================================================================
INDIVIDU/PEREMPUAN
================================================================================
*/

clear all
use "`irdata'"

/*
******************************************************************
Variabel-variabel											[done]
******************************************************************
*/

gen psu = v001

*\% perempuan yang menganggap jarak ke fasilitas kesehatan sulit
bysort psu: egen pwdisthfac = mean(mdisthfac)
	lab var pwdisthfac "Masalah aksesibilitas ke faskes"

*\kuintil
xtile qpwdisthfac = pwdisthfac, nq(5)
	lab var qpwdisthfac "Masalah aksesibilitas ke faskes"
	lab def qpwdisthfac 1 "Kuintil 1"								///
						2 "Kuintil 2"								///
						3 "Kuintil 3"								///
						4 "Kuintil 4"								///
						5 "Kuintil 5"
	lab val qpwdisthfac qpwdisthfac
	tab qpwdisthfac, m

*\pwdisthfac kategori
recode qpwdisthfac (1/2 = 0 "Rendah")								///
				   (3/4 = 1 "Sedang")								///
				   (5 = 2 "Tinggi"), gen(pwdisthfac3c)
	lab var pwdisthfac3c "Masalah aksesibilitas ke faskes (kategorik)"
	tab pwdisthfac3c, m



/*
================================================================================
FINALISASI
================================================================================
*/

keep psu pwdisthfac qpwdisthfac pwdisthfac3c
duplicates drop psu, force
summ(pwdisthfac)

quietly compress
datasignature set, reset
lab data "Variabel komunitas \ `time_date'"
note: `idhs'-mortstudy-community.dta \ `tag'
save "`savenm'", replace


*close log-file
log close _all