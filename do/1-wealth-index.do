log close _all
clear all
macro drop _all
cls
*dir & log file
cd 				"D:\RESEARCH & WRITING\master thesis_child mortality\stata\"
loc idhs 		"idhs17"
loc dfn 		"log_1_wealth_index_`idhs'"
log using 		"log\1_wealth_index_`idhs'", name(`dfn') text replace

/*
================================================================================
********************************************************************************
PROJECT:
PENELITIAN TESIS
HUBUNGAN ANTARA DEPRIVASI LINGKUNGAN RUMAH TANGGA DENGAN KEMATIAN BAYI DAN ANAK
DI INDONESIA: BUKTI DARI MODEL LOGISTIK MULTILEVEL HAZARD DISKRIT

SYNTAX:
1-MEMBENTUK INDEKS KEKAYAAN
METODE DHS, RUTSTEIN & JOHNSON (2004)

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
*\dataset individu
loc irc			"D:\PUSDATIN\DATA MIKRO\IDHS\2017\IDIR71DT\IDIR71FL.dta"

*\dataset laki-laki
loc mrc			"D:\PUSDATIN\DATA MIKRO\IDHS\2017\IDMR71DT\IDMR71FL.dta"

*\dataset rumah tangga
loc hrc			"D:\PUSDATIN\DATA MIKRO\IDHS\2017\IDHR71DT\IDHR71FL.dta"

*\dataset disimpan sebagai (nama)
loc savenm		"dta\1-wealth-index-`idhs'.dta"

*membuat label
lab def yatidak 0 "Tidak" 1 "Ya" 		//yatidak



/*
================================================================================
KONSTRUKSI INDIKATOR DARI DATASET INIDIVIDU

Untuk membentuk variabel house, land
================================================================================
*/

/*
******************************************************************
Perempuan													[done]
******************************************************************
 */
clear all
use caseid v001 v002 v003 v745a v745b using "`irc'"

recode v745a (0 = 0) (1/3 = 1), gen(whouse)
recode v745b (0 = 0) (1/3 = 1), gen(wland)
egen hwhouse = max(whouse), by(v001 v002)
egen hwland = max(wland), by(v001 v002)
duplicates drop v001 v002, force
save whouseland, replace

/*
******************************************************************
Laki-Laki													[done]
******************************************************************
 */
clear all
use mcaseid mv001 mv002 mv003 mv745a mv745b using "`mrc'"

rename mv001 v001
rename mv002 v002
recode mv745a (0 = 0) (1/3 = 1), gen(mhouse)
recode mv745b (0 = 0) (1/3 = 1), gen(mland)
egen hmhouse = max(mhouse), by(v001 v002)
egen hmland = max(mland), by(v001 v002)
duplicates drop v001 v002, force
save mhouseland, replace

/*
******************************************************************
Merge individu perempuan dan laki-laki (household)			[done]
******************************************************************
 */
merge 1:1 v001 v002 using whouseland
keep v001 v002 hwhouse hwland hmhouse hmland
gen house = 0
	replace house = 1 if hwhouse == 1 | hmhouse == 1
	lab var house "Kepemilikan tempat tinggal"
	lab val house yatidak
gen land = 0
	replace land = 1 if hwland == 1 | hmland == 1
	lab var land "Kepemilikan lahan tempat tinggal"
	lab val land yatidak
	
erase whouseland.dta
erase mhouseland.dta
save houseland, replace

/*
******************************************************************
Merge dengan household dataset								[done]
******************************************************************
 */
clear all 
use "`hrc'"
rename hv001 v001
rename hv002 v002
sort v001 v002
merge 1:1 v001 v002 using houseland
erase houseland.dta

/*
******************************************************************
Replace missing dengan 0									[done]
******************************************************************
 */
replace house = 0 if missing(house)
replace land = 0 if missing(land)
summ house
summ land



/*
================================================================================
KONSTRUKSI INDIKATOR DARI DATASET RUMAH TANGGA
================================================================================
*/

/*
******************************************************************
Recode, merubah menjadi variabel dikotom											
******************************************************************
*/

/*
------------------------------------------------------------------
Fungsi-fungsi/perintah-perintah
vr		: nama variabel
value	: nilai variabel
name	: nama variabel varu
lbl		: label variabel baru
------------------------------------------------------------------
*/

*\Perintah untuk dikotomisasi								[done]
program dikotom
	args vr value name lbl
	recode `vr' (`value' = 1) (else = 0), gen(`name')
	lab var `name' "`lbl'"
	lab val `name' yatidak
end

*\Perintah untuk clone variabel								[done]
program klon
	args vr name lbl
	clonevar `name' = `vr'
	replace `name' = 0 if missing(`name')
	lab var `name' "`lbl'"
	lab val `name' yatidak
end	

/*
------------------------------------------------------------------
Indikator-indikator penyusun indeks kekayaan
------------------------------------------------------------------
*/

*\Sumber air minum (hv201)									[done]
dikotom hv201 11 drinkwat_11 "hv201_11_Sumber air minum: saluran ke hunian"
dikotom hv201 12 drinkwat_12 "hv201_12_Sumber air minum: pipa disalurkan ke halaman/petak"
dikotom hv201 13 drinkwat_13 "hv201_13_Sumber air minum: pipa disalurkan ke tetangga"
dikotom hv201 14 drinkwat_14 "hv201_14_Sumber air minum: keran/pipa umum"
dikotom hv201 21 drinkwat_21 "hv201_21_Sumber air minum: sumur tabung/bor"
dikotom hv201 31 drinkwat_31 "hv201_31_Sumber air minum: sumur terlindungi"
dikotom hv201 32 drinkwat_32 "hv201_32_Sumber air minum: sumur tidak terlindungi"
dikotom hv201 41 drinkwat_41 "hv201_41_Sumber air minum: mata air terlindungi"
dikotom hv201 42 drinkwat_42 "hv201_42_Sumber air minum: mata air tidak terlindungi"
dikotom hv201 43 drinkwat_43 "hv201_43_Sumber air minum: sungai/bendungan/danau/kolam/sungai/saluran/saluran irigasi"
dikotom hv201 51 drinkwat_51 "hv201_51_Sumber air minum: air hujan"
dikotom hv201 61 drinkwat_61 "hv201_61_Sumber air minum: truk tangki"
dikotom hv201 62 drinkwat_62 "hv201_62_Sumber air minum: gerobak dengan tangki kecil"
dikotom hv201 71 drinkwat_71 "hv201_71_Sumber air minum: air kemasan"
dikotom hv201 72 drinkwat_72 "hv201_72_Sumber air minum: air isi ulang"
dikotom hv201 96 drinkwat_96 "hv201_96_Sumber air minum: lainnya"

*\Jenis fasilitas toilet (sh109)							[done]
dikotom sh109 11 toiletfac_11 "sh109_11_Jenis toilet: pribadi-dengan tangki septik"
dikotom sh109 12 toiletfac_12 "sh109_12_Jenis toilet: pribadi-tanpa tangki septik"
dikotom sh109 21 toiletfac_21 "sh109_21_Jenis toilet: bersama/umum"
dikotom sh109 31 toiletfac_31 "sh109_31_Jenis toilet: sungai/sungai kecil"
dikotom sh109 32 toiletfac_32 "sh109_32_Jenis toilet: pantai"
dikotom sh109 33 toiletfac_33 "sh109_33_Jenis toilet: kolam"
dikotom sh109 41 toiletfac_41 "sh109_Jenis toilet: lubang"
dikotom sh109 51 toiletfac_51 "sh109_Jenis toilet: pekarangan/semak/hutan"
dikotom sh109 96 toiletfac_96 "sh109_Jenis toilet: lainnya"

*\Bahan bakar memasak (hv226)								[done]
dikotom hv226 1 cookfuel_1 "hv226_1_Bahan bakar memasak: listrik"
dikotom hv226 2 cookfuel_2 "hv226_2_Bahan bakar memasak: LPG"
dikotom hv226 3 cookfuel_3 "hv226_3_Bahan bakar memasak: gas alam"
dikotom hv226 4 cookfuel_4 "hv226_4_Bahan bakar memasak: biogas"
dikotom hv226 5 cookfuel_5 "hv226_5_Bahan bakar memasak: minyak tanah"
dikotom hv226 6 cookfuel_6 "hv226_6_Bahan bakar memasak: batubara, lignit"
dikotom hv226 7 cookfuel_7 "hv226_7_Bahan bakar memasak: arang"
dikotom hv226 8 cookfuel_8 "hv226_8_Bahan bakar memasak: kayu"
replace hv226 = 9 if hv226 == 10
dikotom hv226 9 cookfuel_9 "hv226_9_Bahan bakar memasak: jerami/semak/rumput/tanaman"
dikotom hv226 95 cookfuel_96 "hv226_95_Bahan bakar memasak: tidak ada makanan yang dimasak di rumah"

*\Aset-aset													[done]

*\\Listrik (hv206)				
klon hv206 electricity "Keberadaan listrik"

*\\Radio (hv207)										
klon hv207 radio "Kepemilikan radio"

*\\Televisi (hv208)											
klon hv208 television "Kepemilikan televisi"

*\\Telepon/non-hp (hv221)									
klon hv221 telephone "Kepemilikan telepon"

*\\Komputer (hv234e)								
klon hv243e computer "Kepemilikan komputer"

*\\Refrigerator (hv209)										
klon hv209 refrigerator "Kepemilikan lemari es/refrigerator"

*\\Fan/kipas angin (sh121g)									
klon sh121g fan "Kepemilikan fan/kipas angin"

*\\Mesin cuci (sh121h)										
klon sh121h washingmach "Kepemilikan mesin cuci"

*\\AC (sh121i)												
klon sh121i aircond "Kepemilikan AC"

*\\Jam (hv243b)												
klon hv243b watch "Kepemilikan jam/arloji"

*\\Handphone/telepon genggam (hv243a)						
klon hv243a hp "Kepemilikan telepon genggam"

*\\Sepeda (hv210)											
klon hv210 bcycle "Kepemilikan sepeda"

*\\Sepeda motor (hv211)										
klon hv211 motorcyc "Kepemilikan sepeda motor (salah satu anggota)"

*\\Gerobak yang ditarik hewan (hv243c)						
klon hv243c animdrcart "Kepemilikan gerobak/kendaraan yang ditarik oleh hewan"

*\\Mobil (hv212)											
klon hv212 car "Kepemilikan mobil atau truk (salah satu anggota)"

*\\Perahu motor (hv243d)									
klon hv243d boat "Kepemilikan perahu motor"

*\\Rekening bank (hv247)									
klon hv247 bankac "Kepemilikan rekening bank (salah satu anggota)"

*\Jenis lantai utama rumah (hv213)							[done]
replace hv213 = 11 if hv213 == 12
dikotom hv213 11 matfloor_11 "hv213_Jenis lantai rumah: tanah/pasir"
dikotom hv213 21 matfloor_21 "hv213_Jenis lantai rumah: papan kayu"
dikotom hv213 22 matfloor_22 "hv213_Jenis lantai rumah: palma/bambu"
dikotom hv213 31 matfloor_31 "hv213_Jenis lantai rumah: parket atau kayu poles"
dikotom hv213 32 matfloor_32 "hv213_Jenis lantai rumah: vinil/aspal"
dikotom hv213 33 matfloor_33 "hv213_Jenis lantai rumah: keramik/marmer/granit"
dikotom hv213 34 matfloor_34 "hv213_Jenis lantai rumah: ubin lantai/teraso"
dikotom hv213 35 matfloor_35 "hv213_Jenis lantai rumah: semen/batu bata merah"
dikotom hv213 36 matfloor_36 "hv213_Jenis lantai rumah: karpet"
dikotom hv213 96 matfloor_96 "hv213_Jenis lantai rumah: lainnya"

*\Jenis atap rumah (hv215)									[done]
dikotom hv215 12 matroof_12 "hv215_Jenis atap rumah: rumbia/daun palem"
dikotom hv215 13 matroof_13 "hv215_Jenis atap rumah: atap tanah atau sod"
dikotom hv215 21 matroof_21 "hv215_Jenis atap rumah: atap tikar pedesaan"
dikotom hv215 22 matroof_22 "hv215_Jenis atap rumah: palma/bambu"
dikotom hv215 23 matroof_23 "hv215_Jenis atap rumah: papan kayu"
dikotom hv215 31 matroof_31 "hv215_Jenis atap rumah: roofing, seng"
dikotom hv215 32 matroof_32 "hv215_Jenis atap rumah: asbes"
dikotom hv215 33 matroof_33 "hv215_Jenis atap rumah: genteng"
dikotom hv215 34 matroof_34 "hv215_Jenis atap rumah: beton"
dikotom hv215 35 matroof_35 "hv215_Jenis atap rumah: genteng logam"
dikotom hv215 36 matroof_36 "hv215_Jenis atap rumah: atap sirap"
dikotom hv215 96 matroof_96 "hv215_Jenis atap rumah: lainnya"

*\Jenis dinding rumah (hv214)								[done]
dikotom hv214 12 matwall_12 "hv214_Jenis dinding rumah: tongkat/palma/batang"
replace hv214 = 21 if hv214 == 13
dikotom hv214 21 matwall_21 "hv214_Jenis dinding rumah: bambu dengan tanah/tanah"
dikotom hv214 22 matwall_22 "hv214_Jenis dinding rumah: batu dengan tanah"
dikotom hv214 23 matwall_23 "hv214_Jenis dinding rumah: batu bata terbuka"
dikotom hv214 24 matwall_24 "hv214_Jenis dinding rumah: kayu lapis"
dikotom hv214 25 matwall_25 "hv214_Jenis dinding rumah: karton"
dikotom hv214 26 matwall_26 "hv214_Jenis dinding rumah: kayu bekas"
dikotom hv214 31 matwall_31 "hv214_Jenis dinding rumah: anyaman bambu"
dikotom hv214 32 matwall_32 "hv214_Jenis dinding rumah: batu dengan kapur/semen"
dikotom hv214 34 matwall_34 "hv214_Jenis dinding rumah: batako"
dikotom hv214 35 matwall_35 "hv214_Jenis dinding rumah: batu bata tertutup"
dikotom hv214 36 matwall_36 "hv214_Jenis dinding rumah: papan kayu/sirap"
dikotom hv214 37 matwall_37 "hv214_Jenis dinding rumah: kawat plester"
dikotom hv214 38 matwall_38 "hv214_Jenis dinding rumah: gipsum/asbes"
dikotom hv214 96 matwall_96 "hv214_Jenis dinding rumah: lainnya"

*\Jumlah art per ruang/kamar untuk tidur					[done]
gen memsleep = .
	lab var memsleep "Jumlah art per ruang untuk tidur"
	gen nmember = hv012
	replace nmember = hv013 if nmember == 0
	replace memsleep = trunc(hv012/hv216) if hv216 > 0
	replace memsleep = hv012 if hv216 == 0
	drop nmember

*\Luas lantai												[done]
gen floorarea = sh142a
	lab var floorarea "Luas lantai rumah (m2)"
	replace floorarea = . if sh142a == 998
	summ floorarea

*\Luas lahan (hv244, hv245)									[done]
gen landagr = hv244
	lab var landagr "Kepemilikan lahan yang dapat digunakan untuk pertanian"
	lab val landagr yatidak
	replace landagr = 0 if landagr != 1

replace hv245 = hv245/10
gen landarea = 0
	lab var landarea "Luas lahan yang dapat digunakan untuk pertanian (hektar)"
	replace landarea = hv245 if !missing(hv245)
	replace landarea = . if missing(hv245) | hv245 > 99.8
	replace landarea = 0 if hv244 != 1

*\Kepemilikan ternak										[done]
/*
hv246b, hv246g, hv246c, hv246h, hv246i, hv246f
cows/bulls, water buffaloes, horses/dunkeys/mules, goats/sheep, pigs, chickens/poultry
sapi/banteng, kerbau, kuda/keledai, kambing/domba, babi, ayam/unggas
*/

recode hv246c (1/4 = 1) (5/95 = 2) (else = 0), gen(hv246c_r)
recode hv246f (1/9 = 1) (10/29 = 2) (30/95 = 3) (else = 0), gen(hv246f_r)

foreach i of varlist hv246b hv246g hv246h hv246i  {
	recode `i' (1/4 = 1) (5/9 = 2) (10/95 = 3) (else = 0), gen(`i'_r)
}

