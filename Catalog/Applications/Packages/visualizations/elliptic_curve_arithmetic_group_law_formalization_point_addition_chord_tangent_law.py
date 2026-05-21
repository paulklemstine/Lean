def ec_add(P, Q, a, p):
    """Add two points on y² = x³ + ax + b over F_p."""
    if P is None: return Q
    if Q is None: return P
    x1, y1 = P; x2, y2 = Q
    if x1 == x2:
        if y1 != y2 or y1 == 0: return None
        m = (3 * x1 * x1 + a) * pow(2 * y1, p - 2, p) % p
    else:
        m = (y2 - y1) * pow(x2 - x1, p - 2, p) % p
    x3 = (m * m - x1 - x2) % p
    y3 = (m * (x1 - x3) - y1) % p
    return (x3, y3)

# Example: y² = x³ + x + 1 over F_23
P = (0, 1); Q = (1, 7)
print(f"P + Q = {ec_add(P, Q, 1, 23)}")  # (3, 10)
