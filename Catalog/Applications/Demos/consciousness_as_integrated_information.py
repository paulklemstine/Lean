#!/usr/bin/env python3
"""
Causal Integration Algebra — Numerical Demonstrations

Demonstrates the key theorems of the Causal Integration framework:
1. Φ computation for various network topologies
2. Decomposition theorem: block-diagonal → Φ = 0
3. Monotonicity: strengthening connections increases Φ
4. Weight decomposition: total = cut + internal
5. Complement symmetry of cut values
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple

def cross_weight(W: np.ndarray, S: set, n: int) -> float:
    """Total directed weight from S to its complement."""
    S_comp = set(range(n)) - S
    return sum(W[i, j] for i in S for j in S_comp)

def cut_value(W: np.ndarray, S: set, n: int) -> float:
    """Bidirectional cut value of partition (S, S^c)."""
    return cross_weight(W, S, n) + cross_weight(W, set(range(n)) - S, n)

def total_weight(W: np.ndarray) -> float:
    """Sum of all edge weights."""
    return float(np.sum(W))

def phi(W: np.ndarray, n: int) -> Tuple[float, set]:
    """
    Compute Φ (integrated information): minimum non-trivial cut.
    Returns (Φ value, minimizing partition).
    """
    assert n >= 2, "Need at least 2 nodes"
    best_cut = float('inf')
    best_S = None
    # Enumerate all non-trivial subsets (non-empty, not everything)
    for size in range(1, n):
        for combo in combinations(range(n), size):
            S = set(combo)
            cv = cut_value(W, S, n)
            if cv < best_cut:
                best_cut = cv
                best_S = S
    return best_cut, best_S

def internal_weight(W: np.ndarray, S: set) -> float:
    """Sum of weights within a subset."""
    return sum(W[i, j] for i in S for j in S)

# ============================================================
# DEMO 1: Complete graph — high integration
# ============================================================
print("=" * 60)
print("DEMO 1: Complete Graph (n=4, uniform weight 1)")
print("=" * 60)

n = 4
W = np.ones((n, n)) - np.eye(n)  # Complete graph, no self-loops
phi_val, phi_cut = phi(W, n)
print(f"  Total weight: {total_weight(W):.1f}")
print(f"  Φ = {phi_val:.1f}")
print(f"  Minimizing partition: {phi_cut} vs {set(range(n)) - phi_cut}")
print(f"  → High integration: the complete graph cannot be cheaply partitioned")
print()

# ============================================================
# DEMO 2: Disconnected graph — zero integration
# ============================================================
print("=" * 60)
print("DEMO 2: Block-Diagonal (Disconnected) Graph")
print("=" * 60)

n = 4
W = np.zeros((n, n))
# Block 1: nodes {0, 1} fully connected
W[0, 1] = W[1, 0] = 3.0
# Block 2: nodes {2, 3} fully connected
W[2, 3] = W[3, 2] = 5.0
phi_val, phi_cut = phi(W, n)
print(f"  Block 1: {{0,1}} with weight 3")
print(f"  Block 2: {{2,3}} with weight 5")
print(f"  Φ = {phi_val:.1f}")
print(f"  Minimizing partition: {phi_cut}")
print(f"  → Φ = 0 confirms the Decomposition Theorem!")
print()

# ============================================================
# DEMO 3: Monotonicity — strengthening connections
# ============================================================
print("=" * 60)
print("DEMO 3: Monotonicity of Φ")
print("=" * 60)

n = 3
W1 = np.array([[0, 1, 0], [1, 0, 1], [0, 1, 0]], dtype=float)
W2 = np.array([[0, 2, 1], [2, 0, 2], [1, 2, 0]], dtype=float)

phi1, _ = phi(W1, n)
phi2, _ = phi(W2, n)
print(f"  Network G₁ (weak):   Φ = {phi1:.1f}")
print(f"  Network G₂ (strong): Φ = {phi2:.1f}")
print(f"  G₁.w ≤ G₂.w pointwise → Φ(G₁) ≤ Φ(G₂): {phi1 <= phi2}")
print(f"  → Monotonicity confirmed!")
print()

# ============================================================
# DEMO 4: Weight Decomposition
# ============================================================
print("=" * 60)
print("DEMO 4: Weight Decomposition Theorem")
print("=" * 60)

n = 4
W = np.array([
    [0, 2, 1, 0],
    [3, 0, 0, 1],
    [1, 0, 0, 4],
    [0, 2, 3, 0]
], dtype=float)

S = {0, 1}
S_comp = {2, 3}
tw = total_weight(W)
cv = cut_value(W, S, n)
iw_S = internal_weight(W, S)
iw_Sc = internal_weight(W, S_comp)

print(f"  Partition: S={S}, S^c={S_comp}")
print(f"  Total weight = {tw:.1f}")
print(f"  Cut value    = {cv:.1f}")
print(f"  Internal(S)  = {iw_S:.1f}")
print(f"  Internal(S^c)= {iw_Sc:.1f}")
print(f"  Cut + Int(S) + Int(S^c) = {cv + iw_S + iw_Sc:.1f}")
print(f"  Decomposition holds: {abs(tw - (cv + iw_S + iw_Sc)) < 1e-10}")
print()

# ============================================================
# DEMO 5: Complement Symmetry
# ============================================================
print("=" * 60)
print("DEMO 5: Complement Symmetry of Cut Values")
print("=" * 60)

n = 5
np.random.seed(42)
W = np.random.rand(n, n)
np.fill_diagonal(W, 0)

for size in range(1, n):
    for combo in combinations(range(n), size):
        S = set(combo)
        S_comp = set(range(n)) - S
        cv_S = cut_value(W, S, n)
        cv_Sc = cut_value(W, S_comp, n)
        if abs(cv_S - cv_Sc) > 1e-10:
            print(f"  VIOLATION: cut({S}) ≠ cut({S_comp})")
            break
    else:
        continue
    break
else:
    print(f"  All {2**n - 2} non-trivial partitions satisfy cut(S) = cut(S^c)")
    print(f"  → Complement symmetry confirmed for random 5-node network!")
print()

# ============================================================
# DEMO 6: Scaling behavior of Φ
# ============================================================
print("=" * 60)
print("DEMO 6: Φ vs Network Size (Complete Graphs)")
print("=" * 60)

for n in range(2, 8):
    W = np.ones((n, n)) - np.eye(n)
    phi_val, _ = phi(W, n)
    print(f"  n={n}: Φ = {phi_val:.1f}, total_weight = {n*(n-1):.1f}, "
          f"ratio = {phi_val/(n*(n-1)):.3f}")

print(f"  → Φ grows with n: larger integrated systems have higher Φ")
print()

# ============================================================
# DEMO 7: IIT Exclusion Principle
# ============================================================
print("=" * 60)
print("DEMO 7: Exclusion Principle — Unique Minimum Cut")
print("=" * 60)

n = 5
# A network with a clear "weakest link"
W = np.zeros((n, n))
# Strong cluster: {0, 1, 2}
for i in range(3):
    for j in range(3):
        if i != j:
            W[i, j] = 10.0
# Strong cluster: {3, 4}
W[3, 4] = W[4, 3] = 10.0
# Weak bridge
W[2, 3] = W[3, 2] = 0.5

phi_val, phi_cut = phi(W, n)
print(f"  Network: two clusters {{0,1,2}} and {{3,4}} with weak bridge")
print(f"  Φ = {phi_val:.1f}")
print(f"  Minimizing partition: {phi_cut} vs {set(range(n)) - phi_cut}")
print(f"  → The exclusion principle identifies the natural decomposition!")

print("\n" + "=" * 60)
print("All demonstrations completed successfully.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Φ (Integrated Information) Landscape

Generates plots showing how Φ varies across network topologies,
demonstrating key theorems of the Causal Integration Algebra.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from typing import Set, Tuple, List


def cut_value(W: np.ndarray, S: Set[int], n: int) -> float:
    S_comp = set(range(n)) - S
    return (sum(W[i, j] for i in S for j in S_comp) +
            sum(W[i, j] for i in S_comp for j in S))


def compute_phi(W: np.ndarray, n: int) -> float:
    best = float('inf')
    for size in range(1, n):
        for combo in combinations(range(n), size):
            cv = cut_value(W, set(combo), n)
            if cv < best:
                best = cv
    return best


fig, axes = plt.subplots(2, 2, figsize=(14, 11))
fig.suptitle('Causal Integration Algebra: Φ Landscape', fontsize=16, fontweight='bold')

# --- Plot 1: Φ vs edge density ---
ax = axes[0, 0]
n = 6
densities = np.linspace(0, 1, 20)
phi_values = []
for d in densities:
    np.random.seed(42)
    W = np.random.rand(n, n) * (np.random.rand(n, n) < d).astype(float)
    np.fill_diagonal(W, 0)
    phi_values.append(compute_phi(W, n))

ax.plot(densities, phi_values, 'b-o', markersize=4, linewidth=2)
ax.set_xlabel('Edge Density', fontsize=12)
ax.set_ylabel('Φ (Integrated Information)', fontsize=12)
ax.set_title('Φ vs Edge Density (n=6)', fontsize=13)
ax.grid(True, alpha=0.3)
ax.axhline(y=0, color='r', linestyle='--', alpha=0.5, label='Φ = 0 (decomposable)')
ax.legend()

# --- Plot 2: Φ scaling with network size ---
ax = axes[0, 1]
sizes = list(range(2, 9))
phi_complete = []
phi_cycle = []
for n in sizes:
    # Complete graph
    W = np.ones((n, n)) - np.eye(n)
    phi_complete.append(compute_phi(W, n))
    # Cycle graph
    W2 = np.zeros((n, n))
    for i in range(n):
        W2[i, (i+1) % n] = 1.0
        W2[(i+1) % n, i] = 1.0
    phi_cycle.append(compute_phi(W2, n))

ax.plot(sizes, phi_complete, 'r-s', markersize=6, linewidth=2, label='Complete $K_n$')
ax.plot(sizes, phi_cycle, 'g-^', markersize=6, linewidth=2, label='Cycle $C_n$')
ax.set_xlabel('Network Size n', fontsize=12)
ax.set_ylabel('Φ', fontsize=12)
ax.set_title('Φ Scaling: Complete vs Cycle', fontsize=13)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# --- Plot 3: Integration spectrum ---
ax = axes[1, 0]
n = 5
W = np.array([
    [0, 3, 1, 0.2, 0],
    [2, 0, 0, 1, 0.5],
    [0, 1, 0, 5, 0],
    [1, 0, 4, 0, 0.1],
    [0, 0.5, 0, 0.1, 0]
])
cuts = []
for size in range(1, n):
    for combo in combinations(range(n), size):
        S = set(combo)
        cuts.append(cut_value(W, S, n))
cuts.sort()
ax.bar(range(len(cuts)), cuts, color=plt.cm.viridis(np.linspace(0, 1, len(cuts))),
       edgecolor='black', linewidth=0.5)
ax.axhline(y=cuts[0], color='r', linestyle='--', linewidth=2,
           label=f'Φ = {cuts[0]:.1f} (minimum)')
ax.set_xlabel('Partition Index (sorted)', fontsize=12)
ax.set_ylabel('Cut Value', fontsize=12)
ax.set_title('Integration Spectrum (n=5)', fontsize=13)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3, axis='y')

# --- Plot 4: Monotonicity demonstration ---
ax = axes[1, 1]
n = 4
np.random.seed(123)
W_base = np.random.rand(n, n) * 2
np.fill_diagonal(W_base, 0)

scales = np.linspace(0.1, 3.0, 30)
phi_scaled = [compute_phi(W_base * s, n) for s in scales]

ax.plot(scales, phi_scaled, 'purple', linewidth=2.5)
ax.fill_between(scales, 0, phi_scaled, alpha=0.15, color='purple')
ax.set_xlabel('Weight Scale Factor α', fontsize=12)
ax.set_ylabel('Φ(αG)', fontsize=12)
ax.set_title('Φ Monotonicity: Scaling All Weights', fontsize=13)
ax.grid(True, alpha=0.3)
ax.annotate('Φ scales linearly\n(homogeneity)', xy=(2.0, compute_phi(W_base * 2.0, n)),
            fontsize=10, ha='center',
            arrowprops=dict(arrowstyle='->', color='gray'),
            xytext=(1.2, compute_phi(W_base * 2.5, n)))

plt.tight_layout()
plt.savefig('phi_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: phi_landscape.png")
plt.close()
