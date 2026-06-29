def separation_budget(k: int, K: float, eps: float) -> float:
    """The budget K*2^-k + 2*eps from relu_depth_separation."""
    return K * (0.5 ** k) + 2.0 * eps


def separation_certificate(k: int, K: float, eps: float) -> bool:
    """True iff the theorem certifies no K-Lipschitz function eps-approximates tent^[k]."""
    return separation_budget(k, K, eps) < 1.0