*\\sapi/banteng
dikotom hv246b_r 1 cowbull_1 "hv246b_Kepemilikan sapi/banteng: 1-4"
dikotom hv246b_r 2 cowbull_2 "hv246b_Kepemilikan sapi/banteng: 5-9"
dikotom hv246b_r 3 cowbull_3 "hv246b_Kepemilikan sapi/banteng: 10+"

*\\kerbau
dikotom hv246g_r 1 buffal_1 "hv246g_Kepemilikan kerbau: 1-4"
dikotom hv246g_r 2 buffal_2 "hv246g_Kepemilikan kerbau: 5-9"
dikotom hv246g_r 3 buffal_3 "hv246g_Kepemilikan kerbau: 10+"

*\\kuda/keledai
dikotom hv246c_r 1 horse_1 "hv246c_Kepemilikan kuda/keledai: 1-4"
dikotom hv246c_r 2 horse_2 "hv246c_Kepemilikan kuda/keledai: 5+"

*\\kambing/domba
dikotom hv246h_r 1 goat_1 "hv246h_Kepemilikan kambing/domba: 1-4"
dikotom hv246h_r 2 goat_2 "hv246h_Kepemilikan kambing/domba: 5-9"
dikotom hv246h_r 3 goat_3 "hv246h_Kepemilikan kambing/domba: 10+"

