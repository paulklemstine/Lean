#!/usr/bin/env python3
"""
Turing's Flowers: Morphogenesis as Algebraic Geometry — Algorithms

Type-hinted implementations of core algorithms:
1. Chebyshev polynomial evaluation and expansion
2. Turing instability analysis
3. Pattern polynomial construction and degree computation
4. Zero set extraction and algebraic curve fitting
"""

import numpy as np
from dataclasses import dataclass
from typing import List, Tuple, Optional


# ============================================================
# Data Structures
# ============================================================

@dataclass
class TuringSystem:
    """A two-component reaction-diffusion system."""
    D1: float  # Diffusion coefficient of activator
    D2: float  # Diffusion coefficient of inhibitor
    a11: float  # ∂f/∂u
    a12: float  # ∂f/∂v
    a21: float  # ∂g/∂u
    a22: float  # ∂g/∂v

    @property
    def trace_J(self) -> float:
        return self.a11 + self.a22

    @property
    def det_J(self) -> float:
        return self.a11 * self.a22 - self.a12 * self.a21

    @property
    def cross_diff_coeff(self) -> float:
        return self.D2 * self.a11 + self.D1 * self.a22

    @property
    def dispersion_discriminant(self) -> float:
        return self.cross_diff_coeff**2 - 4 * self.D1 * self.D2 * self.det_J


@dataclass
class InstabilityResult:
    """Result of Turing instability analysis."""
    uniform_stable: bool
    turing_unstable: bool
    trace_J: float
    det_J: float
    cross_diff: float
    discriminant: float
    q_minus: Optional[float] = None
    q_plus: Optional[float] = None
    critical_mode: Optional[float] = None


@dataclass
class MorphogenesisSpectrum:
    """The algebraic data of a Turing pattern."""
    system: TuringSystem
    num_modes: int
    mode_coeffs: List[float]  # Fourier coefficients a_0, ..., a_N

    @property
    def algebraic_degree(self) -> int:
        """The degree of the pattern polynomial."""
        for k in range(len(self.mode_coeffs) - 1, -1, -1):
            if abs(self.mode_coeffs[k]) > 1e-15:
                return k
        return 0


# ============================================================
# Algorithm 1: Chebyshev Polynomial Evaluation
# ============================================================

def chebyshev_eval(n: int, x: np.ndarray) -> np.ndarray:
    """
    Evaluate Chebyshev polynomial T_n at array of points x.
    Uses the three-term recurrence: T_{n+2} = 2x T_{n+1} - T_n.

    Time complexity: O(n * len(x))
    Space complexity: O(len(x))
    """
    if n == 0:
        return np.ones_like(x, dtype=float)
    if n == 1:
        return x.astype(float)
    t_prev2 = np.ones_like(x, dtype=float)
    t_prev1 = x.astype(float)
    for _ in range(2, n + 1):
        t_curr = 2.0 * x * t_prev1 - t_prev2
        t_prev2 = t_prev1
        t_prev1 = t_curr
    return t_curr


def chebyshev_coefficients(n: int) -> List[float]:
    """
    Return coefficients of T_n as a standard polynomial.
    T_n(x) = sum_k c_k x^k.

    Returns list [c_0, c_1, ..., c_n].
    """
    if n == 0:
        return [1.0]
    if n == 1:
        return [0.0, 1.0]
    # Use recurrence on coefficient vectors
    prev2 = [1.0]
    prev1 = [0.0, 1.0]
    for _ in range(2, n + 1):
        # 2x * prev1: shift coefficients and multiply by 2
        shifted = [0.0] + [2.0 * c for c in prev1]
        # Pad prev2 to same length
        while len(prev2) < len(shifted):
            prev2.append(0.0)
        curr = [shifted[k] - prev2[k] for k in range(len(shifted))]
        prev2 = prev1
        prev1 = curr
    return prev1


# ============================================================
# Algorithm 2: Turing Instability Analysis
# ============================================================

