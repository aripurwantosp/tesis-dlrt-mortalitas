log close _all
clear all
macro drop _all
cls
*dir & log file
cd 				"D:\RESEARCH & WRITING\master thesis_child mortality\stata\"
loc idhs 		"idhs17"
loc dfn 		"log_7_descriptive_`idhs'"
log using 		"log\7_descriptive_`idhs'", name(`dfn') text replace

/*
================================================================================
********************************************************************************
PROJECT:
PENELITIAN TESIS
DEPRIVASI LINGKUNGAN RUMAH TANGGA DAN KEMATIAN BAYI DAN ANAK DI INDONESIA

SYNTAX:
7-ANALISIS DESKRIPTIF

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
use "dta\6-chmort-`idhs'.dta"

*filter non-missing
gen nomisvaruse = .
	replace nomisvaruse = 1 if !(chalive == 0 & missing(agedeath)) &	///
							   !missing(depriv) &						///
							   !missing(peduc)	   
loc sett  "precsvy10==1 & nomisvaruse==1"
keep if `sett'

*cek missing kategorik
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

*ganti label bordin
label drop bordin
lab def bordin 0 "Pertama" 			///
			   1 "2 dan >=24"		///
			   2 "2 dan <24"		///
			   3 ">=3 dan >=24"		///
			   4 ">=3 dan <24"
lab val bordin bordin

/*
*as survey design
egen strata = group(prov reside)
svyset psu [pw=wweight],strata(strata) */	

/*
******************************************************************
Gambaran umum sampel										[done]
******************************************************************
*/

*\unweighted
#delimit ;
quietly collect: table, 
				 stat(fvfrequency chalive nndeath ideath u5death $vars)
				 stat(fvpercent chalive nndeath ideath u5death $vars)
				 stat(mean deprivs pwdisthfac)
				 stat(median deprivs pwdisthfac)
				 stat(sd deprivs pwdisthfac)
				 ;
#delimit cr
quietly collect layout (colname) (result)
collect style row stack, nodelimiter nospacer indent length(.) wrapon(word)	///
		noabbreviate wrap(.) truncate(tail)
collect style cell border_block, border(right, pattern(nil))
collect style cell, nformat(%9.2f)
collect style save univar, replace
collect label levels result fvfrequency "n" fvpercent "%" sd "SD", modify
collect preview
collect export ".\output\univar.xls", as(xls) sheet(uw) replace

*\weighted
#delimit ;
quietly collect: table [iw=wweight], 
				 stat(fvfrequency chalive nndeath ideath u5death $vars)
				 stat(fvpercent chalive nndeath ideath u5death $vars)
				 stat(mean deprivs pwdisthfac)
				 stat(median deprivs pwdisthfac)
				 stat(sd deprivs pwdisthfac)
				 ;
#delimit cr
collect style use univar, replace layout
collect label levels result fvfrequency "n" fvpercent "%" sd "SD", modify
collect preview
collect export ".\output\univar.xls", as(xls) sheet(w) modify
  
/*
******************************************************************
Karakteristik sosial ekonomi dan status deprivasi			[done]
******************************************************************
*/

*\Tabulasi silang
tabmult [aw=wweight],													///
		cat(meduc4c peduc4c pareduc wealth reside)						///
		by(impdrinkwat impsan cookfldr depriv2c depriv) row				///
		save(output\desc_soc_depriv.xls) sheet(persen_w) replace

tabmult [aw=wweight],													///
		cat(meduc4c peduc4c pareduc wealth reside)						///
		by(impdrinkwat impsan cookfldr depriv2c depriv)					///
		save(output\desc_soc_depriv.xls) sheet(absolut) append

*\Two-way pearson chi-squared
#delimit ;
quietly collect: table (command) (result),
				 command(r(chi2) r(r): tab meduc4c impdrinkwat, row chi2)
				 command(r(chi2) r(r): tab peduc4c impdrinkwat, row chi2)
				 command(r(chi2) r(r): tab pareduc impdrinkwat, row chi2)
				 command(r(chi2) r(r): tab wealth impdrinkwat, row chi2)
				 command(r(chi2) r(r): tab reside impdrinkwat, row chi2)
				 
				 command(r(chi2) r(r): tab meduc4c impsan, row chi2)
				 command(r(chi2) r(r): tab peduc4c impsan, row chi2)
				 command(r(chi2) r(r): tab pareduc impsan, row chi2)
				 command(r(chi2) r(r): tab wealth impsan, row chi2)
				 command(r(chi2) r(r): tab reside impsan, row chi2)
				 
				 command(r(chi2) r(r): tab meduc4c cookfldr, row chi2)
				 command(r(chi2) r(r): tab peduc4c cookfldr, row chi2)
				 command(r(chi2) r(r): tab pareduc cookfldr, row chi2)
				 command(r(chi2) r(r): tab wealth cookfldr, row chi2)
				 command(r(chi2) r(r): tab reside cookfldr, row chi2)
				 
				 command(r(chi2) r(r): tab meduc4c depriv2c, row chi2)
				 command(r(chi2) r(r): tab peduc4c depriv2c, row chi2)
				 command(r(chi2) r(r): tab pareduc depriv2c, row chi2)
				 command(r(chi2) r(r): tab wealth depriv2c, row chi2)
				 command(r(chi2) r(r): tab reside depriv2c, row chi2)
				 
				 command(r(chi2) r(r): tab meduc4c depriv2c, row chi2)
				 command(r(chi2) r(r): tab peduc4c depriv2c, row chi2)
				 command(r(chi2) r(r): tab pareduc depriv2c, row chi2)
				 command(r(chi2) r(r): tab wealth depriv2c, row chi2)
				 command(r(chi2) r(r): tab reside depriv2c, row chi2)
	;
#delimit cr
collect style row stack, nodelimiter nospacer indent length(.) wrapon(word)	///
		noabbreviate wrap(.) truncate(tail)
collect style cell border_block, border(right, pattern(nil))
collect style cell, nformat(%9.3f)
collect style save chi2, replace
collect stars p "0.001" "***" "0.01" "** " "0.05" "*  " "1" "   ", attach(chi2)
collect preview
collect export ".\output\pearson-chi2.xls", as(xls) sheet(sosek-depriv) replace

*\Spearman corr
#delimit ;
quietly collect: table (rowname) (colname),
				 command(r(Rho): spearman meduc4c peduc4c pareduc wealth reside
							     impdrinkwat impsan cookfldr deprivs depriv)
	;
#delimit cr
collect style row stack, nodelimiter nospacer indent length(.) wrapon(word)	///
		noabbreviate wrap(.) truncate(tail)
collect style cell border_block, border(right, pattern(nil))
collect style cell, nformat(%9.3f)
collect style save spearmancor, replace
collect stars P "0.001" "***" "0.01" "** " "0.05" "*  " "1" "   ", attach(Rho)
collect preview
collect export ".\output\spearman.xls", as(xls) sheet(sosek-depriv) replace

/*
******************************************************************
Kecenderungan kematian anak menurut kovariat				[done]
******************************************************************
*/

*\Tabulasi silang
*Unweight
tabmult, cat(depriv depriv2c chsex bordin mageb pareduc wealth reside	///
			pwdisthfac3c)												///
		by(nndeath ideath u5death) row									///
		save(output\desc_2way_death.xls) sheet(persen) replace

tabmult, cat(depriv depriv2c chsex bordin mageb pareduc wealth reside	///
			pwdisthfac3c)												///
		by(nndeath ideath u5death)										///
		save(output\desc_2way_death.xls) sheet(absolut) append
		
*Weight
tabmult [aw=wweight], 													///
		cat(depriv depriv2c chsex bordin mageb pareduc wealth reside	///
			pwdisthfac3c)												///
		by(nndeath ideath u5death) row									///
		save(output\desc_2way_death.xls) sheet(persen_w) append

*\Two-way pearson chi-squared
#delimit ;
quietly collect: table (command) (result),
				 command(r(chi2) r(r): tab depriv nndeath, row chi2)
				 command(r(chi2) r(r): tab depriv2c nndeath, row chi2)
				 command(r(chi2) r(r): tab impdrinkwat nndeath, row chi2)
				 command(r(chi2) r(r): tab impsan nndeath, row chi2)
				 command(r(chi2) r(r): tab cookfldr nndeath, row chi2)
				 command(r(chi2) r(r): tab chsex nndeath, row chi2)
				 command(r(chi2) r(r): tab bordin nndeath, row chi2)
				 command(r(chi2) r(r): tab mageb nndeath, row chi2)
				 command(r(chi2) r(r): tab meduc4c nndeath, row chi2)
				 command(r(chi2) r(r): tab peduc4c nndeath, row chi2)
				 command(r(chi2) r(r): tab pareduc nndeath, row chi2)
				 command(r(chi2) r(r): tab wealth nndeath, row chi2)
				 command(r(chi2) r(r): tab reside nndeath, row chi2)
				 command(r(chi2) r(r): tab pwdisthfac3c nndeath, row chi2)
				 
				 command(r(chi2) r(r): tab depriv ideath, row chi2)
				 command(r(chi2) r(r): tab depriv2c ideath, row chi2)
				 command(r(chi2) r(r): tab impdrinkwat ideath, row chi2)
				 command(r(chi2) r(r): tab impsan ideath, row chi2)
				 command(r(chi2) r(r): tab cookfldr ideath, row chi2)
				 command(r(chi2) r(r): tab chsex ideath, row chi2)
				 command(r(chi2) r(r): tab bordin ideath, row chi2)
				 command(r(chi2) r(r): tab mageb ideath, row chi2)
				 command(r(chi2) r(r): tab meduc4c ideath, row chi2)
				 command(r(chi2) r(r): tab peduc4c ideath, row chi2)
				 command(r(chi2) r(r): tab pareduc ideath, row chi2)
				 command(r(chi2) r(r): tab wealth ideath, row chi2)
				 command(r(chi2) r(r): tab reside ideath, row chi2)
				 command(r(chi2) r(r): tab pwdisthfac3c ideath, row chi2)
				 
				 command(r(chi2) r(r): tab depriv u5death, row chi2)
				 command(r(chi2) r(r): tab depriv2c u5death, row chi2)
				 command(r(chi2) r(r): tab impdrinkwat u5death, row chi2)
				 command(r(chi2) r(r): tab impsan u5death, row chi2)
				 command(r(chi2) r(r): tab cookfldr u5death, row chi2)
				 command(r(chi2) r(r): tab chsex u5death, row chi2)
				 command(r(chi2) r(r): tab bordin u5death, row chi2)
				 command(r(chi2) r(r): tab mageb u5death, row chi2)
				 command(r(chi2) r(r): tab meduc4c u5death, row chi2)
				 command(r(chi2) r(r): tab peduc4c u5death, row chi2)
				 command(r(chi2) r(r): tab pareduc u5death, row chi2)
				 command(r(chi2) r(r): tab wealth u5death, row chi2)
				 command(r(chi2) r(r): tab reside u5death, row chi2)
				 command(r(chi2) r(r): tab pwdisthfac3c u5death, row chi2)
	;
#delimit cr
collect style use chi2, replace layout
collect stars p "0.001" "***" "0.01" "** " "0.05" "*  " "1" "   ", attach(chi2)
collect preview
collect export ".\output\pearson-chi2.xls", as(xls) sheet(kovar-death) modify

*\Spearman corr
#delimit ;
quietly collect: table (rowname) (colname),
				 command(r(Rho): spearman $vars deprivs pwdisthfac
								 nndeath ideath u5death)
	;
#delimit cr
collect style use spearmancor, replace layout
collect stars P "0.001" "***" "0.01" "** " "0.05" "*  " "1" "   ", attach(Rho)
collect preview
collect export ".\output\spearman.xls", as(xls) sheet(kovar-death) modify


*close log-file
log close _all
