"""
Poincaré Threshold Demo

Demonstrates the key concepts:
1. Rips complex construction at different scales
2. Betti number evolution
3. Poincaré threshold detection for circle and sphere data
4. Stability under noise perturbation
"""

import numpy as np
from algorithms import (
    distance_matrix, rips_simplices, betti_numbers,
    poincare_threshold, connectivity_threshold,
    sphere_signature, covering_radius, packing_number
)


def sample_circle(n: int, noise: float = 0.0, rng: np.random.Generator = None) -> np.ndarray:
    """Sample n points from the unit circle with optional Gaussian noise."""
    if rng is None:
        rng = np.random.default_rng(42)
    theta = np.linspace(0, 2 * np.pi, n, endpoint=False)
    points = np.column_stack([np.cos(theta), np.sin(theta)])
    if noise > 0:
        points += rng.normal(0, noise, points.shape)
    return points


def sample_sphere(n: int, noise: float = 0.0, rng: np.random.Generator = None) -> np.ndarray:
    """Sample n points from the unit 2-sphere using Fibonacci lattice."""
    if rng is None:
        rng = np.random.default_rng(42)
    golden_ratio = (1 + np.sqrt(5)) / 2
    i = np.arange(n)
    theta = np.arccos(1 - 2 * (i + 0.5) / n)
    phi = 2 * np.pi * i / golden_ratio
    points = np.column_stack([
        np.sin(theta) * np.cos(phi),
        np.sin(theta) * np.sin(phi),
        np.cos(theta)
    ])
    if noise > 0:
        points += rng.normal(0, noise, points.shape)
    return points


def demo_rips_evolution():
    """Show how the Rips complex evolves with scale."""
    print("=" * 60)
    print("DEMO 1: Rips Complex Evolution on a Circle")
    print("=" * 60)

    points = sample_circle(12)
    D = distance_matrix(points)

    scales = [0.0, 0.3, 0.5, 0.8, 1.0, 1.5, 2.0]
    print(f"\n{'Scale':>8} | {'Vertices':>8} | {'Edges':>8} | {'Triangles':>9} | {'β₀':>4} | {'β₁':>4}")
    print("-" * 60)

    for eps in scales:
        simps = rips_simplices(D, eps, max_dim=2)
        betti = betti_numbers(simps, max_dim=2)
        n_v = len(simps.get(0, []))
        n_e = len(simps.get(1, []))
        n_t = len(simps.get(2, []))
        print(f"{eps:8.2f} | {n_v:8d} | {n_e:8d} | {n_t:9d} | {betti[0]:4d} | {betti[1]:4d}")

    print("\nAt small scales, β₀ = n (isolated points).")
    print("As scale increases, β₀ → 1 (connected) and β₁ → 1 (loop detected).")
    print("At large scales, β₁ → 0 (loop filled in by triangles).")


def demo_poincare_threshold():
    """Compute the Poincaré threshold for circle data."""
    print("\n" + "=" * 60)
    print("DEMO 2: Poincaré Threshold for the Circle (S¹)")
    print("=" * 60)

    for n in [8, 16, 32, 64]:
        points = sample_circle(n)
        target = sphere_signature(1)  # [1, 1]
        threshold = poincare_threshold(points, target, num_scales=200)
        conn = connectivity_threshold(points)

        print(f"\nn = {n:3d} points on S¹:")
        print(f"  Connectivity threshold:  {conn:.4f}")
        if threshold is not None:
            print(f"  Poincaré threshold (S¹): {threshold:.4f}")
            print(f"  Ratio (Poincaré/Conn):   {threshold / conn:.4f}")
        else:
            print(f"  Poincaré threshold:      not found in range")


