from math import gcd

def multiplicative_order(a: int, m: int) -> int:
    """Least k >= 1 with a^k == 1 (mod m); requires gcd(a, m) == 1."""
    if gcd(a, m) != 1:
        raise ValueError("requires gcd(a, m) == 1")
    k, x = 1, a % m
    while x != 1:
        x = (x * a) % m
        k += 1
    return k

def primitive_root(p: int) -> int:
    """A primitive root g mod prime p, i.e. ord_p(g) = p - 1."""
    for g in range(2, p):
        if multiplicative_order(g, p) == p - 1:
            return g
    raise RuntimeError("p must be prime")
