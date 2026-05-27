"""
Visualization 3: Bridge Theorem Heatmap — Lorentzian Depth vs Log-Concavity Depth

Creates a heatmap showing the relationship between polynomial degree,
Lorentzian depth, and achieved k-fold log-concavity depth for various
families of Lorentzian polynomials.

This directly illustrates the main theorem: recursive Lorentzian depth k
implies k-fold log-concavity of bivariate specialization coefficients.
"""

import math
import numpy as np
import matplotlib.pyplot as plt


def product_of_linear_forms(d, weights=None):
    if weights is None:
        weights = [(i + 1) / (d + 1) for i in range(d)]
    coeffs = [1.0]
    for w in weights:
        new_coeffs = [0.0] * (len(coeffs) + 1)
        for i, c in enumerate(coeffs):
            new_coeffs[i] += c * (1 - w)
            new_coeffs[i + 1] += c * w
        coeffs = new_coeffs
    return coeffs


def is_log_concave(seq, tol=1e-12):
    for m in range(1, len(seq) - 1):
        if seq[m] ** 2 < seq[m-1] * seq[m+1] - tol:
            return False
    return True


def ratio_transform(seq):
    if len(seq) < 2 or any(x == 0 for x in seq):
        return []
    return [seq[m+1]/seq[m] for m in range(len(seq)-1)]


def compute_depth(seq, max_depth=20):
    current = list(seq)
    for k in range(max_depth):
        if len(current) < 3:
            return k
        if not is_log_concave(current):
            return k
        current = ratio_transform(current)
        if not current or any(x <= 0 for x in current):
            return k + 1
    return max_depth


# Generate depth data for various degrees and weight configurations
degrees = list(range(3, 16))
n_configs = 8

# Weight configurations
def make_weights(d, config_idx):
    if config_idx == 0:
        return [0.5] * d  # uniform
    elif config_idx == 1:
        return [(i+1)/(d+1) for i in range(d)]  # linear
    elif config_idx == 2:
        return [0.1 + 0.8*i/max(d-1,1) for i in range(d)]  # spread
    elif config_idx == 3:
        return [0.9] * d  # skewed high
    elif config_idx == 4:
        return [0.1] * d  # skewed low
    elif config_idx == 5:
        return [(i+1)**2 / (d+1)**2 for i in range(d)]  # quadratic
    elif config_idx == 6:
        return [math.sqrt((i+1)/(d+1)) for i in range(d)]  # sqrt
    else:
        return [0.5 + 0.3*math.sin(2*math.pi*i/d) for i in range(d)]  # oscillating


config_names = ['Uniform 0.5', 'Linear', 'Spread', 'Skew high',
                'Skew low', 'Quadratic', 'Sqrt', 'Oscillating']

depth_matrix = np.zeros((n_configs, len(degrees)))

for j, d in enumerate(degrees):
    for i in range(n_configs):
        weights = make_weights(d, i)
        coeffs = product_of_linear_forms(d, weights)
        depth = compute_depth(coeffs)
        depth_matrix[i, j] = depth

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))

# Heatmap
im = ax1.imshow(depth_matrix, aspect='auto', cmap='YlOrRd',
                interpolation='nearest')
ax1.set_xticks(range(len(degrees)))
ax1.set_xticklabels(degrees)
ax1.set_yticks(range(n_configs))
ax1.set_yticklabels(config_names, fontsize=9)
ax1.set_xlabel('Polynomial Degree d')
ax1.set_ylabel('Weight Configuration')
ax1.set_title('k-Fold Log-Concavity Depth\nfor Products of Linear Forms')

# Add text annotations
for i in range(n_configs):
    for j in range(len(degrees)):
        ax1.text(j, i, f'{int(depth_matrix[i,j])}', ha='center', va='center',
                fontsize=8, color='white' if depth_matrix[i,j] > 5 else 'black')

plt.colorbar(im, ax=ax1, label='k-fold depth')

# Line plot: depth vs degree for selected families
for i in [0, 1, 2, 5]:
    ax2.plot(degrees, depth_matrix[i, :], 'o-', label=config_names[i], linewidth=2)

# Theoretical bound d-2
ax2.plot(degrees, [d-2 for d in degrees], 'k--', linewidth=2, label='d-2 (theoretical max)')

ax2.set_xlabel('Polynomial Degree d', fontsize=12)
ax2.set_ylabel('k-Fold Log-Concavity Depth', fontsize=12)
ax2.set_title('Depth vs Degree\n(Bridge Theorem: depth k ⟹ k-fold LC)')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('bridge_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved bridge_heatmap.png")
