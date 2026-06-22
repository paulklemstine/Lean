from math import gcd

def miller_rabin_witness(a: int, n: int) -> bool:
    """Return True iff base a is a Miller-Rabin witness proving n COMPOSITE.
    This is the repair of the Fermat test that detects Carmichael numbers by
    probing nontrivial square roots of 1 along a^((n-1)/2^j)."""
    if n % 2 == 0:
        return n != 2
    d, r = n - 1, 0
    while d % 2 == 0:
        d //= 2
        r += 1
    x = pow(a, d, n)
    if x in (1, n - 1):
        return False
    for _ in range(r - 1):
        x = (x * x) % n
        if x == n - 1:
            return False
    return True
