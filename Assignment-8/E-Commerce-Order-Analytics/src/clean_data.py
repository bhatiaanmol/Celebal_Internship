import pandas as pd
import re
import os

RAW = "Data/Raw"
CLEAN = "Data/Cleaned"

os.makedirs(CLEAN, exist_ok=True)

orders = pd.read_csv(f"{RAW}/orders.csv")
order_items = pd.read_csv(f"{RAW}/order_items.csv")
products = pd.read_csv(f"{RAW}/products.csv")
customers = pd.read_csv(f"{RAW}/customers.csv")


def clean_orders(df):
    issues = {}

    issues["missing_customer_ids"] = df["customer_id"].isna().sum()
    df["customer_id"] = df["customer_id"].fillna("UNKNOWN")

    df["order_date"] = df["order_date"].apply(parse_date)

    issues["invalid_dates"] = df["order_date"].isna().sum()

    df = df.dropna(subset=["order_date"])
    df = df.drop_duplicates()

    return df, issues


def clean_products(df):
    df["product_name"] = (
        df["product_name"]
        .astype(str)
        .str.strip()
        .str.title()
    )

    df = df.drop_duplicates()

    return df


def validate_emails(df):
    pattern = r"^[^@\s]+@[^@\s]+\.[^@\s]+$"

    invalid = df[
        ~df["email"].astype(str).str.match(pattern)
    ]

    return invalid["customer_id"].tolist()


def check_referential_integrity(order_items_df, orders_df):
    invalid = order_items_df[
        ~order_items_df["order_id"].isin(orders_df["order_id"])
    ]

    return invalid


clean_orders_df, order_issues = clean_orders(orders)
clean_products_df = clean_products(products)

invalid_emails = validate_emails(customers)

invalid_order_items = check_referential_integrity(
    order_items,
    clean_orders_df
)

clean_order_items_df = order_items[
    order_items["order_id"].isin(clean_orders_df["order_id"])
].drop_duplicates()

clean_customers_df = customers.drop_duplicates()

clean_orders_df.to_csv(
    f"{CLEAN}/orders_cleaned.csv",
    index=False
)

clean_order_items_df.to_csv(
    f"{CLEAN}/order_items_cleaned.csv",
    index=False
)

clean_products_df.to_csv(
    f"{CLEAN}/products_cleaned.csv",
    index=False
)

clean_customers_df.to_csv(
    f"{CLEAN}/customers_cleaned.csv",
    index=False
)

with open(f"{CLEAN}/cleaning_report.txt", "w") as f:
    f.write(f"Missing customer IDs: {order_issues['missing_customer_ids']}\n")
    f.write(f"Invalid order dates: {order_issues['invalid_dates']}\n")
    f.write(f"Invalid emails: {len(invalid_emails)}\n")
    f.write(
        f"Invalid order_items references: {len(invalid_order_items)}\n"
    )

print("Cleaning completed.")
print("Invalid emails:", len(invalid_emails))
print("Invalid order references:", len(invalid_order_items))