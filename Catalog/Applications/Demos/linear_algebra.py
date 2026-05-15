#!/usr/bin/env python3
"""
Applications of Tropical Rank-One Factorization

Demonstrates real-world applications:
1. Neural network weight analysis — detecting separable layers
2. Optimal transport — identifying separable cost structures
3. Recommendation systems — additive preference models
4. Signal processing — separable filter detection
"""

import numpy as np
from algorithms import (
    verify_tropical_rank1_fast,
    extract_potentials,
    project_to_rank1,
    detect_approximate_rank1,
    tropical_rank1_residual,
)


def app_neural_network_analysis():
    """
    Application 1: Neural Network Weight Analysis

    A neural network layer W has tropical rank 1 iff its weights decompose as
    W[i,j] = u[i] + v[j], meaning the output features are additively separable
    in input features and output channels. This implies the layer can be
    compressed to just n+m parameters instead of n*m.
    """
    print("=" * 60)
    print("APP 1: Neural Network Layer Separability Analysis")
    print("=" * 60)

    np.random.seed(42)

    # Simulate a "separable" weight matrix (tropical rank 1)
    input_dim, output_dim = 128, 64
    input_bias = np.random.randn(input_dim)
    output_bias = np.random.randn(output_dim)
    W_separable = input_bias[:, None] + output_bias[None, :]

    # Simulate a generic weight matrix
    W_generic = np.random.randn(input_dim, output_dim)

    # Simulate a nearly-separable weight matrix (rank-1 + small perturbation)
    W_nearly = W_separable + 0.01 * np.random.randn(input_dim, output_dim)

    for name, W in [("Separable", W_separable), ("Nearly separable", W_nearly), ("Generic", W_generic)]:
        result = detect_approximate_rank1(W, threshold=0.05)
        params_full = W.shape[0] * W.shape[1]
        params_sep = W.shape[0] + W.shape[1]
        compression = params_full / params_sep

        print(f"\n  {name} layer ({W.shape[0]}×{W.shape[1]}):")
        print(f"    Exact rank-1: {result['is_rank1']}")
        print(f"    Relative residual: {result['relative_residual']:.6f}")
        print(f"    Potential compression: {params_full} → {params_sep} params ({compression:.1f}×)")

    print("\n  → Separable layers need only n+m parameters, not n×m!")
    print("  → Tropical minor check provides a polynomial-time certificate.")


def app_optimal_transport():
    """
    Application 2: Optimal Transport with Separable Costs

    If the cost matrix c(i,j) = f(source_i) + g(sink_j) is additively
    separable, optimal transport simplifies dramatically: each source
    and sink can be optimized independently.
    """
    print("\n" + "=" * 60)
    print("APP 2: Optimal Transport — Separable Cost Detection")
    print("=" * 60)

    # Scenario: shipping costs between warehouses and stores
    n_warehouses, n_stores = 5, 8

    # Case 1: Costs are purely geographic (separable)
    warehouse_costs = np.array([10, 15, 8, 20, 12], dtype=float)  # loading costs
    store_costs = np.array([5, 8, 3, 12, 6, 9, 4, 7], dtype=float)  # unloading costs
    C_separable = warehouse_costs[:, None] + store_costs[None, :]

    # Case 2: Costs include route-specific factors (non-separable)
    route_surcharges = np.zeros((n_warehouses, n_stores))
    route_surcharges[0, 3] = 5  # congestion on specific route
    route_surcharges[2, 7] = 3  # toll road
    route_surcharges[4, 1] = 4  # ferry crossing
    C_nonsep = C_separable + route_surcharges

    for name, C in [("Separable costs", C_separable), ("Route-specific costs", C_nonsep)]:
        is_sep, witness = verify_tropical_rank1_fast(C)
        residual = tropical_rank1_residual(C)

        print(f"\n  {name}:")
        print(f"    Separable (tropical rank 1): {is_sep}")
        print(f"    Rank-1 residual: {residual:.4f}")

        if is_sep:
            u, v = extract_potentials(C)
            print(f"    → Decomposition: loading costs + unloading costs")
            print(f"    → Each facility optimizable independently!")
        else:
            print(f"    → Non-separable at indices {witness}")
            print(f"    → Must solve full bipartite optimization.")


