# Thermal Tolerance Analysis for Tree Species
# Analysis of T5 and T50 metrics using sigmoid (3-parameter logistic) curves
# 
# Species: Ziziphus xylopyrus, Xylia xylocarpa, Dalbergia latifolia,
#          Lagerstroemia lanceolata, Lagerstroemia speciosa, 
#          Spathodea campanulata, Grewia tiliifolia

# Load required libraries
library(tidyverse)
library(nlme)
library(minpack.lm)
library(multcomp)
library(ggplot2)
library(gridExtra)

# ============================================================================
# 1. DATA PREPARATION
# ============================================================================

# Create sample data structure (replace with your actual data)
# Expected columns: tree_id, species, temperature, injury_percent
# injury_percent should be 0-100 scale or 0-1 scale

set.seed(42)
species_list <- c("Ziziphus xylopyrus", 
                  "Xylia xylocarpa", 
                  "Dalbergia latifolia",
                  "Lagerstroemia lanceolata", 
                  "Lagerstroemia speciosa",
                  "Spathodea campanulata", 
                  "Grewia tiliifolia")

# Generate example data (replace with your actual thermal tolerance data)
thermal_data <- expand_grid(
  tree_id = paste0("Tree_", 1:3),  # 3 replicate trees per species
  species = species_list,
  temperature = seq(30, 55, by = 1)
) %>%
  mutate(
    # Simulate realistic sigmoid curves with species-specific parameters
    injury_percent = case_when(
      species == "Ziziphus xylopyrus" ~ 100 / (1 + exp((temperature - 45) / 2.5)),
      species == "Xylia xylocarpa" ~ 100 / (1 + exp((temperature - 46) / 2.3)),
      species == "Dalbergia latifolia" ~ 100 / (1 + exp((temperature - 43) / 2.2)),
      species == "Lagerstroemia lanceolata" ~ 100 / (1 + exp((temperature - 44) / 2.4)),
      species == "Lagerstroemia speciosa" ~ 100 / (1 + exp((temperature - 47) / 2.5)),
      species == "Spathodea campanulata" ~ 100 / (1 + exp((temperature - 48) / 2.3)),
      species == "Grewia tiliifolia" ~ 100 / (1 + exp((temperature - 42) / 2.1)),
      TRUE ~ NA_real_
    ),
    # Add measurement noise
    injury_percent = injury_percent + rnorm(n(), mean = 0, sd = 3),
    injury_percent = pmax(0, pmin(100, injury_percent))  # Constrain to 0-100
  ) %>%
  arrange(species, tree_id, temperature)

# View data structure
head(thermal_data, 15)
str(thermal_data)

# ============================================================================
# 2. FIT SIGMOID (3-PARAMETER LOGISTIC) CURVES FOR EACH TREE
# ============================================================================

# 3-parameter logistic model: y = a / (1 + exp((x - x0) / b))
# where: a = upper asymptote, x0 = inflection point, b = slope

# Function to fit logistic curve to a single tree's data
fit_logistic_curve <- function(data_subset) {
  tryCatch({
    model <- nlsLM(
      injury_percent ~ a / (1 + exp((temperature - x0) / b)),
      data = data_subset,
      start = list(a = 100, x0 = 45, b = 2),
      lower = c(a = 50, x0 = 30, b = 0.1),
      upper = c(a = 150, x0 = 60, b = 10),
      control = nls.lm.control(maxiter = 1000)
    )
    
    # Extract parameters
    params <- coef(model)
    
    # Calculate T5 and T50
    # T5: temperature where injury = 5%
    # T50: temperature where injury = 50% (inflection point ≈ x0)
    T5 <- params["x0"] + params["b"] * log(params["a"] / 5 - 1)
    T50 <- params["x0"]  # Inflection point
    
    return(list(
      model = model,
      params = params,
      T5 = as.numeric(T5),
      T50 = as.numeric(T50),
      convergence = TRUE
    ))
  }, error = function(e) {
    return(list(convergence = FALSE, error = e$message))
  })
}

# Fit curves for each tree
thermal_curves <- thermal_data %>%
  split(paste(.$species, .$tree_id)) %>%
  map(fit_logistic_curve)

# Extract T5 and T50 for each tree
T5_T50_data <- bind_rows(
  map_df(thermal_curves, function(fit) {
    if (fit$convergence) {
      tibble(
        T5 = fit$T5,
        T50 = fit$T50,
        a = fit$params["a"],
        x0 = fit$params["x0"],
        b = fit$params["b"]
      )
    }
  }, .id = "tree_species")
) %>%
  separate(tree_species, into = c("species", "tree_id"), sep = "\\.", extra = "merge") %>%
  mutate(
    species = factor(species, levels = species_list)
  )

# View extracted metrics
head(T5_T50_data, 10)

# ============================================================================
# 3. SUMMARY STATISTICS BY SPECIES
# ============================================================================

summary_stats <- T5_T50_data %>%
  group_by(species) %>%
  summarise(
    # T5 statistics
    T5_mean = mean(T5, na.rm = TRUE),
    T5_sd = sd(T5, na.rm = TRUE),
    T5_se = T5_sd / sqrt(n()),
    
    # T50 statistics
    T50_mean = mean(T50, na.rm = TRUE),
    T50_sd = sd(T50, na.rm = TRUE),
    T50_se = T50_sd / sqrt(n()),
    
    # Sample size
    n = n(),
    .groups = "drop"
  )

print("Summary Statistics by Species:")
print(summary_stats)

# ============================================================================
# 4. ONE-WAY ANOVA: Species effect on T5 and T50
# ============================================================================

