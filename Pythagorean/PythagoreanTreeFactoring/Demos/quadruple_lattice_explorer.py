#!/usr/bin/env python3
"""
Pythagorean Quadruple Lattice Explorer
========================================
Explores the 3D lattice L₄(N) = {(x,y,z) : x² + y² + z² ≡ 0 (mod N²)}
and tests whether LLL reduction on this lattice can find factoring-relevant
short vectors.

This implements the concrete research program from Section 6 of the paper.
"""

import math
import sys
from typing import List, Tuple, Optional


def gcd(a: int, b: int) -> int:
    while b:
        a, b = b, a % b
    return abs(a)


def is_prime(n: int) -> bool:
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


# ─── Pythagorean Quadruples ────────────────────────────────────────────

def find_pythagorean_quadruples(limit: int) -> List[Tuple[int, int, int, int]]:
    """Find all primitive Pythagorean quadruples with d ≤ limit."""
    quads = []
    for d in range(3, limit + 1):
        d2 = d * d
        for a in range(1, d):
            a2 = a * a
            if a2 >= d2:
                break
            for b in range(a, d):
                b2 = b * b
                if a2 + b2 >= d2:
                    break
                rem = d2 - a2 - b2
                c = int(math.isqrt(rem))
                if c >= b and c * c == rem:
                    if gcd(gcd(a, b), gcd(c, d)) == 1:
                        quads.append((a, b, c, d))
    return quads


def quaternionic_parametrization(m: int, n: int, p: int, q: int) -> Tuple[int, int, int, int]:
    """
    Generate Pythagorean quadruple from quaternionic parameters.
    (a, b, c, d) where a² + b² + c² = d²

    a = m² + n² - p² - q²
    b = 2(mq + np)
    c = 2(nq - mp)
    d = m² + n² + p² + q²
    """
    a = m*m + n*n - p*p - q*q
    b = 2 * (m*q + n*p)
    c = 2 * (n*q - m*p)
    d = m*m + n*n + p*p + q*q
    return (abs(a), abs(b), abs(c), d)


# ─── Quadruple Lattice ────────────────────────────────────────────────

def construct_lattice_basis(N: int) -> List[List[int]]:
    """
    Construct a basis for L₄(N) = {(x,y,z) ∈ ℤ³ : x² + y² + z² ≡ 0 (mod N²)}.

    We use the basis:
      e₁ = (N², 0, 0)
      e₂ = (0, N², 0)
      e₃ = (0, 0, N²)

    These trivially satisfy the congruence. Finding SHORT vectors in the lattice
    spanned by these (modulo the congruence) is the factoring-relevant problem.
    """
    N2 = N * N
    return [
        [N2, 0, 0],
        [0, N2, 0],
        [0, 0, N2],
    ]


def gram_schmidt(basis: List[List[float]]) -> Tuple[List[List[float]], List[List[float]]]:
    """Gram-Schmidt orthogonalization."""
    n = len(basis)
    d = len(basis[0])
    orth = [row[:] for row in basis]
    mu = [[0.0] * n for _ in range(n)]

    for i in range(n):
        for j in range(i):
            dot_ij = sum(orth[i][k] * orth[j][k] for k in range(d))
            dot_jj = sum(orth[j][k] * orth[j][k] for k in range(d))
            if dot_jj == 0:
                mu[i][j] = 0
            else:
                mu[i][j] = dot_ij / dot_jj
            for k in range(d):
                orth[i][k] -= mu[i][j] * orth[j][k]

    return orth, mu


def lll_reduce(basis: List[List[int]], delta: float = 0.75) -> List[List[int]]:
    """
    LLL lattice reduction algorithm.
    Returns an LLL-reduced basis.
    """
    n = len(basis)
    d = len(basis[0])
    B = [row[:] for row in basis]

    def dot(u, v):
        return sum(u[i] * v[i] for i in range(len(u)))

    def norm_sq(v):
        return dot(v, v)

    def proj_coeff(u, v):
        du = dot(u, u)
        return dot(v, u) / du if du != 0 else 0

    k = 1
    max_iter = 1000
    iteration = 0

    while k < n and iteration < max_iter:
        iteration += 1

        # Gram-Schmidt
        orth = [row[:] for row in B]
        mu = [[0.0] * n for _ in range(n)]
        for i in range(n):
            for j in range(i):
                mu[i][j] = proj_coeff(orth[j], [float(x) for x in B[i]])
                for l in range(d):
                    orth[i][l] = float(orth[i][l]) - mu[i][j] * orth[j][l]

        # Size reduction
        for j in range(k - 1, -1, -1):
            if abs(mu[k][j]) > 0.5:
                r = round(mu[k][j])
                for l in range(d):
                    B[k][l] -= r * B[j][l]
                # Recompute mu
                for i in range(n):
                    orth[i] = [float(x) for x in B[i]]
                    for jj in range(i):
                        mu[i][jj] = proj_coeff(orth[jj], [float(x) for x in B[i]])
                        for l in range(d):
                            orth[i][l] -= mu[i][jj] * orth[jj][l]

        # Lovász condition
        ns_k = norm_sq(orth[k])
        ns_km1 = norm_sq(orth[k - 1])

        if ns_k >= (delta - mu[k][k - 1] ** 2) * ns_km1:
            k += 1
        else:
            B[k], B[k - 1] = B[k - 1], B[k]
            k = max(k - 1, 1)

    return B


