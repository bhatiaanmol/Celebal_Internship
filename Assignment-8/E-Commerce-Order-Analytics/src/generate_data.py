import pandas as pd
import random
from datetime import datetime, timedelta

random.seed(42)

# CUSTOMERS

customers = []

for i in range(1, 501):
    email = f"customer{i}@gmail.com"

    # 2% invalid emails
    if random.random() < 0.02:
        email = f"customer{i}gmail.com"

    customers.append({
        "customer_id": f"C{i:04}",
        "customer_name": f"Customer {i}",
        "email": email,
        "registration_date": (
            datetime.now() - timedelta(days=random.randint(30, 1000))
        ).strftime("%Y-%m-%d"),
        "customer_type": random.choice(["REGULAR", "PREMIUM", "VIP"])
    })

customers_df = pd.DataFrame(customers)


# PRODUCTS


categories = {
    "Electronics": ["Mobile", "Laptop", "Headphones"],
    "Clothing": ["Shirt", "Jeans", "Jacket"],
    "Home": ["Chair", "Table", "Lamp"],
    "Books": ["Fiction", "Education", "Biography"]
}

products = []

for i in range(1, 501):

    category = random.choice(list(categories.keys()))
    subcategory = random.choice(categories[category])

    product_name = f"{subcategory} Product {i}"

    if random.random() < 0.05:
        product_name = f"  {product_name.upper()}  "

    products.append({
        "product_id": f"P{i:04}",
        "product_name": product_name,
        "category": category,
        "subcategory": subcategory,
        "cost_price": round(random.uniform(50, 5000), 2)
    })

products_df = pd.DataFrame(products)


# ORDERS

orders = []

start_date = datetime.now() - timedelta(days=730)

for i in range(1, 1501):

    customer_id = random.choice(customers_df["customer_id"].tolist())

    if random.random() < 0.05:
        customer_id = None

    order_date = start_date + timedelta(days=random.randint(0, 730))

    if random.random() < 0.05:
        formatted_date = order_date.strftime("%d-%m-%Y")
    else:
        formatted_date = order_date.strftime("%Y-%m-%d %H:%M:%S")

    orders.append({
        "order_id": f"O{i:05}",
        "customer_id": customer_id,
        "order_date": formatted_date,
        "status": random.choice(
            ["PLACED", "SHIPPED", "DELIVERED", "CANCELLED", "RETURNED"]
        ),
        "region_code": random.choice(["NORTH", "SOUTH", "EAST", "WEST"])
    })

orders_df = pd.DataFrame(orders)


# ORDER ITEMS

order_items = []

for i in range(1, 3001):

    quantity = random.randint(1, 5)

    if random.random() < 0.03:
        quantity *= -1

    order_items.append({
        "item_id": f"I{i:05}",
        "order_id": random.choice(orders_df["order_id"].tolist()),
        "product_id": random.choice(products_df["product_id"].tolist()),
        "quantity": quantity,
        "unit_price": round(random.uniform(100, 10000), 2),
        "discount_percent": random.randint(0, 30)
    })

order_items_df = pd.DataFrame(order_items)


# SAVE FILES

customers_df.to_csv("Data/Raw/customers.csv", index=False)
products_df.to_csv("Data/Raw/products.csv", index=False)
orders_df.to_csv("Data/Raw/orders.csv", index=False)
order_items_df.to_csv("Data/Raw/order_items.csv", index=False)

print("Datasets generated successfully.")
print("Customers:", len(customers_df))
print("Products:", len(products_df))
print("Orders:", len(orders_df))
print("Order Items:", len(order_items_df))