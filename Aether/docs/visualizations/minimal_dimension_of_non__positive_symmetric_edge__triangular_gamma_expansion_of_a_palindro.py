from fractions import Fraction
from math import comb
from typing import List

def gamma_basis(n: int, i: int) -> List[Fraction]:
    """Coefficient vector of B_{n,i}(t) = t^i (1+t)^(n-2i)."""
    assert 2 * i <= n
    coeffs = [Fraction(0)] * (n + 1)
    top = n - 2 * i
    for k in range(i, n + 1):
        j = k - i
        if 0 <= j <= top:
            coeffs[k] = Fraction(comb(top, j))
    return coeffs

def gamma_vector(coeffs: List[Fraction], n: int) -> List[Fraction]:
    """Peel off gamma-coefficients from lowest degree upward using the fact that
    [t^i] B_{n,i} = 1 and lower-index blocks vanish in degree i after subtraction."""
    c = list(coeffs) + [Fraction(0)] * (n + 1 - len(coeffs))
    residual = [Fraction(x) for x in c]
    gammas: List[Fraction] = []
    for i in range(n // 2 + 1):
        basis = gamma_basis(n, i)
        gi = residual[i]
        gammas.append(gi)
        for k in range(len(basis)):
            residual[k] -= gi * basis[k]
    return gammas

def is_gamma_positive(coeffs: List[Fraction], n: int) -> bool:
    c = list(coeffs) + [Fraction(0)] * (n + 1 - len(coeffs))
    if any(c[k] != c[n - k] for k in range(n + 1)):
        return False  # not palindromic -> no gamma-expansion
    return all(g >= 0 for g in gamma_vector(c, n))
