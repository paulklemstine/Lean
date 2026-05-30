"""
Visualization: Approximate Subgroup Classification Map

Creates a heatmap showing the doubling constant σ(A) = |A+A|/|A| and 
tripling constant τ(A) = |A+A+A|/|A| for various subsets of Z/nZ.
The K=1 region corresponds to genuine subgroups (our main theorem).
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations


def product_set(A, B, n):
    """Product set in Z/nZ."""
    return set((a + b) % n for a in A for b in B)


def compute_constants(A, n):
    """Compute doubling and tripling constants."""
    if len(A) == 0:
        return 0, 0
    AA = product_set(A, A, n)
    AAA = product_set(AA, A, n)
    return len(AA) / len(A), len(AAA) / len(A)


def is_subgroup(A, n):
    """Check if A forms a subgroup of Z/nZ."""
    if 0 not in A:
        return False
    for a in A:
        if (-a) % n not in A:
            return False
    return product_set(A, A, n) == A


# Collect data for Z/24Z
n = 24
doublings = []
triplings = []
sizes = []
is_sub = []
labels = []

# Generate symmetric sets containing 0
elements = list(range(1, n))
tested = set()

for size in range(1, 9):
    # For each size, generate symmetric sets
    half_elements = [x for x in range(1, n//2 + 1)]
    
    for combo in combinations(half_elements, size):
        A = {0}
        for x in combo:
            A.add(x)
            A.add((-x) % n)
        
        A_key = frozenset(A)
        if A_key in tested:
            continue
        tested.add(A_key)
        
        sigma, tau = compute_constants(A, n)
        doublings.append(sigma)
        triplings.append(tau)
        sizes.append(len(A))
        is_sub.append(is_subgroup(A, n))
        labels.append(sorted(A))

doublings = np.array(doublings)
triplings = np.array(triplings)
sizes = np.array(sizes)
is_sub_arr = np.array(is_sub)

fig, ax = plt.subplots(figsize=(10, 8))

# Plot non-subgroups
mask_nonsub = ~is_sub_arr
scatter1 = ax.scatter(doublings[mask_nonsub], triplings[mask_nonsub], 
                      c=sizes[mask_nonsub], cmap='viridis', s=30, alpha=0.6,
                      edgecolors='none', label='Non-subgroup')

# Plot subgroups prominently
mask_sub = is_sub_arr
ax.scatter(doublings[mask_sub], triplings[mask_sub],
           c='red', s=150, marker='*', edgecolors='black',
           linewidths=1, label='Subgroup (K=1)', zorder=5)

# Add diagonal reference line σ ≤ τ
max_val = max(max(doublings), max(triplings)) + 0.5
ax.plot([1, max_val], [1, max_val], 'k--', alpha=0.3, label='σ = τ')

# Labels and formatting
ax.set_xlabel('Doubling constant σ = |A+A|/|A|', fontsize=13)
ax.set_ylabel('Tripling constant τ = |A+A+A|/|A|', fontsize=13)
ax.set_title(f'Approximate Subgroup Landscape in Z/{n}Z\n'
             'Subgroups cluster at (1, 1); non-subgroups show σ ≤ τ',
             fontsize=14)

cbar = plt.colorbar(scatter1, ax=ax, label='|A|')
ax.legend(fontsize=11, loc='upper left')
ax.grid(True, alpha=0.2)
ax.set_xlim(0.8, max_val)
ax.set_ylim(0.8, max_val)

# Annotate the K=1 region
ax.axvspan(0.8, 1.05, alpha=0.1, color='red')
ax.axhspan(0.8, 1.05, alpha=0.1, color='red')
ax.annotate('K=1 region\n(Subgroups)', xy=(1.0, 1.0),
            xytext=(2.0, 1.5), fontsize=11,
            arrowprops=dict(arrowstyle='->', color='red'),
            color='red', fontweight='bold')

plt.tight_layout()
plt.savefig('approx_subgroups.png', dpi=150, bbox_inches='tight')
print("Saved approx_subgroups.png")
