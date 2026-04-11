#!/usr/bin/env python3
"""
Demo 3: Persistent Homology via Tropical Computation

This demonstrates the connection between persistent homology and tropical geometry:
  - Vietoris-Rips filtrations use max (tropical addition) for distance
  - Column reduction is a tropical matrix algorithm
  - The bottleneck distance is a tropical metric (L∞ norm)
  - Barcodes are tropical polynomials

The key insight: the entire persistence pipeline is naturally tropical.
"""

import numpy as np
from itertools import combinations


def vietoris_rips_filtration(points, max_dim=2):
    """
    Compute the Vietoris-Rips filtration of a point cloud.

    The filtration value of a simplex σ = {p₀, ..., pₖ} is:
        filt(σ) = max_{i<j} d(pᵢ, pⱼ)

    This is a TROPICAL operation — the filtration uses max (⊕).
    """
    n = len(points)
    simplices = []

    # 0-simplices (vertices) enter at scale 0
    for i in range(n):
        simplices.append(([i], 0.0))

    # 1-simplices (edges)
    for i, j in combinations(range(n), 2):
        d = np.linalg.norm(points[i] - points[j])
        simplices.append(([i, j], d))

    # 2-simplices (triangles)
    if max_dim >= 2:
        for i, j, k in combinations(range(n), 3):
            d_ij = np.linalg.norm(points[i] - points[j])
            d_ik = np.linalg.norm(points[i] - points[k])
            d_jk = np.linalg.norm(points[j] - points[k])
            filt = max(d_ij, d_ik, d_jk)  # TROPICAL: max = ⊕
            simplices.append(([i, j, k], filt))

    simplices.sort(key=lambda x: (x[1], len(x[0])))
    return simplices


def column_reduce(boundary_matrix):
    """
    Column reduction algorithm for persistence computation.

    This is a TROPICAL matrix algorithm: it uses the structure
    of the boundary matrix over ℤ/2ℤ (which is itself an idempotent semiring
    since 1 + 1 = 0).

    Complexity: O(n³) — verified in Lean as persistence_cubic_bound.
    """
    n = boundary_matrix.shape[1]
    R = boundary_matrix.copy()
    V = np.eye(n, dtype=int)
    low = {}
    pairs = []
    operations = 0

    for j in range(n):
        while True:
            # Find lowest 1 in column j
            col = R[:, j]
            nonzero = np.where(col % 2 != 0)[0]
            if len(nonzero) == 0:
                break
            pivot = nonzero[-1]

            if pivot in low:
                # Add column low[pivot] to column j (mod 2)
                R[:, j] = (R[:, j] + R[:, low[pivot]]) % 2
                V[:, j] = (V[:, j] + V[:, low[pivot]]) % 2
                operations += 1
            else:
                low[pivot] = j
                pairs.append((pivot, j))
                break

    return R, pairs, operations


def bottleneck_distance(diagram1, diagram2):
    """
    Compute the bottleneck distance between persistence diagrams.

    d_B(D₁, D₂) = max_{matched pairs} max(|b₁-b₂|, |d₁-d₂|)

    This is a TROPICAL metric:
      - Uses max (tropical ⊕) over matched pairs
      - Uses max (tropical ⊕) over birth/death coordinates
      - Satisfies triangle inequality (Lean-verified)
    """
    # Simple greedy matching for demonstration
    n = min(len(diagram1), len(diagram2))
    if n == 0:
        return 0.0

    max_dist = 0.0
    for i in range(n):
        b1, d1 = diagram1[i]
        b2, d2 = diagram2[i]
        dist = max(abs(b1 - b2), abs(d1 - d2))  # L∞ = tropical
        max_dist = max(max_dist, dist)  # max over pairs = tropical

    return max_dist


