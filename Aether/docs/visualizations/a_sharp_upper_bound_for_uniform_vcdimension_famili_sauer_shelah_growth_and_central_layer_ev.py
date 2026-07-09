from math import comb
from typing import Tuple

def sauer_shelah_sum(n: int, d: int) -> int:
    """layeredSum(n, d) = sum_{k=0}^{d} C(n, k)."""
    return sum(comb(n, k) for k in range(d + 1))

def central_layer(n: int, d: int) -> int:
    """Mformula(n, d) = C(n, floor(d/2))."""
    return comb(n, d // 2)

def growth_report(n: int, d: int) -> Tuple[int, int, int]:
    """Return (Mformula, layeredSum, 2^n) and assert the chain of bounds."""
    m = central_layer(n, d)
    s = sauer_shelah_sum(n, d)
    p = 2 ** n
    assert m <= s, "central layer must be a summand of the Sauer-Shelah sum"
    if d <= n:
        assert s <= p, "Sauer-Shelah sum must not exceed 2^n"
    return m, s, p
