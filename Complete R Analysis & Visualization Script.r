# ==============================================================================
# Script Name: analyze_and_visualize.R
# Purpose: Run interaction regression and generate publication-ready plots
# ==============================================================================

# Load required libraries
library(tidyverse)
library(interactions) # Excellent package for mapping interaction terms
library(ggplot2)

# 1. READ YOUR CLEANED DATASET 
# (Ensure clean_all_africa_demographics_panel.csv is in your active folder)
panel_data <- read_csv("clean_all_africa_demographics_panel.csv")

# 2. RUN THE ESTIMATION MODEL
# ------------------------------------------------------------------------------
interaction_model <- lm(
  MMR ~ Islam * WSEI + WomenParl + log(GDPCap), 
  data = panel_data
)

# Output the statistical coefficients to the console
cat("--- REGRESSION MODEL RESULTS ---\n")
summary(interaction_model)

# 3. GRAPH 1: MARGINAL EFFECTS PLOT (The Johnson-Neyman / Slopes Plot)
# ------------------------------------------------------------------------------
# This visualizes how the effect of Islam on MMR changes as WSEI increases.
cat("\nGenerating Graph 1: Marginal Effects of Islam by WSEI...\n")

marginal_effects_plot <- jn_plot(
  model = interaction_model, 
  predictor = Islam, 
  moderator = WSEI, 
  alpha = 0.05
) +
  labs(
    title = "Marginal Effect of Islam Demography on Maternal Mortality",
    subtitle = "Evaluated across levels of Women's Structural Empowerment Index (WSEI)",
    x = "Women's Structural Empowerment Index (WSEI)",
    y = "Marginal Effect of Islam (% Population)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.minor = element_blank()
  )

# Save Graph 1 locally
ggsave("plot_marginal_effects.png", plot = marginal_effects_plot, width = 8, height = 5, dpi = 300)

# 4. GRAPH 2: INTERACTION PREDICTION SCATTER
# ------------------------------------------------------------------------------
# This plots the predicted trajectories of MMR at high, average, and low WSEI values.
cat("Generating Graph 2: Predicted Interaction Slopes...\n")

slopes_plot <- interact_plot(
  model = interaction_model, 
  pred = Islam, 
  modx = WSEI,
  modx.values = c(0.2, 0.5, 0.8), # Evaluates Low, Mid, and High empowerment contexts
  interval = TRUE,                # Adds 95% confidence intervals
  x.label = "Islamic Religious Demography (% of Population)",
  y.label = "Predicted Maternal Mortality Ratio (per 100,000 live births)"
) +
  labs(
    title = "Predicted MMR Trends by Religious Demography",
    subtitle = "Contrasted across Low (0.2), Moderate (0.5), and High (0.8) WSEI Baselines",
    legend.title = "WSEI Level"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom"
  )

# Save Graph 2 locally
ggsave("plot_interaction_slopes.png", plot = slopes_plot, width = 8, height = 5, dpi = 300)

cat("\nSuccess! Both graphics ('plot_marginal_effects.png' and 'plot_interaction_slopes.png') have been exported to your directory.\n")