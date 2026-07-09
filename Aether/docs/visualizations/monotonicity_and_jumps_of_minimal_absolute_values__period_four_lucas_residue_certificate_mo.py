from __future__ import annotations
from typing import List

def lucas_residues_mod5(count: int) -> List[int]:
    """Return L_0..L_{count-1} modulo 5, cycling through 2,1,3,4 with period 4.

    Uses the four-step recurrence L_{n+4} = 2 L_n + 3 L_{n+1} implicitly via the
    base recurrence; the output certifies that 0 never appears, i.e. 5 never
    divides a Lucas number.  Complexity O(count).
    """
    r: List[int] = []
    a, b = 2 % 5, 1 % 5
    for _ in range(count):
        r.append(a)
        a, b = b, (a + b) % 5
    return r

def five_divides_some_lucas(bound: int) -> bool:
    """True iff 5 divides L_n for some n < bound (always False)."""
    return 0 in lucas_residues_mod5(bound)
