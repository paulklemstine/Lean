#!/usr/bin/env python3
"""
Tropical Circuit Lower Bounds — Applications

Demonstrates real-world applications of tropical spectral theory:
1. Network routing depth analysis
2. Dynamic programming circuit complexity
3. Supply chain propagation bounds
"""

import numpy as np
from algorithms import (tropical_mul, tropical_pow, tropical_perm,
                         depth_lower_bound_from_perm, depth_lower_bound_from_spectral_gap)


def application_network_routing():
    """
    Application 1: Network Routing Depth Analysis

    In a communication network, data must propagate from sources to destinations
    through relay layers. Each relay adds latency (edge weight). The tropical
    circuit framework gives provable lower bounds on the number of relay layers
    needed to achieve a target end-to-end latency.
    """
    print("=" * 70)
    print("APPLICATION 1: Network Routing — Relay Layer Lower Bounds")
    print("=" * 70)

    # Network with 4 nodes: 2 sources, 2 destinations
    # Latency matrix (microseconds)
    latency = np.array([
        [10, 5, 20, 15],  # Node 0 connections
        [8, 12, 3, 25],   # Node 1 connections
        [15, 7, 8, 4],    # Node 2 connections
        [20, 10, 6, 9]    # Node 3 connections
    ], dtype=float)

    print(f"\nNetwork latency matrix (μs):")
    print(latency.astype(int))

    perm_val, best_perm = tropical_perm(latency)
    print(f"\nTropical permanent = {int(perm_val)} μs")
    print(f"  Optimal assignment: {best_perm}")
    print(f"  Each source-destination pair uses a dedicated relay path")

    for max_relay_latency in [5, 3, 2, 1]:
        depth = depth_lower_bound_from_perm(latency, max_relay_latency)
        print(f"\n  With max relay latency = {max_relay_latency} μs:")
        print(f"    Minimum relay layers needed: d ≥ {depth}")
        print(f"    (from tropPerm/(n×W) = {perm_val}/{4*max_relay_latency} = {perm_val/(4*max_relay_latency):.1f})")


def application_dynamic_programming():
    """
    Application 2: Dynamic Programming Circuit Complexity

    Many optimization problems use dynamic programming, which corresponds
    to tropical matrix computation. The depth of the DP circuit determines
    the number of sequential stages. Our theorems give lower bounds on
    how many stages are needed.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Dynamic Programming — Stage Lower Bounds")
    print("=" * 70)

    # Transition cost matrix for a shortest-path DP
    # M[i][j] = cost of transitioning from state i to state j
    n = 5
    np.random.seed(42)
    transition = np.random.randint(2, 15, size=(n, n)).astype(float)

    print(f"\nTransition cost matrix ({n} states):")
    print(transition.astype(int))

    min_w = np.min(transition)
    max_W = np.max(transition)
    perm_val, _ = tropical_perm(transition)

    print(f"\nMin entry (spectral gap): {int(min_w)}")
    print(f"Max entry: {int(max_W)}")
    print(f"Tropical permanent: {int(perm_val)}")

    # Track how costs grow with DP stages
    print(f"\nCost evolution over DP stages:")
    for k in range(6):
        Mk = tropical_pow(transition, k)
        min_cost = np.min(Mk)
        max_cost = np.max(Mk)
        min_diag = min(Mk[i, i] for i in range(n))
        print(f"  Stage {k+1}: min_cost={int(min_cost):4d}, max_cost={int(max_cost):4d}, "
              f"min_cycle={int(min_diag):4d}, "
              f"bounds: [{int((k+1)*min_w)}, {int((k+1)*max_W)}]")

    target_cost = 30
    gap_bound = depth_lower_bound_from_spectral_gap(transition, target_cost)
    print(f"\n  To achieve total cost ≤ {target_cost}:")
    print(f"    Spectral gap bound: at most {gap_bound+1} stages needed")
    print(f"    (from B/w = {target_cost}/{int(min_w)} = {target_cost/min_w:.1f})")


def application_supply_chain():
    """
    Application 3: Supply Chain Propagation Bounds

    In a supply chain, goods propagate through processing layers.
    Each layer adds cost. The tropical framework tells us:
    - Minimum layers to achieve a target total cost
    - Maximum throughput given layer constraints
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Supply Chain — Processing Layer Bounds")
    print("=" * 70)

    # Cost matrix: processing costs between supply chain stages
    # M[i][j] = cost of routing item from facility i to facility j
    cost_matrix = np.array([
        [5, 2, 8, 12],
        [3, 6, 4, 9],
        [7, 1, 5, 3],
        [10, 8, 2, 7]
    ], dtype=float)

    print(f"\nFacility-to-facility cost matrix:")
    print(cost_matrix.astype(int))

    perm_val, best_assign = tropical_perm(cost_matrix)
    print(f"\nOptimal facility assignment (tropical permanent): ${int(perm_val)}")
    print(f"  Assignment: {best_assign}")
    for i, j in enumerate(best_assign):
        print(f"    Source {i} → Destination {j}: cost ${int(cost_matrix[i,j])}")

    print(f"\nProcessing depth analysis (cost per processing layer):")
    for cap in [1, 2, 3, 5]:
        depth = depth_lower_bound_from_perm(cost_matrix, cap)
        total_capacity = 4 * (depth + 1) * cap
        print(f"  Max cost/layer = ${cap}: need ≥ {depth+1} layers "
              f"(total capacity: ${total_capacity})")