def app_recommendation_system():
    """
    Application 3: Recommendation System — Additive Preference Model

    In a tropical/additive preference model, user rating of item j by user i is:
      R[i,j] = user_quality[i] + item_appeal[j]

    This is a 1-factor model: preferences decompose into user-specific and
    item-specific components with no interaction effects.

    Testing whether a rating matrix has tropical rank 1 tests whether this
    simple additive model explains all observed ratings.
    """
    print("\n" + "=" * 60)
    print("APP 3: Recommendation System — Additive Preference Test")
    print("=" * 60)

    np.random.seed(7)

    # Users and items
    users = ["Alice", "Bob", "Carol", "Dave", "Eve"]
    items = ["Sci-Fi", "Romance", "Action", "Documentary", "Comedy"]

    # Pure additive model: rating = user_generosity + item_quality
    user_gen = np.array([3.0, 1.0, 4.0, 2.0, 5.0])
    item_qual = np.array([1.0, -0.5, 0.5, 2.0, 1.5])
    R_additive = user_gen[:, None] + item_qual[None, :]

    # Model with interaction (some users specifically like/dislike genres)
    interactions = np.zeros((5, 5))
    interactions[0, 0] = 2.0  # Alice loves Sci-Fi
    interactions[3, 1] = -1.5  # Dave dislikes Romance
    interactions[4, 3] = 1.0  # Eve loves Documentaries
    R_interaction = R_additive + interactions

    for name, R in [("Additive model", R_additive), ("With interactions", R_interaction)]:
        is_add, witness = verify_tropical_rank1_fast(R)
        residual = tropical_rank1_residual(R)

        print(f"\n  {name}:")
        print(f"    Additive (tropical rank 1): {is_add}")
        print(f"    Rank-1 residual: {residual:.4f}")

        if is_add:
            u, v = extract_potentials(R)
            print(f"    User generosity: {dict(zip(users, np.round(u, 1)))}")
            print(f"    Item appeal:     {dict(zip(items, np.round(v, 1)))}")
            print(f"    → Simple model explains all ratings!")
        else:
            _, u, v = project_to_rank1(R)
            print(f"    → Interaction effects detected at {witness}")
            print(f"    → Need collaborative filtering, not just additive model.")


def app_separable_filter():
    """
    Application 4: Signal Processing — Separable 2D Filter Detection

    A 2D convolution filter h[i,j] is separable iff h[i,j] = a[i]*b[j],
    which in the log domain becomes log(h[i,j]) = log(a[i]) + log(b[j]).
    Tropical rank-1 of log(|h|) detects multiplicatively separable filters.

    Separable filters reduce 2D convolution from O(nm) to O(n+m) per pixel.
    """
    print("\n" + "=" * 60)
    print("APP 4: Signal Processing — Separable Filter Detection")
    print("=" * 60)

    # Gaussian filter (separable)
    sigma = 2.0
    k = 5
    t = np.arange(-k, k + 1, dtype=float)
    g1d = np.exp(-t ** 2 / (2 * sigma ** 2))
    h_gaussian = np.outer(g1d, g1d)  # Separable!

    # Laplacian of Gaussian (not separable)
    x, y = np.meshgrid(t, t)
    r2 = x ** 2 + y ** 2
    h_log = (1 - r2 / (2 * sigma ** 2)) * np.exp(-r2 / (2 * sigma ** 2))

    for name, h in [("Gaussian", h_gaussian), ("Laplacian-of-Gaussian", h_log)]:
        # Work in log domain (shift to ensure positive)
        h_pos = np.abs(h) + 1e-15
        log_h = np.log(h_pos)

        is_sep, witness = verify_tropical_rank1_fast(log_h)
        residual = tropical_rank1_residual(log_h)

        n_ops_full = h.shape[0] * h.shape[1]
        n_ops_sep = h.shape[0] + h.shape[1]

        print(f"\n  {name} filter ({h.shape[0]}×{h.shape[1]}):")
        print(f"    Log-separable (tropical rank 1): {is_sep}")
        print(f"    Rank-1 residual: {residual:.4f}")
        print(f"    Full conv: {n_ops_full} multiplies/pixel")
        print(f"    If separable: {n_ops_sep} multiplies/pixel ({n_ops_full / n_ops_sep:.1f}× speedup)")


if __name__ == "__main__":
    app_neural_network_analysis()
    app_optimal_transport()
    app_recommendation_system()
    app_separable_filter()