def demo_stability():
    """Demonstrate stability of the Poincaré threshold under noise."""
    print("\n" + "=" * 60)
    print("DEMO 3: Stability Under Noise Perturbation")
    print("=" * 60)

    n = 24
    target = sphere_signature(1)
    rng = np.random.default_rng(42)

    print(f"\nPoincaré threshold for {n} points on S¹ with increasing noise:")
    print(f"{'Noise σ':>10} | {'Threshold':>10} | {'Δ from clean':>12}")
    print("-" * 40)

    clean = sample_circle(n)
    t_clean = poincare_threshold(clean, target, num_scales=200)

    for noise_level in [0.0, 0.01, 0.02, 0.05, 0.1, 0.15]:
        points = sample_circle(n, noise=noise_level, rng=rng)
        t = poincare_threshold(points, target, num_scales=200)
        if t is not None and t_clean is not None:
            delta = abs(t - t_clean)
            print(f"{noise_level:10.3f} | {t:10.4f} | {delta:12.4f}")
        elif t is not None:
            print(f"{noise_level:10.3f} | {t:10.4f} | {'N/A':>12}")
        else:
            print(f"{noise_level:10.3f} | {'N/A':>10} | {'N/A':>12}")


def demo_covering_packing():
    """Show covering and packing number relationships."""
    print("\n" + "=" * 60)
    print("DEMO 4: Covering and Packing Numbers")
    print("=" * 60)

    n = 30
    points = sample_circle(n)

    print(f"\nFor {n} points on S¹:")
    print(f"{'ε':>8} | {'Packing #':>10} | {'Covering radius':>16}")
    print("-" * 40)

    for eps in [0.2, 0.4, 0.6, 0.8, 1.0, 1.5]:
        pack = packing_number(points, eps)
        cov = covering_radius(points, points)
        print(f"{eps:8.2f} | {pack:10d} | {cov:16.4f}")


def demo_sphere_signatures():
    """Show the Betti signatures of spheres of different dimensions."""
    print("\n" + "=" * 60)
    print("DEMO 5: Sphere Betti Signatures")
    print("=" * 60)

    print(f"\n{'Sphere':>8} | {'Betti signature':>30} | {'Length':>6}")
    print("-" * 50)
    for d in range(6):
        sig = sphere_signature(d)
        print(f"{'S^' + str(d):>8} | {str(sig):>30} | {len(sig):6d}")

    print("\nNote: The signature uniquely determines the dimension!")
    print("This is because the position of the top Betti number (βₙ = 1)")
    print("determines n, and the list length is n + 1.")


if __name__ == "__main__":
    demo_rips_evolution()
    demo_poincare_threshold()
    demo_stability()
    demo_covering_packing()
    demo_sphere_signatures()
    print("\n" + "=" * 60)
    print("All demos complete.")
    print("=" * 60)


