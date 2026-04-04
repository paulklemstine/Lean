#!/usr/bin/env python3
"""
The Quadruple Lattice: Computational Demos

This module implements the sum-of-three-squares lattice construction
for integer factoring, including:
1. Finding quadratic residue roots r₁, r₂ with N | (r₁² + r₂² + 1)
2. Constructing the lattice basis
3. LLL reduction (using fpylll or a simple implementation)
4. Checking if short vectors reveal factors

Usage:
    python demo_lattice.py
"""

import math
from typing import Optional


# ============================================================================
# Section 1: Finding Quadratic Residue Roots
# ============================================================================

def find_sum_sq_roots(N: int) -> Optional[tuple[int, int]]:
    """Find r₁, r₂ with N | (r₁² + r₂² + 1).

    Brute-force search over 0 ≤ r₁, r₂ < N.
    By a pigeonhole argument, such roots always exist for N ≥ 2.
    """
    for r1 in range(N):
        for r2 in range(N):
            if (r1 * r1 + r2 * r2 + 1) % N == 0:
                return (r1, r2)
    return None


# ============================================================================
# Section 2: Lattice Basis Construction
# ============================================================================

def lattice_basis(N: int, r1: int, r2: int) -> list[list[int]]:
    """Construct the 3×3 basis matrix for the sum-of-squares lattice.

    Basis vectors:
        b₁ = (N, 0, 0)
        b₂ = (0, N, 0)
        b₃ = (r₁, r₂, 1)

    The lattice Λ = {(x,y,z) : N | (x - r₁z), N | (y - r₂z)}
    has det(Λ) = N².
    """
    return [
        [N, 0, 0],
        [0, N, 0],
        [r1, r2, 1],
    ]


def verify_lattice_vector(N: int, r1: int, r2: int, v: list[int]) -> bool:
    """Check if a vector is in the lattice Λ(N, r₁, r₂)."""
    x, y, z = v
    return (x - r1 * z) % N == 0 and (y - r2 * z) % N == 0


def check_sum_sq_divisibility(N: int, v: list[int]) -> tuple[bool, int]:
    """Check if N divides x² + y² + z² and return the quotient k."""
    x, y, z = v
    s = x * x + y * y + z * z
    if s == 0:
        return True, 0
    if s % N == 0:
        return True, s // N
    return False, -1


# ============================================================================
# Section 3: Simple LLL Implementation (Gram-Schmidt)
# ============================================================================

def dot(u: list[float], v: list[float]) -> float:
    return sum(a * b for a, b in zip(u, v))


def norm_sq(v: list[float]) -> float:
    return dot(v, v)


def proj_coeff(u: list[float], v: list[float]) -> float:
    """Projection coefficient: <v, u> / <u, u>."""
    n = dot(u, u)
    if abs(n) < 1e-15:
        return 0.0
    return dot(v, u) / n


def gram_schmidt(basis: list[list[float]]) -> tuple[list[list[float]], list[list[float]]]:
    """Compute Gram-Schmidt orthogonalization."""
    n = len(basis)
    d = len(basis[0])
    ortho = [[0.0] * d for _ in range(n)]
    mu = [[0.0] * n for _ in range(n)]

    for i in range(n):
        ortho[i] = list(basis[i])
        for j in range(i):
            mu[i][j] = proj_coeff(ortho[j], basis[i])
            for k in range(d):
                ortho[i][k] -= mu[i][j] * ortho[j][k]

    return ortho, mu


def lll_reduce(basis: list[list[int]], delta: float = 0.75) -> list[list[int]]:
    """Simple LLL lattice reduction.

    Args:
        basis: List of basis vectors (as integer lists)
        delta: LLL parameter (0.25 < delta < 1.0, default 0.75)

    Returns:
        LLL-reduced basis
    """
    n = len(basis)
    d = len(basis[0])
    B = [list(map(float, v)) for v in basis]

    def recompute_gs():
        return gram_schmidt(B)

    k = 1
    while k < n:
        ortho, mu = recompute_gs()

        # Size reduction
        for j in range(k - 1, -1, -1):
            if abs(mu[k][j]) > 0.5:
                r = round(mu[k][j])
                for i in range(d):
                    B[k][i] -= r * B[j][i]
                ortho, mu = recompute_gs()

        # Lovász condition
        ortho, mu = recompute_gs()
        lhs = norm_sq(ortho[k])
        rhs = (delta - mu[k][k - 1] ** 2) * norm_sq(ortho[k - 1])

        if lhs >= rhs:
            k += 1
        else:
            B[k], B[k - 1] = B[k - 1], B[k]
            k = max(k - 1, 1)

    return [list(map(int, [round(x) for x in v])) for v in B]


