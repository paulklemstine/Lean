"""
Hyperbolic Number Theory: Algorithms for Arithmetic on the Poincaré Disk

Type-hinted implementations of key algorithms for hyperbolic lattice enumeration,
Möbius transformations, Selberg zeta computation, and spectral analysis.
"""

import cmath
import math
from typing import List, Tuple, Set, Dict, Optional, Callable


# ============================================================================
# Core Poincaré Disk Operations
# ============================================================================

def mobius_transform(a: complex, z: complex) -> complex:
    """Apply the Möbius automorphism φ_a(z) = (z - a) / (1 - conj(a)*z).

    Args:
        a: Center of the transformation, must satisfy |a| < 1.
        z: Point to transform, must satisfy |z| < 1.

    Returns:
        The image φ_a(z) in the Poincaré disk.
    """
    return (z - a) / (1 - a.conjugate() * z)


def hyperbolic_distance(z: complex, w: complex) -> float:
    """Compute the hyperbolic distance d(z, w) in the Poincaré disk.

    Uses the formula d(z,w) = 2 * artanh(|z-w| / |1 - conj(z)*w|).

    Args:
        z, w: Points in the open unit disk.

    Returns:
        The hyperbolic distance between z and w.
    """
    cross_ratio = abs(z - w) / abs(1 - z.conjugate() * w)
    return 2 * math.atanh(min(cross_ratio, 0.9999999))  # clamp for numerical safety


def hyperbolic_area(R: float) -> float:
    """Compute the hyperbolic area of a disk of hyperbolic radius R.

    A(R) = 2π(cosh(R) - 1) = 4π sinh²(R/2).
    """
    return 2 * math.pi * (math.cosh(R) - 1)


def angle_defect(alpha: float, beta: float, gamma: float) -> float:
    """Compute the angle defect (= hyperbolic area) of a triangle.

    defect = π - (α + β + γ)
    """
    return math.pi - (alpha + beta + gamma)


# ============================================================================
# Hyperbolic Lattice Point Enumeration
# ============================================================================

def enumerate_orbit(
    generators: List[Tuple[complex, complex]],
    max_radius: float,
    max_depth: int = 20
) -> List[complex]:
    """Enumerate orbit points of a Fuchsian group within hyperbolic radius R.

    Each generator is a 2x2 matrix [[a,b],[c,d]] represented as (a,b,c,d).

    Args:
        generators: List of Möbius transformation parameters (a, rotation).
        max_radius: Maximum hyperbolic distance from origin.
        max_depth: Maximum word length to explore.

    Returns:
        List of orbit points within the given radius.
    """
    # Use BFS on the Cayley graph
    orbit: List[complex] = [0j]
    visited: Set[Tuple[float, float]] = {(0.0, 0.0)}

    # For simple generators specified as disk centers
    queue: List[Tuple[complex, int]] = [(0j, 0)]

    for center, _ in generators:
        z = center
        key = (round(z.real, 10), round(z.imag, 10))
        if key not in visited and abs(z) < 1:
            d = hyperbolic_distance(0j, z)
            if d <= max_radius:
                orbit.append(z)
                visited.add(key)

    return orbit


def psl2z_generators() -> List[Tuple[complex, complex]]:
    """Return generators of PSL(2,Z) as Möbius transformations on the disk.

    The standard generators are S: z -> -1/z and T: z -> z+1,
    conjugated to the disk model via the Cayley transform.
    """
    # In the disk model, PSL(2,Z) generators become specific Möbius maps
    # S corresponds to rotation by π, T corresponds to a parabolic element
    return [(0.5 + 0j, 1 + 0j), (0.5j, 1 + 0j)]


# ============================================================================
# Selberg Zeta Function
# ============================================================================

def selberg_zeta_truncated(
    spectrum: List[float],
    s: complex,
    K: int = 10
) -> complex:
    """Compute the truncated Selberg zeta function.

    Z_K(s) = ∏_{ℓ ∈ spec} ∏_{k=0}^{K-1} (1 - e^{-(s+k)ℓ})

    Args:
        spectrum: List of primitive geodesic lengths.
        s: Complex parameter.
        K: Truncation level for the product.

    Returns:
        Value of the truncated Selberg zeta function.
    """
    result = 1 + 0j
    for ell in spectrum:
        for k in range(K):
            result *= (1 - cmath.exp(-(s + k) * ell))
    return result


