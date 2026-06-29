#!/usr/bin/env python3
"""
Applications of Tropical Symmetric Margin Theory

Shows real-world applications:
1. Kernel method analysis: margin as separation radius
2. Stability of clustering under noise
3. Signal detection in symmetric noise
4. Random graph edge-weight analysis
"""

import numpy as np
from typing import List, Tuple


def pair_slack(W, i, j):
    return W[i, i] + W[j, j] - 2 * W[i, j]


def trop_sym_margin(W):
    n = W.shape[0]
    if n < 2:
        return 0.0
    return min(pair_slack(W, i, j) for i in range(n) for j in range(i+1, n))


def trop_sym_margin_with_witness(W):
    n = W.shape[0]
    best, bi, bj = float('inf'), 0, 1
    for i in range(n):
        for j in range(i+1, n):
            s = pair_slack(W, i, j)
            if s < best:
                best, bi, bj = s, i, j
    return best, bi, bj


# ═══════════════════════════════════════════════════════════════════
# Application 1: Kernel Method — Margin as Separation Radius
# ═══════════════════════════════════════════════════════════════════

def kernel_separation_analysis(points: np.ndarray) -> dict:
    """Analyze point separation using the tropical symmetric margin.

    For a Gram matrix G = X·Xᵀ, tropSymMargin(G) = min ||xᵢ - xⱼ||².
    This gives the squared separation radius of the point cloud.

    Application: In kernel methods, this determines the margin of the
    closest pair — critical for classification and clustering.

    Args:
        points: (n, d) array of n points in d dimensions

    Returns:
        Analysis dictionary
    """
    G = points @ points.T
    margin, i, j = trop_sym_margin_with_witness(G)
    sq_dists = []
    for a in range(len(points)):
        for b in range(a+1, len(points)):
            sq_dists.append((a, b, np.sum((points[a] - points[b])**2)))
    sq_dists.sort(key=lambda x: x[2])

    return {
        'gram_matrix': G,
        'margin': margin,
        'closest_pair': (i, j),
        'separation_radius': np.sqrt(max(margin, 0)),
        'all_pairwise_sq_distances': sq_dists,
        'margin_equals_min_sq_dist': abs(margin - sq_dists[0][2]) < 1e-10,
    }


# ═══════════════════════════════════════════════════════════════════
# Application 2: Clustering Stability Under Noise
# ═══════════════════════════════════════════════════════════════════

def clustering_stability(
    cluster_centers: np.ndarray,
    noise_level: float,
    num_trials: int = 1000,
    seed: int = 42
) -> dict:
    """Test how the tropical margin predicts clustering stability.

    The Lipschitz bound implies: if tropSymMargin(G_signal) > 4·noise_norm,
    then the closest-pair structure is preserved under noise.

    Args:
        cluster_centers: (k, d) array of cluster center positions
        noise_level: Standard deviation of Gaussian noise
        num_trials: Number of trials
        seed: Random seed

    Returns:
        Stability analysis
    """
    rng = np.random.default_rng(seed)
    k, d = cluster_centers.shape
    G_clean = cluster_centers @ cluster_centers.T
    clean_margin, ci, cj = trop_sym_margin_with_witness(G_clean)

    preserved = 0
    for _ in range(num_trials):
        noise = noise_level * rng.standard_normal(cluster_centers.shape)
        noisy_points = cluster_centers + noise
        G_noisy = noisy_points @ noisy_points.T
        _, ni, nj = trop_sym_margin_with_witness(G_noisy)
        if {ni, nj} == {ci, cj}:
            preserved += 1

    return {
        'clean_margin': clean_margin,
        'noise_level': noise_level,
        'theoretical_bound': 4 * noise_level * np.sqrt(d),
        'margin_exceeds_bound': clean_margin > 4 * noise_level * np.sqrt(d),
        'closest_pair_preserved_rate': preserved / num_trials,
        'clean_closest_pair': (ci, cj),
    }


# ═══════════════════════════════════════════════════════════════════
# Application 3: Signal Detection in Symmetric Noise
# ═══════════════════════════════════════════════════════════════════