"""
Visualization: Rips Complex Evolution

Shows how Betti numbers change as the scale parameter increases
for points sampled from a circle.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def distance_matrix(points):
    diff = points[:, np.newaxis, :] - points[np.newaxis, :, :]
    return np.sqrt(np.sum(diff ** 2, axis=-1))


def rips_simplices(dist_mat, epsilon, max_dim=2):
    n = dist_mat.shape[0]
    simplices = {0: [(i,) for i in range(n)]}
    edges = [(i, j) for i in range(n) for j in range(i+1, n) if dist_mat[i, j] <= epsilon]
    if max_dim >= 1:
        simplices[1] = edges
    adj = {frozenset(e) for e in edges}
    for dim in range(2, max_dim + 1):
        if dim - 1 not in simplices:
            break
        new_simplices = []
        for simplex in simplices[dim - 1]:
            for v in range(max(simplex) + 1, n):
                if all(frozenset({u, v}) in adj for u in simplex):
                    new_simp = tuple(sorted(simplex + (v,)))
                    if all(dist_mat[new_simp[a], new_simp[b]] <= epsilon
                           for a in range(len(new_simp)) for b in range(a+1, len(new_simp))):
                        new_simplices.append(new_simp)
        if new_simplices:
            simplices[dim] = new_simplices
    return simplices


def rank_mod2(matrix):
    if matrix.size == 0:
        return 0
    M = matrix.copy() % 2
    rows, cols = M.shape
    rank = 0
    for col in range(cols):
        pivot = -1
        for row in range(rank, rows):
            if M[row, col] == 1:
                pivot = row
                break
        if pivot == -1:
            continue
        M[[rank, pivot]] = M[[pivot, rank]]
        for row in range(rows):
            if row != rank and M[row, col] == 1:
                M[row] = (M[row] + M[rank]) % 2
        rank += 1
    return rank


def boundary_matrix_mod2(simplices_k, simplices_k_minus_1):
    face_to_idx = {s: i for i, s in enumerate(simplices_k_minus_1)}
    m = len(simplices_k_minus_1)
    n_cols = len(simplices_k)
    B = np.zeros((m, n_cols), dtype=int)
    for j, sigma in enumerate(simplices_k):
        for omit in range(len(sigma)):
            face = sigma[:omit] + sigma[omit+1:]
            if face in face_to_idx:
                B[face_to_idx[face], j] = 1
    return B % 2


def betti_numbers(simplices, max_dim=2):
    betti = []
    for k in range(max_dim + 1):
        n_k = len(simplices.get(k, []))
        if k == 0 or k - 1 not in simplices or k not in simplices:
            rank_dk = 0
        else:
            rank_dk = rank_mod2(boundary_matrix_mod2(simplices[k], simplices[k-1]))
        if k + 1 not in simplices or k not in simplices:
            rank_dk1 = 0
        else:
            rank_dk1 = rank_mod2(boundary_matrix_mod2(simplices[k+1], simplices[k]))
        betti.append(max(0, n_k - rank_dk - rank_dk1))
    return betti


def main():
    # Sample points from circle
    n = 16
    theta = np.linspace(0, 2 * np.pi, n, endpoint=False)
    points = np.column_stack([np.cos(theta), np.sin(theta)])
    D = distance_matrix(points)

    # Compute Betti numbers at many scales
    scales = np.linspace(0.01, 2.5, 200)
    beta0_vals = []
    beta1_vals = []

    for eps in scales:
        simps = rips_simplices(D, eps, max_dim=2)
        betti = betti_numbers(simps, max_dim=2)
        beta0_vals.append(betti[0])
        beta1_vals.append(betti[1])

    # Plot
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Betti number evolution
    axes[0].plot(scales, beta0_vals, 'b-', linewidth=2, label='β₀ (components)')
    axes[0].plot(scales, beta1_vals, 'r-', linewidth=2, label='β₁ (loops)')
    axes[0].set_xlabel('Scale ε', fontsize=12)
    axes[0].set_ylabel('Betti number', fontsize=12)
    axes[0].set_title('Betti Number Evolution\n(16 points on S¹)', fontsize=14)
    axes[0].legend(fontsize=11)
    axes[0].grid(True, alpha=0.3)

    # Mark the Poincaré threshold region (where β₀=1, β₁=1)
    poincare_region = [(s, b0, b1) for s, b0, b1 in zip(scales, beta0_vals, beta1_vals)
                       if b0 == 1 and b1 == 1]
    if poincare_region:
        s_min = poincare_region[0][0]
        s_max = poincare_region[-1][0]
        axes[0].axvspan(s_min, s_max, alpha=0.15, color='green', label=f'S¹ signature [{s_min:.2f}, {s_max:.2f}]')
        axes[0].legend(fontsize=10)

    # Right: Point cloud with Rips edges at the Poincaré threshold
    if poincare_region:
        eps_show = poincare_region[0][0]
    else:
        eps_show = 0.5
    edges = [(i, j) for i in range(n) for j in range(i+1, n) if D[i,j] <= eps_show]

    for i, j in edges:
        axes[1].plot([points[i, 0], points[j, 0]], [points[i, 1], points[j, 1]],
                     'b-', alpha=0.3, linewidth=0.5)
    axes[1].scatter(points[:, 0], points[:, 1], c='red', s=50, zorder=5)
    axes[1].set_title(f'Rips Graph at ε = {eps_show:.2f}\n(Poincaré threshold for S¹)', fontsize=14)
    axes[1].set_aspect('equal')
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('rips_evolution.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved rips_evolution.png")


if __name__ == "__main__":
    main()


"""
Visualization: Stability of the Poincaré Threshold

Shows how the Poincaré threshold varies with noise level,
demonstrating the Lipschitz stability property.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def distance_matrix(points):
    diff = points[:, np.newaxis, :] - points[np.newaxis, :, :]
    return np.sqrt(np.sum(diff ** 2, axis=-1))


