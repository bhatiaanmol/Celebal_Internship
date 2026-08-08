import sqlite3
from datetime import datetime, timedelta

def get_previous_range(start_date, end_date):
    start = datetime.strptime(start_date, "%Y-%m-%d")
    end = datetime.strptime(end_date, "%Y-%m-%d")

    days = (end - start).days + 1

    prev_end = start - timedelta(days=1)
    prev_start = prev_end - timedelta(days=days - 1)

    return prev_start.strftime("%Y-%m-%d"), prev_end.strftime("%Y-%m-%d")


def generate_report(report_type, start_date, end_date):
    conn = sqlite3.connect("ecommerce.db")
    cursor = conn.cursor()

    if report_type not in ["daily", "weekly", "monthly"]:
        print("Invalid report type.")
        conn.close()
        return

    query = """
    SELECT
        COUNT(DISTINCT o.order_id),
        ROUND(SUM(
            oi.quantity * oi.unit_price *
            (1 - oi.discount_percent / 100.0)
        ), 2),
        COUNT(DISTINCT o.customer_id)
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE DATE(o.order_date) BETWEEN ? AND ?
    """

    cursor.execute(query, (start_date, end_date))
    total_orders, revenue, unique_customers = cursor.fetchone()

    top_products_query = """
    SELECT
        p.product_name,
        SUM(oi.quantity) AS total_quantity
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    WHERE DATE(o.order_date) BETWEEN ? AND ?
    GROUP BY p.product_id, p.product_name
    ORDER BY total_quantity DESC
    LIMIT 3
    """

    cursor.execute(top_products_query, (start_date, end_date))
    top_products = cursor.fetchall()

    prev_start, prev_end = get_previous_range(start_date, end_date)

    cursor.execute(query, (prev_start, prev_end))
    _, previous_revenue, _ = cursor.fetchone()

    revenue = revenue or 0
    previous_revenue = previous_revenue or 0

    if previous_revenue == 0:
        change = None
    else:
        change = ((revenue - previous_revenue) / previous_revenue) * 100

    print(f"\n{report_type.upper()} REPORT")
    print(f"Period: {start_date} to {end_date}")
    print(f"Total Orders: {total_orders}")
    print(f"Revenue: {revenue}")
    print(f"Unique Customers: {unique_customers}")

    print("\nTop 3 Products:")
    for product, quantity in top_products:
        print(f"{product}: {quantity}")

    if change is None:
        print("\nPrevious Period Comparison: Not available")
    else:
        print(f"\nRevenue Change vs Previous Period: {change:.2f}%")

    conn.close()


if __name__ == "__main__":
    report_type = input("Enter report type (daily/weekly/monthly): ").lower()
    start_date = input("Enter start date (YYYY-MM-DD): ")
    end_date = input("Enter end date (YYYY-MM-DD): ")

    generate_report(report_type, start_date, end_date)