#!/usr/bin/env python3
"""
Tropical Rank-One Factorization: Demonstrations

This script demonstrates the tropical rank-one factorization theorem with
concrete numerical examples, showing that:
  - A matrix with vanishing 2x2 tropical minors decomposes as u(i) + v(j)
  - The normalized construction A(i,j₀) / A(i₀,j) - A(i₀,j₀) recovers u, v
  - The factorization is unique up to a gauge constant c
"""

import numpy as np

def check_tropical_minors(A):
    """Check if all 2x2 tropical minors vanish: A[i1,j1]+A[i2,j2] == A[i1,j2]+A[i2,j1]."""
    n, m = A.shape
    for i1 in range(n):
        for i2 in range(n):
            for j1 in range(m):
                for j2 in range(m):
                    lhs = A[i1, j1] + A[i2, j2]
                    rhs = A[i1, j2] + A[i2, j1]
                    if not np.isclose(lhs, rhs):
                        return False, (i1, i2, j1, j2, lhs, rhs)
    return True, None

def extract_potentials(A, i0=0, j0=0):
    """Extract normalized potentials u, v from matrix A with base point (i0, j0)."""
    u = A[:, j0].copy()
    v = A[i0, :] - A[i0, j0]
    return u, v

def reconstruct(u, v):
    """Reconstruct matrix from potentials: A[i,j] = u[i] + v[j]."""
    return u[:, np.newaxis] + v[np.newaxis, :]

def demo_basic():
    """Demo 1: Basic factorization of a rank-1 tropical matrix."""
    print("=" * 60)
    print("DEMO 1: Basic Tropical Rank-1 Factorization")
    print("=" * 60)

    u = np.array([1.0, 3.0, -2.0, 5.0])
    v = np.array([2.0, -1.0, 4.0])

    A = reconstruct(u, v)
    print(f"\nOriginal potentials:")
    print(f"  u = {u}")
    print(f"  v = {v}")
    print(f"\nConstructed matrix A[i,j] = u[i] + v[j]:")
    print(A)

    ok, info = check_tropical_minors(A)
    print(f"\nAll 2x2 tropical minors vanish: {ok}")

    u_rec, v_rec = extract_potentials(A, i0=0, j0=0)
    A_rec = reconstruct(u_rec, v_rec)
    print(f"\nRecovered potentials (base point i₀=0, j₀=0):")
    print(f"  u_rec = {u_rec}")
    print(f"  v_rec = {v_rec}")
    print(f"\nReconstruction error: {np.max(np.abs(A - A_rec)):.2e}")

    # Gauge uniqueness
    c = u_rec[0] - u[0]
    print(f"\nGauge constant c = u_rec[0] - u[0] = {c}")
    print(f"  u_rec = u + c? {np.allclose(u_rec, u + c)}")
    print(f"  v_rec = v - c? {np.allclose(v_rec, v - c)}")

def demo_non_rank1():
    """Demo 2: A matrix that is NOT tropical rank-1."""
    print("\n" + "=" * 60)
    print("DEMO 2: Non-Rank-1 Matrix Detection")
    print("=" * 60)

    A = np.array([
        [1.0, 2.0, 3.0],
        [4.0, 6.0, 5.0],  # This row breaks rank-1
        [7.0, 8.0, 9.0]
    ])
    print(f"\nMatrix A:")
    print(A)

    ok, info = check_tropical_minors(A)
    print(f"\nAll 2x2 tropical minors vanish: {ok}")
    if not ok:
        i1, i2, j1, j2, lhs, rhs = info
        print(f"  Counterexample: i₁={i1}, i₂={i2}, j₁={j1}, j₂={j2}")
        print(f"  A[{i1},{j1}] + A[{i2},{j2}] = {A[i1,j1]} + {A[i2,j2]} = {lhs}")
        print(f"  A[{i1},{j2}] + A[{i2},{j1}] = {A[i1,j2]} + {A[i2,j1]} = {rhs}")

