log close _all
clear all
macro drop _all
cls
*dir & log file
cd 				"D:\RESEARCH & WRITING\master thesis_child mortality\stata\"
loc idhs 		"idhs17"
loc dfn 		"log_10_model_deprivc_`idhs'"
log using 		"log\10_model_deprivc_`idhs'", name(`dfn') text replace



/*
================================================================================
********************************************************************************
PROJECT:
PENELITIAN TESIS
HUBUNGAN ANTARA DEPRIVASI LINGKUNGAN RUMAH TANGGA DENGAN KEMATIAN BAYI DAN ANAK
DI INDONESIA: BUKTI DARI MODEL LOGISTIK MULTILEVEL HAZARD DISKRIT

SYNTAX:
10-LOGISTIK MULTILEVEL HAZARD DISKRIT

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

*baca data
loc dta			"dta\8-data-model-`idhs'.dta"
use `dta'

*Fungsi/perintah untuk menghitung signifikansi (p-value) efek random
*-Dipanggil setelah perintah melogit
*-Diadaptasi dari Rabe-Hesketh & Skrondal (2012)
program resignif
	display in smcl as text	///
		char(10) "P-value of random effect through ln transformation" char(10)
	
	*-simpan & hitung
	scalar sigmau2 = _b[/:var(_cons[psu])]
	scalar sesigmau2 = _se[/:var(_cons[psu])]
	scalar lnsigmau2 = ln(sigmau2)
	scalar selnsigmau2 = 1/sigmau2*sesigmau2
	scalar kl = lnsigmau2 + invnormal(0.025)*selnsigmau2
	scalar ku = lnsigmau2 + invnormal(0.975)*selnsigmau2
	scalar tau = 0.001
	scalar z = (lnsigmau2-ln(tau))/selnsigmau2
	scalar pval = 1-normal(z)
	
	*-menampilkan hasil
	display in smcl as text "ln(var(_cons[psu]))" char(9) char(9)	///
		"= " as result %9.7f lnsigmau2
	display in smcl as text "Std. err ln(var(_cons[psu]))" char(9)	///
		"= " as result %9.7f selnsigmau2
	display in smcl as text "95% CI ln(var(_cons[psu]))" char(9)	///
		"= [" as result %9.7f kl "; " ku "]"
	display in smcl as text "P-value H1: sigmau2 > tau" char(9)	///
		"= " as result %9.7f pval
	display in smcl as text "95% CI var(_cons[psu])" char(9) char(9) 	///
		"= [" as result %9.7f exp(kl) "; " exp(ku) "]"
	display in smcl as text "note: tau is assumed close to zero, " as result tau
end

*Fungsi untuk menghitung signifikansi (p-value) ICC
*-Dipanggil setelah perintah melogit
*-Diadaptasi dari stata manual "estat icc"
program iccsignif
	*-icc
	estat icc
	*-simpan & hitung
	scalar icc = r(icc2)
	scalar seicc = r(se2)
	scalar icclogit = ln(icc/(1-icc))
	scalar seicclogit = seicc/(icc*(1-icc))
	scalar kl = icclogit + invnormal(0.025)*seicclogit
	scalar ku = icclogit + invnormal(0.975)*seicclogit
	scalar tau = 0.001
	scalar pval = 2*(1-normal(abs(icclogit/seicclogit)))
	
	*-menampilkan hasil
	display in smcl as text "logit(ICC)" char(9) char(9)	///
		"= " as result %9.7f icclogit
	display in smcl as text "Std. err logit(ICC)" char(9)	///
		"= " as result %9.7f seicclogit
	display in smcl as text "95% CI logit(ICC)" char(9)		///
		"= [" as result %9.7f kl "; " ku "]"
	display in smcl as text "P-value H1: ICC > tau" char(9)	///
		"= " as result %9.7f pval
	display in smcl as text "95% CI ICC" char(9) char(9)		///
		"= [" as result %9.7f 1/(1+exp(-kl)) "; " 1/(1+exp(-ku)) "]"
	display in smcl as text "note: tau is assumed close to zero, " as result tau
end


/*
================================================================================
A. NNDEATH													
================================================================================
*/

collect clear

#delimit ;

// Model 1 - baseline hazard;
collect, tag(model[A. Neonatal] nmodel[Model 1]):
 melogit nndeath i.periods
	     if data == 1 || psu:, or;
resignif;
iccsignif;

// Model 2 - tanpa kontrol;
collect, tag(model[A. Neonatal] nmodel[Model 2]):
 melogit nndeath i.periods i.depriv
		 if data == 1 || psu:, or;
resignif;
iccsignif;

// Model 3 - kontrol: sosek;
collect, tag(model[A. Neonatal] nmodel[Model 3]):
 melogit nndeath i.periods i.depriv
		 b3.pareduc b2.wealth b1.reside pwdisthfac
		 if data == 1 || psu:, or;
resignif;
iccsignif;

// Model 4 - kontrol: full;
collect, tag(model[A. Neonatal] nmodel[Model 4]):
 melogit nndeath i.periods i.depriv
		 b3.pareduc b2.wealth b1.reside pwdisthfac
		 i.chsex b1.bordin b1.mageb
		 if data == 1 || psu:, or;
		 
estimate store mdl_a4;
resignif;
iccsignif;

// Model 5 - interaksi periode umur;
collect, tag(model[A. Neonatal] nmodel[Model 5]):
 melogit nndeath i.periods i.periods#i.depriv
		 b3.pareduc b2.wealth b1.reside pwdisthfac
		 i.chsex b1.bordin b1.mageb
		 if data == 1 || psu:, or;
estimate store mdl_a5;
resignif;
iccsignif;

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
 melogit ideath i.periods
	     if data == 2 || psu:, or;
resignif;
iccsignif;

// Model 2 - tanpa kontrol;
collect, tag(model[B. Bayi] nmodel[Model 2]):
 melogit ideath i.periods i.depriv
		 if data == 2 || psu:, or;
resignif;
iccsignif;

// Model 3 - kontrol: sosek;
collect, tag(model[B. Bayi] nmodel[Model 3]):
 melogit ideath i.periods i.depriv
		 b3.pareduc b2.wealth b1.reside pwdisthfac
		 if data == 2 || psu:, or;
resignif;
iccsignif;

// Model 4 - kontrol: full;
collect, tag(model[B. Bayi] nmodel[Model 4]):
 melogit ideath i.periods i.depriv
		 b3.pareduc b2.wealth b1.reside pwdisthfac
		 i.chsex b1.bordin b1.mageb
		 if data == 2 || psu:, or;
		 
estimate store mdl_b4;
resignif;
iccsignif;

// Model 5 - interaksi periode umur;
collect, tag(model[B. Bayi] nmodel[Model 5]):
 melogit ideath i.periods i.periods#i.depriv 
		 b3.pareduc b2.wealth b1.reside pwdisthfac
		 i.chsex b1.bordin b1.mageb
		 if data == 2 || psu:, or;
estimate store mdl_b5;
resignif;
iccsignif;

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
 melogit u5death i.periods
	     if data == 3 || psu:, or;
resignif;
iccsignif;

// Model 2 - tanpa kontrol;
collect, tag(model[C. <5 Tahun] nmodel[Model 2]):
 melogit u5death i.periods i.depriv
		 if data == 3 || psu:, or;
resignif;
iccsignif;

// Model 3 - kontrol: sosek;
collect, tag(model[C. <5 Tahun] nmodel[Model 3]):
 melogit u5death i.periods i.depriv
		 b3.pareduc b2.wealth b1.reside pwdisthfac
		 if data == 3 || psu:, or;
resignif;
iccsignif;

// Model 4 - kontrol: full;
collect, tag(model[C. <5 Tahun] nmodel[Model 4]):
 melogit u5death i.periods i.depriv
		 b3.pareduc b2.wealth b1.reside pwdisthfac
		 i.chsex b1.bordin b1.mageb
		 if data == 3 || psu:, or;
		 
estimate store mdl_c4;
resignif;
iccsignif;

// Model 5 - interaksi periode umur;
collect, tag(model[C. <5 Tahun] nmodel[Model 5]):
 melogit u5death i.periods i.periods#i.depriv
		 b3.pareduc b2.wealth b1.reside pwdisthfac
		 i.chsex b1.bordin b1.mageb
		 if data == 3 || psu:, or;
estimate store mdl_c5;
resignif;
iccsignif;

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
quietly collect layout (colname[_cons periods depriv periods#depriv
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
collect export ".\output\model-deprivc.xls", as(xls) sheet(SE) replace

/*
------------------------------------------------------------------
95% CI
------------------------------------------------------------------
*/

*samping
#delimit;
quietly collect layout (colname[_cons periods depriv periods#depriv
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
collect export ".\output\model-deprivc.xls", as(xls) sheet(CI) modify

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
 chi2_c "Chi2 (vs fix)" ///
 p_c "p-val" ///
 N "Jumlah observasi" ///
 N_g "Jumlah komunitas" ///
 , modify
collect preview
collect export ".\output\model-deprivc.xls", as(xls) sheet(STAT) modify


*close log-file
log close _all
