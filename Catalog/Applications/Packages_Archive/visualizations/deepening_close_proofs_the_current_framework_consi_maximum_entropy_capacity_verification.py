from __future__ import annotations
import math
import random
from typing import Sequence

def neg_mul_log(x: float) -> float:
    return 0.0 if x <= 0.0 else -x * math.log(x)

def entropy(p: Sequence[float]) -> float:
    return sum(neg_mul_log(px) for px in p)

def verify_max_entropy(n: int, trials: int = 10000, seed: int = 0) -> bool:
    """Empirically witness entropy_le_log_card: H(p) <= log n for all p,
    with equality at the uniform distribution. O(trials * n)."""
    random.seed(seed)
    cap = math.log(n)
    for _ in range(trials):
        raw = [random.random() for _ in range(n)]
        s = sum(raw)
        p = [x / s for x in raw]
        if entropy(p) > cap + 1e-9:
            return False
    uniform = [1.0 / n] * n
    return abs(entropy(uniform) - cap) < 1e-12
