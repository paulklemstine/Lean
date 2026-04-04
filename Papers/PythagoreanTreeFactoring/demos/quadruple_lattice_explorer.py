#!/usr/bin/env python3
"""
Pythagorean Quadruple Lattice Explorer
=======================================

Explores the structure of the Pythagorean quadruple lattice
L₄(N) = {(x,y,z) : x² + y² + z² ≡ 0 (mod N)}

and its connection to O(3,1;ℤ) (the integer Lorentz group).

This is the "escape route" from the 2D Θ(√N) barrier:
in 3+ dimensions, lattice reduction can potentially find
shorter vectors than Gauss's algorithm.
"""

import numpy as np
from math import gcd, isqrt
from itertools import product
import json

# ============================================================================
# Pythagorean Quadruples
# ============================================================================

def find_quadruples(max_d=50):
    """Find all primitive Pythagorean quadruples (a,b,c,d) with d ≤ max_d.
    a² + b² + c² = d², a ≤ b ≤ c, gcd(a,b,c,d) = 1.
    """
    quads = []
    for d in range(1, max_d + 1):
        for c in range(1, d):
            for b in range(1, c + 1):
                a_sq = d*d - c*c - b*b
                if a_sq <= 0:
                    continue
                a = isqrt(a_sq)
                if a*a == a_sq and a <= b:
                    g = gcd(gcd(a, b), gcd(c, d))
                    if g == 1:
                        quads.append((a, b, c, d))
    return quads


def print_quadruples(max_d=30):
    """Display all primitive Pythagorean quadruples up to hypotenuse max_d."""
    quads = find_quadruples(max_d)
    print(f"Primitive Pythagorean quadruples with d ≤ {max_d}:")
    print(f"{'(a, b, c, d)':>20}  {'a²+b²+c²':>10}  {'d²':>8}  {'Check':>6}")
    print("-" * 50)
    for a, b, c, d in quads:
        s = a*a + b*b + c*c
        print(f"({a:3d},{b:3d},{c:3d},{d:3d})  {s:10d}  {d*d:8d}  {'✓' if s == d*d else '✗':>6}")
    print(f"\nTotal: {len(quads)} primitive quadruples")
    return quads


# ============================================================================
# Three-Square Representations
# ============================================================================

def three_square_representations(N, max_reps=20):
    """Find representations N = x² + y² + z² (or k*N = x² + y² + z² for small k)."""
    reps = []
    limit = isqrt(N) + 1
    for x in range(limit):
        for y in range(x, limit):
            z_sq = N - x*x - y*y
            if z_sq < y*y:
                break
            if z_sq < 0:
                break
            z = isqrt(z_sq)
            if z*z == z_sq:
                reps.append((x, y, z))
                if len(reps) >= max_reps:
                    return reps
    return reps


def analyze_three_square(N):
    """Analyze three-square representations of N for factoring potential."""
    print(f"\nThree-square representations of N = {N}:")
    reps = three_square_representations(N)

    if not reps:
        # By Legendre's three-square theorem, N cannot be represented iff
        # N = 4^a(8b+7) for some a, b ≥ 0
        print(f"  No representations found (N ≡ {N % 8} mod 8)")
        return

    for x, y, z in reps:
        print(f"  {N} = {x}² + {y}² + {z}² = {x*x} + {y*y} + {z*z}")

        # Check for factor extraction
        for val in [x, y, z, x+y, x-y, x+z, x-z, y+z, y-z,
                    x*x+y*y, y*y+z*z, x*x+z*z]:
            g = gcd(abs(val), N)
            if 1 < g < N:
                print(f"    → gcd({val}, {N}) = {g} — FACTOR!")


# ============================================================================
# Quadruple Lattice L₄(N)
# ============================================================================

