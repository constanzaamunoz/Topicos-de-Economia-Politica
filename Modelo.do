*·················································*
*  	  PROYECTO - TÓPICOS DE ECONOMÍA POLÍTICA     *
*·················································*

clear all


// Cambiar el directorio a la carpeta de trabajo propia:

cd "/Users/valentina/Library/CloudStorage/OneDrive-UniversidadCatólicadeChile/Universidad/MAE/E. Política/Proyecto"

use "base_final.dta",clear

tsset 

*==========================
* Creación de variables
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

// tests de estacionariedad
dfuller r_ipsa, lags(12) // si
dfuller depuc,  lags(12) // no
dfuller epu,    lags(12) // no
dfuller vix,    lags(12) // si

* diferimos los no estacionarios
gen d_depuc = D.depuc
gen d_epu   = D.epu

dfuller d_depuc, lags(12) 
dfuller d_epu, lags(12)

// ahora sí son estacionarios

*¿Aumenta la intensidad mediática la transmisión del riesgo global (VIX) hacia el mercado accionario chileno?

* estandarizamos
foreach var in vix epu depuc {
    summarize `var'
    gen z_`var' = (`var' - r(mean)) / r(sd)
}


global controles pol L.r_ipsa r_sp500 L.r_sp500 d_tc d_cu 

* reemplazamos variables por su ponderación con los pesos
replace vix = z_vix * vix
replace d_epu = z_epu * d_epu
replace d_depuc = z_depuc * d_depuc

* generamos interacciones
gen int_vix_epu   = vix * d_epu
gen int_vix_depuc = vix * d_depuc

gen int_vix_epu_pol = vix * d_epu * pol
gen int_vix_depuc_pol = vix * d_depuc * pol

*==========================
* Modelo econométrico
*==========================

*regresiones

newey r_ipsa vix d_epu int_vix_epu int_vix_epu_pol $controles , lag(5)
eststo m1
estadd local controles "Sí"

newey r_ipsa vix d_depuc int_vix_depuc int_vix_depuc_pol $controles , lag(5)
eststo m2
estadd local controles "Sí"


*==========================
* Pruebas VIF
*==========================

*multicolinealidad
reg r_ipsa vix d_epu int_vix_epu int_vix_epu_pol $controles , r
vif

reg r_ipsa vix d_depuc int_vix_depuc int_vix_depuc_pol $controles  , r
vif

*==========================
* Tabla 2
*==========================

esttab m1 m2 using "resultados_reg.tex", ///
    replace se star(* 0.10 ** 0.05 *** 0.01) ///
    compress booktabs ///
	keep(vix d_epu int_vix_epu int_vix_epu_pol d_depuc int_vix_depuc int_vix_depuc_pol) ///  <- solo muestra estas vars
    stats(N r2 controles, ///
          labels("Observaciones" "R^2" "Controles")) ///
    title("Resultados – estimaciones de los efectos sobre los retornos del IPSA")
	
*==========================
* Tabla Anexo A
*==========================

esttab m1 m2 using "resultados_reg_anexos.tex", ///
    replace se star(* 0.10 ** 0.05 *** 0.01) ///
    compress booktabs ///
    stats(N r2 controles, ///
          labels("Observaciones" "R^2" "Controles")) ///
    title("Resultados completos – estimaciones de los efectos sobre los retornos del IPSA")
	
*==========================
* Gráfico Anexo C
*==========================	
	
twoway  (tsline d_depuc,  lcolor(green)) ///
		(tsline d_epu,  lcolor(purple)) 
graph export "epu_vs_depuc.png", replace
		


