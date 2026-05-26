"""
Visualization: Subgroup Entropy Landscape

Visualizes how Shannon entropy of subgroup families varies across
cyclic groups Z/nZ, showing the entropy bound H ≤ log|S| and the
concentration pattern of the index⁻² weight distribution.

This reveals that groups with many divisors (highly composite numbers)
have the richest subgroup structure as measured by information content.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def divisors(n):
    divs = []
    for i in range(1, int(n**0.5) + 1):
        if n % i == 0:
            divs.append(i)
            if i != n // i:
                divs.append(n // i)
    return sorted(divs)


def compute_entropy(indices):
    weights = [1.0 / (i ** 2) for i in indices]
    Z = sum(weights)
    probs = [w / Z for w in weights]
    return -sum(p * math.log(p) for p in probs if p > 0)


def compute_max_entropy(indices):
    return math.log(len(indices))


# Compute data
ns = list(range(2, 101))
entropies = []
max_entropies = []
n_divisors = []
deficits = []

for n in ns:
    idx = divisors(n)
    H = compute_entropy(idx)
    Hmax = compute_max_entropy(idx)
    entropies.append(H)
    max_entropies.append(Hmax)
    n_divisors.append(len(idx))
    deficits.append(Hmax - H)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("Subgroup Entropy: Information Theory of Finite Group Structure",
             fontsize=14, fontweight='bold')

# Plot 1: Entropy vs group order
ax1 = axes[0, 0]
ax1.scatter(ns, entropies, c=n_divisors, cmap='viridis', s=20, alpha=0.8)
ax1.set_xlabel('Group order n (for Z/nZ)')
ax1.set_ylabel('Shannon entropy H(S)')
ax1.set_title('Subgroup Entropy vs Group Order')
cbar = plt.colorbar(ax1.scatter(ns, entropies, c=n_divisors, cmap='viridis', s=20),
                     ax=ax1, label='Number of subgroups')

# Highlight highly composite numbers
hcn = [2, 4, 6, 12, 24, 36, 48, 60]
for n in hcn:
    if n <= 100:
        idx_n = ns.index(n)
        ax1.annotate(str(n), (n, entropies[idx_n]),
                    fontsize=7, ha='center', va='bottom')

# Plot 2: Entropy bound H ≤ log|S|
ax2 = axes[0, 1]
ax2.scatter(max_entropies, entropies, c='steelblue', s=20, alpha=0.6)
diag = np.linspace(0, max(max_entropies), 100)
ax2.plot(diag, diag, 'r--', linewidth=1, label='H = log|S| (uniform)')
ax2.set_xlabel('log|S| (maximum entropy)')
ax2.set_ylabel('H(S) (actual entropy)')
ax2.set_title('Entropy Bound: H(S) ≤ log|S|')
ax2.legend()
ax2.set_aspect('equal')

# Plot 3: Entropy deficit
ax3 = axes[1, 0]
ax3.bar(ns, deficits, color='coral', alpha=0.7, width=0.8)
ax3.set_xlabel('Group order n')
ax3.set_ylabel('Entropy deficit (log|S| - H)')
ax3.set_title('Concentration: Deviation from Uniformity')

# Plot 4: Product entropy additivity verification
ax4 = axes[1, 1]
ns_small = list(range(2, 16))
H_sums = []
H_prods = []
labels = []

for i, n1 in enumerate(ns_small):
    for n2 in ns_small[i:]:
        idx1 = divisors(n1)
        idx2 = divisors(n2)
        H1 = compute_entropy(idx1)
        H2 = compute_entropy(idx2)
        prod_idx = [a * b for a in idx1 for b in idx2]
        H_prod = compute_entropy(prod_idx)
        H_sums.append(H1 + H2)
        H_prods.append(H_prod)

ax4.scatter(H_sums, H_prods, c='green', s=10, alpha=0.5)
diag2 = np.linspace(0, max(H_sums), 100)
ax4.plot(diag2, diag2, 'r--', linewidth=1, label='H(G×K) = H(G)+H(K)')
ax4.set_xlabel('H(G) + H(K)')
ax4.set_ylabel('H(G × K)')
ax4.set_title('Entropy Additivity Verification')
ax4.legend()
ax4.set_aspect('equal')

plt.tight_layout()
plt.savefig('entropy_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved entropy_landscape.png")
