#!/usr/bin/env python3
"""
Demo 3: Pythagorean Quadruple Lattice and LLL/BKZ Reduction

Explores the 3D lattice L₄ = {(x,y,z) : x² + y² + z² ≡ 0 (mod N²)}
and its potential for sub-√N factoring.
"""

import numpy as np
from math import gcd, isqrt
from itertools import product as cart_product


def find_three_square_reps(N, max_search=None):
    """Find all representations N = x² + y² + z² with 0 ≤ x ≤ y ≤ z."""
    if max_search is None:
        max_search = isqrt(N) + 1

    reps = []
    for z in range(isqrt(N), -1, -1):
        rem = N - z*z
        if rem < 0:
            continue
        for y in range(min(z, isqrt(rem)), -1, -1):
            rem2 = rem - y*y
            if rem2 < 0:
                continue
            x = isqrt(rem2)
            if x*x == rem2 and x <= y:
                reps.append((x, y, z))
    return reps


def construct_quadruple_lattice_basis(N):
    """
    Construct a basis for L₄ = {(x,y,z) ∈ Z³ : x² + y² + z² ≡ 0 (mod N)}.

    Strategy: Find three linearly independent vectors in L₄.
    Start with (N, 0, 0), then find two more via three-square representations.
    """
    # The trivial basis: N · e₁, N · e₂, N · e₃
    trivial_basis = np.array([
        [N, 0, 0],
        [0, N, 0],
        [0, 0, N]
    ], dtype=int)

    # Try to find shorter vectors
    reps = find_three_square_reps(N)

    if reps:
        # Use first rep as a short vector
        x, y, z = reps[0]
        # Check: x² + y² + z² = N, so (x, y, z) ∈ L₄
        basis = np.array([
            [x, y, z],   # Short vector from 3-square rep
            [N, 0, 0],   # Standard basis
            [0, N, 0],
        ], dtype=int)
    else:
        basis = trivial_basis

    return basis


def gram_schmidt(basis):
    """Gram-Schmidt orthogonalization (returns orthogonal basis and coefficients)."""
    n = len(basis)
    ortho = np.zeros_like(basis, dtype=float)
    mu = np.zeros((n, n), dtype=float)

    for i in range(n):
        ortho[i] = basis[i].astype(float)
        for j in range(i):
            if np.dot(ortho[j], ortho[j]) > 1e-10:
                mu[i][j] = np.dot(basis[i].astype(float), ortho[j]) / np.dot(ortho[j], ortho[j])
                ortho[i] -= mu[i][j] * ortho[j]

    return ortho, mu


def lll_reduce(basis, delta=0.75):
    """
    LLL lattice reduction algorithm.

    Input: integer basis matrix (rows are basis vectors)
    Output: LLL-reduced basis
    """
    n = len(basis)
    basis = basis.astype(float).copy()

    def gs_update():
        return gram_schmidt(basis)

    k = 1
    iterations = 0
    while k < n:
        ortho, mu = gs_update()

        # Size-reduce basis[k]
        for j in range(k-1, -1, -1):
            if abs(mu[k][j]) > 0.5:
                basis[k] -= round(mu[k][j]) * basis[j]
                ortho, mu = gs_update()

        # Lovász condition
        lhs = np.dot(ortho[k], ortho[k])
        rhs = (delta - mu[k][k-1]**2) * np.dot(ortho[k-1], ortho[k-1])

        if lhs >= rhs:
            k += 1
        else:
            # Swap basis[k] and basis[k-1]
            basis[[k, k-1]] = basis[[k-1, k]]
            k = max(k-1, 1)

        iterations += 1
        if iterations > 1000:
            break

    return basis.astype(int) if np.allclose(basis, np.round(basis)) else np.round(basis).astype(int)


def extract_factor_from_vector(v, N):
    """
    Given a vector v = (x, y, z) with x² + y² + z² ≡ 0 (mod N),
    try to extract a factor of N.
    """
    x, y, z = int(v[0]), int(v[1]), int(v[2])
    candidates = [
        gcd(abs(x), N),
        gcd(abs(y), N),
        gcd(abs(z), N),
        gcd(x*x + y*y, N),
        gcd(x*x + z*z, N),
        gcd(y*y + z*z, N),
        gcd(abs(x*y), N),
        gcd(abs(x*z), N),
        gcd(abs(y*z), N),
    ]

    for g in candidates:
        if 1 < g < N:
            return g
    return None


