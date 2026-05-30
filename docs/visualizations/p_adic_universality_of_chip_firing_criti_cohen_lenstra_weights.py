#!/usr/bin/env python3
"""
Visualization: Cohen-Lenstra Weights and the Number Theory Connection
Shows how the Cohen-Lenstra distribution bridges chip-firing theory
with algebraic number theory.
"""

import numpy as np
import matplotlib.pyplot as plt

# ============================================================
# Self-contained: Cohen-Lenstra weight computation
# ============================================================

def cohen_lenstra_weight(p, k):
    """W(p,k) = ∏_{i=1}^{k} (1 - p^{-i})"""
    w = 1.0
    for i in range(1, k + 1):
        w *= (1 - (1.0 / p) ** i)
    return w

def cohen_lenstra_prob(p, partition, r=1):
    """
    Cohen-Lenstra probability for a specific abelian p-group type.
    For a group of type (p^{a1}, p^{a2}, ..., p^{ak}) with a1 ≥ a2 ≥ ... ≥ ak > 0:
    Prob ∝ 1/|Aut(G)| · W(p, r)
    """
    k = len(partition)
    total = sum(partition)
    
    # |Aut(G)| computation (simplified for small cases)
    aut_size = 1.0
    for i in range(k):
        for j in range(i, k):
            if partition[i] == partition[j]:
                aut_size *= (p ** partition[i] - p ** (partition[i] - 1) if i == j
                           else p ** min(partition[i], partition[j]))
    
    return p ** (-total) / max(aut_size, 1e-10)

# ============================================================
# Figure
# ============================================================

fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# --- Panel 1: Cohen-Lenstra weights for different primes ---
ax = axes[0, 0]
primes = [2, 3, 5, 7, 11, 13]
ks = range(0, 15)
colors_p = plt.cm.viridis(np.linspace(0.1, 0.9, len(primes)))

for idx, p in enumerate(primes):
    weights = [cohen_lenstra_weight(p, k) for k in ks]
    ax.plot(list(ks), weights, 'o-', label=f'p = {p}', color=colors_p[idx],
            markersize=4, linewidth=1.5)

ax.set_xlabel('Number of cyclic factors k', fontsize=11)
ax.set_ylabel('Cohen-Lenstra weight W(p, k)', fontsize=11)
ax.set_title('Cohen-Lenstra Weights W(p, k) = ∏(1 - p⁻ⁱ)\nDecreasing in k (proven in Lean), positive (proven in Lean)',
             fontsize=11)
ax.legend(fontsize=9, ncol=2)
ax.grid(True, alpha=0.3)
ax.set_ylim(0, 1.05)

# --- Panel 2: Convergence of W(p, k) as k → ∞ ---
ax2 = axes[0, 1]
for idx, p in enumerate([2, 3, 5, 7]):
    ks_long = range(0, 50)
    weights = [cohen_lenstra_weight(p, k) for k in ks_long]
    limit = weights[-1]  # Approximate limit
    ax2.plot(list(ks_long), weights, '-', color=colors_p[idx], linewidth=2,
             label=f'p = {p} → {limit:.4f}')
    ax2.axhline(y=limit, color=colors_p[idx], linestyle=':', alpha=0.5)

ax2.set_xlabel('k', fontsize=11)
ax2.set_ylabel('W(p, k)', fontsize=11)
ax2.set_title('Convergence of W(p, k) to ∏_{i≥1}(1 - p⁻ⁱ)\n(infinite product = 1/|GL_∞(𝔽_p)|)', fontsize=11)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# --- Panel 3: Ratio W(p,k)/W(p,k-1) ---
ax3 = axes[1, 0]
for idx, p in enumerate([2, 3, 5, 7]):
    ratios = []
    for k in range(1, 20):
        w_k = cohen_lenstra_weight(p, k)
        w_km1 = cohen_lenstra_weight(p, k - 1)
        ratios.append(w_k / w_km1)
    ax3.plot(range(1, 20), ratios, 'o-', color=colors_p[idx],
             label=f'p = {p}', markersize=4, linewidth=1.5)

ax3.set_xlabel('k', fontsize=11)
ax3.set_ylabel('W(p,k) / W(p,k-1)', fontsize=11)
ax3.set_title('Successive Ratios: Each Factor (1 - p⁻ᵏ) → 1\nFaster convergence for larger p', fontsize=11)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)
ax3.axhline(y=1, color='black', linestyle='--', alpha=0.5)
ax3.set_ylim(0.45, 1.02)

# --- Panel 4: The number theory connection ---
ax4 = axes[1, 1]

# Show the analogy between ideal class groups and sandpile groups
# Plot: probability of trivial p-part vs p
primes_wide = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]

# Cohen-Lenstra prediction: Prob(trivial p-part) = ∏_{i≥1}(1-p^{-i}) (for r=1)
cl_probs = [cohen_lenstra_weight(p, 50) for p in primes_wide]  # k=50 ≈ ∞

ax4.bar(range(len(primes_wide)), cl_probs, color='steelblue', alpha=0.8,
        edgecolor='navy', linewidth=0.5)
ax4.set_xticks(range(len(primes_wide)))
ax4.set_xticklabels([str(p) for p in primes_wide], fontsize=9)
ax4.set_xlabel('Prime p', fontsize=11)
ax4.set_ylabel('Prob(trivial Sylow-p subgroup)', fontsize=11)
ax4.set_title('Cohen-Lenstra Prediction:\nProbability of Trivial p-Part in Random Groups', fontsize=11)
ax4.grid(True, alpha=0.3, axis='y')

# Annotate key values
for i, (p, prob) in enumerate(zip(primes_wide, cl_probs)):
    if i < 5:
        ax4.text(i, prob + 0.01, f'{prob:.3f}', ha='center', va='bottom', fontsize=8)

plt.suptitle('Cohen-Lenstra Heuristics: Bridging Tropical Geometry and Number Theory',
             fontsize=14, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig('viz_cohen_lenstra.png', dpi=150, bbox_inches='tight')
print("Saved viz_cohen_lenstra.png")
