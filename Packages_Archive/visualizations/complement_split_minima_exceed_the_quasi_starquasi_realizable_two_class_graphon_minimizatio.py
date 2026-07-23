from typing import Tuple

def grid_min_two_class(k: int, beta: float, n: int = 120
                       ) -> Tuple[float, Tuple[float, float, float, float]]:
    """Minimize S_{k,1} over realizable two-class graphons of density beta."""
    best_val: float = float('inf')
    best: Tuple[float, float, float, float] = (0.0, 0.0, 0.0, 0.0)
    for i in range(1, n):
        a: float = i / n
        denom: float = 2.0 * a * (1.0 - a)
        for jp in range(n + 1):
            p: float = jp / n
            for jr in range(n + 1):
                r: float = jr / n
                q: float = (beta - a*a*p - (1.0-a)**2 * r) / denom
                if q < -1e-12 or q > 1.0 + 1e-12:
                    continue
                d1: float = a*p + (1.0-a)*q
                d2: float = a*q + (1.0-a)*r
                val: float = a*d1**k*(1.0-d1) + (1.0-a)*d2**k*(1.0-d2)
                if val < best_val:
                    best_val, best = val, (a, p, q, r)
    return best_val, best