*\\babi
dikotom hv246i_r 1 pig_1 "hv246i_Kepemilikan babi: 1-4"
dikotom hv246i_r 2 pig_2 "hv246i_Kepemilikan babi: 5-9"
dikotom hv246i_r 3 pig_3 "hv246i_Kepemilikan babi: 10+"

*\\ayam/unggas
dikotom hv246f_r 1 chicken_1 "hv246f_Kepemilikan ayam/unggas: 1-4"
dikotom hv246f_r 2 chicken_2 "hv246f_Kepemilikan ayam/unggas: 5-9"
dikotom hv246f_r 3 chicken_3 "hv246f_Kepemilikan ayam/unggas: 10+"


/*
******************************************************************
Deskriptif										
******************************************************************
*/

/*
------------------------------------------------------------------
Cek frekuensi dengan indikator asli							[done]
------------------------------------------------------------------
*/

*\\Sumber air
tab hv201
tab1 drinkwat_*

*\\Toilet
tab sh109
tab1 toiletfac_*

*\\Bahan bakar memasak
tab hv226
tab1 cookfuel_*

*\\Aset-aset (listrik-rekening/hv206-hv247)
tab1 hv206 electricity
tab1 hv207 radio
tab1 hv208 television
tab1 hv221 telephone
tab1 hv243e computer
tab1 hv209 refrigerator
tab1 sh121g fan
tab1 sh121h washingmach
tab1 sh121i aircond
tab1 hv243b watch
tab1 hv243a hp
tab1 hv210 bcycle
tab1 hv211 motorcyc
tab1 hv243c animdrcart
tab1 hv212 car
tab1 hv243d boat
tab1 hv247 bankac

