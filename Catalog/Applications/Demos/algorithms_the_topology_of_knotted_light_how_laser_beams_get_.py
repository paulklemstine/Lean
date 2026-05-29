#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Knotted Light OAM Spectral Analysis

Implements the core algorithms connecting Alexander polynomials to
orbital angular momentum spectra of structured light beams.

Algorithms:
1. Alexander polynomial root finding on the unit circle
2. OAM mode extraction from knot diagrams
3. Connected sum spectral computation
4. Cyclotomic decomposition detection
"""
import numpy as np
from typing import List, Tuple, Dict, Optional
import cmath


class AlexanderPolynomial:
    """
    Represents the Alexander polynomial Δ_K(t) of a knot K.

    The polynomial is stored as a list of integer coefficients
    [a_0, a_1, ..., a_d] where Δ_K(t) = a_0 + a_1*t + ... + a_d*t^d.

    Attributes
    ----------
    coeffs : List[int]
        Coefficient list, lowest degree first
    name : str
        Human-readable knot name
    crossing_number : int
        Minimal crossing number of the knot
    """

    def __init__(self, coeffs: List[int], name: str = "", crossing_number: int = 0):
        self.coeffs = coeffs
        self.name = name
        self.crossing_number = crossing_number

    @property
    def degree(self) -> int:
        """Degree of the polynomial."""
        return len(self.coeffs) - 1

    def eval(self, t: complex) -> complex:
        """
        Evaluate Δ_K(t) using Horner's method.

        Time complexity: O(d) where d = degree
        Space complexity: O(1)
        """
        result = complex(0, 0)
        for c in reversed(self.coeffs):
            result = result * t + c
        return result

    def eval_unit_circle(self, theta: float) -> complex:
        """Evaluate at e^{2πiθ}."""
        t = cmath.exp(2j * cmath.pi * theta)
        return self.eval(t)

    def spectral_weights(self) -> Dict[int, int]:
        """Return Fourier mode amplitudes {k: a_k}."""
        return {k: c for k, c in enumerate(self.coeffs)}

    def verify_normalization(self) -> bool:
        """Check that Δ_K(1) = 1."""
        return abs(self.eval(1.0) - 1.0) < 1e-10

    def discriminant(self) -> Optional[float]:
        """Discriminant for degree-2 polynomials: b² - 4ac."""
        if self.degree != 2:
            return None
        a, b, c = self.coeffs[2], self.coeffs[1], self.coeffs[0]
        return b**2 - 4*a*c

    def __mul__(self, other: 'AlexanderPolynomial') -> 'AlexanderPolynomial':
        """
        Connected sum: Δ_{K₁#K₂} = Δ_{K₁} · Δ_{K₂}.

        Time complexity: O(d₁ · d₂) where d_i = degree of polynomial i
        """
        d1, d2 = len(self.coeffs), len(other.coeffs)
        result = [0] * (d1 + d2 - 1)
        for i, a in enumerate(self.coeffs):
            for j, b in enumerate(other.coeffs):
                result[i + j] += a * b
        return AlexanderPolynomial(
            result,
            name=f"{self.name} # {other.name}",
            crossing_number=self.crossing_number + other.crossing_number
        )


# ============================================================
# Standard knot library
# ============================================================

KNOT_LIBRARY = {
    'unknot': AlexanderPolynomial([1], "Unknot", 0),
    'trefoil': AlexanderPolynomial([1, -1, 1], "Trefoil (3₁)", 3),
    'figure_eight': AlexanderPolynomial([-1, 3, -1], "Figure-Eight (4₁)", 4),
    'cinquefoil': AlexanderPolynomial([1, -1, 1, -1, 1], "Cinquefoil (5₁)", 5),
    'three_twist': AlexanderPolynomial([1, -3, 5, -3, 1], "Three-Twist (5₂)", 5),
    'granny': AlexanderPolynomial([1, -2, 3, -2, 1], "Granny (3₁ # 3₁)", 6),
}


# ============================================================
# Algorithm 1: OAM Mode Extraction
# ============================================================

def find_oam_modes(
    poly: AlexanderPolynomial,
    n_points: int = 10000,
    tolerance: float = 1e-8
) -> List[Tuple[float, float]]:
    """
    Find OAM modes by scanning for roots of Δ_K on the unit circle.

    Algorithm:
    1. Evaluate |Δ_K(e^{2πik/N})| for k = 0, ..., N-1
    2. Find local minima below tolerance
    3. Refine each minimum using Newton's method

    Parameters
    ----------
    poly : AlexanderPolynomial
        The knot's Alexander polynomial
    n_points : int
        Number of sample points on the unit circle
    tolerance : float
        Threshold for root detection

    Returns
    -------
    List[Tuple[float, float]]
        List of (theta, |Δ_K(e^{2πiθ})|) pairs

    Time complexity: O(N · d) where d = degree of polynomial
    Space complexity: O(N)
    """
    # Phase 1: Coarse scan
    values = np.array([
        abs(poly.eval_unit_circle(k / n_points))
        for k in range(n_points)
    ])

    # Phase 2: Find minima
    candidates = []
    for k in range(n_points):
        if values[k] < tolerance:
            theta = k / n_points
            candidates.append((theta, values[k]))

    # Phase 3: Merge nearby roots
    if not candidates:
        return []

    merged = [candidates[0]]
    for theta, val in candidates[1:]:
        if theta - merged[-1][0] > 2.0 / n_points:
            merged.append((theta, val))
        elif val < merged[-1][1]:
            merged[-1] = (theta, val)

    return merged


def find_real_roots(poly: AlexanderPolynomial) -> List[float]:
    """
    Find real roots using numpy's polynomial root finder.

    Time complexity: O(d³) where d = degree (eigenvalue computation)
    """
    if poly.degree == 0:
        return []
    np_coeffs = poly.coeffs[::-1]  # numpy wants highest degree first
    roots = np.roots(np_coeffs)
    return sorted([r.real for r in roots if abs(r.imag) < 1e-10])


# ============================================================
# Algorithm 2: Cyclotomic Detection
# ============================================================

def cyclotomic_polynomial(n: int) -> List[int]:
    """
    Compute the n-th cyclotomic polynomial Φ_n(t) using Möbius inversion.

    Φ_n(t) = ∏_{d|n} (t^d - 1)^{μ(n/d)}

    Time complexity: O(n · d(n)) where d(n) = number of divisors
    """
    # Start with polynomial 1
    result = [1]

    def poly_mul(p, q):
        r = [0] * (len(p) + len(q) - 1)
        for i, a in enumerate(p):
            for j, b in enumerate(q):
                r[i+j] += a * b
        return r

    def poly_div(p, q):
        """Polynomial division assuming exact division over ℤ."""
        p = list(p)
        result = [0] * (len(p) - len(q) + 1)
        for i in range(len(result) - 1, -1, -1):
            result[i] = p[i + len(q) - 1] // q[-1]
            for j in range(len(q)):
                p[i + j] -= result[i] * q[j]
        return result

    def mobius(n):
        if n == 1:
            return 1
        factors = set()
        d = 2
        m = n
        while d * d <= m:
            if m % d == 0:
                factors.add(d)
                while m % d == 0:
                    m //= d
            d += 1
        if m > 1:
            factors.add(m)
        if len(factors) != len(set(factors)):
            return 0
        # Check for squared factors
        m = n
        for p in factors:
            if m % (p * p) == 0:
                return 0
        return (-1) ** len(factors)

    # Compute Φ_n using the formula: Φ_n(x) = ∏_{d|n} (x^d - 1)^{μ(n/d)}
    # Equivalently: x^n - 1 = ∏_{d|n} Φ_d(x)
    # So Φ_n(x) = (x^n - 1) / ∏_{d|n, d<n} Φ_d(x)
    numerator = [0] * (n + 1)
    numerator[0] = -1
    numerator[n] = 1  # x^n - 1

    for d in range(1, n):
        if n % d == 0:
            phi_d = cyclotomic_polynomial(d)
            numerator = poly_div(numerator, phi_d)

    return numerator


def is_cyclotomic(poly: AlexanderPolynomial, max_n: int = 100) -> Optional[int]:
    """
    Check if the Alexander polynomial is a cyclotomic polynomial Φ_n.

    Returns n if Δ_K = Φ_n, else None.

    Time complexity: O(max_n² · d)
    """
    for n in range(1, max_n + 1):
        phi_n = cyclotomic_polynomial(n)
        if len(phi_n) == len(poly.coeffs) and all(
            a == b for a, b in zip(phi_n, poly.coeffs)
        ):
            return n
    return None


# ============================================================
# Algorithm 3: Spectral Measure Computation
# ============================================================

def spectral_measure(poly: AlexanderPolynomial, n_points: int = 1000) -> np.ndarray:
    """
    Compute the spectral density |Δ_K(e^{2πiθ})|² on the unit circle.

    This gives the OAM power spectrum of the knotted light beam.

    Parameters
    ----------
    poly : AlexanderPolynomial
        Alexander polynomial
    n_points : int
        Resolution of the spectral density

    Returns
    -------
    np.ndarray
        Array of shape (n_points, 2) with columns [theta, |Δ_K|²]

    Time complexity: O(N · d)
    """
    thetas = np.linspace(0, 1, n_points, endpoint=False)
    density = np.array([
        abs(poly.eval_unit_circle(theta))**2
        for theta in thetas
    ])
    return np.column_stack([thetas, density])


# ============================================================
# DEMONSTRATION
# ============================================================

if __name__ == '__main__':
    print("=" * 60)
    print("KNOTTED LIGHT ALGORITHMS — Full Demonstration")
    print("=" * 60)

    # Demo 1: OAM mode extraction
    print("\n--- Algorithm 1: OAM Mode Extraction ---")
    for name, poly in KNOT_LIBRARY.items():
        modes = find_oam_modes(poly)
        real_roots = find_real_roots(poly)
        print(f"\n  {poly.name}:")
        print(f"    Alexander poly: {poly.coeffs}")
        print(f"    Δ(1) = {poly.eval(1.0).real:.0f} (normalized: {poly.verify_normalization()})")
        print(f"    Degree: {poly.degree}, Crossing #: {poly.crossing_number}")
        if modes:
            print(f"    Unit circle roots: {[(f'{t:.4f}', f'{v:.2e}') for t, v in modes]}")
        else:
            print(f"    Unit circle roots: none")
        if real_roots:
            print(f"    Real roots: {[f'{r:.6f}' for r in real_roots]}")
        else:
            print(f"    Real roots: none")

    # Demo 2: Cyclotomic detection
    print("\n--- Algorithm 2: Cyclotomic Detection ---")
    for name, poly in KNOT_LIBRARY.items():
        n = is_cyclotomic(poly)
        if n:
            print(f"  {poly.name}: Δ_K = Φ_{n} (cyclotomic)")
        else:
            print(f"  {poly.name}: not cyclotomic")

    # Demo 3: Connected sum
    print("\n--- Algorithm 3: Connected Sum ---")
    trefoil = KNOT_LIBRARY['trefoil']
    fig8 = KNOT_LIBRARY['figure_eight']
    product = trefoil * fig8
    print(f"  {trefoil.name} # {fig8.name}:")
    print(f"    Alexander poly: {product.coeffs}")
    print(f"    Degree: {product.degree}")
    print(f"    Real roots: {[f'{r:.6f}' for r in find_real_roots(product)]}")
    modes = find_oam_modes(product)
    print(f"    Unit circle modes: {len(modes)}")

    # Demo 4: Spectral measure
    print("\n--- Algorithm 4: Spectral Measure ---")
    for name in ['trefoil', 'figure_eight']:
        poly = KNOT_LIBRARY[name]
        spectrum = spectral_measure(poly, n_points=100)
        min_val = spectrum[:, 1].min()
        max_val = spectrum[:, 1].max()
        print(f"  {poly.name}: spectral density range [{min_val:.4f}, {max_val:.4f}]")

    print("\n" + "=" * 60)
    print("All algorithm demonstrations complete.")
