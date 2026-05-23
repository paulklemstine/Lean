def scalar_mul(n, P, a, p):
    """Compute nP using double-and-add. O(log n) group operations."""
    result = None
    addend = P
    while n > 0:
        if n & 1:
            result = ec_add(result, addend, a, p)
        addend = ec_add(addend, addend, a, p)
        n >>= 1
    return result

def ec_add(P, Q, a, p):
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

# Example: 7 * (0,1) on y² = x³ + x + 1 over F_23
P = (0, 1)
for k in [1,2,3,7,14,28]:
    print(f"{k}P = {scalar_mul(k, P, 1, 23)}")
