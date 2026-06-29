from math import gcd

def fusion_count(n: int) -> int:
    if n == 0:
        return 1
    if n == 1:
        return 2
    a, b = 1, 2
    for _ in range(n - 1):
        a, b = b, a + b
    return b

def chain_commensurability(m: int, n: int) -> int:
    """gcd(fusion m, fusion n) via the Fibonacci gcd identity."""
    g = gcd(m + 2, n + 2)
    assert g >= 2, 'requires gcd(m+2, n+2) >= 2'
    return fusion_count(g - 2)
