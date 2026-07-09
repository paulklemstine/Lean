from typing import List

def closed_form_bound(a: float, b: float, d0: float, k: int) -> float:
    """Exact closed-form upper bound on the worst simplex diameter after k rounds.

    Implements Theorem `d_le_closedForm`:
        d_k <= a**k * d0 + b * (1 - a**k) / (1 - a),   0 <= a < 1, b >= 0.
    """
    if not (0.0 <= a < 1.0):
        raise ValueError("contraction factor a must satisfy 0 <= a < 1")
    if b < 0.0:
        raise ValueError("additive defect b must be nonnegative")
    return a ** k * d0 + b * (1.0 - a ** k) / (1.0 - a)

def fixed_point(a: float, b: float) -> float:
    """Attractor radius L = b/(1-a) (Lean `fixedPoint`)."""
    return b / (1.0 - a)

def steps_to_reach(a: float, b: float, d0: float, eps: float) -> int:
    """Smallest N with closed_form_bound <= L + eps for all k >= N (Lean `exists_steps_below`).

    Since the transient is a**k * (d0 - L), solve a**N * |d0 - L| <= eps.
    """
    import math
    L = fixed_point(a, b)
    gap = abs(d0 - L)
    if gap <= eps or a == 0.0:
        return 0
    return max(0, math.ceil(math.log(eps / gap) / math.log(a)))

def trajectory_bounds(a: float, b: float, d0: float, n: int) -> List[float]:
    """Vector of closed-form bounds [d_0_bound, ..., d_n_bound]."""
    return [closed_form_bound(a, b, d0, k) for k in range(n + 1)]
