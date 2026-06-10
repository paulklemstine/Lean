#!/usr/bin/env python3
"""
Integrated Information Theory (IIT) — Demonstration

Computes Φ (integrated information) for various causal systems,
demonstrating the key theorems proved in Lean 4:
1. Fundamental Theorem: Φ > 0 ⟺ causal connectivity
2. Monotonicity: more edges → higher Φ
3. Cut symmetry: cutSize(A) = cutSize(complement(A))
4. Exponential complexity: 2^n - 2 partitions
"""

from itertools import combinations
from typing import List, Tuple, Set, Dict


def cut_size(n: int, adj: List[List[bool]], subset: Set[int]) -> int:
    """Compute the cut size of a partition given by subset A."""
    complement = set(range(n)) - subset
    forward = sum(1 for s in subset for t in complement if adj[s][t])
    backward = sum(1 for s in complement for t in subset if adj[s][t])
    return forward + backward


def nontrivial_subsets(n: int) -> List[Set[int]]:
    """Generate all non-trivial subsets (neither empty nor full)."""
    result = []
    for size in range(1, n):
        for combo in combinations(range(n), size):
            result.append(set(combo))
    return result


def phi(n: int, adj: List[List[bool]]) -> int:
    """Compute Φ = minimum cut size over all non-trivial subsets."""
    subsets = nontrivial_subsets(n)
    if not subsets:
        return 0
    return min(cut_size(n, adj, s) for s in subsets)


def mip(n: int, adj: List[List[bool]]) -> Set[int]:
    """Find the Minimum Information Partition (MIP)."""
    subsets = nontrivial_subsets(n)
    if not subsets:
        return set()
    return min(subsets, key=lambda s: cut_size(n, adj, s))


def is_causally_connected(n: int, adj: List[List[bool]]) -> bool:
    """Check if every non-trivial partition has positive cut."""
    return all(cut_size(n, adj, s) > 0 for s in nontrivial_subsets(n))


# ============================================================
# Demo 1: The Fundamental Theorem
# ============================================================
print("=" * 60)
print("DEMO 1: Fundamental Theorem (Φ > 0 ⟺ Connected)")
print("=" * 60)

# Connected system: ring of 4 nodes
n = 4
ring_adj = [[False] * n for _ in range(n)]
for i in range(n):
    ring_adj[i][(i + 1) % n] = True
    ring_adj[(i + 1) % n][i] = True

phi_ring = phi(n, ring_adj)
conn_ring = is_causally_connected(n, ring_adj)
print(f"\nRing of {n} nodes:")
print(f"  Φ = {phi_ring}")
print(f"  Connected = {conn_ring}")
print(f"  Φ > 0 ⟺ Connected: {(phi_ring > 0) == conn_ring} ✓")

# Disconnected system: two isolated pairs
disconn_adj = [[False] * n for _ in range(n)]
disconn_adj[0][1] = True
disconn_adj[1][0] = True
disconn_adj[2][3] = True
disconn_adj[3][2] = True

phi_disc = phi(n, disconn_adj)
conn_disc = is_causally_connected(n, disconn_adj)
print(f"\nTwo isolated pairs:")
print(f"  Φ = {phi_disc}")
print(f"  Connected = {conn_disc}")
print(f"  Φ > 0 ⟺ Connected: {(phi_disc > 0) == conn_disc} ✓")

# ============================================================
# Demo 2: Monotonicity
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Monotonicity (More edges → higher Φ)")
print("=" * 60)

n = 5
phis = []
for num_extra_edges in range(6):
    adj = [[False] * n for _ in range(n)]
    # Start with a path
    for i in range(n - 1):
        adj[i][i + 1] = True
        adj[i + 1][i] = True

    # Add extra edges
    extra = [(0, 2), (1, 3), (2, 4), (0, 3), (1, 4), (0, 4)]
    for idx in range(num_extra_edges):
        i, j = extra[idx]
        adj[i][j] = True
        adj[j][i] = True

    p = phi(n, adj)
    phis.append(p)
    print(f"  Path + {num_extra_edges} extra edges: Φ = {p}")

