log close _all
clear all
macro drop _all
cls
*dir & log file
cd 				"D:\RESEARCH & WRITING\master thesis_child mortality\stata\"
loc idhs 		"idhs17"
loc dfn 		"log_4_vars_birth_`idhs'"
log using 		"log\4_vars_birth_`idhs'", name(`dfn') text replace

/*
================================================================================
********************************************************************************
PROJECT:
PENELITIAN TESIS
HUBUNGAN ANTARA DEPRIVASI LINGKUNGAN RUMAH TANGGA DENGAN KEMATIAN BAYI DAN ANAK
DI INDONESIA: BUKTI DARI MODEL LOGISTIK MULTILEVEL HAZARD DISKRIT

SYNTAX:
4-MEMBENTUK VARIABEL ANAK/KELAHIRAN

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
*\dataset kelahiran
loc brc			"D:\PUSDATIN\DATA MIKRO\IDHS\2017\IDBR71DT\IDBR71FL.dta"

*\dataset disimpan sebagai (nama)
loc savenm		"dta\4-vars-birth-`idhs'.dta"

*read data
use "`brc'"

*membuat label
lab def yatidak 0 "Tidak" 1 "Ya" 		//yatidak



/*
================================================================================
SAMPEL
================================================================================
*/

*\umur hipotetik/lama lahir-interview (bulan)				[done]
gen hypage = v008-b3
	lab var hypage "Umur hipotetik (lahir-interview, bulan)"
	
*\anak yang dilahirkan 0-10 tahun sebelum survei			[done]
gen precsvy10 = .
	lab var precsvy10 "Dilahirkan 0-10 tahun sebelum survei"
	replace precsvy10 = 1 if inrange(hypage, 0, 119)
	replace precsvy10 = 0 if hypage > 119
	lab val precsvy10 yatidak
	tab precsvy10, m
	

	
/*
================================================================================
VARIABEL TERIKAT
================================================================================
*/

*\Status kelangsungan hidup anak							[done]
gen chalive = b5
	lab var chalive "Apakah anak masih hidup?"
	lab val chalive yatidak
	tab chalive, m

/*
******************************************************************
Umur anak saat meninggal									[done]
******************************************************************
*/

*\identifier satuan usia saat meninggal	
*-b6 adalah usia saat meninggal (satuan digit di depan)
gen satdeath = int(b6/100) if !inlist(b6,199,299,399,997,998)
	lab var satdeath "Satuan usia saat meninggal"
	lab def satdeath 1 "Hari" 2 "Bulan" 3 "Tahun"
	lab val satdeath satdeath
	tab satdeath, m

*\usia saat meninggal (bulan, imputed DHS)
gen agedeathimp = b7
	lab var agedeathimp "Usia anak saat meninggal (bulan,imputasi DHS)"
	tab agedeathimp, m

*\hitung dari laporan dalam survei
*-satuan masih sesuai dengan format DHS
gen agedeath = .
	lab var agedeath "Usia anak saat meninggal"
	replace agedeath = b6-100 if satdeath == 1
	replace agedeath = b6-200 if satdeath == 2
	replace agedeath = b6-300 if satdeath == 3
*br b5-b7 satdeath agedeath

*\dari laporan survei konversi ke hari
gen agedeathd = .
	lab var agedeathd "Usia anak saat meninggal (hari)"
	replace agedeathd = agedeath if satdeath == 1
	replace agedeathd = agedeath*30 if satdeath == 2
	replace agedeathd = agedeath*360 if satdeath == 3

*\dari laporan survei konversi ke bulan
gen agedeathm = .
	lab var agedeathm "Usia anak saat meninggal (bulan)"
	*replace agedeathm = 0 if satdeath == 1 & agedeath < 30
	*replace agedeathm = 1 if satdeath == 1 & agedeath >= 30
	replace agedeathm = int(agedeath/30) if satdeath == 1
	replace agedeathm = agedeath if satdeath == 2
	replace agedeathm = agedeath*12 if satdeath == 3
*br agedeathimp agedeathm if chalive == 0

/*
******************************************************************
Kematian neonatal (0-28 hari)								[done]
******************************************************************
*/

*\Status kematian neonatal
gen nndeath = .
	lab var nndeath "Meninggal saat periode neonatal"
	replace nndeath = 1 if satdeath == 1 & agedeath <= 28
	replace nndeath = 0 if nndeath != 1
	replace nndeath = . if chalive == 0 & agedeath == .
	lab val nndeath yatidak
	tab nndeath, m

*\Umur periode neonatal
gen agenndeath = .
	lab var agenndeath "Umur bayi/anak, berdasarkan periode neonatal (hari)"
	replace agenndeath = agedeath if nndeath == 1
	replace agenndeath = 28 if nndeath == 0
	summ agenndeath

/*
******************************************************************
Kematian bayi (0-11 bulan)									[done]
******************************************************************
*/

*\Status kematian bayi
gen ideath = .
	lab var ideath "Meninggal saat periode 0-11 bulan"
	replace ideath = 1 if agedeathm <= 11
	replace ideath = 0 if ideath != 1
	replace ideath = . if chalive == 0 & agedeath == .
	lab val ideath yatidak
	tab ideath, m

*\Umur periode kematian bayi
gen ageideath = .
	lab var ageideath "Umur bayi/anak, berdasarkan periode kematian bayi (bulan)"
	replace ageideath = agedeathm if ideath == 1
	replace ageideath = 11 if ideath == 0
	summ ageideath
	
gen ageideathd = agedeathd
	lab var ageideathd "Umur bayi/anak, berdasarkan periode kematian bayi (hari)"
	replace ageideathd = 359 if ideath == 0
	summ ageideathd

/*
******************************************************************
Kematian anak di bawah 5 tahun (0-59 bulan)					[done]
******************************************************************
*/

*\Status kematian anak di bawah 5 tahun
gen u5death = .
	lab var u5death "Meninggal saat periode 0-59 bulan"
	replace u5death = 1 if agedeathm <= 59
	replace u5death = 0 if u5death != 1
	replace u5death = . if chalive == 0 & agedeath == .
	lab val u5death yatidak
	tab u5death, m

*\Umur periode kematian anak di bawah 5 tahun
gen ageu5death = .
	lab var ageu5death "Umur bayi/anak, berdasarkan periode kematian di bawah 5 tahun (bulan)"
	replace ageu5death = agedeathm if u5death == 1
	replace ageu5death = 59 if u5death == 0
	summ ageu5death

gen ageu5deathd = agedeathd
	lab var ageu5deathd "Umur bayi/anak, berdasarkan periode kematian di bawah 5 tahun (hari)"
	replace ageu5deathd = 1799 if u5death == 0
	summ ageu5deathd

	
	
/*
================================================================================
VARIABEL BEBAS
================================================================================
*/

/*
******************************************************************
Jenis kelamin anak											[done]
******************************************************************
*/

recode b4 (2 = 0 "Perempuan") (1 = 1 "Laki-laki"), gen(chsex)
	lab var chsex "Jenis kelamin anak"
	tab chsex, m

/*
******************************************************************
Umur ibu saat melahirkan									[done]
******************************************************************
*/

*\Kontinyu
/*
-dihitung dari tanggal lahir ibu dan tanggal lahir anak (CMC),
-hasil dalam satuan tahun
*/

gen mageby = floor((b3-v011)/12)
	lab var mageby "Umur ibu saat melahirkan"

gen mageby2 = mageby^2
	lab var mageby2 "Umur ibu saat melahirkan^2"

*\4 kategori
recode mageby (min/19 = 0 "<20")										///
			  (20/29 = 1 "20-29")										///
			  (30/39 = 2 "30-39")										///
			  (40/49 = 3 "40-49"),										///
			  gen(mageb)
	lab var mageb "Umur ibu saat melahirkan"
	tab mageb, m
	
/*
******************************************************************
Urutan dan jarak dengan kelahiran sebelumnya				[done]
******************************************************************
*/

*-bord adalah urutan kelahiran
*-b11 adalah jarak kelahiran sebelumnya (dalam bulan)
gen bordin = .
	replace bordin = 0 if bord == 1
	replace bordin = 1 if bord == 2 & b11 >= 24
	replace bordin = 2 if bord == 2 & b11 < 24
	replace bordin = 3 if bord >= 3 & b11 >= 24
	replace bordin = 4 if bord >= 3 & b11 < 24
	lab var bordin "Urutan dan jarak kelahiran sebelumnya"
	lab def bordin 0 "Pertama"					///
					1 "2 dan >=24 bulan"		///
					2 "2 dan <24 bulan"		///
					3 ">=3 dan >=24 bulan"	///
					4 ">=3 dan <24 bulan", replace
	lab val bordin bordin
	tab bordin, m
	assert bordin == 0 if bord == 1


   
/*
================================================================================
FINALISASI
================================================================================
*/

keep v001 v002 v003 bidx hypage-bordin
	 
quietly compress
datasignature set, reset
lab data "Variabel anak-kelahiran \ `time_date'"
note: `idhs'-mortstudy-birth.dta \ `tag'
save "`savenm'", replace


*close log-file
log close _all