# ============================================================================
# Lorentz Group O(3,1;Z) Generators
# ============================================================================

def lorentz_generator_xy():
    """Rotation in xy-plane (preserves x² + y² + z² - w²)."""
    # This is a Givens rotation adapted for the Lorentz form
    return np.array([
        [ 0, -1,  0, 0],
        [ 1,  0,  0, 0],
        [ 0,  0,  1, 0],
        [ 0,  0,  0, 1]
    ], dtype=int)


def lorentz_generator_xz():
    """Rotation in xz-plane."""
    return np.array([
        [ 0,  0, -1, 0],
        [ 0,  1,  0, 0],
        [ 1,  0,  0, 0],
        [ 0,  0,  0, 1]
    ], dtype=int)


def lorentz_boost_x():
    """Boost in x-direction: preserves x² + y² + z² - w², integer version."""
    # Using the simplest integer Lorentz boost
    return np.array([
        [ 2,  0,  0, 1],
        [ 0,  1,  0, 0],
        [ 0,  0,  1, 0],
        [ 1,  0,  0, 2]
    ], dtype=int)


def verify_lorentz(M):
    """Verify M^T · η · M = η where η = diag(1,1,1,-1)."""
    eta = np.diag([1, 1, 1, -1])
    result = M.T @ eta @ M
    return np.array_equal(result, eta)


