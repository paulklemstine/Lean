#!/usr/bin/env python3
"""
Tropical Matrix Algebra — Real-World Applications

Demonstrates practical applications of tropical path algebra:
1. Critical path analysis in project scheduling
2. Network routing (longest reliable path)
3. Tropical neural network propagation
4. Dynamic programming via matrix powers
"""

import numpy as np
from algorithms import tropical_multiply, tropical_power, find_optimal_walk


# ──────────────────────────────────────────────────────────────────
# Application 1: Critical Path Method (Project Scheduling)
# ──────────────────────────────────────────────────────────────────

def critical_path_analysis():
    """
    Model project scheduling as tropical matrix power computation.

    Tasks are vertices; edge weights are task durations.
    The tropical power gives the longest (critical) path duration,
    which determines the minimum project completion time.
    """
    print("=" * 60)
    print("APPLICATION 1: Critical Path Analysis (Project Scheduling)")
    print("=" * 60)

    # 5 project milestones: Start(0), Design(1), Build(2), Test(3), Deploy(4)
    # Edge weights = task durations (days)
    INF = -1e18
    W = np.array([
        [INF, 5,   3,   INF, INF],  # Start → Design(5d), Start → Build(3d)
        [INF, INF, 2,   7,   INF],  # Design → Build(2d), Design → Test(7d)
        [INF, INF, INF, 4,   INF],  # Build → Test(4d)
        [INF, INF, INF, INF, 3  ],  # Test → Deploy(3d)
        [INF, INF, INF, INF, INF],  # Deploy (sink)
    ], dtype=float)

    labels = ["Start", "Design", "Build", "Test", "Deploy"]

    print("\nProject dependency graph (edge = task, weight = duration in days):")
    for i in range(5):
        for j in range(5):
            if W[i, j] > -1e10:
                print(f"  {labels[i]} → {labels[j]}: {W[i,j]:.0f} days")

    # Tropical powers reveal longest paths of each length
    print("\nCritical path analysis via tropical powers:")
    current = W.copy()
    for step in range(1, 5):
        if current[0, 4] > -1e10:
            print(f"  Length-{step+1} paths: Start→Deploy critical duration = "
                  f"{current[0,4]:.0f} days")
        current = tropical_multiply(current, W)

    # Find the actual critical path
    # The longest path from Start to Deploy determines min completion time
    best_duration = -np.inf
    best_path = None
    for length in range(2, 6):
        walk, weight = find_optimal_walk(W, length, 0, 4)
        if weight > best_duration:
            best_duration = weight
            best_path = walk

    if best_path:
        path_names = " → ".join(labels[v] for v in best_path)
        print(f"\n  Critical path: {path_names}")
        print(f"  Minimum project duration: {best_duration:.0f} days")


# ──────────────────────────────────────────────────────────────────
# Application 2: Network Reliability (Max Bandwidth Path)
# ──────────────────────────────────────────────────────────────────