# ============================================================================
# Section 4: Factoring via Short Vectors
# ============================================================================

def factor_via_lattice(N: int, verbose: bool = True) -> Optional[int]:
    """Attempt to factor N using the sum-of-squares lattice.

    Steps:
    1. Find r₁, r₂ with N | (r₁² + r₂² + 1)
    2. Build the lattice basis
    3. LLL-reduce the basis
    4. Check if any short vector reveals a factor
    """
    if verbose:
        print(f"\n{'=' * 60}")
        print(f"Attempting to factor N = {N}")
        print(f"{'=' * 60}")

    # Step 1: Find roots
    roots = find_sum_sq_roots(N)
    if roots is None:
        print(f"  No roots found for N = {N}")
        return None

    r1, r2 = roots
    k = (r1 * r1 + r2 * r2 + 1) // N
    if verbose:
        print(f"  Found roots: r₁ = {r1}, r₂ = {r2}")
        print(f"  r₁² + r₂² + 1 = {r1**2 + r2**2 + 1} = {k} × {N}")

    # Step 2: Build basis
    B = lattice_basis(N, r1, r2)
    if verbose:
        print(f"\n  Lattice basis:")
        for i, v in enumerate(B):
            print(f"    b{i+1} = {v}")
        det = N * N
        print(f"  Determinant = N² = {det}")

    # Step 3: LLL reduce
    reduced = lll_reduce(B)
    if verbose:
        print(f"\n  LLL-reduced basis:")
        for i, v in enumerate(reduced):
            ns = sum(x * x for x in v)
            print(f"    b{i+1}' = {v}  (‖v‖² = {ns})")

    # Step 4: Check for factors
    sqrt_N = math.isqrt(N)
    factor = None

    for v in reduced:
        if all(x == 0 for x in v):
            continue

        x, y, z = v
        s = x * x + y * y + z * z

        if s % N == 0:
            q = s // N
            g = math.gcd(q, N)

            if verbose:
                print(f"\n  Vector ({x}, {y}, {z}): ‖v‖² = {s} = {q} × N")
                print(f"    gcd({q}, {N}) = {g}")

            if 1 < g < N:
                if verbose:
                    print(f"    *** FACTOR FOUND: {g} ***")
                    print(f"    N = {g} × {N // g}")
                factor = g
                break
            elif g == 1:
                if verbose:
                    print(f"    (trivial gcd, no factor)")
            elif g == N:
                if verbose:
                    print(f"    (gcd = N, no info)")
        else:
            # Try gcd of sum-of-squares with N anyway
            g = math.gcd(s, N)
            if 1 < g < N:
                if verbose:
                    print(f"\n  Vector ({x}, {y}, {z}): ‖v‖² = {s}")
                    print(f"    gcd({s}, {N}) = {g}")
                    print(f"    *** FACTOR FOUND via gcd: {g} ***")
                factor = g
                break

    if factor is None and verbose:
        print(f"\n  No factor found via lattice reduction.")
        print(f"  √N ≈ {sqrt_N}")

    return factor


# ============================================================================
# Section 5: Pythagorean Quadruples
# ============================================================================

def pythagorean_quadruples(max_d: int) -> list[tuple[int, int, int, int]]:
    """Generate all Pythagorean quadruples (a,b,c,d) with a ≤ b ≤ c, d ≤ max_d."""
    quads = []
    for d in range(1, max_d + 1):
        for c in range(0, d):
            for b in range(0, c + 1):
                a_sq = d * d - b * b - c * c
                if a_sq < 0:
                    continue
                a = math.isqrt(a_sq)
                if a * a == a_sq and 0 <= a <= b:
                    quads.append((a, b, c, d))
    return quads


def quadruple_parametrization(m: int, n: int, p: int, q: int) -> tuple[int, int, int, int]:
    """The parametrization of Pythagorean quadruples:
    (a,b,c,d) = (m²+n²-p²-q², 2(mq+np), 2(nq-mp), m²+n²+p²+q²)
    """
    a = m * m + n * n - p * p - q * q
    b = 2 * (m * q + n * p)
    c = 2 * (n * q - m * p)
    d = m * m + n * n + p * p + q * q
    return (a, b, c, d)


