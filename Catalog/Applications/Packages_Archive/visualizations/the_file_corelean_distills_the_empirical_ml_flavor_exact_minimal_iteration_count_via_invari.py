from fractions import Fraction

def Nmin(rho: Fraction, eps: Fraction) -> int:
    """Exact minimal iteration count: least n with rho**n <= eps.

    rho, eps must lie in the open interval (0, 1).
    Complexity: O(Nmin) = O(log(1/eps)/g) exact rational multiplications,
    where g = 1 - rho is the spectral gap.
    """
    if not (0 < rho < 1):
        raise ValueError("rho must lie in (0, 1)")
    if not (0 < eps < 1):
        raise ValueError("eps must lie in (0, 1)")
    n: int = 0
    p: Fraction = Fraction(1)
    while p > eps:
        p *= rho
        n += 1
    return n
