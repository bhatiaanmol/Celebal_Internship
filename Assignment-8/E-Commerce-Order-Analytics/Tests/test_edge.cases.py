from datetime import datetime


def test_invalid_order_reference():
    valid_orders = {"O00001", "O00002", "O00003"}
    order_id = "O99999"

    if order_id not in valid_orders:
        print("PASS: Invalid order reference detected.")
    else:
        print("FAIL")


def test_invalid_discount():
    discount_percent = 120

    if discount_percent > 100 or discount_percent < 0:
        print("PASS: Invalid discount detected.")
    else:
        print("FAIL")


def test_zero_quantity():
    quantity = 0

    if quantity == 0:
        print("PASS: Zero quantity detected.")
    else:
        print("FAIL")


def test_future_order_date():
    order_date = datetime(2030, 1, 1)

    if order_date > datetime.now():
        print("PASS: Future order date detected.")
    else:
        print("FAIL")


test_invalid_order_reference()
test_invalid_discount()
test_zero_quantity()
test_future_order_date()