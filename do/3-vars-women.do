log close _all
clear all
macro drop _all
cls
*dir & log file
cd 				"D:\RESEARCH & WRITING\master thesis_child mortality\stata\"
loc idhs 		"idhs17"
loc dfn 		"log_3_vars_women_`idhs'"
log using 		"log\3_vars_women_`idhs'", name(`dfn') text replace

/*
================================================================================
********************************************************************************
PROJECT:
PENELITIAN TESIS
HUBUNGAN ANTARA DEPRIVASI LINGKUNGAN RUMAH TANGGA DENGAN KEMATIAN BAYI DAN ANAK
DI INDONESIA: BUKTI DARI MODEL LOGISTIK MULTILEVEL HAZARD DISKRIT

SYNTAX:
3-MEMBENTUK VARIABEL PEREMPUAN/IBU

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
*\dataset rumah tangga
loc irc			"D:\PUSDATIN\DATA MIKRO\IDHS\2017\IDIR71DT\IDIR71FL.dta"

*\dataset disimpan sebagai (nama)
loc savenm		"dta\3-vars-women-`idhs'.dta"

*read data
use "`irc'"

*membuat label
lab def yatidak 0 "Tidak" 1 "Ya" 			//yatidak



/*
================================================================================
VARIABEL-VARIABEL IBU
================================================================================
*/

*\Penimbang individu perempuan
gen wweight = v005/1000000
lab var wweight "Penimbang perempuan"

/*
******************************************************************
Pendidikan ibu												[done]
******************************************************************
*/

*\Raw, 4 kategori
clonevar meduc4c = v106
	lab var meduc4c "Pendidikan tertinggi yang ditamatkan ibu"
	lab def meduc4c 0 "Tidak sekolah"									///
					1 "Dasar"											///
					2 "Menengah"										///
					3 "Tinggi", replace
	lab val meduc4c meduc4c
	tab meduc4c, m 
		
*\2 kategori (tidak/dasar, menengah/lebih tinggi)
recode meduc4c (0 1 = 0 "Tidak sekolah/dasar")							///
			   (2 3 = 1 "Menengah/lebih tinggi"), gen(meduc2cs)
	lab var meduc2cs "Pendidikan tertinggi yang ditamatkan ibu"
	tab meduc2cs, m

/*
*\kontinyu, lama tahun sekolah
clonevar meducy = v133
	replace meducy = . if inlist(v133,97,98)
	lab var meducy "Lama tahun sekolah ibu"
	summ meducy
*/

/*
******************************************************************
Pendidikan ayah/pasangan dari ibu							[done]
******************************************************************
*/

*\Raw, 4 kategori
clonevar peduc4c = v701
	replace peduc4c = . if peduc4c == 8			/*don't know*/
	lab var peduc4c "Pendidikan tertinggi yang ditamatkan ayah"
	lab val peduc4c meduc4c
	tab peduc4c, m
			
*\2 kategori (tidak/dasar, menengah/lebih tinggi)
recode peduc4c (0 1 = 0 "Tidak sekolah/dasar")							///
			   (2 3 = 1 "Menengah/lebih tinggi"), gen(peduc2cs)
	lab var peduc2cs "Pendidikan tertinggi yang ditamatkan ayah"
	tab peduc2cs, m

/*
*\kontinyu, lama tahun sekolah
clonevar peducy = v715
	replace peducy = . if inlist(v715,97,98)
	lab var peducy "Lama tahun sekolah ayah"
	summ peducy
*/
	
/*
******************************************************************
Pendidikan ibu-ayah											[done]
******************************************************************
*/

gen pareduc = .
	replace pareduc = 0 if meduc2cs == 0 & peduc2cs == 0
	replace pareduc = 1 if meduc2cs == 0 & peduc2cs == 1
	replace pareduc = 2 if meduc2cs == 1 & peduc2cs == 0
	replace pareduc = 3 if meduc2cs == 1 & peduc2cs == 1
	lab var pareduc "Pendidikan orang tua (ibu-ayah)"
	lab def pareduc 0 "Rendah"											///
				    1 "Ibu < ayah"										///
				    2 "Ibu > ayah"										///
				    3  "Tinggi",										///
				    replace
	lab val pareduc pareduc
	tab pareduc, m
	
/*
******************************************************************
Jarak ke fasilitas kesehatan (persepsi)						[done]
******************************************************************
*/

recode v467d (2 = 0 "Tidak/tidak masalah")								///
			 (1 = 1 "Masalah"), gen(mdisthfac)
	lab var mdisthfac "Jarak ke fasilitas kesehatan untuk mendapatkan pertolongan medis"
	tab mdisthfac, m


		
/*
================================================================================
FINALISASI
================================================================================
*/

keep v001 v002 v003 wweight-mdisthfac							
order v001 v002 v003 wweight-mdisthfac
	 
quietly compress
datasignature set, reset
lab data "Variabel perempuan \ `time_date'"
note: `idhs'-mortstudy-women.dta \ `tag'
save "`savenm'", replace


*close log-file
log close _all