def demo_large_random():
    """Demo 3: Large random rank-1 tropical matrix."""
    print("\n" + "=" * 60)
    print("DEMO 3: Large Random Rank-1 Matrix")
    print("=" * 60)

    np.random.seed(42)
    n, m = 20, 15
    u = np.random.randn(n) * 10
    v = np.random.randn(m) * 10
    A = reconstruct(u, v)

    print(f"\nMatrix size: {n} × {m}")
    ok, _ = check_tropical_minors(A)
    print(f"All 2x2 tropical minors vanish: {ok}")

    u_rec, v_rec = extract_potentials(A)
    A_rec = reconstruct(u_rec, v_rec)
    print(f"Max reconstruction error: {np.max(np.abs(A - A_rec)):.2e}")

    # Different base points give gauge-equivalent decompositions
    for i0, j0 in [(0, 0), (10, 5), (15, 10)]:
        u2, v2 = extract_potentials(A, i0, j0)
        A2 = reconstruct(u2, v2)
        err = np.max(np.abs(A - A2))
        c = u2[0] - u_rec[0]
        print(f"  Base ({i0:2d},{j0:2d}): error={err:.2e}, gauge shift c={c:.4f}")

def demo_tropical_cost_matrix():
    """Demo 4: Application to optimal transport cost matrices."""
    print("\n" + "=" * 60)
    print("DEMO 4: Optimal Transport — Separable Cost Matrix")
    print("=" * 60)

    # A separable cost matrix c(i,j) = f(i) + g(j) means transport
    # decomposes into independent source and sink costs
    cities_source = ["New York", "Chicago", "LA"]
    cities_sink = ["London", "Tokyo", "Berlin", "Sydney"]

    f = np.array([5.0, 3.0, 7.0])  # source costs
    g = np.array([8.0, 12.0, 6.0, 15.0])  # sink costs

    C = reconstruct(f, g)
    print(f"\nSeparable cost matrix C[i,j] = f(source_i) + g(sink_j):")
    print(f"{'':12s}", end="")
    for city in cities_sink:
        print(f"{city:>10s}", end="")
    print()
    for i, city in enumerate(cities_source):
        print(f"{city:12s}", end="")
        for j in range(len(cities_sink)):
            print(f"{C[i,j]:10.1f}", end="")
        print()

    ok, _ = check_tropical_minors(C)
    print(f"\nTropical rank 1 (separable): {ok}")
    print("→ Transport cost decomposes: independent source + sink contributions!")

    # Perturb and check
    C_perturbed = C.copy()
    C_perturbed[1, 2] += 1.5  # Add a specific route surcharge
    ok2, _ = check_tropical_minors(C_perturbed)
    print(f"\nAfter adding route-specific surcharge: rank 1? {ok2}")
    print("→ Non-separable costs require full optimization, no shortcut!")

def demo_gauge_uniqueness():
    """Demo 5: Gauge uniqueness illustration."""
    print("\n" + "=" * 60)
    print("DEMO 5: Gauge Uniqueness — The Hidden Symmetry")
    print("=" * 60)

    u = np.array([2.0, 5.0, -1.0])
    v = np.array([3.0, 7.0, -2.0, 4.0])
    A = reconstruct(u, v)

    print(f"\nMatrix A (3×4):")
    print(A)
    print(f"\nFactorization 1: u={u}, v={v}")

    # Shift by gauge constant
    for c in [1.0, -3.5, 10.0]:
        u2 = u + c
        v2 = v - c
        A2 = reconstruct(u2, v2)
        match = np.allclose(A, A2)
        print(f"  c={c:5.1f}: u'={u2}, v'={v2} → same matrix? {match}")

    print("\n→ All factorizations differ by a constant shift (gauge freedom)!")

if __name__ == "__main__":
    demo_basic()
    demo_non_rank1()
    demo_large_random()
    demo_tropical_cost_matrix()
    demo_gauge_uniqueness()


#!/usr/bin/env python3
"""Generate PACKAGE.json with all embedded content."""

import json
import sys
sys.path.insert(0, '/workspace/request-project')
from visualizations import viz_factorization, viz_minor_condition, viz_gauge_freedom, viz_residual_heatmap

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Generate visualizations
print("Generating visualizations...")
v1 = viz_factorization()
v2 = viz_minor_condition()
v3 = viz_gauge_freedom()
v4 = viz_residual_heatmap()
print("Done with visualizations.")

# Read all content files
article = read_file('/workspace/request-project/ARTICLE.md')
research_paper = read_file('/workspace/request-project/RESEARCH_PAPER.md')
future_directions = read_file('/workspace/request-project/FUTURE_DIRECTIONS.md')
lean_code = read_file('/workspace/request-project/Tropical/RankOneFactorization.lean')
demo_code = read_file('/workspace/request-project/demo.py')
algorithms_code = read_file('/workspace/request-project/algorithms.py')
applications_code = read_file('/workspace/request-project/applications.py')