def signal_detection(
    n: int,
    signal_strength: float,
    noise_level: float = 1.0,
    num_trials: int = 2000,
    seed: int = 42
) -> dict:
    """Test signal detection using the tropical margin threshold.

    Signal matrix: diagonal with entries [signal_strength, ..., signal_strength].
    Noise: symmetric Wigner matrix scaled by noise_level.
    The universality surrogate theorem predicts: if signal_strength > 5*C*sqrt(log n),
    the margin stays nonneg.

    Args:
        n: Matrix dimension
        signal_strength: Diagonal signal value
        noise_level: Noise scale
        num_trials: Number of trials
        seed: Random seed

    Returns:
        Detection analysis
    """
    rng = np.random.default_rng(seed)
    threshold = 5 * noise_level * np.sqrt(np.log(n))

    nonneg_count = 0
    margins = []
    for _ in range(num_trials):
        S = signal_strength * np.eye(n)
        A = rng.standard_normal((n, n))
        N = noise_level * (A + A.T) / np.sqrt(2)
        W = S + N
        m = trop_sym_margin(W)
        margins.append(m)
        if m >= 0:
            nonneg_count += 1

    return {
        'n': n,
        'signal_strength': signal_strength,
        'noise_level': noise_level,
        'threshold_5C_sqrt_log_n': threshold,
        'signal_exceeds_threshold': signal_strength > threshold,
        'fraction_nonneg_margin': nonneg_count / num_trials,
        'mean_margin': np.mean(margins),
        'std_margin': np.std(margins),
    }


# ═══════════════════════════════════════════════════════════════════
# Application 4: Random Graph Edge-Weight Analysis
# ═══════════════════════════════════════════════════════════════════

def graph_edge_analysis(W: np.ndarray) -> dict:
    """Interpret the tropical symmetric margin as graph edge weights.

    Construct the weighted complete graph with edge weights
    c_{ij} = W[i,i] + W[j,j] - 2*W[i,j].

    tropSymMargin(W) = min edge weight.
    margin >= 0 iff all edge weights nonneg.

    This connects tropical diagonal dominance to graph cut problems.

    Args:
        W: Symmetric matrix

    Returns:
        Graph analysis
    """
    n = W.shape[0]
    edges = []
    for i in range(n):
        for j in range(i+1, n):
            w = pair_slack(W, i, j)
            edges.append({'edge': (i, j), 'weight': w})
    edges.sort(key=lambda e: e['weight'])

    margin = trop_sym_margin(W)
    all_nonneg = all(e['weight'] >= -1e-12 for e in edges)

    return {
        'num_vertices': n,
        'num_edges': len(edges),
        'margin': margin,
        'all_edges_nonneg': all_nonneg,
        'margin_nonneg_iff_holds': (margin >= -1e-12) == all_nonneg,
        'min_weight_edge': edges[0],
        'max_weight_edge': edges[-1],
        'sorted_edges': edges,
    }


def main():
    sep = "=" * 60

    # Application 1: Kernel separation
    print(sep)
    print("APPLICATION 1: Kernel Method — Separation Radius")
    print(sep)
    points = np.array([
        [1.0, 0.0, 0.0],
        [0.0, 1.0, 0.0],
        [0.0, 0.0, 1.0],
        [0.5, 0.5, 0.0],
    ])
    result = kernel_separation_analysis(points)
    print(f"Points: {points.tolist()}")
    print(f"Tropical symmetric margin = {result['margin']:.4f}")
    print(f"Closest pair: {result['closest_pair']}")
    print(f"Separation radius: {result['separation_radius']:.4f}")
    print(f"Margin = min squared distance: {result['margin_equals_min_sq_dist']}")

    # Application 2: Clustering stability
    print(f"\n{sep}")
    print("APPLICATION 2: Clustering Stability Under Noise")
    print(sep)
    centers = np.array([[0, 0], [3, 0], [0, 4]], dtype=float)
    for noise in [0.1, 0.3, 0.5, 1.0, 2.0]:
        result = clustering_stability(centers, noise, num_trials=500)
        print(f"  noise={noise:.1f}  "
              f"margin={result['clean_margin']:.2f}  "
              f"bound={result['theoretical_bound']:.2f}  "
              f"exceeds={'Y' if result['margin_exceeds_bound'] else 'N'}  "
              f"preserved={result['closest_pair_preserved_rate']:.2%}")

    # Application 3: Signal detection
    print(f"\n{sep}")
    print("APPLICATION 3: Signal Detection in Symmetric Noise")
    print(sep)
    for n in [8, 16, 32]:
        threshold = 5 * np.sqrt(np.log(n))
        for strength in [threshold * 0.5, threshold, threshold * 1.5]:
            result = signal_detection(n, strength, num_trials=500)
            print(f"  n={n:3d} signal={strength:6.2f} "
                  f"thresh={threshold:5.2f} "
                  f"exceeds={'Y' if result['signal_exceeds_threshold'] else 'N'} "
                  f"P(margin≥0)={result['fraction_nonneg_margin']:.2%}")

    # Application 4: Graph analysis
    print(f"\n{sep}")
    print("APPLICATION 4: Random Graph Edge Weights")
    print(sep)
    rng = np.random.default_rng(42)
    W = np.diag([5.0, 3.0, 4.0, 6.0])
    off = rng.uniform(-1, 1, (4, 4))
    off = (off + off.T) / 2
    np.fill_diagonal(off, 0)
    W = W + off
    result = graph_edge_analysis(W)
    print(f"Weighted graph on {result['num_vertices']} vertices:")
    print(f"  Margin = {result['margin']:.4f}")
    print(f"  All edges nonneg: {result['all_edges_nonneg']}")
    print(f"  Min edge: {result['min_weight_edge']}")
    print(f"  Max edge: {result['max_weight_edge']}")
    print(f"  Characterization holds: {result['margin_nonneg_iff_holds']}")


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Demo: Tropical Symmetric Margin for Wigner-Type Matrices

