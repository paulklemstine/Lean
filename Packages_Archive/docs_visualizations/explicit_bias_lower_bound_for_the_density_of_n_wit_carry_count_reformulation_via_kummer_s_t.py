from math import comb

def v2(n: int) -> int:
    """2-adic valuation of n (v2(0) := 0)."""
    if n == 0:
        return 0
    k = 0
    while n % 2 == 0:
        n //= 2
        k += 1
    return k

def carries(t: int, n: int) -> int:
    """Number of base-2 carries in n + t, via Kummer: v2( C(n+t, t) )."""
    return v2(comb(n + t, t))

def cusick_via_carries(t: int, n: int) -> bool:
    """Decide s2(n) <= s2(n+t) using the carry reformulation:
    s2(n) <= s2(n+t) <=> carries(t, n) <= s2(t)."""
    s2t = bin(t).count("1")
    return carries(t, n) <= s2t