# ============================================================================
# Demo
# ============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("DEMO: Pythagorean Quadruple Lattice & Higher-Dimensional Escape")
    print("=" * 70)

    # 1. Three-square representations
    print("\n--- Section 1: Three-Square Representations ---")
    for N in [6, 14, 21, 35, 77, 143]:
        reps = find_three_square_reps(N)
        rep_strs = [f"({x},{y},{z})" for x, y, z in reps]
        print(f"  {N:4d} = " + " = ".join(
            [f"{x}² + {y}² + {z}²" for x, y, z in reps[:3]]
        ) if reps else f"  {N:4d}: no representation (≡ 7 mod 8?)")

    # 2. Quadruple lattice construction
    print(f"\n{'=' * 70}")
    print("--- Section 2: Quadruple Lattice Construction ---")

    N = 35  # = 5 × 7
    print(f"\nN = {N} = 5 × 7")

    basis = construct_quadruple_lattice_basis(N)
    print(f"\nInitial basis for L₄:")
    for i, v in enumerate(basis):
        norm = np.linalg.norm(v)
        check = (v[0]**2 + v[1]**2 + v[2]**2) % N
        print(f"  b{i+1} = ({v[0]:4d}, {v[1]:4d}, {v[2]:4d})  |b| = {norm:8.2f}  x²+y²+z² mod N = {check}")

    # 3. LLL reduction
    print(f"\n{'=' * 70}")
    print("--- Section 3: LLL Reduction of Quadruple Lattice ---")

    reduced = lll_reduce(basis)
    print(f"\nLLL-reduced basis:")
    for i, v in enumerate(reduced):
        norm = np.linalg.norm(v)
        check = (v[0]**2 + v[1]**2 + v[2]**2) % N
        print(f"  b{i+1} = ({v[0]:4d}, {v[1]:4d}, {v[2]:4d})  |b| = {norm:8.2f}  x²+y²+z² mod N = {check}")

    # 4. Factor extraction
    print(f"\n{'=' * 70}")
    print("--- Section 4: Factor Extraction from Short Vectors ---")

    for v in reduced:
        factor = extract_factor_from_vector(v, N)
        if factor:
            print(f"  Vector ({v[0]}, {v[1]}, {v[2]}) → factor {factor} (N = {factor} × {N // factor})")

    # 5. Lorentz group verification
    print(f"\n{'=' * 70}")
    print("--- Section 5: O(3,1;ℤ) Generator Verification ---")

    generators = {
        "R_xy (xy-rotation)": lorentz_generator_xy(),
        "R_xz (xz-rotation)": lorentz_generator_xz(),
        "B_x  (x-boost)":     lorentz_boost_x(),
    }

    for name, M in generators.items():
        is_lorentz = verify_lorentz(M)
        det = int(round(np.linalg.det(M)))
        print(f"  {name}: det = {det:+d}, preserves η? {is_lorentz}")

    # 6. Quadruple generation
    print(f"\n{'=' * 70}")
    print("--- Section 6: Pythagorean Quadruples from O(3,1;ℤ) ---")

    # Start with (1, 0, 0, 1) which satisfies 1² + 0² + 0² = 1²
    seed = np.array([1, 0, 0, 1], dtype=int)
    print(f"  Seed quadruple: {tuple(seed)}")
    print(f"  Check: {seed[0]}² + {seed[1]}² + {seed[2]}² = {seed[0]**2 + seed[1]**2 + seed[2]**2} = {seed[3]}² = {seed[3]**2}")

    quadruples = set()
    quadruples.add(tuple(seed))

    # Apply generators repeatedly
    queue = [seed]
    for _ in range(3):
        new_queue = []
        for q in queue:
            for name, M in generators.items():
                new_q = M @ q
                if all(x >= 0 for x in new_q) and new_q[3] > 0 and new_q[3] < 200:
                    t = tuple(new_q)
                    if t not in quadruples:
                        quadruples.add(t)
                        new_queue.append(new_q)
                        a, b, c, d = new_q
                        check = a**2 + b**2 + c**2 == d**2
                        print(f"  {t}: {a}² + {b}² + {c}² = {a**2+b**2+c**2}, {d}² = {d**2} {'✓' if check else '✗'}")
        queue = new_queue

    # 7. Comparison: 2D vs 3D
    print(f"\n{'=' * 70}")
    print("--- Section 7: 2D vs 3D Lattice Comparison ---")
    print("=" * 70)
    print("""
    DIMENSION 2 (Pythagorean Triples):
    • Lattice: L₂ = {(x,y) : x² + y² ≡ 0 (mod N)}
    • Reduction: Gauss's algorithm (OPTIMAL for d=2)
    • Complexity: Θ(√N) for balanced semiprimes
    • Corresponds to: Berggren tree descent

    DIMENSION 3 (Pythagorean Quadruples):
    • Lattice: L₄ = {(x,y,z) : x² + y² + z² ≡ 0 (mod N)}
    • Reduction: LLL/BKZ (BETTER than Gauss for d≥3)
    • Approximation: LLL gives 2^{(d-1)/2} factor → 2 for d=3
    • Corresponds to: O(3,1;ℤ) tree descent

    KEY INSIGHT: The structured basis from O(3,1;ℤ) generators may
    give BKZ an advantage over random starting bases, potentially
    enabling sub-√N factoring for structured semiprimes.
    """)

    # 8. Experimental comparison
    print("--- Experimental: Shortest vector comparison ---")
    print(f"  {'N':>8s}  {'2D shortest':>12s}  {'3D shortest':>12s}  {'ratio':>8s}")
    print(f"  {'—'*8}  {'—'*12}  {'—'*12}  {'—'*8}")

    for N in [15, 21, 35, 77, 143, 221, 323]:
        # 2D: simple lattice
        best_2d = N  # trivial vector (N, 0)
        for x in range(1, isqrt(N) + 2):
            for y in range(1, isqrt(N) + 2):
                if (x*x + y*y) % N == 0:
                    norm = (x*x + y*y) ** 0.5
                    best_2d = min(best_2d, norm)

        # 3D: with LLL
        basis_3d = construct_quadruple_lattice_basis(N)
        reduced_3d = lll_reduce(basis_3d)
        norms_3d = [np.linalg.norm(v) for v in reduced_3d if np.linalg.norm(v) > 0.1]
        best_3d = min(norms_3d) if norms_3d else N

        ratio = best_3d / best_2d if best_2d > 0 else float('inf')
        print(f"  {N:8d}  {best_2d:12.4f}  {best_3d:12.4f}  {ratio:8.4f}")
