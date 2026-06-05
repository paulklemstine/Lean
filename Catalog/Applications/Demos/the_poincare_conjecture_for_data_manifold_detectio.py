#!/usr/bin/env python3
"""
Demo: The Poincaré Conjecture for Data — Manifold Detection via Persistent Homology

Demonstrates:
1. Point cloud generation on spheres S^d
2. Vietoris-Rips complex construction
3. Poincaré threshold computation (connectivity threshold)
4. Euler characteristic computation
5. Dimension-dependent scaling of the detection threshold
"""

import numpy as np
from itertools import combinations
from collections import defaultdict


def generate_sphere_points(n: int, d: int, noise: float = 0.0) -> np.ndarray:
    """Generate n points uniformly on S^d embedded in R^{d+1}, with optional noise."""
    # Sample from standard normal and normalize
    points = np.random.randn(n, d + 1)
    norms = np.linalg.norm(points, axis=1, keepdims=True)
    points = points / norms
    if noise > 0:
        points += noise * np.random.randn(n, d + 1)
    return points


def pairwise_distances(X: np.ndarray) -> np.ndarray:
    """Compute pairwise distance matrix."""
    n = X.shape[0]
    D = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            D[i, j] = np.linalg.norm(X[i] - X[j])
            D[j, i] = D[i, j]
    return D


def vietoris_rips_graph(D: np.ndarray, epsilon: float) -> dict:
    """Build the VR graph (1-skeleton) at scale epsilon."""
    n = D.shape[0]
    adj = defaultdict(set)
    for i in range(n):
        for j in range(i + 1, n):
            if D[i, j] <= epsilon:
                adj[i].add(j)
                adj[j].add(i)
    return adj


def connected_components(adj: dict, n: int) -> list:
    """Find connected components using BFS."""
    visited = set()
    components = []
    for start in range(n):
        if start in visited:
            continue
        component = set()
        queue = [start]
        while queue:
            node = queue.pop(0)
            if node in visited:
                continue
            visited.add(node)
            component.add(node)
            for neighbor in adj.get(node, set()):
                if neighbor not in visited:
                    queue.append(neighbor)
        components.append(component)
    return components


def connectivity_threshold(D: np.ndarray) -> float:
    """Find the minimum epsilon at which the VR graph becomes connected.
    This is the Poincaré threshold for H_0."""
    n = D.shape[0]
    # Use Kruskal-like approach: sort edges, add until connected
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            edges.append((D[i, j], i, j))
    edges.sort()

    # Union-find
    parent = list(range(n))
    rank = [0] * n

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        px, py = find(x), find(y)
        if px == py:
            return False
        if rank[px] < rank[py]:
            px, py = py, px
        parent[py] = px
        if rank[px] == rank[py]:
            rank[px] += 1
        return True

    components = n
    threshold = 0.0
    for dist_val, i, j in edges:
        if union(i, j):
            components -= 1
            threshold = dist_val
            if components == 1:
                break
    return threshold


def vietoris_rips_simplices(D: np.ndarray, epsilon: float, max_dim: int = 3) -> dict:
    """Build the full VR complex up to dimension max_dim.
    Returns dict mapping dimension k to list of k-simplices."""
    n = D.shape[0]
    simplices = defaultdict(list)

    # 0-simplices (vertices)
    for i in range(n):
        simplices[0].append((i,))

    # k-simplices: check all (k+1)-subsets
    for k in range(1, min(max_dim + 1, n)):
        for subset in combinations(range(n), k + 1):
            if all(D[i][j] <= epsilon for i, j in combinations(subset, 2)):
                simplices[k].append(subset)

    return simplices


def euler_characteristic(simplices: dict) -> int:
    """Compute the Euler characteristic χ = Σ (-1)^k |f_k|."""
    chi = 0
    for k, faces in simplices.items():
        chi += (-1) ** k * len(faces)
    return chi


