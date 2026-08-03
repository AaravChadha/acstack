"""Production code for the /audit tests fixture (task 4.10).

Deliberately simple and deliberately UNDER-TESTED: the suite beside it is
green while catching almost nothing, which is the point of the fixture.
"""


def apply_discount(subtotal, percent):
    """Return subtotal with `percent` off, clamped to a sane range."""
    if subtotal < 0:
        raise ValueError("subtotal must not be negative")
    if not 0 <= percent <= 100:
        raise ValueError("percent must be between 0 and 100")
    return round(subtotal * (100 - percent) / 100, 2)


def cart_total(items):
    """Sum item prices. An empty cart totals 0."""
    return round(sum(i["price"] * i.get("qty", 1) for i in items), 2)
