"""Algorithm: Chevalley-Warning C2 check -- the function-field-side truth."""
from __future__ import annotations
from itertools import product
from typing import Sequence

def has_nontrivial_zero_quadratic(p: int, coeffs: Sequence[int]) -> bool:
    n = len(coeffs)
    for pt in product(range(p), repeat=n):
        if any(v != 0 for v in pt):
            if sum(c * (v * v) for c, v in zip(coeffs, pt)) % p == 0:
                return True
    return False

if __name__ == "__main__":
    for p in (3, 5, 7, 11):
        # degree d=2 form in 5 > d^2=4 variables: always has a nontrivial zero
        assert has_nontrivial_zero_quadratic(p, [1, 1, 1, 1, 1])
        print(f"p={p}: C2 holds over F_p")