def analyze_instability(system: TuringSystem) -> InstabilityResult:
    """
    Analyze a Turing system for diffusion-driven instability.

    The criterion (proved in Lean):
    Turing unstable ⟺ uniform stable ∧ cross_diff > 0 ∧ discriminant > 0

    Time complexity: O(1)
    """
    tr = system.trace_J
    det = system.det_J
    cd = system.cross_diff_coeff
    disc = system.dispersion_discriminant

    uniform_stable = tr < 0 and det > 0
    turing_unstable = uniform_stable and cd > 0 and disc > 0

    result = InstabilityResult(
        uniform_stable=uniform_stable,
        turing_unstable=turing_unstable,
        trace_J=tr,
        det_J=det,
        cross_diff=cd,
        discriminant=disc,
    )

    if turing_unstable:
        result.q_minus = (cd - np.sqrt(disc)) / (2 * system.D1 * system.D2)
        result.q_plus = (cd + np.sqrt(disc)) / (2 * system.D1 * system.D2)
        result.critical_mode = np.sqrt((result.q_minus + result.q_plus) / 2)

    return result


def dispersion_relation(system: TuringSystem, q: np.ndarray) -> np.ndarray:
    """
    Evaluate the dispersion relation h(q) = D1*D2*q² - cross_diff*q + det(J).

    Turing instability occurs when h(q) < 0 for some q > 0.
    """
    return (system.D1 * system.D2 * q**2
            - system.cross_diff_coeff * q
            + system.det_J)


# ============================================================
# Algorithm 3: Pattern Polynomial Construction
# ============================================================

def pattern_polynomial_eval(coeffs: List[float], x: np.ndarray) -> np.ndarray:
    """
    Evaluate the pattern polynomial P(x) = Σ a_k T_k(x).

    This is the algebraic representative of the Turing pattern
    u(θ) = Σ a_k cos(kθ) under x = cos(θ).

    Time complexity: O(N * len(x)) where N = len(coeffs)
    """
    result = np.zeros_like(x, dtype=float)
    for k, a_k in enumerate(coeffs):
        if abs(a_k) > 1e-15:
            result += a_k * chebyshev_eval(k, x)
    return result


def pattern_polynomial_standard(coeffs: List[float]) -> List[float]:
    """
    Convert Chebyshev expansion Σ a_k T_k to standard polynomial Σ c_j x^j.

    Returns the standard polynomial coefficients [c_0, c_1, ..., c_d].
    """
    max_deg = len(coeffs) - 1
    result = [0.0] * (max_deg + 1)
    for k, a_k in enumerate(coeffs):
        if abs(a_k) > 1e-15:
            cheb_coeffs = chebyshev_coefficients(k)
            for j, c_j in enumerate(cheb_coeffs):
                if j <= max_deg:
                    result[j] += a_k * c_j
    # Trim trailing zeros
    while len(result) > 1 and abs(result[-1]) < 1e-15:
        result.pop()
    return result


def pattern_degree(coeffs: List[float]) -> int:
    """
    Compute the algebraic degree of the pattern polynomial.
    Equal to the maximum mode number with nonzero coefficient.
    """
    for k in range(len(coeffs) - 1, -1, -1):
        if abs(coeffs[k]) > 1e-15:
            return k
    return 0


# ============================================================
# Algorithm 4: Zero Set Extraction
# ============================================================

def extract_zero_set_1d(coeffs: List[float],
                        n_points: int = 10000) -> List[float]:
    """
    Find the zero set of the pattern u(θ) = Σ a_k cos(kθ).

    Equivalently, find roots of P(x) = Σ a_k T_k(x) in [-1, 1].

    Returns the x-values (cos θ) where the pattern vanishes.
    """
    x = np.linspace(-1, 1, n_points)
    p = pattern_polynomial_eval(coeffs, x)

    roots = []
    for i in range(len(p) - 1):
        if p[i] * p[i + 1] < 0:
            # Linear interpolation for root
            root = x[i] - p[i] * (x[i + 1] - x[i]) / (p[i + 1] - p[i])
            roots.append(float(root))
        elif abs(p[i]) < 1e-10:
            roots.append(float(x[i]))

    return roots


