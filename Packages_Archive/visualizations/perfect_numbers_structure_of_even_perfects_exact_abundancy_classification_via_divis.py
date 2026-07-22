from fractions import Fraction
from math import isqrt

def classify(n: int) -> str:
    """Classify n as 'deficient', 'perfect', or 'abundant' via A(n)=sigma(n)/n."""
    if n <= 0:
        raise ValueError('n must be positive')
    s: int = 0
    for d in range(1, isqrt(n) + 1):
        if n % d == 0:
            s += d
            if d != n // d:
                s += n // d
    a: Fraction = Fraction(s, n)
    if a < 2:
        return 'deficient'
    if a == 2:
        return 'perfect'
    return 'abundant'