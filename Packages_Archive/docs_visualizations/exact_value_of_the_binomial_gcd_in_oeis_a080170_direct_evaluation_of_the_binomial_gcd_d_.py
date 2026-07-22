from functools import reduce
from math import comb, gcd

def binom_gcd(k: int) -> int:
    """D(k) = gcd over 2 <= q <= k+1 of C(q*k, k) (OEIS A080170)."""
    if k < 2:
        raise ValueError('A080170 is indexed from k >= 2')
    g = comb(2 * k, k)
    for q in range(3, k + 2):
        g = gcd(g, comb(q * k, k))
        if g == 1:
            return 1
    return g
