"""
Tropical Lossy Compression — Real-World Applications

Demonstrates the tropical optimization framework applied to:
1. Image quantization (color palette reduction)
2. Sensor network compression
3. Clustering as tropical optimization
"""

import numpy as np


def image_quantization_demo():
    """Demonstrate tropical optimal quantization for grayscale image compression.

    Reduces 256 intensity levels to k reproduction levels using squared-error
    distortion and uniform rate penalty.
    """
    print("=" * 60)
    print("APPLICATION 1: Grayscale Image Quantization")
    print("=" * 60)

    # Source: 256 grayscale levels (0-255), weighted by typical histogram
    n_source = 64  # Use 64 for speed
    source_levels = np.linspace(0, 255, n_source)
    # Approximate Gaussian-ish histogram
    w = np.exp(-0.5 * ((source_levels - 128) / 60) ** 2)
    w = w / w.sum() * n_source  # Normalize to sum to n_source

    for k in [2, 4, 8, 16]:
        # Reproduction: k evenly spaced levels
        reprod_levels = np.linspace(0, 255, k)
        kappa = np.ones(k) * np.log2(k)  # Uniform coding cost

        # Distortion: squared error
        d = (source_levels[:, None] - reprod_levels[None, :]) ** 2

        # Sweep lambda
        print(f"\n--- k={k} reproduction levels ---")
        print(f"{'lambda':>8} | {'MSE':>10} | {'Rate':>8} | {'Assignments':>30}")
        print("-" * 70)

        for lam in [0.0, 0.01, 0.1, 1.0]:
            local_cost = d + lam * kappa[None, :]
            assignment = np.argmin(local_cost, axis=1)
            mse = float(np.sum(w * d[np.arange(n_source), assignment]) / np.sum(w))
            rate = float(np.mean(kappa[assignment]))
            # Show which reprod levels are actually used
            used = sorted(set(assignment.tolist()))
            print(f"{lam:8.2f} | {mse:10.2f} | {rate:8.3f} | "
                  f"using {len(used)}/{k} levels")