package = {
    "title": "Tropical Rank-One Factorization: A Complete Structure Theorem for Additively Separable Matrices",
    "domain": "Tropical Geometry / Linear Algebra",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Rank-1 Factorization Demo",
            "code": demo_code
        },
        {
            "name": "Applications: Neural Networks, Transport, Recommendations",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Fast Tropical Rank-1 Verification (O(nm))",
            "pseudocode": """Input: Matrix A of size n × m
Output: (is_rank_1, counterexample)

ref_diffs[j] ← A[0,j] - A[0,0] for j = 0,...,m-1
for i = 1 to n-1:
    for j = 1 to m-1:
        if A[i,j] - A[i,0] ≠ ref_diffs[j]:
            return (False, (i, j))
return (True, None)

Complexity: O(nm) time, O(m) space""",
            "code": algorithms_code
        },
        {
            "name": "Basepoint Potential Extraction (O(n+m))",
            "pseudocode": """Input: Rank-1 matrix A, basepoint (i₀, j₀)
Output: Potentials u, v with A[i,j] = u[i] + v[j]

u[i] ← A[i, j₀] for all i
v[j] ← A[i₀, j] - A[i₀, j₀] for all j

Complexity: O(n+m) time and space""",
            "code": """import numpy as np

def extract_potentials(A, i0=0, j0=0):
    u = A[:, j0].copy()
    v = A[i0, :] - A[i0, j0]
    return u, v

# Example
A = np.array([[3, 0, 5], [5, 2, 7], [0, -3, 2], [7, 4, 9]], dtype=float)
u, v = extract_potentials(A)
print(f"u = {u}")
print(f"v = {v}")
print(f"Reconstruction matches: {np.allclose(A, u[:,None] + v[None,:])}")"""
        },
        {
            "name": "Rank-1 Projection (O(nm))",
            "pseudocode": """Input: Arbitrary matrix A of size n × m
Output: Nearest rank-1 matrix A*, potentials u, v

row_means ← row averages of A
col_means ← column averages of A
grand_mean ← overall average of A
u ← row_means
v ← col_means - grand_mean
A* ← u ⊕ v (outer sum)

Complexity: O(nm) time""",
            "code": """import numpy as np

def project_to_rank1(A):
    row_means = A.mean(axis=1)
    col_means = A.mean(axis=0)
    grand_mean = A.mean()
    u = row_means
    v = col_means - grand_mean
    A_proj = u[:, None] + v[None, :]
    return A_proj, u, v

# Example
np.random.seed(42)
u0 = np.array([1, 3, -1, 4, 2], dtype=float)
v0 = np.array([2, -1, 3, 0], dtype=float)
A_rank1 = u0[:, None] + v0[None, :]
A_noisy = A_rank1 + 0.1 * np.random.randn(5, 4)
A_proj, u, v = project_to_rank1(A_noisy)
residual = np.linalg.norm(A_noisy - A_proj) / np.linalg.norm(A_noisy)
print(f"Relative residual: {residual:.4f}")"""
        }
    ],
    "visualizations": [
        {"name": "Rank-1 Factorization Decomposition", "data": v1},
        {"name": "2×2 Tropical Minor Test", "data": v2},
        {"name": "Gauge Freedom Illustration", "data": v3},
        {"name": "Rank-1 Projection and Residual", "data": v4}
    ],
    "lean_proofs": lean_code
}

