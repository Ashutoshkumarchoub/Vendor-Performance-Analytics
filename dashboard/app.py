
from pathlib import Path

import pandas as pd
import streamlit as st

# Page configuration
st.set_page_config(
    page_title="Vendor Performance Analytics",
    page_icon="📊",
    layout="wide"
)

BASE_DIR = Path(__file__).resolve().parents[1]
DATA_DIR = BASE_DIR / "data" / "processed"
CLEANED_DIR = BASE_DIR / "data" / "cleaned"


@st.cache_data
def load_data():
    orders = pd.read_csv(
        CLEANED_DIR / "vendor_purchase_orders_cleaned.csv"
    )
    delivery = pd.read_csv(
        DATA_DIR / "vendor_delivery_analysis.csv"
    )
    quality = pd.read_csv(
        DATA_DIR / "vendor_quality_analysis.csv"
    )
    cost = pd.read_csv(
        DATA_DIR / "vendor_cost_analysis.csv"
    )
    scorecard = pd.read_csv(
        DATA_DIR / "vendor_performance_scorecard.csv"
    )
    monthly = pd.read_csv(
        DATA_DIR / "monthly_procurement_analysis.csv"
    )

    return orders, delivery, quality, cost, scorecard, monthly


st.title("📊 Vendor Performance Analytics")
st.caption("Procurement | Delivery | Quality | Cost | Vendor Evaluation")

try:
    orders, delivery, quality, cost, scorecard, monthly = load_data()
except Exception as e:
    st.error(f"Unable to load project data: {e}")
    st.stop()


# Sidebar filters
st.sidebar.header("Dashboard Filters")

vendors = ["All Vendors"] + sorted(
    orders["Vendor_Name"].dropna().unique().tolist()
)
categories = ["All Categories"] + sorted(
    orders["Product_Category"].dropna().unique().tolist()
)

selected_vendor = st.sidebar.selectbox("Select Vendor", vendors)
selected_category = st.sidebar.selectbox("Select Product Category", categories)

filtered = orders.copy()

if selected_vendor != "All Vendors":
    filtered = filtered[
        filtered["Vendor_Name"] == selected_vendor
    ]

if selected_category != "All Categories":
    filtered = filtered[
        filtered["Product_Category"] == selected_category
    ]


# KPI calculations
total_orders = filtered["Purchase_Order_ID"].nunique()
total_vendors = filtered["Vendor_ID"].nunique()
procurement_value = filtered["Total_Order_Value"].sum()

valid = filtered[filtered["Actual_Delivery_Date"].notna()]
successful = valid["Delivery_Status"].isin(["Early", "On-Time"]).sum()

delivery_rate = (
    successful / len(valid) * 100 if len(valid) else 0
)

delivered = filtered["Quantity_Delivered"].sum()
accepted = filtered["Accepted_Quantity"].sum()
quality_rate = accepted / delivered * 100 if delivered else 0
defective = filtered["Defective_Quantity"].sum()

# KPI cards
st.subheader("Executive Overview")

c1, c2, c3 = st.columns(3)
c1.metric("Total Orders", f"{total_orders:,}")
c2.metric("Total Vendors", f"{total_vendors:,}")
c3.metric("Procurement Value", f"₹{procurement_value:,.0f}")

c4, c5, c6 = st.columns(3)
c4.metric("Successful Delivery Rate", f"{delivery_rate:.2f}%")
c5.metric("Overall Quality Rate", f"{quality_rate:.2f}%")
c6.metric("Defective Quantity", f"{defective:,.0f}")

st.divider()

# Delivery analysis
st.subheader("🚚 Delivery Performance")

left, right = st.columns(2)

with left:
    status_data = (
        filtered["Delivery_Status"]
        .value_counts()
        .rename_axis("Delivery Status")
        .reset_index(name="Orders")
    )
    st.write("Delivery Status Distribution")
    st.bar_chart(status_data.set_index("Delivery Status"))

with right:
    st.write("Vendor Delivery Performance")
    vendor_delivery = delivery.copy()

    if selected_vendor != "All Vendors":
        vendor_delivery = vendor_delivery[
            vendor_delivery["Vendor_Name"] == selected_vendor
        ]

    st.bar_chart(
        vendor_delivery.set_index("Vendor_Name")[["delivery_score"]]
    )

st.divider()

# Quality analysis
st.subheader("🛡️ Quality Analysis")

left, right = st.columns(2)

with left:
    quality_data = quality.copy()

    if selected_vendor != "All Vendors":
        quality_data = quality_data[
            quality_data["Vendor_Name"] == selected_vendor
        ]

    st.write("Vendor Quality Scores")
    st.bar_chart(
        quality_data.set_index("Vendor_Name")[["quality_score"]]
    )

with right:
    category_defects = (
        filtered.groupby("Product_Category")["Defective_Quantity"]
        .sum()
        .sort_values(ascending=False)
    )
    st.write("Defective Quantity by Category")
    st.bar_chart(category_defects)

st.divider()

# Procurement analysis
st.subheader("💰 Procurement & Cost Analysis")

monthly_filtered = monthly.copy()

left, right = st.columns(2)

with left:
    st.write("Monthly Procurement Spending")
    st.line_chart(
        monthly_filtered.set_index("Month_Name")[["Total_Order_Value"]]
    )

with right:
    cost_data = cost.copy()

    if selected_vendor != "All Vendors":
        cost_data = cost_data[
            cost_data["Vendor_Name"] == selected_vendor
        ]

    st.write("Vendor Cost Efficiency")
    st.bar_chart(
        cost_data.set_index("Vendor_Name")[["cost_score"]]
    )

st.divider()

# Vendor scorecard
st.subheader("🏆 Vendor Performance Scorecard")

score_data = scorecard.copy()

if selected_vendor != "All Vendors":
    score_data = score_data[
        score_data["Vendor_Name"] == selected_vendor
    ]

if selected_category != "All Categories":
    category_vendors = filtered["Vendor_ID"].unique()
    score_data = score_data[
        score_data["Vendor_ID"].isin(category_vendors)
    ]

if not score_data.empty:
    st.write("Vendor Rankings")
    st.bar_chart(
        score_data.set_index("Vendor_Name")[["overall_vendor_score"]]
    )

    st.write("Detailed Vendor Scorecard")
    st.dataframe(
        score_data.sort_values(
            "overall_vendor_score", ascending=False
        ),
        use_container_width=True,
        hide_index=True
    )
else:
    st.info("No vendor records found for the selected filters.")

st.caption(
    "Note: This dashboard uses a synthetic procurement dataset "
    "created for educational and portfolio purposes."
)
