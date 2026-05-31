"""
Hyperbolic Number Theory: Algorithms for Arithmetic on the Poincaré Disk

Core implementations of hyperbolic geometry, lattice counting,
and the hyperbolic zeta function for PSL(2,Z).
"""

import math
import cmath
from typing import List, Tuple, Optional


def poincare_cf(z: complex) -> float:
    """Poincaré conformal factor λ(z) = 2 / (1 - |z|²)."""
    r2 = abs(z) ** 2
    if r2 >= 1.0:
        return float('inf')
    return 2.0 / (1.0 - r2)


def mobius_map(a: complex, z: complex) -> complex:
    """Möbius automorphism φ_a(z) = (z - a) / (1 - conj(a)*z)."""
    denom = 1.0 - a.conjugate() * z
    if abs(denom) < 1e-15:
        return complex(float('inf'), 0)
    return (z - a) / denom


def hyp_dist(z: complex, w: complex) -> float:
    """Hyperbolic distance d_H(z, w) = 2 * artanh(|φ_w(z)|)."""
    t = abs(mobius_map(w, z))
    if t >= 1.0:
        return float('inf')
    return 2.0 * math.atanh(t)


def hyp_area(R: float) -> float:
    """Hyperbolic area of a disk of radius R: A(R) = 2π(cosh R - 1)."""
    return 2.0 * math.pi * (math.cosh(R) - 1.0)


def upper_half_to_disk(z: complex) -> complex:
    """Map from upper half-plane to Poincaré disk: w = (z - i)/(z + i)."""
    return (z - 1j) / (z + 1j)


def disk_to_upper_half(w: complex) -> complex:
    """Map from Poincaré disk to upper half-plane: z = i(1 + w)/(1 - w)."""
    return 1j * (1.0 + w) / (1.0 - w)


def hyp_dist_upper_half(z: complex, w: complex) -> float:
    """Hyperbolic distance in the upper half-plane model.
    d(z,w) = 2 * artanh(|z-w| / |z-conj(w)|).
    """
    num = abs(z - w)
    den = abs(z - w.conjugate())
    if den < 1e-15:
        return float('inf')
    t = num / den
    if t >= 1.0:
        return float('inf')
    return 2.0 * math.atanh(t)


def enumerate_psl2z(R: float) -> List[Tuple[int, int, int, int]]:
    """Enumerate elements [[a,b],[c,d]] of PSL(2,Z) with
    hyperbolic distance from i to γ·i ≤ R in upper half-plane.

    d_H(i, γ·i) = 2 * arccosh((a²+b²+c²+d²) / 2)
    So we need a²+b²+c²+d² ≤ 2*cosh(R).
    """
    bound = 2.0 * math.cosh(R)
    max_val = int(math.sqrt(bound)) + 1
    results = []

    for a in range(-max_val, max_val + 1):
        for b in range(-max_val, max_val + 1):
            for c in range(-max_val, max_val + 1):
                for d in range(-max_val, max_val + 1):
                    if a * d - b * c != 1:
                        continue
                    trace_sq = a * a + b * b + c * c + d * d
                    if trace_sq <= bound:
                        # PSL identification: (a,b,c,d) ~ (-a,-b,-c,-d)
                        if a > 0 or (a == 0 and b > 0) or (a == 0 and b == 0 and c > 0) or \
                           (a == 0 and b == 0 and c == 0 and d > 0):
                            results.append((a, b, c, d))

    return results


def lattice_count_psl2z(R: float) -> int:
    """Count PSL(2,Z) lattice points within hyperbolic radius R of i."""
    return len(enumerate_psl2z(R))


def hyp_zeta_partial(R_max: float, s: float, num_terms: int = 100) -> float:
    """Compute partial sum of hyperbolic zeta function for PSL(2,Z):
    ζ_H(s) = Σ 1/d_H(i, γ·i)^{2s}
    summing over PSL(2,Z) elements with d_H(i, γ·i) ≤ R_max.
    """
    elements = enumerate_psl2z(R_max)
    total = 0.0
    for (a, b, c, d) in elements:
        trace_sq = a * a + b * b + c * c + d * d
        if trace_sq <= 2:
            continue  # Skip identity
        dist = 2.0 * math.acosh(trace_sq / 2.0)
        if dist > 0:
            total += dist ** (-2.0 * s)
    return total


def test_lattice_growth(R_values: List[float]) -> List[Tuple[float, int, float]]:
    """Test the Selberg-Huber lattice growth conjecture for PSL(2,Z).

    Predicts N(R) ~ e^R / (π/3) = 3e^R/π.
    Returns (R, N(R), ratio = N(R)·(π/3)/e^R).
    """
    covolume = math.pi / 3.0
    results = []
    for R in R_values:
        N = lattice_count_psl2z(R)
        ratio = N * covolume / math.exp(R)
        results.append((R, N, ratio))
    return results


def conformal_factor_along_radius(num_points: int = 100) -> List[Tuple[float, float]]:
    """Compute conformal factor along the real axis [0, 0.99]."""
    results = []
    for i in range(num_points):
        r = 0.99 * i / (num_points - 1)
        cf = poincare_cf(complex(r, 0))
        results.append((r, cf))
    return results


def hyp_area_vs_euclidean(R_values: List[float]) -> List[Tuple[float, float, float]]:
    """Compare hyperbolic and Euclidean disk areas.
    Returns (R, A_hyp(R), A_euc(R)) where A_euc uses the
    Euclidean radius corresponding to hyperbolic radius R.
    """
    results = []
    for R in R_values:
        A_hyp = hyp_area(R)
        # Euclidean radius of a hyperbolic disk of radius R centered at origin:
        # r_euc = tanh(R/2)
        r_euc = math.tanh(R / 2.0)
        A_euc = math.pi * r_euc ** 2
        results.append((R, A_hyp, A_euc))
    return results