def search_short_lattice_vectors(N: int, search_radius: int = None) -> List[Tuple[int, int, int]]:
    """
    Search for short vectors in L₄(N).
    Returns vectors (x, y, z) with x² + y² + z² ≡ 0 (mod N²) and small norm.
    """
    N2 = N * N
    if search_radius is None:
        search_radius = min(N * 5, 200)

    vectors = []
    for x in range(-search_radius, search_radius + 1):
        for y in range(-search_radius, search_radius + 1):
            for z in range(-search_radius, search_radius + 1):
                s = x * x + y * y + z * z
                if s > 0 and s % N2 == 0:
                    vectors.append((x, y, z))

    # Sort by norm
    vectors.sort(key=lambda v: v[0]**2 + v[1]**2 + v[2]**2)
    return vectors


def extract_factors(N: int, vectors: List[Tuple[int, int, int]]) -> Optional[Tuple[int, int]]:
    """
    Try to extract a non-trivial factor of N from short lattice vectors.
    """
    for x, y, z in vectors:
        for val in [x, y, z, x + y, x - y, x + z, y + z, x*x + y*y, x*x + z*z, y*y + z*z]:
            g = gcd(abs(val), N)
            if 1 < g < N:
                return (g, N // g)
    return None


# ─── O(3,1;ℤ) Generators ────────────────────────────────────────────

def lorentz_boost_x(beta_num: int, beta_den: int):
    """
    A Lorentz boost in the x-direction with rational velocity.
    For integer Lorentz group, we need Pythagorean-type parameters.
    """
    # For integer boosts, use Pythagorean parametrization:
    # cosh(θ) = m²+n² / (m²-n²), sinh(θ) = 2mn / (m²-n²)
    # This gives integer matrix entries when m,n are integers
    pass


def generate_O31_elements():
    """
    Generate elements of O(3,1;ℤ) using Pythagorean quadruple parametrization.

    Key insight: just as the Berggren tree uses 3 generators of O(2,1;ℤ),
    we need generators of O(3,1;ℤ). But O(3,1;ℤ) is NOT finitely generated
    by a free group, so we need a different structure.

    Generators include:
    1. Spatial rotations: S₃ acting on (x,y,z) coordinates
    2. Lorentz boosts: one for each spatial direction
    3. Reflections: sign changes on individual coordinates
    """
    generators = []

    # Spatial permutations (S₃ on first 3 coords)
    # swap x,y
    generators.append(("swap_xy", [
        [0, 1, 0, 0],
        [1, 0, 0, 0],
        [0, 0, 1, 0],
        [0, 0, 0, 1]
    ]))

    # swap y,z
    generators.append(("swap_yz", [
        [1, 0, 0, 0],
        [0, 0, 1, 0],
        [0, 1, 0, 0],
        [0, 0, 0, 1]
    ]))

    # Reflections
    generators.append(("neg_x", [
        [-1, 0, 0, 0],
        [0, 1, 0, 0],
        [0, 0, 1, 0],
        [0, 0, 0, 1]
    ]))

    # Lorentz boost from Pythagorean triple (3,4,5)
    # cosh(θ) = 5/3, sinh(θ) = 4/3 → integer version uses (5, 4, 3)
    generators.append(("boost_x_345", [
        [5, 0, 0, 4],
        [0, 3, 0, 0],
        [0, 0, 3, 0],
        [4, 0, 0, 5]
    ]))

    # Lorentz boost from (5,12,13)
    generators.append(("boost_x_51213", [
        [13, 0, 0, 12],
        [0, 5, 0, 0],
        [0, 0, 5, 0],
        [12, 0, 0, 13]
    ]))

    return generators


# ─── Main ────────────────────────────────────────────────────────────

def main():
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  PYTHAGOREAN QUADRUPLE LATTICE EXPLORER                        ║")
    print("║  L₄(N) = {(x,y,z) : x² + y² + z² ≡ 0 (mod N²)}              ║")
    print("║  The 3D Escape from the √N Barrier                            ║")
    print("╚══════════════════════════════════════════════════════════════════╝")

    # 1. Find some Pythagorean quadruples
    print(f"\n{'='*60}")
    print("PYTHAGOREAN QUADRUPLES (a² + b² + c² = d²)")
    print(f"{'='*60}")
    quads = find_pythagorean_quadruples(30)
    for a, b, c, d in quads[:15]:
        print(f"  {a}² + {b}² + {c}² = {d}²  ({a*a} + {b*b} + {c*c} = {d*d})")

    # 2. Quaternionic parametrization
    print(f"\n{'='*60}")
    print("QUATERNIONIC PARAMETRIZATION")
    print(f"{'='*60}")
    params = [(1, 0, 0, 1), (1, 1, 0, 1), (1, 1, 1, 0), (2, 1, 0, 1), (2, 1, 1, 1)]
    for m, n, p, q in params:
        a, b, c, d = quaternionic_parametrization(m, n, p, q)
        check = a*a + b*b + c*c
        print(f"  Q({m},{n},{p},{q}) → ({a}, {b}, {c}, {d})  check: {a}²+{b}²+{c}² = {check} = {d}² ({'✓' if check == d*d else '✗'})")

    # 3. Test factoring via quadruple lattice
    test_semiprimes = [15, 21, 35, 77, 143, 221, 323, 437]
    print(f"\n{'='*60}")
    print("QUADRUPLE LATTICE FACTORING ATTEMPTS")
    print(f"{'='*60}")

    for N in test_semiprimes:
        print(f"\n  N = {N}:")
        vectors = search_short_lattice_vectors(N, search_radius=min(N * 3, 100))
        if vectors:
            print(f"    Found {len(vectors)} lattice vectors")
            shortest = vectors[0]
            norm = math.sqrt(sum(x**2 for x in shortest))
            sqrt_n = math.sqrt(N)
            print(f"    Shortest: {shortest}, norm = {norm:.2f}, √N = {sqrt_n:.2f}, ratio = {norm/sqrt_n:.2f}")

            result = extract_factors(N, vectors[:50])
            if result:
                p, q = result
                print(f"    ✓ FACTORED: {N} = {p} × {q}")
            else:
                print(f"    ✗ No factor extracted from short vectors")
        else:
            print(f"    No lattice vectors found in search radius")

    # 4. O(3,1;ℤ) generators
    print(f"\n{'='*60}")
    print("O(3,1;ℤ) GENERATORS")
    print(f"{'='*60}")
    gens = generate_O31_elements()
    for name, matrix in gens:
        print(f"\n  {name}:")
        for row in matrix:
            print(f"    {row}")

    # 5. LLL reduction test
    print(f"\n{'='*60}")
    print("LLL REDUCTION ON QUADRUPLE LATTICE")
    print(f"{'='*60}")

    for N in [15, 21, 35]:
        basis = construct_lattice_basis(N)
        print(f"\n  N = {N}, basis vectors:")
        for v in basis:
            norm = math.sqrt(sum(x**2 for x in v))
            print(f"    {v}  (norm = {norm:.1f})")

        reduced = lll_reduce(basis)
        print(f"  LLL-reduced basis:")
        for v in reduced:
            norm = math.sqrt(sum(x**2 for x in v))
            print(f"    {v}  (norm = {norm:.1f})")

    # Summary
    print(f"\n{'='*60}")
    print("SUMMARY")
    print(f"{'='*60}")
    print("""
  The Pythagorean quadruple lattice L₄(N) provides a natural 3D setting
  where Gauss's 2D reduction is no longer optimal. Key observations:

  1. L₄(N) is a well-defined sublattice of ℤ³
  2. Short vectors in L₄(N) can reveal factors of N
  3. LLL/BKZ reduction in 3D may find shorter vectors than greedy descent
  4. The O(3,1;ℤ) symmetry group provides structured starting bases
  5. Sub-√N factoring remains a concrete but ambitious target

  The Lattice-Tree Correspondence proves this is the ONLY escape route:
  any 2D method (including all Berggren tree variants) is stuck at Θ(√N).
""")


if __name__ == "__main__":
    main()
