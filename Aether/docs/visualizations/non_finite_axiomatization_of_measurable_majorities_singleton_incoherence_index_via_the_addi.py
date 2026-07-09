from math import gcd


def singleton_incoherence_index(n: int, a: int) -> int:
    """Incoherence index of {a} in Z/nZ = additive order of a = n/gcd(n,a)."""
    a %= n
    if a == 0:
        return 1
    return n // gcd(n, a)
