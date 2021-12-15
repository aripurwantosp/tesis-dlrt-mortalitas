log close _all
cls
*log file
cd 				"D:\RESEARCH & WRITING\master thesis_child mortality\stata\"
loc logdir		"log"
loc idhs 		"idhs17"
loc dfn 		"log_7b_descriptive_full_`idhs'"
log using 		"`logdir'\7b_descriptive_full_`idhs'", name(`dfn') text replace

/*
================================================================================
********************************************************************************
PROJECT:
PENELITIAN TESIS
DEPRIVASI LINGKUNGAN RUMAH TANGGA DAN KEMATIAN BAYI DAN ANAK DI INDONESIA

SYNTAX:
7-ANALISIS DESKRIPTIF FULL SAMPLE

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



/*
================================================================================
ANAK-KELAHIRAN
================================================================================
*/

/*
******************************************************************
Set sampel													[done]
******************************************************************
*/

*data
use "`dtadir'\6-chmort-`idhs'.dta"
keep if precsvy10 == 1

*cek missing
#delimit ;
glo vars
	/*var bebas utama, lingkungan*/
	depriv depriv2c
	impdrinkwat impsan cookfldr
	/*antara*/
	chsex bordin mageb
	/*sosek*/
	meduc4c peduc4c pareduc	wealth reside pwdisthfac3c
	;
#delimit cr

foreach p in $vars{
	nmissing `p'
}

/*
******************************************************************
Gambaran umum sampel										[done]
******************************************************************
*/

*univar
foreach p in $vars chalive nndeath ideath u5death {
	    quietly tabout `p'			///
		using "output\univar_full_.xls", c(freq col) clab(N %) 			///
		format(0c 2) mi append
}

foreach p in $vars chalive nndeath ideath u5death {
	    quietly tabout `p' [iw=wweight]			///
		using "output\univar_full_iw.xls", c(freq col) clab(N %) 		///
		format(0c 2) mi append
}

*kontinyu
*duplicates drop psu, force
table [iw=wweight], stat(mean pwdisthfac)	///
					stat(median pwdisthfac)	///
					stat(sd pwdisthfac)
					
table, stat(mean pwdisthfac)	///
	   stat(median pwdisthfac)	///
	   stat(sd pwdisthfac)	