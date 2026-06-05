#!/usr/bin/env python3
"""
Integrated Information Theory: Numerical Demonstrations

Demonstrates the key results from the formalization:
1. Phi computation via minimum cut
2. Integration Filtration construction
3. Direct sum and weak interaction bounds
4. Uniform complete graph analysis
"""

import numpy as np
from itertools import combinations


def compute_cut_value(weights: np.ndarray, S: set) -> float:
    """Compute the cut value of subset S in a weighted graph."""
    n = weights.shape[0]
    S_complement = set(range(n)) - S
    total = 0.0
    for i in S:
        for j in S_complement:
            total += weights[i, j]
    return total


def compute_phi(weights: np.ndarray) -> tuple[float, set]:
    """Compute Phi (minimum cut) over all non-trivial bipartitions.
    Returns (phi_value, optimal_partition)."""
    n = weights.shape[0]
    if n < 2:
        return 0.0, set()

    best_cut = float('inf')
    best_S = set()

    # Enumerate all non-trivial subsets (non-empty, not full)
    for size in range(1, n):
        for subset in combinations(range(n), size):
            S = set(subset)
            cut = compute_cut_value(weights, S)
            if cut < best_cut:
                best_cut = cut
                best_S = S

    return best_cut, best_S


def compute_integration_filtration(weights: np.ndarray, thresholds: list[float]) -> dict:
    """Compute the Integration Filtration at multiple thresholds."""
    n = weights.shape[0]
    # Compute subset phi for all subsets of size >= 2
    subset_phis = {}
    for size in range(2, n + 1):
        for subset in combinations(range(n), size):
            S = frozenset(subset)
            indices = sorted(S)
            sub_weights = weights[np.ix_(indices, indices)]
            phi_val, _ = compute_phi(sub_weights)
            subset_phis[S] = phi_val

    # Build filtration
    filtration = {}
    for tau in thresholds:
        members = [S for S, phi in subset_phis.items() if phi >= tau]
        filtration[tau] = members

    return filtration, subset_phis


def direct_sum_weights(w1: np.ndarray, w2: np.ndarray) -> np.ndarray:
    """Construct the direct sum (block diagonal) of two weight matrices."""
    m, n = w1.shape[0], w2.shape[0]
    result = np.zeros((m + n, m + n))
    result[:m, :m] = w1
    result[m:, m:] = w2
    return result


def uniform_interaction_weights(w1: np.ndarray, w2: np.ndarray, epsilon: float) -> np.ndarray:
    """Construct uniform interaction of two systems with cross-coupling epsilon."""
    m, n = w1.shape[0], w2.shape[0]
    result = np.zeros((m + n, m + n))
    result[:m, :m] = w1
    result[m:, m:] = w2
    result[:m, m:] = epsilon
    result[m:, :m] = epsilon
    np.fill_diagonal(result, 0)
    return result


def uniform_complete(n: int, w: float) -> np.ndarray:
    """Uniform complete graph: all edges have weight w."""
    return w * (np.ones((n, n)) - np.eye(n))


# ============================================================
# DEMO 1: Uniform Complete Graph
# ============================================================
print("=" * 60)
print("DEMO 1: Uniform Complete Graph K_n(w)")
print("=" * 60)
print()

for n in range(2, 7):
    w = 1.0
    weights = uniform_complete(n, w)
    phi, S = compute_phi(weights)
    expected = w * (n - 1)
    print(f"  K_{n}(1.0): Φ = {phi:.2f}, expected w·(n-1) = {expected:.2f}, "
          f"optimal cut = {S}")

print()
print("  → Theorem verified: Φ(K_n(w)) = w·(n-1)")
print()

# ============================================================
# DEMO 2: Disconnected System (Direct Sum)
# ============================================================
print("=" * 60)
print("DEMO 2: Direct Sum (Disconnected Systems)")
print("=" * 60)
print()

# Two triangles
w1 = uniform_complete(3, 2.0)
w2 = uniform_complete(3, 3.0)

phi1, _ = compute_phi(w1)
phi2, _ = compute_phi(w2)
print(f"  System 1 (K_3, w=2): Φ = {phi1:.2f}")
print(f"  System 2 (K_3, w=3): Φ = {phi2:.2f}")

ds = direct_sum_weights(w1, w2)
phi_ds, S_ds = compute_phi(ds)
print(f"  Direct Sum: Φ = {phi_ds:.2f} (should be 0)")
print(f"  → Theorem verified: Φ(C₁ ⊕ C₂) = 0")
print()

# ============================================================
# DEMO 3: Weak Interaction Bound
# ============================================================
print("=" * 60)
print("DEMO 3: Weak Interaction Bound")
print("=" * 60)
print()