def sensor_network_demo():
    """Demonstrate tropical compression for a sensor network.

    n sensors report m possible readings; readings must be quantized
    to k < m categories for bandwidth-limited transmission.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Sensor Network Compression")
    print("=" * 60)

    np.random.seed(42)
    n_sensors = 10
    n_readings = 8
    n_categories = 3

    # Random distortion matrix (sensor-specific quantization errors)
    d = np.random.exponential(2.0, (n_readings, n_categories))
    # Add structure: first category is "low", second "mid", third "high"
    for i in range(n_readings):
        closest_cat = min(2, i * 3 // n_readings)
        d[i, closest_cat] *= 0.1  # Make the natural category much cheaper

    # Rate penalty: higher categories cost more bandwidth
    kappa = np.array([1.0, 1.5, 2.0])
    w = np.ones(n_readings)

    print(f"\nDistortion matrix ({n_readings} readings × {n_categories} categories):")
    print(np.array2string(d, precision=2, suppress_small=True))
    print(f"\nRate penalties: {kappa}")

    print(f"\n{'lambda':>8} | {'Total Dist':>10} | {'Total Rate':>10} | {'Assignment':>20}")
    print("-" * 60)

    for lam in [0.0, 0.5, 1.0, 2.0, 5.0]:
        local_cost = d + lam * kappa[None, :]
        assignment = np.argmin(local_cost, axis=1)
        total_dist = float(np.sum(d[np.arange(n_readings), assignment]))
        total_rate = float(np.sum(kappa[assignment]))
        print(f"{lam:8.1f} | {total_dist:10.2f} | {total_rate:10.2f} | "
              f"{assignment.tolist()}")

    # Verify KKT for each lambda
    print("\nKKT Verification:")
    for lam in [0.0, 1.0, 5.0]:
        local_cost = d + lam * kappa[None, :]
        assignment = np.argmin(local_cost, axis=1)
        chosen = local_cost[np.arange(n_readings), assignment]
        mins = np.min(local_cost, axis=1)
        kkt_ok = np.allclose(chosen, mins)
        print(f"  λ={lam:.1f}: KKT satisfied = {kkt_ok}")


def clustering_demo():
    """Demonstrate clustering as tropical optimization.

    k-means with regularization is exactly the tropical quantizer problem.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Clustering as Tropical Optimization")
    print("=" * 60)

    np.random.seed(123)

    # Generate 2D data from 3 clusters
    n_points = 20
    centers_true = np.array([[0, 0], [5, 0], [2.5, 4]])
    points = []
    labels_true = []
    for i in range(n_points):
        c = i % 3
        pt = centers_true[c] + np.random.randn(2) * 0.8
        points.append(pt)
        labels_true.append(c)
    points = np.array(points)

    # Define codebook (reproduction symbols) = candidate cluster centers
    n_centers = 4
    codebook = np.array([[0, 0], [5, 0], [2.5, 4], [2.5, 2]])

    # Distortion: squared Euclidean distance
    d = np.sum((points[:, None, :] - codebook[None, :, :]) ** 2, axis=2)

    # Rate penalty: penalize using more centers
    kappa = np.array([0.5, 0.5, 0.5, 2.0])  # 4th center is expensive

    w = np.ones(n_points)

    print(f"Data: {n_points} points in 2D")
    print(f"Codebook: {n_centers} candidate centers")
    print(f"Rate penalties: {kappa}")

    print(f"\n{'lambda':>8} | {'Centers Used':>12} | {'Total Dist':>10} | {'Total Rate':>10}")
    print("-" * 50)

    for lam in [0.0, 0.1, 0.5, 1.0, 5.0]:
        local_cost = d + lam * kappa[None, :]
        assignment = np.argmin(local_cost, axis=1)
        centers_used = len(set(assignment.tolist()))
        total_dist = float(np.sum(d[np.arange(n_points), assignment]))
        total_rate = float(np.sum(kappa[assignment]))
        print(f"{lam:8.1f} | {centers_used:12d} | {total_dist:10.2f} | {total_rate:10.2f}")

    print("\nNote: As λ increases, the optimizer avoids expensive center 4,")
    print("preferring cheaper centers even at the cost of higher distortion.")
    print("This is exactly the tropical KKT principle in action.")


