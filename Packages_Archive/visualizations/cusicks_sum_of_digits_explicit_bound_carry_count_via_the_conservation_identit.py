from math import comb

def s2(n: int) -> int:
    """Binary digit sum (Hamming weight) of n >= 0."""
    return bin(n).count("1")

def v2(m: int) -> int:
    """2-adic valuation of m >= 1."""
    e = 0
    while m and m % 2 == 0:
        m //= 2
        e += 1
    return e

def carries(t: int, n: int) -> int:
    """Carry count of binary addition n + t.

    Two provably-equal definitions:
      * Kummer:        v2( C(n+t, t) )
      * Conservation:  s2(t) + s2(n) - s2(n+t)
    Returns the conservation form (O(log) cost), asserting equality with Kummer.
    """
    fast = s2(t) + s2(n) - s2(n + t)
    assert fast == v2(comb(n + t, t))
    return fast
