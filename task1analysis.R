library(tidyverse)
library(scales)
library(lubridate)

full_data <- read_csv("QVI_full_data.csv")

print("--- Data loaded successfully ---")
glimpse(full_data)

# --- 2. Metric 1: Total Sales by Segment ---
# Zilinka wants to know "where the highest sales are coming from".
# We'll group by LIFESTAGE and PREMIUM_CUSTOMER and sum the TOT_SALES.

sales_summary <- full_data %>%
  group_by(LIFESTAGE, PREMIUM_CUSTOMER) %>%
  summarise(
    TOTAL_SALES = sum(TOT_SALES),
    .groups = 'drop' # This drops the grouping, which is good practice
  ) %>%
  arrange(desc(TOTAL_SALES)) # Sort from highest to lowest sales

print("--- Total Sales by Customer Segment ---")
print(sales_summary)

# --- 3. Visualization 1: Total Sales by Segment ---
# A bar chart is the best way to show this.
sales_plot <- ggplot(sales_summary, aes(x = LIFESTAGE, y = TOTAL_SALES, fill = PREMIUM_CUSTOMER)) +
  geom_bar(stat = "identity", position = "dodge") +
  
  # Add titles and labels
  labs(
    title = "Total Chip Sales by Customer Segment",
    x = "Lifestage",
    y = "Total Sales ($)",
    fill = "Premium Status"
  ) +
  
  # Format the y-axis to show dollar amounts clearly
  scale_y_continuous(labels = dollar_format()) +
  
  # Make the x-axis labels readable (they are long)
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

# Save the plot to your project folder
ggsave("sales_by_segment.png", sales_plot)
print("--- Sales by Segment plot saved as 'sales_by_segment.png' ---")

sales_plot

# --- 4. Metric 2: Average Price Per Unit (Price Sensitivity) ---
# This helps us understand if "Premium" customers actually buy 
# more expensive items, or if "Budget" customers buy cheaper items.

# First, create a "Price per Unit" column for each transaction
full_data_with_metrics <- full_data %>%
  mutate(PRICE_PER_UNIT = TOT_SALES / PROD_QTY)

# Now, let's find the average (mean) unit price for each segment
price_summary <- full_data_with_metrics %>%
  group_by(LIFESTAGE, PREMIUM_CUSTOMER) %>%
  summarise(
    AVG_UNIT_PRICE = mean(PRICE_PER_UNIT),
    .groups = 'drop'
  ) %>%
  arrange(desc(AVG_UNIT_PRICE))

print("--- Average Unit Price by Customer Segment ---")
print(price_summary)


# --- 5. Visualization 2: Average Unit Price by Segment ---
price_plot <- ggplot(price_summary, aes(x = LIFESTAGE, y = AVG_UNIT_PRICE, fill = PREMIUM_CUSTOMER)) +
  geom_bar(stat = "identity", position = "dodge") +
  
  labs(
    title = "Average Price per Unit by Customer Segment",
    x = "Lifestage",
    y = "Average Unit Price ($)",
    fill = "Premium Status"
  ) +
  
  scale_y_continuous(labels = dollar_format()) +
  
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )
price_plot
# Save the plot
ggsave("unit_price_by_segment.png", price_plot)
print("--- Unit Price by Segment plot saved as 'unit_price_by_segment.png' ---")

# --- 2. Engineering TIME Features ---
# Let's find out WHEN people shop.
# This helps answer: Are sales seasonal? Do people buy more chips on weekends?
data_with_features <- full_data %>%
  mutate(
    # Feature 2a: Day of the Week (e.g., "Mon", "Sat")
    DAY_OF_WEEK = wday(DATE, label = TRUE, abbr = TRUE),
    
    # Feature 2b: Month (e.g., "Jan", "Dec")
    MONTH = month(DATE, label = TRUE, abbr = TRUE)
  )

print("--- Checking TIME features ---")
print(table(data_with_features$DAY_OF_WEEK))


# --- 3. Engineering VALUE Features ---
# Let's find out what "value" means.
# This helps answer: Are premium customers paying more per gram?
data_with_features <- data_with_features %>%
  mutate(
    # Feature 3a: Price Per Item
    # This is the price of one bag (e.g., if PROD_QTY is 2, this is half)
    PRICE_PER_ITEM = TOT_SALES / PROD_QTY,
    
    # Feature 3b: Price Per Gram
    # This is the ultimate value metric!
    # It allows us to compare a 175g bag to a 330g bag fairly.
    PRICE_PER_GRAM = PRICE_PER_ITEM / PACK_SIZE
  )

print("--- Checking VALUE features ---")
print(summary(data_with_features$PRICE_PER_GRAM))

