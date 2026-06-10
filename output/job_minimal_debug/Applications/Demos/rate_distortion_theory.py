#!/usr/bin/env python3
"""
applications.py — Real-world applications of packing-covering theory.

Demonstrates:
1. Image compression via vector quantization
2. Learning theory: capacity bounds for nearest-neighbor classifiers
3. Signal quantization: optimal codebook design
4. Geometric approximation: mesh simplification
"""

import numpy as np
from algorithms import (
    FiniteMetricSpace, greedy_maximal_separated_set,
    covering_number, packing_number, box_packing_bound,
    rate_distortion_curve, euclidean_dist, sup_norm_dist
)


def demo_vector_quantization():
    """Vector quantization: compress a 'signal' using codebooks of varying size.

    This demonstrates the rate-distortion tradeoff: smaller codebooks mean
    higher compression (lower rate) but more distortion.
    """
    print("=" * 60)
    print("APPLICATION 1: Vector Quantization (Signal Compression)")
    print("=" * 60)

    np.random.seed(42)
    # Generate a synthetic 2D signal (e.g., image color patches)
    n_points = 100
    # Mixture of 3 clusters
    centers = [(-3, 2), (2, 4), (1, -3)]
    signal = []
    for cx, cy in centers:
        cluster = np.random.normal(loc=[cx, cy], scale=0.8, size=(n_points // 3, 2))
        signal.extend(cluster.tolist())
    signal = np.array(signal)

    space = FiniteMetricSpace(signal)

    print(f"  Signal: {len(signal)} 2D vectors from 3 clusters")
    print(f"  {'Codebook size':>14s}  {'Avg distortion':>16s}  {'Max distortion':>16s}  {'Rate (bits)':>12s}")

    for k in [3, 5, 10, 20, 33]:
        # Use greedy maximal separated set as codebook
        r_search = 0.1
        while True:
            order = np.random.permutation(space.n)
            C = greedy_maximal_separated_set(space, r_search, order)
            if len(C) <= k:
                break
            r_search *= 1.1

        # Compute distortions
        codebook = signal[C]
        distortions = []
        for p in signal:
            min_d = min(np.linalg.norm(p - c) for c in codebook)
            distortions.append(min_d)

        avg_d = np.mean(distortions)
        max_d = np.max(distortions)
        rate = np.log2(len(C)) if len(C) > 1 else 0
        print(f"  {len(C):14d}  {avg_d:16.3f}  {max_d:16.3f}  {rate:12.2f}")


def demo_learning_capacity():
    """Learning theory: covering numbers bound the capacity of a hypothesis class.

    The covering number N(ε) measures how many ε-balls are needed to cover the
    hypothesis class. By the packing-covering sandwich, this is bounded by
    the packing number, which counts the maximum number of 'distinguishable'
    hypotheses at resolution ε.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Learning Theory — Capacity Bounds")
    print("=" * 60)

    np.random.seed(123)
    # Simulate a set of 'hypotheses' as parameter vectors in [-1,1]^d
    for d in [2, 3, 5]:
        n_hypotheses = min(500, 20 ** d)
        hypotheses = np.random.uniform(-1, 1, (n_hypotheses, d))
        space = FiniteMetricSpace(hypotheses, sup_norm_dist)

        print(f"\n  Dimension d={d}, {n_hypotheses} hypotheses in [-1,1]^{d}")
        print(f"  {'ε':>8s}  {'N(ε) (covering)':>16s}  {'M(ε) (packing)':>16s}  "
              f"{'Box bound':>10s}  {'log₂ N(ε)':>10s}")

        for eps in [0.5, 0.3, 0.2]:
            N = covering_number(space, eps, trials=50)
            M = packing_number(space, eps, trials=50)
            bound = box_packing_bound(1.0, eps, d)
            log_N = np.log2(N) if N > 1 else 0
            print(f"  {eps:8.2f}  {N:16d}  {M:16d}  {bound:10d}  {log_N:10.2f}")


def demo_signal_quantization():
    """Demonstrate how the interval packing bound governs quantization.

    For a signal x ∈ [-B, B], the number of quantization levels needed
    to achieve distortion ≤ D is at most floor(2B/D) + 1 = N(D).
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Signal Quantization")
    print("=" * 60)

    B = 5.0
    print(f"  Signal range: [-{B}, {B}]")
    print(f"  {'Distortion D':>14s}  {'Levels needed':>14s}  "
          f"{'Bits needed':>12s}  {'SNR (dB)':>10s}")

    for D in [2.0, 1.0, 0.5, 0.2, 0.1, 0.05]:
        levels = int(np.floor(2 * B / D)) + 1
        bits = np.ceil(np.log2(levels))
        # Approximate SNR for uniform quantization
        signal_power = B ** 2 / 3  # uniform distribution variance
        noise_power = D ** 2 / 12  # quantization noise
        snr_db = 10 * np.log10(signal_power / noise_power) if noise_power > 0 else float('inf')
        print(f"  {D:14.3f}  {levels:14d}  {bits:12.0f}  {snr_db:10.1f}")


def demo_geometric_approximation():
    """Mesh simplification via covering: approximate a point cloud
    by a smaller set with bounded approximation error."""
    print("\n" + "=" * 60)
    print("APPLICATION 4: Geometric Approximation (Point Cloud Simplification)")
    print("=" * 60)

    np.random.seed(456)
    # Generate points on a circle (simulating a 2D contour)
    n = 200
    theta = np.linspace(0, 2 * np.pi, n, endpoint=False)
    # Add noise
    r_noise = 1.0 + 0.05 * np.random.randn(n)
    points = np.column_stack([r_noise * np.cos(theta), r_noise * np.sin(theta)])

    space = FiniteMetricSpace(points)

    print(f"  Original: {n} points on a noisy circle (radius ≈ 1)")
    print(f"  {'Tolerance ε':>14s}  {'Simplified size':>16s}  "
          f"{'Compression ratio':>18s}  {'Max error':>10s}")

    for eps in [0.05, 0.1, 0.2, 0.3, 0.5]:
        C = greedy_maximal_separated_set(space, eps)
        codebook = points[C]
        # Verify covering
        max_err = 0
        for p in points:
            min_d = min(np.linalg.norm(p - c) for c in codebook)
            max_err = max(max_err, min_d)
        ratio = n / len(C)
        print(f"  {eps:14.3f}  {len(C):16d}  {ratio:18.1f}x  {max_err:10.4f}")


if __name__ == "__main__":
    demo_vector_quantization()
    demo_learning_capacity()
    demo_signal_quantization()
    demo_geometric_approximation()
    print("\n✓ All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
demo.py — Demonstrations of packing-covering theory for finite metric spaces.

Concrete numerical examples illustrating:
1. Maximal separated sets and their covering property
2. The packing-covering sandwich inequality
3. Interval packing bounds
"""

import numpy as np
from itertools import combinations

def dist(x, y):
    """Euclidean distance between two points."""
    return np.linalg.norm(np.array(x) - np.array(y))

def is_separated(C, r, metric=dist):
    """Check if a set C is r-separated: all pairwise distances >= r."""
    for (x, y) in combinations(C, 2):
        if metric(x, y) < r:
            return False
    return True

def is_covering(C, points, R, metric=dist):
    """Check if C is an R-covering of points: every point within R of some c in C."""
    for p in points:
        if not any(metric(p, c) <= R for c in C):
            return False
    return True

def greedy_maximal_separated(points, r, metric=dist):
    """Build a maximal r-separated subset greedily."""
    C = []
    for p in points:
        if all(metric(p, c) >= r for c in C):
            C.append(p)
    return C

def packing_number(points, r, metric=dist, trials=1000):
    """Estimate the packing number: max size of r-separated subset."""
    best = 0
    for _ in range(trials):
        perm = list(points)
        np.random.shuffle(perm)
        C = greedy_maximal_separated(perm, r, metric)
        best = max(best, len(C))
    return best

def covering_number(points, R, metric=dist, trials=1000):
    """Estimate the covering number: min size of R-covering subset."""
    best = len(points)
    for _ in range(trials):
        perm = list(points)
        np.random.shuffle(perm)
        C = greedy_maximal_separated(perm, R, metric)
        if is_covering(C, points, R, metric):
            best = min(best, len(C))
    return best

# ============================================================
# Demo 1: 1D interval packing
# ============================================================
print("=" * 60)
print("DEMO 1: Interval Packing Bound")
print("=" * 60)

B = 10.0
for r in [1.0, 2.0, 3.0, 5.0]:
    # Generate points on [-B, B]
    points = [round(x, 2) for x in np.arange(-B, B + 0.01, 0.1)]
    C = greedy_maximal_separated(points, r)
    theory_bound = int(2 * B / r) + 1
    print(f"  r = {r:4.1f}  |  Greedy separated set size: {len(C):3d}  "
          f"|  Theoretical bound floor(2B/r)+1: {theory_bound:3d}  "
          f"|  Bound holds: {len(C) <= theory_bound}")

# ============================================================
# Demo 2: Maximal separated => covering (1D)
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Maximal Separated Set is a Covering")
print("=" * 60)

points_1d = list(np.arange(-5, 5.01, 0.5))
r = 2.0
C = greedy_maximal_separated([(p,) for p in points_1d], r,
                              metric=lambda x, y: abs(x[0] - y[0]))
C_vals = [c[0] for c in C]
print(f"  Points: {len(points_1d)} points in [-5, 5] with spacing 0.5")
print(f"  r = {r}")
print(f"  Maximal {r}-separated set: {C_vals}")
print(f"  Size: {len(C)}")

# Check covering
all_covered = all(
    any(abs(p - c) <= r for c in C_vals) for p in points_1d
)
print(f"  Is {r}-covering: {all_covered}")

# ============================================================
# Demo 3: Packing-covering sandwich inequality (2D grid)
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Packing-Covering Sandwich Inequality (2D)")
print("=" * 60)

# Create a 2D grid
grid_points = [(i, j) for i in range(-3, 4) for j in range(-3, 4)]
print(f"  {len(grid_points)} points on integer grid [-3,3]²")

for r in [1.5, 2.0, 3.0]:
    M_r = packing_number(grid_points, r, trials=500)
    N_r = covering_number(grid_points, r, trials=500)
    M_2r = packing_number(grid_points, 2 * r, trials=500)
    print(f"  r = {r:.1f}: M(2r) = {M_2r:2d} ≤ N(r) = {N_r:2d} ≤ M(r) = {M_r:2d}  "
          f"|  {M_2r <= N_r and N_r <= M_r}")

# ============================================================
# Demo 4: Rate-distortion tradeoff curve
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Rate-Distortion Tradeoff")
print("=" * 60)

np.random.seed(42)
source_points = [(round(x, 2), round(y, 2))
                 for x, y in zip(np.random.uniform(-5, 5, 50),
                                 np.random.uniform(-5, 5, 50))]
print(f"  Source: {len(source_points)} random points in [-5,5]²")
print(f"  {'Distortion D':>14s}  {'Codebook size N(D)':>18s}  {'Rate (bits)':>12s}")
print(f"  {'-'*14}  {'-'*18}  {'-'*12}")

for D in [0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 7.0, 10.0]:
    N = covering_number(source_points, D, trials=200)
    rate = np.log2(N) if N > 0 else 0
    print(f"  {D:14.1f}  {N:18d}  {rate:12.2f}")

# ============================================================
# Demo 5: Dimension effect on packing
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Dimension Effect on Packing Bounds")
print("=" * 60)

def sup_norm(x, y):
    return max(abs(a - b) for a, b in zip(x, y))

B_val = 3
r_val = 2.0
print(f"  B = {B_val}, r = {r_val}, sup-norm metric")
print(f"  {'Dimension n':>12s}  {'Max separated':>14s}  {'Bound (2B/r+1)^n':>18s}")

for n in range(1, 5):
    # Grid in [-B, B]^n
    from itertools import product
    coords = list(range(-B_val, B_val + 1))
    pts = list(product(coords, repeat=n))
    if len(pts) > 5000:
        pts = [pts[i] for i in np.random.choice(len(pts), 5000, replace=False)]
    M = packing_number(pts, r_val, metric=sup_norm, trials=100)
    bound = (int(2 * B_val / r_val) + 1) ** n
    print(f"  {n:12d}  {M:14d}  {bound:18d}")

print("\n✓ All demonstrations completed successfully.")


#!/usr/bin/env python3
"""
visualizations.py — Generate publication-quality charts for packing-covering theory.
Saves PNG files for inclusion in the article and research paper.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Circle
from matplotlib.collections import PatchCollection
import base64
from io import BytesIO


def save_fig_base64(fig, dpi=150):
    """Convert a matplotlib figure to a base64-encoded PNG string."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=dpi, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def viz_covering_and_packing():
    """Visualize a covering and a packing side by side."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    np.random.seed(42)
    # Generate random points
    n = 50
    points = np.random.uniform(-4, 4, (n, 2))

    # Greedy maximal separated set
    r = 2.0
    selected = []
    for i in range(n):
        if all(np.linalg.norm(points[i] - points[j]) >= r for j in selected):
            selected.append(i)

    # Left: Packing (separated set)
    ax = axes[0]
    ax.scatter(points[:, 0], points[:, 1], c='lightgray', s=30, zorder=2, label='All points')
    for idx in selected:
        circle = Circle(points[idx], r / 2, fill=False, edgecolor='steelblue',
                        linewidth=1.5, linestyle='--', alpha=0.6)
        ax.add_patch(circle)
    ax.scatter(points[selected, 0], points[selected, 1], c='steelblue', s=80,
               zorder=3, label=f'Separated set ({len(selected)} pts)')
    ax.set_xlim(-6, 6)
    ax.set_ylim(-6, 6)
    ax.set_aspect('equal')
    ax.set_title(f'r-Separated Set (r = {r})', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Right: Covering
    ax = axes[1]
    ax.scatter(points[:, 0], points[:, 1], c='lightgray', s=30, zorder=2, label='All points')
    patches = []
    for idx in selected:
        circle = Circle(points[idx], r, fill=True, alpha=0.15,
                        facecolor='coral', edgecolor='coral', linewidth=1.5)
        ax.add_patch(circle)
    ax.scatter(points[selected, 0], points[selected, 1], c='coral', s=80,
               zorder=3, label=f'Cover centers ({len(selected)} pts)')
    ax.set_xlim(-6, 6)
    ax.set_ylim(-6, 6)
    ax.set_aspect('equal')
    ax.set_title(f'r-Covering (r = {r})', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Maximal Separated Set ↔ Covering: The Duality',
                 fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig


def viz_rate_distortion_curve():
    """Plot a rate-distortion curve for a sample finite metric space."""
    fig, ax = plt.subplots(figsize=(10, 6))

    np.random.seed(42)
    n = 80
    points = np.random.uniform(-5, 5, (n, 2))

    distortions = np.linspace(0.3, 8, 40)
    rates = []

    for D in distortions:
        # Greedy covering
        best = n
        for trial in range(50):
            order = np.random.permutation(n)
            selected = []
            for i in order:
                if all(np.linalg.norm(points[i] - points[j]) >= D for j in selected):
                    selected.append(i)
            best = min(best, len(selected))
        rates.append(np.log2(best) if best > 1 else 0)

    ax.plot(distortions, rates, 'b-', linewidth=2.5, label='R(D) = log₂ N(D)')
    ax.fill_between(distortions, rates, alpha=0.1, color='blue')
    ax.set_xlabel('Distortion D', fontsize=13)
    ax.set_ylabel('Rate R(D) [bits]', fontsize=13)
    ax.set_title('Rate-Distortion Curve for a Finite Point Cloud', fontsize=15, fontweight='bold')
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 8)
    ax.set_ylim(0, max(rates) * 1.1)

    # Add annotation
    mid = len(distortions) // 3
    ax.annotate('Lower distortion\n→ more codewords\n→ higher rate',
                xy=(distortions[mid], rates[mid]),
                xytext=(distortions[mid] + 1.5, rates[mid] + 0.5),
                fontsize=10, arrowprops=dict(arrowstyle='->', color='gray'),
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

    fig.tight_layout()
    return fig


def viz_sandwich_inequality():
    """Visualize the sandwich inequality M(2r) ≤ N(r) ≤ M(r)."""
    fig, ax = plt.subplots(figsize=(10, 6))

    np.random.seed(42)
    n = 60
    points = np.random.uniform(-5, 5, (n, 2))

    radii = np.linspace(0.5, 6, 30)
    M_vals = []
    N_vals = []
    M2_vals = []

    for r in radii:
        # M(r): packing number
        best_M = 0
        for _ in range(30):
            order = np.random.permutation(n)
            sel = []
            for i in order:
                if all(np.linalg.norm(points[i] - points[j]) >= r for j in sel):
                    sel.append(i)
            best_M = max(best_M, len(sel))
        M_vals.append(best_M)

        # N(r): covering number
        best_N = n
        for _ in range(30):
            order = np.random.permutation(n)
            sel = []
            for i in order:
                if all(np.linalg.norm(points[i] - points[j]) >= r for j in sel):
                    sel.append(i)
            best_N = min(best_N, len(sel))
        N_vals.append(best_N)

        # M(2r): packing at double radius
        best_M2 = 0
        for _ in range(30):
            order = np.random.permutation(n)
            sel = []
            for i in order:
                if all(np.linalg.norm(points[i] - points[j]) >= 2 * r for j in sel):
                    sel.append(i)
            best_M2 = max(best_M2, len(sel))
        M2_vals.append(best_M2)

    ax.plot(radii, M_vals, 'b-', linewidth=2, label='M(r) — packing number')
    ax.plot(radii, N_vals, 'r--', linewidth=2, label='N(r) — covering number')
    ax.plot(radii, M2_vals, 'g-.', linewidth=2, label='M(2r) — packing at 2r')
    ax.fill_between(radii, M2_vals, M_vals, alpha=0.08, color='purple',
                     label='Sandwich region')
    ax.set_xlabel('Radius r', fontsize=13)
    ax.set_ylabel('Number of points', fontsize=13)
    ax.set_title('Packing-Covering Sandwich: M(2r) ≤ N(r) ≤ M(r)',
                 fontsize=15, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_yscale('log')

    fig.tight_layout()
    return fig


def viz_dimension_scaling():
    """Show how the box-packing bound scales with dimension."""
    fig, ax = plt.subplots(figsize=(10, 6))

    B = 5.0
    dims = range(1, 11)
    for r in [0.5, 1.0, 2.0]:
        bounds = [(int(2 * B / r) + 1) ** d for d in dims]
        ax.semilogy(list(dims), bounds, 'o-', linewidth=2, markersize=6,
                    label=f'r = {r}')

    ax.set_xlabel('Dimension n', fontsize=13)
    ax.set_ylabel('Box packing bound (⌊2B/r⌋+1)ⁿ', fontsize=13)
    ax.set_title('Curse of Dimensionality: Packing Bounds Explode with Dimension',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(list(dims))

    fig.tight_layout()
    return fig


def generate_all():
    """Generate all visualizations, save to files, and return base64 data."""
    results = {}

    print("Generating covering-packing visualization...")
    fig1 = viz_covering_and_packing()
    fig1.savefig('viz_covering_packing.png', dpi=150, bbox_inches='tight')
    results['covering_packing'] = save_fig_base64(fig1)

    print("Generating rate-distortion curve...")
    fig2 = viz_rate_distortion_curve()
    fig2.savefig('viz_rate_distortion.png', dpi=150, bbox_inches='tight')
    results['rate_distortion'] = save_fig_base64(fig2)

    print("Generating sandwich inequality plot...")
    fig3 = viz_sandwich_inequality()
    fig3.savefig('viz_sandwich.png', dpi=150, bbox_inches='tight')
    results['sandwich'] = save_fig_base64(fig3)

    print("Generating dimension scaling plot...")
    fig4 = viz_dimension_scaling()
    fig4.savefig('viz_dimension.png', dpi=150, bbox_inches='tight')
    results['dimension'] = save_fig_base64(fig4)

    print("All visualizations generated.")
    return results


if __name__ == "__main__":
    generate_all()