# ============================================================================
# Section 6: Statistics and Analysis
# ============================================================================

def analyze_lattice_vectors(N: int) -> dict:
    """Analyze the distribution of short vectors in the factoring lattice."""
    roots = find_sum_sq_roots(N)
    if roots is None:
        return {"error": "no roots found"}

    r1, r2 = roots
    B = lattice_basis(N, r1, r2)
    reduced = lll_reduce(B)

    norms_sq = []
    for v in reduced:
        ns = sum(x * x for x in v)
        norms_sq.append(ns)

    shortest = min(norms_sq)
    minkowski_bound = 2.0 * (N ** 2) ** (1.0 / 3.0)  # √γ₃ · det^{1/3}
    sqrt_N = math.sqrt(N)

    return {
        "N": N,
        "roots": (r1, r2),
        "reduced_basis": reduced,
        "norms_sq": norms_sq,
        "shortest_norm_sq": shortest,
        "shortest_norm": math.sqrt(shortest),
        "sqrt_N": sqrt_N,
        "minkowski_bound": minkowski_bound,
        "ratio_to_sqrt_N": math.sqrt(shortest) / sqrt_N,
        "ratio_to_minkowski": math.sqrt(shortest) / minkowski_bound,
    }


# ============================================================================
# Section 7: Main Demo
# ============================================================================

def main():
    print("=" * 60)
    print("THE QUADRUPLE LATTICE: Computational Demos")
    print("=" * 60)

    # Demo 1: Find roots for small semiprimes
    print("\n" + "=" * 60)
    print("Demo 1: Quadratic Residue Roots")
    print("=" * 60)
    test_Ns = [6, 10, 14, 15, 21, 33, 35, 51, 55, 77, 91, 143, 221, 323, 437, 667, 899]
    for N in test_Ns:
        roots = find_sum_sq_roots(N)
        if roots:
            r1, r2 = roots
            k = (r1**2 + r2**2 + 1) // N
            print(f"  N = {N:4d}: r₁ = {r1:3d}, r₂ = {r2:3d}  "
                  f"(r₁² + r₂² + 1 = {r1**2 + r2**2 + 1} = {k}×{N})")

    # Demo 2: Factor small semiprimes
    print("\n" + "=" * 60)
    print("Demo 2: Lattice Factoring")
    print("=" * 60)
    semiprimes = [15, 21, 33, 35, 55, 77, 91, 143, 221, 323, 437, 667, 899]
    results = []
    for N in semiprimes:
        f = factor_via_lattice(N, verbose=True)
        results.append((N, f))

    # Demo 3: Statistical analysis
    print("\n" + "=" * 60)
    print("Demo 3: Shortest Vector Analysis")
    print("=" * 60)
    print(f"{'N':>6s} {'√N':>8s} {'λ₁':>8s} {'λ₁/√N':>8s} {'Mink':>8s} {'λ₁/Mink':>8s}")
    print("-" * 50)

    for N in semiprimes:
        stats = analyze_lattice_vectors(N)
        if "error" not in stats:
            print(f"{stats['N']:6d} "
                  f"{stats['sqrt_N']:8.2f} "
                  f"{stats['shortest_norm']:8.2f} "
                  f"{stats['ratio_to_sqrt_N']:8.4f} "
                  f"{stats['minkowski_bound']:8.2f} "
                  f"{stats['ratio_to_minkowski']:8.4f}")

    # Demo 4: Pythagorean quadruples
    print("\n" + "=" * 60)
    print("Demo 4: Pythagorean Quadruples (d ≤ 25)")
    print("=" * 60)
    quads = pythagorean_quadruples(25)
    for a, b, c, d in quads:
        if a > 0:  # skip degenerate
            print(f"  {a}² + {b}² + {c}² = {d}²  "
                  f"({a**2} + {b**2} + {c**2} = {d**2})")

    # Demo 5: Success rate summary
    print("\n" + "=" * 60)
    print("Demo 5: Factoring Summary")
    print("=" * 60)
    successes = sum(1 for _, f in results if f is not None)
    print(f"  Semiprimes tested: {len(results)}")
    print(f"  Factors found:     {successes}")
    print(f"  Success rate:      {100 * successes / len(results):.1f}%")

    print("\n" + "=" * 60)
    print("Demo complete.")
    print("=" * 60)


if __name__ == "__main__":
    main()
