log close _all
clear all
macro drop _all
cls
*dir & log file
cd 				"D:\RESEARCH & WRITING\master thesis_child mortality\stata\"
loc idhs 		"idhs17"
loc dfn 		"log_10_modeling_`idhs'"
log using 		"log\10_modeling_`idhs'", name(`dfn') text replace




/*
================================================================================
********************************************************************************
PROJECT:
PENELITIAN TESIS
DEPRIVASI LINGKUNGAN RUMAH TANGGA DAN KEMATIAN BAYI DAN ANAK DI INDONESIA

SYNTAX:
10-LOGISTIK MULTILEVEL HAZARD DISKRIT-KEMATIAN BAYI

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

*baca data
loc dta			"dta\8-data-model-`idhs'.dta"
use `dta'



/*
================================================================================
A. NNDEATH													
================================================================================
*/

collect clear

#delimit ;

// Model 1 - baseline hazard;
collect, tag(model[A. Neonatal] nmodel[Model 1]):
 melogit nndeath i.interval
	     if data == 1 || psu:, or;
estat icc;

// Model 2 - tanpa kontrol;
collect, tag(model[A. Neonatal] nmodel[Model 2]):
 melogit nndeath i.interval deprivs
		 if data == 1 || psu:, or;
estat icc;

// Model 3 - kontrol: sosek;
collect, tag(model[A. Neonatal] nmodel[Model 3]):
 melogit nndeath i.interval deprivs
		 b3.pareduc b2.wealth b1.reside pwdisthfac
		 if data == 1 || psu:, or;
estat icc;

// Model 4 - kontrol: full;
collect, tag(model[A. Neonatal] nmodel[Model 4]):
 melogit nndeath i.interval deprivs
		 b3.pareduc b2.wealth b1.reside pwdisthfac
		 i.chsex b1.bordin b1.mageb
		 if data == 1 || psu:, or;
		 
estimate store mdl_a4;
estat icc;

// Model 5 - interaksi periode umur;
collect, tag(model[A. Neonatal] nmodel[Model 5]):
 melogit nndeath i.interval i.interval#c.deprivs
		 b3.pareduc b2.wealth b1.reside pwdisthfac
		 i.chsex b1.bordin b1.mageb
		 if data == 1 || psu:, or;
estimate store mdl_a5;
estat icc;

// /likelihood ratio test model a5 vs model a4;
lrtest mdl_a4 mdl_a5;

#delimit cr



/*
================================================================================
B. IDEATH													
================================================================================
*/

#delimit ;

// Model 1 - baseline hazard;
collect, tag(model[B. Bayi] nmodel[Model 1]):
 melogit ideath i.interval
	     if data == 2 || psu:, or;
estat icc;

// Model 2 - tanpa kontrol;
collect, tag(model[B. Bayi] nmodel[Model 2]):
 melogit ideath i.interval deprivs
		 if data == 2 || psu:, or;
estat icc;

// Model 3 - kontrol: sosek;
collect, tag(model[B. Bayi] nmodel[Model 3]):
 melogit ideath i.interval deprivs
		 b3.pareduc b2.wealth b1.reside pwdisthfac
		 if data == 2 || psu:, or;
estat icc;

// Model 4 - kontrol: full;
collect, tag(model[B. Bayi] nmodel[Model 4]):
 melogit ideath i.interval deprivs
		 b3.pareduc b2.wealth b1.reside pwdisthfac
		 i.chsex b1.bordin b1.mageb
		 if data == 2 || psu:, or;
		 
estimate store mdl_b4;
estat icc;

// Model 5 - interaksi periode umur;
collect, tag(model[B. Bayi] nmodel[Model 5]):
 melogit ideath i.interval i.interval#c.deprivs 
		 b3.pareduc b2.wealth b1.reside pwdisthfac
		 i.chsex b1.bordin b1.mageb
		 if data == 2 || psu:, or;
estimate store mdl_b5;
estat icc;

// /likelihood ratio test model b4 vs model b5;
lrtest mdl_b4 mdl_b5;

#delimit cr



/*
================================================================================
C. U5DEATH													
================================================================================
*/

#delimit ;

// Model 1 - baseline hazard;
collect, tag(model[C. <5 Tahun] nmodel[Model 1]):
 melogit u5death i.interval
	     if data == 3 || psu:, or;
estat icc;

// Model 2 - tanpa kontrol;
collect, tag(model[C. <5 Tahun] nmodel[Model 2]):
 melogit u5death i.interval deprivs
		 if data == 3 || psu:, or;
estat icc;

// Model 3 - kontrol: sosek;
collect, tag(model[C. <5 Tahun] nmodel[Model 3]):
 melogit u5death i.interval deprivs
		 b3.pareduc b2.wealth b1.reside pwdisthfac
		 if data == 3 || psu:, or;
estat icc;

// Model 4 - kontrol: full;
collect, tag(model[C. <5 Tahun] nmodel[Model 4]):
 melogit u5death i.interval deprivs
		 b3.pareduc b2.wealth b1.reside pwdisthfac
		 i.chsex b1.bordin b1.mageb
		 if data == 3 || psu:, or;
		 
estimate store mdl_c4;
estat icc;

// Model 5 - interaksi periode umur;
collect, tag(model[C. <5 Tahun] nmodel[Model 5]):
 melogit u5death i.interval i.interval#c.deprivs
		 b3.pareduc b2.wealth b1.reside pwdisthfac
		 i.chsex b1.bordin b1.mageb
		 if data == 3 || psu:, or;
estimate store mdl_c5;
estat icc;

// /likelihood ratio test model c4 vs model c5;
lrtest mdl_c4 mdl_c5;

#delimit cr



/*
================================================================================
TABEL (REPORT)													
================================================================================
*/

/*
------------------------------------------------------------------
SE
------------------------------------------------------------------
*/

*samping
#delimit;
quietly collect layout (colname[_cons interval deprivs interval#deprivs
 chsex bordin mageb pareduc wealth reside pwdisthfac var(_cons[psu])])
 (nmodel#result[_r_b _r_se]) (model);
#delimit cr
collect style cell result[_r_b], nformat(%6,3fc)
collect style cell result[_r_se], nformat(%6,3fc) sformat("(%s)")
collect stars _r_p "0.001" "***" "0.01" "** " "0.05" "*  " "1" "   ", attach(_r_b)
collect style column, dups(center)
collect style header result, level(label)
collect style row stack, nobinder delimiter(" x ")
collect style cell border_block, border(right, pattern(nil))
collect label levels result ///
	_r_b "OR" ///
	_r_se "SE" ///
	, modify
collect label values colname ///
	 _cons "Intersep" ///
	 , modify
collect preview
collect export ".\output\model-deprivs.xls", as(xls) sheet(SE) replace

/*
------------------------------------------------------------------
95% CI
------------------------------------------------------------------
*/

*samping
#delimit;
quietly collect layout (colname[_cons interval deprivs interval#deprivs
 chsex bordin mageb pareduc wealth reside pwdisthfac var(_cons[psu])])
 (nmodel#result[_r_b _r_ci]) (model);
#delimit cr
collect style cell result[_r_b], nformat(%6,3fc)
collect style cell result[_r_ci], nformat(%6,3fc) sformat("(%s)") cidelimiter("-")
collect stars _r_p "0.001" "***" "0.01" "** " "0.05" "*  " "1" "   ", attach(_r_b)
collect style column, dups(center)
collect style header result, level(label)
collect style row stack, nobinder delimiter(" x ")
collect style cell border_block, border(right, pattern(nil))
collect label levels result ///
	_r_b "OR" ///
	, modify
collect label values colname ///
	 _cons "Intersep" ///
	 , modify
collect preview
collect export ".\output\model-deprivs.xls", as(xls) sheet(CI) modify

*stat
quietly collect layout (result[chi2 p chi2_c p_c N N_g]) (nmodel) (model)
collect style cell result[chi2 chi2_c], nformat(%6,3fc)
collect style cell result[N N_g], nformat(%9,0fc)
collect style column, dups(center)
collect style header result, level(label)
collect style cell border_block, border(right, pattern(nil))
collect label levels result ///
 chi2 "Chi2 (simultan)" ///
 p "p-val" ///
 chi2_c "Chi2 vs (fix)" ///
 p_c "p-val" ///
 N "Jumlah Observasi" ///
 N_g "Jumlah Komunitas" ///
 , modify
collect preview
collect export ".\output\model-deprivs.xls", as(xls) sheet(STAT) modify


*close log-file
log close _all
