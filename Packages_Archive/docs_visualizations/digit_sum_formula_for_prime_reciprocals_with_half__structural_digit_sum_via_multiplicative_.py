from typing import Optional

def multiplicative_order(b: int, p: int) -> int:
    """Least l >= 1 with b^l == 1 (mod p); requires p not dividing b."""
    if p <= 1 or b % p == 0:
        raise ValueError("require p > 1 and p coprime to b")
    value, l = 1 % p, 0
    for l in range(1, p):
        value = (value * b) % p
        if value == 1:
            return l
    raise ValueError("no order found")

def structural_digit_sum(p: int, b: int, m: int) -> Optional[int]:
    """Return (b-1)(p-1)/2^(m+1) if (p,b,m) admissible, else None.

    Admissible: ord_p(b) == (p-1)/2^m and 2^(m+1) | (p-1) (i.e. even period).
    Cost: one order computation, no materialization of the l-digit period.
    """
    if b % p == 0:
        return None
    l = multiplicative_order(b, p)
    if (p - 1) % (2 ** m) != 0 or l != (p - 1) // (2 ** m):
        return None
    if (p - 1) % (2 ** (m + 1)) != 0:
        return None
    return (b - 1) * (p - 1) // (2 ** (m + 1))
