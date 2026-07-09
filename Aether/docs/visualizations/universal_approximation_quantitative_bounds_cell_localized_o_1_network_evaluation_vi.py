import math
from typing import Callable

Func = Callable[[float], float]

def eval_fast(f: Func, n: int, x: float) -> float:
    """O(1) evaluation using the exact cellwise affine identity."""
    k: int = min(int(math.floor(x * n)), n - 1)
    a: float = k / n
    s: float = n * (f((k + 1) / n) - f(k / n))
    return f(a) + s * (x - a)
