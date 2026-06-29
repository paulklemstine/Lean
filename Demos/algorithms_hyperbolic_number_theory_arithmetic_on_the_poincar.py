"""
Hyperbolic Number Theory: Algorithms for Arithmetic on the Poincaré Disk

Type-hinted implementations of the core mathematical structures formalized
in the Lean 4 proofs.
"""

from typing import Tuple, List, Optional
import math
import cmath


# ============================================================
# 1. Einstein Addition (Relativistic Velocity Addition)
# ============================================================

def einstein_add(a: float, b: float) -> float:
    """
    Einstein addition on (-1, 1): a ⊕ b = (a + b) / (1 + a*b).
    
    This is the group operation on the "hyperbolic line" — the 1D
    Poincaré disk model. It's also the relativistic velocity addition
    formula (in units where c = 1).
    
    Args:
        a: First velocity, must be in (-1, 1)
        b: Second velocity, must be in (-1, 1)
    
    Returns:
        The Einstein sum, guaranteed to be in (-1, 1)
    """
    return (a + b) / (1 + a * b)


def einstein_neg(a: float) -> float:
    """Einstein negation: the inverse of a under ⊕ is -a."""
    return -a


def rapidity(x: float) -> float:
    """
    The rapidity function: artanh(x) = (1/2) * log((1+x)/(1-x)).
    
    This is the isomorphism from ((-1,1), ⊕) to (ℝ, +).
    rapidity(a ⊕ b) = rapidity(a) + rapidity(b).
    """
    if abs(x) >= 1:
        raise ValueError(f"|x| must be < 1, got x = {x}")
    return 0.5 * math.log((1 + x) / (1 - x))


def inverse_rapidity(r: float) -> float:
    """Inverse of rapidity: tanh(r). Maps (ℝ, +) back to ((-1,1), ⊕)."""
    return math.tanh(r)


# ============================================================
# 2. Chebyshev Polynomials
# ============================================================

def chebyshev_T(n: int, x: float) -> float:
    """
    Chebyshev polynomial of the first kind T_n(x), computed via recurrence.
    
    Satisfies: T_n(cos θ) = cos(nθ) for all θ.
    Composition: T_m(T_n(x)) = T_{mn}(x) for all x.
    
    Args:
        n: Degree (non-negative integer)
        x: Point to evaluate at
    
    Returns:
        T_n(x)
    """
    if n == 0:
        return 1.0
    if n == 1:
        return x
    
    t_prev2 = 1.0  # T_0
    t_prev1 = x    # T_1
    for _ in range(2, n + 1):
        t_curr = 2 * x * t_prev1 - t_prev2
        t_prev2 = t_prev1
        t_prev1 = t_curr
    return t_prev1


def verify_chebyshev_cos(n: int, theta: float) -> Tuple[float, float]:
    """Verify T_n(cos θ) = cos(nθ)."""
    lhs = chebyshev_T(n, math.cos(theta))
    rhs = math.cos(n * theta)
    return lhs, rhs


def verify_chebyshev_composition(m: int, n: int, x: float) -> Tuple[float, float]:
    """Verify T_m(T_n(x)) = T_{mn}(x)."""
    lhs = chebyshev_T(m, chebyshev_T(n, x))
    rhs = chebyshev_T(m * n, x)
    return lhs, rhs


# ============================================================
# 3. Möbius Transformations on the Poincaré Disk
# ============================================================

def moebius_transform(a: complex, b: complex, z: complex) -> complex:
    """
    Apply the Möbius (Blaschke) transformation z ↦ (az + b) / (conj(b)z + conj(a)).
    
    When |a|² - |b|² = 1, this is an automorphism of the unit disk.
    
    Args:
        a, b: Coefficients with |a|² - |b|² > 0
        z: Point in the disk
    
    Returns:
        Image of z under the transformation
    """
    numerator = a * z + b
    denominator = b.conjugate() * z + a.conjugate()
    return numerator / denominator


def verify_blaschke_identity(a: complex, b: complex, z: complex) -> Tuple[float, float]:
    """
    Verify the Blaschke identity:
    |conj(b)z + conj(a)|² * (1 - |φ(z)|²) = (|a|²-|b|²) * (1-|z|²)
    """
    denom = b.conjugate() * z + a.conjugate()
    phi_z = moebius_transform(a, b, z)
    
    lhs = abs(denom)**2 * (1 - abs(phi_z)**2)
    rhs = (abs(a)**2 - abs(b)**2) * (1 - abs(z)**2)
    return lhs, rhs


# ============================================================
# 4. Hyperbolic Distance and Orbit Counting
# ============================================================