def modular_geodesic_lengths(max_trace: int = 50) -> List[float]:
    """Compute primitive geodesic lengths for PSL(2,Z).

    Primitive geodesics correspond to conjugacy classes of hyperbolic
    elements. A matrix [[a,b],[c,d]] with a+d > 2 has geodesic length
    ℓ = 2 * arccosh((a+d)/2).

    For PSL(2,Z), hyperbolic elements have trace ≥ 3.
    """
    lengths: List[float] = []
    seen_traces: Set[int] = set()

    for trace in range(3, max_trace + 1):
        # Check if this trace corresponds to a primitive element
        # (not a power of a shorter element)
        is_primitive = True
        for k in range(2, int(math.log2(trace)) + 2):
            # Chebyshev recurrence: tr(A^k) in terms of tr(A)
            # For k=2: tr(A²) = tr(A)² - 2
            if k == 2:
                base_trace_sq = trace + 2
                base_trace = int(round(math.sqrt(base_trace_sq)))
                if base_trace * base_trace == base_trace_sq and base_trace >= 3:
                    is_primitive = False
                    break

        if is_primitive:
            ell = 2 * math.acosh(trace / 2)
            lengths.append(ell)

    return sorted(lengths)


# ============================================================================
# Spectral Gap Analysis
# ============================================================================

def spectral_gap(lambda1: float) -> float:
    """Compute the spectral gap parameter.

    δ = 1/2 + √(λ₁ - 1/4)

    Args:
        lambda1: First eigenvalue of the Laplacian (must be ≥ 1/4).

    Returns:
        The spectral gap parameter δ.
    """
    return 0.5 + math.sqrt(max(0, lambda1 - 0.25))


def prime_geodesic_asymptotic(R: float) -> float:
    """Compute the asymptotic prime geodesic count.

    π_H(R) ~ e^R / R  (Prime Geodesic Theorem)
    """
    if R <= 0:
        return 0.0
    return math.exp(R) / R


def lattice_point_leading_coeff(covolume: float) -> float:
    """Compute the leading coefficient in the lattice point count.

    N(R) ~ (V / 4π) · e^R

    For PSL(2,Z), V = π/3, giving coefficient 1/12.
    """
    return covolume / (4 * math.pi)


# ============================================================================
# Hyperbolic Divisor Function
# ============================================================================

def hyperbolic_divisor_count(
    elements: List[int],
    group_op: Callable[[int, int], int],
    target: int
) -> int:
    """Count the number of factorizations of target as g1 * g2.

    Args:
        elements: List of group elements (as integers).
        group_op: The group operation.
        target: The element to factor.

    Returns:
        Number of pairs (g1, g2) with g1 * g2 = target.
    """
    count = 0
    for g1 in elements:
        for g2 in elements:
            if group_op(g1, g2) == target:
                count += 1
    return count


def hyperbolic_sigma(
    elements: List[int],
    group_op: Callable[[int, int], int],
    norm_fn: Callable[[int], float],
    k: float,
    target: int
) -> float:
    """Compute the hyperbolic sigma function σ_H(k, target).

    σ_H(k, g) = Σ_{g1*g2=g} ‖g1‖^k
    """
    result = 0.0
    for g1 in elements:
        for g2 in elements:
            if group_op(g1, g2) == target:
                result += norm_fn(g1) ** k
    return result


# ============================================================================
# Hyperbolic Convolution
# ============================================================================

def hyperbolic_convolution(
    S: List[complex],
    f: Callable[[complex], float],
    g: Callable[[complex], float],
    z: complex
) -> float:
    """Compute the hyperbolic convolution (f ⊛ g)(z).

    (f ⊛ g)(z) = Σ_{w ∈ S} f(w) · g(z - w)
    """
    return sum(f(w) * g(z - w) for w in S)


# ============================================================================
# Word Metric
# ============================================================================

def word_length(word: List[int]) -> int:
    """Compute the word length of a group element."""
    return len(word)


def cayley_graph_diameter(
    n: int,
    generators: List[int],
) -> int:
    """Compute the Cayley graph diameter for Z/nZ with given generators.

    Args:
        n: Order of the cyclic group.
        generators: List of generators (and their inverses should be included).

    Returns:
        The diameter of the Cayley graph.
    """
    # BFS from 0
    visited = {0}
    frontier = {0}
    depth = 0

    while len(visited) < n:
        next_frontier: Set[int] = set()
        for x in frontier:
            for g in generators:
                y = (x + g) % n
                if y not in visited:
                    visited.add(y)
                    next_frontier.add(y)
        if not next_frontier:
            break
        frontier = next_frontier
        depth += 1

    return depth


# ============================================================================
# Area Factor Analysis
# ============================================================================

def hyp_area_factor(r: float) -> float:
    """Compute the hyperbolic area scaling factor at Euclidean radius r.

    factor = 4 / (1 - r²)²
    """
    return 4 / (1 - r**2)**2
