#!/usr/bin/env python3
"""
applications.py — Real-world applications of the Tropical Satake Isomorphism.

Demonstrates:
1. Symmetric cost function optimization via orbit-min decomposition
2. Compact representation of S_n-invariant piecewise-linear functions
3. Assignment problem relaxation via tropical Schur basis
4. Permutahedron geometry and support functions
"""

from itertools import permutations
from typing import Callable
import json


def trop_schur(w: list[int], x: list[int]) -> int:
    """Tropical Schur polynomial."""
    n = len(w)
    return min(
        sum(w[sigma[i]] * x[i] for i in range(n))
        for sigma in permutations(range(n))
    )


# ──────────────────────────────────────────────────
# APPLICATION 1: Symmetric optimization
# ──────────────────────────────────────────────────
def symmetric_optimization_demo():
    """
    Any S_n-invariant piecewise-linear cost function that is an orbit-min
    polynomial can be decomposed into tropical Schur basis elements.

    This means we can optimize over the basis representation instead of
    enumerating all n! permutations each time.

    Example: Minimize a symmetric assignment-like cost.
    """
    print("=" * 60)
    print("APPLICATION 1: Symmetric Cost Function Optimization")
    print("=" * 60)

    n = 4

    # Consider the cost function: min over assignments of ∑ w(i) * x(σ(i))
    # where w = [4, 3, 2, 1] (priority weights)
    w = [4, 3, 2, 1]

    print(f"\nAssignment cost function with priority weights w = {w}")
    print(f"C(x) = min_σ ∑ w(i) * x(σ(i)) = tropSchur({w}, x)")
    print(f"\nThis finds the optimal assignment of tasks to agents,")
    print(f"where w(i) is the priority of agent i and x(j) is the cost of task j.\n")

    test_cases = [
        [10, 20, 30, 40],
        [5, 5, 5, 5],
        [1, 100, 1, 100],
        [0, 0, 0, 100],
    ]

    for x in test_cases:
        cost = trop_schur(w, x)
        # Find the optimal assignment
        best_sigma = None
        for sigma in permutations(range(n)):
            val = sum(w[i] * x[sigma[i]] for i in range(n))
            if val == cost:
                best_sigma = sigma
                break
        assignment = {f"agent_{i}": f"task_{best_sigma[i]}" for i in range(n)}
        print(f"  Tasks x={x}: optimal cost={cost}")
        print(f"    Assignment: {assignment}")
    print()


# ──────────────────────────────────────────────────
# APPLICATION 2: Compact representation
# ──────────────────────────────────────────────────
def compact_representation_demo():
    """
    The tropical Satake isomorphism says that S_n-invariant orbit-min
    functions are uniquely determined by their dominant weight.

    This gives an exponentially compact representation:
    - Naive: store all n! permutation evaluations
    - Tropical Satake: store just n integers (the dominant weight)

    The weight can be recovered from O(n) function evaluations.
    """
    print("=" * 60)
    print("APPLICATION 2: Compact Representation of Symmetric Functions")
    print("=" * 60)

    for n in range(2, 8):
        n_factorial = 1
        for i in range(1, n + 1):
            n_factorial *= i
        compression = n_factorial / n
        print(f"  GL_{n}: S_{n} has {n_factorial} elements, "
              f"dominant weight has {n} entries → "
              f"compression ratio {compression:.0f}x")

    print(f"\n  Example: recovering a GL_5 dominant weight from 5 evaluations")
    w_secret = [10, 7, 4, 2, 0]
    print(f"  Secret weight: {w_secret}")

    recovered = []
    tail_sums = []
    for k in range(5):
        test = [1 if i >= k else 0 for i in range(5)]
        tail_sums.append(trop_schur(w_secret, test))

    for k in range(4):
        recovered.append(tail_sums[k] - tail_sums[k + 1])
    recovered.append(tail_sums[4])

    print(f"  Recovered:     {recovered}")
    print(f"  Match: {'✓' if w_secret == recovered else '✗'}")
    print()