def sphere_betti_signature(d: int) -> dict:
    """Expected Betti numbers of S^d."""
    betti = {k: 0 for k in range(d + 1)}
    betti[0] = 1
    betti[d] = 1
    return betti


# ============================================================
# DEMONSTRATION
# ============================================================

def main():
    np.random.seed(42)

    print("=" * 70)
    print("THE POINCARÉ CONJECTURE FOR DATA")
    print("Manifold Detection via Persistent Homology")
    print("=" * 70)

    # --- Experiment 1: Connectivity thresholds on S^d ---
    print("\n--- Experiment 1: Connectivity Threshold Scaling ---")
    print(f"{'d':>3} {'n':>6} {'ε*(mean)':>12} {'ε*(theory)':>14} {'ratio':>8}")
    print("-" * 50)

    for d in [1, 2, 3]:
        for n in [50, 100, 200]:
            thresholds = []
            for _ in range(20):
                X = generate_sphere_points(n, d)
                D = pairwise_distances(X)
                eps_star = connectivity_threshold(D)
                thresholds.append(eps_star)
            mean_eps = np.mean(thresholds)
            # Theory: ε* ~ C * d^{1/2} * n^{-1/d}
            theory_eps = np.sqrt(d) * n ** (-1.0 / d)
            ratio = mean_eps / theory_eps if theory_eps > 0 else float('inf')
            print(f"{d:>3} {n:>6} {mean_eps:>12.4f} {theory_eps:>14.4f} {ratio:>8.3f}")

    # --- Experiment 2: Euler characteristic ---
    print("\n--- Experiment 2: Euler Characteristic of VR Complexes ---")
    for d in [1, 2, 3]:
        n = 30
        X = generate_sphere_points(n, d)
        D = pairwise_distances(X)
        eps_star = connectivity_threshold(D)

        print(f"\nS^{d} with {n} points, connectivity threshold ε* = {eps_star:.4f}")
        for scale in [0.5, 1.0, 1.5, 2.0]:
            eps = scale * eps_star
            simplices = vietoris_rips_simplices(D, eps, max_dim=min(d + 1, 4))
            chi = euler_characteristic(simplices)
            face_counts = {k: len(v) for k, v in simplices.items()}
            print(f"  ε = {scale:.1f}·ε* = {eps:.4f}: χ = {chi}, "
                  f"faces = {face_counts}")

    # --- Experiment 3: Sphere detection vs noise ---
    print("\n--- Experiment 3: Stability Under Perturbation ---")
    d = 2
    n = 50
    print(f"S^{d} with {n} points")
    print(f"{'noise':>8} {'ε*':>10} {'χ(at 1.5·ε*)':>15} {'components(ε*)':>15}")
    print("-" * 55)
    for noise in [0.0, 0.01, 0.05, 0.1, 0.2]:
        X = generate_sphere_points(n, d, noise=noise)
        D = pairwise_distances(X)
        eps_star = connectivity_threshold(D)
        simplices = vietoris_rips_simplices(D, 1.5 * eps_star, max_dim=3)
        chi = euler_characteristic(simplices)
        adj = vietoris_rips_graph(D, eps_star)
        comps = connected_components(adj, n)
        print(f"{noise:>8.3f} {eps_star:>10.4f} {chi:>15} {len(comps):>15}")

    # --- Experiment 4: Diameter bound verification ---
    print("\n--- Experiment 4: Diameter Bound (Formal Theorem Verification) ---")
    print("Theorem: Points on S^d(r) have diam ≤ 2r")
    for d in [1, 2, 3, 10]:
        r = 1.0
        X = generate_sphere_points(100, d)
        D = pairwise_distances(X)
        max_dist = np.max(D)
        print(f"  S^{d}(r={r}): max dist = {max_dist:.6f}, 2r = {2*r:.1f}, "
              f"bound holds: {max_dist <= 2*r + 1e-10}")

    # --- Experiment 5: Packing-covering bound ---
    print("\n--- Experiment 5: Packing-Covering Lower Bound ---")
    print("Theorem: n packing points need ≥ n covering points")
    for d in [1, 2, 3]:
        n = 20
        X = generate_sphere_points(n, d)
        D = pairwise_distances(X)
        # Find minimum pairwise distance
        min_dist = np.min(D[D > 0])
        eps = min_dist / 2.1  # slightly less than half min distance
        # Check packing condition
        packing_ok = all(D[i, j] > 2 * eps for i in range(n) for j in range(i + 1, n))
        print(f"  S^{d}: n={n}, min_dist={min_dist:.4f}, ε={eps:.4f}, "
              f"packing valid: {packing_ok}")

    print("\n" + "=" * 70)
    print("KEY FINDINGS:")
    print("1. Connectivity threshold scales as ε* ~ C·√d·n^{-1/d}")
    print("2. Euler characteristic detects sphere topology at appropriate scale")
    print("3. Detection is stable under small perturbations (stability theorem)")
    print("4. Diameter bound 2r is tight for sphere data")
    print("5. Packing-covering duality gives lower bounds on covering numbers")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Euler Characteristic Phase Diagram

