"""
Visualization: Quadratic Residue Separation Heatmap

This script visualizes the Pell separation conjecture by computing
quadratic residue counts for various squarefree integers d mod primes p,
and displaying a heatmap showing which pairs are separated.
"""

import matplotlib.pyplot as plt
import numpy as np


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def primes_up_to(n):
    return [p for p in range(2, n + 1) if is_prime(p)]


def quad_res_count(d, p):
    """Count #{x in F_p : x^2 = d mod p}."""
    return sum(1 for x in range(p) if (x * x) % p == d % p)


fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# ── Panel 1: Quadratic residue count heatmap ──

ax = axes[0]
d_values = [2, 3, 5, 6, 7, 10, 11, 13, 14, 15]
primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]

data = np.zeros((len(d_values), len(primes)))
for i, d in enumerate(d_values):
    for j, p in enumerate(primes):
        data[i, j] = quad_res_count(d, p)

im = ax.imshow(data, cmap='YlOrRd', aspect='auto', interpolation='nearest')
ax.set_xticks(range(len(primes)))
ax.set_xticklabels([str(p) for p in primes], fontsize=9)
ax.set_yticks(range(len(d_values)))
ax.set_yticklabels([f'd={d}' for d in d_values], fontsize=9)
ax.set_xlabel('Prime p', fontsize=11)
ax.set_ylabel('Squarefree d', fontsize=11)
ax.set_title('Quadratic Residue Counts\n#{x ∈ 𝔽_p : x² ≡ d (mod p)}',
             fontsize=12, fontweight='bold')

# Add text annotations
for i in range(len(d_values)):
    for j in range(len(primes)):
        val = int(data[i, j])
        color = 'white' if val >= 2 else 'black'
        ax.text(j, i, str(val), ha='center', va='center',
                fontsize=8, color=color, fontweight='bold')

plt.colorbar(im, ax=ax, label='Count', shrink=0.8)

# ── Panel 2: Separation matrix ──

ax = axes[1]
n_d = len(d_values)
sep_matrix = np.zeros((n_d, n_d))

for i in range(n_d):
    for j in range(n_d):
        if i == j:
            sep_matrix[i, j] = 0
        else:
            # Check if separated by any prime
            separated = any(
                quad_res_count(d_values[i], p) != quad_res_count(d_values[j], p)
                for p in primes
            )
            # Find first separating prime
            if separated:
                first_sep = next(
                    p for p in primes
                    if quad_res_count(d_values[i], p) != quad_res_count(d_values[j], p)
                )
                sep_matrix[i, j] = primes.index(first_sep) + 1
            else:
                sep_matrix[i, j] = -1  # not separated

# Custom colormap
cmap = plt.cm.viridis.copy()
cmap.set_under('red')  # unseparated pairs in red

im2 = ax.imshow(sep_matrix, cmap=cmap, aspect='auto', vmin=0,
                interpolation='nearest')
ax.set_xticks(range(n_d))
ax.set_xticklabels([f'd={d}' for d in d_values], fontsize=8, rotation=45)
ax.set_yticks(range(n_d))
ax.set_yticklabels([f'd={d}' for d in d_values], fontsize=9)
ax.set_title('Separation Matrix\n(color = index of first separating prime)',
             fontsize=12, fontweight='bold')

# Add text
for i in range(n_d):
    for j in range(n_d):
        if i == j:
            ax.text(j, i, '·', ha='center', va='center', fontsize=10,
                    color='gray')
        elif sep_matrix[i, j] < 0:
            ax.text(j, i, '✗', ha='center', va='center', fontsize=10,
                    color='red', fontweight='bold')
        else:
            p_idx = int(sep_matrix[i, j]) - 1
            ax.text(j, i, f'p={primes[p_idx]}', ha='center', va='center',
                    fontsize=6, color='white' if p_idx > 3 else 'black')

plt.colorbar(im2, ax=ax, label='Separating prime index', shrink=0.8)

plt.tight_layout()
plt.savefig('separation_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved separation_heatmap.png")
