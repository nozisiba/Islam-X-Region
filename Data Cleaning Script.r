# ==============================================================================
# Script Name: clean_and_analyze_pan_africa.R
# Purpose: Compile 2000-2020 cross-sectional annual panels for individual 
#          African nations using strictly uploaded source layers.
# ==============================================================================

library(tidyverse)
library(zoo)

# 1. LOAD RAW DATA LAYERS
# ------------------------------------------------------------------------------
mmr_raw   <- read_csv("mmr worldbank.xls - Data.csv", skip = 3)
gdp_raw   <- read_csv("gdp.xls - Data.csv", skip = 3)
parl_raw  <- read_csv("parl.xls - Data.csv", skip = 3)
islam_raw <- read_csv("Africa Islam Demographics Annual Panel (2000-2020).xlsx - Africa Islam Demographics Annua.csv")
edu_raw   <- read_csv("education.zip/API_SE.SEC.CUAT.UP.FE.ZS_DS2_en_csv_v2_264121.csv", skip = 4)
labor_raw <- read_csv("labour force.zip/API_SL.TLF.ACTI.1524.FE.ZS_DS2_en_csv_v2_260979.csv", skip = 4)
meta_raw  <- read_csv("gdp.xls - Metadata - Countries.csv")

# Identify total tracking scope across both Sub-Saharan and North African sets
target_isos <- islam_raw$ISO

africa_meta <- meta_raw %>%
  filter(`Country Code` %in% target_isos) %>%
  select(`Country Code`, Region)

# 2. HELPER TO PIVOT HORIZONTAL YEAR COLUMNS INTO INDIVIDUAL ROWS
# ------------------------------------------------------------------------------
pivot_panel_years <- function(df, column_metric_name) {
  df %>%
    filter(`Country Code` %in% target_isos) %>%
    select(`Country Name`, `Country Code`, as.character(2000:2020)) %>%
    pivot_longer(cols = as.character(2000:2020), names_to = "Year", values_to = column_metric_name) %>%
    mutate(Year = as.integer(Year))
}

# 3. CONVERT ALL LAYERS
# ------------------------------------------------------------------------------
mmr_long   <- pivot_panel_years(mmr_raw, "MMR")
gdp_long   <- pivot_panel_years(gdp_raw, "GDPCap")
parl_long  <- pivot_panel_years(parl_raw, "WomenParl")
edu_long   <- pivot_panel_years(edu_raw, "EduAttainment")
labor_long <- pivot_panel_years(labor_raw, "LaborForce")

islam_long <- islam_raw %>%
  pivot_longer(cols = as.character(2000:2020), names_to = "Year", values_to = "Islam") %>%
  mutate(Year = as.integer(Year)) %>%
  select(ISO, Year, Islam)

# 4. JOIN LAYERS INTO A COMPREHENSIVE PANEL
# ------------------------------------------------------------------------------
master_panel <- mmr_long %>%
  left_join(gdp_long,   by = c("Country Code", "Year")) %>%
  left_join(parl_long,  by = c("Country Code", "Year")) %>%
  left_join(edu_long,   by = c("Country Code", "Year")) %>%
  left_join(labor_long, by = c("Country Code", "Year")) %>%
  left_join(islam_long, by = c("Country Code" = "ISO", "Year")) %>%
  left_join(africa_meta, by = "Country Code") %>%
  rename(Country = `Country Name`, ISO = `Country Code`)

# 5. SCALE COMPONENTS NATIVELY AND HANDLE SPARE VALUES
# ------------------------------------------------------------------------------
min_max_norm <- function(x) {
  if(all(is.na(x))) return(NA)
  (x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
}

clean_dataset <- master_panel %>%
  group_by(ISO) %>%
  mutate(
    EduAttainment = na.approx(EduAttainment, na.rm = FALSE),
    LaborForce    = na.approx(LaborForce, na.rm = FALSE)
  ) %>%
  fill(EduAttainment, LaborForce, .direction = "downup") %>%
  ungroup() %>%
  filter(!is.na(EduAttainment), !is.na(LaborForce), !is.na(MMR)) %>%
  mutate(
    WSEI = (min_max_norm(EduAttainment) + min_max_norm(LaborForce)) / 2
  ) %>%
  select(Country, ISO, Region, Year, MMR, Islam, WSEI, WomenParl, GDPCap)

# Save file directly
write_csv(clean_dataset, "clean_all_africa_demographics_panel.csv")

# 6. ESTIMATE INTERACTION SPECIFICATION
# ------------------------------------------------------------------------------
model <- lm(MMR ~ Islam * WSEI + WomenParl + log(GDPCap), data = clean_dataset)
summary(model)
