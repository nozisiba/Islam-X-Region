# ==============================================================================
# Script Name: advanced_econometric_analysis.R
# Purpose: Advanced Panel Diagnostics, Fixed Effects Interaction, & Robust Estimation
# ==============================================================================

# 1. INSTALL AND LOAD REQUIRED PACKAGES
# ------------------------------------------------------------------------------
required_packages <- c("tidyverse", "plm", "lmtest", "sandwich", "interactions", "ggplot2")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

library(tidyverse)
library(plm)         # Core package for panel data econometrics
library(lmtest)      # For diagnostic testing
library(sandwich)    # For robust standard errors
library(interactions)
library(ggplot2)

# 2. READ AND SET UP PANEL DATA STRUCTURE
# ------------------------------------------------------------------------------
data_panel <- read_csv("clean_all_africa_demographics_panel.csv")

# Explicitly define the panel dimensions (individual country = ISO, time = Year)
p_data <- pdata.frame(data_panel, index = c("ISO", "Year"))

# 3. ESTIMATE COMPETING PANEL MODELS
# ------------------------------------------------------------------------------
# Model A: Pooled OLS (Baseline)
pooled_ols <- plm(MMR ~ Islam * WSEI + WomenParl + log(GDPCap), data = p_data, model = "pooling")

# Model B: Fixed Effects (Within Country Transformation)
fixed_effects <- plm(MMR ~ Islam * WSEI + WomenParl + log(GDPCap), data = p_data, model = "within")

# Model C: Random Effects
random_effects <- plm(MMR ~ Islam * WSEI + WomenParl + log(GDPCap), data = p_data, model = "random")

# 4. RUN ECONOMETRIC DIAGNOSTIC CHECKS
# ------------------------------------------------------------------------------
cat("\n=========================================\n")
cat("      ECONOMETRIC DIAGNOSTIC TESTS       \n")
cat("=========================================\n")

# Test 1: Hausman Test (Fixed Effects vs. Random Effects)
hausman_result <- phtest(fixed_effects, random_effects)
cat("\n--- 1. Hausman Test Result ---\n")
print(hausman_result)
cat("Interpretation: If p-value < 0.05, reject Random Effects in favor of Country Fixed Effects.\n")

# Test 2: Wooldridge Test for Serial Correlation in Panel Data
serial_result <- pbgtest(fixed_effects)
cat("\n--- 2. Wooldridge Test for Autocorrelation ---\n")
print(serial_result)

# Test 3: Breusch-Pagan Test for Heteroskedasticity
bptest_result <- bptest(MMR ~ Islam * WSEI + WomenParl + log(GDPCap), data = p_data)
cat("\n--- 3. Breusch-Pagan Test for Heteroskedasticity ---\n")
print(bptest_result)

# 5. GENERATE FINAL ROBUST ESTIMATION MATRIX
# ------------------------------------------------------------------------------
cat("\n=========================================\n")
cat("   ROBUST COUNTRY-CLUSTERED ESTIMATES    \n")
cat("=========================================\n")

# Calculate coefficients with standard errors clustered tightly at the individual country level (ISO)
robust_fe_summary <- coeftest(fixed_effects, vcov = vcovHC(fixed_effects, type = "HC1", cluster = "group"))
print(robust_fe_summary)

# 6. GRAPH: MARGINAL EFFECTS UNDER FIXED EFFECTS
# ------------------------------------------------------------------------------
cat("\nGenerating and exporting final visualization plots...\n")

# Constructing an analytical interaction visualization mapping 
final_interaction_plot <- interact_plot(
  model = fixed_effects, 
  pred = Islam, 
  modx = WSEI, 
  modx.values = c(0.15, 0.50, 0.85),
  interval = TRUE,
  x.label = "Islamic Religious Demography (% of Population)",
  y.label = "Maternal Mortality Ratio (per 100,000 live births)"
) +
  labs(
    title = "Conditioning Effects of Women's Structural Empowerment (WSEI)",
    subtitle = "Maternal Mortality Predicted Values under Country Fixed Effects Estimation",
    caption = "Data Source: Strictly Compiled From Uploaded World Bank & ARDA Registry Sheets"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    legend.position = "bottom"
  )

ggsave("final_robust_interaction_slopes.png", plot = final_interaction_plot, width = 8, height = 5, dpi = 300)
cat("Success! 'final_robust_interaction_slopes.png' has been saved to your directory.\n")