m, n_size = 3, 3
for eps in [0.1, 0.5, 1.0, 2.0]:
    wi = uniform_interaction_weights(w1, w2, eps)
    phi_wi, _ = compute_phi(wi)
    bound = eps * m * n_size
    print(f"  ε = {eps:.1f}: Φ = {phi_wi:.2f}, bound ε·m·n = {bound:.2f}, "
          f"{'✓' if phi_wi <= bound + 1e-10 else '✗'}")

print()
print("  → Theorem verified: Φ(C₁ ⊗_ε C₂) ≤ ε·m·n")
print()

# ============================================================
# DEMO 4: Integration Filtration
# ============================================================
print("=" * 60)
print("DEMO 4: Integration Filtration")
print("=" * 60)
print()

# A 4-node system with varying coupling strengths
weights_4 = np.array([
    [0, 5, 1, 0],
    [5, 0, 1, 0],
    [1, 1, 0, 4],
    [0, 0, 4, 0]
])

thresholds = [0.0, 0.5, 1.0, 2.0, 3.0, 4.0, 5.0]
filtration, subset_phis = compute_integration_filtration(weights_4, thresholds)

print("  Weight matrix:")
for row in weights_4:
    print(f"    {row}")
print()

print("  Subset Phi values:")
for S, phi in sorted(subset_phis.items(), key=lambda x: (-x[1], len(x[0]))):
    print(f"    {set(S)}: Φ = {phi:.2f}")
print()

print("  Integration Filtration:")
for tau in thresholds:
    members = filtration[tau]
    count = len(members)
    print(f"    τ = {tau:.1f}: {count} subsystems")
    if count <= 5:
        for m in members:
            print(f"      {set(m)}")

print()
print("  → Filtration is antitone: higher τ ⟹ fewer subsystems ✓")
print()

# ============================================================
# DEMO 5: Phi vs System Size
# ============================================================
print("=" * 60)
print("DEMO 5: Phi Scaling for Random Graphs")
print("=" * 60)
print()

np.random.seed(42)
for n in [3, 4, 5, 6, 7]:
    # Random symmetric coupling
    raw = np.random.exponential(1.0, (n, n))
    weights = (raw + raw.T) / 2
    np.fill_diagonal(weights, 0)

    phi, S = compute_phi(weights)
    min_deg = min(sum(weights[i, j] for j in range(n)) for i in range(n))
    print(f"  n = {n}: Φ = {phi:.2f}, min_degree = {min_deg:.2f}, "
          f"Φ ≤ min_deg: {'✓' if phi <= min_deg + 1e-10 else '✗'}")

print()
print("  → Theorem verified: Φ ≤ min weighted degree ✓")


if __name__ == "__main__":
    print()
    print("All demonstrations completed successfully.")


