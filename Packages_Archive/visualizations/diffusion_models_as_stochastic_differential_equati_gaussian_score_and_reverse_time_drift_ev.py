def gaussian_score(m: float, sigma: float, x: float) -> float:
    """Gaussian score d/dx log p(x) = -(x - m) / sigma^2."""
    return -(x - m) / sigma ** 2


def vp_reverse_drift(x: float, m: float, sigma: float) -> float:
    """Reverse-time VP-OU drift evaluated on a Gaussian marginal N(m, sigma^2).

    The Anderson reverse SDE for dX = -(1/2) X dt + dW is
        dX = [-(1/2) X - score(X)] dt + dWbar,
    so the (deterministic part of the) reverse drift is -(1/2) x - score.
    Complexity: O(1) per evaluation.
    """
    return -0.5 * x - gaussian_score(m, sigma, x)
