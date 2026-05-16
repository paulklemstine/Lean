#!/usr/bin/env python3
"""
Applications of Tropical Algebra and Optimal Transport

Demonstrates real-world applications of the formally verified theorems:
1. Shortest path computation via tropical matrix powers
2. Network routing optimization
3. Image histogram transport (color transfer)
4. Supply chain logistics as assignment problem
"""

import numpy as np
from itertools import permutations
from typing import List, Tuple

# ============================================================
# Application 1: Shortest Paths via Tropical Powers
# ============================================================

def tropical_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Min-plus matrix multiplication."""
    return np.min(A[:, :, np.newaxis] + B[np.newaxis, :, :], axis=1)

def all_pairs_shortest_paths(weight_matrix: np.ndarray) -> np.ndarray:
    """
    Compute all-pairs shortest paths using tropical matrix powers.

    The (i,j) entry of A^{⊗n} gives the minimum weight of a path
    from i to j using at most n edges. For n vertices, A^{⊗(n-1)}
    gives all shortest paths (if no negative cycles exist).

    This is equivalent to the Floyd-Warshall / repeated squaring approach
    but expressed in the language of tropical algebra.

    Time complexity: O(n⁴) [O(n³ log n) with repeated squaring]
    """
    n = weight_matrix.shape[0]
    result = weight_matrix.copy()
    for _ in range(n - 2):
        result = tropical_multiply(result, weight_matrix)
    return result

print("=" * 60)
print("APPLICATION 1: Shortest Paths via Tropical Powers")
print("=" * 60)

# Example: 5-city road network
cities = ["NYC", "BOS", "DC", "CHI", "MIA"]
n = len(cities)
INF = 1e9  # "infinity" for no direct connection

# Distance matrix (hours of driving, approximate)
dist = np.array([
    [0,    3.5,  3.5,  12,   18],   # NYC
    [3.5,  0,    6.5,  14,   21],   # BOS
    [3.5,  6.5,  0,    10,   15],   # DC
    [12,   14,   10,   0,    20],   # CHI
    [18,   21,   15,   20,   0],    # MIA
], dtype=float)

shortest = all_pairs_shortest_paths(dist)

print(f"\nDirect distances (hours):")
for i in range(n):
    for j in range(n):
        print(f"  {cities[i]} → {cities[j]}: {dist[i,j]:.1f}h"
              + (f" (via shortcut: {shortest[i,j]:.1f}h)" if shortest[i,j] < dist[i,j] - 0.1 else ""))

print(f"\nShortest path matrix:")
header = "     " + "  ".join(f"{c:>5}" for c in cities)
print(header)
for i in range(n):
    row = f"{cities[i]:>4} " + "  ".join(f"{shortest[i,j]:5.1f}" for j in range(n))
    print(row)

# Demonstrate subadditivity: diagonal of tropical powers
print(f"\nSubadditivity verification (round-trip bounds):")
for i in range(n):
    a2 = tropical_multiply(dist, dist)[i,i]
    a3 = tropical_multiply(tropical_multiply(dist, dist), dist)[i,i]
    a4 = tropical_multiply(tropical_multiply(tropical_multiply(dist, dist), dist), dist)[i,i]
    print(f"  {cities[i]}: a₂={a2:.1f}, a₃={a3:.1f}, a₄={a4:.1f}")
    print(f"    a₄ ≤ a₂+a₂? {a4 <= a2+a2+0.01} (subadditivity)")

# ============================================================
# Application 2: Supply Chain as Assignment Problem
# ============================================================

print("\n" + "=" * 60)
print("APPLICATION 2: Supply Chain Assignment Optimization")
print("=" * 60)

factories = ["Shanghai", "Mumbai", "Detroit"]
warehouses = ["LA", "London", "Tokyo"]

# Shipping cost matrix ($/unit)
shipping_cost = np.array([
    [500,  800,  300],   # Shanghai → {LA, London, Tokyo}
    [700,  400,  900],   # Mumbai → {LA, London, Tokyo}
    [200,  600,  1100],  # Detroit → {LA, London, Tokyo}
], dtype=float)

print(f"\nShipping costs ($/unit):")
header = "           " + "  ".join(f"{w:>8}" for w in warehouses)
print(header)
for i, f in enumerate(factories):
    row = f"{f:>10} " + "  ".join(f"${shipping_cost[i,j]:7.0f}" for j in range(3))
    print(row)

# Find optimal assignment
best_cost = np.inf
best_assignment = None
for perm in permutations(range(3)):
    cost = sum(shipping_cost[i, perm[i]] for i in range(3))
    if cost < best_cost:
        best_cost = cost
        best_assignment = list(perm)

print(f"\nOptimal assignment (minimum total cost):")
for i in range(3):
    j = best_assignment[i]
    print(f"  {factories[i]} → {warehouses[j]}: ${shipping_cost[i,j]:.0f}")
print(f"  Total: ${best_cost:.0f}")

# Show this equals the Wasserstein transport cost for uniform distributions
print(f"\n  As Wasserstein-1 transport cost (uniform): ${best_cost/3:.2f} per unit")
print(f"  This is (1/n) × assignment cost, matching permPlan_transportCost theorem")

# Verify conjugation invariance
print(f"\nConjugation invariance test:")
print(f"  Relabeling factories as {factories[1]}, {factories[2]}, {factories[0]}")
e = [1, 2, 0]  # relabeling permutation
# Check if cost is invariant (generally not for arbitrary relabeling)
# But the assignment cost structure is preserved

for sigma in permutations(range(3)):
    orig_cost = sum(shipping_cost[i, sigma[i]] for i in range(3))
    # Conjugated permutation: e⁻¹ ∘ σ ∘ e
    e_inv = [2, 0, 1]
    conj = tuple(e_inv[sigma[e[i]]] for i in range(3))
    # Cost under relabeled system
    shipping_relabeled = np.array([[shipping_cost[e_inv[i], e_inv[j]]
                                     for j in range(3)] for i in range(3)])
    conj_cost = sum(shipping_relabeled[i, conj[i]] for i in range(3))
    print(f"  σ={list(sigma)}: orig={orig_cost:.0f}, conj(e⁻¹σe)={conj_cost:.0f}",
          "✓" if abs(orig_cost - conj_cost) < 0.01 else "✗")

# ============================================================
# Application 3: Color Histogram Transport
# ============================================================

print("\n" + "=" * 60)
print("APPLICATION 3: Discrete Color Histogram Transport")
print("=" * 60)

# Simplified: 4 color bins {dark, mid-dark, mid-light, light}
colors = ["dark", "mid-dark", "mid-light", "light"]
n = 4

# Cost = absolute difference in intensity levels
c = np.array([[abs(i-j) for j in range(n)] for i in range(n)], dtype=float)

# Source image histogram (dim photo)
mu = np.array([0.4, 0.35, 0.15, 0.1])

# Target image histogram (bright photo)
nu = np.array([0.1, 0.15, 0.35, 0.4])

print(f"\nSource histogram (dim image): {dict(zip(colors, mu))}")
print(f"Target histogram (bright image): {dict(zip(colors, nu))}")
print(f"Cost matrix (intensity distance):\n{c}")

# Compute optimal transport
best_cost = np.inf
best_plan = None
# For non-uniform marginals, enumerate fractional plans along edges
# Use simple LP approach for this small case
from itertools import product

# For uniform, use permutations; for general, we need LP
# Construct the "northwest corner" style solution
plan = np.zeros((n, n))
mu_rem = mu.copy()
nu_rem = nu.copy()
for i in range(n):
    for j in range(n):
        transfer = min(mu_rem[i], nu_rem[j])
        plan[i, j] = transfer
        mu_rem[i] -= transfer
        nu_rem[j] -= transfer

cost = np.sum(plan * c)
print(f"\nNorthwest-corner transport plan:")
print(f"  Plan:\n{np.round(plan, 3)}")
print(f"  Cost: {cost:.4f}")
print(f"  Row sums: {plan.sum(axis=1)} (should match μ)")
print(f"  Col sums: {plan.sum(axis=0)} (should match ν)")

# Invariance: shifting intensity levels is a cost-preserving map
e = [1, 2, 3, 0]  # cyclic shift
is_cost_invariant = all(abs(c[e[i], e[j]] - c[i, j]) < 1e-10
                        for i in range(n) for j in range(n))
print(f"\nIs cyclic shift cost-invariant? {is_cost_invariant}")
print(f"(For absolute-difference cost on a line, only identity preserves cost)")
print(f"This demonstrates that Wasserstein invariance is selective —")
print(f"it holds precisely for the isometry group of the cost structure.")

# ============================================================
# Application 4: Network Latency via Tropical Eigenvalues
# ============================================================

print("\n" + "=" * 60)
print("APPLICATION 4: Network Latency Analysis")
print("=" * 60)

# Network with 4 nodes: latency matrix
nodes = ["Server A", "Server B", "Server C", "Server D"]
latency = np.array([
    [1,   2,   5,   10],
    [2,   1,   3,   8],
    [5,   3,   1,   2],
    [10,  8,   2,   1],
], dtype=float)

print(f"\nNetwork latency matrix (ms):")
for i in range(4):
    print(f"  {nodes[i]}: {latency[i]}")

# Tropical powers give multi-hop latencies
print(f"\nMinimum round-trip latencies (tropical diagonals):")
for hops in range(1, 6):
    power = latency.copy()
    for _ in range(hops - 1):
        power = tropical_multiply(power, latency)
    print(f"  {hops}-hop round trips:", [f"{power[i,i]:.0f}ms" for i in range(4)])

# Compute asymptotic average per-hop latency (tropical eigenvalue)
print(f"\nAsymptotic per-hop latency (cycle means):")
for i in range(4):
    means = []
    power = latency.copy()
    for m in range(1, 20):
        means.append(power[i, i] / m)
        power = tropical_multiply(power, latency)
    print(f"  {nodes[i]}: converges to {min(means):.2f} ms/hop")

trop_eig = min(
    min(tropical_multiply(latency, latency)[i, i] / 2 for i in range(4)),
    min(latency[i, i] for i in range(4))
)
print(f"\nTropical eigenvalue (minimum cycle mean): {trop_eig:.2f} ms")
print(f"This represents the best achievable average latency per hop")
print(f"in a repeating communication pattern.")

print("\n" + "=" * 60)
print("All applications demonstrated successfully!")
print("=" * 60)


#!/usr/bin/env python3
"""
Demonstrations of Tropical Matrix Algebra and Discrete Optimal Transport

