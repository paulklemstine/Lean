from __future__ import annotations
from typing import List

def poly_eval_real(coeffs: List[float], x: float) -> float:
    """Horner evaluation of a real polynomial; coeffs ascending."""
    r = 0.0
    for c in reversed(coeffs):
        r = r * x + c
    return r

def ivt_root_witness(coeffs: List[float], a: float, b: float,
                     tol: float = 1e-15, iters: int = 200) -> float:
    """Bracket a real root in (a, b) by bisection, faithful to the IVT proof.

    Preconditions: poly_eval_real(coeffs, a) and (...) at b have opposite signs.
    Returns a point z with |poly_eval_real(coeffs, z)| ~ 0; if z > 1 it is a
    spectral-escape witness certifying positive logarithmic Mahler measure.
    """
    fa, fb = poly_eval_real(coeffs, a), poly_eval_real(coeffs, b)
    if fa == 0:
        return a
    if fb == 0:
        return b
    if fa * fb > 0:
        raise ValueError("no sign change: IVT does not apply on this bracket")
    for _ in range(iters):
        m = 0.5 * (a + b)
        fm = poly_eval_real(coeffs, m)
        if fm == 0 or (b - a) < tol:
            return m
        if fa * fm < 0:
            b = m
        else:
            a, fa = m, fm
    return 0.5 * (a + b)
