from __future__ import annotations
from typing import List, Optional

Poly = List[float]  # ascending coefficients: [a0, a1, a2, ...]

def _trim(p: Poly) -> Poly:
    q = list(p)
    while q and abs(q[-1]) < 1e-12:
        q.pop()
    return q

def degree(p: Poly) -> int:
    """Degree of a polynomial; the zero polynomial has degree -1."""
    return len(_trim(p)) - 1

def has_polynomial_solution_linear(coeff_q: Poly) -> bool:
    """Decide whether p'' = q * p admits a NONZERO polynomial solution.

    By the degree calculus: if deg q >= 1 then deg(q*p) = deg q + n >= n + 1,
    while deg(p'') <= n - 2, so no nonzero solution exists. If deg q <= 0 the
    classical eigenvalue/Hermite-type analysis applies and solutions may exist.
    Returns True only in the (possible) constant-coefficient case.
    """
    dq = degree(coeff_q)
    if dq >= 1:
        return False          # degree gap forbids any nonzero solution
    return True               # deg q <= 0: not forbidden by degree counting

def riccati_has_polynomial_solution() -> bool:
    """Decide whether u' + u^2 = x has a polynomial solution. Always False:
    for deg u = 0 the LHS has degree <= 0 != 1; for deg u >= 1 the u^2 term
    forces degree 2*deg u >= 2 != 1."""
    return False

def airy_polynomial_certificate(coeff_q: Optional[Poly] = None) -> str:
    """Return a human-readable non-existence certificate for p'' = q*p
    (default q = x, i.e. Airy's equation)."""
    q = [0.0, 1.0] if coeff_q is None else coeff_q
    dq = degree(q)
    if dq >= 1:
        return (f"deg(q*p) = {dq} + n >= n+1 > n-2 >= deg(p''); "
                f"no nonzero polynomial solution.")
    return "deg q <= 0: degree counting does not forbid solutions."
