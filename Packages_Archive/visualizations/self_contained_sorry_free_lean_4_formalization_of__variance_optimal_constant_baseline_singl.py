from typing import List, Tuple

def optimal_baseline(pi: List[float], R: List[float], s: List[float]) -> Tuple[float, float]:
    """Compute the variance-optimal constant baseline b* = E_pi[R s^2] / E_pi[s^2]
    and the residual second moment M(b*) = C - B^2/A, in a single O(n) pass.

    A = E_pi[s^2], B = E_pi[R s^2], C = E_pi[R^2 s^2]."""
    A = sum(p * si * si for p, si in zip(pi, s))
    B = sum(p * Ri * si * si for p, Ri, si in zip(pi, R, s))
    C = sum(p * Ri * Ri * si * si for p, Ri, si in zip(pi, R, s))
    if A <= 0.0:
        raise ValueError("score has zero variance; baseline is irrelevant")
    b_star = B / A
    m_star = C - B * B / A
    return b_star, m_star
