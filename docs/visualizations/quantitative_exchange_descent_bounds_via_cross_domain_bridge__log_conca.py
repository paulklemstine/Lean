"""
Visualization 3: Cross-Domain Bridge — Log-Concavity to Descent Bounds

Illustrates the central cross-domain connection: higher-order log-concavity
of weight sequences generates deeper exchange certificates, which in turn
produce tighter descent bounds.

Left panel: Log-concavity hierarchy — ratio sequences at different depths.
Right panel: The certificate depth ladder, showing how analytic structure
(log-concavity) translates to algorithmic guarantees (descent bounds).

This visualization shows why the theory creates a genuine bridge between
analytic combinatorics and discrete optimization.
"""

import numpy as np
import matplotlib.pyplot as plt


def gaussian_sequence(n_terms=20, sigma=2.0):
    """Generate a Gaussian-like positive sequence (infinitely log-concave)."""
    return np.array([np.exp(-i**2 / (2 * sigma**2)) for i in range(n_terms)])


def ratio_sequence(a):
    """Compute ratio sequence r(n) = a(n+1) / a(n)."""
    return a[1:] / np.maximum(a[:-1], 1e-15)


def check_log_concavity(a):
    """Check if a(n+1)^2 >= a(n) * a(n+2) for all n."""
    violations = 0
    for n in range(len(a) - 2):
        if a[n+1]**2 < a[n] * a[n+2] - 1e-10:
            violations += 1
    return violations == 0


def kfold_depth(a, max_depth=10):
    """Estimate the k-fold log-concavity depth of sequence a."""
    current = a.copy()
    for k in range(max_depth):
        if len(current) < 3:
            return k
        if not check_log_concavity(current):
            return k
        if not np.all(current > 1e-15):
            return k
        current = ratio_sequence(current)
    return max_depth


fig, axes = plt.subplots(1, 2, figsize=(14, 7))

# Panel 1: Iterated ratio sequences
ax1 = axes[0]

# Generate a Gaussian sequence and its iterated ratios
a = gaussian_sequence(n_terms=15, sigma=3.0)

colors = ['#2c3e50', '#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6']
labels = ['Original a(n)', 'Ratio r¹(n)', 'Ratio r²(n)',
          'Ratio r³(n)', 'Ratio r⁴(n)']

current = a.copy()
for depth in range(5):
    if len(current) < 3:
        break

    # Normalize for plotting
    current_norm = current / np.max(np.abs(current)) if np.max(np.abs(current)) > 0 else current

    ax1.plot(range(len(current_norm)), current_norm, 'o-',
            color=colors[depth], linewidth=2, markersize=6,
            label=labels[depth], alpha=0.8)

    is_lc = check_log_concavity(current)
    ax1.annotate(f'{"✓ LC" if is_lc else "✗"}',
                xy=(len(current_norm) - 1, current_norm[-1]),
                fontsize=9, color=colors[depth], fontweight='bold')

    current = ratio_sequence(current)

ax1.set_xlabel('Index n', fontsize=13)
ax1.set_ylabel('Normalized Value', fontsize=13)
ax1.set_title('Iterated Ratio Sequences\n(Gaussian: all levels log-concave)', fontsize=14)
ax1.legend(fontsize=10, loc='lower left')
ax1.grid(True, alpha=0.3)

# Panel 2: The bridge diagram
ax2 = axes[1]
ax2.set_xlim(0, 10)
ax2.set_ylim(0, 10)
ax2.set_aspect('equal')
ax2.axis('off')
ax2.set_title('Certificate Depth Ladder:\nLog-Concavity → Descent Bounds', fontsize=14)

# Draw the ladder
ladder_x = 5
rung_width = 3
rungs = [
    (1.5, 'k=1: Basic DLC\nBound: O(d^{d-1}·D)', '#e74c3c'),
    (3.5, 'k=2: 2-fold certificate\nBound: O(d^{d-2}·D)', '#f39c12'),
    (5.5, 'k=d/2: Half-depth\nBound: O(d^{d/2}·D)', '#3498db'),
    (7.5, 'k=d: Maximal depth\nBound: O(D)  ★ Linear!', '#2ecc71'),
]

# Vertical rails
ax2.plot([ladder_x - rung_width/2, ladder_x - rung_width/2],
        [0.5, 9], '-', color='#7f8c8d', linewidth=3)
ax2.plot([ladder_x + rung_width/2, ladder_x + rung_width/2],
        [0.5, 9], '-', color='#7f8c8d', linewidth=3)

for y, text, color in rungs:
    # Rung
    ax2.plot([ladder_x - rung_width/2, ladder_x + rung_width/2],
            [y, y], '-', color=color, linewidth=4)
    # Label
    ax2.text(ladder_x, y + 0.6, text, ha='center', va='bottom',
            fontsize=10, fontweight='bold', color=color,
            bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                     edgecolor=color, alpha=0.9))

# Arrow showing depth direction
ax2.annotate('', xy=(1.2, 8.5), xytext=(1.2, 1.5),
            arrowprops=dict(arrowstyle='->', color='#2c3e50', lw=2.5))
ax2.text(0.5, 5, 'Deeper\ncertificate\n→ faster\ndescent',
        ha='center', va='center', fontsize=11, fontstyle='italic',
        color='#2c3e50', rotation=0)

# Source annotation
ax2.text(ladder_x, 0.2, 'Source: k-fold log-concavity\nof weight sequences',
        ha='center', va='bottom', fontsize=10, color='#7f8c8d',
        fontstyle='italic')

# Top annotation
ax2.text(ladder_x, 9.3, 'Analytic Combinatorics → Discrete Optimization',
        ha='center', va='bottom', fontsize=12, fontweight='bold',
        color='#2c3e50')

plt.tight_layout()
plt.savefig('viz_theory_bridge.png', dpi=150, bbox_inches='tight')
print("Saved viz_theory_bridge.png")