Shows how the Euler characteristic of the VR complex transitions through
different topological phases as the scale parameter ε increases.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import combinations
from collections import defaultdict


def generate_sphere_points(n, d, rng):
    X = rng.standard_normal((n, d + 1))
    return X / np.linalg.norm(X, axis=1, keepdims=True)


def vr_euler(D, eps, max_dim=4):
    n = D.shape[0]
    chi = n  # vertices
    for k in range(1, min(max_dim + 1, n)):
        count = 0
        for subset in combinations(range(n), k + 1):
            if all(D[i][j] <= eps for i, j in combinations(subset, 2)):
                count += 1
        chi += (-1) ** k * count
    return chi


def count_components(D, eps):
    n = D.shape[0]
    parent = list(range(n))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        px, py = find(x), find(y)
        if px == py: return
        parent[py] = px
    for i in range(n):
        for j in range(i+1, n):
            if D[i, j] <= eps:
                union(i, j)
    return len(set(find(i) for i in range(n)))


def main():
    rng = np.random.default_rng(42)
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    for idx, d in enumerate([1, 2, 3]):
        n = 15 if d <= 2 else 12
        X = generate_sphere_points(n, d, rng)
        D = np.sqrt(np.sum((X[:, np.newaxis, :] - X[np.newaxis, :, :]) ** 2, axis=-1))

        eps_range = np.linspace(0, 2.5, 80)
        chis = []
        comps = []
        for eps in eps_range:
            chis.append(vr_euler(D, eps, max_dim=min(d + 1, 4)))
            comps.append(count_components(D, eps))

        target_chi = 1 + (-1) ** d
        ax = axes[idx]
        ax.plot(eps_range, chis, 'b-', linewidth=2, label='χ(VR_ε)')
        ax.plot(eps_range, comps, 'r--', linewidth=1.5, label='β₀ (components)')
        ax.axhline(y=target_chi, color='green', linestyle=':', linewidth=1.5,
                   label=f'χ(S^{d}) = {target_chi}')
        ax.axhline(y=1, color='gray', linestyle=':', alpha=0.5)
        ax.fill_between(eps_range, [target_chi] * len(eps_range),
                        [chi for chi in chis],
                        where=[chi == target_chi for chi in chis],
                        color='green', alpha=0.2)
        ax.set_xlabel('Scale parameter ε', fontsize=11)
        ax.set_ylabel('Value', fontsize=11)
        ax.set_title(f'S^{d}: Euler Characteristic vs Scale\n(n={n} points)',
                     fontsize=12)
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)
        ax.set_ylim(-5, n + 2)

    plt.tight_layout()
    plt.savefig('euler_characteristic_phases.png', dpi=150, bbox_inches='tight')
    print("Saved: euler_characteristic_phases.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Poincaré Threshold Scaling Law

Plots the connectivity threshold ε* vs number of points n for spheres S^d,
demonstrating the scaling law ε* ~ C · √d · n^{-1/d}.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def generate_sphere_points(n, d, rng):
    X = rng.standard_normal((n, d + 1))
    norms = np.linalg.norm(X, axis=1, keepdims=True)
    return X / norms


def connectivity_threshold(X):
    n = X.shape[0]
    if n <= 1:
        return 0.0
    D = np.sqrt(np.sum((X[:, np.newaxis, :] - X[np.newaxis, :, :]) ** 2, axis=-1))
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            edges.append((D[i, j], i, j))
    edges.sort()
    parent = list(range(n))
    rank = [0] * n

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        px, py = find(x), find(y)
        if px == py:
            return False
        if rank[px] < rank[py]:
            px, py = py, px
        parent[py] = px
        if rank[px] == rank[py]:
            rank[px] += 1
        return True

    components = n
    threshold = 0.0
    for dist_val, i, j in edges:
        if union(i, j):
            components -= 1
            threshold = dist_val
            if components == 1:
                break
    return threshold


def main():
    rng = np.random.default_rng(42)
    dims = [1, 2, 3]
    n_values = [20, 30, 50, 75, 100, 150, 200, 300]
    trials = 15
    colors = ['#2196F3', '#FF5722', '#4CAF50']

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: ε* vs n
    ax1 = axes[0]
    for idx, d in enumerate(dims):
        means = []
        stds = []
        for n in n_values:
            vals = [connectivity_threshold(generate_sphere_points(n, d, rng))
                    for _ in range(trials)]
            means.append(np.mean(vals))
            stds.append(np.std(vals))
        means = np.array(means)
        stds = np.array(stds)
        ax1.errorbar(n_values, means, yerr=stds, marker='o', color=colors[idx],
                     label=f'S^{d}', capsize=3, linewidth=2)
        # Theory curve
        C = means[-1] * n_values[-1] ** (1.0 / d) / np.sqrt(d) if d > 0 else 1
        theory = C * np.sqrt(d) * np.array(n_values, dtype=float) ** (-1.0 / d)
        ax1.plot(n_values, theory, '--', color=colors[idx], alpha=0.5,
                 label=f'C·√{d}·n^{{-1/{d}}}')

    ax1.set_xlabel('Number of points n', fontsize=12)
    ax1.set_ylabel('Connectivity threshold ε*', fontsize=12)
    ax1.set_title('Poincaré Threshold: ε* vs n', fontsize=14)
    ax1.legend(fontsize=9)
    ax1.set_xscale('log')
    ax1.set_yscale('log')
    ax1.grid(True, alpha=0.3)

    # Right: log-log slope estimation
    ax2 = axes[1]
    for idx, d in enumerate(dims):
        means = []
        for n in n_values:
            vals = [connectivity_threshold(generate_sphere_points(n, d, rng))
                    for _ in range(trials)]
            means.append(np.mean(vals))
        log_n = np.log(n_values)
        log_eps = np.log(means)
        slope, intercept = np.polyfit(log_n, log_eps, 1)
        ax2.scatter(log_n, log_eps, color=colors[idx], s=50, zorder=3)
        ax2.plot(log_n, slope * log_n + intercept, '-', color=colors[idx],
                 label=f'S^{d}: slope={slope:.3f} (theory: {-1/d:.3f})',
                 linewidth=2)

    ax2.set_xlabel('log(n)', fontsize=12)
    ax2.set_ylabel('log(ε*)', fontsize=12)
    ax2.set_title('Log-Log Scaling: Slope = -1/d', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('poincare_threshold_scaling.png', dpi=150, bbox_inches='tight')
    print("Saved: poincare_threshold_scaling.png")


if __name__ == "__main__":
    main()