*\\Lantai rumah
tab hv213
tab1 matfloor_*

*\\Atap rumah
tab hv215
tab1 matroof_*

*\\Dinding rumah
tab hv214
tab1 matwall_*

*\\Kepemilikan ternak
*\\\sapi/banteng
tab hv246b_r
tab1 cowbull_*

*\\\kerbau
tab hv246g_r
tab1 buffal_*

*\\\kuda/keledai
tab hv246c_r
tab1 horse_*

*\\\kambing/domba
tab hv246h_r
tab1 goat_*

*\\\babi
tab hv246i_r
tab1 pig_*

*\\\ayam/unggas
tab hv246f_r
tab1 chicken_*

drop hv246c_r-hv246i_r



/*
================================================================================
INDEKS KEKAYAAN (LENGKAP)
================================================================================
*/

/*
******************************************************************
Commons/Umum/All											[done]
******************************************************************
 */

/*
------------------------------------------------------------------
Ringkasan Deskriptif										[done]
------------------------------------------------------------------
*/

*\raw
#delimit ;
glo indicator
	drinkwat_* toiletfac_* cookfuel_* electricity-bankac matfloor_*
	matroof_* matwall_* house land
	;
#delimit cr
summ $indicator memsleep floorarea
mdesc $indicator memsleep floorarea

