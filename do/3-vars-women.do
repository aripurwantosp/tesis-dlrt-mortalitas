/*
================================================================================
********************************************************************************
PROJECT:
PENELITIAN TESIS
DEPRIVASI LINGKUNGAN RUMAH TANGGA DAN KEMATIAN BAYI DAN ANAK DI INDONESIA

SYNTAX:
3-MEMBENTUK VARIABEL PEREMPUAN/IBU

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
loc dfn 		"log_3_vars_women_`idhs'"
log using 		"`logdir'\3_vars_women_`idhs'", name(`dfn') text replace

*set the date
loc date = c(current_date)
loc time = c(current_time)
loc time_date = "`date'" + "_" + "`time'"
loc tag "`dfn'.do Ari Prasojo `time_date'"

*direktori dataset
*\dataset rumah tangga
loc irc			"D:\PUSDATIN\DATA MIKRO\IDHS\2017\IDIR71DT\IDIR71FL.dta"

*\dataset disimpan sebagai (nama)
loc savenm		"`dtadir'\3-vars-women-`idhs'.dta"

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

*\3 kategori (tidak sekolah, dasar, menengah/lebih tinggi)
recode meduc4c (0 = 0 "Tidak sekolah") 									///
			   (1 = 1 "Dasar")											///
			   (2 3 = 2 "Menengah/lebih tinggi"), gen(meduc)
	lab var meduc "Pendidikan tertinggi yang ditamatkan ibu"
	tab meduc, m

*\3 kategori (tidak/dasar, menengah, tinggi)
recode meduc4c (0/1 = 0 "Tidak sekolah/dasar") 							///
			   (2 = 1 "Menengah")										///
			   (3 = 2 "Tinggi"), gen(meduc3c)
	lab var meduc3c "Pendidikan tertinggi yang ditamatkan ibu"
	tab meduc3c, m
	
*\2 kategori (tidak sekolah, dasar/lebih tinggi)
recode meduc4c (0 = 0 "Tidak sekolah")									///
			   (1/3 = 1 "Dasar/lebih tinggi"), gen(meduc2c)
	lab var meduc2c "Pendidikan tertinggi yang ditamatkan ibu"
	tab meduc2c, m
		
*\2 kategori (tidak/dasar, menengah/lebih tinggi)
recode meduc (0 1 = 0 "Tidak sekolah/dasar")							///
			 (2 3 = 1 "Menengah/lebih tinggi"),	gen(meduc2cs)
	lab var meduc2cs "Pendidikan tertinggi yang ditamatkan ibu"
	tab meduc2cs, m

*\2 kategori (tidak/dasar/menengah, tinggi)
recode meduc4c (0/2 = 0 "Tidak sekolah/dasar")							///
			   (3 = 1 "Tinggi"), gen(meduc2ch)
	lab var meduc2ch "Pendidikan tertinggi yang ditamatkan ibu"
	tab meduc2ch, m

*\kontinyu, lama tahun sekolah
clonevar meducy = v133
	replace meducy = . if inlist(v133,97,98)
	lab var meducy "Lama tahun sekolah ibu"
	summ meducy

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

*\3 kategori (tidak sekolah, dasar, menengah/lebih tinggi)
recode peduc4c (0 = 0 "Tidak sekolah") 									///
			   (1 = 1 "Dasar")											///
			   (2 3 = 2 "Menengah/lebih tinggi"), gen(peduc)
	lab var peduc "Pendidikan tertinggi yang ditamatkan ayah"
	tab peduc, m

*\3 kategori (tidak/dasar, menengah, tinggi)
recode peduc4c (0/1 = 0 "Tidak sekolah/dasar") 							///
			   (2 = 1 "Menengah")										///
			   (3 = 2 "Tinggi"), gen(peduc3c)
	lab var peduc3c "Pendidikan tertinggi yang ditamatkan ayah"
	tab peduc3c, m
	
*\2 kategori (tidak sekolah, dasar/lebih tinggi)
recode peduc4c (0 = 0 "Tidak sekolah")									///
			   (1/3 = 1 "Dasar/lebih tinggi"), gen(peduc2c)
	lab var peduc2c "Pendidikan tertinggi yang ditamatkan ayah"
	tab peduc2c, m
		
*\2 kategori (tidak/dasar, menengah/lebih tinggi)
recode peduc (0 1 = 0 "Tidak sekolah/dasar")							///
			 (2 3 = 1 "Menengah/lebih tinggi"), gen(peduc2cs)
	lab var peduc2cs "Pendidikan tertinggi yang ditamatkan ayah"
	tab peduc2cs, m

*\2 kategori (tidak/dasar/menengah, tinggi)
recode peduc4c (0/2 = 0 "Tidak sekolah/dasar")							///
			   (3 = 1 "Tinggi"), gen(peduc2ch)
	lab var peduc2ch "Pendidikan tertinggi yang ditamatkan ayah"
	tab peduc2ch, m

*\kontinyu, lama tahun sekolah
clonevar peducy = v715
	replace peducy = . if inlist(v715,97,98)
	lab var peducy "Lama tahun sekolah ayah"
	summ peducy
	
/*
******************************************************************
Pendidikan ibu-ayah											[done]
******************************************************************
*/