This module provides concrete numerical examples illustrating:
1. Min-plus (tropical) matrix multiplication
2. Subadditivity of tropical power diagonals
3. Discrete Wasserstein distance computation
4. Invariance under permutation relabeling
5. Permutation couplings and assignment costs

These demos correspond to formally verified theorems in Lean 4.
"""

import numpy as np
from itertools import permutations

# ============================================================
# 1. Tropical (Min-Plus) Matrix Multiplication
# ============================================================

def trop_mul(A, B):
    """Min-plus matrix multiplication: (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj})."""
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            C[i, j] = min(A[i, k] + B[k, j] for k in range(n))
    return C

def trop_pow(A, m):
    """Compute A^{⊗m} (m-fold tropical product). m >= 1."""
    result = A.copy()
    for _ in range(m - 1):
        result = trop_mul(result, A)
    return result

print("=" * 60)
print("DEMO 1: Tropical Matrix Multiplication")
print("=" * 60)

A = np.array([
    [0, 3, 8],
    [2, 0, 5],
    [1, 4, 0]
], dtype=float)

print(f"\nMatrix A:\n{A}")
print(f"\nA ⊗ A (tropical square):\n{trop_mul(A, A)}")
print(f"\nA ⊗ A ⊗ A (tropical cube):\n{trop_pow(A, 3)}")

# ============================================================
# 2. Subadditivity of Tropical Power Diagonals
# ============================================================

print("\n" + "=" * 60)
print("DEMO 2: Subadditivity of Tropical Power Diagonals")
print("=" * 60)
print("\nVerifying: (A^{⊗(m+k)})_{ii} ≤ (A^{⊗m})_{ii} + (A^{⊗k})_{ii}")
print("(Using 1-indexed powers: m,k ≥ 1)\n")

for i in range(3):
    print(f"  Index i = {i}:")
    for m in range(1, 5):
        for k in range(1, 5):
            lhs = trop_pow(A, m + k)[i, i]
            rhs = trop_pow(A, m)[i, i] + trop_pow(A, k)[i, i]
            status = "✓" if lhs <= rhs + 1e-10 else "✗"
            print(f"    m={m}, k={k}: A^⊗{m+k}[{i},{i}]={lhs:.1f} ≤ "
                  f"A^⊗{m}[{i},{i}] + A^⊗{k}[{i},{i}] = {rhs:.1f}  {status}")

# Show convergence to tropical eigenvalue (cycle mean)
print("\nAsymptotic cycle means (tropical eigenvalue candidates):")
for i in range(3):
    means = [trop_pow(A, m)[i, i] / m for m in range(1, 15)]
    print(f"  i={i}: {[f'{x:.3f}' for x in means]}")
    print(f"  → limit ≈ {means[-1]:.4f}")

# ============================================================
# 3. Discrete Wasserstein Distance
# ============================================================

def transport_cost(c, pi_plan):
    """Total transport cost: ∑_{i,j} π_{ij} * c_{ij}."""
    return np.sum(pi_plan * c)

def wasserstein1_brute(c, mu, nu):
    """
    Compute Wasserstein-1 by brute force over permutation couplings.
    (For uniform distributions, the optimal plan is always a permutation.)
    """
    n = len(mu)
    best_cost = np.inf
    best_perm = None
    for perm in permutations(range(n)):
        plan = np.zeros((n, n))
        for i in range(n):
            plan[i, perm[i]] = mu[i]  # general marginals
        # Check marginals
        if np.allclose(plan.sum(axis=1), mu) and np.allclose(plan.sum(axis=0), nu):
            cost = transport_cost(c, plan)
            if cost < best_cost:
                best_cost = cost
                best_perm = perm
    return best_cost, best_perm

def wasserstein1_lp(c, mu, nu):
    """Compute Wasserstein-1 by enumerating all vertex transport plans (permutations)
    for uniform distributions of equal size."""
    n = len(mu)
    best = np.inf
    for perm in permutations(range(n)):
        pi_plan = np.zeros((n, n))
        for i in range(n):
            pi_plan[i, perm[i]] = 1.0 / n
        if np.allclose(pi_plan.sum(axis=1), mu) and np.allclose(pi_plan.sum(axis=0), nu):
            cost = transport_cost(c, pi_plan)
            best = min(best, cost)
    return best

print("\n" + "=" * 60)
print("DEMO 3: Discrete Wasserstein Distance on Fin 4")
print("=" * 60)

n = 4
c = np.array([
    [0, 1, 2, 3],
    [1, 0, 1, 2],
    [2, 1, 0, 1],
    [3, 2, 1, 0]
], dtype=float)

mu = np.array([0.25, 0.25, 0.25, 0.25])
nu = np.array([0.25, 0.25, 0.25, 0.25])

w = wasserstein1_lp(c, mu, nu)
print(f"\nCost matrix c (metric on {{0,1,2,3}}):\n{c}")
print(f"μ = ν = uniform({n})")
print(f"W₁(μ, ν) = {w:.4f}")
print(f"(Expected 0 since μ = ν, achieved by identity permutation)")

# ============================================================
# 4. Wasserstein Invariance Under Permutation
# ============================================================

print("\n" + "=" * 60)
print("DEMO 4: Wasserstein Invariance Under Relabeling")
print("=" * 60)

n = 4
c = np.array([
    [0, 1, 3, 5],
    [1, 0, 2, 4],
    [3, 2, 0, 1],
    [5, 4, 1, 0]
], dtype=float)

mu = np.array([0.4, 0.3, 0.2, 0.1])
nu = np.array([0.1, 0.2, 0.3, 0.4])

# A permutation e: Fin 4 → Fin 4
e = [2, 0, 3, 1]  # e(0)=2, e(1)=0, e(2)=3, e(3)=1
e_inv = [1, 3, 0, 2]  # e⁻¹

# Check cost invariance: c(e(i), e(j)) = c(i, j)
cost_invariant = all(
    abs(c[e[i], e[j]] - c[i, j]) < 1e-10
    for i in range(n) for j in range(n)
)
print(f"\nCost matrix c:\n{c}")
print(f"Permutation e = {e}")
print(f"Cost-invariant: c(e(i), e(j)) = c(i,j)? {cost_invariant}")

if cost_invariant:
    # Pushforward: (e_* μ)(i) = μ(e⁻¹(i))
    mu_push = np.array([mu[e_inv[i]] for i in range(n)])
    nu_push = np.array([nu[e_inv[i]] for i in range(n)])

    print(f"\nμ = {mu}")
    print(f"e_*μ = {mu_push}")
    print(f"ν = {nu}")
    print(f"e_*ν = {nu_push}")

    w_original = wasserstein1_lp(c, mu, nu)
    w_pushed = wasserstein1_lp(c, mu_push, nu_push)
    print(f"\nW₁(μ, ν) = {w_original:.6f}")
    print(f"W₁(e_*μ, e_*ν) = {w_pushed:.6f}")
    print(f"Equal? {abs(w_original - w_pushed) < 1e-10} ✓")
else:
    print("Cost matrix is not invariant under this permutation.")
    # Use a cost that IS invariant
    print("\nUsing a cost matrix invariant under e...")
    c_sym = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            c_sym[i, j] = abs(i - j)
    # Make it invariant: average over orbit
    c_inv = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            c_inv[i, j] = (c_sym[i, j] + c_sym[e[i], e[j]]) / 2
    print(f"Symmetrized cost:\n{c_inv}")

# ============================================================
# 5. Permutation Couplings and Assignment Costs
# ============================================================

print("\n" + "=" * 60)
print("DEMO 5: Permutation Couplings as Assignment Problems")
print("=" * 60)

n = 3
c = np.array([
    [0, 2, 5],
    [2, 0, 3],
    [5, 3, 0]
], dtype=float)

print(f"\nCost matrix (n={n}):\n{c}")
print(f"\nAll permutation couplings and their assignment costs:")

for perm in permutations(range(n)):
    assignment_cost = sum(c[i, perm[i]] for i in range(n))
    scaled_cost = assignment_cost / n
    print(f"  σ = {perm}: ∑ c(i,σ(i)) = {assignment_cost:.1f}, "
          f"transport cost = (1/{n})·{assignment_cost:.1f} = {scaled_cost:.4f}")

print(f"\nMinimum assignment cost gives W₁ for uniform distributions.")

# Conjugation invariance
print("\nConjugation invariance demo:")
print("Verifying: ∑ c(i, (e⁻¹∘σ∘e)(i)) = ∑ c(i, σ(i))")
print("when c(e(i), e(j)) = c(i,j)")

# Use metric cost which is invariant under specific symmetries
c_metric = np.array([
    [0, 1, 2],
    [1, 0, 1],
    [2, 1, 0]
], dtype=float)

# e = (0 1 2) → (2 0 1), cyclic shift
e_perm = [2, 0, 1]
e_inv_perm = [1, 2, 0]

is_inv = all(abs(c_metric[e_perm[i], e_perm[j]] - c_metric[i,j]) < 1e-10
             for i in range(3) for j in range(3))

if is_inv:
    print(f"\nCost matrix:\n{c_metric}")
    print(f"e = {e_perm} (cyclic shift)")
    for sigma in permutations(range(3)):
        # Conjugated: e⁻¹ ∘ σ ∘ e
        conj = tuple(e_inv_perm[sigma[e_perm[i]]] for i in range(3))
        orig_cost = sum(c_metric[i, sigma[i]] for i in range(3))
        conj_cost = sum(c_metric[i, conj[i]] for i in range(3))
        print(f"  σ={sigma}, e⁻¹σe={conj}: "
              f"cost(σ)={orig_cost:.1f}, cost(e⁻¹σe)={conj_cost:.1f} "
              f"{'✓' if abs(orig_cost - conj_cost) < 1e-10 else '✗'}")
else:
    print("  (Cost not invariant under this permutation)")

print("\n" + "=" * 60)
print("All demos completed successfully!")
print("=" * 60)


#!/usr/bin/env python3
"""Generate visualizations for the tropical algebra / optimal transport project."""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO

def fig_to_base64(fig):
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"

# ============================================================
# Visualization 1: Tropical Power Diagonal Subadditivity
# ============================================================

def viz_subadditivity():
    A = np.array([[0, 3, 8], [2, 0, 5], [1, 4, 0]], dtype=float)

    def trop_mul(A, B):
        return np.min(A[:, :, np.newaxis] + B[np.newaxis, :, :], axis=1)

    max_m = 12
    powers = [A.copy()]
    for m in range(1, max_m):
        powers.append(trop_mul(powers[-1], A))

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Panel 1: Diagonal sequences
    ax = axes[0]
    for i in range(3):
        diag = [powers[m][i, i] for m in range(max_m)]
        ax.plot(range(1, max_m + 1), diag, 'o-', label=f'$a_m^{{({i})}} = (A^{{\\otimes m}})_{{{i}{i}}}$', markersize=5)
    ax.set_xlabel('Power m', fontsize=12)
    ax.set_ylabel('Diagonal value', fontsize=12)
    ax.set_title('Tropical Power Diagonals', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Panel 2: Subadditivity verification
    ax = axes[1]
    i = 0
    gaps = []
    labels = []
    for m in range(1, 7):
        for k in range(1, 7):
            lhs = powers[m + k - 1][i, i]
            rhs = powers[m - 1][i, i] + powers[k - 1][i, i]
            gaps.append(rhs - lhs)
            labels.append(f'({m},{k})')

    ax.bar(range(len(gaps)), gaps, color=['#2196F3' if g >= -1e-10 else '#F44336' for g in gaps], alpha=0.7)
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.set_xlabel('(m, k) pair index', fontsize=12)
    ax.set_ylabel('$a_m + a_k - a_{m+k}$ (≥ 0 by subadditivity)', fontsize=12)
    ax.set_title('Subadditivity Gap (all non-negative ✓)', fontsize=14)
    ax.grid(True, alpha=0.3, axis='y')

    fig.suptitle('Theorem: Tropical Power Diagonal Subadditivity', fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)

# ============================================================
# Visualization 2: Tropical Eigenvalue Convergence
# ============================================================

def viz_eigenvalue():
    A = np.array([[0, 3, 8], [2, 0, 5], [1, 4, 0]], dtype=float)

    def trop_mul(A, B):
        return np.min(A[:, :, np.newaxis] + B[np.newaxis, :, :], axis=1)

    max_m = 20
    powers = [A.copy()]
    for m in range(1, max_m):
        powers.append(trop_mul(powers[-1], A))

    fig, ax = plt.subplots(figsize=(10, 6))

    for i in range(3):
        means = [powers[m][i, i] / (m + 1) for m in range(max_m)]
        ax.plot(range(1, max_m + 1), means, 'o-', label=f'$a_m^{{({i})}}/m$', markersize=5)

    # The tropical eigenvalue is the minimum cycle mean
    # For this matrix, compute it
    cycles_2 = [min(A[i, j] + A[j, i] for j in range(3)) / 2 for i in range(3)]
    cycles_1 = [A[i, i] for i in range(3)]
    trop_eig = min(min(cycles_1), min(cycles_2))

    ax.axhline(y=trop_eig, color='red', linestyle='--', linewidth=2,
               label=f'Tropical eigenvalue λ = {trop_eig:.2f}')

    ax.set_xlabel('Power m', fontsize=12)
    ax.set_ylabel('$a_m / m$ (cycle mean)', fontsize=12)
    ax.set_title('Convergence to Tropical Eigenvalue\n(Justified by Subadditivity + Fekete\'s Lemma)', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    return fig_to_base64(fig)

# ============================================================
# Visualization 3: Transport Plan Reindexing
# ============================================================

def viz_transport_reindex():
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))

    n = 3
    # Original transport plan
    pi = np.array([[0.3, 0.1, 0.0],
                    [0.0, 0.2, 0.1],
                    [0.1, 0.0, 0.2]])

    # Permutation e = (0→1, 1→2, 2→0)
    e = [1, 2, 0]
    e_inv = [2, 0, 1]

    # Reindexed plan
    pi_reindex = np.array([[pi[e_inv[i], e_inv[j]] for j in range(n)] for i in range(n)])

    plans = [pi, pi_reindex]
    titles = ['Original Plan π', 'Reindexed Plan π\'']
    labels = [['0', '1', '2'], ['e(2)=0', 'e(0)=1', 'e(1)=2']]

    for idx, (plan, title) in enumerate(zip(plans, titles)):
        ax = axes[idx]
        im = ax.imshow(plan, cmap='Blues', vmin=0, vmax=0.4)
        ax.set_title(title, fontsize=13, fontweight='bold')
        ax.set_xlabel('Target', fontsize=11)
        ax.set_ylabel('Source', fontsize=11)
        for i in range(n):
            for j in range(n):
                ax.text(j, i, f'{plan[i,j]:.2f}', ha='center', va='center',
                       color='white' if plan[i,j] > 0.2 else 'black', fontsize=12)
        ax.set_xticks(range(n))
        ax.set_yticks(range(n))

    # Panel 3: Show the bijection
    ax = axes[2]
    ax.set_xlim(-0.5, 2.5)
    ax.set_ylim(-0.5, 2.5)
    ax.set_aspect('equal')
    ax.set_title('Reindexing Bijection e', fontsize=13, fontweight='bold')

    for i in range(3):
        ax.annotate(f'{i}', xy=(0.5, 2-i), fontsize=16, ha='center', va='center',
                   bbox=dict(boxstyle='round,pad=0.3', facecolor='#E3F2FD'))
        ax.annotate(f'{e[i]}', xy=(2, 2-i), fontsize=16, ha='center', va='center',
                   bbox=dict(boxstyle='round,pad=0.3', facecolor='#FFF3E0'))
        ax.annotate('', xy=(1.7, 2-i), xytext=(0.8, 2-i),
                    arrowprops=dict(arrowstyle='->', color='#1976D2', lw=2))

    ax.text(0.5, -0.3, 'Source', ha='center', fontsize=11, color='#1565C0')
    ax.text(2, -0.3, 'Image', ha='center', fontsize=11, color='#E65100')
    ax.axis('off')

    fig.suptitle('Transport Plan Reindexing Preserves Structure & Cost',
                fontsize=15, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)

# ============================================================
# Generate all visualizations
# ============================================================

if __name__ == "__main__":
    print("Generating visualizations...")

    viz1 = viz_subadditivity()
    print(f"  Subadditivity: {len(viz1)} chars")

    viz2 = viz_eigenvalue()
    print(f"  Eigenvalue convergence: {len(viz2)} chars")

    viz3 = viz_transport_reindex()
    print(f"  Transport reindexing: {len(viz3)} chars")

    # Save as standalone HTML for preview
    html = f"""<html><body>
    <h1>Visualizations</h1>
    <h2>1. Subadditivity</h2><img src="{viz1}"/>
    <h2>2. Eigenvalue Convergence</h2><img src="{viz2}"/>
    <h2>3. Transport Reindexing</h2><img src="{viz3}"/>
    </body></html>"""

    with open("visualizations.html", "w") as f:
        f.write(html)
    print("  Saved visualizations.html")

    # Export base64 data for PACKAGE.json
    import json
    viz_data = [
        {"name": "Tropical Power Diagonal Subadditivity", "data": viz1},
        {"name": "Tropical Eigenvalue Convergence", "data": viz2},
        {"name": "Transport Plan Reindexing", "data": viz3}
    ]
    with open("viz_data.json", "w") as f:
        json.dump(viz_data, f)
    print("  Saved viz_data.json")
    print("Done!")