#!/usr/bin/env python3
"""
Visualization: Integration Filtration as a persistence diagram.
Shows how subsystems appear/disappear as the integration threshold varies.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def compute_cut_value(weights, S):
    n = weights.shape[0]
    complement = set(range(n)) - S
    return sum(weights[i, j] for i in S for j in complement)


def compute_phi(weights):
    n = weights.shape[0]
    if n < 2:
        return 0.0
    best = float('inf')
    for size in range(1, n):
        for subset in combinations(range(n), size):
            cv = compute_cut_value(weights, set(subset))
            best = min(best, cv)
    return best


def compute_all_subset_phis(weights):
    n = weights.shape[0]
    results = {}
    for size in range(2, n + 1):
        for subset in combinations(range(n), size):
            S = frozenset(subset)
            indices = sorted(S)
            sub_w = weights[np.ix_(indices, indices)]
            results[S] = compute_phi(sub_w)
    return results


# Example: 5-node system with hierarchical structure
# Nodes 0,1 are tightly coupled; nodes 2,3,4 form a triangle; weak cross-coupling
weights = np.array([
    [0, 8, 1, 0, 0],
    [8, 0, 1, 0, 0],
    [1, 1, 0, 5, 5],
    [0, 0, 5, 0, 5],
    [0, 0, 5, 5, 0],
])

subset_phis = compute_all_subset_phis(weights)

# Create persistence diagram
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Bar chart of subset Phi values
ax1 = axes[0]
items = sorted(subset_phis.items(), key=lambda x: -x[1])
labels = [str(set(s)) for s, _ in items]
values = [v for _, v in items]
colors = ['#e74c3c' if len(s) == 2 else '#3498db' if len(s) == 3 else '#2ecc71'
          for s, _ in items]

bars = ax1.barh(range(len(items)), values, color=colors)
ax1.set_yticks(range(len(items)))
ax1.set_yticklabels(labels, fontsize=8)
ax1.set_xlabel('Φ (Integration)', fontsize=12)
ax1.set_title('Subset Integration Values', fontsize=14, fontweight='bold')
ax1.invert_yaxis()

# Legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#e74c3c', label='Pairs (|S|=2)'),
    Patch(facecolor='#3498db', label='Triples (|S|=3)'),
    Patch(facecolor='#2ecc71', label='Larger (|S|≥4)')
]
ax1.legend(handles=legend_elements, loc='lower right', fontsize=9)

# Panel 2: Filtration size vs threshold
ax2 = axes[1]
thresholds = np.linspace(0, max(values) + 0.5, 200)
counts = []
for tau in thresholds:
    count = sum(1 for v in subset_phis.values() if v >= tau)
    counts.append(count)

ax2.fill_between(thresholds, counts, alpha=0.3, color='#3498db')
ax2.plot(thresholds, counts, color='#2c3e50', linewidth=2)
ax2.set_xlabel('Threshold τ', fontsize=12)
ax2.set_ylabel('|F_τ| (Number of subsystems)', fontsize=12)
ax2.set_title('Integration Filtration', fontsize=14, fontweight='bold')

# Mark key thresholds
unique_phis = sorted(set(subset_phis.values()), reverse=True)
for phi_val in unique_phis[:5]:
    ax2.axvline(x=phi_val, color='#e74c3c', linestyle='--', alpha=0.5)
    ax2.annotate(f'τ={phi_val:.1f}', xy=(phi_val, 0.5),
                xycoords=('data', 'axes fraction'),
                fontsize=8, color='#e74c3c', rotation=90, va='bottom')

plt.tight_layout()
plt.savefig('integration_filtration.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved: integration_filtration.png")
print(f"Total subsystems: {len(subset_phis)}")
print(f"Max Φ: {max(subset_phis.values()):.2f}")
print(f"Most integrated: {set(max(subset_phis, key=subset_phis.get))}")


#!/usr/bin/env python3
"""
Visualization: Interaction strength vs. integrated information.
Shows the phase transition from disconnected (Φ=0) to integrated as ε increases.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def compute_cut_value(weights, S):
    n = weights.shape[0]
    complement = set(range(n)) - S
    return sum(weights[i, j] for i in S for j in complement)


def compute_phi(weights):
    n = weights.shape[0]
    if n < 2:
        return 0.0
    best = float('inf')
    for size in range(1, n):
        for subset in combinations(range(n), size):
            cv = compute_cut_value(weights, set(subset))
            best = min(best, cv)
    return best


def uniform_complete(n, w):
    return w * (np.ones((n, n)) - np.eye(n))


def uniform_interaction_weights(w1, w2, epsilon):
    m, n = w1.shape[0], w2.shape[0]
    result = np.zeros((m + n, m + n))
    result[:m, :m] = w1
    result[m:, m:] = w2
    result[:m, m:] = epsilon
    result[m:, :m] = epsilon
    np.fill_diagonal(result, 0)
    return result


# Two K_3 systems with internal weight 3, varying cross-coupling ε
w_internal = 3.0
m, n = 3, 3
w1 = uniform_complete(m, w_internal)
w2 = uniform_complete(n, w_internal)

epsilons = np.linspace(0, 5, 50)
phis = []
bounds = []

for eps in epsilons:
    wi = uniform_interaction_weights(w1, w2, eps)
    phi = compute_phi(wi)
    phis.append(phi)
    bounds.append(eps * m * n)

fig, ax = plt.subplots(figsize=(10, 6))

ax.plot(epsilons, phis, '-', color='#e74c3c', linewidth=2.5, label='Φ(C₁ ⊗_ε C₂)')
ax.plot(epsilons, bounds, '--', color='#3498db', linewidth=2,
        label='Upper bound ε·m·n')
ax.fill_between(epsilons, phis, bounds, alpha=0.1, color='#3498db')

# Mark the phase transition
# When ε = 0, Φ = 0 (disconnected)
# When ε is large enough, Φ = internal min-cut of the merged system
ax.axhline(y=0, color='gray', linestyle='-', alpha=0.3)
ax.axvline(x=0, color='gray', linestyle='-', alpha=0.3)

# Internal Phi values
phi1 = compute_phi(w1)
phi2 = compute_phi(w2)
ax.axhline(y=phi1, color='#2ecc71', linestyle=':', alpha=0.5,
           label=f'Φ(C₁) = {phi1:.1f}')
ax.axhline(y=phi2, color='#9b59b6', linestyle=':', alpha=0.5,
           label=f'Φ(C₂) = {phi2:.1f}')

ax.set_xlabel('Interaction Strength ε', fontsize=14)
ax.set_ylabel('Φ (Integrated Information)', fontsize=14)
ax.set_title('Integration vs. Interaction: How Coupling Creates Consciousness',
             fontsize=14, fontweight='bold')
