
# Figure 1. Study Area Map
# Bhadra Tiger Reserve, Karnataka, India



# Load packages


library(sf)
library(terra)
library(dplyr)


# Working directory


setwd("D:/GIS/PTB Study Map")
graphics.off()


# Read India


india <- st_read(
  "Data/India boundary/ne_10m_admin_0_countries.shp",
  quiet = TRUE
)

india <- subset(india, ADMIN == "India")


# Read Karnataka


karnataka <- st_read(
  "Data/Karnataka boundary/gadm41_IND.gpkg",
  layer = "ADM_ADM_1",
  quiet = TRUE
)

karnataka <- subset(karnataka, NAME_1 == "Karnataka")


# Read Bhadra


pa <- st_read(
  "Data/Bhadra boundary/PA_TR_Corridor_Final.kml",
  quiet = TRUE
)


pa <- st_zm(pa, drop = TRUE)

bhadra <- subset(pa, Name == "Bhadra")

study_area <- bhadra


# Read Kuvempu University


ku <- st_read(
  "Data/Kuvempu University KML/Kuvempu University.kml",
  quiet = TRUE
)

ku <- st_zm(ku, drop = TRUE)


# Read Landsat LST

lst <- rast(
  "Data/LST Raster/LC08_L2SP_145051_20260408_20260416_02_T1_ST_B10.TIF"
)


# Transform to raster CRS


bhadra_utm <- st_transform(bhadra, crs(lst))
ku_utm <- st_transform(ku, crs(lst))



# Crop and mask raster


bhadra_vect <- vect(bhadra_utm)

lst_crop <- crop(lst, bhadra_vect)

lst_mask <- mask(lst_crop, bhadra_vect)


# Convert Kelvin to Celsius


lst_celsius <- (lst_mask * 0.00341802 + 149) - 273.15


# Save processed files


writeRaster(
  lst_celsius,
  "Data/LST_Bhadra_Celsius.tif",
  overwrite = TRUE
)

st_write(
  bhadra_utm,
  "Data/Bhadra_UTM.gpkg",
  delete_dsn = TRUE,
  quiet = TRUE
)

st_write(
  ku_utm,
  "Data/KU_UTM.gpkg",
  delete_dsn = TRUE,
  quiet = TRUE
)


# Export PNG


png(
  "Figure_1_Study_Area.png",
  width = 4200,
  height = 1600,
  units = "px",
  res = 600
)


par(
  mfrow = c(1,3),
  family = "sans",
  mar = c(2,2,3,2),
  oma = c(0,0,0,0),
  cex.main = 0.60
)
# Panel A


plot(
  st_geometry(india),
  col = "grey40",
  border = "grey40",
  axes = FALSE,
  main = ""
)

title(
  main = "A. Karnataka within India",
  cex.main = 1,
  font.main = 2
)


plot(
  st_geometry(karnataka),
  add = TRUE,
  col = "#66BB6A",
  border = "black",
  lwd = 1.5
)

legend(
  "bottomleft",
  legend = "Karnataka",
  fill = "#66BB6A",
  border = "black",
  bty = "n",
  cex = 0.75
)


# Panel B


plot(
  st_geometry(karnataka),
  col = "#D8F3DC",
  border = "black",
  axes = FALSE,
  main = ""
)

title(
  main = "B. Study Area in Karnataka",
  cex.main = 1,
  font.main = 2
)

plot(
  st_geometry(study_area),
  add = TRUE,
  col = adjustcolor("#2A9D8F",0.35),
  border = "black",
  lwd = 1
)

plot(
  st_geometry(ku),
  add = TRUE,
  col = adjustcolor("blue",0.60),
  border = "blue",
  lwd = 1
)

legend(
  "topleft",
  inset = c(0.02,0.03),
  legend = c("BTR","KU"),
  fill = c(
    adjustcolor("#2A9D8F",0.35),
    adjustcolor("blue",0.60)
  ),
  border = c("black","blue"),
  bty = "n",
  cex = 0.70
)


# Panel C


plot(
  lst_celsius,
  col = rev(hcl.colors(100,"Spectral")),
  axes = FALSE,
  legend = FALSE,
  main = "C. Bhadra Tiger Reserve and KU")

plot(
  st_geometry(bhadra_utm),
  add = TRUE,
  border = "black",
  lwd = 0.8
)

plot(
  st_geometry(ku_utm),
  add = TRUE,
  col = adjustcolor("blue",0.60),
  border = "blue",
  lwd = 1.5
)

legend(
  "topright",
  inset = c(0.12,0.03),
  legend = c("BTR","KU"),
  fill = c(
    adjustcolor("#2A9D8F",0.35),
    adjustcolor("blue",0.60)
  ),
  border = c("black","blue"),
  bty = "n",
  cex = 0.60
)


# Finish


par(mfrow = c(1,1))

dev.off()

graphics.off()

cat("\n----------------------------------------\n")
cat("Figure successfully created.\n")
cat("Output: Figure_1_Study_Area.png\n")
cat("----------------------------------------\n")

