# STEP-BY-STEP GUIDE: Thermal Tolerance Analysis
# Complete Tutorial with Explanations
# For: Photosynthetic Heat Stress Project
# By: Prakash N31

# ============================================================================
# TABLE OF CONTENTS
# ============================================================================
# STEP 1: Understand Your Data Structure
# STEP 2: Prepare Your Raw Data
# STEP 3: Load Libraries and Import Data
# STEP 4: Explore and Visualize Raw Data
# STEP 5: Fit Sigmoid Curves (3-Parameter Logistic Model)
# STEP 6: Extract T5 and T50 Metrics
# STEP 7: Summarize Results by Species
# STEP 8: Check Statistical Assumptions
# STEP 9: Perform ANOVA Tests
# STEP 10: Post-hoc Comparisons (Tukey HSD)
# STEP 11: Linear Mixed-Effects Models
# STEP 12: Create Publication-Quality Figures
# STEP 13: Generate Summary Tables
# ============================================================================

# ============================================================================
# STEP 1: UNDERSTAND YOUR DATA STRUCTURE
# ============================================================================

# WHY THIS STEP IS IMPORTANT:
# Before you analyze, you MUST know what your data looks like.
# This prevents errors and ensures correct analysis.

# YOUR DATA SHOULD CONTAIN:
# - Column 1: tree_id (e.g., "Tree_1", "Tree_2", etc.)
#   WHY: To track which measurements come from the same tree
#        (important for mixed-effects models later)
#
# - Column 2: species (e.g., "Ziziphus xylopyrus")
#   WHY: To compare thermal tolerance across species
#
# - Column 3: temperature (e.g., 30, 35, 40, 45, 50, 55°C)
#   WHY: The X-axis of your sigmoid curve
#        These are the temperatures at which you measured injury
#
# - Column 4: injury_percent (e.g., 5, 15, 35, 65, 85, 95)
#   WHY: The Y-axis of your sigmoid curve
#        This is your response variable (0-100% scale)
#        Can also be: chlorophyll loss, photosynthesis decline, leaf damage, etc.

# EXAMPLE DATA STRUCTURE:
#   tree_id    species             temperature  injury_percent
#   Tree_1     Ziziphus xylopyrus  30           2.5
#   Tree_1     Ziziphus xylopyrus  35           4.2
#   Tree_1     Ziziphus xylopyrus  40           8.7
#   Tree_1     Ziziphus xylopyrus  45           45.3
#   Tree_1     Ziziphus xylopyrus  50           88.5
#   Tree_2     Ziziphus xylopyrus  30           3.1
#   ...and so on

# ============================================================================
# STEP 2: PREPARE YOUR RAW DATA FILE
# ============================================================================

# WHERE TO GET YOUR DATA:
# Option 1: From Excel - Your measurements from the heat stress experiment
# Option 2: From CSV file - If you already have exported data
# Option 3: From a database - If your lab uses data management software

# HOW TO FORMAT YOUR DATA (IMPORTANT!):
# 1. Create a CSV file (comma-separated values)
#    OR Excel file that you'll convert to CSV
#
# 2. Column Headers MUST be exactly:
#    tree_id, species, temperature, injury_percent
#    (R is case-sensitive, so use lowercase)
#
# 3. NO EMPTY CELLS - remove rows with missing data
#    (If you have missing values, handle them intentionally)
#
# 4. Species names must be EXACTLY as shown:
#    - Ziziphus xylopyrus
#    - Xylia xylocarpa
#    - Dalbergia latifolia
#    - Lagerstroemia lanceolata
#    - Lagerstroemia speciosa
#    - Spathodea campanulata
#    - Grewia tiliifolia
#    (Spelling matters! Check botanical names carefully)

# STEPS TO CREATE YOUR DATA FILE:
# 1. Open Excel or Google Sheets
# 2. Create 4 columns with headers: tree_id, species, temperature, injury_percent
# 3. Enter your experimental data (one row per measurement)
# 4. Save as CSV (File → Save As → Format: CSV)
# 5. Name it: "thermal_tolerance_data.csv"
# 6. Put it in your working directory (same folder as this script)

# ============================================================================
# STEP 3: LOAD LIBRARIES AND IMPORT YOUR DATA
# ============================================================================