Demonstrates the core theorems with concrete numerical examples:
1. Pair slack computation and the 3-coordinate structure
2. Lipschitz stability under perturbations
3. Telescoping replacement bounds
4. Nonnegativity characterization (graph-theoretic)
5. Gram matrix / metric geometry bridge
6. Universality conjecture test via empirical survival curves
"""

import numpy as np
from typing import Tuple, Optional


def pair_slack(W: np.ndarray, i: int, j: int) -> float:
    """Pair slack: W[i,i] + W[j,j] - 2*W[i,j]."""
    return W[i, i] + W[j, j] - 2 * W[i, j]


def trop_sym_margin(W: np.ndarray) -> float:
    """Tropical symmetric margin: min_{i<j} pair_slack(W, i, j)."""
    n = W.shape[0]
    if n < 2:
        return 0.0
    return min(pair_slack(W, i, j) for i in range(n) for j in range(i+1, n))


def trop_sym_margin_with_witness(W: np.ndarray):
    """Return (margin, i_min, j_min)."""
    n = W.shape[0]
    best, bi, bj = float('inf'), 0, 1
    for i in range(n):
        for j in range(i+1, n):
            s = pair_slack(W, i, j)
            if s < best:
                best, bi, bj = s, i, j
    return best, bi, bj


def pair_replacement_dist(W, W2):
    """Entrywise sup-norm."""
    return np.max(np.abs(W - W2))


def gen_sym_gaussian(n, rng):
    A = rng.standard_normal((n, n))
    return (A + A.T) / np.sqrt(2)


def gen_sym_rademacher(n, rng):
    A = (2 * rng.integers(0, 2, size=(n, n)) - 1).astype(float)
    return np.triu(A) + np.triu(A, 1).T


def gen_sym_uniform(n, rng):
    s = np.sqrt(3.0)
    A = rng.uniform(-s, s, size=(n, n))
    return (A + A.T) / np.sqrt(2)


def main():
    rng = np.random.default_rng(42)
    sep = "=" * 60

    # ─── Demo 1: Basic pair slack and 3-coordinate structure ───
    print(sep)
    print("DEMO 1: Pair Slack and 3-Coordinate Structure")
    print(sep)
    W = np.array([[4.0, 1.0, 0.5],
                   [1.0, 3.0, 2.0],
                   [0.5, 2.0, 5.0]])
    print(f"Symmetric matrix W =\n{W}\n")
    for i in range(3):
        for j in range(i+1, 3):
            s = pair_slack(W, i, j)
            print(f"  pair_slack({i},{j}) = W[{i},{i}] + W[{j},{j}] - 2*W[{i},{j}]"
                  f" = {W[i,i]} + {W[j,j]} - 2*{W[i,j]} = {s}")
    m, mi, mj = trop_sym_margin_with_witness(W)
    print(f"\ntropSymMargin(W) = {m} (minimized at pair ({mi},{mj}))")
    print(f"Key insight: Each pair slack depends on exactly 3 coordinates.")

    # ─── Demo 2: Lipschitz stability ───
    print(f"\n{sep}")
    print("DEMO 2: Lipschitz Stability (Theorem 1)")
    print(sep)
    n = 6
    W1 = gen_sym_gaussian(n, rng)
    eps_values = [0.01, 0.05, 0.1, 0.5, 1.0]
    print(f"{'ε':>8} {'|Δ margin|':>12} {'4·d_pair':>12} {'ratio':>8} {'ok?':>5}")
    for eps in eps_values:
        E = eps * gen_sym_gaussian(n, rng)
        W2 = W1 + E
        m1, m2 = trop_sym_margin(W1), trop_sym_margin(W2)
        d = pair_replacement_dist(W1, W2)
        diff = abs(m1 - m2)
        bound = 4 * d
        ratio = diff / bound if bound > 0 else 0
        ok = "✓" if diff <= bound + 1e-12 else "✗"
        print(f"{eps:8.3f} {diff:12.6f} {bound:12.6f} {ratio:8.4f} {ok:>5}")

    # ─── Demo 3: Telescoping bound ───
    print(f"\n{sep}")
    print("DEMO 3: Telescoping Replacement Bound (Theorem 2)")
    print(sep)
    chain_len = 8
    chain = [gen_sym_gaussian(5, rng)]
    for _ in range(chain_len - 1):
        E = 0.2 * gen_sym_gaussian(5, rng)
        chain.append(chain[-1] + E)
    margins = [trop_sym_margin(M) for M in chain]
    total = abs(margins[0] - margins[-1])
    steps = [abs(margins[k] - margins[k+1]) for k in range(len(chain)-1)]
    tel_sum = sum(steps)
    lip_sum = sum(4 * pair_replacement_dist(chain[k], chain[k+1])
                  for k in range(len(chain)-1))
    print(f"Chain of {chain_len} matrices (n=5)")
    print(f"  |margin(W₀) - margin(W₇)| = {total:.6f}")
    print(f"  Σ |margin(Wₖ) - margin(Wₖ₊₁)| = {tel_sum:.6f}")
    print(f"  Σ 4·d_pair(Wₖ, Wₖ₊₁)        = {lip_sum:.6f}")
    print(f"  Telescoping holds: {total <= tel_sum + 1e-12}")
    print(f"  Lipschitz holds:   {total <= lip_sum + 1e-12}")

    # ─── Demo 4: Nonnegativity ↔ all pairs nonneg ───
    print(f"\n{sep}")
    print("DEMO 4: Nonnegativity Characterization (Theorem 3)")
    print(sep)
    # Diagonally dominant matrix → positive margin
    D = np.diag([10.0, 8.0, 12.0, 9.0])
    Off = rng.uniform(-1, 1, (4, 4))
    Off = (Off + Off.T) / 2
    np.fill_diagonal(Off, 0)
    W_pos = D + Off
    m_pos = trop_sym_margin(W_pos)
    all_nonneg = all(pair_slack(W_pos, i, j) >= -1e-12
                     for i in range(4) for j in range(i+1, 4))
    print(f"Diagonally dominant matrix: margin = {m_pos:.4f}")
    print(f"  All pair slacks nonneg: {all_nonneg}")
    print(f"  margin ≥ 0: {m_pos >= -1e-12}")
    print(f"  Characterization holds: {(m_pos >= -1e-12) == all_nonneg}")

    # Matrix with negative margin
    W_neg = np.array([[1.0, 5.0], [5.0, 1.0]])
    m_neg = trop_sym_margin(W_neg)
    has_bad_pair = any(pair_slack(W_neg, i, j) < 0
                       for i in range(2) for j in range(i+1, 2))
    print(f"\nMatrix with large off-diagonal: margin = {m_neg:.4f}")
    print(f"  Has negative pair slack: {has_bad_pair}")
    print(f"  Characterization holds: {(m_neg < 0) == has_bad_pair}")

    # ─── Demo 5: Gram matrix bridge ───
    print(f"\n{sep}")
    print("DEMO 5: Gram Matrix / Metric Geometry Bridge")
    print(sep)
    points = np.array([[1.0, 0.0], [3.0, 0.0], [0.0, 4.0], [2.0, 2.0]])
    G = points @ points.T  # Gram matrix
    print(f"Points in R²: {points.tolist()}")
    print(f"Gram matrix G = X·Xᵀ:\n{G}\n")
    print(f"{'pair':>8} {'pair_slack':>12} {'||xᵢ-xⱼ||²':>12} {'match?':>8}")
    for i in range(4):
        for j in range(i+1, 4):
            ps = pair_slack(G, i, j)
            sq_dist = np.sum((points[i] - points[j])**2)
            match = abs(ps - sq_dist) < 1e-10
            print(f"  ({i},{j})  {ps:12.4f} {sq_dist:12.4f} {'✓' if match else '✗':>8}")
    margin_G = trop_sym_margin(G)
    min_sq_dist = min(np.sum((points[i] - points[j])**2)
                      for i in range(4) for j in range(i+1, 4))
    print(f"\ntropSymMargin(G) = {margin_G:.4f}")
    print(f"min pairwise ||xᵢ-xⱼ||² = {min_sq_dist:.4f}")
    print(f"They match: {abs(margin_G - min_sq_dist) < 1e-10}")
    print(f"\n→ Tropical margin = geometric separation radius for Gram matrices!")

    # ─── Demo 6: Universality conjecture test ───
    print(f"\n{sep}")
    print("DEMO 6: Universality Conjecture — Empirical Test")
    print(sep)
    num_trials = 5000
    for n in [8, 12, 16]:
        print(f"\n  n = {n}, {num_trials} trials:")
        for name, gen in [('Gaussian', gen_sym_gaussian),
                          ('Rademacher', gen_sym_rademacher),
                          ('Uniform', gen_sym_uniform)]:
            margins = [trop_sym_margin(gen(n, rng)) for _ in range(num_trials)]
            margins = np.array(margins)
            b_n = np.sqrt(np.log(n))
            a_n = np.median(margins)
            rescaled = (margins - a_n) / b_n
            p25, p50, p75 = np.percentile(rescaled, [25, 50, 75])
            print(f"    {name:12s}: median(raw)={np.median(margins):7.3f}  "
                  f"b_n={b_n:.3f}  "
                  f"rescaled quartiles=[{p25:.3f}, {p50:.3f}, {p75:.3f}]")

    print(f"\n{sep}")
    print("PREDICTION: If rescaled quartiles collapse across ensembles,")
    print("the universality conjecture is supported.")
    print(sep)


if __name__ == '__main__':
    main()


"""
Visualization: Gram Matrix Bridge — Tropical Margin as Geometric Separation