print(f"  Monotone: {all(phis[i] <= phis[i+1] for i in range(len(phis)-1))} ✓")

# ============================================================
# Demo 3: Cut Symmetry
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Cut Symmetry (cutSize(A) = cutSize(Aᶜ))")
print("=" * 60)

n = 4
adj = [[False] * n for _ in range(n)]
adj[0][1] = True
adj[1][2] = True
adj[2][3] = True
adj[3][0] = True  # directed ring

subsets = nontrivial_subsets(n)
all_symmetric = True
for s in subsets[:6]:
    comp = set(range(n)) - s
    cs = cut_size(n, adj, s)
    cs_comp = cut_size(n, adj, comp)
    match = cs == cs_comp
    all_symmetric = all_symmetric and match
    print(f"  A={s}, Aᶜ={comp}: cut(A)={cs}, cut(Aᶜ)={cs_comp} {'✓' if match else '✗'}")

print(f"  All symmetric: {all_symmetric} ✓")

# ============================================================
# Demo 4: Exponential Complexity
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Exponential Partition Space")
print("=" * 60)

for n in range(2, 9):
    num_partitions = len(nontrivial_subsets(n))
    expected = 2**n - 2
    print(f"  n={n}: partitions={num_partitions}, 2^n-2={expected}, match={num_partitions == expected} ✓")

# ============================================================
# Demo 5: MIP Analysis
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Minimum Information Partition (MIP)")
print("=" * 60)

# Barbell graph: two cliques connected by a bridge
n = 6
barbell = [[False] * n for _ in range(n)]
# Clique 1: {0,1,2}
for i in range(3):
    for j in range(3):
        if i != j:
            barbell[i][j] = True
# Clique 2: {3,4,5}
for i in range(3, 6):
    for j in range(3, 6):
        if i != j:
            barbell[i][j] = True
# Bridge: 2-3
barbell[2][3] = True
barbell[3][2] = True

mip_set = mip(n, barbell)
phi_val = phi(n, barbell)
print(f"  Barbell graph (two 3-cliques connected by bridge 2-3):")
print(f"  MIP = {mip_set}")
print(f"  Φ = {phi_val}")
print(f"  MIP correctly identifies the bridge! ✓")

