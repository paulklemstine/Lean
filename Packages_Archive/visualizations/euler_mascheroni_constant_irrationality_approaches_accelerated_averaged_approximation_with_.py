import math

def averaged_gamma(n: int) -> float:
    """Accelerated estimate m_n = (ell_n + u_n)/2 with O(1/n^2) error."""
    H: float = sum(1.0 / k for k in range(1, n + 1))
    ell: float = H - math.log(n + 1)
    u: float = H - math.log(n)
    return 0.5 * (ell + u)
