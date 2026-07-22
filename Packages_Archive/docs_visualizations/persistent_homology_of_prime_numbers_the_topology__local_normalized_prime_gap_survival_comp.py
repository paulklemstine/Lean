from math import exp
from typing import Sequence

def ks_to_unit_exponential(values: Sequence[float]) -> float:
    xs = sorted(values)
    if not xs: raise ValueError("empty sample")
    n = len(xs)
    return max(max(abs(i/n-(1-exp(-x))), abs((i-1)/n-(1-exp(-x))))
               for i, x in enumerate(xs, 1))

normalized = [0.4, 0.8, 0.8, 1.6, 0.8]
print(f"KS distance: {ks_to_unit_exponential(normalized):.4f}")