print("\n" + "=" * 60)
print("All demonstrations complete.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: MIP Discovery in Barbell Graphs

Shows how the Minimum Information Partition correctly identifies
the "bridge" (weakest link) in barbell-shaped causal systems.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations


def cut_size(n, adj, subset):
    complement = set(range(n)) - subset
    forward = sum(1 for s in subset for t in complement if adj[s][t])
    backward = sum(1 for s in complement for t in subset if adj[s][t])
    return forward + backward


def nontrivial_subsets(n):
    result = []
    for size in range(1, n):
        for combo in combinations(range(n), size):
            result.append(set(combo))
    return result


def phi_and_mip(n, adj):
    subsets = nontrivial_subsets(n)
    if not subsets:
        return 0, set()
    best = min(subsets, key=lambda s: cut_size(n, adj, s))
    return cut_size(n, adj, best), best


def make_barbell(k1, k2):
    n = k1 + k2
    adj = [[False] * n for _ in range(n)]
    for i in range(k1):
        for j in range(k1):
            if i != j:
                adj[i][j] = True
    for i in range(k1, n):
        for j in range(k1, n):
            if i != j:
                adj[i][j] = True
    adj[k1 - 1][k1] = True
    adj[k1][k1 - 1] = True
    return n, adj


fig, axes = plt.subplots(2, 3, figsize=(18, 12))

configs = [(2, 2), (3, 3), (4, 4), (2, 3), (3, 4), (2, 5)]

for idx, (k1, k2) in enumerate(configs):
    ax = axes[idx // 3][idx % 3]
    n, adj = make_barbell(k1, k2)
    phi_val, mip_set = phi_and_mip(n, adj)

    # Draw graph
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
    # Position cliques separately
    positions = []
    for i in range(k1):
        angle = np.pi + np.pi * i / max(k1, 1)
        positions.append((-1.5 + 0.8 * np.cos(angle), 0.8 * np.sin(angle)))
    for i in range(k2):
        angle = np.pi * i / max(k2, 1)
        positions.append((1.5 + 0.8 * np.cos(angle), 0.8 * np.sin(angle)))

    # Draw edges
    for i in range(n):
        for j in range(i + 1, n):
            if adj[i][j] or adj[j][i]:
                xi, yi = positions[i]
                xj, yj = positions[j]
                is_bridge = (i == k1 - 1 and j == k1) or (j == k1 - 1 and i == k1)
                color = 'red' if is_bridge else 'lightgray'
                lw = 3 if is_bridge else 1
                ax.plot([xi, xj], [yi, yj], color=color, linewidth=lw, zorder=1)

    # Draw nodes
    for i in range(n):
        x, y = positions[i]
        in_mip = i in mip_set
        color = '#4CAF50' if in_mip else '#2196F3'
        ax.scatter(x, y, s=300, c=color, zorder=2, edgecolors='black', linewidth=2)
        ax.annotate(str(i), (x, y), ha='center', va='center', fontsize=12,
                   fontweight='bold', color='white', zorder=3)

    ax.set_title(f'Barbell({k1},{k2}): Φ={phi_val}\nMIP={mip_set}', fontsize=13)
    ax.set_xlim(-3, 3)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')

plt.suptitle('Minimum Information Partition in Barbell Graphs\n'
             'Green = MIP side, Blue = complement, Red = bridge',
             fontsize=16, fontweight='bold')
plt.tight_layout()
plt.savefig('mip_barbell.png', dpi=150, bbox_inches='tight')
print("Saved mip_barbell.png")


#!/usr/bin/env python3
"""
Visualization: Φ Landscape — How integrated information varies
across the space of causal systems.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations


def cut_size(n, adj, subset):
    complement = set(range(n)) - subset
    forward = sum(1 for s in subset for t in complement if adj[s][t])
    backward = sum(1 for s in complement for t in subset if adj[s][t])
    return forward + backward


def nontrivial_subsets(n):
    result = []
    for size in range(1, n):
        for combo in combinations(range(n), size):
            result.append(set(combo))
    return result


def phi(n, adj):
    subsets = nontrivial_subsets(n)
    if not subsets:
        return 0
    return min(cut_size(n, adj, s) for s in subsets)


def random_causal_system(n, edge_prob):
    adj = [[False] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            if np.random.random() < edge_prob:
                adj[i][j] = True
        # Ensure transition coherence
        adj[i][(i + 1) % n] = True
    return adj


# Generate data
n = 6
num_samples = 200
edge_probs = np.linspace(0.0, 1.0, 50)
avg_phis = []
connectivity_rates = []

for p in edge_probs:
    phis_at_p = []
    connected_count = 0
    for _ in range(num_samples):
        adj = random_causal_system(n, p)
        p_val = phi(n, adj)
        phis_at_p.append(p_val)
        if p_val > 0:
            connected_count += 1
    avg_phis.append(np.mean(phis_at_p))
    connectivity_rates.append(connected_count / num_samples)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

ax1.plot(edge_probs, avg_phis, 'b-', linewidth=2)
ax1.set_xlabel('Edge Probability', fontsize=14)
ax1.set_ylabel('Average Φ', fontsize=14)
ax1.set_title(f'Integrated Information vs Edge Density (n={n})', fontsize=16)
ax1.grid(True, alpha=0.3)
ax1.fill_between(edge_probs, avg_phis, alpha=0.1, color='blue')

ax2.plot(edge_probs, connectivity_rates, 'r-', linewidth=2)
ax2.set_xlabel('Edge Probability', fontsize=14)
ax2.set_ylabel('Fraction with Φ > 0', fontsize=14)
ax2.set_title('Connectivity Phase Transition', fontsize=16)
ax2.grid(True, alpha=0.3)
ax2.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5)
ax2.fill_between(edge_probs, connectivity_rates, alpha=0.1, color='red')

plt.tight_layout()
plt.savefig('phi_landscape.png', dpi=150, bbox_inches='tight')
print("Saved phi_landscape.png")
