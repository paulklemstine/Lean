from typing import List, Tuple

def refine_segment(D: float, K: int) -> Tuple[List[float], float]:
    """Bisect a segment K times (minicenter = midpoint); lambda = 2."""
    d, trajectory, total = D, [], 0.0
    for _ in range(K):
        trajectory.append(d)
        total += d
        m = 0.5 * (0.0 + d)   # midpoint = minicenter
        d = d - m             # child length = d / 2
    return trajectory, total
