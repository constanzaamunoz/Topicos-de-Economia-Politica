cd "C:\Users\const\OneDrive - Universidad Católica de Chile\2025-02\Archivos de Valentina Constanza Flores Quintanilla - T. de E. Política\Proyecto"

*==========================
* IPSA: precios -> retornos
*==========================
import excel "C:\Users\const\OneDrive - Universidad Católica de Chile\2025-02\Archivos de Valentina Constanza Flores Quintanilla - T. de E. Política\Proyecto\IPSA.xlsx", sheet("Cuadro") cellrange(A12:AC178) firstrow clear

describe    // mira cómo se llaman las columnas

* Convertir fecha diaria a fecha mensual
gen mdate = mofd(Periodo)
format mdate %tm

tsset mdate, monthly

* retornos mensuales
gen r_ipsa = 100*(ln(ChileIPSA) - ln(L.ChileIPSA))

tsline ChileIPSA
tsline r_ipsa
rename ChileIPSA ipsa

* guardamos
keep mdate ipsa r_ipsa
order mdate ipsa r_ipsa
save "ipsa.dta", replace

*==========================
* EPU -> noticias
*==========================
import excel "C:\Users\const\OneDrive - Universidad Católica de Chile\2025-02\Archivos de Valentina Constanza Flores Quintanilla - T. de E. Política\Proyecto\EPU.xlsx", sheet("Hoja1") cellrange(A3:B399) firstrow clear


describe    // mira cómo se llaman las columnas

gen date = monthly(Date, "YM")
format date %tm
drop Date
order date EPU
tsset date, monthly

rename date mdate

* guardamos
keep mdate EPU
order mdate EPU
collapse (mean) EPU, by(mdate)
save "epu.dta", replace


*==========================
* DEPUC -> redes sociales
*==========================

import excel "C:\Users\const\OneDrive - Universidad Católica de Chile\2025-02\Archivos de Valentina Constanza Flores Quintanilla - T. de E. Política\Proyecto\EMF_IND_COY.xlsx", sheet("Cuadro") cellrange(A14:B180) firstrow clear

rename Índicediariodeincertidumbr depuc

gen mdate = mofd(Periodo)
format mdate %tm

keep mdate depuc
order mdate depuc
tsset mdate, monthly

* Guardar limpio
save "depuc.dta", replace

*==========================
* S&P500 -> control macro
*==========================
 import excel "C:\Users\const\OneDrive - Universidad Católica de Chile\2025-02\Archivos de Valentina Constanza Flores Quintanilla - T. de E. Política\Proyecto\Historical_Data.xlsx", sheet("Sheet1") firstrow clear

 
gen mdate = mofd(Date)
format mdate %tm

keep mdate Close 
rename Close sp500
order mdate sp500

tsset mdate, monthly

*retornos sp500
gen r_sp500 = 100*(ln(sp500) - ln(L.sp500))

save "sp500.dta", replace

*==========================
* VIX -> volatilidad
*==========================
import excel "C:\Users\const\OneDrive - Universidad Católica de Chile\2025-02\Archivos de Valentina Constanza Flores Quintanilla - T. de E. Política\Proyecto\VIX.xlsx", sheet("Cuadro") cellrange(A11:B177) firstrow clear

gen mdate = mofd(Periodo)
format mdate %tm

keep mdate VIX 
order mdate VIX
tsset mdate, monthly

save "VIX.dta", replace

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

tsset mdate, monthly

save "merged.dta", replace
keep if mdate >= ym(2012,1)
rename EPU epu
rename VIX vix
save "merged.dta", replace

*==========================
* Gráfico
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
* Modelo
*==========================

// declaramos la variable de intensidad política
gen pol = 0

* Elección presidencial 2013 (campaña fuerte)
replace pol = 1 if inrange(mdate, ym(2013,9), ym(2013,11))

* Municipales 2016
replace pol = 1 if inrange(mdate, ym(2016,8), ym(2016,10))

* Presidencial 2017 (primera y segunda vuelta)
replace pol = 1 if inrange(mdate, ym(2017,9), ym(2017,12))

* Estallido social
replace pol = 1 if inrange(mdate, ym(2019,10), ym(2019,12))

* Plebiscito de entrada (Proceso constituyente)
replace pol = 1 if inrange(mdate, ym(2020,9), ym(2020,10))

* Proceso constituyente y elecciones convencionales / presidenciales
replace pol = 1 if inrange(mdate, ym(2021,4), ym(2021,5))
replace pol = 1 if inrange(mdate, ym(2021,9), ym(2021,11))

* Plebiscito 2022 (salida texto 1)
replace pol = 1 if inrange(mdate, ym(2022,8), ym(2022,9))

* Plebiscito 2023 (salida texto 2)
replace pol = 1 if inrange(mdate, ym(2023,4), ym(2023,5))

label define pollab 0 "Normal" 1 "Alta intensidad política"
label values pol pollab


// estacionariedad
dfuller r_ipsa, lags(12) // si
dfuller depuc,  lags(12) // no
dfuller epu,    lags(12) // no
dfuller vix,    lags(12) // si

* diferimos los no estacionarios
gen d_depuc = D.depuc
gen d_epu   = D.epu // ahora sí son estacionarios

////////////////////////////////////////
*¿Aumenta la intensidad mediática la transmisión del riesgo global (VIX) hacia el mercado accionario chileno?

****************
* estandarizamos
foreach var in vix epu depuc {
    summarize `var'
    gen z_`var' = (`var' - r(mean)) / r(sd)
}

* generamos interacciones
gen int_vix_epu   = L.z_vix * L.z_epu
gen int_vix_depuc = L.z_vix * L.z_depuc

*regresiones
reg r_ipsa L.z_vix L.z_epu L.int_vix_epu ///
    L.r_ipsa L.r_sp500, vce(robust)

reg r_ipsa L.z_vix L.z_depuc L.int_vix_depuc ///
    L.r_ipsa L.r_sp500, vce(robust)

reg r_ipsa L.z_vix L.z_epu L.z_depuc ///
    L.int_vix_epu L.int_vix_depuc ///
    L.r_ipsa L.r_sp500, vce(robust)

*rta:
*Sí, pero de forma asimétrica:

**La prensa escrita (EPU) amplifica el contagio del riesgo global hacia el IPSA (+ y significativo)

**La incertidumbre generada en redes sociales (DEPUC) tiende a reducirlo (- y significativo)






