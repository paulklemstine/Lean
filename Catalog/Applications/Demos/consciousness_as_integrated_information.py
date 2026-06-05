#!/usr/bin/env python3
"""
Demonstration of Causal Integration Theory (CIT)

Computes Phi (integrated information) for various causal networks,
illustrating the key theorems proved in Lean 4.
"""

import numpy as np
from itertools import combinations

def cross_weight(W, S):
    """Compute cross-weight of subset S in network with weight matrix W."""
    n = W.shape[0]
    S_set = set(S)
    Sc = [i for i in range(n) if i not in S_set]
    cw = 0.0
    for i in S:
        for j in Sc:
            cw += W[i, j]
    for i in Sc:
        for j in S:
            cw += W[i, j]
    return cw

def phi(W):
    """Compute Phi: minimum cross-weight over all non-trivial bipartitions."""
    n = W.shape[0]
    if n < 2:
        return 0.0
    min_cw = float('inf')
    for k in range(1, n):
        for S in combinations(range(n), k):
            cw = cross_weight(W, S)
            if cw < min_cw:
                min_cw = cw
                min_S = S
    return min_cw

def total_weight(W):
    return W.sum()

def internal_weight(W, S):
    S = list(S)
    return sum(W[i, j] for i in S for j in S)

def integration_complexity(W):
    """Number of distinct cross-weight values."""
    n = W.shape[0]
    values = set()
    for k in range(1, n):
        for S in combinations(range(n), k):
            values.add(round(cross_weight(W, S), 10))
    return len(values)

# ============================================================
# Demo 1: Uniform complete network
# ============================================================
print("=" * 60)
print("DEMO 1: Uniform Complete Network")
print("=" * 60)
for n in [3, 4, 5]:
    w = 1.0
    W = np.full((n, n), w)
    p = phi(W)
    expected = 2 * w * (n - 1)
    print(f"  n={n}: Phi = {p:.1f}, expected 2*w*(n-1) = {expected:.1f} ✓" if abs(p - expected) < 1e-9 else f"  n={n}: MISMATCH")

# ============================================================
# Demo 2: Block-diagonal (disconnected) network
# ============================================================
print(f"\n{'=' * 60}")
print("DEMO 2: Block-Diagonal Network (Phi should be 0)")
print("=" * 60)
W = np.array([
    [1, 2, 0, 0],
    [3, 1, 0, 0],
    [0, 0, 2, 1],
    [0, 0, 3, 2]
], dtype=float)
p = phi(W)
print(f"  Block-diagonal 4-node: Phi = {p:.1f} (should be 0) {'✓' if p == 0 else '✗'}")

# ============================================================
# Demo 3: Scaling invariance
# ============================================================
print(f"\n{'=' * 60}")
print("DEMO 3: Scaling Invariance (Phi(cW) = c * Phi(W))")
print("=" * 60)
W_base = np.array([
    [0, 1, 0.5],
    [2, 0, 1],
    [0.5, 1.5, 0]
], dtype=float)
p_base = phi(W_base)
for c in [0.5, 2.0, 3.0, 10.0]:
    p_scaled = phi(c * W_base)
    expected = c * p_base
    match = abs(p_scaled - expected) < 1e-9
    print(f"  c={c}: Phi(cW)={p_scaled:.2f}, c*Phi(W)={expected:.2f} {'✓' if match else '✗'}")

# ============================================================
# Demo 4: Weight decomposition
# ============================================================
print(f"\n{'=' * 60}")
print("DEMO 4: Weight Decomposition (total = internal(S) + internal(Sc) + cross(S))")
print("=" * 60)
W = np.random.RandomState(42).rand(5, 5)
for S in [(0,), (0, 1), (0, 1, 2), (0, 2, 4)]:
    Sc = tuple(i for i in range(5) if i not in S)
    tw = total_weight(W)
    iw_S = internal_weight(W, S)
    iw_Sc = internal_weight(W, Sc)
    cw = cross_weight(W, S)
    decomp = iw_S + iw_Sc + cw
    match = abs(tw - decomp) < 1e-10
    print(f"  S={S}: total={tw:.4f}, internal(S)+internal(Sc)+cross(S)={decomp:.4f} {'✓' if match else '✗'}")

