/*
================================================================================
********************************************************************************
PROJECT:
PENELITIAN TESIS
DEPRIVASI LINGKUNGAN RUMAH TANGGA DAN KEMATIAN BAYI DAN ANAK DI INDONESIA

SYNTAX:
5-MEMBENTUK VARIABEL TINGKAT KOMUNITAS

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
loc dfn 		"log_5_vars_community_`idhs'"
log using 		"`logdir'\5_vars_community_`idhs'", name(`dfn') text replace

*set the date
loc date = c(current_date)
loc time = c(current_time)
loc time_date = "`date'" + "_" + "`time'"
loc tag "`dfn'.do Ari Prasojo `time_date'"

*direktori dataset
*\dataset rumah tangga
loc hhdata		"`dtadir'\2-vars-household-`idhs'.dta"

*\dataset individu perempuan
loc irdata		"`dtadir'\3-vars-women-`idhs'.dta"

*\dataset disimpan sebagai (nama)
loc savenm		"`dtadir'\5-vars-community-`idhs'.dta"



/*
================================================================================
RUMAH TANGGA
================================================================================
*/

use "`hhdata'"

/*
******************************************************************
Variabel-variabel											[done]
******************************************************************
 */

*\denominator (banyaknya ruta)
bysort psu: gen nhh = _N
lab var nhh "Banyaknya rumah tangga"

*\% rumah tangga yang memiliki sumber air minum layak
bysort psu: egen nimpdrinkwathh = sum(impdrinkwat)
	gen phhimpdrinkwat = nimpdrinkwathh/nhh
	lab var phhimpdrinkwat "% Rumah tangga dengan sumber air minum layak di komunitas"

*\% rumah tangga yang memiliki sanitasi layak
bysort psu: egen nimpsanhh = sum(impsan)
	gen phhimpsan = nimpsanhh/nhh
	lab var phhimpsan "% Rumah tangga dengan sanitasi layak di komunitas"

*\% rumah tangga yang memiliki bahan bakar memasak aman/polusi rendah
bysort psu: egen nimpcookflhh = sum(cookfldr)
	gen phhimpcookfl = nimpcookflhh/nhh
	lab var phhimpcookfl "% Rumah tangga dengan bahan bakar memasak aman di komunitas"

*\% rumah tangga yang terdeprivasi lingkungan
bysort psu: egen ndephh = sum(depriv)
	gen phhdep = ndephh/nhh
	lab var phhdep "% Rumah tangga yang mengalami deprivasi lingkungan di komunitas"


/*
******************************************************************
Simpan 														[done]
******************************************************************
*/

keep psu-reside phhimpdrinkwat phhimpsan phhimpcookfl ndephh
duplicates drop psu, force
summ(phhimpdrinkwat phhimpsan phhimpcookfl ndephh)

quietly compress
datasignature set, reset
lab data "Variabel komunitas ruta\ `time_date'"
note: `idhs'-mortstudy-comm-hh.dta \ `tag'
save "comm-hh.dta", replace



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

*\denominator (banyaknya perempuan)
gen psu = v001
bysort psu: gen nw = _N

*\% perempuan berpendidikan menengah ke atas
bysort psu: egen neduc2 = sum(meduc2cs)
	gen pweduc2 = neduc2/nw
	lab var pweduc2 "% Perempuan berpendidikan menengah ke atas di komunitas"

*\rata-rata lama sekolah perempuan
*-v133 rata-rata lama sekolah perempuan
bysort psu: egen mweducy = mean(meducy)
	lab var mweducy "Rata-rata lama sekolah perempuan di komunitas"

*\% perempuan yang menganggap jarak ke fasilitas kesehatan sulit
bysort psu: egen nwdisthfac = sum(mdisthfac)
	gen pwdisthfac = nwdisthfac/nw
	lab var pwdisthfac "% Perempuan yang menyatakan bermasalah menjangkau jarak faskes"

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
	lab var pwdisthfac3c "Masalah aksesibilitas ke faskes"

/*
******************************************************************
Simpan	 													[done]
******************************************************************
*/

keep psu pweduc2 mweducy pwdisthfac qpwdisthfac pwdisthfac3c
duplicates drop psu, force
summ(pweduc2 mweducy pwdisthfac)

quietly compress
datasignature set, reset
lab data "Variabel komunitas perempuan\ `time_date'"
note: `idhs'-mortstudy-comm-wmn.dta \ `tag'
save "comm-wmn.dta", replace



/*
================================================================================
FINALISASI
================================================================================
*/

merge 1:1 psu using "comm-hh.dta", keep(match) keepus() nogen

erase "comm-hh.dta"
erase "comm-wmn.dta"

quietly compress
datasignature set, reset
lab data "Variabel komunitas \ `time_date'"
note: `idhs'-mortstudy-community.dta \ `tag'
save "`savenm'", replace