# --- 4. Engineering PRODUCT Features ---
# Let's get specific about the product itself.
# This helps answer: Do certain segments prefer Crinkle Cut vs. Tortillas?
# We use `case_when` for "if-then" logic based on the product name.

data_with_features <- data_with_features %>%
  mutate(
    # Feature 4a: Product Type
    PRODUCT_TYPE = case_when(
      str_detect(PROD_NAME, "Crinkle|Crnkle") ~ "Crinkle Cut",
      str_detect(PROD_NAME, "Tortilla|Doritos|Tostitos|CCs") ~ "Tortilla Chips",
      str_detect(PROD_NAME, "Kettle") ~ "Kettle Cooked",
      str_detect(PROD_NAME, "Popd|Pop") ~ "Popped Chips",
      str_detect(PROD_NAME, "Grain|GrnWves") ~ "Grain Chips",
      # `TRUE ~` acts as the "else" (default) category
      TRUE ~ "Classic Chips"
    ),
    
    # Feature 4b: Key Flavour
    # We can pick out a few key flavours
    FLAVOUR = case_when(
      str_detect(PROD_NAME, "Salt|Slt") ~ "Salt",
      str_detect(PROD_NAME, "Cheese|Chese|Chs") ~ "Cheese",
      str_detect(PROD_NAME, "Vinegar|Vineger") ~ "Salt & Vinegar",
      str_detect(PROD_NAME, "Chilli|Chili") ~ "Chilli",
      str_detect(PROD_NAME, "Chicken") ~ "Chicken",
      str_detect(PROD_NAME, "Onion") ~ "Onion/Cream",
      TRUE ~ "Other"
    )
  )

print("--- Checking PRODUCT features ---")
print("Product Types:")
print(table(data_with_features$PRODUCT_TYPE))
print("Flavours:")
print(table(data_with_features$FLAVOUR))

# --- 5. Save Your New "Super-Data" ---
write_csv(data_with_features, "QVI_full_data_with_features.csv")
print("--- Successfully saved new features to QVI_full_data_with_features.csv ---")

# Let's look at the new data structure
glimpse(data_with_features)

# Are sales higher on weekends?
ggplot(data_with_features, aes(x = DAY_OF_WEEK, y = sum(TOT_SALES))) +
  geom_bar(stat = "identity", fill = "blue") +
  labs(title = "Total Sales by Day of Week")

# Do Premium customers really buy items that are more expensive *per gram*?
data_with_features %>%
  group_by(PREMIUM_CUSTOMER) %>%
  summarise(AVG_PRICE_PER_GRAM = mean(PRICE_PER_GRAM)) %>%
  ggplot(aes(x = PREMIUM_CUSTOMER, y = AVG_PRICE_PER_GRAM, fill = PREMIUM_CUSTOMER)) +
  geom_bar(stat = "identity") +
  labs(title = "Average Price per Gram by Customer")

# What kind of chips do "Older Families" (a high-value group) prefer?
data_with_features %>%
  filter(LIFESTAGE == "OLDER FAMILIES") %>%
  count(PRODUCT_TYPE, sort = TRUE) %>%
  ggplot(aes(x = reorder(PRODUCT_TYPE, n), y = n)) +
  geom_bar(stat = "identity", fill = "purple") +
  coord_flip() +
  labs(title = "Favorite Chip Types for Older Families")



# --- 1. Load Your Feature-Rich Data ---
# (If you don't have it in your environment already)
data_with_features <- read_csv("QVI_full_data_with_features.csv")

# --- 2. Define and Filter for Our Target Segment ---
target_segment <- data_with_features %>%
  filter(
    LIFESTAGE == "YOUNG SINGLES/COUPLES",
    PREMIUM_CUSTOMER == "Mainstream"
  )

print("--- Target Segment (Mainstream, Young Singles/Couples) ---")
print(paste("Total transactions:", nrow(target_segment)))


# --- 3. Analyze Brand Preference (Sales) ---
# We want to see which brands they spend the most *money* on.
brand_sales_target <- target_segment %>%
  group_by(BRAND_NAME) %>%
  summarise(TOTAL_SALES = sum(TOT_SALES)) %>%
  arrange(desc(TOTAL_SALES))

print("--- Top 5 Brands by Sales for Target Segment ---")
print(head(brand_sales_target, 5))

# Let's visualize this as a bar chart
brand_plot_target <- brand_sales_target %>%
  head(10) %>% # Top 10 brands
  ggplot(aes(x = reorder(BRAND_NAME, TOTAL_SALES), y = TOTAL_SALES)) +
  geom_bar(stat = "identity", fill = "cornflowerblue") +
  coord_flip() + # Flip to horizontal bars (easier to read)
  labs(
    title = "Top Brands for Mainstream Young Singles/Couples",
    x = "Brand",
    y = "Total Sales ($)"
  ) +
  scale_y_continuous(labels = dollar_format())

