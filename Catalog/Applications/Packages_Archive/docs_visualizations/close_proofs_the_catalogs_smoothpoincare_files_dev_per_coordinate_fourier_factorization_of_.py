from __future__ import annotations
from typing import Tuple

Vector = Tuple[int, ...]
I = complex(0, 1)

def weight(y: Vector) -> int:
    return sum(1 for b in y if b == 1)

def fourier_iwt(y: Vector) -> complex:
    """Closed form of the DFT of x |-> i^{wt(x)} at y:
       (1+i)^{n-wt(y)} (1-i)^{wt(y)}.  Collapses to (1+i)^n if 4 | wt(y)."""
    n = len(y); w = weight(y)
    return (1 + I) ** (n - w) * (1 - I) ** w

def fourier_iwt_doubly_even(y: Vector) -> complex:
    assert weight(y) % 4 == 0, "y must be doubly-even"
    return (1 + I) ** len(y)
