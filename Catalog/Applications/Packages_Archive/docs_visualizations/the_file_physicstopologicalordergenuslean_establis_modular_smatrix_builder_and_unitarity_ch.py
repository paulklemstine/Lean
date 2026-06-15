from __future__ import annotations

import cmath
import math
from itertools import product
from typing import Callable, List, Sequence, Tuple

Element = Tuple[int, ...]


def group_elements(orders: Sequence[int]) -> List[Element]:
    """Enumerate A = Z_{n_1} x ... x Z_{n_k}."""
    return list(product(*[range(n) for n in orders]))


def build_smatrix(
    orders: Sequence[int],
    beta: Callable[[Element, Element], float],
) -> List[List[complex]]:
    """Assemble S_{a,b} = (1/sqrt d) exp(2 pi i beta(a,b)) for an abelian group.

    `beta(a,b)` is the braiding phase fraction in R/Z. Complexity O(d^2).
    """
    els = group_elements(orders)
    d = len(els)
    norm = 1.0 / math.sqrt(d)
    return [[norm * cmath.exp(2j * math.pi * beta(a, b)) for b in els] for a in els]


def check_unitary(S: List[List[complex]], tol: float = 1e-9) -> bool:
    """Verify S S^dagger = I, i.e. rows are orthonormal. Complexity O(d^2) per row."""
    d = len(S)
    for a in range(d):
        for b in range(d):
            acc = sum(S[a][c] * S[b][c].conjugate() for c in range(d))
            if abs(acc - (1.0 if a == b else 0.0)) > tol:
                return False
    return True