# ============================================================
# Demo 5: Integration complexity
# ============================================================
print(f"\n{'=' * 60}")
print("DEMO 5: Integration Complexity")
print("=" * 60)
# Uniform network: all cross-weights are 2w*|S|*|Sc|, so complexity = n-1 (distinct products |S|*(n-|S|))
for n in [3, 4, 5, 6]:
    W_unif = np.ones((n, n))
    ic = integration_complexity(W_unif)
    max_bipartitions = 2**n - 2
    print(f"  n={n}: complexity={ic}, max bipartitions={max_bipartitions}, ratio={ic/max_bipartitions:.2f}")

# Random network: typically high complexity
W_rand = np.random.RandomState(123).rand(5, 5)
ic = integration_complexity(W_rand)
print(f"  Random 5-node: complexity={ic}, max=30")

# ============================================================
# Demo 6: Edge addition monotonicity
# ============================================================
print(f"\n{'=' * 60}")
print("DEMO 6: Edge Addition (crossing edge increases cross-weight)")
print("=" * 60)
W = np.array([
    [0, 1, 0],
    [1, 0, 1],
    [0, 1, 0]
], dtype=float)
S = (0,)
cw_before = cross_weight(W, S)
delta = 5.0
W_new = W.copy()
W_new[0, 2] += delta  # crossing edge (0 in S, 2 not in S)
cw_after = cross_weight(W_new, S)
print(f"  Before: cross({S})={cw_before:.1f}")
print(f"  After adding δ={delta} to edge (0,2): cross({S})={cw_after:.1f}")
print(f"  Increase ≥ δ: {cw_after - cw_before:.1f} ≥ {delta} {'✓' if cw_after - cw_before >= delta - 1e-10 else '✗'}")

print(f"\n{'=' * 60}")
print("All demonstrations complete.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Integration Landscape

Shows how Phi varies as we interpolate between a disconnected and fully connected network.
"""
import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations

def cross_weight(W, S):
    n = W.shape[0]
    S_set = set(S)
    Sc = [i for i in range(n) if i not in S_set]
    cw = 0.0
    for i in S:
        for j in Sc:
            cw += W[i, j]
    for i in Sc:
        for j in S:
            cw += W[i, j]
    return cw

def phi(W):
    n = W.shape[0]
    if n < 2:
        return 0.0
    min_cw = float('inf')
    for k in range(1, n):
        for S in combinations(range(n), k):
            cw = cross_weight(W, S)
            min_cw = min(min_cw, cw)
    return min_cw

# Block-diagonal base network
n = 5
W_block = np.zeros((n, n))
# Block 1: nodes 0,1
W_block[0, 1] = 3; W_block[1, 0] = 2
# Block 2: nodes 2,3,4
W_block[2, 3] = 1; W_block[3, 2] = 2
W_block[3, 4] = 1; W_block[4, 3] = 3
W_block[2, 4] = 0.5; W_block[4, 2] = 1

# Cross-edges to add
W_cross = np.zeros((n, n))
W_cross[1, 2] = 1; W_cross[2, 0] = 1
W_cross[0, 3] = 0.5; W_cross[4, 1] = 0.5

# Interpolate
alphas = np.linspace(0, 3, 100)
phis = [phi(W_block + a * W_cross) for a in alphas]

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left: Phi vs alpha
ax = axes[0]
ax.plot(alphas, phis, 'b-', linewidth=2)
ax.axhline(y=0, color='r', linestyle='--', alpha=0.5, label='Disconnected (Φ=0)')
ax.set_xlabel('Cross-link strength α', fontsize=13)
ax.set_ylabel('Φ (Integrated Information)', fontsize=13)
ax.set_title('Phase Transition: Disconnected → Integrated', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Right: Integration profile for a specific network
ax = axes[1]
W_example = W_block + 1.5 * W_cross
profile = {}
for k in range(1, n):
    for S in combinations(range(n), k):
        profile[S] = cross_weight(W_example, S)

sorted_profile = sorted(profile.values())
ax.bar(range(len(sorted_profile)), sorted_profile, color='steelblue', alpha=0.7)
ax.axhline(y=phi(W_example), color='r', linestyle='--', linewidth=2, label=f'Φ = {phi(W_example):.2f}')
ax.set_xlabel('Bipartition index (sorted by cross-weight)', fontsize=13)
ax.set_ylabel('Cross-weight', fontsize=13)
ax.set_title('Integration Profile (α=1.5)', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('integration_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved integration_landscape.png")
