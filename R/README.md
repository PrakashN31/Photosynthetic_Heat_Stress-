# 📊 R Analysis Scripts for Photosynthetic Thermal Tolerance Research

**Analysis workflows for thermal tolerance mechanisms in tropical tree species**

---

## 📌 Overview

This directory contains R scripts for processing, analyzing, and visualizing data from the photosynthetic thermal tolerance study of tropical tree species in South India. The scripts follow a sequential workflow from raw data processing through statistical analysis and publication-ready figure generation.

---

## 📂 Directory Structure

```
R/
├── README.md                          # This file
├── 01_data_processing.R              # Data cleaning and preprocessing
├── 02_thermal_analysis.R             # TRC analysis and temperature calculations
├── 03_visualization.R                # Plotting and figure generation
├── 04_statistical_analysis.R         # Statistical tests and comparisons
├── LST_Bhadra_Workflow.R             # Land Surface Temperature analysis
└── functions/                        # [Optional] Custom R functions
    └── thermal_tolerance_functions.R # Helper functions for TRC calculations
```

---

## 🔧 Getting Started

### Prerequisites

Ensure you have R (≥ 4.0.0) installed. Then install required packages:

```r
# Install CRAN packages
packages <- c(
  "tidyverse",      # Data manipulation and visualization
  "ggplot2",        # Advanced graphics
  "dplyr",          # Data wrangling
  "readxl",         # Excel data import
  "nlme",           # Mixed effects models
  "fitdistrplus",   # Curve fitting
  "raster",         # Spatial analysis
  "sf",             # Simple features for spatial data
  "terra",          # Raster data handling
  "viridisLite",    # Color palettes
  "cowplot",        # Combine plots
  "gridExtra"       # Grid graphics
)

install.packages(packages)
```

### Project Setup

1. Clone the repository:
```bash
git clone https://github.com/PrakashN31/Photosynthetic_Heat_Stress-.git
cd Photosynthetic_Heat_Stress-
```

2. Set working directory in R:
```r
setwd("path/to/Photosynthetic_Heat_Stress-")
```

---

## 📋 Script Descriptions

### 01_data_processing.R

**Purpose:** Data cleaning, quality control, and preprocessing

**Key Functions:**
- Import raw data from Excel files
- Handle missing values and outliers
- Standardize variable naming and units
- Create processed datasets for analysis

**Inputs:**
- Raw data files from `data/raw/`

**Outputs:**
- Cleaned datasets in `data/processed/`

**Run:**
```r
source("R/01_data_processing.R")
```

---

### 02_thermal_analysis.R

**Purpose:** Thermal Response Curve (TRC) analysis and calculations

**Key Functions:**
- Extract temperature optima (T_opt)
- Calculate critical temperatures (T_crit)
- Fit polynomial/exponential models to TRCs
- Assess PSII efficiency and photosynthetic rate thermal responses
- Compare thermal traits across species and populations

**Inputs:**
- Processed data from `data/processed/`
- Temperature gradient measurements
- PSII efficiency and gas exchange data

**Outputs:**
- TRC parameters and thermal tolerance metrics
- Results tables in `output/tables/`

**Run:**
```r
source("R/02_thermal_analysis.R")
```

---

### 03_visualization.R

**Purpose:** Publication-quality figure generation

**Figures Generated:**
- Thermal Response Curves (species comparison)
- Temperature optima distribution plots
- Heatmaps of thermal tolerance across species
- Phenological vs. thermal plasticity plots
- Environmental gradient visualizations

**Inputs:**
- Analysis results from `02_thermal_analysis.R`
- Processed data

**Outputs:**
- Publication-ready figures in `output/figures/`
- High-resolution PNG and PDF formats

**Run:**
```r
source("R/03_visualization.R")
```

---

### 04_statistical_analysis.R

**Purpose:** Statistical hypothesis testing and comparative analysis

**Analyses Included:**
- ANOVA and mixed effects models for thermal tolerance differences
- Correlation analysis (thermal traits vs. phenology)
- Linear/non-linear regression models
- Post-hoc tests and multiple comparisons
- Effect size calculations

**Inputs:**
- Processed and analyzed data

**Outputs:**
- Statistical results and summary tables in `output/tables/`

**Run:**
```r
source("R/04_statistical_analysis.R")
```

---

### LST_Bhadra_Workflow.R

**Purpose:** Land Surface Temperature (LST) analysis of Bhadra Tiger Reserve using Landsat 8

**Key Processes:**
- Import Landsat 8 Collection 2 Level-2 Surface Temperature (ST_B10) imagery
- Reproject and mask raster to study area boundary
- Convert ST_B10 to Land Surface Temperature (°C)
- Calculate raster statistics
- Generate LST map and distribution histogram

**Data Used:**
- Landsat 8 ST_B10 (acquired 08 April 2026)
- Administrative boundaries (Bhadra Tiger Reserve, Karnataka)
- Kuvempu University location data

**Temperature Conversion Formula:**
```
Temperature (°C) = (ST_B10 × 0.00341802 + 149) − 273.15
```

**Summary Statistics (Bhadra Tiger Reserve):**
- Minimum: 27.35 °C
- Maximum: 50.28 °C
- Mean: 32.65 ± 2.51 °C

**Outputs:**
- LST_Bhadra_Celsius.tif (processed raster)
- Bhadra_LST_Map.png (publication-quality map)
- Bhadra_LST_Distribution.png (histogram)

**Run:**
```r
source("R/LST_Bhadra_Workflow.R")
```

---

## 🚀 Complete Workflow Execution

