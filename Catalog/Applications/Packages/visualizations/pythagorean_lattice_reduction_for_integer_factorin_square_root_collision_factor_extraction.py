import math
def gcd_factor_extract(n, x, y):
    if (x*x - y*y) % n != 0: return None
    if (x - y) % n == 0 or (x + y) % n == 0: return None
    d = math.gcd(abs(x - y), n)
    if 1 < d < n: return d
    d = math.gcd(abs(x + y), n)
    if 1 < d < n: return d
    return None

# Example: factor 91
print(gcd_factor_extract(91, 10, 3))  # Output: 7
