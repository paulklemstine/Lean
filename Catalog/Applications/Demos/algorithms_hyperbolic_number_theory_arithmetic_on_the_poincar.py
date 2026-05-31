"""
Algorithms for Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

Implements Möbius addition, orbit computation, hyperbolic convolution,
and the associativity defect computation for both 1D real and 2D complex cases.
"""

from typing import List, Callable, Tuple
import math


def moebius_add(a: float, b: float) -> float:
    """
    Möbius addition on (-1,1): a ⊕ b = (a + b) / (1 + a*b).

    Parameters
    ----------
    a : float
        First disk point, |a| < 1
    b : float
        Second disk point, |b| < 1

    Returns
    -------
    float
        Möbius sum a ⊕ b, guaranteed to satisfy |result| < 1
    """
    return (a + b) / (1 + a * b)


def moebius_add_complex(z: complex, w: complex) -> complex:
    """
    Möbius addition on the complex unit disk:
    z ⊕ w = (z + w) / (1 + conj(z) * w).

    Parameters
    ----------
    z : complex
        First disk point, |z| < 1
    w : complex
        Second disk point, |w| < 1

    Returns
    -------
    complex
        Möbius sum z ⊕ w
    """
    return (z + w) / (1 + z.conjugate() * w)


def moebius_orbit(g: float, n: int) -> List[float]:
    """
    Compute the Möbius orbit of generator g up to step n.

    The orbit is defined by O(0) = 0, O(k+1) = g ⊕ O(k).

    Parameters
    ----------
    g : float
        Generator, 0 < g < 1
    n : int
        Number of orbit steps

    Returns
    -------
    List[float]
        Array [O(0), O(1), ..., O(n)]
    """
    orbit: List[float] = [0.0]
    for _ in range(n):
        orbit.append(moebius_add(g, orbit[-1]))
    return orbit


def hyp_dist_proxy(a: float, b: float) -> float:
    """
    Hyperbolic distance proxy: |a ⊖ b| = |a ⊕ (-b)|.

    Parameters
    ----------
    a : float
        First disk point
    b : float
        Second disk point

    Returns
    -------
    float
        |a ⊖ b|, a monotone function of the true hyperbolic distance
    """
    return abs(moebius_add(a, -b))


def hyp_convolution(f: List[float], g: List[float], n: int) -> float:
    """
    Compute (f ⋆ g)(n) = Σ_{k=0}^{n} f(k) * g(n-k).

    Parameters
    ----------
    f : List[float]
        First function values [f(0), f(1), ..., f(N)]
    g : List[float]
        Second function values [g(0), g(1), ..., g(N)]
    n : int
        Evaluation point

    Returns
    -------
    float
        Convolution value (f ⋆ g)(n)
    """
    result = 0.0
    for k in range(min(n + 1, len(f))):
        if n - k < len(g):
            result += f[k] * g[n - k]
    return result


def hyp_convolution_full(f: List[float], g: List[float]) -> List[float]:
    """
    Compute the full convolution f ⋆ g up to index len(f)+len(g)-2.

    Parameters
    ----------
    f : List[float]
        First function values
    g : List[float]
        Second function values

    Returns
    -------
    List[float]
        Full convolution array
    """
    n = len(f) + len(g) - 1
    return [hyp_convolution(f, g, k) for k in range(n)]


def associativity_defect_1d(a: float, b: float, c: float) -> float:
    """
    Compute the associativity defect δ(a,b,c) = |(a⊕b)⊕c - a⊕(b⊕c)| in 1D.

    In the 1D real case, this should always be 0 (up to floating point).

    Parameters
    ----------
    a, b, c : float
        Disk points with |a|, |b|, |c| < 1

    Returns
    -------
    float
        Associativity defect
    """
    lhs = moebius_add(moebius_add(a, b), c)
    rhs = moebius_add(a, moebius_add(b, c))
    return abs(lhs - rhs)


def associativity_defect_2d(z1: complex, z2: complex, z3: complex) -> float:
    """
    Compute the associativity defect in 2D (complex disk).

    This is generically nonzero due to the gyration operator.

    Parameters
    ----------
    z1, z2, z3 : complex
        Disk points with |z1|, |z2|, |z3| < 1

    Returns
    -------
    float
        Associativity defect |δ|
    """
    lhs = moebius_add_complex(moebius_add_complex(z1, z2), z3)
    rhs = moebius_add_complex(z1, moebius_add_complex(z2, z3))
    return abs(lhs - rhs)


def gyration(a: complex, b: complex, c: complex) -> complex:
    """
    The gyration operator gyr[a,b](c) for the complex Möbius gyrogroup.

    gyr[a,b](c) = ((1 + a*conj(b)) / (1 + conj(a)*b)) * c

    Parameters
    ----------
    a, b : complex
        Parameters of the gyration
    c : complex
        Point to be gyrated

    Returns
    -------
    complex
        gyr[a,b](c)
    """
    numerator = 1 + a * b.conjugate()
    denominator = 1 + a.conjugate() * b
    return (numerator / denominator) * c


def pythagorean_disk_points(max_c: int) -> List[Tuple[int, int, int, float]]:
    """
    Generate Pythagorean triples (a, b, c) with c ≤ max_c and their disk points a/c.

    Parameters
    ----------
    max_c : int
        Maximum hypotenuse

    Returns
    -------
    List[Tuple[int, int, int, float]]
        List of (a, b, c, a/c) for each Pythagorean triple
    """
    results: List[Tuple[int, int, int, float]] = []
    for c in range(1, max_c + 1):
        for a in range(1, c):
            b_sq = c * c - a * a
            b = int(math.isqrt(b_sq))
            if b > 0 and b * b == b_sq and a <= b:
                results.append((a, b, c, a / c))
    return results


def hyperbolic_zeta_partial(g: float, s: float, n_terms: int) -> float:
    """
    Compute the partial sum of the hyperbolic zeta function:
    ζ_H(s) ≈ Σ_{n=1}^{N} |O(g,n)|^{-2s}

    Parameters
    ----------
    g : float
        Generator, 0 < g < 1
    s : float
        Exponent (real part)
    n_terms : int
        Number of terms

    Returns
    -------
    float
        Partial sum of ζ_H(s)
    """
    orbit = moebius_orbit(g, n_terms)
    total = 0.0
    for i in range(1, len(orbit)):
        norm = abs(orbit[i])
        if norm > 0:
            total += norm ** (-2 * s)
    return total