# WHY LOAD LIBRARIES?
# Libraries are toolboxes containing specialized functions
# We need specific functions for curve fitting, statistics, and plotting

# Install libraries FIRST TIME ONLY:
# Uncomment the lines below (remove the #) if this is your first time
# install.packages("tidyverse")      # For data manipulation
# install.packages("nlme")            # For mixed-effects models
# install.packages("minpack.lm")      # For curve fitting
# install.packages("multcomp")        # For post-hoc tests
# install.packages("ggplot2")         # For beautiful plots
# install.packages("gridExtra")       # For combining plots
# install.packages("car")             # For ANOVA assumptions testing

# After installing, load the libraries:
library(tidyverse)      # Data wrangling and plotting
library(nlme)           # Linear mixed-effects models
library(minpack.lm)     # Nonlinear least squares curve fitting
library(multcomp)       # Multiple comparisons (Tukey HSD)
library(ggplot2)        # Publication-quality graphics
library(gridExtra)      # Combine multiple plots
library(car)            # Statistical tests (Levene's test)

# Set your working directory (WHERE YOUR DATA FILE IS LOCATED)
# CHANGE THIS PATH to match your computer!
# Example for Windows: "C:/Users/YourName/Documents/Thermal_Analysis"
# Example for Mac: "/Users/YourName/Documents/Thermal_Analysis"
setwd("~/Desktop/Thermal_Tolerance_Analysis")  # CHANGE THIS!

# IMPORT YOUR DATA
# Read the CSV file you created in Step 2
thermal_data <- read_csv("thermal_tolerance_data.csv")

# WHY read_csv instead of read.csv?
# read_csv is faster and handles data types better
# It's part of the tidyverse package

# ============================================================================
# STEP 4: EXPLORE AND VISUALIZE YOUR RAW DATA
# ============================================================================

# WHY EXPLORE?
# Before fitting curves, you should:
# 1. Check data integrity (no errors in entry)
# 2. Understand the range of values
# 3. Spot patterns or anomalies
# 4. Verify species names are correct

# VIEW THE FIRST FEW ROWS
head(thermal_data, 10)
# This shows the first 10 rows
# Check: Are species names spelled correctly? Are temperatures reasonable?

# VIEW DATA STRUCTURE
str(thermal_data)
# This shows: data types, number of rows, number of columns
# Check: Are numeric columns truly numeric? Are factors correct?

# SUMMARY STATISTICS
summary(thermal_data)
# This shows: min, max, median, quartiles for each column
# Check: Temperature range (should be your experimental range)
#        Injury percent range (should be 0-100 or close)

# VIEW UNIQUE SPECIES
unique(thermal_data$species)
# This shows all species in your data
# Check: Are there exactly 7 species? Correct spelling?

# COUNT MEASUREMENTS PER SPECIES AND TREE
thermal_data %>%
  group_by(species, tree_id) %>%
  summarise(n_measurements = n(), .groups = "drop") %>%
  head(20)
# This shows how many temperature points per tree
# WHY: Ensures you have enough points for curve fitting
#      (Ideally 5+ points per tree for good curves)

