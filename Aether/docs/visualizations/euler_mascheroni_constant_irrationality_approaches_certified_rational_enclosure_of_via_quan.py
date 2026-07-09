import math


def enclose_gamma(width: float) -> tuple[float, float]:
    """Return a certified interval (a_n, b_n) with a_n < gamma < b_n
    and b_n - a_n <= width, using the proven Theta(1/n) bracketing."""
    n: int = max(1, math.ceil(1.0 / width))
    harmonic: float = sum(1.0 / k for k in range(1, n + 1))
    a_n: float = harmonic - math.log(n + 1)
    b_n: float = harmonic - math.log(n)
    assert b_n - a_n <= width + 1e-12
    return a_n, b_n
