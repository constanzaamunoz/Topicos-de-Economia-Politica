# Tópicos de Economía Política 

Este repositorio contiene los archivos, bases de datos y códigos necesarios para reproducir el análisis empírico desarrollado en el marco del curso **Tópicos de Economía Política**. El objetivo del proyecto es examinar la interacción entre incertidumbre global, ecosistemas mediáticos (medios tradicionales y redes sociales) y retornos financieros en Chile, utilizando técnicas econométricas aplicadas a series de tiempo.

A continuación se presenta la documentación de los insumos utilizados y de los procedimientos de construcción de la base de datos.

---

## 1. Descripción de las bases de datos

El proyecto emplea una serie de bases de datos provenientes de fuentes oficiales y repositorios financieros internacionales. Todas las series se encuentran en frecuencia diaria y fueron estandarizadas, alineadas y depuradas en el proceso de limpieza.

### 1.1. Índices de incertidumbre mediática

- **EMF_IND_COY.xlsx**  
  Contiene el índice **DEPUC**, una medida de incertidumbre económica proveniente de contenidos digitales y redes sociales.  
  **Fuente:** Banco Central de Chile.

- **EPU.xlsx**  
  Contiene el índice **EPU (Economic Policy Uncertainty)** para Chile, basado en artículos de prensa escrita.  
  **Fuente:** Banco Central de Chile.

### 1.2. Mercados financieros internacionales

- **Historical_Data.xlsx**  
  Serie histórica del índice **S&P 500 (Standard & Poor's 500 Index)**.  
  **Fuente:** Yahoo! Finance.

- **VIX.xlsx**  
  Serie del índice de volatilidad **VIX**, elaborado por Chicago Board Options Exchange (CBOE). Corresponde a la volatilidad implícita de opciones del S&P 500 a un mes.  
  **Fuente:** Banco Central de Chile.

### 1.3. Mercados financieros nacionales

- **IPSA.xlsx**  
  Serie del índice **IPSA (Índice de Precio Selectivo de Acciones)**, principal indicador bursátil de Chile, elaborado por S&P Dow Jones a partir de la Bolsa de Santiago.  
  **Fuente:** Banco Central de Chile.

- **PEM_TC.xlsx**  
  Tipo de cambio nominal (CLP/USD).  
  **Fuente:** Banco Central de Chile.

- **PEM_ECIN_Precios.xlsx**  
  Base de datos con indicadores macroeconómicos complementarios relevantes para el análisis.  
  **Fuente:** Banco Central de Chile.

---

## 2. Construcción de la base de datos

La base final utilizada en los modelos econométricos se genera mediante el script de Stata:

### `Creacion_BD.do`

Este código ejecuta los siguientes procedimientos:

1. **Importación** de todas las bases de datos en formato `.xlsx`.  
2. **Estandarización de fechas** y armonización de la frecuencia diaria.  
3. **Merge secuencial** de todas las series, asegurando alineamiento por fecha y completitud de observaciones.  
4. **Generación de variables transformadas** utilizadas en el análisis (retornos, logaritmos, z-scores, interacciones, etc.).

El resultado es una base de datos unificada y lista para el proceso de estimación.

---

## 3. Metodología y estimaciones

La estimación econométrica se ejecuta en:

### `Modelo.do`

Este archivo contiene:

- Especificación de las ecuaciones de interés.  
- Construcción de retornos financieros diarios.  
- Generación de interacciones entre incertidumbre global (VIX) y los índices mediáticos (EPU y DEPUC).  
- Estimaciones mediante Mínimos Cuadrados Ordinarios (OLS) con errores estándar robustos HAC.  
- Pruebas de robustez y especificaciones alternativas.

El enfoque principal del proyecto consiste en evaluar el contagio financiero internacional y el rol político-informacional de los medios (tradicionales y digitales) en la transmisión o mitigación de dicho contagio.

---

## 4. Reproducibilidad

Para reproducir los resultados del proyecto:

1. Abrir Stata.  
2. Ejecutar primero `Creacion_BD.do` para generar la base consolidada.  
3. Ejecutar posteriormente `Modelo.do` para replicar todas las estimaciones presentadas en el informe.

---
Valentina Flores y Constanza Muñoz
