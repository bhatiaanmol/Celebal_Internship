import pandas as pd
import sqlite3

conn = sqlite3.connect("ecommerce.db")

orders = pd.read_csv("Data/Cleaned/orders_cleaned.csv")
order_items = pd.read_csv("Data/Cleaned/order_items_cleaned.csv")
products = pd.read_csv("Data/Cleaned/products_cleaned.csv")
customers = pd.read_csv("Data/Cleaned/customers_cleaned.csv")

orders.to_sql("orders", conn, if_exists="replace", index=False)
order_items.to_sql("order_items", conn, if_exists="replace", index=False)
products.to_sql("products", conn, if_exists="replace", index=False)
customers.to_sql("customers", conn, if_exists="replace", index=False)

cursor = conn.cursor()

for table in ["orders", "order_items", "products", "customers"]:
    cursor.execute(f"SELECT COUNT(*) FROM {table}")
    print(table, cursor.fetchone()[0])

conn.close()
