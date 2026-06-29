import math

def required_samples(C: float, delta: float, eps: float) -> int:
    """Smallest n with perturbedBound <= R + L*rho + eps."""
    if eps <= 0:
        raise ValueError("eps must be positive")
    return math.ceil((C + math.log(1.0 / delta)) / (2.0 * eps ** 2))
