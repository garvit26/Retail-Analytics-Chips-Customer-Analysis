# Retail-Analytics-Chips-Customer-Analysis

# Quantium Retail Analytics Virtual Internship

This repository contains the complete R analysis for the Quantium Retail Analytics Virtual Internship, completed via [Forage](https://www.theforage.com/). The project simulates a real-world analytics task to help a retail client (the Category Manager for Chips) develop a data-driven strategic plan.

The analysis is broken into three main tasks, following the client briefs provided by our manager, Zilinka.

---

## 📊 Task 1: Customer Segmentation & Data Cleaning

**Objective:** Analyze transaction and customer data to understand who buys chips and what drives their purchasing behavior.

* **Data Cleaning:** Loaded, inspected, and cleaned transaction (`QVI_transaction_data.xlsx`) and customer (`QVI_purchase_behaviour.csv`) data. This included handling date formats, removing outliers, and filtering for the "Chips" category.
* **Feature Engineering:** Created new, insightful features from existing data, such as:
    * `PACK_SIZE` (e.g., 175g)
    * `BRAND_NAME` (e.g., Kettle, Doritos)
    * `PRICE_PER_ITEM`
* **Analysis & Insights:**
    * Identified **"Mainstream, young singles/couples"** and **"Budget - Older Families"** as key high-value segments.
    * Performed a deep dive into "Mainstream, young singles/couples," discovering they are not price-sensitive and show a clear preference for **Kettle brand** chips and **175g pack sizes**.
    * Confirmed this finding with a t-test, proving their average price per item is significantly higher.

---

## 📈 Task 2: A/B Trial Analysis

**Objective:** Evaluate the performance of a new store layout trial (in stores 77, 86, 88) to determine if it should be rolled out.

* **Control Store Selection:** Developed an R function to find suitable "control" stores for each trial store. The function calculates a similarity score based on pre-trial (Jul 2018 - Jan 2019) metrics, including:
    * Total Sales
    * Total Customers
    * Average Transactions per Customer
* **Trial Assessment:** Compared the performance of each trial store against its control store during the trial period (Feb - Apr 2019). This analysis was visualized by plotting the percentage difference in sales and customers against a 95% confidence interval.
* **Findings:**
    * **Store 77 & 88 (SUCCESS):** Showed a significant and sustained increase in both sales and customer numbers.
    * **Store 86 (NO IMPACT):** Showed no significant change, with performance remaining within the normal range.

---

## 📋 Task 3: Final Report & Recommendations

**Objective:** Synthesize all findings into a clear, scannable report for the client, following the Pyramid Principle.

* Created a final PDF report using **R Markdown** that combined insights from both tasks.
* Provided a clear, "answer-first" executive summary.
* Delivered a final recommendation to **roll out the new store layout** and **focus marketing efforts** on "Mainstream, young singles/couples" by promoting 175g bags of Kettle chips.

---

## 🛠️ Technology Stack

* **Language:** **R**
* **Core Packages:**
    * `tidyverse` (for all data manipulation and visualization)
        * `dplyr`
        * `ggplot2`
        * `readr`
    * `readxl`: For loading the Excel transaction file.
    * `lubridate`: For all date and time manipulation.
    * `scales`: For formatting plot labels (e.g., `dollar_format()`, `percent_format()`).
    * `gridExtra`: For arranging multiple `ggplot` objects in a single frame.
    * `RMarkdown`: For creating the final reproducible reports.

---

## 🚀 How to Run

This repository is structured to be run using RStudio.

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/YourUsername/YourRepoName.git](https://github.com/YourUsername/YourRepoName.git)
    ```
2.  **Install Packages:**
    Open RStudio and ensure you have all the necessary packages installed:
    ```R
    install.packages(c("tidyverse", "readxl", "lubridate", "scales", "gridExtra", "knitr"))
    ```
3.  **Run the Analysis:**
    * The analysis for each task is contained in its respective R Markdown (`.Rmd`) file.
    * Open `Final_Report.Rmd` (or `Task_1_Analysis.Rmd`, `Task_2_Analysis.Rmd`) in RStudio.
    * Click the **Knit** button to run the entire analysis and generate the final PDF or HTML report.

---

## Acknowledgements

This project was completed as part of the **Forage** virtual internship program. Thank you to **Quantium** for providing this excellent, hands-on learning opportunity.
