from typing import Dict, List

def gcd(a: int, b: int) -> int:
    while b:
        a, b = b, a % b
    return abs(a)

def units_mod(n: int) -> List[int]:
    return [a for a in range(1, n) if gcd(a, n) == 1]

def artin_iso_forward(sigma_exponent: int, n: int) -> int:
    """Map the automorphism zeta_n |-> zeta_n^a of Gal(Q(zeta_n)/Q) to a in (Z/nZ)^x."""
    a = sigma_exponent % n
    assert gcd(a, n) == 1, "exponent must be a unit"
    return a

def artin_iso_inverse(a: int, n: int) -> int:
    """Map a unit a to the automorphism described by the exponent a (returned as a)."""
    a %= n
    assert gcd(a, n) == 1
    return a

def galois_group(n: int) -> Dict[int, int]:
    """Realize Gal(Q(zeta_n)/Q) as (Z/nZ)^x: unit -> automorphism exponent."""
    return {a: a for a in units_mod(n)}
