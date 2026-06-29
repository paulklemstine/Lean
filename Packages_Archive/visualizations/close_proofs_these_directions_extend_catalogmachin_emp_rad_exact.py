from __future__ import annotations
import itertools
from typing import Iterable, Sequence, Tuple

Vector = Sequence[float]
SignPattern = Tuple[int, ...]

def all_sign_patterns(n: int) -> Iterable[SignPattern]:
    """Yield all 2^n sign patterns in {+1, -1}^n."""
    for bits in itertools.product((1, -1), repeat=n):
        yield bits

def corr(sigma: SignPattern, v: Vector) -> float:
    """Correlation <sigma, v> = sum_i sigma_i * v_i."""
    return sum(s * x for s, x in zip(sigma, v))

def emp_rad(F: Sequence[Vector]) -> float:
    """Exact empirical Rademacher complexity of a nonempty finite class F.

    empRad(F) = (1 / (2^n * n)) * sum_sigma max_{v in F} corr(sigma, v).
    Cost: O(2^n * |F| * n).
    """
    if not F:
        raise ValueError("F must be nonempty")
    n = len(F[0])
    if n == 0:
        return 0.0
    total = 0.0
    for sigma in all_sign_patterns(n):
        total += max(corr(sigma, v) for v in F)
    return total / (2 ** n * n)