*\replace missing dengan mean
gen memsleep_iall = memsleep
	lab var memsleep_iall "Jumlah art per ruang untuk tidur (imputasi mean, all)"
	quiet: egen meanval = mean(memsleep)
	replace memsleep_iall = meanval if missing(memsleep)
	drop meanval

gen floorarea_iall = floorarea
	lab var floorarea_iall "Luas lantai rumah (m2) (imputasi mean, all)"
	quiet: egen meanval = mean(floorarea)
	replace floorarea_iall = meanval if missing(floorarea)
	drop meanval
 
summ $indicator memsleep_iall floorarea_iall
mdesc $indicator memsleep_iall floorarea_iall

/*
------------------------------------------------------------------
Skor - Faktor PCA											[done]
------------------------------------------------------------------
*/

*\factor pc
factor $indicator memsleep_iall floorarea_iall, factors(1) pcf
predict wi_complete_all
lab var wi_complete_all "Indeks kekayaan (lengkap, umum)"

/*
******************************************************************
Kota-desa													[done]
******************************************************************
*/

/*
------------------------------------------------------------------
Ringkasan Deskriptif										[done]
------------------------------------------------------------------
*/

*\raw
#delimit ;
glo indicator
	drinkwat_* toiletfac_* cookfuel_* electricity-bankac
	matfloor_* matroof_* matwall_* house land
	cowbull_* buffal_* horse_* goat_* pig_* chicken_*
	;