if __name__ == "__main__":
    image_quantization_demo()
    sensor_network_demo()
    clustering_demo()
    print("\n" + "=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


"""
Tropical Lagrangian Duality for Lossy Compression — Demonstrations

Concrete numerical examples demonstrating:
1. Optimal quantizer construction via pointwise min-plus selection
2. Tropical KKT verification
3. Weak duality verification
4. Rate-distortion tradeoff sweep
"""

import numpy as np
from typing import Callable


def optimal_quantizer(
    source: list,
    reprod: list,
    w: dict,
    d: Callable,
    kappa: dict,
    lam: float,
) -> dict:
    """Find the optimal quantizer by pointwise tropical minimization (Theorem A)."""
    q = {}
    for x in source:
        best_y = None
        best_cost = float("inf")
        for y in reprod:
            cost = d(x, y) + lam * kappa[y]
            if cost < best_cost:
                best_cost = cost
                best_y = y
        q[x] = best_y
    return q


def total_cost(
    source: list,
    q: dict,
    w: dict,
    d: Callable,
    kappa: dict,
    lam: float,
) -> float:
    """Compute total Lagrangian cost of a quantizer."""
    return sum(w[x] + d(x, q[x]) + lam * kappa[q[x]] for x in source)


def verify_kkt(
    source: list,
    reprod: list,
    q: dict,
    d: Callable,
    kappa: dict,
    lam: float,
) -> bool:
    """Verify tropical KKT conditions (Theorem B)."""
    for x in source:
        current = d(x, q[x]) + lam * kappa[q[x]]
        for y in reprod:
            if d(x, y) + lam * kappa[y] < current - 1e-12:
                return False
    return True


def dual_value(
    source: list,
    reprod: list,
    w: dict,
    d: Callable,
    kappa: dict,
    D: float,
    lam: float,
) -> float:
    """Compute the Lagrangian dual value by exhaustive enumeration."""
    from itertools import product as cartesian_product

    best = float("inf")
    for assignment in cartesian_product(reprod, repeat=len(source)):
        q = dict(zip(source, assignment))
        rate = sum(w[x] + kappa[q[x]] for x in source)
        dist = sum(d(x, q[x]) for x in source)
        val = rate + lam * (dist - D)
        best = min(best, val)
    return best


def primal_optimum(
    source: list,
    reprod: list,
    w: dict,
    d: Callable,
    kappa: dict,
    D: float,
) -> float:
    """Compute the primal optimum by exhaustive enumeration."""
    from itertools import product as cartesian_product

    best = float("inf")
    for assignment in cartesian_product(reprod, repeat=len(source)):
        q = dict(zip(source, assignment))
        dist = sum(d(x, q[x]) for x in source)
        if dist <= D + 1e-12:
            rate = sum(w[x] + kappa[q[x]] for x in source)
            best = min(best, rate)
    return best


# ============================================================
# Demo 1: Binary source, binary reproduction
# ============================================================
print("=" * 60)
print("DEMO 1: Binary Source with Binary Reproduction")
print("=" * 60)

source = [0, 1]
reprod = ["a", "b"]
w = {0: 1.0, 1: 2.0}
d_matrix = {(0, "a"): 0, (0, "b"): 3, (1, "a"): 2, (1, "b"): 0}
d_func = lambda x, y: d_matrix[(x, y)]
kappa = {"a": 1.0, "b": 2.0}
lam = 0.5

q_opt = optimal_quantizer(source, reprod, w, d_func, kappa, lam)
cost = total_cost(source, q_opt, w, d_func, kappa, lam)
kkt_ok = verify_kkt(source, reprod, q_opt, d_func, kappa, lam)

print(f"Optimal quantizer: {q_opt}")
print(f"Total Lagrangian cost: {cost}")
print(f"KKT conditions satisfied: {kkt_ok}")

# Verify all quantizers
print("\nAll quantizers and their costs:")
for q0 in reprod:
    for q1 in reprod:
        q = {0: q0, 1: q1}
        c = total_cost(source, q, w, d_func, kappa, lam)
        kkt = verify_kkt(source, reprod, q, d_func, kappa, lam)
        print(f"  q(0)={q0}, q(1)={q1}: cost={c:.2f}, KKT={kkt}")

# ============================================================
# Demo 2: Rate-distortion tradeoff sweep
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Rate-Distortion Tradeoff Sweep")
print("=" * 60)

source3 = [0, 1, 2]
reprod3 = ["A", "B"]
w3 = {0: 1.0, 1: 1.0, 2: 1.0}
d3 = {
    (0, "A"): 0, (0, "B"): 2,
    (1, "A"): 1, (1, "B"): 1,
    (2, "A"): 3, (2, "B"): 0,
}
d3_func = lambda x, y: d3[(x, y)]
kappa3 = {"A": 1.0, "B": 1.5}

print(f"{'lambda':>8} | {'Optimal q':>15} | {'Total Cost':>10} | {'KKT':>5}")
print("-" * 50)

for lam_val in np.arange(0, 5.1, 0.5):
    q = optimal_quantizer(source3, reprod3, w3, d3_func, kappa3, lam_val)
    c = total_cost(source3, q, w3, d3_func, kappa3, lam_val)
    kkt = verify_kkt(source3, reprod3, q, d3_func, kappa3, lam_val)
    q_str = "".join(q[x] for x in source3)
    print(f"{lam_val:8.1f} | {q_str:>15} | {c:10.2f} | {kkt!s:>5}")

# ============================================================
# Demo 3: Weak duality verification
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Weak Duality Verification")
print("=" * 60)

D_budget = 3.0
p_opt = primal_optimum(source3, reprod3, w3, d3_func, kappa3, D_budget)
print(f"Primal optimum P({D_budget}) = {p_opt:.4f}")

print(f"\n{'lambda':>8} | {'G(lambda)':>10} | {'Gap':>10} | {'Weak Dual':>10}")
print("-" * 50)

for lam_val in np.arange(0, 3.1, 0.25):
    g = dual_value(source3, reprod3, w3, d3_func, kappa3, D_budget, lam_val)
    gap = p_opt - g
    ok = g <= p_opt + 1e-10
    print(f"{lam_val:8.2f} | {g:10.4f} | {gap:10.4f} | {'✓' if ok else '✗':>10}")

# ============================================================
# Demo 4: Larger example — image quantization analogy
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Image Quantization (8 levels → 3 levels)")
print("=" * 60)

source_img = list(range(8))
reprod_img = [1, 4, 7]  # 3 reproduction levels
w_img = {x: 1.0 for x in source_img}
d_img_func = lambda x, y: (x - y) ** 2  # squared error
kappa_img = {1: 0.5, 4: 0.8, 7: 0.5}

print(f"{'lambda':>8} | {'Quantizer':>24} | {'Distortion':>10} | {'Rate':>8}")
print("-" * 60)

for lam_val in [0.0, 0.1, 0.5, 1.0, 2.0]:
    q = optimal_quantizer(source_img, reprod_img, w_img, d_img_func, kappa_img, lam_val)
    dist = sum(d_img_func(x, q[x]) for x in source_img)
    rate = sum(kappa_img[q[x]] for x in source_img)
    q_str = str([q[x] for x in source_img])
    print(f"{lam_val:8.1f} | {q_str:>24} | {dist:10.1f} | {rate:8.1f}")

print("\nAll demos completed successfully.")


"""Generate PACKAGE.json with all embedded content."""

import json
import sys
sys.path.insert(0, '/workspace/request-project')

from visualizations import (
    create_rate_distortion_plot,
    create_dual_value_plot,
    create_assignment_heatmap,
    create_kkt_verification_plot,
)

# Read all text files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('/workspace/request-project/ARTICLE.md')
research_paper = read_file('/workspace/request-project/RESEARCH_PAPER.md')
future_directions = read_file('/workspace/request-project/FUTURE_DIRECTIONS.md')
lean_proofs = read_file('/workspace/request-project/Computation/TropicalLossyCompression.lean')
demo_code = read_file('/workspace/request-project/demo.py')
algorithms_code = read_file('/workspace/request-project/algorithms.py')
applications_code = read_file('/workspace/request-project/applications.py')

# Generate visualizations
viz_rd, _ = create_rate_distortion_plot()
viz_dual, _ = create_dual_value_plot()
viz_heatmap, _ = create_assignment_heatmap()
viz_kkt, _ = create_kkt_verification_plot()

package = {
    "title": "Tropical Lagrangian Duality for Finite Lossy Compression",
    "domain": "Computation / Information Theory / Tropical Geometry",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Lossy Compression Demos",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Optimal Quantizer",
            "pseudocode": "For each source symbol x:\\n  q*(x) <- argmin_{y in beta} (d(x,y) + lambda * kappa(y))\\nCost <- sum_{x in s} (w(x) + d(x,q*(x)) + lambda * kappa(q*(x)))\\nReturn (q*, Cost)\\n\\nComplexity: O(|source| * |reprod|) time, O(|source|) space",
            "code": algorithms_code
        },
        {
            "name": "Tropical KKT Verification",
            "pseudocode": "For each source symbol x in s:\\n  current_cost <- d(x, q(x)) + lambda * kappa(q(x))\\n  For each y in beta:\\n    If d(x, y) + lambda * kappa(y) < current_cost:\\n      Return False\\nReturn True\\n\\nComplexity: O(|source| * |reprod|) time, O(1) space",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {"name": "Rate-Distortion Tradeoff", "data": viz_rd},
        {"name": "Tropical Weak Duality: G(λ) ≤ P(D)", "data": viz_dual},
        {"name": "Optimal Quantizer Assignments vs. λ", "data": viz_heatmap},
        {"name": "Tropical KKT Conditions Visualization", "data": viz_kkt}
    ],
    "lean_proofs": lean_proofs
}

