"""
Hyperbolic Arithmetic Algorithms

Type-hinted implementations of Möbius addition, hyperbolic distance,
Möbius iteration, and hyperbolic prime detection on the Poincaré disk.
"""

from typing import List, Tuple, Optional
import math


def moebius_add(a: float, b: float) -> float:
    """Möbius addition on the real Poincaré disk (-1, 1).

    Computes a ⊕ b = (a + b) / (1 + a*b).
    Both inputs should satisfy |a| < 1 and |b| < 1.
    """
    return (a + b) / (1 + a * b)


def moebius_add_complex(z: complex, w: complex) -> complex:
    """Möbius addition on the complex Poincaré disk.

    Computes z ⊕ w = (z + w) / (1 + conj(z)*w).
    """
    return (z + w) / (1 + z.conjugate() * w)


def moebius_neg(a: float) -> float:
    """Möbius negation (inverse under ⊕). Simply -a."""
    return -a


def moebius_iter(g: float, n: int) -> float:
    """Compute g^{⊕n} = g ⊕ g ⊕ ... ⊕ g (n times).

    This is the hyperbolic analog of n*g in Euclidean arithmetic.
    """
    result = 0.0
    for _ in range(n):
        result = moebius_add(result, g)
    return result


def hyp_norm(x: float) -> float:
    """Hyperbolic norm: |x| / (1 - |x|).

    Maps the disk (-1,1) to [0, ∞), measuring hyperbolic distance from origin.
    """
    ax = abs(x)
    if ax >= 1.0:
        return float('inf')
    return ax / (1 - ax)


def hyp_distance(a: float, b: float) -> float:
    """Hyperbolic distance between two points in (-1, 1).

    d(a, b) = arctanh(|(-a) ⊕ b|) = 0.5 * ln((1+|m|)/(1-|m|))
    where m = moebius_add(-a, b).
    """
    m = abs(moebius_add(-a, b))
    if m >= 1.0:
        return float('inf')
    return 0.5 * math.log((1 + m) / (1 - m))


def generate_moebius_orbit(g: float, n: int) -> List[float]:
    """Generate the first n Möbius iterates of g.

    Returns [g^{⊕0}, g^{⊕1}, ..., g^{⊕(n-1)}].
    """
    orbit = [0.0]
    for i in range(1, n):
        orbit.append(moebius_add(orbit[-1], g))
    return orbit


def is_hyp_decomposable(p: float, lattice: List[float], tol: float = 1e-10) -> bool:
    """Check if p can be written as a ⊕ b for nonzero a, b in lattice."""
    for a in lattice:
        if abs(a) < tol:
            continue
        for b in lattice:
            if abs(b) < tol:
                continue
            if abs(moebius_add(a, b) - p) < tol:
                return True
    return False


def find_hyp_primes(lattice: List[float], tol: float = 1e-10) -> List[float]:
    """Find all hyperbolic primes in a lattice.

    A hyperbolic prime is a nonzero element that cannot be decomposed
    as a ⊕ b for nonzero a, b in the lattice.
    """
    primes = []
    for p in lattice:
        if abs(p) < tol:
            continue
        if not is_hyp_decomposable(p, lattice, tol):
            primes.append(p)
    return primes


def hyp_zeta_partial(lattice: List[float], s: float, max_terms: int = 1000) -> float:
    """Partial sum of the hyperbolic zeta function.

    ζ_H(s) = Σ_{x ∈ lattice, x ≠ 0} 1/|x|_H^{2s}
    """
    total = 0.0
    count = 0
    for x in lattice:
        if abs(x) < 1e-15:
            continue
        hn = hyp_norm(x)
        if hn <= 0:
            continue
        total += hn ** (-2 * s)
        count += 1
        if count >= max_terms:
            break
    return total


def verify_orbit_growth_conjecture(g: float, max_n: int = 100) -> Tuple[bool, List[Tuple[int, float, float]]]:
    """Verify the hyperbolic orbit growth conjecture.

    Checks: moebiusIter(g, n) > 1 - 2/(n+1) for n = 1, ..., max_n.
    Returns (all_pass, list of (n, actual, bound)).
    """
    results = []
    all_pass = True
    for n in range(1, max_n + 1):
        actual = moebius_iter(g, n)
        bound = 1 - 2 / (n + 1)
        passed = actual > bound
        if not passed:
            all_pass = False
        results.append((n, actual, bound))
    return all_pass, results


def moebius_cayley_table(elements: List[float]) -> List[List[float]]:
    """Compute the Cayley table for Möbius addition on a finite set."""
    return [[moebius_add(a, b) for b in elements] for a in elements]
