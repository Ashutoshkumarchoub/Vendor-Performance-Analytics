# Vendor Performance Analytics Dashboard

## Project Overview
Vendor Performance Analytics is a data analytics project designed to evaluate supplier performance using procurement, delivery, quality, and cost-related data.

The project analyzes 3,000 purchase orders across 50 vendors to identify delivery delays, evaluate product quality, compare procurement costs, and rank vendors using a weighted performance score.


## 🚀 Live Dashboard

**[Click here to view the Live Dashboard](https://vendor-performance-analytics-rawpwzkp5cadctyjoh8awp.streamlit.app/)**


**Note:** This project uses a synthetic procurement dataset created for analytical and portfolio purposes.

## Business Objectives
- Analyze vendor delivery performance and late deliveries.
- Measure product quality and defect rates.
- Analyze procurement spending across product categories and months.
- Compare vendor cost efficiency within product categories.
- Develop a composite vendor performance scorecard.
- Support data-driven vendor evaluation and decision-making.

## Tools & Technologies
- Excel – Data review and analysis
- Python – Data cleaning and analysis
- Pandas & NumPy – Data processing and analysis
- Matplotlib & Seaborn – Data visualization
- MySQL – Data storage and SQL analysis
- Power BI – Interactive dashboard development
- Git & GitHub – Project version control

## Project Workflow
1. Data generation and exploration
2. Data cleaning and validation using Python
3. Database creation and data loading using MySQL
4. SQL-based vendor analysis
5. Exploratory data analysis using Python
6. Vendor scorecard development
7. Interactive Power BI dashboard development

## Key Performance Indicators
| Metric | Result |
|---|---:|
| Total Purchase Orders | 3,000 |
| Total Vendors | 50 |
| Total Procurement Value | ₹3,775,194,520.48 |
| Successful Delivery Rate | 45.72% |
| Late Deliveries | 1,623 |
| Overall Quality Rate | 96.13% |
| Defective Quantity | 27,867 |
| Good Vendors | 2 |
| Average Vendors | 48 |

## Vendor Scoring Model
Vendor performance is evaluated using three components:

- Delivery Score – 40%
- Quality Score – 35%
- Cost Score – 25%

**Overall Score = (Delivery × 0.40) + (Quality × 0.35) + (Cost × 0.25)**

Vendor classifications:
- Excellent: 85 and above
- Good: 70 to below 85
- Average: 55 to below 70
- Needs Improvement: 40 to below 55
- High Risk: below 40

Cost efficiency is compared within the same product category to avoid comparing unrelated product prices.

## Power BI Dashboard Pages
1. Executive Overview
2. Delivery Performance
3. Quality Analysis
4. Procurement & Cost
5. Vendor Scorecard

The dashboards include KPI cards, trend charts, vendor rankings, category analysis, scorecard tables, and interactive slicers.

## Key Findings
- 54.28% of valid deliveries were late.
- Successful delivery rate was 45.72%, counting Early and On-Time deliveries.
- Overall product quality rate was 96.13%.
- Total defective quantity was 27,867.
- August recorded the highest monthly procurement spending.
- December recorded the lowest monthly procurement spending.
- Two vendors were classified as Good and 48 as Average under the defined scoring thresholds.

## Project Structure
- data/ – Raw, cleaned, and processed datasets
- python/ – Python notebooks, scripts, and utilities
- sql/ – SQL analysis queries
- powerbi/ – Power BI dashboard file
- excel/ – Excel analysis files
- screenshots/ – Dashboard screenshots
- reports/ – Project reports

## Disclaimer
The dataset used in this project is synthetic and does not represent actual procurement transactions or real vendor performance.