# PLOT RAW DATA TO VISUALIZE
ggplot(thermal_data, aes(x = temperature, y = injury_percent, color = species)) +
  geom_point(size = 3, alpha = 0.6) +
  facet_wrap(~ species) +
  labs(title = "Raw Thermal Tolerance Data",
       x = "Temperature (°C)",
       y = "Injury/Decline (%)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45))

# WHAT TO LOOK FOR:
# - Do curves look S-shaped (sigmoid)? GOOD - this is what we expect
# - Are there outliers? BAD measurements? Consider removing them
# - Is there sufficient data spread? Should have low, medium, high injury values
# - Do trees of same species show similar patterns? If very different, investigate

# ============================================================================
# STEP 5: FIT SIGMOID CURVES (3-PARAMETER LOGISTIC MODEL)
# ============================================================================

# WHAT IS A SIGMOID CURVE?
# A sigmoid (S-shaped) curve is the standard model for thermal tolerance data
# It models the response of plants to increasing temperature
# 
# At low temperatures: Low injury (near 0%)
# At medium temperatures: Rapid increase in injury (the steep part of S)
# At high temperatures: High injury plateaus (near 100%)

# THE 3-PARAMETER LOGISTIC MODEL:
# Formula: y = a / (1 + exp((x - x0) / b))
# 
# Where:
# y = injury_percent (the response)
# x = temperature (the predictor)
# a = upper asymptote (maximum injury, should be ~100)
# x0 = inflection point (temperature at 50% injury = T50)
# b = slope parameter (how steep the curve is)
#
# WHY 3 PARAMETERS?
# - a: captures how severe the injury can get
# - x0: captures the temperature threshold for injury
# - b: captures how quickly injury increases with temperature

# EXAMPLE VALUES:
# If a = 100, x0 = 45, b = 2.5:
# - At temperature 30°C: y = 100/(1+exp((30-45)/2.5)) ≈ 1.8% injury
# - At temperature 45°C: y = 100/(1+exp((45-45)/2.5)) = 50% injury
# - At temperature 60°C: y = 100/(1+exp((60-45)/2.5)) ≈ 98.2% injury

# CREATE FUNCTION TO FIT CURVES
fit_logistic_curve <- function(data_subset) {
  # WHY A FUNCTION?
  # A function lets us apply the same analysis to each tree automatically
  # Instead of copying and pasting code 21 times!
  
  tryCatch({  # tryCatch: If curve fitting fails, don't crash - report error
    
    model <- nlsLM(
      injury_percent ~ a / (1 + exp((temperature - x0) / b)),
      # nlsLM: Nonlinear Least Squares Levenberg-Marquardt algorithm
      # This finds the best-fit parameters for the sigmoid curve
      
      data = data_subset,
      # Use this subset of data (one tree at a time)
      
      start = list(a = 100, x0 = 45, b = 2),
      # STARTING VALUES: Your best guess for parameters
      # a = 100: Assume max injury is ~100%
      # x0 = 45: Guess the inflection point is ~45°C (typical for tropical plants)
      # b = 2: Guess a moderate slope
      # WHY? The algorithm needs a starting point to search from
      #      Good starting values help it converge faster
      
      lower = c(a = 50, x0 = 30, b = 0.1),
      # LOWER BOUNDS: Don't allow unrealistic values
      # a >= 50: At least some injury should occur
      # x0 >= 30: T50 shouldn't be below room temperature
      # b >= 0.1: Slope can't be zero or negative
      
      upper = c(a = 150, x0 = 60, b = 10),
      # UPPER BOUNDS: Maximum reasonable values
      # a <= 150: Injury shouldn't exceed 150%
      # x0 <= 60: T50 shouldn't be above 60°C (for tropical plants)
      # b <= 10: Slope shouldn't be extremely steep
      
      control = nls.lm.control(maxiter = 1000)
      # maxiter = 1000: Allow up to 1000 iterations to find best fit
      # If it can't fit after 1000 iterations, something is wrong with data
    )
    
    # EXTRACT THE FITTED PARAMETERS
    params <- coef(model)
    # coef extracts a, x0, b from the fitted model
    
    # CALCULATE T5 AND T50
    # T50 is simple: it's the inflection point
    T50 <- params["x0"]
    
    # T5 requires more math:
    # We want temperature where y = 5%
    # Solve: 5 = a / (1 + exp((T5 - x0) / b))
    # Math: T5 = x0 + b * log(a/5 - 1)
    # WHY LOG? Because exponential and log are inverse functions
    # This math comes from rearranging the sigmoid equation
    T5 <- params["x0"] + params["b"] * log(params["a"] / 5 - 1)
    
    return(list(
      model = model,           # The fitted model object
      params = params,         # The fitted parameters
      T5 = as.numeric(T5),     # T5 value
      T50 = as.numeric(T50),   # T50 value
      convergence = TRUE       # Flag: fitting was successful
    ))
    
  }, error = function(e) {
    # If fitting fails, return this instead of crashing
    return(list(convergence = FALSE, error = e$message))
  })
}

# APPLY THE FUNCTION TO ALL TREES
# Split data by species and tree_id, then fit each one separately
thermal_curves <- thermal_data %>%
  split(paste(.$species, .$tree_id)) %>%
  # paste creates combinations like "Ziziphus xylopyrus.Tree_1"
  # split divides data into separate chunks for each combination
  map(fit_logistic_curve)
  # map applies the function to each chunk

# CHECK WHICH TREES FITTED SUCCESSFULLY
convergence_check <- map_df(thermal_curves, function(fit) {
  tibble(
    convergence = fit$convergence,
    error = if(fit$convergence) NA_character_ else fit$error
  )
}, .id = "tree_species")

# If any have convergence = FALSE, you may need to:
# 1. Check data quality for that tree
# 2. Adjust starting values
# 3. Expand bounds
print(convergence_check)

# ============================================================================
# STEP 6: EXTRACT T5 AND T50 METRICS
# ============================================================================

# WHY EXTRACT?
# We need to get T5 and T50 values for each tree
# Then analyze if species differ in thermal tolerance

# CONVERT FITTED CURVES INTO A DATA FRAME
T5_T50_data <- bind_rows(
  map_df(thermal_curves, function(fit) {
    if (fit$convergence) {
      # Only include successful fits
      tibble(
        T5 = fit$T5,              # Temperature at 5% injury
        T50 = fit$T50,            # Temperature at 50% injury
        a = fit$params["a"],      # Upper asymptote
        x0 = fit$params["x0"],    # Inflection point
        b = fit$params["b"]       # Slope
      )
    } else {
      # Skip failed fits
      NULL
    }
  }, .id = "tree_species")
) %>%
  separate(
    tree_species, 
    into = c("species", "tree_id"), 
    sep = "\\.",      # Separate at the dot
    extra = "merge"
  ) %>%
  mutate(
    species = factor(species, levels = c(
      "Ziziphus xylopyrus",
      "Xylia xylocarpa",
      "Dalbergia latifolia",
      "Lagerstroemia lanceolata",
      "Lagerstroemia speciosa",
      "Spathodea campanulata",
      "Grewia tiliifolia"
    ))
    # factor sets the order for plots (important for consistency!)
  )

# VIEW THE EXTRACTED DATA
head(T5_T50_data, 15)

# WHAT SHOULD T5 AND T50 BE?
# T5: Usually 5-10°C lower than T50
# T50: Depends on species
#      - Tropical species: Usually 45-50°C
#      - Temperate species: Usually 40-45°C
#      - Cold-hardy species: Usually 35-40°C
# If you see values way outside these ranges, check for data errors

# ============================================================================
# STEP 7: SUMMARIZE RESULTS BY SPECIES
# ============================================================================

# WHY SUMMARIZE?
# Instead of 21 tree-level values, we want species-level summaries
# This helps answer: "Which species is most heat-tolerant?"

summary_stats <- T5_T50_data %>%
  group_by(species) %>%
  # Group by species (treat all trees of same species together)
  
  summarise(
    # CALCULATE STATISTICS FOR T5
    T5_mean = mean(T5, na.rm = TRUE),
    # Mean (average) T5 across trees
    # na.rm = TRUE: Ignore any missing values
    
    T5_sd = sd(T5, na.rm = TRUE),
    # SD (standard deviation) - spread of T5 values
    # Large SD = high variation between trees
    # Small SD = consistent trees
    
    T5_se = T5_sd / sqrt(n()),
    # SE (standard error) - uncertainty in the mean
    # Used for error bars in plots and confidence intervals
    # Formula: SD / √(sample size)
    # WHY? Larger samples give more precise mean estimates
    
    # CALCULATE STATISTICS FOR T50
    T50_mean = mean(T50, na.rm = TRUE),
    T50_sd = sd(T50, na.rm = TRUE),
    T50_se = T50_sd / sqrt(n()),
    
    # SAMPLE SIZE
    n = n(),
    # How many trees per species
    # Should be the same for all species (ideally 3 or more)
    
    .groups = "drop"
    # Drop grouping after summarise
  )

# VIEW SUMMARY
print(summary_stats)

# INTERPRETATION:
# Species with LOWER T5/T50 = LESS heat-tolerant
# Species with HIGHER T5/T50 = MORE heat-tolerant
# Species with LOWER SE = More consistent across trees
# Species with HIGHER SE = High tree-to-tree variation

# ============================================================================
# STEP 8: CHECK STATISTICAL ASSUMPTIONS
# ============================================================================

# WHY CHECK ASSUMPTIONS?
# Statistical tests (ANOVA, etc.) assume your data follows certain patterns
# If assumptions are violated, results may be unreliable
# We check: Normality and Equal Variance

# ASSUMPTION 1: NORMALITY
# Data should be approximately normally distributed (bell-shaped)
# Test: Shapiro-Wilk test
# Null hypothesis: Data ARE normally distributed
# If p-value > 0.05: Data looks normal (GOOD)
# If p-value < 0.05: Data is NOT normal (consider transformation)

print("=== NORMALITY TEST: T5 ===")
shapiro_T5 <- shapiro.test(T5_T50_data$T5)
print(shapiro_T5)
# p-value interpretation: See above

print("=== NORMALITY TEST: T50 ===")
shapiro_T50 <- shapiro.test(T5_T50_data$T50)
print(shapiro_T50)

# ASSUMPTION 2: EQUAL VARIANCE (Homogeneity)
# Each group (species) should have similar spread
# Test: Levene's test
# Null hypothesis: All groups have equal variance
# If p-value > 0.05: Variances are equal (GOOD)
# If p-value < 0.05: Variances are unequal (may need transformation)

print("=== LEVENE'S TEST: T5 ===")
levene_T5 <- car::leveneTest(T5 ~ species, data = T5_T50_data)
print(levene_T5)

print("=== LEVENE'S TEST: T50 ===")
levene_T50 <- car::leveneTest(T50 ~ species, data = T5_T50_data)
print(levene_T50)

# IF ASSUMPTIONS ARE VIOLATED:
# Option 1: Transform data (log, square root, arcsine)
# Option 2: Use non-parametric test (Kruskal-Wallis instead of ANOVA)
# For now, we'll assume assumptions are met
# If not, ask for help!

# ============================================================================
# STEP 9: PERFORM ANOVA TESTS
# ============================================================================

# WHAT IS ANOVA?
# ANOVA = Analysis of Variance
# It tests: "Are means different across groups?"
# In our case: "Do T5/T50 differ among the 7 species?"

# ANOVA NULL HYPOTHESIS:
# All species have the same mean T5 (or T50)
# If p-value > 0.05: We accept this (species are similar)
# If p-value < 0.05: We reject this (species ARE different) ← This is what we want!

# ONE-WAY ANOVA FOR T5
aov_T5 <- aov(T5 ~ species, data = T5_T50_data)
# aov = Analysis of Variance function
# T5 ~ species: Predict T5 based on species membership

print("=== ONE-WAY ANOVA: T5 ~ Species ===")
anova_results_T5 <- summary(aov_T5)
print(anova_results_T5)

# INTERPRETING ANOVA OUTPUT:
# Df (Degrees of Freedom): 6 for species (7 groups - 1)
# Sum Sq (Sum of Squares): Total variation explained
# Mean Sq (Mean Square): Sum Sq / Df
# F value: How different species are (higher = more different)
# Pr(>F): The p-value!
#   p < 0.05: Species significantly different ✓
#   p > 0.05: Species NOT significantly different ✗

# ONE-WAY ANOVA FOR T50
aov_T50 <- aov(T50 ~ species, data = T5_T50_data)

print("=== ONE-WAY ANOVA: T50 ~ Species ===")
anova_results_T50 <- summary(aov_T50)
print(anova_results_T50)

# ============================================================================
# STEP 10: POST-HOC COMPARISONS (TUKEY HSD TEST)
# ============================================================================

# WHY POST-HOC?
# ANOVA tells us: "Species differ"
# But not: "Which species differ from which?"
# Tukey HSD answers: "Which pairwise comparisons are significant?"

# TUKEY HSD FOR T5
print("=== TUKEY HSD TEST: T5 ===")
tukey_T5 <- TukeyHSD(aov_T5)
print(tukey_T5)

# INTERPRETING TUKEY OUTPUT:
# For each pair of species:
# diff: Difference in mean T5
# lwr: Lower limit of confidence interval
# upr: Upper limit of confidence interval
# p adj: Adjusted p-value (accounts for multiple comparisons)
# 
# If p adj < 0.05: Species pair is significantly different
# If confidence interval (lwr-upr) doesn't include 0: Significant
# If confidence interval includes 0: NOT significant

# TUKEY HSD FOR T50
print("=== TUKEY HSD TEST: T50 ===")
tukey_T50 <- TukeyHSD(aov_T50)
print(tukey_T50)

# EXAMPLE INTERPRETATION:
# "Ziziphus xylopyrus - Spathodea campanulata"
# diff = -2.5 (Spathodea has T50 2.5°C higher than Ziziphus)
# p adj = 0.032 (significant, p < 0.05)
# Conclusion: Spathodea is significantly more heat-tolerant

# ============================================================================
# STEP 11: LINEAR MIXED-EFFECTS MODELS (Advanced)
# ============================================================================

# WHY MIXED-EFFECTS MODELS?
# ANOVA treats each tree independently
# Mixed models account for: Trees are nested within species
# This is more appropriate for hierarchical data structure

# FIXED vs RANDOM EFFECTS:
# Fixed effect (species): We're interested in species differences
# Random effect (tree): Trees are just a sample; we're not interested in
#                       Tree_1 specifically, just accounting for tree variation

# MODEL FORMULA: T5 ~ Species + (1|Tree)
# T5: Response variable
# Species: Fixed effect (what we're testing)
# (1|Tree): Random intercept by tree
#   (1|...): means random intercept
#   ...| Tree: grouped by Tree ID

lme_T5 <- nlme::lme(
  T5 ~ species,                    # Fixed effects
  random = ~ 1 | tree_id,          # Random intercept by tree
  data = T5_T50_data
)

print("=== MIXED-EFFECTS MODEL: T5 ~ Species + (1|Tree) ===")
summary(lme_T5)

# OUTPUT INTERPRETATION:
# Fixed effects: Coefficients for each species
#   Intercept: Reference species mean
#   Species2, Species3, etc.: Difference from reference
# Random effects: Variation by tree
#   StdDev: How much trees vary around species mean

lme_T50 <- nlme::lme(
  T50 ~ species,
  random = ~ 1 | tree_id,
  data = T5_T50_data
)

print("=== MIXED-EFFECTS MODEL: T50 ~ Species + (1|Tree) ===")
summary(lme_T50)

# WHY USE MIXED MODELS?
# More realistic for experimental design
# Accounts for tree-level variation
# More statistically powerful
# Better for repeated measures

# ============================================================================
# STEP 12: CREATE PUBLICATION-QUALITY FIGURES
# ============================================================================

# WHY FIGURES?
# A picture is worth a thousand words
# Figures communicate results to reviewers and readers
# We'll create two types: Curves and Boxplots

# FIGURE 1: SIGMOID CURVES WITH T5 AND T50 MARKED

# First, calculate average parameters per species for smooth curves
avg_params <- T5_T50_data %>%
  group_by(species) %>%
  summarise(
    a_mean = mean(a, na.rm = TRUE),
    x0_mean = mean(x0, na.rm = TRUE),
    b_mean = mean(b, na.rm = TRUE),
    T5_mean = mean(T5, na.rm = TRUE),
    T50_mean = mean(T50, na.rm = TRUE),
    .groups = "drop"
  )
# WHY AVERAGE?
# Smooth curves are easier to interpret than individual noisy curves
# Averaging parameters creates representative curves for each species

# Create a grid of temperature values for smooth curves
prediction_data <- expand_grid(
  species = unique(T5_T50_data$species),
  # All species
  temperature = seq(30, 55, by = 0.5)
  # Temperature range in 0.5°C increments
)

# Generate predicted injury values using average parameters
prediction_curves <- prediction_data %>%
  left_join(avg_params, by = "species") %>%
  mutate(
    injury_percent = a_mean / (1 + exp((temperature - x0_mean) / b_mean))
    # Apply sigmoid formula with average parameters
  )

# CREATE THE PLOT
p_curves <- ggplot() +
  # Layer 1: Raw data points
  geom_point(
    data = thermal_data,
    aes(x = temperature, y = injury_percent, color = species),
    alpha = 0.4, size = 2
  ) +
  # WHY ALPHA? Makes overlapping points visible
  # WHY SIZE? Makes points visible in print
  
  # Layer 2: Fitted sigmoid curves
  geom_line(
    data = prediction_curves,
    aes(x = temperature, y = injury_percent, color = species),
    size = 1
  ) +
  # SIZE = 1: Line thickness for visibility
  
  # Layer 3: Mark T5 (dashed vertical line)
  geom_vline(
    data = avg_params,
    aes(xintercept = T5_mean, color = species),
    linetype = "dashed", alpha = 0.7, size = 0.8
  ) +
  # Dashed line = easier to distinguish from T50
  
  # Layer 4: Mark T50 (solid vertical line)
  geom_vline(
    data = avg_params,
    aes(xintercept = T50_mean, color = species),
    linetype = "solid", alpha = 0.9, size = 1
  ) +
  # Solid line = standard for important values
  
  # Separate plot for each species
  facet_wrap(~ species, nrow = 2) +
  
  # Labels
  labs(
    title = "Thermal Tolerance Curves: 3-Parameter Logistic Model",
    subtitle = "Dashed line = T5 (5% injury); Solid line = T50 (50% injury)",
    x = "Temperature (°C)",
    y = "Injury/Decline (%)",
    color = "Species"
  ) +
  
  # Clean theme
  theme_minimal() +
  theme(
    legend.position = "bottom",
    strip.text = element_text(face = "italic"),  # Species names in italics
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

print(p_curves)
# Save to file
ggsave(
  "Figure_1_Sigmoid_Curves.png",
  p_curves,
  width = 14, height = 10, dpi = 300
)
# WHY 300 DPI? Publication standard (journals require this)

# FIGURE 2: BOXPLOTS OF T5 AND T50

p_T5_box <- ggplot(T5_T50_data, aes(x = species, y = T5, fill = species)) +
  geom_boxplot(alpha = 0.7) +
  # Box = middle 50% of data
  # Line in box = median
  # Whiskers = range of data
  # Points beyond whiskers = outliers
  
  geom_jitter(width = 0.2, alpha = 0.5, size = 2) +
  # Add individual points with jitter (so they don't overlap)
  # Shows the actual tree measurements
  
  labs(
    title = "T5 Distribution by Species",
    x = "Species",
    y = "T5 (°C)",
    fill = "Species"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, face = "italic"),
    legend.position = "none"  # Remove legend (species names on x-axis)
  )

p_T50_box <- ggplot(T5_T50_data, aes(x = species, y = T50, fill = species)) +
  geom_boxplot(alpha = 0.7) +
  geom_jitter(width = 0.2, alpha = 0.5, size = 2) +
  labs(
    title = "T50 Distribution by Species",
    x = "Species",
    y = "T50 (°C)",
    fill = "Species"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, face = "italic"),
    legend.position = "none"
  )

