from __future__ import annotations
import cmath, math
from typing import Tuple

def local_factor_roots(q: float, lam: float) -> Tuple[complex, complex]:
    """Roots of the Ihara local factor q*u^2 - lambda*u + 1."""
    sqrt_disc = cmath.sqrt(complex(lam * lam - 4.0 * q))
    return (lam + sqrt_disc) / (2.0 * q), (lam - sqrt_disc) / (2.0 * q)

def classify_eigenvalue(q: float, lam: float) -> str:
    """Classify a local factor by the sign of the discriminant lambda^2 - 4q."""
    disc = lam * lam - 4.0 * q
    r1, r2 = local_factor_roots(q, lam)
    crit = 1.0 / math.sqrt(q)
    on_circle = abs(abs(r1) - crit) < 1e-9 and abs(abs(r2) - crit) < 1e-9
    if disc < -1e-12:
        return f"complex-conjugate roots ON circle (|u|={crit:.4f}); RH-OK"
    if abs(disc) <= 1e-12:
        return f"double real root ON circle (boundary lambda=+-2sqrt(q)); RH-OK"
    return f"split real roots, one OFF circle; RH-VIOLATED (on_circle={on_circle})"