Run all analysis scripts in sequence:

```r
# Set working directory
setwd("path/to/Photosynthetic_Heat_Stress-")

# Execute scripts in order
source("R/01_data_processing.R")
source("R/02_thermal_analysis.R")
source("R/03_visualization.R")
source("R/04_statistical_analysis.R")

# Optional: Run LST analysis separately
source("R/LST_Bhadra_Workflow.R")
```

---

## 📊 Key R Packages Used

| Package | Purpose |
|---------|---------|
| `tidyverse` | Data manipulation and visualization framework |
| `ggplot2` | Advanced graphics and plotting |
| `dplyr` | Data wrangling and transformation |
| `readxl` | Import Excel spreadsheets |
| `nlme` | Mixed effects models for thermal comparisons |
| `fitdistrplus` | Curve fitting for TRC analysis |
| `raster` / `terra` | Spatial raster data processing |
| `sf` | Simple features for vector data |
| `viridisLite` | Color-blind friendly palettes |
| `cowplot` | Combine and arrange multiple plots |
| `gridExtra` | Grid-based graphics |

---

## 📈 Data Flow Diagram

```
Raw Data (data/raw/)
       ↓
01_data_processing.R
       ↓
Processed Data (data/processed/)
       ↓
02_thermal_analysis.R
       ↓
Thermal Tolerance Metrics
       ↓
    ↙ ↓ ↘
03_viz  04_stats  LST_analysis
    ↙ ↓ ↘
  Figures  Tables  Rasters
```

---

## 🔍 Reproducibility

All scripts include:
- ✅ Inline comments explaining each step
- ✅ Explicit package loading and version information
- ✅ Clear input/output file paths
- ✅ Seed setting for reproducible randomization
- ✅ Session information capture at script end

**To ensure reproducibility:**
```r
# Capture session info
sessionInfo()

# Check package versions
packageVersion("ggplot2")
```

---

## 📖 Data Dictionary Reference

For detailed variable descriptions, see: `docs/data_dictionary.md`

### Key Variables

- **T_opt:** Temperature optimum for photosynthetic rate (°C)
- **T_crit:** Critical temperature for PSII efficiency (°C)
- **Fv/Fm:** Maximum PSII quantum yield
- **Y(II):** PSII operating efficiency
- **NPQ:** Non-photochemical quenching
- **Anet:** Net photosynthetic rate (µmol m⁻² s⁻¹)
- **gs:** Stomatal conductance (mol m⁻² s⁻¹)
- **E:** Transpiration rate (mmol m⁻² s⁻¹)

---

## 🐛 Troubleshooting

### Common Issues

**Issue:** Missing packages
```r
# Solution: Install missing packages
install.packages("package_name")
```

**Issue:** File path errors
```r
# Verify working directory
getwd()

# Check file exists
file.exists("data/raw/your_file.xlsx")
```

**Issue:** Raster projection mismatch
```r
# Check CRS
st_crs(vector_data)
crs(raster_data)

# Reproject if needed
raster_data <- terra::project(raster_data, crs(vector_data))
```

---

## 📝 Output Files

### Generated Data Files
- `data/processed/` - Cleaned datasets
- `output/tables/` - Summary statistics and results
- `output/figures/` - Publication-quality plots (PNG/PDF)

### Specific Outputs
- Thermal tolerance parameter tables
- ANOVA and model results
- LST statistics and raster data
- High-resolution figures for manuscripts

---

## 📚 Related Documentation

- **Methods:** See `docs/methods.md` for detailed methodology
- **Field Protocols:** See `docs/field_protocols.md` for data collection procedures
- **Data Dictionary:** See `docs/data_dictionary.md` for variable descriptions
- **Main README:** See root `README.md` for full project overview

---

## 🔗 Resources & References

### Key Publications
- Tiwari et al. (2026). *Decoupled phenology and PSII thermal plasticity in seasonally dry tropical forest trees.* Plant, Cell & Environment (Under Review)

### R Documentation
- [tidyverse documentation](https://www.tidyverse.org/)
- [ggplot2 book](https://ggplot2-book.org/)
- [R for Data Science](https://r4ds.had.co.nz/)

### Thermal Ecology Resources
- Temperature Response Curves: [Reference paper]
- PSII Fluorescence Measurements: [PAM manuals]

---

## ✍️ Author & Contact

**Prakash Narayanappa**
- 🔗 GitHub: [@PrakashN31](https://github.com/PrakashN31)
- 🆔 ORCID: [0009-0002-5419-5192](https://orcid.org/0009-0002-5419-5192)
- 🌐 Linktree: [prakashnarayanappa9](https://linktr.ee/prakashnarayanappa9)

**Affiliation:** Forestry College Ponnampet × ETH Zurich

---

## 📄 License

This project is licensed under the [MIT License](../LICENSE)

---

## 🤝 Contributing

Contributions, bug reports, and suggestions are welcome! Please:
1. Create an issue for bugs or suggestions
2. Fork and create a feature branch for contributions
3. Ensure code follows the project's style and includes comments

---

## 📞 Support & Questions

For questions about:
- **Analysis methods:** See `docs/methods.md`
- **Data collection:** See `docs/field_protocols.md`
- **Script usage:** Check inline comments in R files
- **General inquiries:** Open an issue or contact via GitHub

---

<div align="center">

**"Understanding thermal tolerance mechanisms today to predict ecosystem responses to climate change tomorrow."**

🌿 **Ecology** • 🌍 **Conservation** • 🔬 **Research** • 📊 **Data Analysis** • 🗺️ **GIS**

</div>
