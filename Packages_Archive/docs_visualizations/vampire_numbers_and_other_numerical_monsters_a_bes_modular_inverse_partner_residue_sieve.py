from math import gcd
from typing import Optional

def required_partner_residue(x: int, base: int) -> Optional[int]:
    """Return the unique required residue of y modulo base-1, or None."""
    if base < 2: raise ValueError("base must be at least 2")
    m = base - 1
    if m == 1: return 0
    u = (x - 1) % m
    if gcd(u, m) != 1: return None
    return (1 + pow(u, -1, m)) % m
