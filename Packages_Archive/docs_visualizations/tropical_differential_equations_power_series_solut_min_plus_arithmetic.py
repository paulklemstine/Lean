INF = float("inf")

def trop_add(a, b):
    """Tropical addition = min  (lower bounds the order of a sum)."""
    return min(a, b)

def trop_mul(a, b):
    """Tropical multiplication = ordinary addition  (order of a product)."""
    if a == INF or b == INF:
        return INF
    return a + b