#delimit cr
sort hv025, stable
by hv025: summ $indicator memsleep landarea floorarea
by hv025: mdesc $indicator memsleep landarea floorarea

*\replace missing dengan mean
gen memsleep_iurbrur = memsleep
	lab var memsleep_iurbrur "Jumlah art per ruang untuk tidur (imputasi mean, kota/desa)"
	quiet: by hv025: egen meanval = mean(memsleep)
	by hv025: replace memsleep_iurbrur = meanval if missing(memsleep)
	drop meanval

gen landarea_iurbrur = landarea
	lab var landarea_iurbrur "Luas lahan yang dapat digunakan untuk pertanian (hektar) (imputasi mean, kota/desa)"
	quiet: by hv025: egen meanval = mean(landarea)
	by hv025: replace landarea_iurbrur = meanval if missing(landarea)
	drop meanval
	
gen floorarea_iurbrur = floorarea
	lab var floorarea_iurbrur "Luas lantai rumah (m2) (imputasi mean, kota/desa)"
	quiet: by hv025: egen meanval = mean(floorarea)
	by hv025: replace floorarea_iurbrur = meanval if missing(floorarea)
	drop meanval

by hv025: summ $indicator memsleep_iurbrur landarea_iurbrur floorarea_iurbrur
by hv025: mdesc $indicator memsleep_iurbrur landarea_iurbrur floorarea_iurbrur

/*
------------------------------------------------------------------
Skor - Faktor PCA											[done]
------------------------------------------------------------------
*/

*\factor pc
factor $indicator memsleep_iurbrur landarea_iurbrur floorarea_iurbrur		///
		if hv025 == 1, factors(1) pcf
predict wi_complete_urb if hv025 == 1

factor $indicator memsleep_iurbrur landarea_iurbrur floorarea_iurbrur		///
		if hv025 == 2, factors(1) pcf
predict wi_complete_rur if hv025 == 2

gen wi_complete_urbrur = wi_complete_urb
	lab var wi_complete_urbrur "Indeks kekayaan (lengkap, kota/desa)"
	replace wi_complete_urbrur = wi_complete_rur if hv025 == 2

drop wi_complete_urb wi_complete_rur

*\ringkasan
summ wi_complete_urbrur
histogram wi_complete_urbrur, density normal
graph export ".\output\hist_wi_complete_urbrur.png", replace
sepscatter hv271 wi_complete_urbrur, separate(hv025)
graph export ".\output\scat_wi_complete_urbrur.png", replace

/*
******************************************************************
Komposit/Kombinasi											[done]
******************************************************************
*/

/*
------------------------------------------------------------------
Regress														[done]
------------------------------------------------------------------
*/

*\kota
regress wi_complete_all wi_complete_urbrur if hv025 == 1
predict wi_1

*\desa
regress wi_complete_all wi_complete_urbrur if hv025 == 2
predict wi_2

*\skor
gen wi_complete_combine = .
	lab var wi_complete_combine "Indeks kekayaan (lengkap, kombinasi)"
	replace wi_complete_combine = wi_1 if hv025 == 1
	replace wi_complete_combine = wi_2 if hv025 == 2

