def second_moment_zero_bound(mean: float, variance: float) -> float:
    """Upper bound on P(X = 0) given E[X] > 0:  Var(X) / E[X]^2."""
    if mean <= 0.0:
        raise ValueError("second moment method requires E[X] > 0")
    return variance / mean ** 2
