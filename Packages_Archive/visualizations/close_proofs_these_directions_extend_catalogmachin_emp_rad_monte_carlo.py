from __future__ import annotations
import random
from typing import Sequence, Tuple

Vector = Sequence[float]

def corr(sigma: Tuple[int, ...], v: Vector) -> float:
    return sum(s * x for s, x in zip(sigma, v))

def emp_rad_monte_carlo(F: Sequence[Vector], num_samples: int,
                        seed: int = 0) -> float:
    """Unbiased Monte-Carlo estimate of empRad(F) over sampled sign patterns.

    Useful when 2^n is too large to enumerate. Cost: O(num_samples * |F| * n).
    """
    if not F:
        raise ValueError("F must be nonempty")
    n = len(F[0])
    if n == 0:
        return 0.0
    rng = random.Random(seed)
    acc = 0.0
    for _ in range(num_samples):
        sigma = tuple(rng.choice((1, -1)) for _ in range(n))
        acc += max(corr(sigma, v) for v in F)
    return acc / (num_samples * n)
