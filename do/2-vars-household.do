log close _all
clear all
macro drop _all
cls
*dir & log file
cd 				"D:\RESEARCH & WRITING\master thesis_child mortality\stata\"
loc idhs 		"idhs17"
loc dfn 		"log_2_vars_household_`idhs'"
log using 		"log\2_vars_household_`idhs'", name(`dfn') text replace

/*
================================================================================
********************************************************************************
PROJECT:
PENELITIAN TESIS
DEPRIVASI LINGKUNGAN RUMAH TANGGA DAN KEMATIAN BAYI DAN ANAK DI INDONESIA

SYNTAX:
2-MEMBENTUK VARIABEL DI TINGKAT RUMAH TANGGA

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

*set the date
loc date = c(current_date)
loc time = c(current_time)
loc time_date = "`date'" + "_" + "`time'"
loc tag "`dfn'.do Ari Prasojo `time_date'"

*direktori dataset
*\dataset rumah tangga
loc hrc 		"D:\PUSDATIN\DATA MIKRO\IDHS\2017\IDHR71DT\IDHR71FL.dta"

*\dataset indeks kekayaan
loc wealthdata	"dta\1-wealth-index-`idhs'.dta"

*\dataset disimpan sebagai (nama)
loc savenm		"dta\2-vars-household-`idhs'.dta"

*merge dengan dataset indeks kekayaan
*use v001 v002 hhweight hmweight wi_* wiq_* wid_* using "`wealthdata'"
use v001 v002 hhweight hmweight drinkwat_* toiletfac_* cookfuel_*		///
	wi_* wiq_* wid_* using "`wealthdata'"

rename v001 hv001
rename v002 hv002
merge 1:1 hv001 hv002 using "`hrc'"

*membuat label
lab def layaktidak 0 "Tidak layak" 1 "Layak" 		//layaktidak



/*
================================================================================
VARIABEL-VARIABEL DASAR
================================================================================
*/

*\PSU														[done]
gen psu = hv021
	lab var psu "Primary sampling unit (proksi komunitas)"

*\Geografi													[done]
*\\Provinsi
gen prov = hv024
	lab var prov "Provinsi"
	lab def prov 11 "Aceh" 12 "Sumatera Utara"							///
				 13 "Sumatera Barat" 14 "Riau"							///
				 15 "Jambi" 16 "Sumatera Selatan" 						///
				 17 "Bengkulu" 18 "Lampung" 							///
				 19 "Bangka Belitung" 21 "Kepulauan Riau"				///
				 31 "DKI Jakarta" 32 "Jawa Barat" 						///
				 33 "Jawa Tengah" 34 "DI Yogyakarta"					///
				 35 "Jawa Timur" 36 "Banten"							///
				 51 "Bali" 52 "Nusa Tenggara Barat" 					///
				 53 "Nusa Tenggara Timur" 61 "Kalimantan Barat"			///
				 62 "Kalimantan Tengah" 63 "Kalimantan Selatan" 		///
				 64 "Kalimantan Timur" 65 "Kalimantan Utara"    		///
				 71 "Sulawesi Utara" 72 "Sulawesi Tengah"				///
				 73 "Sulawesi Selatan" 74 "Sulawesi Tenggara"			///
				 75 "Gorontalo"	76 "Sulawesi Barat"						///
				 81 "Maluku" 82 "Maluku Utara"							///
				 91 "Papua Barat" 94 "Papua", replace
	lab val prov prov
	tab prov, m
	
*\\Region (7 kategori)
recode prov (31/36 = 1 "Jawa")											///
			(11/21 = 2 "Sumatera")										///
			(51/53 = 3 "Bali & Nusa Tenggara")							///
			(61/65 = 4 "Kalimantan")									///
			(71/76 = 5 "Sulawesi")										///
			(81 82 = 6 "Maluku")										///
			(91 94 = 7 "Papua"),										///
			gen(reg7c)
	lab var reg7c "Regional tempat tinggal"
	tab reg7c, m
	
*\\Wilayah tempat tinggal (kota/desa)
recode hv025 (2 = 0 "Perdesaan") (1 = 1 "Perkotaan"), gen(reside)
	lab var reside "Wilayah tempat tinggal"
	tab reside, m


	
/*
================================================================================
VARIABEL BEBAS UTAMA
================================================================================
*/

/*
******************************************************************
Sumber air													[done]
******************************************************************
*/

*\Sumber utama air minum (DHS standard recode)				[done]
clonevar drinkwat = hv201									
	lab var drinkwat "Sumber air minum utama di rumah tangga"
	lab def drinkwat 10 "Ledeng/keran"									 ///
					 11 "Ledeng sampai ke dalam rumah"					 ///
					 12 "Ledeng sampai ke halaman"						 ///
					 13 "Ledeng dari tetangga"							 ///
					 14 "Hidran/keran umum"								 ///
					 20 "Sumur bor"										 ///
					 21 "Sumur bor/pompa"								 ///
					 30 "Sumur"											 ///
					 31 "Sumur terlindung"								 ///
					 32 "Sumur tidak terlindung"						 ///
					 40 "Air permukaan"									 ///
					 41 "Mata air terlindung"							 ///
					 42 "Mata air tidak terlindung"						 ///
					 43 "Sungai/dam/danau/kolam/aliran/saluran/irigasi"	 ///
					 51 "Air hujan"										 ///
					 61 "Tangki truk"									 ///
					 62 "Gerobak dengan tangki kecil"					 ///
					 71 "Air kemasan"									 ///
					 72 "Air isi ulang"									 ///
					 96 "Lainnya", replace
	lab val drinkwat drinkwat
	tab drinkwat, m

*\Sumber utama air selain untuk minum						[done]
clonevar nondrinkwat = hv202
	lab var nondrinkwat "Sumber air utama selain untuk minum"
	lab val nondrinkwat drinkwat
	tab nondrinkwat, m

*\Kategori/status sumber utama air minum (layak/tidak layak)[done]
/*
https://dhsprogram.com/Data/Guide-to-DHS-Statistics/index.htm#t=Household_Drinking_Water.htm
berdasarkan WHO-UNICEF JMP 2017 dan Guide to DHS statistics VII
*/

*\\3 kategori
recode nondrinkwat (32 42 43 96 71 72 = 0 "Tidak layak")				///
				   (11/14 21 31 41 51 61 62 = 1 "Layak"),				///
				   gen(impnondrinkwat)
	lab var impnondrinkwat "Kategori sumber air selain untuk minum"
	tab impnondrinkwat, m
	
gen drinkwatldr = .
	replace drinkwatldr = 0 if drinkwat == 43
	replace drinkwatldr = 1 if inlist(drinkwat,32,42,96)
	replace drinkwatldr = 2 if inlist(drinkwat,11,12,13,14,21,31,41,51,61,62)
	replace drinkwatldr = 1 if inlist(drinkwat,71,72)
	replace drinkwatldr = 2 if inlist(drinkwat,71,72) & impnondrinkwat==1
	lab var drinkwatldr "Level/kategori sumber utama air minum"
	lab def drinkwatldr 0 "Air permukaan"								///
						1 "Tidak layak"									///
						2 "Layak", replace
	lab val drinkwatldr drinkwatldr
	tab drinkwatldr, m

*\\2 kategori (layak/tidak layak)
recode drinkwatldr (0 1 = 0 "Tidak layak")								///
				   (2 = 1 "Layak"),										///
				   gen(impdrinkwat)	
	lab var impdrinkwat "Kategori sumber utama air minum"
	tab impdrinkwat, m

*\\Kategori (layak/tidak layak), DHS report					[done]
gen impdrinkwatdhs = .
	replace impdrinkwatdhs = 0 if inlist(drinkwat,32,42,43,61,62,96)
	replace impdrinkwatdhs = 1 if inlist(drinkwat,11,12,13,14,21,31,41,51)
	replace impdrinkwatdhs = 0 if inlist(drinkwat,71,72)
	replace impdrinkwatdhs = 1 if inlist(drinkwat,71,72) & impnondrinkwat==1
	lab var impdrinkwatdhs "Kategori sumber utama air minum (DHS report)"
	lab val impdrinkwatdhs layaktidak
	tab impdrinkwatdhs, m

/*
******************************************************************
Sanitasi/Toilet												[done]
******************************************************************
*/

*\Jenis toilet (DHS standard recode)						[done]
clonevar toiletfac = hv205
	lab var toiletfac "Jenis toilet yang biasa digunakan art"
	lab def toiletfac 10 "Toilet siram (flush)"							///
					  11 "Toilet siram dengan saluran pembuangan pipa"	///
					  12 "Toilet siram siram dengan tangki septik"		///
					  13 "Toilet siram dengan jamban lubang"			///
					  14 "Toilet siram dengan saluran pembuangan terbuka/tempat lain" ///
					  15 "Toilet siram siram, pembuangan tidak diketahui"	///
					  16 "Toilet siram, tanpa tangki septik"			///
					  17 "Toilet bersama/umum"							///
					  20 "Jamban lubang"								///
					  21 "Jamban lubang dengan ventilasi"				///
					  22 "Jamban lubang dengan tutup/slab"				///
					  23 "Jamban lubang tanpa tutup/slab"				///
					  30 "Tidak ada fasilitas toilet"					///
					  31 "Tidak memiliki/semak/ladang/sungai/pantai/kolam"	///
					  41 "Toilet kompos"								///
					  42 "Toilet ember"									///
					  43 "Toilet/jamban gantung"						///
					  96 "Lainnya", replace
	lab val toiletfac toiletfac
	tab toiletfac, m

*\Kategori/status jenis toilet/sanitasi (layak/tidak layak)	[done]
/*
https://dhsprogram.com/data/Guide-to-DHS-Statistics/index.htm#t=Type_of_Sanitation_Facility.htm
berdasarkan WHO-UNICEF JMP 2017
 */

*\\3 tingkatan/kategori
recode toiletfac (31 = 0 "Tempat terbuka/sembarang")					///
				 (14 17 23 42 43 96 = 1 "Tidak layak")					///
				 (11/13 15 16 21 22 41 = 2 "Layak"),					///
				 gen(sanldr)
	lab var sanldr "Level/kategori fasilitas toilet/sanitasi"
	tab sanldr, m

*\\2 kategori (layak/ tidak layak)
recode sanldr (0/1 = 0 "Tidak layak")									///
			  (2 = 1 "Layak"),											///
			  gen(impsan)
	lab var impsan "Kategori fasilitas toilet/sanitasi"
	tab impsan, m
	
*\\Kategori, DHS report										[done]
gen sanldrdhs = .
	replace sanldrdhs = 0 if sh109 == 51
	replace sanldrdhs = 1 if inlist(sh109,31,32,33,41,96)
	replace sanldrdhs = 2 if sh109 == 21
	replace sanldrdhs = 3 if inlist(sh109,11,12)
	lab var sanldrdhs "Level/kategori fasilitas toilet/sanitasi (DHS report)"
	lab def sanldrdhs 0 "Tanpa fasilitas" 1 "Tidak layak"				///
					  2 "Bersama/publik" 3 "Layak", replace
	lab val sanldrdhs sanldrdhs
	tab sanldrdhs, m

recode sanldrdhs (0/2 = 0 "Tidak layak") (3 = 1 "Layak"), gen(impsandhs)
	lab var impsandhs "Kategori fasilitas toilet/sanitasi (DHS report)"
	tab impsandhs, m

/*
******************************************************************
Bahan bakar memasak											[done]
******************************************************************
*/

*\Jenis bahan bakar memasak (DHS standard recode)			[done]
clonevar cookfuel = hv226
	lab var cookfuel "Bahan bakar memasak"
	lab def cookfuel 1 "Listrik"										///
					 2 "LPG"											///
					 3 "Gas alam" 										///
					 4 "Biogas"											///
					 5 "Minyak tanah" 									///
					 6 "Batubara, lignit"								///
					 7 "Arang"											///
					 8 "Kayu"											///
					 9 "Jerami/semak/rumput"							///
					 10 "Tanaman pertanian"								///
					 11 "Kotoran hewan"									///
					 95 "Tidak ada makanan yang dimasak di rumah"		///
					 96 "Lainnya", replace
	lab val cookfuel cookfuel
	tab cookfuel,m
					 
*\Kategori bahan bakar memasak (aman/tidak aman)			[done]
/*
https://dhsprogram.com/data/Guide-to-DHS-Statistics/Cooking_Fuel.htm
https://www.who.int/news-room/fact-sheets/detail/household-air-pollution-and-health
 */
 
*\\Kategori yang digunakan
recode cookfuel (1/4 95 = 1 "Aman/polusi rendah") (. = .)				///
				(else = 0 "Tidak aman/polusi tinggi"), gen(cookfldr)
	lab var cookfldr "Kategori bahan bakar memasak"
	tab cookfldr, m

*\\Kategori, DHS report										[done]
recode cookfuel (1/4 = 0 "Bersih")										///
				(5 = 1 "Minyak tanah")									///
				(6/11 = 2 "Padat")										///
				(95 = 3 "Tidak memasak")								///
				(96 = 4 "Lainnya"),										///
				gen(cookfldrdhs)
	lab var cookfldrdhs "Bahan bakar memasak"
	tab cookfldrdhs, m

recode cookfldrdhs (0 3 = 1 "Bersih/tidak memasak")						///
				   (1 2 4 = 0 "Padat/minyak tanah/lainnya"),			///
				   gen(impcookfldhs)
	lab var impcookfldhs "Bahan bakar memasak (DHS report)"
	tab impcookfldhs, m

/*
******************************************************************
Gabungan/deprivasi lingkungan rumah tangga					[done]
******************************************************************
*/

*\Banyaknya fasilitas lingkungan yang layak					[done]

*\\4 kategori (0,1,2,3)
gen nenvfac = impdrinkwat + impsan + cookfldr
	lab var nenvfac "Banyaknya fasilitas (sumber air, sanitasi, bahan bakar) layak"
	tab nenvfac, m

*\\3 kategori (0-1,2,3)
recode nenvfac (0 1 = 1), gen(nenvfac1)
	lab var nenvfac1 "Banyaknya fasilitas (sumber air, sanitasi, bahan bakar) layak"
	lab def nenvfac1 1 "0-1" 2 "2" 3 "3", replace
	lab val nenvfac1 nenvfac1
	tab nenvfac1, m

*\\Banyaknya fasilitas lingkungan yang layak, DHS			[done]
gen nenvfacdhs = impdrinkwatdhs + impsandhs + impcookfldhs
	lab var nenvfac "Banyaknya fasilitas (sumber air, sanitasi, bahan bakar) layak"
	tab nenvfacdhs, m

*\Deprivasi lingkungan rumah tangga							[done]

*\\2 kategori (tidak/ya)
recode nenvfac (3 = 0 "Tidak") (0/2 = 1 "Ya"), gen(depriv2c)
	lab var depriv "Status deprivasi lingkungan rumah tangga"
	tab depriv2c, m
	
*\\3 kategori (tidak,rendah,tinggi)
recode nenvfac (3 = 0 "Tidak") (2 = 1 "Rendah") (0/1 = 2 "Tinggi"), gen(depriv)
	lab var depriv "Tingkat deprivasi lingkungan rumah tangga (kategorik)"
	tab depriv, m
	
*\\skor 0-3 (tidak-tinggi)
recode nenvfac (0 = 3) (1 = 2) (2 = 1) (3 = 0), gen(deprivs)
	lab var deprivs "Tingkat deprivasi lingkungan rumah tangga"

/*
*\\Kontinyu dengan pca

*\\\pca
pca impdrinkwat impsan cookfldr
*screeplot, yline(1) ci(het)
predict depc1 depc2, score
matrix eig = e(Ev)
scalar eig1p = eig[1,1]
scalar eig2p = eig[1,2]
scalar w1p = eig1p/(eig1p+eig2p)
scalar w2p = eig2p/(eig1p+eig2p)
gen deprivpc = w1p*depc1 + w2p*depc2
*histogram deprivpc, density normal

*\\\polychoric pca
polychoricpca impdrinkwat impsan cookfldr, score(deppcpol) nscore(2)
scalar eig1 = r(lambda1)
scalar eig2 = r(lambda2)
scalar w1 = eig1/(eig1+eig2)
scalar w2 = eig2/(eig1+eig2)
gen deprivpcpol = w1*deppcpol1 + w2*deppcpol2
*histogram deprivpcpol, density normal

*\\\pca fasilitas
glo depindic "drinkwat_* toiletfac_* cookfuel_*"
pca $depindic
predict deprivc, score
*histogram deprivc, density normal
 */

	
	
/*
******************************************************************
Status ekonomi/kekayaan/wealth								[done]
******************************************************************
*/

*\indeks kekayaan, tereduksi								[done]
/*
tanpa komponen air,sanitasi,bahan bakar
*/

*\\gabungan
recode wiq_reduce_combine (1/2 = 0 "Miskin")							///
						  (3/4 = 1 "Menengah")							///
						  (5 = 2 "Kaya"),								///
						  gen(wealth)
	lab var wealth "Indeks kekayaan rumah tangga"
	tab wealth, m

/*
*\\kota-desa
recode wiq_reduce_urbrur  (1/2 = 0 "Miskin")							///
						  (3/4 = 1 "Menengah")							///
						  (5 = 2 "Kaya"),								///
						  gen(wealth1)
	lab var wealth1 "Indeks kekayaan rumah tangga (kota-desa)"
	tab wealth1, m
*/



/*
================================================================================
FINALISASI
================================================================================
*/

rename hv001 v001
rename hv002 v002
keep hhid v001 v002 hhweight hmweight psu-reside						///
	 wi_* wiq_* wid_* drinkwat-wealth
order hhid v001 v002 psu-reside hhweight hmweight						///
	 wi_* wiq_* wid_* drinkwat-wealth
	 
quietly compress
datasignature set, reset
lab data "Variabel level rumah tangga \ `time_date'"
note: `idhs'-mortstudy-hh.dta \ `tag'
save "`savenm'", replace


*close log-file
log close _all