if __name__ == "__main__":
    application_network_routing()
    application_dynamic_programming()
    application_supply_chain()
    print("\n" + "=" * 70)
    print("All applications demonstrated successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Circuit Lower Bounds — Interactive Demo

Demonstrates the core theorems connecting tropical (min-plus) matrix algebra
to circuit depth lower bounds. All computations are self-contained.
"""

import numpy as np
from itertools import permutations


def tropical_mul(A, B):
    """Min-plus matrix multiplication: (A ⊗ B)[i,j] = min_k (A[i,k] + B[k,j])."""
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C


def tropical_pow(M, k):
    """Compute M^⊗(k+1): tropical product of k+1 copies of M.
    tropPow M 0 = M, tropPow M k = tropMul(tropPow M (k-1), M)."""
    result = M.copy()
    for _ in range(k):
        result = tropical_mul(result, M)
    return result


def tropical_perm(M):
    """Tropical permanent: min over all permutations σ of Σ_i M[i, σ(i)]."""
    n = M.shape[0]
    best = np.inf
    best_perm = None
    for perm in permutations(range(n)):
        cost = sum(M[i, perm[i]] for i in range(n))
        if cost < best:
            best = cost
            best_perm = perm
    return best, best_perm


def max_entry(M):
    """Maximum finite entry of M."""
    finite = M[np.isfinite(M)]
    return np.max(finite) if len(finite) > 0 else 0


def min_entry(M):
    """Minimum entry of M."""
    return np.min(M)


def min_diag(M):
    """Minimum diagonal entry."""
    return min(M[i, i] for i in range(M.shape[0]))


# ══════════════════════════════════════════════════════════════════════════════
# DEMO 1: Basic Tropical Matrix Operations
# ══════════════════════════════════════════════════════════════════════════════

print("=" * 70)
print("DEMO 1: Tropical (Min-Plus) Matrix Multiplication")
print("=" * 70)

A = np.array([[2, 5], [3, 4]], dtype=float)
B = np.array([[1, 3], [2, 6]], dtype=float)
C = tropical_mul(A, B)

print(f"\nA =\n{A}")
print(f"\nB =\n{B}")
print(f"\nA ⊗ B (min-plus product) =\n{C}")
print(f"\nVerification: C[0,0] = min(A[0,0]+B[0,0], A[0,1]+B[1,0])")
print(f"            = min({A[0,0]}+{B[0,0]}, {A[0,1]}+{B[1,0]})")
print(f"            = min({A[0,0]+B[0,0]}, {A[0,1]+B[1,0]}) = {C[0,0]}")


# ══════════════════════════════════════════════════════════════════════════════
# DEMO 2: Path Semantics of Tropical Powers
# ══════════════════════════════════════════════════════════════════════════════

print("\n" + "=" * 70)
print("DEMO 2: Path Semantics — Tropical Powers Encode Shortest Walks")
print("=" * 70)

# Weighted graph adjacency matrix
M = np.array([
    [10, 1, 100],
    [100, 20, 2],
    [3, 100, 30]
], dtype=float)

print(f"\nWeighted graph M (3 nodes):")
print(f"  Edge 0→1: weight {int(M[0,1])}")
print(f"  Edge 1→2: weight {int(M[1,2])}")
print(f"  Edge 2→0: weight {int(M[2,0])}")
print(f"  (and self-loops, other edges with high weight)")

for k in range(4):
    Mk = tropical_pow(M, k)
    print(f"\ntropPow M {k} (min-cost {k+1}-edge walks):")
    for i in range(3):
        for j in range(3):
            print(f"  [{i}→{j}]: {int(Mk[i,j]):4d}", end="")
        print()

print(f"\nOptimal 3-edge cycle 0→1→2→0: cost = {int(M[0,1])}+{int(M[1,2])}+{int(M[2,0])} = {int(M[0,1]+M[1,2]+M[2,0])}")
M2 = tropical_pow(M, 2)
print(f"tropPow M 2 [0,0] = {int(M2[0,0])} ✓ (matches!)")


# ══════════════════════════════════════════════════════════════════════════════
# DEMO 3: Tropical Permanent and Depth Lower Bounds
# ══════════════════════════════════════════════════════════════════════════════

print("\n" + "=" * 70)
print("DEMO 3: Tropical Permanent → Circuit Depth Lower Bounds")
print("=" * 70)

M_ex = np.array([[5, 3], [4, 6]], dtype=float)
perm_val, best_perm = tropical_perm(M_ex)
print(f"\nMatrix M = [[5, 3], [4, 6]]")
print(f"Tropical permanent = {int(perm_val)} (achieved by permutation {best_perm})")
print(f"  Identity: {int(M_ex[0,0])}+{int(M_ex[1,1])} = {int(M_ex[0,0]+M_ex[1,1])}")
print(f"  Swap:     {int(M_ex[0,1])}+{int(M_ex[1,0])} = {int(M_ex[0,1]+M_ex[1,0])}")

n = M_ex.shape[0]
W = max_entry(M_ex)
print(f"\nn = {n}, maxEntry = {int(W)}")
print(f"Theorem: tropPerm(M) ≤ n × (d+1) × W for any layered realization of depth d")
print(f"  {int(perm_val)} ≤ {n} × (d+1) × {int(W)}")
print(f"  ⟹ d+1 ≥ {int(perm_val)} / ({n} × {int(W)}) = {perm_val/(n*W):.2f}")
print(f"  ⟹ d+1 ≥ {int(np.ceil(perm_val/(n*W)))} (rounding up)")

# With weight cap W=1
W1 = 1
print(f"\nWith weight cap W = {W1}:")
print(f"  d+1 ≥ {int(perm_val)} / ({n} × {W1}) = {perm_val/(n*W1):.1f}")
print(f"  ⟹ d+1 ≥ {int(np.ceil(perm_val/(n*W1)))}, so depth d ≥ {int(np.ceil(perm_val/(n*W1)))-1}")


# ══════════════════════════════════════════════════════════════════════════════
# DEMO 4: Spectral Gap and Linear Cost Growth
# ══════════════════════════════════════════════════════════════════════════════

print("\n" + "=" * 70)
print("DEMO 4: Spectral Gap — Minimum Entry Forces Linear Cost Growth")
print("=" * 70)

M_gap = np.array([
    [5, 3, 7],
    [4, 6, 3],
    [7, 4, 5]
], dtype=float)

w = min_entry(M_gap)
print(f"\nMatrix with minEntry = {int(w)}:")
print(M_gap.astype(int))

print(f"\nTheorem: every entry of tropPow M k ≥ (k+1) × minEntry = (k+1) × {int(w)}")
for k in range(5):
    Mk = tropical_pow(M_gap, k)
    actual_min = np.min(Mk)
    bound = (k + 1) * w
    print(f"  k={k}: min entry of tropPow = {int(actual_min):4d} ≥ {int(bound):4d} = {k+1}×{int(w)}  {'✓' if actual_min >= bound else '✗'}")

print(f"\nCorollary: if tropPow M d has any entry ≤ B, then d+1 ≤ B/{int(w)} + 1")
B = 20
print(f"  Budget B = {B}: any walk achieving cost ≤ {B} needs at most {B//int(w) + 1} layers")


# ══════════════════════════════════════════════════════════════════════════════
# DEMO 5: Scaling with Matrix Size
# ══════════════════════════════════════════════════════════════════════════════

print("\n" + "=" * 70)
print("DEMO 5: Scaling — Tropical Permanent vs Matrix Dimension")
print("=" * 70)

for n in [2, 3, 4, 5, 6]:
    # Create a matrix with off-diagonal entries = 1, diagonal = n
    M_n = np.full((n, n), 1.0)
    np.fill_diagonal(M_n, float(n))

    perm_val, _ = tropical_perm(M_n)
    W = max_entry(M_n)
    depth_bound = perm_val / (n * 1)  # W=1 for off-diagonal cap

    print(f"  n={n}: M has diag={n}, off-diag=1 → tropPerm={int(perm_val):3d}, "
          f"maxEntry={int(W)}, depth bound (W=1): d+1 ≥ {depth_bound:.1f}")


# ══════════════════════════════════════════════════════════════════════════════
# DEMO 6: Counterexample to MinDiag Subadditivity
# ══════════════════════════════════════════════════════════════════════════════

print("\n" + "=" * 70)
print("DEMO 6: Counterexample — MinDiag Subadditivity Fails!")
print("=" * 70)

M_counter = np.array([
    [2, 1000, 1000, 1000],
    [1000, 1000, 1, 1000],
    [1000, 1, 1000, 1000],
    [1000, 1000, 1000, 1000]
], dtype=float)

M0 = M_counter
M1 = tropical_pow(M_counter, 1)
M2 = tropical_pow(M_counter, 2)

d0 = min_diag(M0)
d1 = min_diag(M1)
d2 = min_diag(M2)

print(f"\nM = diag(2,1000,1000,1000) with edges 1↔2 of weight 1")
print(f"minDiag(M^⊗1) = {int(d0)}  (cheapest 1-edge self-loop at vertex 0)")
print(f"minDiag(M^⊗2) = {int(d1)}  (cheapest 2-edge cycle: 1→2→1, cost 2)")
print(f"minDiag(M^⊗3) = {int(d2)}  (cheapest 3-edge cycle: 0→0→0→0, cost 6)")
print(f"\nSubadditivity would require: minDiag(M^⊗3) ≤ minDiag(M^⊗1) + minDiag(M^⊗2)")
print(f"  {int(d2)} ≤ {int(d0)} + {int(d1)} = {int(d0+d1)}  → {'✓ HOLDS' if d2 <= d0+d1 else '✗ FAILS!'}")
print(f"\nThis shows different powers can achieve their minimum diagonal at different vertices,")
print(f"breaking the naive subadditivity. Our theorems carefully avoid this trap.")


# ══════════════════════════════════════════════════════════════════════════════
# DEMO 7: Entry Bound Theorem Verification
# ══════════════════════════════════════════════════════════════════════════════

print("\n" + "=" * 70)
print("DEMO 7: Entry Bound — tropPow M k entries ≤ (k+1) × maxEntry")
print("=" * 70)

M_bound = np.array([
    [2, 5, 1],
    [4, 3, 6],
    [1, 2, 4]
], dtype=float)

W = max_entry(M_bound)
print(f"\nM with maxEntry = {int(W)}:")
print(M_bound.astype(int))

for k in range(5):
    Mk = tropical_pow(M_bound, k)
    actual_max = np.max(Mk)
    bound = (k + 1) * W
    print(f"  k={k}: max entry of tropPow = {int(actual_max):4d} ≤ {int(bound):4d} = {k+1}×{int(W)}  {'✓' if actual_max <= bound else '✗'}")


print("\n" + "=" * 70)
print("All demos completed successfully!")
print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all embedded content."""

import json
import base64
from pathlib import Path

# Read markdown files
article = Path('ARTICLE.md').read_text()
research_paper = Path('RESEARCH_PAPER.md').read_text()
future_directions = Path('FUTURE_DIRECTIONS.md').read_text()

# Read Lean code
lean_files = [
    'Computation/TropicalCircuitLowerBounds/Defs.lean',
    'Computation/TropicalCircuitLowerBounds/Theorems.lean',
    'Computation/TropicalCircuitLowerBounds/Spectral.lean',
]
lean_code = ""
for f in lean_files:
    lean_code += f"-- ═══ {f} ═══\n\n"
    lean_code += Path(f).read_text() + "\n\n"

# Read Python files
demo_code = Path('demo.py').read_text()
algorithms_code = Path('algorithms.py').read_text()
applications_code = Path('applications.py').read_text()

# Read visualization images as base64
viz_files = {
    'Entry Bounds': 'viz_entry_bounds.png',
    'Depth Lower Bounds': 'viz_depth_bounds.png',
    'Spectral Gap': 'viz_spectral_gap.png',
    'Counterexample': 'viz_counterexample.png',
}

visualizations = []
for name, filename in viz_files.items():
    with open(filename, 'rb') as f:
        b64 = base64.b64encode(f.read()).decode('utf-8')
    visualizations.append({
        'name': name,
        'data': f'data:image/png;base64,{b64}'
    })

# Build package
package = {
    'title': 'Circuit Lower Bounds from Tropical Spectral Theory',
    'domain': 'Computation / Complexity Theory / Tropical Algebra',
    'article': article,
    'research_paper': research_paper,
    'future_directions': future_directions,
    'demos': [
        {
            'name': 'Tropical Circuit Lower Bounds Demo',
            'code': demo_code,
        }
    ],
    'algorithms': [
        {
            'name': 'Tropical Matrix Multiplication',
            'pseudocode': 'for i,j: C[i,j] = min_k (A[i,k] + B[k,j])',
            'code': algorithms_code,
        },
        {
            'name': 'Applications',
            'pseudocode': 'Network routing, DP complexity, supply chain analysis',
            'code': applications_code,
        }
    ],
    'visualizations': visualizations,
    'lean_proofs': lean_code,
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({Path('PACKAGE.json').stat().st_size / 1024:.1f} KB)")


#!/usr/bin/env python3
"""
Tropical Circuit Lower Bounds — Visualizations

Generates publication-quality figures illustrating the key theorems.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from algorithms import tropical_pow, tropical_perm
import base64
from io import BytesIO


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 PNG."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')


def viz_entry_bounds():
    """Visualize entry bound theorem: max/min of tropPow vs (k+1)*W bounds."""
    M = np.array([[5, 3, 7], [4, 6, 3], [7, 4, 5]], dtype=float)
    W = np.max(M)
    w = np.min(M)

    ks = list(range(8))
    max_entries = []
    min_entries = []
    upper_bounds = []
    lower_bounds = []

    for k in ks:
        Mk = tropical_pow(M, k)
        max_entries.append(np.max(Mk))
        min_entries.append(np.min(Mk))
        upper_bounds.append((k + 1) * W)
        lower_bounds.append((k + 1) * w)

    fig, ax = plt.subplots(figsize=(10, 6))
    ax.fill_between(ks, lower_bounds, upper_bounds, alpha=0.15, color='blue', label='Provable bounds')
    ax.plot(ks, upper_bounds, 'b--', linewidth=2, label=f'Upper: (k+1)×{int(W)}')
    ax.plot(ks, lower_bounds, 'r--', linewidth=2, label=f'Lower: (k+1)×{int(w)}')
    ax.plot(ks, max_entries, 'bs-', linewidth=2, markersize=8, label='Actual max entry')
    ax.plot(ks, min_entries, 'ro-', linewidth=2, markersize=8, label='Actual min entry')

    ax.set_xlabel('Power index k (walk uses k+1 edges)', fontsize=14)
    ax.set_ylabel('Entry value', fontsize=14)
    ax.set_title('Tropical Power Entry Bounds\n(Theorem: entries sandwiched between linear bounds)', fontsize=14)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(ks)

    fig.savefig('viz_entry_bounds.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close()
    return b64


def viz_depth_lower_bound():
    """Visualize depth lower bound from tropical permanent."""
    ns = list(range(2, 8))
    depths_w1 = []
    depths_w2 = []
    depths_w3 = []
    perms = []

    for n in ns:
        # Create challenging matrix: off-diagonal dense, diagonal heavy
        M = np.full((n, n), 2.0)
        for i in range(n):
            M[i, (i + 1) % n] = 1.0
            M[i, i] = float(n)

        perm_val, _ = tropical_perm(M)
        perms.append(perm_val)
        depths_w1.append(max(0, int(np.ceil(perm_val / (n * 1))) - 1))
        depths_w2.append(max(0, int(np.ceil(perm_val / (n * 2))) - 1))
        depths_w3.append(max(0, int(np.ceil(perm_val / (n * 3))) - 1))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ax1.bar(ns, perms, color='steelblue', alpha=0.7, edgecolor='navy')
    ax1.set_xlabel('Matrix dimension n', fontsize=13)
    ax1.set_ylabel('Tropical permanent', fontsize=13)
    ax1.set_title('Tropical Permanent vs Dimension', fontsize=14)
    ax1.set_xticks(ns)
    ax1.grid(True, alpha=0.3, axis='y')

    x = np.array(ns)
    width = 0.25
    ax2.bar(x - width, depths_w1, width, label='W=1', color='#e74c3c', alpha=0.8)
    ax2.bar(x, depths_w2, width, label='W=2', color='#3498db', alpha=0.8)
    ax2.bar(x + width, depths_w3, width, label='W=3', color='#2ecc71', alpha=0.8)
    ax2.set_xlabel('Matrix dimension n', fontsize=13)
    ax2.set_ylabel('Depth lower bound d', fontsize=13)
    ax2.set_title('Circuit Depth Lower Bounds\n(from Theorem B: d ≥ tropPerm/(nW) − 1)', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.set_xticks(ns)
    ax2.grid(True, alpha=0.3, axis='y')

    fig.tight_layout()
    fig.savefig('viz_depth_bounds.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close()
    return b64


def viz_spectral_gap():
    """Visualize spectral gap: linear cost growth forces depth."""
    M = np.array([[5, 3, 8], [4, 7, 3], [8, 4, 6]], dtype=float)
    w = np.min(M)

    ks = list(range(10))
    min_costs = []
    min_diags = []
    for k in ks:
        Mk = tropical_pow(M, k)
        min_costs.append(np.min(Mk))
        min_diags.append(min(Mk[i, i] for i in range(3)))

    fig, ax = plt.subplots(figsize=(10, 6))

    ax.plot(ks, min_costs, 'ro-', linewidth=2, markersize=8, label='Min entry of tropPow M k')
    ax.plot(ks, min_diags, 'bs-', linewidth=2, markersize=8, label='Min diagonal (cycle cost)')
    ax.plot(ks, [(k + 1) * w for k in ks], 'g--', linewidth=2,
            label=f'Lower bound: (k+1)×{int(w)}')

    # Budget line
    B = 25
    ax.axhline(y=B, color='purple', linestyle=':', linewidth=2, label=f'Budget B = {B}')

    # Find where min_cost crosses budget
    crossing = None
    for k in ks:
        if min_costs[k] > B:
            crossing = k
            break

    if crossing:
        ax.axvline(x=crossing - 1, color='orange', linestyle='--', alpha=0.7)
        ax.annotate(f'Max depth for B={B}:\nk ≤ {crossing-1}',
                    xy=(crossing - 1, B), fontsize=11,
                    xytext=(crossing + 1, B + 5),
                    arrowprops=dict(arrowstyle='->', color='orange'),
                    color='orange', fontweight='bold')

    ax.set_xlabel('Power index k (walk uses k+1 edges)', fontsize=14)
    ax.set_ylabel('Cost', fontsize=14)
    ax.set_title('Spectral Gap: Minimum Entry Forces Linear Cost Growth\n'
                 '(walks cannot be cheap AND deep)', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(ks)

    fig.savefig('viz_spectral_gap.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close()
    return b64


def viz_counterexample():
    """Visualize the counterexample to minDiag subadditivity."""
    M = np.array([
        [2, 1000, 1000, 1000],
        [1000, 1000, 1, 1000],
        [1000, 1, 1000, 1000],
        [1000, 1000, 1000, 1000]
    ], dtype=float)

    ks = list(range(8))
    min_diags = []
    for k in ks:
        Mk = tropical_pow(M, k)
        min_diags.append(min(Mk[i, i] for i in range(4)))

    # Subadditive envelope
    sub_env = [0] * len(ks)
    sub_env[0] = min_diags[0]
    for k in range(1, len(ks)):
        sub_env[k] = min(min_diags[i] + min_diags[k - 1 - i] for i in range(k))

    fig, ax = plt.subplots(figsize=(10, 6))

    ax.plot(ks, min_diags, 'ro-', linewidth=2, markersize=10, label='Actual minDiag(tropPow M k)', zorder=3)
    ax.plot(ks, sub_env, 'b^--', linewidth=2, markersize=8,
            label='Subadditive envelope (would-be bound)', alpha=0.7)

    # Highlight the gap at k=2
    if len(min_diags) > 2 and min_diags[2] > sub_env[2]:
        ax.annotate(f'GAP: {int(min_diags[2])} > {int(sub_env[2])}\n(subadditivity fails!)',
                    xy=(2, min_diags[2]), fontsize=12,
                    xytext=(3.5, min_diags[2] + 1),
                    arrowprops=dict(arrowstyle='->', color='red', lw=2),
                    color='red', fontweight='bold')

    ax.set_xlabel('Power index k', fontsize=14)
    ax.set_ylabel('minDiag(tropPow M k)', fontsize=14)
    ax.set_title('Counterexample: MinDiag Subadditivity FAILS\n'
                 'M = diag(2,1000,1000,1000) with cheap edges 1↔2', fontsize=14)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(ks)
    ax.set_ylim(bottom=0)

    fig.savefig('viz_counterexample.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close()
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    viz_entry_bounds()
    print("  ✓ Entry bounds (viz_entry_bounds.png)")
    viz_depth_lower_bound()
    print("  ✓ Depth lower bounds (viz_depth_bounds.png)")
    viz_spectral_gap()
    print("  ✓ Spectral gap (viz_spectral_gap.png)")
    viz_counterexample()
    print("  ✓ Counterexample (viz_counterexample.png)")
    print("All visualizations generated!")