# Check assumptions
# Normality test
print("\n=== NORMALITY TESTS ===")
print("T5 Shapiro-Wilk test:")
print(shapiro.test(T5_T50_data$T5))
print("T50 Shapiro-Wilk test:")
print(shapiro.test(T5_T50_data$T50))

# Homogeneity of variance
print("\n=== HOMOGENEITY OF VARIANCE (Levene's test) ===")
print("T5:")
print(car::leveneTest(T5 ~ species, data = T5_T50_data))
print("T50:")
print(car::leveneTest(T50 ~ species, data = T5_T50_data))

# One-way ANOVA for T5
aov_T5 <- aov(T5 ~ species, data = T5_T50_data)
print("\n=== ONE-WAY ANOVA: T5 ~ Species ===")
print(summary(aov_T5))

# One-way ANOVA for T50
aov_T50 <- aov(T50 ~ species, data = T5_T50_data)
print("\n=== ONE-WAY ANOVA: T50 ~ Species ===")
print(summary(aov_T50))

# ============================================================================
# 5. TUKEY'S HSD POST-HOC TEST
# ============================================================================

print("\n=== TUKEY'S HSD: T5 ===")
tukey_T5 <- TukeyHSD(aov_T5)
print(tukey_T5)

print("\n=== TUKEY'S HSD: T50 ===")
tukey_T50 <- TukeyHSD(aov_T50)
print(tukey_T50)

# ============================================================================
# 6. LINEAR MIXED-EFFECTS MODELS (if appropriate for your design)
# ============================================================================

# Model with species as fixed effect and tree as random effect
lme_T5 <- lme(T5 ~ species, 
              random = ~ 1 | tree_id,
              data = T5_T50_data)

lme_T50 <- lme(T50 ~ species, 
               random = ~ 1 | tree_id,
               data = T5_T50_data)

print("\n=== LINEAR MIXED-EFFECTS MODEL: T5 ~ Species + (1|Tree) ===")
print(summary(lme_T5))

print("\n=== LINEAR MIXED-EFFECTS MODEL: T50 ~ Species + (1|Tree) ===")
print(summary(lme_T50))

# ============================================================================
# 7. VISUALIZATION: SIGMOID CURVES WITH T5 AND T50 MARKED
# ============================================================================

# Generate smooth prediction curves for each species
species_to_plot <- species_list
prediction_data <- expand_grid(
  species = species_to_plot,
  temperature = seq(30, 55, by = 0.5)
)

# Use average parameters per species for smooth curves
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

prediction_curves <- prediction_data %>%
  left_join(avg_params, by = "species") %>%
  mutate(
    injury_percent = a_mean / (1 + exp((temperature - x0_mean) / b_mean))
  )

# Plot sigmoid curves
p_curves <- ggplot() +
  # Raw data points
  geom_point(data = thermal_data, 
             aes(x = temperature, y = injury_percent, color = species),
             alpha = 0.4, size = 2) +
  # Fitted curves
  geom_line(data = prediction_curves, 
            aes(x = temperature, y = injury_percent, color = species),
            size = 1) +
  # Mark T5
  geom_vline(data = avg_params, 
             aes(xintercept = T5_mean, color = species),
             linetype = "dashed", alpha = 0.7, size = 0.8) +
  # Mark T50
  geom_vline(data = avg_params, 
             aes(xintercept = T50_mean, color = species),
             linetype = "solid", alpha = 0.9, size = 1) +
  facet_wrap(~ species, nrow = 2) +
  labs(
    title = "Thermal Tolerance Curves (3-Parameter Logistic Model)",
    subtitle = "Dashed line = T5 (5% injury); Solid line = T50 (50% injury)",
    x = "Temperature (°C)",
    y = "Injury/Decline (%)",
    color = "Species"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    strip.text = element_text(face = "italic"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

print(p_curves)
ggsave("01_sigmoid_curves.png", p_curves, width = 14, height = 10, dpi = 300)

# ============================================================================
# 8. VISUALIZATION: BOXPLOTS OF T5 AND T50
# ============================================================================

p_T5_box <- ggplot(T5_T50_data, aes(x = species, y = T5, fill = species)) +
  geom_boxplot(alpha = 0.7) +
  geom_jitter(width = 0.2, alpha = 0.5, size = 2) +
  labs(
    title = "T5 (5% Injury Temperature) by Species",
    x = "Species",
    y = "T5 (°C)",
    fill = "Species"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, face = "italic"),
    legend.position = "none"
  )

p_T50_box <- ggplot(T5_T50_data, aes(x = species, y = T50, fill = species)) +
  geom_boxplot(alpha = 0.7) +
  geom_jitter(width = 0.2, alpha = 0.5, size = 2) +
  labs(
    title = "T50 (50% Injury Temperature) by Species",
    x = "Species",
    y = "T50 (°C)",
    fill = "Species"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, face = "italic"),
    legend.position = "none"
  )

p_boxes <- gridExtra::grid.arrange(p_T5_box, p_T50_box, nrow = 1)
print(p_boxes)
ggsave("02_boxplots_T5_T50.png", p_boxes, width = 12, height = 6, dpi = 300)

# ============================================================================
# 9. CREATE SUMMARY TABLE FOR PUBLICATION
# ============================================================================

publication_table <- summary_stats %>%
  mutate(
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

print("\n=== SUMMARY TABLE FOR PUBLICATION ===")
print(publication_table)

# Save to CSV
write_csv(publication_table, "thermal_tolerance_summary.csv")
write_csv(T5_T50_data, "thermal_tolerance_raw_metrics.csv")

# ============================================================================
# 10. SESSION INFO
# ============================================================================

print("\n=== SESSION INFO ===")
sessionInfo()