def enumerate_lattice_points(N, radius=None):
    """Find points in L₄(N) = {(x,y,z) : x²+y²+z² ≡ 0 mod N} within radius."""
    if radius is None:
        radius = min(isqrt(3 * N) + 1, 100)

    points = []
    for x in range(-radius, radius + 1):
        for y in range(-radius, radius + 1):
            for z in range(-radius, radius + 1):
                if (x*x + y*y + z*z) % N == 0:
                    norm = (x*x + y*y + z*z)
                    if norm > 0:
                        points.append((x, y, z, norm, norm // N))
    return points


def analyze_lattice(N, max_points=50):
    """Analyze the structure of L₄(N)."""
    print(f"\n{'='*60}")
    print(f"QUADRUPLE LATTICE L₄({N})")
    print(f"{'='*60}")
    print(f"L₄({N}) = {{(x,y,z) ∈ ℤ³ : x²+y²+z² ≡ 0 (mod {N})}}")

    points = enumerate_lattice_points(N, radius=min(2*isqrt(N), 30))
    points.sort(key=lambda p: p[3])  # Sort by norm

    print(f"\nShortest vectors (up to {max_points}):")
    print(f"{'(x, y, z)':>20}  {'‖v‖²':>8}  {'k=‖v‖²/N':>8}  {'Factor?':>10}")
    print("-" * 55)

    factors_found = set()
    for i, (x, y, z, norm, k) in enumerate(points[:max_points]):
        # Check for factors
        factor_str = ""
        for val in [x, y, z, x+y, x-y, x+z, x-z, y+z, y-z]:
            g = gcd(abs(val), N)
            if 1 < g < N:
                factor_str = f"gcd={g}"
                factors_found.add(g)
                break

        print(f"({x:4d},{y:4d},{z:4d})  {norm:8d}  {k:8d}  {factor_str:>10}")

    if factors_found:
        print(f"\nFactors found via GCD extraction: {factors_found}")
    else:
        print(f"\nNo factors found via simple GCD extraction")

    # Statistics
    print(f"\nLattice statistics:")
    print(f"  Total points found: {len(points)}")
    if points:
        norms = [p[3] for p in points]
        print(f"  Shortest vector norm²: {min(norms)}")
        print(f"  Shortest vector norm: {np.sqrt(min(norms)):.4f}")
        print(f"  √N = {np.sqrt(N):.4f}")
        print(f"  Ratio (shortest/√N): {np.sqrt(min(norms))/np.sqrt(N):.4f}")

    return points, factors_found


# ============================================================================
# O(3,1;ℤ) Generators
# ============================================================================

def lorentz_generators():
    """Return generators for O(3,1;ℤ), the integer Lorentz group.

    These are 4×4 integer matrices M with M^T η M = η
    where η = diag(1,1,1,-1).

    Generators include:
    - Spatial rotations (permutations and sign changes of first 3 coords)
    - Boosts (hyperbolic rotations in a space-time plane)
    """
    gens = []

    # Spatial permutation (12)
    gens.append(np.array([
        [0, 1, 0, 0],
        [1, 0, 0, 0],
        [0, 0, 1, 0],
        [0, 0, 0, 1]
    ], dtype=np.int64))

    # Spatial permutation (23)
    gens.append(np.array([
        [1, 0, 0, 0],
        [0, 0, 1, 0],
        [0, 1, 0, 0],
        [0, 0, 0, 1]
    ], dtype=np.int64))

    # Spatial reflection (1)
    gens.append(np.array([
        [-1, 0, 0, 0],
        [0, 1, 0, 0],
        [0, 0, 1, 0],
        [0, 0, 0, 1]
    ], dtype=np.int64))

    # Boost in (1,4) plane: the simplest integer Lorentz boost
    # For Q = x²+y²+z²-t², the matrix [[2,0,0,1],[0,1,0,0],[0,0,1,0],[1,0,0,2]]
    # does NOT preserve Q (check: 2²+0+0-1² = 3 ≠ 1).
    # The correct integer boost uses (a,b,c,d) → ...
    # Actually, the Berggren-type generators for quadruples are:
    # From the parametrization (a,b,c,d) = (2mp-2nq, m²+n²-p²-q², 2mq+2np, m²+n²+p²+q²)

    # A simple boost that DOES preserve Q:
    # We need M^T diag(1,1,1,-1) M = diag(1,1,1,-1)
    # The matrix [[1,0,0,0],[0,1,0,0],[0,0,2,1],[0,0,1,2]]
    # preserves x₁² + x₂² + (2x₃+x₄)² - (x₃+2x₄)²
    # = x₁² + x₂² + 4x₃²+4x₃x₄+x₄² - x₃²-4x₃x₄-4x₄²
    # = x₁² + x₂² + 3x₃² - 3x₄² ≠ Q. Not right.

    # The correct primitive boost: [[3,0,0,2],[0,1,0,0],[0,0,1,0],[2,0,0,3]]
    # Check: row 0: 3²+0+0-2² = 5 ≠ 1. Still wrong.

    # Actually: [[1,0,0,0],[0,1,0,0],[0,0,cosh,sinh],[0,0,sinh,cosh]]
    # with cosh²-sinh² = 1, i.e., Pell equation. (cosh,sinh)=(1,0),(3,2√2)...
    # No integer solutions except (1,0). For rational: use (m²+n²,2mn)/(m²-n²).

    # The group O(3,1;ℤ) is generated by permutations + sign changes
    # of the first 3 coordinates. There are no nontrivial integer boosts
    # because cosh²-sinh²=1 has no integer solutions with sinh≠0.

    # HOWEVER, O₊(3,1;ℤ) (preserving the form up to a scalar) is richer.
    # For factoring, we actually want GL transformations that preserve
    # the lattice structure modulo N.

    return gens


def verify_lorentz(M, eta=None):
    """Verify that M is in O(3,1;ℤ): M^T η M = η."""
    if eta is None:
        eta = np.diag([1, 1, 1, -1])
    return np.array_equal(M.T @ eta @ M, eta)


def explore_lorentz_orbits(seed_quad, gens, max_depth=3):
    """Explore the orbit of a quadruple under O(3,1;ℤ) generators."""
    visited = {tuple(seed_quad)}
    frontier = [np.array(seed_quad)]
    all_quads = [tuple(seed_quad)]

    for depth in range(max_depth):
        new_frontier = []
        for v in frontier:
            for M in gens:
                w = M @ v
                key = tuple(w)
                if key not in visited:
                    visited.add(key)
                    new_frontier.append(w)
                    all_quads.append(key)
        frontier = new_frontier
        if not frontier:
            break

    return all_quads


# ============================================================================
# BKZ Simulation
# ============================================================================

def bkz_reduce_3d(basis, block_size=3, max_tours=10):
    """Simplified BKZ reduction for 3D lattices.

    BKZ with block_size β processes overlapping blocks of β consecutive
    basis vectors, applying enumeration within each block to find the
    shortest vector in the projected sublattice.

    For β = d (full dimension), this is equivalent to exact SVP.
    """
    n = len(basis)
    B = [np.array(b, dtype=np.float64) for b in basis]

    def norm(v):
        return np.sqrt(np.sum(v**2))

    # Simple implementation: repeatedly size-reduce and swap
    improved = True
    tours = 0
    while improved and tours < max_tours:
        improved = False
        tours += 1

        for k in range(n):
            # Size-reduce B[k] against all previous
            for j in range(k - 1, -1, -1):
                if norm(B[j]) > 1e-10:
                    mu = np.dot(B[k], B[j]) / np.dot(B[j], B[j])
                    if abs(mu) > 0.5:
                        B[k] = B[k] - round(mu) * B[j]
                        improved = True

            # Check for swap
            if k > 0 and norm(B[k]) < norm(B[k-1]) * 0.99:
                B[k], B[k-1] = B[k-1], B[k]
                improved = True

    return [np.array(b, dtype=np.int64) for b in B], tours


# ============================================================================
# SCG Visualization Data
# ============================================================================

def generate_lattice_scg(N, radius=15):
    """Generate SCG visualization data for the quadruple lattice."""
    points = enumerate_lattice_points(N, radius)

    scg_data = {
        "title": f"Quadruple Lattice L₄({N})",
        "N": N,
        "sqrt_N": float(np.sqrt(N)),
        "points": [],
        "edges": [],
        "metadata": {
            "total_points": len(points),
            "shortest_norm": min(p[3] for p in points) if points else None,
            "description": f"Lattice points (x,y,z) with x²+y²+z² ≡ 0 (mod {N})"
        }
    }

    for x, y, z, norm, k in points[:200]:  # Cap at 200 for visualization
        scg_data["points"].append({
            "x": x, "y": y, "z": z,
            "norm_sq": norm,
            "k": k,
            "has_factor": any(1 < gcd(abs(v), N) < N for v in [x, y, z])
        })

    return scg_data


# ============================================================================
# Main Exploration
# ============================================================================

if __name__ == "__main__":
    print("PYTHAGOREAN QUADRUPLE LATTICE EXPLORER")
    print("="*60)

    # 1. List primitive quadruples
    quads = print_quadruples(max_d=25)

    # 2. Explore three-square representations for some semiprimes
    for N in [15, 21, 35, 77, 143, 221]:
        analyze_three_square(N)

    # 3. Analyze the quadruple lattice for some semiprimes
    for N in [15, 21, 35]:
        analyze_lattice(N, max_points=20)

    # 4. Explore O(3,1;ℤ) orbits
    print("\n" + "="*60)
    print("O(3,1;ℤ) ORBIT EXPLORATION")
    print("="*60)
    gens = lorentz_generators()
    print(f"Number of generators: {len(gens)}")
    for i, M in enumerate(gens):
        is_lor = verify_lorentz(M)
        print(f"  Generator {i}: {'✓' if is_lor else '✗'} Lorentz")

    seed = (1, 2, 2, 3)  # 1² + 2² + 2² = 9 = 3²
    print(f"\nOrbit of {seed}:")
    orbit = explore_lorentz_orbits(seed, gens, max_depth=3)
    for q in sorted(set(orbit))[:20]:
        a, b, c, d = q
        check = a*a + b*b + c*c == d*d
        print(f"  {q}  {'✓' if check else '✗'}")

    # 5. BKZ experiment
    print("\n" + "="*60)
    print("BKZ REDUCTION EXPERIMENT")
    print("="*60)

    N = 143  # = 11 × 13
    basis, short_vecs = construct_quadruple_lattice(N)
    if len(short_vecs) >= 3:
        print(f"\nOriginal basis for L₄({N}):")
        for v in short_vecs[:3]:
            print(f"  {v}  (norm = {np.linalg.norm(v):.2f})")

        reduced, tours = bkz_reduce_3d(short_vecs[:3], block_size=3)
        print(f"\nBKZ-reduced basis ({tours} tours):")
        for v in reduced:
            print(f"  {v}  (norm = {np.linalg.norm(v):.2f})")
            x, y, z = int(v[0]), int(v[1]), int(v[2])
            g = gcd(gcd(abs(x), abs(y)), gcd(abs(z), N))
            if 1 < g < N:
                print(f"    → Factor: {g}")

    # 6. Generate SCG data
    scg = generate_lattice_scg(15, radius=10)
    with open("quadruple_lattice_scg.json", 'w') as f:
        json.dump(scg, f, indent=2)
    print(f"\nSCG data saved to quadruple_lattice_scg.json")

    print("\nExploration complete.")
