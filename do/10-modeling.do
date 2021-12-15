log close _all
cls
*dir & log file
cd 				"D:\RESEARCH & WRITING\master thesis_child mortality\stata\"
loc logdir		"log"
loc idhs 		"idhs17"
loc dfn 		"log_10_modeling_`idhs'"
log using 		"`logdir'\10_modeling_`idhs'", name(`dfn') text replace

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

clear all
macro drop _all
set maxvar 10000

*direktori kerja
loc dtadir		"dta"
*loc outdir		"output"

*baca data
loc dta			"`dtadir'\8-data-model-`idhs'.dta"
use `dta'

/*
================================================================================
A. NNDEATH													
================================================================================
*/

collect clear

/*
******************************************************************
ESTIMASI													[done]
******************************************************************
*/

*\Model 1 - baseline hazard
#delimit ;
collect: melogit nndeath i.interval
	     if data == 1 || psu:, or
 ;
#delimit cr
estat icc

*\Model 2 - tanpa kontrol
#delimit ;
collect: melogit nndeath i.interval i.depriv
		 if data == 1 || psu:, or
 ;
#delimit cr
estat icc

*\Model 3 - kontrol: sosek
#delimit ;
collect: melogit nndeath i.interval i.depriv
		 b3.pareduc b2.wealth b1.reside pwdisthfac
		 if data == 1 || psu:, or
 ;
#delimit cr
estat icc

*\Model 4 - kontrol: full
#delimit ;
collect: melogit nndeath i.interval i.depriv i.chsex b1.bordin b1.mageb
		 b3.pareduc b2.wealth b1.reside pwdisthfac
		 if data == 1 || psu:, or
 ;
#delimit cr
estimate store mdl_a4
estat icc

*\Model 5 - interaksi periode umur
#delimit ;
collect: melogit nndeath i.interval i.interval#i.depriv i.chsex b1.bordin 
		 b1.mageb b3.pareduc b2.wealth b1.reside pwdisthfac
		 if data == 1 || psu:, or
 ;
#delimit cr
estimate store mdl_a5
estat icc

*\\likelihood ratio test model a5 vs model a4
lrtest mdl_a4 mdl_a5

/*
******************************************************************
SAVE														[done]
******************************************************************
*/

/*
------------------------------------------------------------------
SE
------------------------------------------------------------------
*/

*samping
collect style autolevels result _r_b _r_se, clear
quietly collect layout (colname) (cmdset#result[_r_b stars _r_se])
collect style _cons first
collect style cell result[_r_b], nformat(%6,3fc)
collect style cell result[_r_se], nformat(%6,3fc) sformat("(%s)")
collect stars _r_p "0.001" "***" "0.01" "**" "0.05" "*"
collect style column, dups(center)
collect style header result, level(hide)
collect style row stack, nobinder delimiter(" x ")
collect style cell, font( Times New Roman, size(8) )
collect style cell border_block, border(right, pattern(nil))
collect preview
collect export ".\output\model.xls", as(xls) sheet(nndeath_side_se) replace

*bawah
collect style autolevels result _r_b _r_se, clear
quietly collect layout (colname#result result[chi2 chi2_c N N_g]) (cmdset)
collect style _cons first
collect style header result[N chi2 chi2_c N_g], level(label)
collect label levels result N "Jumlah Observasi" chi2 "Chi2-simultan"		///
		chi2_c "Chi2 vs fix" N_g "Jumlah Komunitas", modify
collect style cell result[_r_b chi2 chi2_c], nformat(%6,3fc)
collect style cell result[_r_se], nformat(%6,3fc) sformat("(%s)")
collect style cell result[N N_g], nformat(%9,0fc)
collect stars _r_p "0.001" "***" "0.01" "**" "0.05" "*", attach(_r_b)
collect style column, dups(center)
collect style row stack, nobinder delimiter(" x ")
collect style header result, level(hide)
collect style cell, font( Times New Roman, size(8) )
collect style cell border_block, border(right, pattern(nil))
collect preview
collect export ".\output\model.xls", as(xls) sheet(nndeath_down_se, replace) modify

/*
------------------------------------------------------------------
95% CI
------------------------------------------------------------------
*/

*samping
collect style autolevels result _r_b _r_ci, clear
quietly collect layout (colname) (cmdset#result[_r_b stars _r_ci])
collect style _cons first
collect style cell result[_r_b], nformat(%6,2fc)
collect style cell result[_r_ci], nformat(%6,2fc) sformat("(%s)") cidelimiter("-")
collect stars _r_p "0.001" "***" "0.01" "**" "0.05" "*"
collect style column, dups(center)
collect style header result, level(hide)
collect style row stack, nobinder delimiter(" x ")
collect style cell, font( Times New Roman, size(8) )
collect style cell border_block, border(right, pattern(nil))
collect preview
collect export ".\output\model.xls", as(xls) sheet(nndeath_side_ci) modify

*bawah
collect style autolevels result _r_b _r_ci, clear
quietly collect layout (colname#result result[chi2 chi2_c N N_g]) (cmdset)
collect style _cons first
collect style header result[N chi2 chi2_c N_g], level(label)
collect label levels result N "Jumlah Observasi" chi2 "Chi2-simultan"		///
		chi2_c "Chi2 vs fix" N_g "Jumlah Komunitas", modify
collect style cell result[_r_b chi2 chi2_c], nformat(%6,2fc)
collect style cell result[_r_ci], nformat(%6,2fc) sformat("(%s)") cidelimiter("-")
collect style cell result[N N_g], nformat(%9,0fc)
collect stars _r_p "0.001" "***" "0.01" "**" "0.05" "*", attach(_r_b)
collect style column, dups(center)
collect style row stack, nobinder delimiter(" x ")
collect style header result, level(hide)
collect style cell, font( Times New Roman, size(8) )
collect style cell border_block, border(right, pattern(nil))
collect preview
collect export ".\output\model.xls", as(xls) sheet(nndeath_down_ci, replace) modify


/*
================================================================================
B. IDEATH													
================================================================================
*/

collect clear

/*
******************************************************************
ESTIMASI													[done]
******************************************************************
*/

*\Model 1 - baseline hazard
#delimit ;
collect: melogit ideath i.interval
		 if data == 2 || psu:, or
 ;
#delimit cr
estat icc

*\Model 2 - tanpa kontrol
#delimit ;
collect: melogit ideath i.interval i.depriv
		 if data == 2 || psu:, or
 ;
#delimit cr
estat icc

*\Model 3 - kontrol: sosek
#delimit ;
collect: melogit ideath i.interval i.depriv
		 b3.pareduc b2.wealth b1.reside pwdisthfac
		 if data == 2 || psu:, or
 ;
#delimit cr
estat icc

*\Model 4 - kontrol: full
#delimit ;
collect: melogit ideath i.interval i.depriv i.chsex b1.bordin b1.mageb
		 b3.pareduc b2.wealth b1.reside pwdisthfac
		 if data == 2 || psu:, or
 ;
#delimit cr
estimate store mdl_b4
estat icc

*\Model 5 - interaksi periode umur
#delimit ;
collect: melogit ideath i.interval i.interval#i.depriv i.chsex b1.bordin 
		 b1.mageb b3.pareduc b2.wealth b1.reside pwdisthfac
		 if data == 2 || psu:, or
 ;
#delimit cr
estimate store mdl_b5
estat icc

*\\likelihood ratio test model a5 vs model a4
lrtest mdl_b4 mdl_b5

/*
******************************************************************
SAVE														[done]
******************************************************************
*/

/*
------------------------------------------------------------------
SE
------------------------------------------------------------------
*/

*samping
collect style autolevels result _r_b _r_se, clear
quietly collect layout (colname) (cmdset#result[_r_b stars _r_se])
collect style _cons first
collect style cell result[_r_b], nformat(%6,3fc)
collect style cell result[_r_se], nformat(%6,3fc) sformat("(%s)")
collect stars _r_p "0.001" "***" "0.01" "**" "0.05" "*"
collect style column, dups(center)
collect style header result, level(hide)
collect style row stack, nobinder delimiter(" x ")
collect style cell, font( Times New Roman, size(8) )
collect style cell border_block, border(right, pattern(nil))
collect preview
collect export ".\output\model.xls", as(xls) sheet(ideath_side_se) modify

*bawah
collect style autolevels result _r_b _r_se, clear
quietly collect layout (colname#result result[chi2 chi2_c N N_g]) (cmdset)
collect style _cons first
collect style header result[N chi2 chi2_c N_g], level(label)
collect label levels result N "Jumlah Observasi" chi2 "Chi2-simultan"		///
		chi2_c "Chi2 vs fix" N_g "Jumlah Komunitas", modify
collect style cell result[_r_b chi2 chi2_c], nformat(%6,3fc)
collect style cell result[_r_se], nformat(%6,3fc) sformat("(%s)")
collect style cell result[N N_g], nformat(%9,0fc)
collect stars _r_p "0.001" "***" "0.01" "**" "0.05" "*", attach(_r_b)
collect style column, dups(center)
collect style row stack, nobinder delimiter(" x ")
collect style header result, level(hide)
collect style cell, font( Times New Roman, size(8) )
collect style cell border_block, border(right, pattern(nil))
collect preview
collect export ".\output\model.xls", as(xls) sheet(ideath_down_se, replace) modify

/*
------------------------------------------------------------------
95% CI
------------------------------------------------------------------
*/

*samping
collect style autolevels result _r_b _r_ci, clear
quietly collect layout (colname) (cmdset#result[_r_b stars _r_ci])
collect style _cons first
collect style cell result[_r_b], nformat(%6,2fc)
collect style cell result[_r_ci], nformat(%6,2fc) sformat("(%s)") cidelimiter("-")
collect stars _r_p "0.001" "***" "0.01" "**" "0.05" "*"
collect style column, dups(center)
collect style header result, level(hide)
collect style row stack, nobinder delimiter(" x ")
collect style cell, font( Times New Roman, size(8) )
collect style cell border_block, border(right, pattern(nil))
collect preview
collect export ".\output\model.xls", as(xls) sheet(ideath_side_ci) modify

*bawah
collect style autolevels result _r_b _r_ci, clear
quietly collect layout (colname#result result[chi2 chi2_c N N_g]) (cmdset)
collect style _cons first
collect style header result[N chi2 chi2_c N_g], level(label)
collect label levels result N "Jumlah Observasi" chi2 "Chi2-simultan"		///
		chi2_c "Chi2 vs fix" N_g "Jumlah Komunitas", modify
collect style cell result[_r_b chi2 chi2_c], nformat(%6,2fc)
collect style cell result[_r_ci], nformat(%6,2fc) sformat("(%s)") cidelimiter("-")
collect style cell result[N N_g], nformat(%9,0fc)
collect stars _r_p "0.001" "***" "0.01" "**" "0.05" "*", attach(_r_b)
collect style column, dups(center)
collect style row stack, nobinder delimiter(" x ")
collect style header result, level(hide)
collect style cell, font( Times New Roman, size(8) )
collect style cell border_block, border(right, pattern(nil))
collect preview
collect export ".\output\model.xls", as(xls) sheet(ideath_down_ci, replace) modify



/*
================================================================================
C. U5DEATH													
================================================================================
*/

collect clear

/*
******************************************************************
ESTIMASI													[done]
******************************************************************
*/

*\Model 1 - baseline hazard
#delimit ;
collect: melogit u5death i.interval
		 if data == 3 || psu:, or
 ;
#delimit cr
estat icc

*\Model 2 - tanpa kontrol
#delimit ;
collect: melogit u5death i.interval i.depriv
		 if data == 3 || psu:, or
 ;
#delimit cr
estat icc

*\Model 3 - kontrol: sosek
#delimit ;
collect: melogit u5death i.interval i.depriv
		 b3.pareduc b2.wealth b1.reside pwdisthfac
		 if data == 3 || psu:, or
 ;
#delimit cr
estat icc

*\Model 4 - kontrol: full
#delimit ;
collect: melogit u5death i.interval i.depriv i.chsex b1.bordin b1.mageb
		 b3.pareduc b2.wealth b1.reside pwdisthfac
		 if data == 3 || psu:, or
 ;
#delimit cr
estimate store mdl_c4
estat icc

*\Model 5 - interaksi periode umur
#delimit ;
collect: melogit u5death i.interval i.interval#i.depriv i.chsex b1.bordin 
		 b1.mageb b3.pareduc b2.wealth b1.reside pwdisthfac
		 if data == 3 || psu:, or
 ;
#delimit cr
estimate store mdl_c5
estat icc

*\\likelihood ratio test model a5 vs model a4
lrtest mdl_c4 mdl_c5

/*
******************************************************************
SAVE														[done]
******************************************************************
*/

/*
------------------------------------------------------------------
SE
------------------------------------------------------------------
*/

*samping
collect style autolevels result _r_b _r_se, clear
quietly collect layout (colname) (cmdset#result[_r_b stars _r_se])
collect style _cons first
collect style cell result[_r_b], nformat(%6,3fc)
collect style cell result[_r_se], nformat(%6,3fc) sformat("(%s)")
collect stars _r_p "0.001" "***" "0.01" "**" "0.05" "*"
collect style column, dups(center)
collect style header result, level(hide)
collect style row stack, nobinder delimiter(" x ")
collect style cell, font( Times New Roman, size(8) )
collect style cell border_block, border(right, pattern(nil))
collect preview
collect export ".\output\model.xls", as(xls) sheet(u5death_side_se) modify

*bawah
collect style autolevels result _r_b _r_se, clear
quietly collect layout (colname#result result[chi2 chi2_c N N_g]) (cmdset)
collect style _cons first
collect style header result[N chi2 chi2_c N_g], level(label)
collect label levels result N "Jumlah Observasi" chi2 "Chi2-simultan"		///
		chi2_c "Chi2 vs fix" N_g "Jumlah Komunitas", modify
collect style cell result[_r_b chi2 chi2_c], nformat(%6,3fc)
collect style cell result[_r_se], nformat(%6,3fc) sformat("(%s)")
collect style cell result[N N_g], nformat(%9,0fc)
collect stars _r_p "0.001" "***" "0.01" "**" "0.05" "*", attach(_r_b)
collect style column, dups(center)
collect style row stack, nobinder delimiter(" x ")
collect style header result, level(hide)
collect style cell, font( Times New Roman, size(8) )
collect style cell border_block, border(right, pattern(nil))
collect preview
collect export ".\output\model.xls", as(xls) sheet(u5death_down_se, replace) modify

/*
------------------------------------------------------------------
95% CI
------------------------------------------------------------------
*/

*samping
collect style autolevels result _r_b _r_ci, clear
quietly collect layout (colname) (cmdset#result[_r_b stars _r_ci])
collect style _cons first
collect style cell result[_r_b], nformat(%6,2fc)
collect style cell result[_r_ci], nformat(%6,2fc) sformat("(%s)") cidelimiter("-")
collect stars _r_p "0.001" "***" "0.01" "**" "0.05" "*"
collect style column, dups(center)
collect style header result, level(hide)
collect style row stack, nobinder delimiter(" x ")
collect style cell, font( Times New Roman, size(8) )
collect style cell border_block, border(right, pattern(nil))
collect preview
collect export ".\output\model.xls", as(xls) sheet(u5death_side_ci) modify

*bawah
collect style autolevels result _r_b _r_ci, clear
quietly collect layout (colname#result result[chi2 chi2_c N N_g]) (cmdset)
collect style _cons first
collect style header result[N chi2 chi2_c N_g], level(label)
collect label levels result N "Jumlah Observasi" chi2 "Chi2-simultan"		///
		chi2_c "Chi2 vs fix" N_g "Jumlah Komunitas", modify
collect style cell result[_r_b chi2 chi2_c], nformat(%6,2fc)
collect style cell result[_r_ci], nformat(%6,2fc) sformat("(%s)") cidelimiter("-")
collect style cell result[N N_g], nformat(%9,0fc)
collect stars _r_p "0.001" "***" "0.01" "**" "0.05" "*", attach(_r_b)
collect style column, dups(center)
collect style row stack, nobinder delimiter(" x ")
collect style header result, level(hide)
collect style cell, font( Times New Roman, size(8) )
collect style cell border_block, border(right, pattern(nil))
collect preview
collect export ".\output\model.xls", as(xls) sheet(u5death_down_ci, replace) modify