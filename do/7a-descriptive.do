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

cls
log close _all
clear all
macro drop _all
set maxvar 10000

*direktori kerja
cd 				"D:\RESEARCH & WRITING\master thesis_child mortality\stata\"
loc logdir		"log"
loc dtadir		"dta"
loc idhs		"idhs17"
*loc outdir		"output"

*log file
loc dfn 		"log_7a_descriptive_`idhs'"
log using 		"`logdir'\7a_descriptive_`idhs'", name(`dfn') text replace



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
use "`dtadir'\6-chmort-`idhs'.dta"

*filter non-missing
gen nomisvaruse = .
	replace nomisvaruse = 1 if !(chalive == 0 & missing(agedeath)) &	///
							   !missing(depriv) &						///
							   !missing(peduc)	   
loc sett  "precsvy10==1 & nomisvaruse==1"
keep if `sett'

*cek missing
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

gen con = 1

*as survey design
egen strata = group(prov reside)
svyset psu [pw=wweight],strata(strata)	


/*
******************************************************************
Gambaran umum sampel										[done]
******************************************************************
*/

*univar
foreach p in $vars chalive nndeath ideath u5death {
	    quietly tabout `p'			///
		using "output\univar_.xls", c(freq col) clab(N %) format(0c 2) append
}

foreach p in $vars chalive nndeath ideath u5death {
	    quietly tabout `p' [iw=wweight]			///
		using "output\univar_iw.xls", c(freq col) clab(N %) format(0c 2) append
}

*kontinyu
*duplicates drop psu, force
table [iw=wweight], stat(mean pwdisthfac)	///
					stat(median pwdisthfac)	///
					stat(sd pwdisthfac)
					
table, stat(mean pwdisthfac)	///
	   stat(median pwdisthfac)	///
	   stat(sd pwdisthfac)	
  
/*
******************************************************************
Karakteristik sosial ekonomi dan status deprivasi			[done]
******************************************************************
*/

*Weight
tabmult [aw=wweight],													///
		cat(meduc4c peduc4c pareduc wealth reside)						///
		by(impdrinkwat impsan cookfldr depriv2c depriv) row				///
		save(output\desc_soc_depriv.xls) sheet(persen_w) replace

tabmult [aw=wweight],													///
		cat(meduc4c peduc4c pareduc wealth reside)						///
		by(impdrinkwat impsan cookfldr depriv2c depriv)					///
		save(output\desc_soc_depriv.xls) sheet(absolut) append

*Two-way pearson chi-squared
*\sumber utama air minum
foreach p of varlist meduc4c peduc4c pareduc wealth reside{
    tab `p' impdrinkwat, row m chi2
}

*\sanitasi
foreach p of varlist meduc4c peduc4c pareduc wealth reside{
    tab `p' impsan, row m chi2
}

*\bahan bakar memasak
foreach p of varlist meduc4c peduc4c pareduc wealth reside{
    tab `p' cookfldr, row m chi2
}

*\depriv 2 kategori
foreach p of varlist meduc4c peduc4c pareduc wealth reside{
    tab `p' depriv2c, row m chi2
}

*\depriv 3 kategori
foreach p of varlist meduc4c peduc4c pareduc wealth reside{
    tab `p' depriv, row m chi2
}

*Spearman corr
*\impdrinkwat
quietly spearman meduc4c peduc4c pareduc wealth reside impdrinkwat, stats(rho p)
matrix list r(Rho), format(%4.3f)
matrix list r(P), format(%4.3f)
*\impsan
quietly spearman meduc4c peduc4c pareduc wealth reside impsan, stats(rho p)
matrix list r(Rho), format(%4.3f)
matrix list r(P), format(%4.3f)
*\cookfldr
quietly spearman meduc4c peduc4c pareduc wealth reside cookfldr, stats(rho p)
matrix list r(Rho), format(%4.3f)
matrix list r(P), format(%4.3f)
*\depriv
*spearman meduc4c peduc4c pareduc wealth reside depriv2c, stats(rho p)
quietly spearman meduc4c peduc4c pareduc wealth reside depriv, stats(rho p)
matrix list r(Rho), format(%4.3f)
matrix list r(P), format(%4.3f)

/*
******************************************************************
Kecenderungan kematian anak menurut kovariat				[done]
******************************************************************
*/

*Unweight
tabmult, cat(depriv depriv2c chsex bordin mageb pareduc wealth reside	///
			pwdisthfac3c)												///
		cont(pwdisthfac)												///
		by(nndeath ideath u5death) row statc(mean med sd)				///
		save(output\desc_2way_death.xls) sheet(persen) replace

tabmult, cat(depriv depriv2c chsex bordin mageb pareduc wealth reside	///
			pwdisthfac3c)												///
		cont(pwdisthfac)												///
		by(nndeath ideath u5death) statc(mean med sd)					///
		save(output\desc_2way_death.xls) sheet(absolut) append
		
*Weight
tabmult [aw=wweight], 													///
		cat(depriv depriv2c chsex bordin mageb pareduc wealth reside	///
			pwdisthfac3c)												///
		cont(pwdisthfac)												///
		by(nndeath ideath u5death) row statc(mean med sd)				///
		save(output\desc_2way_death.xls) sheet(persen_w) append

		
*Two-way pearson chi-squared
*\neonatal
foreach p in $vars{
	tab `p' nndeath, row m chi2
}

*\bayi
foreach p in $vars{
	tab `p' ideath, row m chi2
}

*\di bawah 5 tahun
foreach p in $vars{
	tab `p' u5death, row m chi2
}

*Spearman corr
*\neonatal
quietly spearman $vars pwdisthfac nndeath, stats(rho p)
matrix list r(Rho), format(%4.3f)
matrix list r(P), format(%4.3f)
*\bayi
quietly spearman $vars pwdisthfac ideath, stats(rho p)
matrix list r(Rho), format(%4.3f)
matrix list r(P), format(%4.3f)
*\di bawah 5 tahun
quietly spearman $vars pwdisthfac u5death, stats(rho p)
matrix list r(Rho), format(%4.3f)
matrix list r(P), format(%4.3f)