# Combine both boxplots side-by-side
p_boxes <- gridExtra::grid.arrange(p_T5_box, p_T50_box, nrow = 1)
print(p_boxes)

# Save to file
ggsave(
  "Figure_2_Boxplots.png",
  p_boxes,
  width = 12, height = 6, dpi = 300
)

# ============================================================================
# STEP 13: GENERATE SUMMARY TABLES
# ============================================================================

# WHY TABLES?
# Tables provide exact numbers for readers
# Plots show patterns; tables show precision

# CREATE PUBLICATION TABLE (Mean ± SE format)
publication_table <- summary_stats %>%
  mutate(
    # Format as "mean ± SE" (standard in publications)
    T5_display = sprintf("%.2f ± %.2f", T5_mean, T5_se),
    T50_display = sprintf("%.2f ± %.2f", T50_mean, T50_se),
    Species = species
  ) %>%
  select(Species, n, T5_display, T50_display) %>%
  rename(
    "n (trees)" = n,
    "T5 (°C)" = T5_display,
    "T50 (°C)" = T50_display
  )

print("=== SUMMARY TABLE FOR PUBLICATION ===")
print(publication_table)

# SAVE TABLES TO CSV FILES
# WHY CSV? Can be opened in Excel, easy to share

# Table 1: Summary statistics
write_csv(publication_table, "Table_1_Summary_Statistics.csv")