with open('/workspace/request-project/PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2)

print(f"PACKAGE.json written ({len(json.dumps(package))} chars)")


#!/usr/bin/env python3
"""Generate visualizations for the tropical rank-one factorization theorem."""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import base64
from io import BytesIO


def fig_to_base64(fig, dpi=150):
    """Convert a matplotlib figure to a base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=dpi, bbox_inches='tight', facecolor='white')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_factorization():
    """Visualize the rank-1 factorization: A = u + v^T."""
    u = np.array([1.0, 3.0, -2.0, 5.0, 0.5])
    v = np.array([2.0, -1.0, 4.0, 0.0, 3.0, -2.0])
    A = u[:, None] + v[None, :]

    fig = plt.figure(figsize=(14, 4))
    gs = GridSpec(1, 5, width_ratios=[5, 0.3, 1, 0.3, 5], figure=fig)

    ax_a = fig.add_subplot(gs[0, 0])
    im = ax_a.imshow(A, cmap='RdBu_r', aspect='auto')
    ax_a.set_title('Matrix A', fontsize=14, fontweight='bold')
    ax_a.set_xlabel('Column j')
    ax_a.set_ylabel('Row i')
    plt.colorbar(im, ax=ax_a, shrink=0.8)
    for i in range(A.shape[0]):
        for j in range(A.shape[1]):
            ax_a.text(j, i, f'{A[i,j]:.0f}', ha='center', va='center', fontsize=9)

    ax_eq = fig.add_subplot(gs[0, 2])
    ax_eq.text(0.5, 0.5, '=', fontsize=30, ha='center', va='center', fontweight='bold')
    ax_eq.axis('off')

    ax_uv = fig.add_subplot(gs[0, 4])
    # Show u as column and v as row with their sum
    u_col = u[:, None]
    v_row = v[None, :]
    combined = np.zeros((len(u) + 1, len(v) + 1))
    combined[1:, 0] = u
    combined[0, 1:] = v
    combined[1:, 1:] = A

    ax_uv.imshow(combined, cmap='RdBu_r', aspect='auto')
    ax_uv.set_title('u(i) + v(j) decomposition', fontsize=14, fontweight='bold')

    # Annotate
    for i in range(len(u)):
        ax_uv.text(0, i + 1, f'u={u[i]:.0f}', ha='center', va='center',
                   fontsize=8, fontweight='bold', color='darkblue',
                   bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    for j in range(len(v)):
        ax_uv.text(j + 1, 0, f'v={v[j]:.0f}', ha='center', va='center',
                   fontsize=8, fontweight='bold', color='darkred',
                   bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    for i in range(len(u)):
        for j in range(len(v)):
            ax_uv.text(j + 1, i + 1, f'{A[i,j]:.0f}', ha='center', va='center', fontsize=8)

    ax_uv.set_xlabel('Column index')
    ax_uv.set_ylabel('Row index')

    fig.suptitle('Tropical Rank-1 Factorization: A[i,j] = u[i] + v[j]', fontsize=16, fontweight='bold', y=1.02)
    return fig_to_base64(fig)


def viz_minor_condition():
    """Visualize the 2×2 minor condition."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Rank-1 matrix
    u = np.array([2, 5, 1, 4])
    v = np.array([3, -1, 2, 0])
    A1 = u[:, None] + v[None, :]

    ax = axes[0]
    im = ax.imshow(A1, cmap='viridis', aspect='equal')
    ax.set_title('Rank-1: All 2×2 minors vanish', fontsize=13, fontweight='bold', color='green')
    for i in range(4):
        for j in range(4):
            ax.text(j, i, f'{A1[i,j]}', ha='center', va='center', fontsize=12,
                    color='white' if A1[i,j] < 4 else 'black')

    # Highlight a 2x2 submatrix
    from matplotlib.patches import Rectangle
    rect = Rectangle((-0.5, -0.5), 2, 2, linewidth=3, edgecolor='yellow', facecolor='none')
    ax.add_patch(rect)
    ax.text(2.5, -0.8, f'{A1[0,0]}+{A1[1,1]} = {A1[0,1]}+{A1[1,0]}',
            fontsize=11, color='yellow', fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='black', alpha=0.7))

    plt.colorbar(im, ax=ax, shrink=0.8)

    # Non-rank-1 matrix
    A2 = np.array([[1, 2, 3, 4], [5, 7, 6, 8], [2, 3, 4, 5], [6, 8, 7, 10]])

    ax = axes[1]
    im = ax.imshow(A2, cmap='viridis', aspect='equal')
    ax.set_title('Not rank-1: 2×2 minor ≠ 0', fontsize=13, fontweight='bold', color='red')
    for i in range(4):
        for j in range(4):
            ax.text(j, i, f'{A2[i,j]}', ha='center', va='center', fontsize=12,
                    color='white' if A2[i,j] < 5 else 'black')

    rect = Rectangle((-0.5, -0.5), 2, 2, linewidth=3, edgecolor='red', facecolor='none')
    ax.add_patch(rect)
    ax.text(2.5, -0.8, f'{A2[0,0]}+{A2[1,1]} ≠ {A2[0,1]}+{A2[1,0]}',
            fontsize=11, color='red', fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='black', alpha=0.7))

    plt.colorbar(im, ax=ax, shrink=0.8)

    fig.suptitle('The 2×2 Tropical Minor Test', fontsize=16, fontweight='bold')
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_gauge_freedom():
    """Visualize gauge freedom: u→u+c, v→v-c preserves A."""
    u0 = np.array([1.0, 3.0, -2.0, 5.0])
    v0 = np.array([2.0, -1.0, 4.0, 0.0, 3.0])

    shifts = [-3, -1.5, 0, 1.5, 3]

    fig, axes = plt.subplots(2, len(shifts), figsize=(15, 6),
                              gridspec_kw={'height_ratios': [1, 1]})

    for idx, c in enumerate(shifts):
        u = u0 + c
        v = v0 - c

        axes[0, idx].bar(range(len(u)), u, color='steelblue', alpha=0.8)
        axes[0, idx].set_title(f'c = {c}', fontsize=11, fontweight='bold')
        axes[0, idx].set_ylim(-6, 9)
        axes[0, idx].set_ylabel('u[i]' if idx == 0 else '')
        axes[0, idx].axhline(y=0, color='gray', linewidth=0.5)

        axes[1, idx].bar(range(len(v)), v, color='coral', alpha=0.8)
        axes[1, idx].set_ylim(-6, 9)
        axes[1, idx].set_ylabel('v[j]' if idx == 0 else '')
        axes[1, idx].axhline(y=0, color='gray', linewidth=0.5)

    fig.suptitle('Gauge Freedom: u → u+c, v → v−c  (same matrix A[i,j] = u[i]+v[j])',
                 fontsize=15, fontweight='bold')
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_residual_heatmap():
    """Show the residual when projecting a non-rank-1 matrix to rank-1."""
    np.random.seed(42)

    # Create a matrix that is "close" to rank-1
    u = np.array([1, 3, -1, 4, 2], dtype=float)
    v = np.array([2, -1, 3, 0, 1, -2], dtype=float)
    A_rank1 = u[:, None] + v[None, :]
    perturbation = np.random.randn(5, 6) * 1.5
    A = A_rank1 + perturbation

    # Project to rank-1
    row_means = A.mean(axis=1)
    col_means = A.mean(axis=0)
    grand_mean = A.mean()
    u_proj = row_means
    v_proj = col_means - grand_mean
    A_proj = u_proj[:, None] + v_proj[None, :]
    residual = A - A_proj

    fig, axes = plt.subplots(1, 3, figsize=(15, 4))

    titles = ['Original A', 'Best rank-1 approx A*', 'Residual A − A*']
    data = [A, A_proj, residual]
    cmaps = ['RdBu_r', 'RdBu_r', 'PiYG']

    for ax, d, title, cmap in zip(axes, data, titles, cmaps):
        vmax = max(abs(d.min()), abs(d.max()))
        im = ax.imshow(d, cmap=cmap, vmin=-vmax, vmax=vmax, aspect='auto')
        ax.set_title(title, fontsize=13, fontweight='bold')
        plt.colorbar(im, ax=ax, shrink=0.8)
        for i in range(d.shape[0]):
            for j in range(d.shape[1]):
                ax.text(j, i, f'{d[i,j]:.1f}', ha='center', va='center', fontsize=8)

    fro_norm = np.linalg.norm(residual, 'fro')
    rel_res = fro_norm / np.linalg.norm(A, 'fro')
    fig.suptitle(f'Rank-1 Projection: ||residual||/||A|| = {rel_res:.3f}',
                 fontsize=15, fontweight='bold')
    plt.tight_layout()
    return fig_to_base64(fig)


if __name__ == '__main__':
    print("Generating visualizations...")

    v1 = viz_factorization()
    print(f"  factorization: {len(v1)} chars")

    v2 = viz_minor_condition()
    print(f"  minor_condition: {len(v2)} chars")

    v3 = viz_gauge_freedom()
    print(f"  gauge_freedom: {len(v3)} chars")

    v4 = viz_residual_heatmap()
    print(f"  residual_heatmap: {len(v4)} chars")

    # Save for reference
    with open('viz_data.txt', 'w') as f:
        f.write(f"factorization: {len(v1)} chars\n")
        f.write(f"minor_condition: {len(v2)} chars\n")
        f.write(f"gauge_freedom: {len(v3)} chars\n")
        f.write(f"residual_heatmap: {len(v4)} chars\n")

    print("Done!")
