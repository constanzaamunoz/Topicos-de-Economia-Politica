*·················································*
*  	  PROYECTO - TÓPICOS DE ECONOMÍA POLÍTICA     *
*·················································*

clear all


// Cambiar el directorio a la carpeta de trabajo propia:

cd "/Users/valentina/Library/CloudStorage/OneDrive-UniversidadCatólicadeChile/Universidad/MAE/E. Política/Proyecto/Código"

*==========================
* IPSA: precios -> retornos
*==========================

import excel "IPSA.xlsx", sheet("Cuadro") cellrange(A12:AC178) firstrow clear

describe    // para encontrar nombres de las variables 

* convertir fecha diaria a fecha mensual
gen mdate = mofd(Periodo)
format mdate %tm

tsset mdate, monthly

* retornos mensuales
gen r_ipsa = 100*(ln(ChileIPSA) - ln(L.ChileIPSA))

tsline ChileIPSA
tsline r_ipsa
rename ChileIPSA ipsa

* guardar base
keep mdate ipsa r_ipsa
order mdate ipsa r_ipsa
save "ipsa.dta", replace

*==========================
* EPU -> noticias
*==========================

import excel "EPU.xlsx", sheet("Hoja1") cellrange(A3:B399) firstrow clear


describe    // mira cómo se llaman las columnas

gen date = monthly(Date, "YM")
format date %tm
drop Date
order date EPU
tsset date, monthly

rename date mdate

* guardar base
keep mdate EPU
order mdate EPU
collapse (mean) EPU, by(mdate)
save "epu.dta", replace


*==========================
* DEPUC -> redes sociales
*==========================

import excel "EMF_IND_COY.xlsx", sheet("Cuadro") cellrange(A14:B180) firstrow clear

rename Índicediariodeincertidumbr depuc

gen mdate = mofd(Periodo)
format mdate %tm

keep mdate depuc
order mdate depuc
tsset mdate, monthly

* guardar base 
save "depuc.dta", replace

*==========================
* S&P500 -> control macro
*==========================
import excel "Historical_Data.xlsx", sheet("Sheet1") firstrow clear

 
gen mdate = mofd(Date)
format mdate %tm

keep mdate Close 
rename Close sp500
order mdate sp500

tsset mdate, monthly

*retornos sp500
gen r_sp500 = 100*(ln(sp500) - ln(L.sp500))

* guardar base
save "sp500.dta", replace

*==========================
* VIX -> volatilidad
*==========================
import excel "VIX.xlsx", sheet("Cuadro") cellrange(A11:B177) firstrow clear

gen mdate = mofd(Periodo)
format mdate %tm

keep mdate VIX 
order mdate VIX
tsset mdate, monthly

* guardar base
save "VIX.dta", replace


*==========================
* TC -> control macro
*==========================
import excel "PEM_TC.xlsx", sheet("Cuadro") cellrange(A13:B179) firstrow clear

rename Tipodecambionominaldó tc
describe

gen mdate = mofd(Periodo)
format mdate %tm

tsset mdate, monthly

keep mdate tc

gen d_tc = 100*(ln(tc)-ln(L.tc))

save "tc.dta", replace

*==========================
* Precio del cobre
*==========================

import excel "PEM_ECIN_Precios.xlsx", sheet("Cuadro") cellrange(A15:B181) firstrow clear

rename PreciodelcobreUSDporlib precio_cu

gen mdate = mofd(Periodo)
format mdate %tm

tsset mdate, monthly
keep mdate precio_cu

gen d_cu = 100*(ln(precio_cu)-ln(L.precio_cu))

save "precio_cobre.dta", replace

*==========================
* Merge
*==========================
clear
use "ipsa.dta", clear

merge 1:1 mdate using "epu.dta"
drop _merge

merge 1:1 mdate using "depuc.dta"
drop _merge

merge 1:1 mdate using "vix.dta"
drop _merge

merge 1:1 mdate using "sp500.dta"
drop _merge

merge 1:1 mdate using "tc.dta"
drop _merge

merge 1:1 mdate using "precio_cobre.dta"
drop _merge

tsset mdate, monthly

save "merged.dta", replace

keep if mdate >= ym(2012,1)
rename EPU epu
rename VIX vix

label variable mdate "Fecha"
label variable ipsa "IPSA"
label variable r_ipsa "Retornos del IPSA"
label variable epu "EPU index"
label variable depuc "DEPUC index"
label variable vix "Índice de volatilidad global"
label variable sp500 "S&P500"
label variable r_sp500 "Retornos del S&P500"
label variable tc "Tipo de cambio nominal"
label variable d_tc "Diferencia de Tipo de cambio"
label variable precio_cu "Precio del cobre: USD/libra"
label variable d_cu "Crecimiento del precio del cobre"
 
save "base_final.dta", replace

*==========================
* Gráfico Anexo A
*==========================
twoway ///
    (tsline epu, lcolor(blue) lwidth(medthick)) ///
    (tsline depuc, lcolor(red) lwidth(medthick)) ///
    (tsline ipsa, yaxis(2) lcolor(gs6) lwidth(thick)) ///
    , ///
    legend(order(1 "EPU" 2 "DEPUC" 3 "IPSA (eje 2)")) ///
    title("IPSA vs EPU vs DEPUC") ///
    ytitle("EPU / DEPUC") ///
    ytitle("IPSA", axis(2))
	
*==========================
* Tabla Anexo A
*==========================
	
estpost summarize r_ipsa epu depuc vix r_sp500 tc precio_cu, detail
esttab using "descriptivo_c.tex", replace ///
    cells("mean sd min max") ///
    label booktabs nomtitles noobs nonumber

*==========================
* Tabla 1: Estadísticas
*==========================
estpost summarize r_ipsa epu depuc vix, detail
esttab using "descriptivo_1.tex", replace ///
    cells("mean sd") ///
    label booktabs nomtitles noobs nonumber
	





