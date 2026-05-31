"""
Algorithms for Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

Type-hinted implementations of the core algorithms:
1. Einstein addition on (-1,1)
2. Chebyshev trace recurrence
3. Tree Möbius inversion
4. Hyperbolic lattice point counting
5. Pseudo-hyperbolic distance computation
"""

from typing import List, Tuple, Callable, Optional
import math
import cmath


def einstein_add(a: float, b: float) -> float:
    """Einstein addition (relativistic velocity addition): (a + b) / (1 + ab).

    This is the group operation on (-1, 1) that makes it isomorphic to (ℝ, +)
    via the rapidity map artanh. It is associative, commutative, and has
    -a as the inverse of a.

    Args:
        a: First velocity, must be in (-1, 1)
        b: Second velocity, must be in (-1, 1)

    Returns:
        Einstein sum in (-1, 1)
    """
    return (a + b) / (1 + a * b)


def einstein_neg(a: float) -> float:
    """Einstein additive inverse: -a."""
    return -a


def einstein_add_iterated(a: float, n: int) -> float:
    """Compute n-fold Einstein addition of a with itself.

    Args:
        a: Base value in (-1, 1)
        n: Number of iterations (non-negative)

    Returns:
        a ⊕ a ⊕ ... ⊕ a (n times), which equals tanh(n * artanh(a))
    """
    result = 0.0
    for _ in range(n):
        result = einstein_add(result, a)
    return result


def chebyshev_trace(t: int, n: int) -> int:
    """Compute the Chebyshev trace sequence: T(0) = 2, T(1) = t,
    T(n+2) = t * T(n+1) - T(n).

    This gives the trace of the n-th power of an SL₂(ℤ) matrix with trace t.
    Connected to Chebyshev polynomials of the first kind via
    T_n(t/2) = chebyshev_trace(t, n) / 2.

    Args:
        t: The trace of the base matrix
        n: The power (non-negative)

    Returns:
        Trace of the n-th power
    """
    if n == 0:
        return 2
    if n == 1:
        return t
    prev, curr = 2, t
    for _ in range(n - 1):
        prev, curr = curr, t * curr - prev
    return curr


def tree_moebius(k: int, d: int) -> int:
    """The Möbius function on a k-ary tree.

    μ_T(0) = 1, μ_T(1) = -k, μ_T(d) = 0 for d ≥ 2.

    This captures the inclusion-exclusion structure of the tree.

    Args:
        k: Branching factor of the tree
        d: Depth difference

    Returns:
        Value of the tree Möbius function
    """
    if d == 0:
        return 1
    elif d == 1:
        return -k
    else:
        return 0


def tree_zeta(k: int, d: int) -> int:
    """The tree zeta function: ζ_T(d) = k^d (descendants at depth d)."""
    return k ** d


def tree_convolve(f: Callable[[int], int], g: Callable[[int], int], n: int) -> int:
    """Dirichlet-style convolution on depth-indexed functions.

    (f * g)(n) = ∑_{i=0}^{n} f(i) * g(n - i)
    """
    return sum(f(i) * g(n - i) for i in range(n + 1))


def verify_moebius_inversion(k: int, max_depth: int = 20) -> List[Tuple[int, int]]:
    """Verify the tree Möbius inversion: μ_T * ζ_T = δ.

    Returns list of (n, value) where value should be 1 if n=0, else 0.
    """
    results = []
    for n in range(max_depth):
        val = tree_convolve(lambda d: tree_moebius(k, d),
                           lambda d: tree_zeta(k, d), n)
        results.append((n, val))
    return results


def pseudo_hyperbolic_distance(z: complex, w: complex) -> float:
    """Pseudo-hyperbolic distance in the Poincaré disk.

    ρ(z, w) = |z - w| / |1 - conj(w) * z|

    This is a metric on the open unit disk, related to the hyperbolic distance by
    d_hyp(z, w) = 2 * artanh(ρ(z, w)).

    Args:
        z: Point in the open unit disk
        w: Point in the open unit disk

    Returns:
        Pseudo-hyperbolic distance
    """
    return abs(z - w) / abs(1 - w.conjugate() * z)


def mobius_map(a: complex, theta: float, z: complex) -> complex:
    """Möbius disk automorphism: z ↦ e^{iθ} (z - a) / (1 - conj(a) z).

    Args:
        a: Center of the Möbius map, |a| < 1
        theta: Rotation angle
        z: Input point

    Returns:
        Image under the Möbius map
    """
    rotation = cmath.exp(1j * theta)
    return rotation * (z - a) / (1 - a.conjugate() * z)


def hyperbolic_lattice_points(generators: List[complex],
                               max_depth: int = 5) -> List[complex]:
    """Generate lattice points by applying Möbius generators iteratively.

    Starting from the origin, apply each generator and its inverse up to
    max_depth times to generate the orbit.

    Args:
        generators: List of complex numbers in the open unit disk
        max_depth: Maximum number of generator applications

    Returns:
        List of lattice points (orbit of 0)
    """
    points = {0j}
    frontier = {0j}

    for _ in range(max_depth):
        new_frontier = set()
        for p in frontier:
            for g in generators:
                # Apply g and g^{-1} as Möbius maps
                new_p = mobius_map(g, 0, p)
                inv_p = mobius_map(-g, 0, p)  # Inverse of Möbius map with center g
                for q in [new_p, inv_p]:
                    if abs(q) < 0.9999 and all(abs(q - existing) > 1e-10
                                                for existing in points):
                        new_frontier.add(q)
                        points.add(q)
        frontier = new_frontier

    return sorted(list(points), key=abs)


def trace_witness(t: int) -> Tuple[Tuple[int, int], Tuple[int, int]]:
    """Construct an SL₂(ℤ) matrix with given trace.

    Returns [[t, -1], [1, 0]] which has trace t and determinant 1.

    Args:
        t: Desired trace value

    Returns:
        2x2 matrix as nested tuples
    """
    return ((t, -1), (1, 0))


def hyperbolic_conj_class_count(T: int) -> int:
    """Conjectured count of hyperbolic conjugacy classes with |trace| ≤ T.

    Conjecture: equals 2T - 3 for T ≥ 2.
    """
    if T <= 1:
        return 0
    return 2 * T - 3


def lattice_count_constant() -> float:
    """The conjectured constant C = 3/π for modular group lattice counting.

    N(R) / e^R → 3/π as R → ∞, where N(R) counts lattice points within
    hyperbolic distance R of the origin.
    """
    return 3.0 / math.pi


if __name__ == "__main__":
    # Quick self-test
    print("=== Einstein Addition ===")
    print(f"0.5 ⊕ 0.3 = {einstein_add(0.5, 0.3):.6f}")
    print(f"0.5 ⊕ (-0.5) = {einstein_add(0.5, -0.5):.6f}")

    print("\n=== Chebyshev Trace ===")
    for n in range(8):
        print(f"T_3({n}) = {chebyshev_trace(3, n)}")

    print("\n=== Möbius Inversion Verification (k=3) ===")
    results = verify_moebius_inversion(3, 10)
    for n, val in results:
        expected = 1 if n == 0 else 0
        status = "✓" if val == expected else "✗"
        print(f"  n={n}: μ*ζ = {val} (expected {expected}) {status}")