# Table 2: Raw extracted metrics (all tree-level values)
write_csv(T5_T50_data, "Table_2_Raw_Metrics_T5_T50.csv")

# ============================================================================
# STEP 14: ORGANIZE YOUR RESULTS AND CONCLUSIONS
# ============================================================================

# CREATE A SUMMARY OF YOUR FINDINGS
cat("\n\n===============================================\n")
cat("THERMAL TOLERANCE ANALYSIS SUMMARY\n")
cat("===============================================\n\n")

cat("1. SPECIES RANKING BY T50 (from highest to lowest):\n")
ranking <- summary_stats %>%
  arrange(desc(T50_mean)) %>%
  mutate(rank = row_number()) %>%
  select(rank, species, T50_mean, T50_se)
print(ranking)
cat("\nInterpretation: Species with higher T50 are more heat-tolerant\n\n")

cat("2. SPECIES RANKING BY T5 (from highest to lowest):\n")
ranking_T5 <- summary_stats %>%
  arrange(desc(T5_mean)) %>%
  mutate(rank = row_number()) %>%
  select(rank, species, T5_mean, T5_se)
print(ranking_T5)
cat("\nInterpretation: Species with higher T5 tolerate injury threshold at higher temperature\n\n")

cat("3. ANOVA RESULTS:\n")
cat("T5 differences among species: p-value = ",
    anova_results_T5[[1]][1, 5], "\n")
