library(tidyverse)
library(lubridate) # For working with dates
library(scales)    # For nice plot labels

# --- 2. Load the Data ---
# This is the merged file from Task 1, or the QVI_data.csv
full_data <- read_csv("QVI_data.csv") %>%
  mutate(
    # Ensure DATE is in Date format
    DATE = as.Date(DATE)
  )

# --- 3. Aggregate Data to Monthly Metrics ---
# We need to create the key metrics for *all* stores by month.
# We'll create a YEAR_MONTH column.
monthly_metrics <- full_data %>%
  mutate(
    YEAR_MONTH = floor_date(DATE, "month")
  ) %>%
  group_by(STORE_NBR, YEAR_MONTH) %>%
  summarise(
    # 1. Total sales revenue
    TOT_SALES = sum(TOT_SALES),
    
    # 2. Total number of customers
    N_CUSTOMERS = n_distinct(LYLTY_CARD_NBR),
    
    # 3. Average number of transactions per customer
    AVG_TXN_PER_CUSTOMER = n() / n_distinct(LYLTY_CARD_NBR),
    
    .groups = "drop" # Drop the grouping
  )

print("--- Monthly Metrics Created (Sample) ---")
glimpse(monthly_metrics)

# --- 4. Define Trial Period & Filter Pre-Trial Data ---
# Based on the project, the trial period is Feb, Mar, and Apr 2019.
# Therefore, the pre-trial period is all data before that (Jul 2018 - Jan 2019).
pre_trial_end_date <- as.Date("2019-02-01")

# Create a table of pre-trial metrics for all stores
pre_trial_metrics <- monthly_metrics %>%
  filter(YEAR_MONTH < pre_trial_end_date)

print(paste("Pre-trial data runs from", min(pre_trial_metrics$YEAR_MONTH), "to", max(pre_trial_metrics$YEAR_MONTH)))