drop wi_1 wi_2

*\ringkasan
summ wi_complete_combine
histogram wi_complete_combine, density normal
graph export ".\output\hist_wi_complete_combine.png", replace
sepscatter hv271a wi_complete_combine, separate(hv025)
graph export ".\output\scat_wi_complete_combine.png", replace

/*
******************************************************************
Kuintil indeks 												[done]
******************************************************************
*/

*\penimbang
gen hhweight = hv005/1000000
	lab var hhweight "Penimbang rumah tangga"

gen hmweight = hhweight*hv012
	lab var hmweight "Penimbang rumah tangga x jumlah art"
	replace hmweight = hhweight*hv013 if hv012 == 0

*\kota/desa
xtile wiq_complete_urb = wi_complete_urbrur if hv025 == 1 [pw = hmweight], nq(5)
xtile wiq_complete_rur = wi_complete_urbrur if hv025 == 2 [pw = hmweight], nq(5)
gen wiq_complete_urbrur = .
	lab var wiq_complete_urbrur "Kuintil indeks kekayaan (lengkap, kota/desa)"
	replace wiq_complete_urbrur = wiq_complete_urb if hv025 == 1
	replace wiq_complete_urbrur = wiq_complete_rur if hv025 == 2
drop wiq_complete_urb wiq_complete_rur

tab hv270a wiq_complete_urbrur

*\kombinasi
xtile wiq_complete_combine = wi_complete_combine [pw = hmweight], nq(5)
	lab var wiq_complete_combine "Kuintil indeks kekayaan (lengkap, kombinasi)"

tab hv270 wiq_complete_combine

/*
******************************************************************
Desil indeks 												[done]
******************************************************************
*/

*\kota/desa
xtile wid_complete_urb = wi_complete_urbrur if hv025 == 1 [pw = hmweight], nq(10)
xtile wid_complete_rur = wi_complete_urbrur if hv025 == 2 [pw = hmweight], nq(10)
gen wid_complete_urbrur = .
	lab var wid_complete_urbrur "Desil indeks kekayaan (lengkap, kota/desa)"
	replace wid_complete_urbrur = wid_complete_urb if hv025 == 1
	replace wid_complete_urbrur = wid_complete_rur if hv025 == 2
drop wid_complete_urb wid_complete_rur

tab wid_complete_urbrur

*\\kombinasi
xtile wid_complete_combine = wi_complete_combine [pw = hmweight], nq(10)
	lab var wid_complete_combine "Desil indeks kekayaan (lengkap, kombinasi)"

tab wid_complete_combine



/*
================================================================================
INDEKS KEKAYAAN (TEREDUKSI)

Tanpa indikator:
-Sumber air minum
-Jenis toilet
-Bahan bakar memasak
================================================================================
*/

/*
******************************************************************
Commons/Umum/All											[done]
******************************************************************
*/

/*
------------------------------------------------------------------
Skor - Faktor PCA											[done]
------------------------------------------------------------------
*/

#delimit ;
glo indicator 
	electricity-bankac matfloor_* matroof_* matwall_*
	house land memsleep_iall floorarea_iall
	;
#delimit cr

*\factor pc
factor $indicator, factors(1) pcf
predict wi_reduce_all
lab var wi_reduce_all "Indeks kekayaan (tereduksi, umum)"

/*
******************************************************************
Kota-desa													[done]
******************************************************************
*/

/*
------------------------------------------------------------------
Skor - Faktor PCA											[done]
------------------------------------------------------------------
*/

#delimit ;
glo indicator 
	electricity-bankac matfloor_* matroof_* matwall_* house land memsleep_iurbrur
	cowbull_* buffal_* horse_* goat_* pig_* chicken_*
	landarea_iurbrur floorarea_iurbrur
	;
#delimit cr

*\factor pc
factor $indicator if hv025 == 1, factors(1) pcf
predict wi_reduce_urb if hv025 == 1

factor $indicator if hv025 == 2, factors(1) pcf
predict wi_reduce_rur if hv025 == 2

gen wi_reduce_urbrur = wi_reduce_urb
	lab var wi_reduce_urbrur "Indeks kekayaan (tereduksi, kota/desa)"
	replace wi_reduce_urbrur = wi_reduce_rur if hv025 == 2