cat("T50 differences among species: p-value = ",
    anova_results_T50[[1]][1, 5], "\n")
cat("(p < 0.05 means species are significantly different)\n\n")

cat("4. KEY FINDINGS FROM TUKEY HSD:\n")
cat("(Significant pairwise comparisons - p < 0.05)\n")
tukey_T50_mat <- tukey_T50$species
sig_pairs <- which(tukey_T50_mat[, "p adj"] < 0.05)
if(length(sig_pairs) > 0) {
  print(tukey_T50_mat[sig_pairs, ])
} else {
  cat("No significant pairwise differences at p < 0.05\n")
}

cat("\n===============================================\n\n")

# ============================================================================
# COMMON PROBLEMS AND SOLUTIONS
# ============================================================================

# PROBLEM 1: Curve fitting fails for a tree
# SYMPTOMS: convergence = FALSE
# SOLUTIONS:
# a) Check data quality - are there enough points? Do values look realistic?
# b) Adjust starting values - try different initial guesses
# c) Expand bounds - maybe realistic values are outside our bounds
# d) Remove outliers - check for measurement errors

# PROBLEM 2: T5 is higher than T50 (doesn't make sense!)
# SYMPTOMS: T5 > T50
# SOLUTIONS:
# a) Check curve parameters - is 'b' very large (flat curve)?
# b) Check raw data - do actual injury values plateau early?
# c) Try log-transforming injury_percent
# d) May indicate poor curve fit - remove this tree from analysis