Demonstrates the cross-domain theorem: for Gram matrices G = X·Xᵀ,
the tropical symmetric margin equals the minimum pairwise squared distance.
This bridges tropical optimization to metric geometry and kernel methods.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle


def pair_slack(W, i, j):
    return W[i, i] + W[j, j] - 2 * W[i, j]


def trop_sym_margin(W):
    n = W.shape[0]
    if n < 2:
        return 0.0
    return min(pair_slack(W, i, j) for i in range(n) for j in range(i+1, n))


def trop_sym_margin_with_witness(W):
    n = W.shape[0]
    best, bi, bj = float('inf'), 0, 1
    for i in range(n):
        for j in range(i+1, n):
            s = pair_slack(W, i, j)
            if s < best:
                best, bi, bj = s, i, j
    return best, bi, bj


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Points with closest pair highlighted
ax = axes[0]
rng = np.random.default_rng(42)
n_points = 8
points = rng.standard_normal((n_points, 2)) * 2
G = points @ points.T
margin, ci, cj = trop_sym_margin_with_witness(G)

# Draw all edges faintly
for i in range(n_points):
    for j in range(i+1, n_points):
        d = np.sqrt(np.sum((points[i] - points[j])**2))
        ax.plot([points[i, 0], points[j, 0]], [points[i, 1], points[j, 1]],
                'gray', alpha=0.15, linewidth=0.5)