with open('/workspace/request-project/PACKAGE.json', 'w') as f:
    json.dump(package, f, ensure_ascii=False)

print("PACKAGE.json generated successfully.")
print(f"File size: {len(json.dumps(package))} bytes")


"""
Tropical Lossy Compression — Visualizations

Generates publication-quality figures:
1. Rate-distortion tradeoff curve
2. Dual value as function of λ (piecewise linear)
3. Weak duality gap visualization
4. Quantizer assignment heatmap
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def create_rate_distortion_plot():
    """Plot the rate-distortion tradeoff as λ varies."""
    n_source = 6
    n_reprod = 4
    np.random.seed(42)

    source = np.arange(n_source)
    d = np.random.rand(n_source, n_reprod) * 5
    kappa = np.array([0.5, 1.0, 1.5, 2.0])
    w = np.ones(n_source)

    lam_vals = np.linspace(0, 5, 200)
    distortions = []
    rates = []

    for lam in lam_vals:
        lc = d + lam * kappa[None, :]
        assignment = np.argmin(lc, axis=1)
        dist = float(np.sum(d[np.arange(n_source), assignment]))
        rate = float(np.sum(kappa[assignment]))
        distortions.append(dist)
        rates.append(rate)

    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    ax.plot(distortions, rates, 'b-', linewidth=2, label='Rate-Distortion Frontier')
    ax.scatter(distortions[0], rates[0], c='red', s=100, zorder=5, label='λ=0 (min distortion)')
    ax.scatter(distortions[-1], rates[-1], c='green', s=100, zorder=5, label='λ=5 (min rate)')

    # Mark a few intermediate points
    for idx in [40, 80, 120, 160]:
        ax.annotate(f'λ={lam_vals[idx]:.1f}',
                    (distortions[idx], rates[idx]),
                    textcoords="offset points", xytext=(10, 10),
                    fontsize=9, alpha=0.7)

    ax.set_xlabel('Total Distortion', fontsize=12)
    ax.set_ylabel('Total Rate (Coding Cost)', fontsize=12)
    ax.set_title('Tropical Rate-Distortion Tradeoff', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    return fig_to_base64(fig), fig


def create_dual_value_plot():
    """Plot dual value G(λ) showing piecewise linearity."""
    n_source = 4
    n_reprod = 3

    d = np.array([[0, 2, 4], [3, 0, 1], [2, 3, 0], [1, 1, 3]], dtype=float)
    kappa = np.array([1.0, 1.5, 2.0])
    w = np.ones(n_source)
    D = 4.0

    lam_vals = np.linspace(0, 5, 500)
    dual_vals = []
    primal_val = None

    # Compute primal optimum
    from itertools import product as cartesian_product
    primal_opt = float('inf')
    for assignment in cartesian_product(range(n_reprod), repeat=n_source):
        a = np.array(assignment)
        dist = float(np.sum(d[np.arange(n_source), a]))
        if dist <= D:
            rate_cost = float(np.sum(w + kappa[a]))
            primal_opt = min(primal_opt, rate_cost)

    for lam in lam_vals:
        combined = kappa[None, :] + lam * d
        min_combined = np.min(combined, axis=1)
        g = float(np.sum(w + min_combined) - lam * D)
        dual_vals.append(g)

    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    ax.plot(lam_vals, dual_vals, 'b-', linewidth=2, label='Dual G(λ)')
    ax.axhline(y=primal_opt, color='r', linestyle='--', linewidth=1.5,
               label=f'Primal P(D)={primal_opt:.2f}')

    best_idx = np.argmax(dual_vals)
    ax.scatter([lam_vals[best_idx]], [dual_vals[best_idx]], c='green', s=100,
               zorder=5, label=f'Best dual (λ*={lam_vals[best_idx]:.2f})')

    # Shade the duality gap
    ax.fill_between(lam_vals, dual_vals, primal_opt, alpha=0.1, color='red',
                     label='Duality gap')

    ax.set_xlabel('Lagrange Multiplier λ', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Tropical Weak Duality: G(λ) ≤ P(D)', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    return fig_to_base64(fig), fig


def create_assignment_heatmap():
    """Heatmap of optimal quantizer assignments as λ varies."""
    n_source = 8
    n_reprod = 4

    np.random.seed(7)
    d = np.random.rand(n_source, n_reprod) * 5
    kappa = np.array([0.5, 1.0, 2.0, 3.0])

    lam_vals = np.linspace(0, 5, 50)
    assignments = np.zeros((len(lam_vals), n_source), dtype=int)

    for i, lam in enumerate(lam_vals):
        lc = d + lam * kappa[None, :]
        assignments[i] = np.argmin(lc, axis=1)

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    cmap = plt.cm.get_cmap('Set1', n_reprod)
    im = ax.imshow(assignments.T, aspect='auto', cmap=cmap,
                   extent=[0, 5, n_source - 0.5, -0.5],
                   interpolation='nearest')
    ax.set_xlabel('Lagrange Multiplier λ', fontsize=12)
    ax.set_ylabel('Source Symbol x', fontsize=12)
    ax.set_title('Optimal Quantizer Assignments vs. λ', fontsize=14)
    ax.set_yticks(range(n_source))
    ax.set_yticklabels([f'x={i}' for i in range(n_source)])
    cbar = plt.colorbar(im, ax=ax, ticks=range(n_reprod))
    cbar.set_label('Reproduction Symbol y', fontsize=11)
    cbar.set_ticklabels([f'y={j}' for j in range(n_reprod)])

    return fig_to_base64(fig), fig


def create_kkt_verification_plot():
    """Visualize KKT conditions: local cost comparison at each source symbol."""
    n_source = 5
    n_reprod = 4

    d = np.array([
        [0, 2, 4, 5],
        [3, 0, 1, 2],
        [2, 3, 0, 1],
        [4, 1, 2, 0],
        [1, 2, 3, 1],
    ], dtype=float)
    kappa = np.array([1.0, 1.5, 2.0, 2.5])
    lam = 1.0

    lc = d + lam * kappa[None, :]
    assignment = np.argmin(lc, axis=1)

    fig, axes = plt.subplots(1, n_source, figsize=(15, 4), sharey=True)
    colors = ['#2196F3', '#FF9800', '#4CAF50', '#F44336']

    for i, ax in enumerate(axes):
        costs = lc[i]
        bars = ax.bar(range(n_reprod), costs, color=colors, alpha=0.6, edgecolor='black')
        # Highlight the chosen one
        bars[assignment[i]].set_alpha(1.0)
        bars[assignment[i]].set_edgecolor('gold')
        bars[assignment[i]].set_linewidth(3)
        ax.set_xlabel(f'x={i}', fontsize=11)
        ax.set_xticks(range(n_reprod))
        ax.set_xticklabels([f'y={j}' for j in range(n_reprod)], fontsize=9)
        if i == 0:
            ax.set_ylabel('Local Cost', fontsize=11)
        ax.set_title(f'q({i})={assignment[i]}', fontsize=10)

    fig.suptitle('Tropical KKT: Each Source Symbol Selects Its Minimum-Cost Reproduction',
                 fontsize=13, y=1.02)
    fig.tight_layout()

    return fig_to_base64(fig), fig


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_rd, _ = create_rate_distortion_plot()
    print(f"Rate-distortion plot: {len(b64_rd)} chars")

    b64_dual, _ = create_dual_value_plot()
    print(f"Dual value plot: {len(b64_dual)} chars")

    b64_heatmap, _ = create_assignment_heatmap()
    print(f"Assignment heatmap: {len(b64_heatmap)} chars")

    b64_kkt, _ = create_kkt_verification_plot()
    print(f"KKT verification plot: {len(b64_kkt)} chars")

    print("All visualizations generated successfully.")