brand_plot_target
ggsave("target_brand_sales.png", brand_plot_target)
print("--- Brand plot saved as 'target_brand_sales.png' ---")

# --- 4. Analyze Pack Size Preference (Transactions) ---
# We want to see what pack size they *buy most often*.
pack_size_target <- target_segment %>%
  group_by(PACK_SIZE) %>%
  summarise(TRANSACTIONS = n()) %>% # n() counts the number of rows/transactions
  arrange(desc(TRANSACTIONS))

print("--- Top 5 Pack Sizes by Transactions for Target Segment ---")
print(head(pack_size_target, 5))

# Let's visualize this
pack_plot_target <- pack_size_target %>%
  head(10) %>%
  ggplot(aes(x = reorder(as.factor(PACK_SIZE), TRANSACTIONS), y = TRANSACTIONS)) +
  geom_bar(stat = "identity", fill = "darkseagreen") +
  coord_flip() +
  labs(
    title = "Most Popular Pack Sizes (Mainstream Young Singles/Couples)",
    x = "Pack Size (grams)",
    y = "Number of Transactions"
  )

pack_plot_target
ggsave("target_pack_size.png", pack_plot_target)
print("--- Pack Size plot saved as 'target_pack_size.png' ---")

# --- 5. Analyze Product Type Preference (Transactions) ---
# Let's use our new PRODUCT_TYPE feature
product_type_target <- target_segment %>%
  group_by(PRODUCT_TYPE) %>%
  summarise(TRANSACTIONS = n()) %>%
  arrange(desc(TRANSACTIONS))

print("--- Top 5 Product Types by Transactions for Target Segment ---")
print(head(product_type_target, 5))

# --- 2. Create a "Segment" Column ---
# We'll label rows as either "Target" or "Other"
data_with_comparison <- data_with_features %>%
  mutate(
    SEGMENT_TYPE = if_else(
      LIFESTAGE == "YOUNG SINGLES/COUPLES" & PREMIUM_CUSTOMER == "Mainstream",
      "Target Segment",
      "Other Customers"
    )
  )
# --- 3. Analyze Pack Size Proportions ---
# We need to find the *percentage* each pack size contributes to its segment,
# otherwise, the "Other Customers" group will be too large to compare.

pack_size_comparison <- data_with_comparison %>%
  group_by(SEGMENT_TYPE, PACK_SIZE) %>%
  summarise(TRANSACTIONS = n(), .groups = "drop_last") %>%
  # Calculate proportion (percentage) of transactions for each segment
  mutate(PROPORTION = TRANSACTIONS / sum(TRANSACTIONS)) %>%
  ungroup() # Remove all grouping

print("--- Proportional Pack Size Comparison ---")
# Filter to see a specific pack size, e.g., 175g
print(filter(pack_size_comparison, PACK_SIZE == 175))

# --- 4. Visualize the Pack Size Comparison ---
comparison_plot <- pack_size_comparison %>%
  # Let's filter for common pack sizes to make the chart readable
  filter(PACK_SIZE %in% c(110, 134, 150, 170, 175, 270, 330, 380)) %>%
  ggplot(aes(x = as.factor(PACK_SIZE), y = PROPORTION, fill = SEGMENT_TYPE)) +
  geom_bar(stat = "identity", position = "dodge") +
  
  # Format Y axis as percentages
  scale_y_continuous(labels = percent_format()) +
  
  labs(
    title = "Pack Size Preference: Target Segment vs. Others",
    x = "Pack Size (grams)",
    y = "Proportion of Transactions",
    fill = "Segment"
  )

comparison_plot
ggsave("pack_size_comparison.png", comparison_plot)

print("--- Pack size comparison plot saved! ---")

# --- 5. Perform T-Test on Average Unit Price ---

# We'll use the data_with_comparison from the step above.
# We need to create two separate groups for the test.

target_prices <- data_with_comparison %>%
  filter(SEGMENT_TYPE == "Target Segment") %>%
  # We need the price per unit, which we made in the creative step
  pull(PRICE_PER_ITEM) # pull() extracts just that one column

other_prices <- data_with_comparison %>%
  filter(SEGMENT_TYPE == "Other Customers") %>%
  pull(PRICE_PER_ITEM)

# --- Run the T-Test ---
# We are testing if the average price of the 'target' group
# is 'greater' than the 'other' group.
test_result <- t.test(target_prices, other_prices, alternative = "greater")

print("--- T-Test for Average Price Per Item ---")
print(test_result)