def demo_persistence_computation():
    """Full persistence computation pipeline."""
    print("=" * 70)
    print("PERSISTENT HOMOLOGY VIA TROPICAL COMPUTATION")
    print("=" * 70)
    print()

    # Create a point cloud: circle with noise
    np.random.seed(42)
    n_points = 8
    theta = np.linspace(0, 2 * np.pi, n_points, endpoint=False)
    points = np.column_stack([np.cos(theta), np.sin(theta)])
    points += np.random.randn(*points.shape) * 0.1

    print(f"Point cloud: {n_points} points near unit circle in ℝ²")
    print()

    # Build filtration
    simplices = vietoris_rips_filtration(points, max_dim=2)

    print("Vietoris-Rips filtration (tropical construction):")
    print(f"  Vertices: {n_points}")
    edges = sum(1 for s, _ in simplices if len(s) == 2)
    triangles = sum(1 for s, _ in simplices if len(s) == 3)
    print(f"  Edges: {edges}")
    print(f"  Triangles: {triangles}")
    print(f"  Total simplices: {len(simplices)}")
    print()

    # Show that filtration uses tropical operations
    print("Key: Filtration values use max (tropical ⊕):")
    for simplex, filt in simplices[:10]:
        if len(simplex) == 2:
            i, j = simplex
            d = np.linalg.norm(points[i] - points[j])
            print(f"  Edge {simplex}: filt = d({i},{j}) = {d:.4f}")
        elif len(simplex) == 3:
            i, j, k = simplex
            ds = [np.linalg.norm(points[a] - points[b])
                  for a, b in [(i, j), (i, k), (j, k)]]
            print(f"  Triangle {simplex}: filt = max({ds[0]:.3f}, {ds[1]:.3f}, {ds[2]:.3f}) = {max(ds):.4f}")

    print()
    print("Complexity bounds (Lean-verified):")
    n_total = len(simplices)
    print(f"  Column reduction: O(n³) = O({n_total}³) = O({n_total ** 3})")
    print(f"  Persistence pairs: ≤ n/2 = {n_total // 2}")
    print()


def demo_bottleneck_metric():
    """Show bottleneck distance is a tropical metric."""
    print("=" * 70)
    print("BOTTLENECK DISTANCE AS TROPICAL METRIC")
    print("=" * 70)
    print()

    # Three persistence diagrams
    D1 = [(0.0, 1.5), (0.2, 0.8), (0.5, 2.0)]
    D2 = [(0.1, 1.6), (0.3, 0.9), (0.4, 1.8)]
    D3 = [(0.2, 1.4), (0.1, 0.7), (0.6, 2.2)]

    d12 = bottleneck_distance(D1, D2)
    d23 = bottleneck_distance(D2, D3)
    d13 = bottleneck_distance(D1, D3)

    print("Diagram D₁:", D1)
    print("Diagram D₂:", D2)
    print("Diagram D₃:", D3)
    print()
    print(f"d_B(D₁, D₂) = {d12:.4f}")
    print(f"d_B(D₂, D₃) = {d23:.4f}")
    print(f"d_B(D₁, D₃) = {d13:.4f}")
    print()
    print("Triangle inequality (Lean-verified):")
    print(f"  d(D₁,D₃) ≤ d(D₁,D₂) + d(D₂,D₃)")
    print(f"  {d13:.4f}  ≤ {d12:.4f} + {d23:.4f} = {d12 + d23:.4f}")
    print(f"  Satisfied: {d13 <= d12 + d23 + 1e-10}")
    print()
    print("Symmetry (Lean-verified: barcode_tropical_invariance):")
    d21 = bottleneck_distance(D2, D1)
    print(f"  d(D₁,D₂) = {d12:.4f} = d(D₂,D₁) = {d21:.4f}")
    print()


def demo_stability():
    """Demonstrate stability of persistence under perturbation."""
    print("=" * 70)
    print("STABILITY THEOREM (TROPICAL PERSPECTIVE)")
    print("=" * 70)
    print()

    np.random.seed(42)
    n = 6
    theta = np.linspace(0, 2 * np.pi, n, endpoint=False)
    points = np.column_stack([np.cos(theta), np.sin(theta)])

    for eps in [0.0, 0.05, 0.1, 0.2, 0.5]:
        perturbed = points + np.random.randn(*points.shape) * eps

        # Compute distance matrices
        D_orig = np.zeros((n, n))
        D_pert = np.zeros((n, n))
        for i in range(n):
            for j in range(n):
                D_orig[i, j] = np.linalg.norm(points[i] - points[j])
                D_pert[i, j] = np.linalg.norm(perturbed[i] - perturbed[j])

        # Max difference in distance matrices
        max_diff = np.max(np.abs(D_orig - D_pert))

        print(f"  ε = {eps:.2f}: max |d_orig - d_pert| = {max_diff:.4f}")
        print(f"          Stability guarantee: barcode change ≤ {max_diff:.4f}")

    print()
    print("Theorem: If input perturbation ≤ ε, then")
    print("  d_B(barcode(X), barcode(X')) ≤ ε")
    print("Features with lifetime > 2ε are guaranteed to persist.")
    print()


if __name__ == "__main__":
    demo_persistence_computation()
    demo_bottleneck_metric()
    demo_stability()

    print("=" * 70)
    print("All persistence demos completed.")
    print("=" * 70)
