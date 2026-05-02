# Pricing & Promotion Effectiveness Analysis

> **"Which promotions actually make money, and which ones just give away discounts?"**
> This project answers that question using 2.8 million retail transactions.

---


## Business Problem

Every year, retailers spend **millions** on promotions — in-store displays, newspaper mailers, coupons. But most don't know:

- Are promotions driving **real** new sales, or just giving discounts to people who would've bought anyway?
- Which promotion type (display vs mailer vs coupon) gives the **best return**?
- Are some campaigns causing customers to **stock up and stop buying later** (pantry loading)?
- When we promote Product A, does Product B in the same category **lose sales** (cannibalization)?

**This project answers all of these questions with data.**

---

## Key Findings

| # | Finding | Business Impact |
|---|---------|-----------------|
| 1 | Optimal discount is **1-10%** — delivers 36% sales lift | Cap discounts at 15% to maximize ROI |
| 2 | Beyond 20% discount: **returns turn NEGATIVE** | Deep discounts destroy margin |
| 3 | **5 of 30 campaigns (17%)** show pantry loading | Customers stock up, then stop buying |
| 4 | Display promotions outperform mailers by **3x in ROI** | Shift budget from mailers to displays |
| 5 | Champions segment responds **most positively** to promos | Target promos by customer segment |
| 6 | Several categories show **high cannibalization** | Promoting one product hurts similar products |

**Estimated savings: ~$2.1M annually** by eliminating wasteful campaigns and optimizing discount depth.

---

## Tools & Technologies

| Tool | What It Does in This Project |
|------|------------------------------|
| **Snowflake** | Cloud data warehouse — stores and processes 2.8M transactions |
| **dbt** | SQL transformation pipeline — 14 models with 28 automated tests |
| **Python** | Statistical analysis — t-tests, K-Means clustering, Difference-in-Differences |
| **Excel** | Client deliverable — interactive ROI calculator with dropdown |
| **Power BI** | Dashboard — 4 pages with DAX measures, drill-through, What-If parameter |
| **SQL** | Core language — CTEs, window functions, joins, aggregations |
| **GitHub** | Version control and project portfolio |

---

## Project Architecture

STEP 1: DATA LOADING 8 raw CSV files → Snowflake tables (2.8M+ rows)
STEP 2: DATA CLEANING (dbt staging layer) Raw tables → 5 staging views
Removed duplicates (ROW_NUMBER)
Handled nulls (COALESCE)
Flagged outliers (99th percentile)
Validated ranges (day, week)
Standardized text (UPPER, TRIM)
STEP 3: BUSINESS ANALYTICS (dbt mart layer) Staging views → 9 mart tables
Promo effectiveness (lift calculation)
Discount depth optimization
Campaign ROI & pantry loading
Price elasticity
Customer segmentation
Cannibalization
Halo effect
Segment x promo response
STEP 4: STATISTICAL ANALYSIS (Python) Mart tables → Statistical proof
T-tests (is the difference real?)
K-Means clustering (customer segments)
Difference-in-Differences (causal impact)
Visualizations (matplotlib)
STEP 5: DELIVERABLES
Excel: ROI calculator for stakeholders
Power BI: Interactive dashboard for monitoring
---


## Data Cleaning

| Issue Found | How We Fixed It | Why It Matters |
|-------------|-----------------|----------------|
| Duplicate transactions | ROW_NUMBER + PARTITION BY | Counting same sale twice = wrong totals |
| Null discount values | COALESCE to 0 | Null ≠ no discount; treated as zero |
| Negative quantities | Set to 1 | Can't sell -3 items |
| Extreme values | Flagged at 99th percentile | $5000 grocery item is likely an error |
| Inconsistent text | UPPER + TRIM | "coca cola" and "COCA COLA" should match |
| Missing demographics | Imputed with 'UNKNOWN' | Keeps rows in analysis |

---

## Recommendations

| # | Recommendation | Expected Impact |
|---|----------------|-----------------|
| 1 | Cap all discounts at **15% maximum** | Prevent margin erosion |
| 2 | Discontinue campaigns **15, 20, 23, 24, 25** | Eliminate pantry loading waste |
| 3 | Shift **30% of mailer budget** to display promotions | 3x better ROI |
| 4 | Create **segment-specific promo strategy** | Target right customers |
| 5 | Avoid deep discounts in **high-cannibalization categories** | Protect category revenue |

---

## Dataset

**Source:** Dunnhumby "The Complete Journey"

| Table | Rows | Description |
|-------|------|-------------|
| Transaction Data | 2,844,738 | Every purchase — who, what, when, how much |
| Product | 92,353 | Product catalog with department, brand |
| Causal Data | 757,027 | Promotion flags (display, mailer) |
| Household Demographics | 801 | Customer profiles (age, income, family) |
| Campaign Descriptions | 30 | 30 marketing campaigns |
| Campaign Table | 7,208 | Which customers got which campaign |
| Coupon | 124,548 | Coupon-product mapping |
| Coupon Redemptions | 4,636 | Actual coupon usage |