def rips_simplices(dist_mat, epsilon, max_dim=2):
    n = dist_mat.shape[0]
    simplices = {0: [(i,) for i in range(n)]}
    edges = [(i, j) for i in range(n) for j in range(i+1, n) if dist_mat[i, j] <= epsilon]
    if max_dim >= 1:
        simplices[1] = edges
    adj = {frozenset(e) for e in edges}
    for dim in range(2, max_dim + 1):
        if dim - 1 not in simplices:
            break
        new_simplices = []
        for simplex in simplices[dim - 1]:
            for v in range(max(simplex) + 1, n):
                if all(frozenset({u, v}) in adj for u in simplex):
                    new_simp = tuple(sorted(simplex + (v,)))
                    if all(dist_mat[new_simp[a], new_simp[b]] <= epsilon
                           for a in range(len(new_simp)) for b in range(a+1, len(new_simp))):
                        new_simplices.append(new_simp)
        if new_simplices:
            simplices[dim] = new_simplices
    return simplices


def rank_mod2(matrix):
    if matrix.size == 0:
        return 0
    M = matrix.copy() % 2
    rows, cols = M.shape
    rank = 0
    for col in range(cols):
        pivot = -1
        for row in range(rank, rows):
            if M[row, col] == 1:
                pivot = row
                break
        if pivot == -1:
            continue
        M[[rank, pivot]] = M[[pivot, rank]]
        for row in range(rows):
            if row != rank and M[row, col] == 1:
                M[row] = (M[row] + M[rank]) % 2
        rank += 1
    return rank


def boundary_matrix_mod2(simplices_k, simplices_k_minus_1):
    face_to_idx = {s: i for i, s in enumerate(simplices_k_minus_1)}
    m = len(simplices_k_minus_1)
    n_cols = len(simplices_k)
    B = np.zeros((m, n_cols), dtype=int)
    for j, sigma in enumerate(simplices_k):
        for omit in range(len(sigma)):
            face = sigma[:omit] + sigma[omit+1:]
            if face in face_to_idx:
                B[face_to_idx[face], j] = 1
    return B % 2


def betti_numbers(simplices, max_dim=2):
    betti = []
    for k in range(max_dim + 1):
        n_k = len(simplices.get(k, []))
        if k == 0 or k - 1 not in simplices or k not in simplices:
            rank_dk = 0
        else:
            rank_dk = rank_mod2(boundary_matrix_mod2(simplices[k], simplices[k-1]))
        if k + 1 not in simplices or k not in simplices:
            rank_dk1 = 0
        else:
            rank_dk1 = rank_mod2(boundary_matrix_mod2(simplices[k+1], simplices[k]))
        betti.append(max(0, n_k - rank_dk - rank_dk1))
    return betti


def poincare_threshold_search(points, target, num_scales=300):
    D = distance_matrix(points)
    max_dim = len(target) - 1
    upper_tri = D[np.triu_indices_from(D, k=1)]
    scales = np.sort(np.unique(upper_tri))
    if len(scales) > num_scales:
        scales = np.linspace(scales[0], scales[-1], num_scales)
    for eps in scales:
        simps = rips_simplices(D, eps, max_dim=max_dim)
        betti = betti_numbers(simps, max_dim=max_dim)
        if betti == target:
            return float(eps)
    return None


