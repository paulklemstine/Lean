"""
Hyperbolic Trace Arithmetic: Core Algorithms

Type-hinted implementations of the main algorithms from the
hyperbolic trace arithmetic framework.
"""

from typing import List, Tuple, Set, Dict, Optional
import math


def sl2_mul(a: Tuple[int, int, int, int],
            b: Tuple[int, int, int, int]) -> Tuple[int, int, int, int]:
    """Multiply two SL₂(ℤ) matrices represented as (a, b, c, d)."""
    a1, b1, c1, d1 = a
    a2, b2, c2, d2 = b
    return (a1*a2 + b1*c2, a1*b2 + b1*d2,
            c1*a2 + d1*c2, c1*b2 + d1*d2)


def sl2_inv(m: Tuple[int, int, int, int]) -> Tuple[int, int, int, int]:
    """Compute the inverse of an SL₂(ℤ) matrix."""
    a, b, c, d = m
    return (d, -b, -c, a)


def sl2_trace(m: Tuple[int, int, int, int]) -> int:
    """Compute the trace of an SL₂(ℤ) matrix."""
    return m[0] + m[3]


def cheb_trace(t: int, n: int) -> int:
    """Compute the n-th Chebyshev trace value for initial trace t.

    Uses the recurrence:
        chebTrace(t, 0) = 2
        chebTrace(t, 1) = t
        chebTrace(t, n+2) = t * chebTrace(t, n+1) - chebTrace(t, n)
    """
    if n == 0:
        return 2
    if n == 1:
        return t
    a, b = 2, t
    for _ in range(2, n + 1):
        a, b = b, t * b - a
    return b


def cheb_trace_invariant(t: int, n: int) -> int:
    """Verify the Chebyshev-Trace Invariant.

    Returns chebTrace(n+1)² + chebTrace(n)² - t*chebTrace(n)*chebTrace(n+1),
    which should always equal 4 - t².
    """
    cn = cheb_trace(t, n)
    cn1 = cheb_trace(t, n + 1)
    return cn1**2 + cn**2 - t * cn * cn1


def trace_spectrum(k: int) -> Set[int]:
    """Compute the set of distinct traces achievable by words
    of length ≤ k in {S, T, S⁻¹, T⁻¹}.

    Args:
        k: Maximum word length

    Returns:
        Set of distinct trace values
    """
    S = (0, -1, 1, 0)
    T = (1, 1, 0, 1)
    S_inv = sl2_inv(S)
    T_inv = sl2_inv(T)
    generators = [S, T, S_inv, T_inv]

    identity = (1, 0, 0, 1)
    current_level: Set[Tuple[int, int, int, int]] = {identity}
    all_matrices: Set[Tuple[int, int, int, int]] = {identity}
    traces: Set[int] = {sl2_trace(identity)}

    for _ in range(k):
        next_level: Set[Tuple[int, int, int, int]] = set()
        for g in current_level:
            for gen in generators:
                h = sl2_mul(g, gen)
                if h not in all_matrices:
                    all_matrices.add(h)
                    next_level.add(h)
                    traces.add(sl2_trace(h))
        current_level = next_level
        if not current_level:
            break

    return traces


def farey_neighbors(n: int) -> List[Tuple[Tuple[int, int], Tuple[int, int]]]:
    """Generate Farey neighbor pairs in the Farey sequence F_n.

    Args:
        n: Order of the Farey sequence

    Returns:
        List of neighboring fraction pairs ((a,b), (c,d)) with ad-bc=1
    """
    # Build Farey sequence F_n
    fractions: List[Tuple[int, int]] = [(0, 1), (1, 1)]
    for _ in range(n - 1):
        new_fracs: List[Tuple[int, int]] = [fractions[0]]
        for i in range(len(fractions) - 1):
            a, b = fractions[i]
            c, d = fractions[i + 1]
            if b + d <= n:
                new_fracs.append((a + c, b + d))
            new_fracs.append(fractions[i + 1])
        fractions = new_fracs

    # Extract neighbor pairs
    neighbors: List[Tuple[Tuple[int, int], Tuple[int, int]]] = []
    for i in range(len(fractions) - 1):
        a, b = fractions[i]
        c, d = fractions[i + 1]
        if abs(a * d - b * c) == 1:
            neighbors.append(((a, b), (c, d)))

    return neighbors


