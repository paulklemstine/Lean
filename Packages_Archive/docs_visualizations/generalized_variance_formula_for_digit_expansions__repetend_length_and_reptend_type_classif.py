from math import gcd
from typing import Dict


def multiplicative_order(p: int, b: int) -> int:
    """Return ord_p(b), the least l >= 1 with b^l = 1 (mod p)."""
    if gcd(p, b) != 1:
        raise ValueError("require gcd(p, b) = 1")
    l: int = 1
    x: int = b % p
    while x != 1:
        x = (x * b) % p
        l += 1
    return l


def classify_reptend(p: int, b: int) -> Dict[str, int]:
    """Classify the repetend of 1/p in base b by its length l = ord_p(b),
    the cofactor d = (p-1)/l, and the reptend type (full / half / other).
    """
    l: int = multiplicative_order(p, b)
    d: int = (p - 1) // l if (p - 1) % l == 0 else 0
    if l == p - 1:
        kind: str = "full reptend (b is a primitive root mod p)"
    elif d == 2:
        kind = "half reptend"
    else:
        kind = f"order-{l} reptend, cofactor d={d}"
    return {"length": l, "cofactor_d": d, "type": kind}