# Highlight closest pair
ax.plot([points[ci, 0], points[cj, 0]], [points[ci, 1], points[cj, 1]],
        'r-', linewidth=2.5, label=f'Closest pair ({ci},{cj})')

# Draw points
ax.scatter(points[:, 0], points[:, 1], s=80, c='#2196F3', zorder=5, edgecolors='white')
for i in range(n_points):
    ax.annotate(str(i), (points[i, 0]+0.1, points[i, 1]+0.1), fontsize=9)

ax.set_title(f'Point Cloud (n={n_points})\nMargin = min ||xᵢ-xⱼ||² = {margin:.2f}',
             fontsize=12, fontweight='bold')
ax.set_xlabel('x₁')
ax.set_ylabel('x₂')
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)
ax.legend(fontsize=9)

# Panel 2: Pair slack vs squared distance scatter
ax = axes[1]
pair_slacks = []
sq_dists = []
for i in range(n_points):
    for j in range(i+1, n_points):
        pair_slacks.append(pair_slack(G, i, j))
        sq_dists.append(np.sum((points[i] - points[j])**2))

ax.scatter(sq_dists, pair_slacks, s=40, c='#4CAF50', alpha=0.7, edgecolors='white')
lim = max(max(sq_dists), max(pair_slacks)) * 1.1
ax.plot([0, lim], [0, lim], 'r--', linewidth=1.5, label='y = x (exact match)')
ax.set_xlabel('||xᵢ - xⱼ||²', fontsize=11)
ax.set_ylabel('pairSlack(G, i, j)', fontsize=11)
ax.set_title('Pair Slack = Squared Distance\nfor Gram Matrices', fontsize=12, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Margin vs dimension for random point clouds
ax = axes[2]
dims = range(2, 20)
n_pts = 10
num_trials = 200

mean_margins = []
std_margins = []
for d in dims:
    ms = []
    for _ in range(num_trials):
        pts = rng.standard_normal((n_pts, d))
        G = pts @ pts.T
        ms.append(trop_sym_margin(G))
    mean_margins.append(np.mean(ms))
    std_margins.append(np.std(ms))

mean_margins = np.array(mean_margins)
std_margins = np.array(std_margins)
dims_arr = np.array(list(dims))

ax.plot(dims_arr, mean_margins, 'o-', color='#2196F3', linewidth=1.5, label='Mean margin')
ax.fill_between(dims_arr, mean_margins - std_margins, mean_margins + std_margins,
                alpha=0.2, color='#2196F3')
ax.set_xlabel('Ambient dimension d', fontsize=11)
ax.set_ylabel('tropSymMargin(G)', fontsize=11)
ax.set_title(f'Margin Growth with Dimension\n(n={n_pts} random points)', fontsize=12, fontweight='bold')
ax.grid(True, alpha=0.3)
ax.legend(fontsize=10)

fig.suptitle('Cross-Domain Bridge: Tropical Margin = Geometric Separation',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_gram_bridge.png', dpi=150, bbox_inches='tight')
print("Saved viz_gram_bridge.png")


"""
Visualization: Lipschitz Stability of Tropical Symmetric Margin

Demonstrates the 4-Lipschitz bound:
|tropSymMargin(W) - tropSymMargin(W')| ≤ 4 · d_pair(W, W')

Shows the bound holding across many random perturbations,
with the tightness ratio illustrating how sharp the constant 4 is.
"""

import numpy as np
import matplotlib.pyplot as plt


def pair_slack(W, i, j):
    return W[i, i] + W[j, j] - 2 * W[i, j]


def trop_sym_margin(W):
    n = W.shape[0]
    if n < 2:
        return 0.0
    return min(pair_slack(W, i, j) for i in range(n) for j in range(i+1, n))


def gen_sym_gaussian(n, rng):
    A = rng.standard_normal((n, n))
    return (A + A.T) / np.sqrt(2)


rng = np.random.default_rng(42)
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Scatter of |Δmargin| vs 4·d_pair
ax = axes[0]
n = 8
W_base = gen_sym_gaussian(n, rng)
diffs, bounds = [], []
for _ in range(500):
    eps = rng.uniform(0.01, 1.0)
    E = eps * gen_sym_gaussian(n, rng)
    W2 = W_base + E
    m1, m2 = trop_sym_margin(W_base), trop_sym_margin(W2)
    d = np.max(np.abs(W_base - W2))
    diffs.append(abs(m1 - m2))
    bounds.append(4 * d)

ax.scatter(bounds, diffs, alpha=0.3, s=10, color='#2196F3')
max_val = max(max(bounds), max(diffs)) * 1.1
ax.plot([0, max_val], [0, max_val], 'r--', linewidth=1.5, label='y = x (tight)')
ax.set_xlabel('4 · d_pair(W, W\')', fontsize=11)
ax.set_ylabel('|tropSymMargin(W) - tropSymMargin(W\')|', fontsize=11)
ax.set_title('Lipschitz Bound (n=8)', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Tightness ratio histogram
ax = axes[1]
ratios = [d/b if b > 0 else 0 for d, b in zip(diffs, bounds)]
ax.hist(ratios, bins=40, color='#4CAF50', alpha=0.7, edgecolor='white')
ax.axvline(x=1.0, color='red', linestyle='--', label='Bound = 1')
ax.set_xlabel('Tightness ratio |Δmargin| / (4·d_pair)', fontsize=11)
ax.set_ylabel('Count', fontsize=11)
ax.set_title('How Tight Is the Bound?', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Margin vs perturbation size
ax = axes[2]
eps_range = np.linspace(0.01, 2.0, 50)
for n_val, color in [(4, '#2196F3'), (8, '#F44336'), (16, '#9C27B0')]:
    W0 = gen_sym_gaussian(n_val, rng)
    m0 = trop_sym_margin(W0)
    margins_mean = []
    for eps in eps_range:
        ms = []
        for _ in range(100):
            E = eps * gen_sym_gaussian(n_val, rng)
            ms.append(trop_sym_margin(W0 + E))
        margins_mean.append(np.mean(ms))
    ax.plot(eps_range, margins_mean, color=color, label=f'n={n_val}', linewidth=1.5)
    ax.axhline(y=m0, color=color, linestyle=':', alpha=0.5)

ax.set_xlabel('Perturbation scale ε', fontsize=11)
ax.set_ylabel('Mean tropSymMargin(W + εE)', fontsize=11)
ax.set_title('Margin Under Growing Perturbation', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

fig.suptitle('Lipschitz Stability of Tropical Symmetric Margin',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_lipschitz.png', dpi=150, bbox_inches='tight')
print("Saved viz_lipschitz.png")


"""
Visualization: Universality of Tropical Symmetric Margin

Shows the rescaled survival curves P(tropSymMargin >= t) for Gaussian,
Rademacher, and Uniform symmetric ensembles at different n values.
The curves collapse under sqrt(log n) scaling, supporting the
universality conjecture.
"""

import numpy as np
import matplotlib.pyplot as plt


def pair_slack(W, i, j):
    return W[i, i] + W[j, j] - 2 * W[i, j]


def trop_sym_margin(W):
    n = W.shape[0]
    if n < 2:
        return 0.0
    return min(pair_slack(W, i, j) for i in range(n) for j in range(i+1, n))


def gen_sym_gaussian(n, rng):
    A = rng.standard_normal((n, n))
    return (A + A.T) / np.sqrt(2)


def gen_sym_rademacher(n, rng):
    A = (2 * rng.integers(0, 2, size=(n, n)) - 1).astype(float)
    return np.triu(A) + np.triu(A, 1).T


def gen_sym_uniform(n, rng):
    s = np.sqrt(3.0)
    A = rng.uniform(-s, s, size=(n, n))
    return (A + A.T) / np.sqrt(2)


rng = np.random.default_rng(42)
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

n_values = [8, 12, 16]
num_trials = 3000
ensembles = {
    'Gaussian': gen_sym_gaussian,
    'Rademacher': gen_sym_rademacher,
    'Uniform': gen_sym_uniform,
}
colors = {'Gaussian': '#2196F3', 'Rademacher': '#F44336', 'Uniform': '#4CAF50'}

for idx, n in enumerate(n_values):
    ax = axes[idx]
    b_n = np.sqrt(np.log(n))

    for name, gen in ensembles.items():
        margins = np.array([trop_sym_margin(gen(n, rng)) for _ in range(num_trials)])
        a_n = np.median(margins)
        rescaled = (margins - a_n) / b_n

        # Compute empirical CDF and survival
        sorted_r = np.sort(rescaled)
        survival = 1.0 - np.arange(1, len(sorted_r)+1) / len(sorted_r)
        ax.plot(sorted_r, survival, color=colors[name], label=name,
                alpha=0.8, linewidth=1.5)

    ax.set_xlabel('Rescaled threshold (t - aₙ) / √(log n)', fontsize=11)
    ax.set_ylabel('P(rescaled margin ≥ t)', fontsize=11)
    ax.set_title(f'n = {n}', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_xlim(-4, 4)
    ax.set_ylim(-0.05, 1.05)
    ax.grid(True, alpha=0.3)

fig.suptitle('Tropical Symmetric Margin: Universality Under √(log n) Scaling',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_universality.png', dpi=150, bbox_inches='tight')
print("Saved viz_universality.png")