def hyperbolic_distance(z1: complex, z2: complex) -> float:
    """
    Hyperbolic distance in the Poincaré disk model.
    d(z1, z2) = artanh(|z1 - z2| / |1 - conj(z1)*z2|)
    """
    numerator = abs(z1 - z2)
    denominator = abs(1 - z1.conjugate() * z2)
    ratio = numerator / denominator
    if ratio >= 1:
        return float('inf')
    return math.atanh(ratio)


def sl2z_action(a: int, b: int, c: int, d: int, z: complex) -> complex:
    """
    Action of SL₂(ℤ) on the upper half-plane via z ↦ (az+b)/(cz+d).
    """
    return (a * z + b) / (c * z + d)


def cayley_to_disk(z: complex) -> complex:
    """Cayley transform: upper half-plane → unit disk. w = (z-i)/(z+i)."""
    return (z - 1j) / (z + 1j)


def cayley_to_uhp(w: complex) -> complex:
    """Inverse Cayley: unit disk → upper half-plane. z = i(1+w)/(1-w)."""
    return 1j * (1 + w) / (1 - w)


def orbit_points_in_disk(R: float, max_entries: int = 50) -> List[complex]:
    """
    Compute orbit points of PSL₂(ℤ) acting on i (in the upper half-plane),
    mapped to the Poincaré disk via Cayley transform, within hyperbolic
    distance R of the origin.
    
    Uses generators S: z ↦ -1/z and T: z ↦ z+1.
    """
    origin_uhp = 1j  # i in upper half-plane
    origin_disk = cayley_to_disk(origin_uhp)  # = 0
    
    visited = set()
    orbit = []
    queue = [(origin_uhp, 0)]  # (point, word length)
    
    while queue and len(orbit) < max_entries:
        z, depth = queue.pop(0)
        
        # Map to disk
        w = cayley_to_disk(z)
        key = (round(w.real, 8), round(w.imag, 8))
        
        if key in visited:
            continue
        visited.add(key)
        
        d = hyperbolic_distance(complex(0), w)
        if d <= R:
            orbit.append(w)
            
            if depth < 10:
                # Apply generators
                # S: z -> -1/z
                if abs(z) > 1e-10:
                    queue.append((-1/z, depth + 1))
                # T: z -> z + 1
                queue.append((z + 1, depth + 1))
                # T⁻¹: z -> z - 1
                queue.append((z - 1, depth + 1))
    
    return orbit


def count_orbit_up_to_distance(R: float) -> int:
    """Count orbit points within hyperbolic distance R."""
    return len(orbit_points_in_disk(R, max_entries=1000))


# ============================================================
# 5. Selberg Zeta Function (Partial Sum)
# ============================================================

def selberg_zeta_partial(s: float, N: int = 100) -> float:
    """
    Compute partial sum of the hyperbolic zeta function:
    ζ_H(s) = Σ_{n=1}^{N} 1/n^{2s}
    
    This is a simplified model using the integer distances as a proxy
    for orbit distances.
    """
    return sum(1.0 / n**(2*s) for n in range(1, N + 1))


def trace_to_distance(trace: int) -> float:
    """
    For γ ∈ SL₂(ℤ), the distance satisfies cosh(d(i, γi)) = |tr(γ)|/2.
    Returns d given the trace.
    """
    t = abs(trace) / 2.0
    if t < 1:
        return 0.0  # Elliptic element
    return math.acosh(t)


if __name__ == "__main__":
    # Quick demo
    print("=== Einstein Addition Demo ===")
    a, b = 0.5, 0.3
    result = einstein_add(a, b)
    print(f"{a} ⊕ {b} = {result:.6f}")
    print(f"rapidity({a}) + rapidity({b}) = {rapidity(a) + rapidity(b):.6f}")
    print(f"rapidity({a} ⊕ {b}) = {rapidity(result):.6f}")
    
    print("\n=== Chebyshev Composition ===")
    for m, n in [(2, 3), (3, 4), (5, 7)]:
        x = 2.5
        lhs, rhs = verify_chebyshev_composition(m, n, x)
        print(f"T_{m}(T_{n}({x})) = {lhs:.2f}, T_{m*n}({x}) = {rhs:.2f}, match: {abs(lhs-rhs) < 1e-6}")
    
    print("\n=== Blaschke Identity ===")
    a_coeff = complex(1.2, 0.3)
    b_coeff = complex(0.4, 0.1)
    z = complex(0.3, 0.2)
    lhs, rhs = verify_blaschke_identity(a_coeff, b_coeff, z)
    print(f"LHS = {lhs:.8f}, RHS = {rhs:.8f}, match: {abs(lhs-rhs) < 1e-10}")