---
## Data Cleaning

| Issue Found | How We Fixed It | Why It Matters |
|-------------|-----------------|----------------|
| Duplicate transactions | ROW_NUMBER + PARTITION BY | Counting same sale twice = wrong totals |
| Null discount values | COALESCE to 0 | Null ≠ no discount; treated as zero |
| Negative quantities | Set to 1 | Can't sell -3 items |
| Extreme values | Flagged at 99th percentile | $5000 grocery item is likely an error |
| Inconsistent text | UPPER + TRIM | "coca cola" and "COCA COLA" should match |
| Missing demographics | Imputed with 'UNKNOWN' | Keeps rows in analysis |

---

## Analyses Performed

### 1. Promo Lift Calculation
**Question:** Does promotion actually increase sales?
**Method:** Compare sales during promotion vs non-promotion baseline
**Result:** Varies by type — display promos show highest lift

### 2. Discount Depth Optimization
**Question:** What's the optimal discount percentage?
**Method:** Group transactions by discount bands, calculate lift per band
**Result:** 1-10% is optimal. Beyond 20% = negative returns

### 3. Pantry Loading Detection
**Question:** Are customers actually buying more, or just buying earlier?
**Method:** Compare pre-campaign, during-campaign, and post-campaign spend
**Result:** 5 campaigns show post-campaign dip > 15% = pantry loading

### 4. Price Elasticity
**Question:** Which product categories are price-sensitive?
**Method:** Correlation between price changes and quantity changes
**Result:** Identified elastic categories (best for promotions) vs inelastic (avoid discounting)

### 5. Customer Segmentation (RFM + K-Means)
**Question:** Who are our best customers?
**Method:** Score by Recency, Frequency, Monetary → cluster with K-Means
**Result:** 4 segments — Champions, Loyal, Recent, At Risk

### 6. Cannibalization
**Question:** When we promote Coke, do Pepsi sales drop?
**Method:** Compare same-category product sales during vs outside promotion
**Result:** Several categories show significant cannibalization

### 7. Halo Effect
**Question:** Do promoted items drive additional purchases?
**Method:** Compare basket size and value for promo vs non-promo baskets
**Result:** Minimal halo in this dataset — opportunity for bundle promotions

### 8. Segment x Promo Response
**Question:** Do all customers respond to promotions equally?
**Method:** Cross-reference RFM segments with promo response rates
**Result:** Champions respond positively; At Risk shows negative response

---


## Project Structure

pricing-promo-effectiveness/ │ ├── README.md # You are here │ ├── dbt_project/ # SQL Transformation Layer │ ├── dbt_project.yml # Project config │ ├── profiles.yml # Snowflake connection │ └── models/ │ ├── staging/ # Data cleaning (5 models) │ │ ├── sources.yml │ │ ├── stg_transactions.sql │ │ ├── stg_products.sql │ │ ├── stg_causal.sql │ │ ├── stg_campaigns.sql │ │ └── stg_households.sql │ ├── marts/ # Business logic (9 models) │ │ ├── mart_promo_effectiveness.sql │ │ ├── mart_promo_roi.sql │ │ ├── mart_price_elasticity.sql │ │ ├── mart_campaign_performance.sql │ │ ├── mart_discount_depth.sql │ │ ├── mart_cannibalization.sql │ │ ├── mart_halo_effect.sql │ │ ├── mart_pantry_loading.sql │ │ └── mart_segment_promo_response.sql │ └── schema.yml # Tests & documentation │ ├── data/ # CSV data files │ ├── stg_transactions.csv │ └── mart_*.csv (9 files) │ ├── notebooks/ # Python Analysis │ └── promo_analysis.ipynb # Open in Colab to run │ ├── excel/ # Excel Deliverables │ └── Promo_Analysis.xlsx │ └── powerbi/ # Power BI Dashboard ├── Promo_Dashboard.pbix └── screenshots/ ├── page1_overview.png ├── page2_discount.png ├── page3_campaigns.png └── page4_segments.png

---

## How to Run

### Python Notebook
1. Click the **"Open in Colab"** badge at the top of the notebook
2. Upload CSV files from `data/` folder when prompted
3. Click **Runtime → Run All**
4. View charts and statistical outputs

### dbt Models
1. Set up Snowflake account
2. Load raw CSVs into `PROMO_ANALYTICS` schema
3. Run `dbt build` from the `dbt_project/` directory
4. All 14 models + 28 tests will execute

### Power BI
1. Download `Promo_Dashboard.pbix`
2. Open in Power BI Desktop (free)
3. Data is embedded — dashboard loads immediately

---

## Author

**Megha Pawar**

Built as an end-to-end data analytics portfolio project demonstrating SQL, Python, Excel, and Power BI skills for data analyst roles.
