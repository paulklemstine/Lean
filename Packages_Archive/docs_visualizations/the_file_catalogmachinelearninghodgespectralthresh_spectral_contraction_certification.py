from typing import Tuple

def contraction_factor(alpha: float, mu: float, lam: float) -> float:
    """rho = 1 - alpha*mu*(2 - alpha*lam): the certified per-layer energy
    contraction factor. Returns a value in [0, 1) when 0 < alpha < 2/lam, mu > 0."""
    return 1.0 - alpha * mu * (2.0 - alpha * lam)

def certify_contraction(mu: float, lam: float,
                        alpha: float) -> Tuple[bool, float]:
    """Check the admissible-step condition 0 < alpha < 2/lam and return
    (is_contractive, rho)."""
    admissible = 0.0 < alpha < 2.0 / lam
    rho = contraction_factor(alpha, mu, lam)
    is_contractive = admissible and (0.0 <= rho < 1.0)
    return is_contractive, rho
