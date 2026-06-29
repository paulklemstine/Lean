from typing import Sequence, Tuple

def cramer_rao(p: Sequence[float], score: Sequence[float],
               T: Sequence[float], tol: float = 1e-9
               ) -> Tuple[float, float, bool]:
    """Return (CR bound psi'^2/G00, efficiency residual, is_efficient)."""
    n = len(p)
    ET = sum(p[x] * T[x] for x in range(n))
    var_T = sum(p[x] * (T[x] - ET) ** 2 for x in range(n))
    psi_prime = sum(p[x] * T[x] * score[x] for x in range(n))
    G00 = sum(p[x] * score[x] * score[x] for x in range(n))
    bound = psi_prime ** 2 / G00
    residual = var_T - bound
    ratios = [(T[x] - ET) / score[x] for x in range(n) if abs(score[x]) > tol]
    is_efficient = (max(ratios) - min(ratios) < tol) if ratios else False
    return bound, residual, is_efficient
