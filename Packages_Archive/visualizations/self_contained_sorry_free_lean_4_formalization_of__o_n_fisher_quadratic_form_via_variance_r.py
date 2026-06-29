from typing import List

def fisher_quadratic_via_variance(pi: List[float], v: List[float]) -> float:
    """Evaluate v^T F v for the softmax Fisher matrix F = diag(pi) - pi pi^T
    in O(n), via its variance realization v^T F v = E_pi[(<v, psi(a)>)^2],
    where the directional score is X(a) = v_a - <v, pi>.

    Returns a value that is nonnegative by construction (a PSD certificate)."""
    vp: float = sum(pa * va for pa, va in zip(pi, v))   # <v, pi>, O(n)
    return sum(pa * (va - vp) ** 2 for pa, va in zip(pi, v))  # E_pi[X^2], O(n)