def network_routing():
    """
    Find maximum-bandwidth paths in a communication network.

    Edge weights = log(bandwidth). Tropical max-plus finds the path
    that maximizes total log-bandwidth = maximizes bandwidth product.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Network Routing (Max Bandwidth Path)")
    print("=" * 60)

    # 4 network nodes with bandwidth capacities on links
    # Using log-bandwidth as weights
    bandwidths = np.array([
        [0, 100, 50, 0],
        [100, 0, 80, 30],
        [50, 80, 0, 90],
        [0, 30, 90, 0]
    ], dtype=float)

    W = np.where(bandwidths > 0, np.log(bandwidths), -np.inf)
    labels = ["Server A", "Server B", "Server C", "Server D"]

    print("\nNetwork topology (bandwidth in Mbps):")
    for i in range(4):
        for j in range(i + 1, 4):
            if bandwidths[i, j] > 0:
                print(f"  {labels[i]} ↔ {labels[j]}: {bandwidths[i,j]:.0f} Mbps")

    # Multi-hop routing via tropical powers
    print("\nMax-bandwidth paths (via tropical powers):")
    for length in range(1, 4):
        Wm = tropical_power(W, length - 1)
        for i in range(4):
            for j in range(i + 1, 4):
                if Wm[i, j] > -1e10:
                    bw = np.exp(Wm[i, j])
                    print(f"  {labels[i]}→{labels[j]} ({length} hops): "
                          f"bandwidth = {bw:.0f} Mbps")


# ──────────────────────────────────────────────────────────────────
# Application 3: Tropical Neural Network Layer
# ──────────────────────────────────────────────────────────────────

def tropical_neural_network():
    """
    Demonstrate a tropical neural network layer.

    In a tropical network, each layer computes:
      output[j] = max_k (weight[j,k] + input[k])

    This is exactly tropical matrix-vector multiplication.
    Multi-layer propagation = tropical matrix power applied to input.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Tropical Neural Network Propagation")
    print("=" * 60)

    # 3-node network, 2 layers with same weights
    W = np.array([
        [1.0, -0.5, 2.0],
        [0.5, 1.5, -1.0],
        [-1.0, 3.0, 0.0]
    ])

    input_vec = np.array([1.0, 2.0, -1.0])

    print(f"\nWeight matrix W:\n{W}")
    print(f"Input: {input_vec}")

    # Layer 1: tropical matrix-vector multiply
    layer1 = np.array([max(W[j, k] + input_vec[k] for k in range(3)) for j in range(3)])
    print(f"\nAfter layer 1 (max_k(W[j,k] + x[k])):")
    print(f"  {layer1}")
    for j in range(3):
        terms = [f"({W[j,k]:.1f}+{input_vec[k]:.1f})" for k in range(3)]
        vals = [W[j, k] + input_vec[k] for k in range(3)]
        best_k = np.argmax(vals)
        print(f"  node {j}: max({', '.join(terms)}) = {layer1[j]:.1f} (via input {best_k})")

    # Layer 2
    layer2 = np.array([max(W[j, k] + layer1[k] for k in range(3)) for j in range(3)])
    print(f"\nAfter layer 2:")
    print(f"  {layer2}")

    # Compare with tropical power
    W2 = tropical_multiply(W, W)
    direct = np.array([max(W2[j, k] + input_vec[k] for k in range(3)) for j in range(3)])
    print(f"\nDirect via W² ⊗ x:")
    print(f"  {direct}")
    print(f"Match: {np.allclose(layer2, direct)} ✓")
    print("\n→ Multi-layer tropical propagation = tropical power × input")


# ──────────────────────────────────────────────────────────────────
# Application 4: Dynamic Programming (Viterbi-style)
# ──────────────────────────────────────────────────────────────────

def viterbi_decoding():
    """
    Viterbi algorithm as tropical matrix power.

    Hidden Markov Model with 3 states, finding the most likely
    state sequence via tropical (max-plus) matrix multiplication.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Viterbi Decoding via Tropical Algebra")
    print("=" * 60)

    # Transition log-probabilities
    T = np.array([
        [-0.5, -1.0, -2.0],
        [-1.5, -0.3, -1.2],
        [-2.0, -0.8, -0.4]
    ])

    states = ["Sunny", "Cloudy", "Rainy"]
    print("\nTransition log-probabilities:")
    for i in range(3):
        for j in range(3):
            print(f"  {states[i]} → {states[j]}: {T[i,j]:.1f}")

    print("\nMost likely state sequences via tropical powers:")
    for steps in range(1, 5):
        Tm = tropical_power(T, steps - 1)
        print(f"\n  {steps}-step transitions (log-probability of best path):")
        for i in range(3):
            best_j = np.argmax(Tm[i])
            print(f"    {states[i]} → {states[best_j]}: {Tm[i, best_j]:.2f}")


# ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    critical_path_analysis()
    network_routing()
    tropical_neural_network()
    viterbi_decoding()
    print("\n" + "=" * 60)
    print("ALL APPLICATION DEMONSTRATIONS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Matrix Algebra and Graph Path Semantics — Demonstrations

This script demonstrates the core theorems connecting tropical (max-plus)
matrix algebra to weighted directed graph path optimization.
"""

import numpy as np
from itertools import product as cartesian_product

# ──────────────────────────────────────────────────────────────────
# Core Definitions
# ──────────────────────────────────────────────────────────────────