# PROBLEM 3: ANOVA shows no significant differences
# SYMPTOMS: p-value > 0.05
# SOLUTIONS:
# a) Is sample size too small? Need n ≥ 3 trees per species ideally
# b) Is variation too high? Check boxplots
# c) Try mixed-effects model instead (more powerful)
# d) Consider combining similar species?

# PROBLEM 4: Boxplots look weird (very skewed)
# SYMPTOMS: Outliers, unequal variances
# SOLUTIONS:
# a) Check assumptions - run Levene's test
# b) Transform data - try log transformation
# c) Use non-parametric test - Kruskal-Wallis
# d) Remove outliers if they're measurement errors

# PROBLEM 5: Can't install packages
# SYMPTOMS: Error message about dependencies
# SOLUTIONS:
# a) Update R to latest version
# b) Update RStudio
# c) Try: install.packages("PackageName", dependencies=TRUE)
# d) May need to install dependencies manually

# ============================================================================
# CHECKLIST: BEFORE SUBMITTING YOUR ANALYSIS
# ============================================================================

# Run through this checklist:
# □ Data file loaded successfully
# □ All 7 species present
# □ n ≥ 3 trees per species
# □ No empty cells or errors
# □ Curves fit successfully (check convergence)
# □ T5 < T50 for all trees
# □ ANOVA assumptions checked
# □ Figures created and saved at 300 DPI
# □ Tables created and saved as CSV
# □ Results make biological sense
# □ Code is commented and reproducible
# □ Session info captured (see below)

# ============================================================================
# FINAL: SAVE SESSION INFORMATION
# ============================================================================

# WHY SESSION INFO?
# Ensures reproducibility - records R version, packages, etc.

sessionInfo()
# This prints version of R, all loaded packages, and their versions
# Save this when publishing results!

cat("\n\nAnalysis completed successfully!\n")
cat("Check your working directory for output files:\n")
cat("- Figure_1_Sigmoid_Curves.png\n")
cat("- Figure_2_Boxplots.png\n")
cat("- Table_1_Summary_Statistics.csv\n")
cat("- Table_2_Raw_Metrics_T5_T50.csv\n")

# ============================================================================
# END OF TUTORIAL
# ============================================================================