# ──────────────────────────────────────────────────
# APPLICATION 3: Permutahedron geometry
# ──────────────────────────────────────────────────
def permutahedron_demo():
    """
    tropSchur(w, x) is the support function of the permutahedron P(w),
    the convex hull of all permutations of w.

    h_P(x) = min_{v ∈ P(w)} <v, x> = min_{σ ∈ S_n} <σ(w), x>

    This connects tropical Satake theory to convex geometry.
    """
    print("=" * 60)
    print("APPLICATION 3: Permutahedron Geometry")
    print("=" * 60)

    n = 3
    w = [3, 1, 0]

    # Compute vertices of permutahedron
    vertices = set()
    for sigma in permutations(range(n)):
        vertex = tuple(w[sigma[i]] for i in range(n))
        vertices.add(vertex)

    print(f"\nDominant weight: w = {w}")
    print(f"Permutahedron P(w) has {len(vertices)} vertices:")
    for v in sorted(vertices):
        print(f"  {list(v)}")

    print(f"\nSupport function h_P(x) = tropSchur(w, x):")
    directions = [
        ([1, 0, 0], "x-axis"),
        ([0, 1, 0], "y-axis"),
        ([0, 0, 1], "z-axis"),
        ([1, 1, 0], "x+y diagonal"),
        ([1, -1, 0], "x-y direction"),
        ([1, 1, 1], "(1,1,1) direction"),
    ]
    for x, name in directions:
        val = trop_schur(w, x)
        # Find the supporting vertex
        min_vertex = min(vertices, key=lambda v: sum(vi * xi for vi, xi in zip(v, x)))
        print(f"  h_P({x}) = {val}  [supporting vertex: {list(min_vertex)}, {name}]")

    print(f"\nMinkowski sum property:")
    w1, w2 = [2, 1, 0], [1, 0, 0]
    w_sum = [w1[i] + w2[i] for i in range(n)]
    x = [2, -1, 1]
    print(f"  w1={w1}, w2={w2}, w1+w2={w_sum}")
    print(f"  tropSchur(w1, x) + tropSchur(w2, x) = "
          f"{trop_schur(w1, x)} + {trop_schur(w2, x)} = "
          f"{trop_schur(w1, x) + trop_schur(w2, x)}")
    print(f"  tropSchur(w1+w2, x) = {trop_schur(w_sum, x)}")
    print(f"  Note: tropSchur(w1,x)+tropSchur(w2,x) ≤ tropSchur(w1+w2,x)")
    print()


# ──────────────────────────────────────────────────
# APPLICATION 4: Sorting network connection
# ──────────────────────────────────────────────────
def sorting_network_demo():
    """
    The tropical Schur polynomial computes a symmetric function via
    a min-of-linear-forms representation. This connects to sorting
    networks: evaluating tropSchur efficiently is equivalent to finding
    the optimal sorting permutation for a given cost structure.
    """
    print("=" * 60)
    print("APPLICATION 4: Sorting Networks and Dynamic Programming")
    print("=" * 60)

    n = 4
    w = [4, 3, 2, 1]

    print(f"\nDominant weight w = {w}")
    print(f"tropSchur(w, x) finds the permutation σ minimizing ∑ w(σ(i)) x(i)")
    print(f"This is equivalent to sorting x to align with w optimally.\n")

    test_points = [
        [1, 2, 3, 4],
        [4, 3, 2, 1],
        [1, 4, 2, 3],
        [10, 1, 10, 1],
    ]

    for x in test_points:
        val = trop_schur(w, x)
        # Find optimal permutation
        indices = list(range(n))
        best_sigma = min(
            permutations(indices),
            key=lambda s: sum(w[s[i]] * x[i] for i in indices)
        )
        w_permuted = [w[best_sigma[i]] for i in range(n)]
        print(f"  x={x}: optimal pairing w_σ={w_permuted}, cost={val}")
        print(f"    (pairs largest w with smallest x)")

    print()


