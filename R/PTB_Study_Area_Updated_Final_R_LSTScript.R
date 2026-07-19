
# BHADRA TIGER RESERVE
# LAND SURFACE TEMPERATURE ANALYSIS
# By PRAKASH N

#===========================================================
# Install Packages (Run only once)
#===========================================================

# install.packages(c("sf","terra","viridisLite"))


# Load Packages


library(sf)
library(terra)
library(viridisLite)


# Set Working Directory


setwd("D:/GIS/PTB Study Map")

#===========================================================
# Create Output Folder
#===========================================================

if(!dir.exists("Outputs")){
  dir.create("Outputs")}

#===========================================================
# Read Vector Data
#===========================================================

cat("Reading vector data...\n")

india <- st_read(
  "Data/India boundary/ne_10m_admin_0_countries.shp",
  quiet = TRUE)

karnataka <- st_read(
  "Data/Karnataka boundary/gadm41_IND.gpkg",
  layer = "ADM_ADM_1",
  quiet = TRUE)

karnataka <- subset(
  karnataka,
  NAME_1=="Karnataka")

pa <- st_read(
  "Data/Bhadra boundary/PA_TR_Corridor_Final.kml",
  quiet = TRUE)

pa <- st_zm(pa,drop=TRUE)

bhadra <- subset(
  pa,
  Name=="Bhadra")

ku <- st_read(
  "Data/Kuvempu University KML/Kuvempu University.kml",
  quiet=TRUE)

ku <- st_zm(ku,drop=TRUE)

#===========================================================
# Read Raster
#===========================================================

cat("Reading Landsat raster...\n")

lst <- rast(
  "Data/LST Raster/LC08_L2SP_145051_20260408_20260416_02_T1_ST_B10.TIF")

#===========================================================
# Reproject Vector Layers
#===========================================================

cat("Projecting vector layers...\n")

bhadra_utm <- st_transform(
  bhadra,
  crs(lst))

ku_utm <- st_transform(
  ku,
  crs(lst))

bhadra_vect <- vect(bhadra_utm)

#===========================================================
# Crop Raster
#===========================================================

cat("Cropping raster...\n")

lst_crop <- crop(
  lst,
  bhadra_vect)

#===========================================================
# Mask Raster
#===========================================================

cat("Masking raster...\n")

lst_mask <- mask(
  lst_crop,
  bhadra_vect)

#===========================================================
# Convert Kelvin to Celsius
#===========================================================

cat("Converting temperature...\n")

lst_celsius <-
  (lst_mask*0.00341802+149)-273.15

#===========================================================
# Raster Statistics
#===========================================================

cat("\n")
cat("=============================\n")
cat("Raster Statistics\n")
cat("=============================\n")

min_temp <-
  global(
    lst_celsius,
    "min",
    na.rm=TRUE)

max_temp <-
  global(
    lst_celsius,
    "max",
    na.rm=TRUE)

mean_temp <-
  global(
    lst_celsius,
    "mean",
    na.rm=TRUE)

sd_temp <-
  global(
    lst_celsius,
    "sd",
    na.rm=TRUE)

print(min_temp)
print(max_temp)
print(mean_temp)
print(sd_temp)

#===========================================================
# Save Processed Raster
#===========================================================

writeRaster(
  lst_celsius,
  "Data/LST_Bhadra_Celsius.tif",
  overwrite=TRUE)

st_write(
  bhadra_utm,
  "Data/Bhadra_UTM.gpkg",
  delete_dsn=TRUE,
  quiet=TRUE)

st_write(
  ku_utm,
  "Data/KU_UTM.gpkg",
  delete_dsn=TRUE,
  quiet=TRUE)

############################################################
# EXPORT LST MAP
############################################################

png(
  "Outputs/Bhadra_LST_Map.png",
  width = 4200,
  height = 3200,
  res = 600)

par(
  mar = c(3,3,6,7),
  family = "sans")

plot(
  lst_celsius,
  col = viridis(100),
  axes = FALSE,
  legend = TRUE,
  plg = list(
    title = "LST (°C)",
    cex = 0.65),
  main = "LST of Bhadra Tiger Reserve",
  cex.main = 0.95)



## Bhadra Boundary

plot(
  st_geometry(bhadra_utm),
  add = TRUE,
  border = "black",
  lwd = 2)

## Kuvempu University Polygon

plot(
  st_geometry(ku_utm),
  add = TRUE,
  border = "black",
  col = adjustcolor("cyan",0.5),
  lwd = 1)

## KU Label

ku.xy <- st_coordinates(
  st_centroid(
    st_geometry(ku_utm)))

text(
  ku.xy[1] + 2000,
  ku.xy[2] + 2000,
  labels = "KU",
  font = 2,
  cex = 0.75,
  col ="black")

dev.off()

############################################################
# EXPORT HISTOGRAM
############################################################

temp <- values(
  lst_celsius,
  na.rm = TRUE)

png(
  "Outputs/Bhadra_LST_Distribution.png",
  width = 3000,
  height = 2200,
  res = 600)

par(
  mar = c(5,5,2,2),
  family = "sans")

hist(
  temp,
  breaks = 30,
  col = "#2C7FB8",
  border = "white",
  main = "",
  xlab = "Land Surface Temperature (°C)",
  ylab = "Frequency",
  cex.lab = 1,
  cex.axis = 1.2)

title(
  "Distribution of Land Surface Temperature",
  cex.main = 1.2,
  font.main = 2)

## Mean Line

abline(
  v = mean_temp[1,1],
  col = "red",
  lwd = 2,
  lty = 2)

text(
  mean_temp[1,1],
  par("usr")[4] * 0.86,
  labels = paste0(
    "Mean = ",
    round(mean_temp[1,1],2),
    " °C"),
  pos = 4,
  col = "red",
  cex = 0.9)

## Rug Plot

rug(
  temp,
  col = "grey50")

dev.off()

############################################################
# FINISHED
############################################################

cat("\n")
cat("======================================\n")
cat("Figures successfully exported!\n")
cat("======================================\n\n")

cat("Outputs created:\n\n")

cat("Outputs/Bhadra_LST_Map.png\n")
cat("Outputs/Bhadra_LST_Distribution.png\n")