drop wi_reduce_urb wi_reduce_rur

*\ringkasan
summ wi_reduce_urbrur
histogram wi_reduce_urbrur, density normal
graph export ".\output\hist_wi_reduce_urbrur.png", replace
sepscatter hv271 wi_reduce_urbrur, separate(hv025)
graph export ".\output\scat_wi_reduce_urbrur.png", replace

/*
******************************************************************
Komposit/Kombinasi											[done]
******************************************************************
*/

/*
------------------------------------------------------------------
Regress														[done]
------------------------------------------------------------------
*/

*\kota
regress wi_reduce_all wi_reduce_urbrur if hv025 == 1
predict wi_1

*\desa
regress wi_reduce_all wi_reduce_urbrur if hv025 == 2
predict wi_2

*\skor
gen wi_reduce_combine = .
	lab var wi_reduce_combine "Indeks kekayaan (tereduksi, kombinasi)"
	replace wi_reduce_combine = wi_1 if hv025 == 1
	replace wi_reduce_combine = wi_2 if hv025 == 2

drop wi_1 wi_2

*\ringkasan
summ wi_reduce_combine
histogram wi_reduce_combine, density normal
graph export ".\output\hist_wi_reduce_combine.png", replace
sepscatter hv271a wi_reduce_combine, separate(hv025)
graph export ".\output\scat_wi_reduce_combine.png", replace

/*
******************************************************************
Kuintil indeks 												[done]
******************************************************************
*/

*\kota/desa
xtile wiq_reduce_urb = wi_reduce_urbrur if hv025 == 1 [pw = hmweight], nq(5)
xtile wiq_reduce_rur = wi_reduce_urbrur if hv025 == 2 [pw = hmweight], nq(5)
gen wiq_reduce_urbrur = .
	lab var wiq_reduce_urbrur "Kuintil indeks kekayaan (tereduksi, kota-desa)"
	replace wiq_reduce_urbrur = wiq_reduce_urb if hv025 == 1
	replace wiq_reduce_urbrur = wiq_reduce_rur if hv025 == 2
drop wiq_reduce_urb wiq_reduce_rur

tab hv270a wiq_reduce_urbrur

*\kombinasi
xtile wiq_reduce_combine = wi_reduce_combine [pw = hmweight], nq(5)
	lab var wiq_reduce_combine "Kuintil indeks kekayaan (tereduksi, kombinasi)"

tab hv270 wiq_reduce_combine

/*
******************************************************************
Desil indeks 												[done]
******************************************************************
*/

*\kota/desa
xtile wid_reduce_urb = wi_reduce_urbrur if hv025 == 1 [pw = hmweight], nq(10)
xtile wid_reduce_rur = wi_reduce_urbrur if hv025 == 2 [pw = hmweight], nq(10)
gen wid_reduce_urbrur = .
	lab var wid_reduce_urbrur "Desil indeks kekayaan (tereduksi, kota-desa)"
	replace wid_reduce_urbrur = wid_reduce_urb if hv025 == 1
	replace wid_reduce_urbrur = wid_reduce_rur if hv025 == 2
drop wid_reduce_urb wid_reduce_rur

tab wid_reduce_urbrur

*\kombinasi
xtile wid_reduce_combine = wi_reduce_combine [pw = hmweight], nq(10)
	lab var wid_reduce_combine "Desil indeks kekayaan (tereduksi, kombinasi)"

tab wid_reduce_combine



/*
================================================================================
FINALISASI
================================================================================
*/

keep hhid v001 v002 hv024 hv025 hhweight hmweight house land 	///
	 drinkwat_11-chicken_3 memsleep_* floorarea_* landarea_* 	///
	 wi_* wiq_* wid_*
order hhid v001 v002 hv024 hv025 hhweight hmweight house land   ///
	 drinkwat_11-chicken_3 memsleep_* floorarea_* landarea_* 	///
	 wi_* wiq_* wid_*
sort v001 v002

quietly compress
datasignature set, reset
lab data "Perhitungan indeks kekayaan \ `time_date'"
note: `idhs'-mortstudy-wealth.dta \ `tag'
save `savenm', replace


*close log-file
log close _all