def fricke_vogt_check(A: Tuple[int, int, int, int],
                       B: Tuple[int, int, int, int]) -> bool:
    """Verify the Fricke-Vogt identity for matrices A, B.

    Checks: tr(A)² + tr(B)² + tr(AB)² = tr(A)·tr(B)·tr(AB) + tr([A,B]) + 2
    """
    AB = sl2_mul(A, B)
    ABA_inv = sl2_mul(AB, sl2_inv(A))
    comm = sl2_mul(ABA_inv, sl2_inv(B))

    tA = sl2_trace(A)
    tB = sl2_trace(B)
    tAB = sl2_trace(AB)
    tComm = sl2_trace(comm)

    lhs = tA**2 + tB**2 + tAB**2
    rhs = tA * tB * tAB + tComm + 2

    return lhs == rhs


def trace_product_check(A: Tuple[int, int, int, int],
                         B: Tuple[int, int, int, int]) -> bool:
    """Verify the trace product identity: tr(AB) + tr(AB⁻¹) = tr(A)·tr(B)."""
    AB = sl2_mul(A, B)
    AB_inv = sl2_mul(A, sl2_inv(B))
    return sl2_trace(AB) + sl2_trace(AB_inv) == sl2_trace(A) * sl2_trace(B)


def trace_convolution(f: Dict[int, float], f_bound: int,
                       g: Dict[int, float], g_bound: int,
                       t: int) -> float:
    """Compute the trace convolution (f ⊛ g)(t).

    Args:
        f: First function as dict {trace_value: function_value}
        f_bound: Support bound for f
        g: Second function as dict
        g_bound: Support bound for g
        t: Point at which to evaluate the convolution

    Returns:
        (f ⊛ g)(t) = Σᵢ f(i) · g(t - i)
    """
    total = 0.0
    bound = f_bound + g_bound
    for i in range(-bound, bound + 1):
        fi = f.get(i, 0.0)
        gti = g.get(t - i, 0.0)
        total += fi * gti
    return total


def hyperbolic_lattice_count(points: List[complex], r: float) -> int:
    """Count lattice points with |z| < r in the Poincaré disk.

    Args:
        points: List of complex numbers in the unit disk
        r: Radius bound

    Returns:
        Number of points with |z| < r
    """
    return sum(1 for z in points if abs(z) < r)


def cayley_transform(s: complex) -> complex:
    """Apply the Cayley transform s ↦ (s-1)/(s+1)."""
    return (s - 1) / (s + 1)


if __name__ == "__main__":
    # Quick self-test
    print("=== Chebyshev-Trace Invariant Test ===")
    for t in [2, 3, 5, 10]:
        for n in range(6):
            inv_val = cheb_trace_invariant(t, n)
            expected = 4 - t**2
            assert inv_val == expected, f"Failed: t={t}, n={n}"
            print(f"  t={t}, n={n}: invariant = {inv_val} = 4-{t}² ✓")

    print("\n=== Trace Product Identity Test ===")
    S = (0, -1, 1, 0)
    T = (1, 1, 0, 1)
    for A in [S, T, sl2_mul(S, T), sl2_mul(T, T)]:
        for B in [S, T, sl2_mul(S, T)]:
            assert trace_product_check(A, B), f"Failed for {A}, {B}"
    print("  All checks passed ✓")

    print("\n=== Fricke-Vogt Identity Test ===")
    for A in [S, T, sl2_mul(S, T)]:
        for B in [S, T, sl2_mul(T, S)]:
            assert fricke_vogt_check(A, B), f"Failed for {A}, {B}"
    print("  All checks passed ✓")