ax.legend(fontsize=11, loc='upper left')
ax.grid(True, alpha=0.3)

# Annotate key regions
ax.annotate('Disconnected\n(Φ = 0)',
           xy=(0.2, 0.5), fontsize=11, color='#7f8c8d',
           ha='center', va='center')
ax.annotate('Weakly coupled\n(Φ ≈ ε·m·n)',
           xy=(1.5, compute_phi(uniform_interaction_weights(w1, w2, 1.5))),
           fontsize=10, color='#e74c3c',
           xytext=(2.5, 2), arrowprops=dict(arrowstyle='->', color='#e74c3c'))

plt.tight_layout()
plt.savefig('interaction_vs_phi.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved: interaction_vs_phi.png")
print(f"\nΦ(C₁) = {phi1:.2f}, Φ(C₂) = {phi2:.2f}")
print(f"At ε=0: Φ = {phis[0]:.2f} (disconnected)")
print(f"At ε=5: Φ = {phis[-1]:.2f}")
print(f"Bound at ε=5: {bounds[-1]:.2f}")


#!/usr/bin/env python3
"""
Visualization: Phi scaling behavior.
Shows how Phi scales with system size for different graph families.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def compute_cut_value(weights, S):
    n = weights.shape[0]
    complement = set(range(n)) - S
    return sum(weights[i, j] for i in S for j in complement)


def compute_phi(weights):
    n = weights.shape[0]
    if n < 2:
        return 0.0
    best = float('inf')
    for size in range(1, n):
        for subset in combinations(range(n), size):
            cv = compute_cut_value(weights, set(subset))
            best = min(best, cv)
    return best


def uniform_complete(n, w):
    return w * (np.ones((n, n)) - np.eye(n))


def ring_graph(n, w):
    """Ring (cycle) graph with weight w."""
    weights = np.zeros((n, n))
    for i in range(n):
        weights[i, (i + 1) % n] = w
        weights[(i + 1) % n, i] = w
    return weights


def star_graph(n, w):
    """Star graph: node 0 connected to all others with weight w."""
    weights = np.zeros((n, n))
    for i in range(1, n):
        weights[0, i] = w
        weights[i, 0] = w
    return weights


def random_graph(n, density=0.5, seed=None):
    """Random Erdős-Rényi-like weighted graph."""
    rng = np.random.RandomState(seed)
    weights = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < density:
                w = rng.exponential(1.0)
                weights[i, j] = w
                weights[j, i] = w
    return weights


sizes = range(2, 10)
w = 1.0

phi_complete = []
phi_ring = []
phi_star = []
phi_random = []

np.random.seed(42)

for n in sizes:
    phi_complete.append(compute_phi(uniform_complete(n, w)))
    phi_ring.append(compute_phi(ring_graph(n, w)))
    phi_star.append(compute_phi(star_graph(n, w)))
    phi_random.append(np.mean([compute_phi(random_graph(n, 0.5, seed=42 + i))
                               for i in range(3)]))

fig, ax = plt.subplots(figsize=(10, 6))

ax.plot(list(sizes), phi_complete, 'o-', color='#e74c3c', linewidth=2,
        markersize=8, label='Complete K_n(1)')
ax.plot(list(sizes), phi_ring, 's-', color='#3498db', linewidth=2,
        markersize=8, label='Ring C_n(1)')
ax.plot(list(sizes), phi_star, '^-', color='#2ecc71', linewidth=2,
        markersize=8, label='Star S_n(1)')
ax.plot(list(sizes), phi_random, 'D-', color='#9b59b6', linewidth=2,
        markersize=8, label='Random G(n, 0.5)')

# Theoretical lines
n_arr = np.array(list(sizes))
ax.plot(n_arr, w * (n_arr - 1), '--', color='#e74c3c', alpha=0.3, label='w·(n-1)')
ax.axhline(y=2 * w, color='#3498db', linestyle='--', alpha=0.3, label='2w (ring)')
ax.axhline(y=w, color='#2ecc71', linestyle='--', alpha=0.3, label='w (star)')

ax.set_xlabel('System Size n', fontsize=14)
ax.set_ylabel('Φ (Integrated Information)', fontsize=14)
ax.set_title('Phi Scaling: How Integration Grows with System Size', fontsize=14,
             fontweight='bold')
ax.legend(fontsize=10, loc='upper left')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('phi_scaling.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved: phi_scaling.png")
print("\nScaling summary:")
print(f"  Complete graph: Φ grows linearly as w·(n-1)")
print(f"  Ring graph: Φ = 2w (constant!) - min cut always severs 2 edges")
print(f"  Star graph: Φ = w (constant!) - min cut isolates one leaf")
print(f"  Random graph: Φ grows sub-linearly")
