from typing import Callable, Dict, Hashable, List

def idempotent_cgf(
    weight: Dict[Hashable, float],
    val: Callable[[Hashable], float],
    lam: float,
) -> float:
    """Idempotent cumulant generating function (idempotentCGF):
        Lambda(lam) = max_x (lam * val(x) + w(x)).
    Convex in lam (idempotentCGF_convex), additive under independent products
    (idempotentCGF_add), and scales as n*Lambda for the n-step walk
    (idempotentCGF_walk). Runs in O(|X|) per evaluation."""
    return max(lam * val(x) + w for x, w in weight.items())

def lf_biconjugate(
    weight: Dict[Hashable, float],
    val: Callable[[Hashable], float],
    a: float,
    grid: List[float],
) -> float:
    """Legendre-Fenchel biconjugate (lfBiconj):
        I**(a) = sup_lam (lam * a - Lambda(lam)),
    the largest convex lower bound of the rate function, approximated over a finite
    grid of slopes. By lfBiconj_le_rate this never exceeds I; equality requires a
    supporting line (lfBiconj_eq_rate_of_support)."""
    return max(lam * a - idempotent_cgf(weight, val, lam) for lam in grid)
