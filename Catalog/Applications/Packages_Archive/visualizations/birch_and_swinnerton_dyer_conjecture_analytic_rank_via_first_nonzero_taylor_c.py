from typing import List

def analytic_rank_from_coeffs(coeffs: List[complex], tol: float = 1e-12) -> int:
    """Analytic rank = index of the first nonzero Taylor coefficient of L at s0.

    Realizes analyticRank_factorization: L(s) = (s - s0)^r * g(s), g(s0) != 0,
    so r is the position of the first nonzero coefficient. Rank 0 corresponds to
    L(s0) = coeffs[0] != 0 (analyticRank_eq_zero_iff)."""
    for n, a in enumerate(coeffs):
        if abs(a) > tol:
            return n
    raise ValueError("function identically zero near s0 (order = infinity)")
