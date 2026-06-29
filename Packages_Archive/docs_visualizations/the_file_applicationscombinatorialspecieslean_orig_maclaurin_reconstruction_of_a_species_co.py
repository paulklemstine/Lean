from fractions import Fraction
from typing import Callable, List

def formal_derivative(coeffs: List[Fraction]) -> List[Fraction]:
    return [(n + 1) * coeffs[n + 1] for n in range(len(coeffs) - 1)]

def iterate_derivative(coeffs: List[Fraction], k: int) -> List[Fraction]:
    out = list(coeffs)
    for _ in range(k):
        out = formal_derivative(out)
    return out

def species_maclaurin_reconstruct(egf_coeffs: List[Fraction]) -> List[Fraction]:
    """coeff_0(D^k EGF) = F[k]: recover raw counts, no factorial."""
    N = len(egf_coeffs) - 1
    return [iterate_derivative(egf_coeffs, k)[0] for k in range(N + 1)]
