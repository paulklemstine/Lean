from math import gcd

def element_order(a: int, n: int) -> int:
    """Multiplicative order of a unit a modulo n: least k>0 with a^k = 1 (mod n).
    This realizes the lemma 'order divides any annihilating exponent': the
    returned value always divides every e with a^e = 1 (mod n)."""
    if gcd(a, n) != 1:
        raise ValueError(f"{a} is not a unit modulo {n}")
    k, cur = 1, a % n
    while cur != 1:
        cur = (cur * a) % n
        k += 1
    return k
