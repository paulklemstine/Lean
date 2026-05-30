"""
Visualization 2: K-Fold Log-Concavity Tower

Visualizes the hierarchy of k-fold log-concavity for binomial coefficients
and products of linear forms. Shows how the ratio sequence transforms at
each level of the tower, with log-concavity ratios at each depth.

This reveals the fractal-like structure of the k-fold hierarchy:
each level's ratio sequence becomes the input for the next level's
log-concavity test.
"""
import numpy as np
import matplotlib.pyplot as plt
import math


def ratio_seq(seq):
    """Compute ratio sequence r(m) = a(m+1)/a(m)."""
    return [seq[m + 1] / seq[m] for m in range(len(seq) - 1) if seq[m] > 0]


def lc_ratios(seq):
    """Compute log-concavity ratios a(m)^2 / (a(m-1)*a(m+1))."""
    d = len(seq) - 1
    return [seq[m]**2 / (seq[m - 1] * seq[m + 1])
            for m in range(1, d)
            if seq[m - 1] > 0 and seq[m + 1] > 0]


def convolve(a, b):
    result = [0.0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            result[i + j] += ai * bj
    return result


# Generate test sequences
d = 15
binomial = [float(math.comb(d, m)) for m in range(d + 1)]

# Product of 15 distinct linear forms
np.random.seed(42)
forms = [(np.random.uniform(0.5, 3), np.random.uniform(0.5, 3)) for _ in range(d)]
poly = [1.0]
for a, b in forms:
    poly = convolve(poly, [a, b])

sequences = {
    f'Binomial C({d},m)': binomial,
    f'Product of {d} linear forms': poly,
}

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

for row, (name, seq) in enumerate(sequences.items()):
    current = seq[:]
    
    for col in range(3):
        ax = axes[row, col]
        
        if len(current) < 3:
            ax.text(0.5, 0.5, 'Too short', ha='center', va='center',
                    transform=ax.transAxes, fontsize=14)
            ax.set_title(f'Level {col}: Ratio sequence')
            continue
        
        # Plot the sequence
        x = np.arange(len(current))
        ax.bar(x, current, alpha=0.6, color=['#2196F3', '#FF9800', '#4CAF50'][col])
        
        # Compute and annotate LC ratios
        ratios = lc_ratios(current)
        min_r = min(ratios) if ratios else float('inf')
        is_lc = min_r >= 1.0 - 1e-10
        
        status = '✓' if is_lc else '✗'
        color = '#2E7D32' if is_lc else '#C62828'
        
        ax.set_title(f'Level {col}: {"Original" if col == 0 else "Iterated ratio"}\n'
                     f'LC ratio ≥ {min_r:.4f} {status}',
                     fontsize=11, color=color)
        ax.set_xlabel('Index m')
        ax.set_ylabel('Value')
        
        if col == 0:
            ax.set_ylabel(name, fontsize=11, fontweight='bold')
        
        # Compute ratio sequence for next level
        current = ratio_seq(current)

plt.suptitle('K-Fold Log-Concavity Tower\n'
             'Each level applies the ratio operator and checks log-concavity',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_kfold_tower.png', dpi=150, bbox_inches='tight')
print("Saved viz_kfold_tower.png")