def main():
    n = 20
    target = [1, 1]  # S¹ signature
    rng = np.random.default_rng(42)

    noise_levels = np.linspace(0, 0.2, 30)
    n_trials = 5

    thresholds_mean = []
    thresholds_std = []

    for noise in noise_levels:
        trials = []
        for trial in range(n_trials):
            theta = np.linspace(0, 2 * np.pi, n, endpoint=False)
            points = np.column_stack([np.cos(theta), np.sin(theta)])
            if noise > 0:
                points += rng.normal(0, noise, points.shape)
            t = poincare_threshold_search(points, target)
            if t is not None:
                trials.append(t)
        if trials:
            thresholds_mean.append(np.mean(trials))
            thresholds_std.append(np.std(trials))
        else:
            thresholds_mean.append(np.nan)
            thresholds_std.append(0)

    thresholds_mean = np.array(thresholds_mean)
    thresholds_std = np.array(thresholds_std)

    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(noise_levels, thresholds_mean, 'b-o', linewidth=2, markersize=4, label='Mean threshold')
    ax.fill_between(noise_levels,
                    thresholds_mean - thresholds_std,
                    thresholds_mean + thresholds_std,
                    alpha=0.2, color='blue', label='±1 std dev')

    # Plot the Lipschitz bound line
    if not np.isnan(thresholds_mean[0]):
        t0 = thresholds_mean[0]
        ax.plot(noise_levels, t0 + 2 * noise_levels, 'r--', linewidth=1.5,
                label='Lipschitz bound (slope 2)')
        ax.plot(noise_levels, t0 - 2 * noise_levels, 'r--', linewidth=1.5)

    ax.set_xlabel('Noise level σ', fontsize=12)
    ax.set_ylabel('Poincaré threshold τ_{S¹}', fontsize=12)
    ax.set_title(f'Stability of the Poincaré Threshold\n({n} points on S¹, {n_trials} trials per noise level)', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('stability.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved stability.png")


if __name__ == "__main__":
    main()


"""
Visualization: Threshold Scaling with Sample Size

Shows how the Poincaré threshold and connectivity threshold
scale with the number of sample points on S¹.
"""

import numpy as np
import matplotlib.pyplot as plt


def distance_matrix(points):
    diff = points[:, np.newaxis, :] - points[np.newaxis, :, :]
    return np.sqrt(np.sum(diff ** 2, axis=-1))


def connectivity_threshold_mst(points):
    D = distance_matrix(points)
    n = D.shape[0]
    edges = sorted((D[i, j], i, j) for i in range(n) for j in range(i+1, n))
    parent = list(range(n))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        px, py = find(x), find(y)
        if px == py: return False
        parent[px] = py
        return True
    max_edge = 0.0
    count = 0
    for w, u, v in edges:
        if union(u, v):
            max_edge = w
            count += 1
            if count == n - 1:
                break
    return max_edge


def main():
    sample_sizes = [8, 10, 12, 16, 20, 24, 32, 40, 48, 64, 80, 100]
    conn_thresholds = []

    for n in sample_sizes:
        theta = np.linspace(0, 2 * np.pi, n, endpoint=False)
        points = np.column_stack([np.cos(theta), np.sin(theta)])
        ct = connectivity_threshold_mst(points)
        conn_thresholds.append(ct)

    # Theoretical scaling: connectivity threshold ~ 2*sin(pi/n) ~ 2*pi/n for circle
    theoretical = [2 * np.sin(np.pi / n) for n in sample_sizes]

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Linear scale
    axes[0].plot(sample_sizes, conn_thresholds, 'bo-', linewidth=2, markersize=6,
                 label='Connectivity threshold')
    axes[0].plot(sample_sizes, theoretical, 'r--', linewidth=1.5,
                 label='Theoretical: 2sin(π/n)')
    axes[0].set_xlabel('Number of points n', fontsize=12)
    axes[0].set_ylabel('Threshold', fontsize=12)
    axes[0].set_title('Connectivity Threshold vs Sample Size\n(uniform points on S¹)', fontsize=14)
    axes[0].legend(fontsize=11)
    axes[0].grid(True, alpha=0.3)

    # Right: Log-log scale
    axes[1].loglog(sample_sizes, conn_thresholds, 'bo-', linewidth=2, markersize=6,
                   label='Connectivity threshold')
    axes[1].loglog(sample_sizes, theoretical, 'r--', linewidth=1.5,
                   label='2sin(π/n) ~ 2π/n')
    # Fit power law
    log_n = np.log(sample_sizes)
    log_ct = np.log(conn_thresholds)
    slope, intercept = np.polyfit(log_n, log_ct, 1)
    axes[1].set_xlabel('Number of points n', fontsize=12)
    axes[1].set_ylabel('Threshold', fontsize=12)
    axes[1].set_title(f'Log-Log Scale (slope = {slope:.3f} ≈ -1/d = -1)',
                      fontsize=14)
    axes[1].legend(fontsize=11)
    axes[1].grid(True, alpha=0.3, which='both')

    plt.tight_layout()
    plt.savefig('threshold_scaling.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved threshold_scaling.png (fitted slope: {slope:.3f})")


if __name__ == "__main__":
    main()