if __name__ == "__main__":
    symmetric_optimization_demo()
    compact_representation_demo()
    permutahedron_demo()
    sorting_network_demo()

    print("=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
demo.py — Concrete numerical demonstrations of the Tropical Satake Isomorphism for GL_n.

Shows that tropSchur maps dominant weights injectively into S_n-invariant
tropical polynomials, and that the Hecke basis element equals the tropical
Schur polynomial via reindexing.
"""

from itertools import permutations
from typing import Callable

def trop_inner(a: list[int], b: list[int]) -> int:
    """Inner product ∑ a(i) * b(i)."""
    return sum(ai * bi for ai, bi in zip(a, b))

def trop_schur(w: list[int], x: list[int]) -> int:
    """Tropical Schur polynomial: min over S_n of ∑ w(σ(i)) * x(i)."""
    n = len(w)
    indices = list(range(n))
    return min(
        sum(w[sigma[i]] * x[i] for i in indices)
        for sigma in permutations(indices)
    )

def hecke_basis(w: list[int], x: list[int]) -> int:
    """Hecke basis element: min over S_n of ∑ w(i) * x(σ(i))."""
    n = len(w)
    indices = list(range(n))
    return min(
        sum(w[i] * x[sigma[i]] for i in indices)
        for sigma in permutations(indices)
    )

def satake_transform(f: Callable, x: list[int]) -> int:
    """Satake transform: min over S_n of f(w · x)."""
    n = len(x)
    indices = list(range(n))
    return min(
        f([x[p[i]] for i in indices])
        for p in permutations(indices)
    )

def is_dominant(w: list[int]) -> bool:
    """Check if w is weakly decreasing."""
    return all(w[i] >= w[i+1] for i in range(len(w) - 1))

def test_vec(n: int, k: int) -> list[int]:
    """Test vector: 1 at positions i >= k, 0 elsewhere."""
    return [1 if i >= k else 0 for i in range(n)]

# ──────────────────────────────────────────────────
# DEMO 1: Hecke Basis = Tropical Schur (Reindexing)
# ──────────────────────────────────────────────────
print("=" * 60)
print("DEMO 1: heckeBasis = tropSchur (reindexing identity)")
print("=" * 60)

for n in range(2, 6):
    print(f"\n--- GL_{n} ---")
    # Use a generic dominant weight
    w = list(range(n, 0, -1))  # e.g. [5,4,3,2,1] for n=5
    for trial in range(3):
        x = [(-1)**i * (i + trial) for i in range(n)]
        h = hecke_basis(w, x)
        s = trop_schur(w, x)
        status = "✓" if h == s else "✗"
        print(f"  w={w}, x={x}: heckeBasis={h}, tropSchur={s}  {status}")

# ──────────────────────────────────────────────────
# DEMO 2: Weyl Invariance of tropSchur
# ──────────────────────────────────────────────────
print("\n" + "=" * 60)
print("DEMO 2: Weyl (S_n) invariance of tropSchur")
print("=" * 60)

for n in range(2, 6):
    print(f"\n--- GL_{n} ---")
    w = list(range(n, 0, -1))
    x = list(range(1, n + 1))
    base_val = trop_schur(w, x)
    all_ok = True
    count = 0
    for sigma in permutations(range(n)):
        x_perm = [x[sigma[i]] for i in range(n)]
        val = trop_schur(w, x_perm)
        if val != base_val:
            all_ok = False
            break
        count += 1
    print(f"  w={w}, x={x}: tropSchur(w, σ·x) = {base_val} for all {count} permutations σ  {'✓' if all_ok else '✗'}")

# ──────────────────────────────────────────────────
# DEMO 3: Injectivity via test vectors
# ──────────────────────────────────────────────────
print("\n" + "=" * 60)
print("DEMO 3: Injectivity — test vectors separate dominant weights")
print("=" * 60)

n = 4
# Generate several distinct dominant weights
dominant_weights = []
for a in range(0, 5):
    for b in range(0, a + 1):
        for c in range(0, b + 1):
            for d in range(0, c + 1):
                dominant_weights.append([a, b, c, d])

print(f"\n--- GL_{n}: {len(dominant_weights)} dominant weights ---")
print(f"Testing injectivity by evaluating tropSchur at test vectors...")

# Build fingerprint: tuple of tropSchur evaluations at test vectors
fingerprints: dict[tuple, list[int]] = {}
collisions = 0
for w in dominant_weights:
    fp = tuple(trop_schur(w, test_vec(n, k)) for k in range(n))
    if fp in fingerprints:
        print(f"  COLLISION: {w} and {fingerprints[fp]} have same fingerprint {fp}")
        collisions += 1
    fingerprints[fp] = w

if collisions == 0:
    print(f"  ✓ All {len(dominant_weights)} dominant weights have distinct fingerprints")
    print(f"  Sample fingerprints:")
    for w in dominant_weights[:5]:
        fp = tuple(trop_schur(w, test_vec(n, k)) for k in range(n))
        print(f"    w={w} → fingerprint={fp}")

# ──────────────────────────────────────────────────
# DEMO 4: Satake transform of Hecke basis
# ──────────────────────────────────────────────────
print("\n" + "=" * 60)
print("DEMO 4: satakeTransform(heckeBasis w) = tropSchur w")
print("=" * 60)

for n in range(2, 5):
    print(f"\n--- GL_{n} ---")
    w = list(range(n, 0, -1))
    for trial in range(3):
        x = [trial + i * 2 for i in range(n)]
        sat_val = satake_transform(lambda y: hecke_basis(w, y), x)
        schur_val = trop_schur(w, x)
        status = "✓" if sat_val == schur_val else "✗"
        print(f"  w={w}, x={x}: satake={sat_val}, tropSchur={schur_val}  {status}")

# ──────────────────────────────────────────────────
# DEMO 5: Tropical Schur as permutahedron support
# ──────────────────────────────────────────────────
print("\n" + "=" * 60)
print("DEMO 5: tropSchur as support function of the permutahedron")
print("=" * 60)

print("\nFor dominant weight w, tropSchur(w, x) = min over Weyl orbit of <w, x>")
print("This equals the support function of the permutahedron Perm(w).\n")

n = 3
w = [3, 1, 0]
# The Weyl orbit of w
orbit = set()
for sigma in permutations(range(n)):
    orbit.add(tuple(w[sigma[i]] for i in range(n)))

print(f"Dominant weight: w = {w}")
print(f"Weyl orbit (vertices of permutahedron): {sorted(orbit)}")
print(f"\nEvaluation at various x:")
for x in [[1, 0, 0], [0, 1, 0], [0, 0, 1], [1, 1, 0], [1, 1, 1], [2, -1, 0]]:
    val = trop_schur(w, x)
    # Also show which permutation achieves the min
    indices = list(range(n))
    min_sigma = None
    min_val = float('inf')
    for sigma in permutations(indices):
        v = sum(w[sigma[i]] * x[i] for i in indices)
        if v < min_val:
            min_val = v
            min_sigma = sigma
    print(f"  x={x}: tropSchur={val}, achieved by σ={list(min_sigma)}")

print("\n" + "=" * 60)
print("All demonstrations complete.")
print("=" * 60)
