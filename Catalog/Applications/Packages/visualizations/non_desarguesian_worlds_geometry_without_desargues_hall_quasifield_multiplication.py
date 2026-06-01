def hall_mul(x, y, p=3):
    a, b = x
    c, d = y
    if d % p == 0:
        return ((a * c) % p, (b * c) % p)
    else:
        return ((a * c + b * d) % p, (a * d + (p - 1) * b * c) % p)