# Photosynthetic Thermal Tolerance of Tropical Trees

**Investigation of thermal tolerance mechanisms in tropical tree species to understand resilience under climate warming scenarios.**

---

## 📋 Project Overview

This research investigates the photosynthetic thermal tolerance mechanisms of tropical tree species to assess their resilience and adaptive potential under projected climate warming scenarios. The project combines physiological measurements with ecological assessment to understand how different tree species respond to thermal stress.

### Research Objectives

- Quantify photosynthetic thermal tolerance limits (T_opt, T_crit) across tropical tree species
- Examine intraspecific variation in thermal tolerance among populations
- Assess the relationship between thermal tolerance and ecological distribution
- Understand decoupling between phenology and PSII thermal plasticity
- Evaluate climate resilience of tropical forest ecosystems

---

## 🔬 Methodology

### Field Sites
- **Primary Study Area:** Tropical dry deciduous and evergreen forests of South India
- **Focus Regions:** Western Ghats, Kodagu, Tarikiere Taluk

### Data Collection

#### Physiological Measurements
- **PSII Efficiency:** Chlorophyll fluorescence measurements using portable fluorometer
- **Thermal Tolerance Assessment:** Temperature gradient experiments
- **Gas Exchange:** Photosynthetic rate measurements across temperature ranges
- **Leaf Temperature:** In-situ temperature monitoring under natural conditions

#### Ecological Data
- Species inventory and distribution mapping
- Phenological observations
- Microclimate characterization
- Leaf trait measurements

### Analytical Approach

- Thermal response curves (TRCs) for photosynthetic rate and PSII efficiency
- Temperature optima (T_opt) and critical temperature (T_crit) determination
- Comparative analysis across species and populations
- Climate envelope modeling
- Correlation analysis between thermal traits and phenological timing

---

## 📁 Repository Structure

```
thermal-tolerance-tropical-trees/
├── README.md                          # Project documentation
├── data/
│   ├── raw/                           # Original field measurements
│   │   ├── chlorophyll_fluorescence/
│   │   ├── gas_exchange/
│   │   └── leaf_traits/
│   ├── processed/                     # Cleaned and formatted data
│   └── metadata/                      # Data descriptions and protocols
├── scripts/
│   ├── 01_data_processing.R          # Data cleaning and preprocessing
│   ├── 02_thermal_analysis.R         # TRC analysis and calculations
│   ├── 03_visualization.R            # Plotting and figures
│   └── 04_statistical_analysis.R     # Statistical tests and comparisons
├── output/
│   ├── figures/                       # Publication-ready figures
│   ├── tables/                        # Summary statistics tables
│   └── results/                       # Analysis results
├── docs/
│   ├── methods.md                     # Detailed methods
│   ├── field_protocols.md             # Field sampling protocols
│   └── data_dictionary.md             # Variable descriptions
└── literature/
    └── references.bib                 # Related publications
```

---

## 🛠️ Tools & Technologies

### Field Equipment
- Portable Chlorophyll Fluorometer (PAM)
- LI-COR Portable Photosynthesis System
- Thermocouple temperature sensors
- GPS receivers

### Analysis Software
- **R** - Primary analysis platform
- **R Packages:**
  - `tidyverse` - Data manipulation and visualization
  - `ggplot2` - Advanced graphics
  - `raster` - Spatial analysis
  - `dplyr` - Data wrangling
  - `readxl` - Excel data import
  - `nlme` - Mixed effects models
  - `fitdistrplus` - Curve fitting

### GIS & Remote Sensing
- QGIS for spatial analysis and mapping
- Sentinel-2 imagery for vegetation assessment

---

## 📊 Key Findings

### Published Work
- **Tiwari et al. (2026)** - *Decoupled phenology and PSII thermal plasticity in seasonally dry tropical forest trees.* 
  - **Journal:** Plant, Cell & Environment
  - **Status:** Under Review

### Preliminary Results
- Significant variation in thermal tolerance among tropical tree species
- Non-linear relationship between phenological timing and thermal plasticity
- Species-specific thermal optima range from 28-36°C
- Implications for climate resilience and forest composition changes under warming

---

## 📚 Data

### Data Availability
- Raw field data stored in: `data/raw/`
- Processed datasets: `data/processed/`
- All data collection followed standardized protocols documented in `docs/field_protocols.md`

### Data Description
- **Chlorophyll Fluorescence Data:** Fv/Fm, Y(II), NPQ measurements at temperature gradients
- **Gas Exchange Data:** Photosynthetic rate (Anet), stomatal conductance, transpiration
- **Leaf Traits:** Leaf area, thickness, specific leaf area (SLA)
- **Environmental Variables:** Air temperature, humidity, light intensity

---

## 🎓 Collaboration & Affiliation

### Lead Institution
- **Forestry College Ponnampet** × **ETH Zurich Collaboration**

### Research Team
- Prakash Narayanappa (Lead Researcher)
- [Collaborators and supervisors to be added]

### Contact
- **Email:** [Your contact email]
- **ORCID:** [0009-0002-5419-5192](https://orcid.org/0009-0002-5419-5192)
- **GitHub:** [@PrakashN31](https://github.com/PrakashN31)

---

## 📖 How to Use This Repository

### For Researchers
1. Review methods in `docs/methods.md` and `docs/field_protocols.md`
2. Access raw data in `data/raw/`
3. Run analysis scripts in order: `scripts/01_*.R` → `scripts/02_*.R` → etc.
4. Check `output/` for results and figures

### For Reproducibility
- All analyses are documented in R scripts with comments
- Data processing steps are transparent and version-controlled
- Results can be reproduced by running scripts sequentially
- Package versions and dependencies are documented

### For Citation
Please cite this research as:

```bibtex
@article{Tiwari2026,
  title={Decoupled phenology and PSII thermal plasticity in seasonally dry tropical forest trees},
  author={Tiwari, [et al.]},
  journal={Plant, Cell & Environment},
  year={2026},
  status={Under Review}
}
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE) - see the LICENSE file for details.

---

## 🔗 Related Projects

- [Arecanut Plantation Expansion & Carbon Storage Potential](https://github.com/PrakashN31/arecanut-carbon-storage-analysis)
- [Plant-Pollinator Network Dynamics](https://github.com/PrakashN31/plant-pollinator-network-dynamics)
- [Long-Term Ecological Monitoring (LTEM)](https://github.com/PrakashN31/ltem-kuvempu-university)
- [QGIS Ecology Workflows](https://github.com/PrakashN31/qgis-ecology-workflows)
- [R for Ecology](https://github.com/PrakashN31/r-for-ecology)

---

## 🙏 Acknowledgments

- Forestry College Ponnampet for field site access and institutional support
- ETH Zurich for research collaboration and technical guidance
- Kuvempu University for institutional affiliation
- All field assistants and research collaborators

---

## 📞 Contact & Collaboration

**Interested in collaborating or have questions?**

- 📧 Reach out via GitHub
- 🔗 [ORCID Profile](https://orcid.org/0009-0002-5419-5192)
- 🌐 [Linktree](https://linktr.ee/prakashnarayanappa9)

---

<div align="center">

**"Understanding ecosystems today to conserve landscapes for tomorrow."**

🌿 Ecology • 🌍 Conservation • 🔬 Research • 🗺️ GIS • 📡 Remote Sensing

</div>
