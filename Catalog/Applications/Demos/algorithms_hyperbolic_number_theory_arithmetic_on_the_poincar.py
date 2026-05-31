"""
Hyperbolic Arithmetic Algorithms
================================

Type-hinted implementations of the core operations from
Hyperbolic Number Theory on the Poincaré Disk.
"""

from typing import List, Tuple
import math


def moebius_add(a: float, b: float) -> float:
    """Möbius addition on the Poincaré disk: (a+b)/(1+ab).
    
    For a, b in (-1, 1), the result is also in (-1, 1).
    This is the fundamental arithmetic operation of hyperbolic geometry.
    """
    return (a + b) / (1 + a * b)


def moebius_neg(a: float) -> float:
    """Möbius negation: the inverse under Möbius addition."""
    return -a


def moebius_iterate(a: float, n: int) -> float:
    """Compute the n-th Möbius iterate: a ⊕ a ⊕ ... ⊕ a (n times).
    
    Uses the artanh isomorphism: moebiusIterate(a, n) = tanh(n * artanh(a)).
    """
    if n == 0:
        return 0.0
    return math.tanh(n * math.atanh(a))


def moebius_iterate_recursive(a: float, n: int) -> float:
    """Recursive Möbius iteration (direct computation, O(n))."""
    result = 0.0
    for _ in range(n):
        result = moebius_add(a, result)
    return result


def hyp_dist(a: float, b: float) -> float:
    """Hyperbolic distance: d(a,b) = artanh(|a ⊕ (-b)|)."""
    diff = moebius_add(a, -b)
    return math.atanh(abs(diff))


def orbit_gap(a: float, b: float, n: int) -> float:
    """Gap between two Möbius orbits at step n."""
    return moebius_iterate(b, n) - moebius_iterate(a, n)


def word_ball_size(n: int) -> int:
    """Exact number of words of length ≤ n in a 2-generator system.
    
    Returns 2^{n+1} - 1.
    """
    return 2 ** (n + 1) - 1


def hyp_zeta_summand(r: float, s: float) -> float:
    """Hyperbolic zeta summand: r^{-2s}.
    
    For 0 < r < 1, this is > 1 when s > 0 (reversal of classical behavior).
    """
    return r ** (-2 * s)


def gyration(a: float, b: float, c: float) -> float:
    """The gyration operator gyr[a,b](c).
    
    On the real line, this is always c (associativity holds).
    On the complex plane, it would be nontrivial.
    """
    lhs = moebius_add(moebius_add(a, b), c)  # (a⊕b)⊕c
    ab = moebius_add(a, b)
    # gyr[a,b](c) = -(a⊕b) ⊕ (a ⊕ (b⊕c))
    return moebius_add(-ab, moebius_add(a, moebius_add(b, c)))


def pythagorean_disk_point(a: int, b: int, c: int) -> float:
    """Map a Pythagorean triple (a, b, c) to a disk point a/c."""
    assert a**2 + b**2 == c**2, f"Not a Pythagorean triple: {a}^2 + {b}^2 != {c}^2"
    return a / c


def find_pythagorean_triples(max_c: int) -> List[Tuple[int, int, int]]:
    """Find all primitive Pythagorean triples with hypotenuse ≤ max_c."""
    triples = []
    for c in range(1, max_c + 1):
        for a in range(1, c):
            b_sq = c**2 - a**2
            b = int(math.isqrt(b_sq))
            if b > 0 and b * b == b_sq and a <= b:
                if math.gcd(math.gcd(a, b), c) == 1:
                    triples.append((a, b, c))
    return triples


def verify_orbit_separation(a: float, b: float, n_max: int) -> List[float]:
    """Verify the orbit separation conjecture for given a, b up to n_max steps.
    
    Returns list of gaps. All should be positive if conjecture holds.
    """
    gaps = []
    for n in range(1, n_max + 1):
        gap = orbit_gap(a, b, n)
        gaps.append(gap)
    return gaps


def verify_associativity(a: float, b: float, c: float) -> float:
    """Check associativity: returns |(a⊕b)⊕c - a⊕(b⊕c)|."""
    lhs = moebius_add(moebius_add(a, b), c)
    rhs = moebius_add(a, moebius_add(b, c))
    return abs(lhs - rhs)