def extract_zero_set_2d(coeffs_2d: List[List[float]],
                        nx: int = 200, ny: int = 200
                        ) -> Tuple[np.ndarray, np.ndarray]:
    """
    Find the zero set of a 2D pattern P(X, Y) = Σ a_{mn} T_m(X) T_n(Y).

    Returns (X_zeros, Y_zeros) arrays of points on the zero set.
    """
    x = np.linspace(-1, 1, nx)
    y = np.linspace(-1, 1, ny)
    X, Y = np.meshgrid(x, y)

    Z = np.zeros_like(X)
    for m, row in enumerate(coeffs_2d):
        Tm = chebyshev_eval(m, X)
        for n, a_mn in enumerate(row):
            if abs(a_mn) > 1e-15:
                Tn = chebyshev_eval(n, Y)
                Z += a_mn * Tm * Tn

    # Extract zero contour points
    from numpy import abs as nabs
    threshold = np.max(nabs(Z)) * 0.01
    mask = nabs(Z) < threshold
    return X[mask], Y[mask]


# ============================================================
# Algorithm 5: Algebraic Curve Fitting
# ============================================================

def fit_algebraic_curve(x_points: np.ndarray, y_points: np.ndarray,
                        max_degree: int = 6) -> Tuple[int, np.ndarray]:
    """
    Fit the zero set points to an algebraic curve of minimal degree.

    For each degree d from 1 to max_degree, fit the polynomial
    P(x,y) = Σ_{i+j≤d} c_{ij} x^i y^j to the data points
    using least squares, and select the minimal degree with
    residual below threshold.

    Returns (degree, coefficients).
    """
    best_degree = max_degree
    best_coeffs = None

    for d in range(1, max_degree + 1):
        # Build Vandermonde matrix for monomials x^i y^j with i+j ≤ d
        n_terms = (d + 1) * (d + 2) // 2
        A = np.zeros((len(x_points), n_terms))
        col = 0
        for i in range(d + 1):
            for j in range(d + 1 - i):
                A[:, col] = x_points**i * y_points**j
                col += 1

        # SVD to find the null space (the curve equation)
        _, s, Vt = np.linalg.svd(A)
        # The last row of Vt is the least-squares solution
        coeffs = Vt[-1, :]
        residual = np.min(s) / np.max(s) if np.max(s) > 0 else 0

        if residual < 0.01:  # Good fit
            best_degree = d
            best_coeffs = coeffs
            break

    if best_coeffs is None:
        best_coeffs = np.zeros(1)

    return best_degree, best_coeffs


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    # Example: Gierer-Meinhardt system
    gm = TuringSystem(D1=0.01, D2=1.0, a11=1.0, a12=-1.0, a21=2.0, a22=-1.5)
    result = analyze_instability(gm)
    print(f"Gierer-Meinhardt system:")
    print(f"  Turing unstable: {result.turing_unstable}")
    if result.turing_unstable:
        print(f"  Critical mode: k ≈ {result.critical_mode:.4f}")

    # Pattern with 2 modes: spots (conic section)
    spot_coeffs = [0.5, 0.0, 1.0]  # a₀ + a₂ cos(2θ)
    degree = pattern_degree(spot_coeffs)
    std_poly = pattern_polynomial_standard(spot_coeffs)
    print(f"\nSpot pattern coefficients: {spot_coeffs}")
    print(f"  Algebraic degree: {degree}")
    print(f"  Standard polynomial: {' + '.join(f'{c:.1f}x^{i}' for i, c in enumerate(std_poly) if abs(c) > 1e-10)}")

    zeros = extract_zero_set_1d(spot_coeffs)
    print(f"  Zero set (x = cos θ): {[f'{z:.4f}' for z in zeros]}")
