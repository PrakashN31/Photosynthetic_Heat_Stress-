# 🌿 Land Surface Temperature (LST) Analysis of Bhadra Tiger Reserve

**Author:** Prakash N

This repository contains a complete R workflow for processing Landsat 8 Collection 2 Level-2 Surface Temperature (ST_B10) imagery to estimate Land Surface Temperature (LST) across Bhadra Tiger Reserve, Karnataka, India.

The workflow includes preprocessing, raster masking, temperature conversion, statistical analysis, and publication-quality figure generation.

---

## Study Area

**Bhadra Tiger Reserve**
Karnataka, India

The study also highlights the location of **Kuvempu University**, which served as one of the field study locations.

---

## Landsat Dataset

**Satellite:** Landsat 8

**Product:** Collection 2 Level-2 Surface Temperature (ST_B10)

**Acquisition Date:** 08 April 2026

**Path/Row:** 145/051

---

## Processing Workflow

The workflow performs the following steps:

1. Read administrative boundaries and study area polygons
2. Import Landsat 8 ST_B10 raster
3. Reproject vector layers to raster CRS
4. Crop raster to Bhadra Tiger Reserve
5. Mask raster using reserve boundary
6. Convert ST_B10 to Land Surface Temperature (°C)
7. Calculate raster statistics
8. Export processed raster
9. Generate publication-quality LST map
10. Generate LST distribution histogram

---

## Temperature Conversion

Landsat Collection 2 Level-2 Surface Temperature is converted using:

Temperature (°C) = (ST_B10 × 0.00341802 + 149) − 273.15

---

## Summary Statistics

| Statistic | Value |
|-----------|------:|
| Minimum | 27.35 °C |
| Maximum | 50.28 °C |
| Mean | 32.65 °C |
| Standard Deviation | 2.51 °C |

---

## Repository Structure

```
Photosynthetic_Heat_Stress-/
│
├── Data/
│   ├── India boundary/
│   ├── Karnataka boundary/
│   ├── Bhadra boundary/
│   ├── Kuvempu University KML/
│   ├── LST Raster/
│   ├── Bhadra_UTM.gpkg
│   ├── KU_UTM.gpkg
│   └── LST_Bhadra_Celsius.tif
│
├── Outputs/
│   ├── Bhadra_LST_Map.png
│   └── Bhadra_LST_Distribution.png
│
├── R/
│   └── LST_Bhadra_Workflow.R
│
└── README.md
```

---

## Required R Packages

```r
library(sf)
library(terra)
library(viridisLite)
```

---

## Output Files

### Raster

- LST_Bhadra_Celsius.tif

### Figures

- Bhadra_LST_Map.png
- Bhadra_LST_Distribution.png

---

## Citation

Prakash N.

Land Surface Temperature (LST) across Bhadra Tiger Reserve derived from Landsat 8 Collection 2 Level-2 Surface Temperature (ST_B10) acquired on **08 April 2026**.

LST ranged from **27.35 °C to 50.28 °C** (mean = **32.65 ± 2.51 °C**).

---

## License

This repository is intended for academic research and educational purposes.