def trop_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix multiplication: (A ⊗ B)_{ij} = max_k (A_{ik} + B_{kj})."""
    n = A.shape[0]
    C = np.full((n, n), -np.inf)
    for i in range(n):
        for j in range(n):
            C[i, j] = max(A[i, k] + B[k, j] for k in range(n))
    return C


def trop_pow(W: np.ndarray, m: int) -> np.ndarray:
    """Tropical matrix power: tropPow W m.
    m=0 returns W itself (length-1 walks).
    m=k returns the (k+1)-fold tropical product."""
    if m == 0:
        return W.copy()
    result = W.copy()
    for _ in range(m):
        result = trop_mul(result, W)
    return result


def all_walks(n: int, length: int, i: int, j: int):
    """Generate all walks of a given length from i to j.
    A walk of length m visits m+1 vertices."""
    if length == 1:
        yield [i, j]
        return
    for intermediates in cartesian_product(range(n), repeat=length - 1):
        walk = [i] + list(intermediates) + [j]
        yield walk


def walk_weight(W: np.ndarray, walk: list) -> float:
    """Total weight of a walk: sum of edge weights along the walk."""
    return sum(W[walk[t], walk[t + 1]] for t in range(len(walk) - 1))


def max_walk_weight(W: np.ndarray, m: int, i: int, j: int) -> float:
    """Maximum weight over all walks of length m from i to j."""
    return max(walk_weight(W, w) for w in all_walks(W.shape[0], m, i, j))


# ──────────────────────────────────────────────────────────────────
# Demo 1: Tropical Product = Max Path Weight (Length-2 Paths)
# ──────────────────────────────────────────────────────────────────

print("=" * 70)
print("DEMO 1: Tropical Product = Max Weight over Length-2 Paths")
print("=" * 70)

np.random.seed(42)
n = 4
A = np.random.randint(-5, 10, size=(n, n)).astype(float)
B = np.random.randint(-5, 10, size=(n, n)).astype(float)

print(f"\nMatrix A ({n}×{n}):")
print(A)
print(f"\nMatrix B ({n}×{n}):")
print(B)

C = trop_mul(A, B)
print(f"\nTropical Product A ⊗ B:")
print(C)

print("\nVerification (entry-by-entry):")
for i in range(n):
    for j in range(n):
        max_path = max(A[i, k] + B[k, j] for k in range(n))
        best_k = max(range(n), key=lambda k: A[i, k] + B[k, j])
        assert abs(C[i, j] - max_path) < 1e-10
        print(f"  (A⊗B)[{i},{j}] = {C[i,j]:.0f}  "
              f"= max_k(A[{i},k]+B[k,{j}])  "
              f"(best via k={best_k}: {A[i,best_k]:.0f}+{B[best_k,j]:.0f}={max_path:.0f}) ✓")

# ──────────────────────────────────────────────────────────────────
# Demo 2: Associativity of Tropical Multiplication
# ──────────────────────────────────────────────────────────────────

print("\n" + "=" * 70)
print("DEMO 2: Associativity (A ⊗ B) ⊗ C = A ⊗ (B ⊗ C)")
print("=" * 70)

D = np.random.randint(-5, 10, size=(n, n)).astype(float)
left = trop_mul(trop_mul(A, B), D)
right = trop_mul(A, trop_mul(B, D))
print(f"\n(A ⊗ B) ⊗ C:\n{left}")
print(f"\nA ⊗ (B ⊗ C):\n{right}")
print(f"\nAssociativity holds: {np.allclose(left, right)} ✓")

# ──────────────────────────────────────────────────────────────────
# Demo 3: Bellman Recurrence
# ──────────────────────────────────────────────────────────────────

print("\n" + "=" * 70)
print("DEMO 3: Bellman Optimality Recurrence")
print("=" * 70)

W = np.array([
    [0, 3, -1, 7],
    [2, 0, 5, -2],
    [4, 1, 0, 6],
    [-3, 8, 2, 0]
], dtype=float)

print(f"\nWeight matrix W ({n}×{n}):")
print(W)

for m in range(1, 5):
    Wm = trop_pow(W, m - 1)  # tropPow W (m-1) gives length-m walks
    print(f"\ntropPow W {m-1} (optimal length-{m} walk weights):")
    print(Wm)

    # Verify Bellman recurrence for m >= 2
    if m >= 2:
        Wm_prev = trop_pow(W, m - 2)
        for i in range(n):
            for j in range(n):
                bellman_val = max(Wm_prev[i, k] + W[k, j] for k in range(n))
                assert abs(Wm[i, j] - bellman_val) < 1e-10
        print(f"  Bellman recurrence verified ✓")

# ──────────────────────────────────────────────────────────────────
# Demo 4: Tropical Powers = Max Walk Weights (Main Theorem)
# ──────────────────────────────────────────────────────────────────

print("\n" + "=" * 70)
print("DEMO 4: tropPow W m = max walk weight (Main Theorem)")
print("=" * 70)

n_small = 3
W_small = np.array([
    [1, 3, -2],
    [4, -1, 5],
    [2, 0, 3]
], dtype=float)
print(f"\nWeight matrix ({n_small}×{n_small}):")
print(W_small)

for m in range(1, 5):
    Wm = trop_pow(W_small, m - 1)
    print(f"\nLength-{m} walks (tropPow W {m-1}):")
    all_match = True
    for i in range(n_small):
        for j in range(n_small):
            # Enumerate all walks of length m
            walks = list(all_walks(n_small, m, i, j))
            weights = [walk_weight(W_small, w) for w in walks]
            max_w = max(weights)
            best_walk = walks[weights.index(max_w)]
            assert abs(Wm[i, j] - max_w) < 1e-10, \
                f"Mismatch at ({i},{j}): tropPow={Wm[i,j]}, max_walk={max_w}"
            if i == 0:
                walk_str = " → ".join(map(str, best_walk))
                print(f"  ({i},{j}): weight={max_w:.0f}, "
                      f"best walk: {walk_str} ({len(walks)} walks checked)")
    print(f"  All entries match ✓ ({n_small**m} walks per entry)")

# ──────────────────────────────────────────────────────────────────
# Demo 5: Boolean Reachability
# ──────────────────────────────────────────────────────────────────

print("\n" + "=" * 70)
print("DEMO 5: Boolean Reachability as Tropical Semantics")
print("=" * 70)

# Adjacency matrix (True = edge exists)
adj = np.array([
    [False, True, False, False],
    [False, False, True, False],
    [False, False, False, True],
    [True, False, False, False]
], dtype=bool)

print("\nAdjacency matrix (cycle 0→1→2→3→0):")
print(adj.astype(int))

# Encode: True→0, False→-inf
NEG_INF = -1e18
W_bool = np.where(adj, 0.0, NEG_INF)

print("\nTropical encoding (0 = edge, -∞ = no edge):")
print(np.where(W_bool > -1e10, W_bool, "  -∞"))

for m in range(1, 6):
    Wm = trop_pow(W_bool, m - 1)
    print(f"\nLength-{m} reachability:")
    for i in range(4):
        reachable = [j for j in range(4) if Wm[i, j] > -1e10]
        print(f"  From {i}: reachable = {reachable}")

# ──────────────────────────────────────────────────────────────────
# Demo 6: Tropical Idempotence (max a a = a)
# ──────────────────────────────────────────────────────────────────

print("\n" + "=" * 70)
print("DEMO 6: Tropical Idempotence (Catalog Connection)")
print("=" * 70)
print("\nmax(a, a) = a  [tropical_mirror_theorem]")
for a in [-3.7, 0, 2.5, 100]:
    print(f"  max({a}, {a}) = {max(a, a)} ✓")

print("\n" + "=" * 70)
print("ALL DEMONSTRATIONS COMPLETED SUCCESSFULLY")
print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Matrix Algebra — Visualizations

Generates publication-quality figures illustrating tropical path algebra concepts.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from algorithms import tropical_multiply, tropical_power, encode_boolean_graph
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


def viz_tropical_vs_standard():
    """Compare standard and tropical matrix multiplication."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    A = np.array([[1, 3], [4, 2]], dtype=float)
    B = np.array([[5, -1], [0, 7]], dtype=float)

    # Standard product
    C_std = A @ B
    # Tropical product
    C_trop = tropical_multiply(A, B)

    for ax, mat, title in [
        (axes[0], A, "Matrix A"),
        (axes[1], B, "Matrix B"),
        (axes[2], C_trop, "A ⊗ B (Tropical)")
    ]:
        im = ax.imshow(mat, cmap='RdYlGn', aspect='equal')
        for i in range(mat.shape[0]):
            for j in range(mat.shape[1]):
                ax.text(j, i, f'{mat[i,j]:.0f}', ha='center', va='center',
                       fontsize=20, fontweight='bold')
        ax.set_title(title, fontsize=14, fontweight='bold')
        ax.set_xticks(range(mat.shape[1]))
        ax.set_yticks(range(mat.shape[0]))

    fig.suptitle('Tropical Matrix Multiplication\n'
                 '(A⊗B)ᵢⱼ = maxₖ(Aᵢₖ + Bₖⱼ)',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_tropical_multiply.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_path_weights():
    """Visualize how tropical powers compute optimal walk weights."""
    W = np.array([
        [0, 3, -2],
        [4, -1, 5],
        [2, 0, 3]
    ], dtype=float)

    fig, axes = plt.subplots(2, 3, figsize=(16, 10))

    # Show the weight matrix and its tropical powers
    matrices = [W] + [tropical_power(W, m) for m in range(1, 5)]
    titles = ['W (length-1 walks)', 'W² (length-2)', 'W³ (length-3)',
              'W⁴ (length-4)', 'W⁵ (length-5)']

    for idx, (mat, title) in enumerate(zip(matrices, titles)):
        ax = axes[idx // 3, idx % 3]
        im = ax.imshow(mat, cmap='viridis', aspect='equal',
                      vmin=min(m.min() for m in matrices),
                      vmax=max(m.max() for m in matrices))
        for i in range(3):
            for j in range(3):
                ax.text(j, i, f'{mat[i,j]:.0f}', ha='center', va='center',
                       fontsize=14, fontweight='bold', color='white')
        ax.set_title(title, fontsize=12, fontweight='bold')
        ax.set_xticks(range(3))
        ax.set_yticks(range(3))
        ax.set_xlabel('Target vertex')
        ax.set_ylabel('Source vertex')

    axes[1, 2].axis('off')
    axes[1, 2].text(0.5, 0.5,
                    'Each entry equals the\nmaximum total weight\nover all directed walks\n'
                    'of the given length\nfrom source to target.\n\n'
                    'Proved formally:\ntropPow_eq_sup_pathWeight',
                    ha='center', va='center', fontsize=12,
                    bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    fig.suptitle('Tropical Powers = Optimal Walk Weights\n'
                 '(Main Theorem: tropPow_eq_sup_pathWeight)',
                 fontsize=16, fontweight='bold')
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_path_weights.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_reachability():
    """Visualize Boolean reachability via tropical encoding."""
    # Directed cycle: 0→1→2→3→0
    adj = np.array([
        [False, True, False, False, False],
        [False, False, True, False, False],
        [False, False, False, True, False],
        [False, False, False, False, True],
        [True, False, False, False, False]
    ])

    n = 5
    NEG_INF = -1e18
    W = np.where(adj, 0.0, NEG_INF)

    fig, axes = plt.subplots(1, 5, figsize=(20, 4))

    for step in range(5):
        ax = axes[step]
        Wm = tropical_power(W, step)
        reach = (Wm > -1e10).astype(int)

        ax.imshow(reach, cmap='Greens', vmin=0, vmax=1, aspect='equal')
        for i in range(n):
            for j in range(n):
                color = 'white' if reach[i, j] else 'gray'
                symbol = '✓' if reach[i, j] else '✗'
                ax.text(j, i, symbol, ha='center', va='center',
                       fontsize=14, color=color, fontweight='bold')
        ax.set_title(f'Length {step + 1}', fontsize=12, fontweight='bold')
        ax.set_xticks(range(n))
        ax.set_yticks(range(n))

    fig.suptitle('Boolean Reachability on 5-Cycle (0→1→2→3→4→0)\n'
                 'Green = reachable in exactly k steps',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_reachability.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_bellman_convergence():
    """Visualize Bellman recurrence convergence for a specific (i,j) pair."""
    W = np.array([
        [0, 3, -1, 7],
        [2, 0, 5, -2],
        [4, 1, 0, 6],
        [-3, 8, 2, 0]
    ], dtype=float)

    max_steps = 8
    values = {(i, j): [] for i in range(4) for j in range(4)}

    for m in range(max_steps):
        Wm = tropical_power(W, m)
        for i in range(4):
            for j in range(4):
                values[(i, j)].append(Wm[i, j])

    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    pairs = [(0, 1), (0, 3), (1, 2), (2, 0)]
    colors = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63']

    for idx, (i, j) in enumerate(pairs):
        ax = axes[idx // 2, idx % 2]
        steps = list(range(1, max_steps + 1))
        vals = values[(i, j)]
        ax.plot(steps, vals, 'o-', color=colors[idx], linewidth=2, markersize=8)
        ax.set_xlabel('Walk length', fontsize=12)
        ax.set_ylabel('Optimal walk weight', fontsize=12)
        ax.set_title(f'Vertex {i} → Vertex {j}', fontsize=14, fontweight='bold')
        ax.grid(True, alpha=0.3)
        ax.set_xticks(steps)

    fig.suptitle('Bellman Recurrence: Optimal Walk Weights vs Length\n'
                 'Each point = max weight over all walks of that length',
                 fontsize=16, fontweight='bold')
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_bellman.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_1 = viz_tropical_vs_standard()
    print("  ✓ Tropical multiplication comparison")
    b64_2 = viz_path_weights()
    print("  ✓ Path weights heatmap")
    b64_3 = viz_reachability()
    print("  ✓ Boolean reachability")
    b64_4 = viz_bellman_convergence()
    print("  ✓ Bellman convergence")
    print("\nAll visualizations saved as PNG files.")

    # Save base64 data for PACKAGE.json
    import json
    viz_data = [
        {"name": "Tropical Matrix Multiplication", "data": b64_1},
        {"name": "Optimal Walk Weights (Main Theorem)", "data": b64_2},
        {"name": "Boolean Reachability", "data": b64_3},
        {"name": "Bellman Recurrence Convergence", "data": b64_4}
    ]
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump(viz_data, f)
    print("Visualization data saved to viz_data.json")
