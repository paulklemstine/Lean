import math

def eigenvalue(a: float, r: float) -> float:
    """Dispersion relation lambda(a, r) = (1 - 2a) + a (r + 1/r)."""
    return (1.0 - 2.0 * a) + a * (r + 1.0 / r)

def amplification(a: float, r: float, n: int) -> float:
    """n-step amplification of the geometric mode r: lambda(a, r)**n."""
    return eigenvalue(a, r) ** n

def spectral_radius(a: float, n_angles: int = 2001) -> float:
    """max_theta |lambda(a, e^{i theta})| = max |1 - 2a(1 - cos theta)|."""
    best = 0.0
    for k in range(n_angles):
        theta = math.pi * k / (n_angles - 1)
        best = max(best, abs(1.0 - 2.0 * a * (1.0 - math.cos(theta))))
    return best