/*
gen pareduc1 = .
	replace pareduc1 = 0 if meduc2c == 0 & peduc2c == 0
	replace pareduc1 = 1 if meduc2c == 0 & peduc2c == 1
	replace pareduc1 = 2 if meduc2c == 1 & peduc2c == 0
	replace pareduc1 = 3 if meduc2c == 1 & peduc2c == 1
	lab var pareduc1 "Pendidikan orang tua (ibu-ayah)"
	lab def pareduc1 0 "Tidak-tidak"									///
					 1 "Tidak-berpendidikan"							///
					 2 "Berpendidikan-tidak"							///
					 3 "Berpendidikan",									///
					replace
	lab val pareduc1 pareduc1
	tab pareduc1, m
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
gen pareduc = .
	replace pareduc = 0 if meduc2cs == 0 & peduc2cs == 0
	replace pareduc = 1 if meduc2cs == 1 & peduc2cs == 1
	replace pareduc = 2 if meduc2cs == 0 & peduc2cs == 1
	replace pareduc = 3 if meduc2cs == 1 & peduc2cs == 0
	lab var pareduc "Pendidikan orang tua (ibu-ayah)"
	lab def pareduc 0 "Rendah"											///
				    1 "Tinggi"											///
				    2 "Ibu < ayah"										///
				    3 "Ibu > ayah",										///
				    replace
	lab val pareduc pareduc
	tab pareduc, m
*/

/*
gen pareduc1 = .
	replace pareduc1 = 0 if meduc2ch == 0 & peduc2ch == 0
	replace pareduc1 = 1 if meduc2ch == 1 & peduc2ch == 1
	replace pareduc1 = 2 if meduc2ch == 0 & peduc2ch == 1
	replace pareduc1 = 3 if meduc2ch == 1 & peduc2ch == 0
	lab var pareduc1 "Pendidikan orang tua (ibu-ayah)"
	lab val pareduc1 pareduc
	tab pareduc1, m

gen difmpeducy = meducy-peducy
	lab var difmpeducy "Perbedaan lama tahun sekolah ibu-ayah"

gen ratmpeducy = meducy/peducy
	lab var ratmpeducy "Rasio lama tahun sekolah ibu-ayah"
	
gen difpmeducy = peducy-meducy
	lab var difpmeducy "Perbedaan lama tahun sekolah ibu-ayah"

gen ratpmeducy = peducy/meducy
	lab var ratpmeducy "Rasio lama tahun sekolah ibu-ayah"
*/
	
/*
gen mating = .
	replace mating = 0 if meduc2cs == 0 & peduc2cs == 0
	replace mating = 1 if meduc2cs == 1 & peduc2cs == 1
	replace mating = 2 if meduc2cs == 0 & peduc2cs == 1
	replace mating = 3 if meduc2cs == 1 & peduc2cs == 0
	lab var mating "Assortative pendidikan orang tua"
	lab def mating 0 "Homogami-rendah"									///
				   1 "Homogami-tinggi"									///
				   2 "Hipergami"										///
				   3 "Hipogami",										///
				   replace
	lab val mating mating
	tab mating, m
*/
	
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