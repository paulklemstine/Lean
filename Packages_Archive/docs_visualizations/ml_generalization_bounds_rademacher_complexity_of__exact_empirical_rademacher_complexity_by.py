from itertools import product
from typing import List, Sequence, Tuple

Vector = Tuple[float, ...]

def emp_rad(klass: Sequence[Vector]) -> float:
    """Exact empirical Rademacher complexity of a finite nonempty class.

    Returns (1/2^n) * sum_sigma max_{a in klass} (1/n) sum_i sigma_i a_i,
    where sigma ranges over all 2^n sign patterns in {-1,+1}^n.
    """
    if not klass:
        raise ValueError("class must be nonempty")
    n = len(klass[0])
    if n == 0:
        return 0.0
    total = 0.0
    for signs in product((-1.0, 1.0), repeat=n):
        best = max(sum(s * a_i for s, a_i in zip(signs, a)) / n for a in klass)
        total += best
    return total / (2 ** n)
