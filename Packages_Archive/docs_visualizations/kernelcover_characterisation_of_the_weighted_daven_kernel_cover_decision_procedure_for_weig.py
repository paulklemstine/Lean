from itertools import product
from typing import List, Sequence, Tuple

def is_admissible(coeffs: Sequence[int], weight_set: Sequence[int]) -> bool:
    """Admissible: each coefficient is 0 (skip) or a genuine weight, and at
    least one coefficient is non-zero."""
    allowed = {0, *weight_set}
    if any(c not in allowed for c in coeffs):
        return False
    return any(c != 0 for c in coeffs)

def weighted_kernel_cover(n: int, m: int, weight_set: Sequence[int]) -> bool:
    """Decide the kernel-cover property at level n over Z/m for weight set W.

    For every x in (Z/m)^n we ask whether some admissible induced homomorphism
    Phi(x) = sum_i c_i x_i vanishes.  Complexity O(|Z/m|^n * (|W|+1)^n)."""
    allowed_coeffs: List[int] = [0, *weight_set]
    admissible: List[Tuple[int, ...]] = [
        c for c in product(allowed_coeffs, repeat=n) if is_admissible(c, weight_set)
    ]
    for x in product(range(m), repeat=n):
        if not any(sum(c * xi for c, xi in zip(coeffs, x)) % m == 0
                   for coeffs in admissible):
            return False
    return True
