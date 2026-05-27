"""
Visualization 2: k-Fold Log-Concavity Depth Across Families

Shows the iterated ratio transforms and their log-concavity status for
a product of linear forms, illustrating how recursive Lorentzian depth
translates to layers of log-concavity in the coefficient sequence.

This creates a multi-panel plot showing the original sequence, ratio
transform, second ratio transform, etc., with log-concavity status.
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


def compute_depth(seq, max_depth=15):
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


# Generate data
d = 8
coeffs = product_of_linear_forms(d, weights=[0.15 * (i+1) for i in range(d)])

fig, axes = plt.subplots(3, 2, figsize=(14, 12))
fig.suptitle(f'Iterated Ratio Transforms (degree {d}, product of linear forms)\n'
             'Each level of Lorentzian depth ↔ one level of log-concavity',
             fontsize=14, fontweight='bold')

current = list(coeffs)
for level in range(6):
    ax = axes[level // 2][level % 2]

    if len(current) < 2:
        ax.text(0.5, 0.5, 'Sequence too short', ha='center', va='center',
                transform=ax.transAxes, fontsize=12)
        ax.set_title(f'Level {level}')
        continue

    lc = is_log_concave(current) if len(current) >= 3 else True
    color = '#4CAF50' if lc else '#F44336'

    ax.plot(range(len(current)), current, 'o-', color=color, markersize=6,
            linewidth=2, label=f'Log-concave: {lc}')
    ax.fill_between(range(len(current)), current, alpha=0.2, color=color)

    if level == 0:
        title = f'Level 0: Original coefficients'
    else:
        title = f'Level {level}: {"Ratio" if level == 1 else f"{level}× ratio"} transform'

    ax.set_title(f'{title} — {"✓ LC" if lc else "✗ not LC"}',
                 fontsize=11, color='darkgreen' if lc else 'darkred')
    ax.set_xlabel('Index')
    ax.set_ylabel('Value')
    ax.legend(loc='upper right')
    ax.grid(True, alpha=0.3)

    current = ratio_transform(current)
    if not current or any(x <= 0 for x in current):
        for remaining in range(level + 1, 6):
            ax_r = axes[remaining // 2][remaining % 2]
            ax_r.text(0.5, 0.5, 'Ratio not positive\n(sequence terminates)',
                     ha='center', va='center', transform=ax_r.transAxes, fontsize=12)
            ax_r.set_title(f'Level {remaining}')
        break

# Add depth summary
depth = compute_depth(coeffs)
fig.text(0.5, 0.01, f'k-fold log-concavity depth = {depth}', ha='center',
         fontsize=13, fontweight='bold',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.tight_layout(rect=[0, 0.03, 1, 0.95])
plt.savefig('kfold_depth.png', dpi=150, bbox_inches='tight')
print("Saved kfold_depth.png")
