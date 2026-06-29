from __future__ import annotations
from typing import Callable, Sequence
import math

def willmore_pipeline(
    k1: Sequence[float],
    k2: Sequence[float],
    w: Sequence[float],
    genus: int,
) -> dict[str, float]:
    """Discrete Willmore pipeline (Algorithm 8.1).

    Given per-vertex principal curvatures (k1, k2) and area weights w on a
    triangulated closed surface of given genus, compute the Willmore energy W,
    the total Gaussian curvature integral(K), the total umbilic defect, verify
    the square identity and balance identity, and report the elementary
    Gauss-Bonnet floor b(g) = 2*pi*chi.  Runs in O(V) time, O(1) extra space.
    """
    assert len(k1) == len(k2) == len(w)
    W = 0.0
    K_total = 0.0
    D_total = 0.0
    max_identity_err = 0.0
    for a, b, wi in zip(k1, k2, w):
        H2 = ((a + b) / 2.0) ** 2          # Willmore density
        K = a * b                          # Gaussian curvature
        D = ((a - b) / 2.0) ** 2           # umbilic defect
        max_identity_err = max(max_identity_err, abs((H2 - K) - D))
        W += wi * H2
        K_total += wi * K
        D_total += wi * D
    chi = 2 - 2 * genus
    floor = 2.0 * math.pi * chi            # b(g) = 4*pi*(1 - g)
    return {
        "willmore_energy": W,
        "total_gauss": K_total,
        "total_defect": D_total,
        "balance_residual": (W - K_total) - D_total,   # should be ~ 0
        "gauss_le_willmore": float(K_total <= W + 1e-12),
        "euler_char": float(chi),
        "elementary_floor": floor,
        "floor_meets_energy": float(floor <= W + 1e-12),
        "max_pointwise_identity_error": max_identity_err,
    }