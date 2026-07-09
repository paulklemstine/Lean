"""Algorithm: compute and certify the local GL2 Frobenius datum at (a, p)."""

from __future__ import annotations

import cmath
import math
from dataclasses import dataclass
from typing import List, Optional, Tuple


@dataclass
class LocalDatum:
    """The complete local Frobenius datum of the Hecke polynomial X^2 - a X + p."""
    a: float
    p: float
    matrix: List[List[float]]
    trace: float
    det: float
    discriminant: float
    deligne_ok: bool
    modulus: Optional[float]
    sato_tate_angle: Optional[float]
    alpha: Optional[complex]
    beta: Optional[complex]


def local_frobenius_datum(a: float, p: float) -> LocalDatum:
    """Build the local Frobenius datum and check the Deligne (Weil) bound.

    The companion matrix [[0, -p], [1, a]] has trace a, determinant p, and
    characteristic polynomial X^2 - a X + p. When a^2 <= 4p the two eigenvalues
    are complex conjugates of modulus sqrt(p) (Weil numbers of weight one), with
    Sato-Tate angle theta = arccos(a / (2 sqrt(p))). Runs in O(1) field ops.
    """
    if p <= 0.0:
        raise ValueError("p must be positive (Weil weight-one needs p > 0)")
    matrix = [[0.0, -p], [1.0, a]]
    trace = matrix[0][0] + matrix[1][1]            # = a
    det = matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0]  # = p
    disc = a * a - 4.0 * p
    deligne_ok = disc <= 0.0
    sq = cmath.sqrt(complex(disc))
    alpha = (a + sq) / 2.0
    beta = (a - sq) / 2.0
    if deligne_ok:
        modulus: Optional[float] = math.sqrt(p)
        theta: Optional[float] = math.acos(max(-1.0, min(1.0, a / (2.0 * math.sqrt(p)))))
    else:
        modulus, theta = None, None
    return LocalDatum(a, p, matrix, trace, det, disc, deligne_ok,
                      modulus, theta, alpha, beta)


def verify_root_on_circle(a: float, p: float, z: complex, eps: float = 1e-9) -> bool:
    """Certify |z| = sqrt(p) for a root z of X^2 - a X + p (Theorem deligne_root_abs)."""
    x, y = z.real, z.imag
    if abs(z * z - a * z + p) > 1e-6:
        return False
    if abs(y) > eps:
        return abs(a - 2.0 * x) < 1e-6 and abs(x * x + y * y - p) < 1e-6
    return abs(x * x - p) < 1e-6


if __name__ == "__main__":
    d = local_frobenius_datum(3.0, 11.0)
    print(d)
    print("alpha on circle:", verify_root_on_circle(3.0, 11.0, d.alpha))
