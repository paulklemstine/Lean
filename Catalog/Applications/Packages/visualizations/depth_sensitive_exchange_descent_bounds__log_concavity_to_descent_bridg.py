"""
Visualization 3: The Log-Concavity to Descent Bridge

Illustrates the cross-domain bridge from higher-order log-concavity
to exchange descent certificates. Shows:
1. How k-fold log-concave sequences become progressively more structured
2. The ratio sequence monotonicity that drives exchange improvements
3. The full pipeline: analytic structure → combinatorial certificate → runtime bound
"""

import numpy as np
import matplotlib.pyplot as plt


def binomial(n, k):
    if k < 0 or k > n: return 0
    if k == 0 or k == n: return 1
    k = min(k, n - k)
    r = 1
    for i in range(k):
        r = r * (n - i) // (i + 1)
    return r


def ratio_seq(a):
    """Compute ratio sequence r(n) = a(n+1)/a(n)."""
    return np.array([a[i+1] / a[i] if a[i] > 0 else 0
                     for i in range(len(a) - 1)])


def check_log_concave(a):
    """Check if a(n+1)^2 >= a(n)*a(n+2) for all n."""
    violations = 0
    for n in range(len(a) - 2):
        if a[n+1]**2 < a[n] * a[n+2] - 1e-10:
            violations += 1
    return violations == 0


fig, axes = plt.subplots(2, 3, figsize=(14, 8))

# ─── Row 1: Sequences of increasing log-concavity depth ───

# 1-fold log-concave: simple bell curve
n_pts = 15
a1 = np.array([np.exp(-0.1 * (i - 7)**2) for i in range(n_pts)])
a1 = a1 / a1.max()

# 3-fold: binomial C(20, i)
a3 = np.array([float(binomial(20, i)) for i in range(n_pts)])
a3 = a3 / a3.max()

# Ultra-log-concave (high depth): C(30, i) / C(15, i)
a_deep = np.array([float(binomial(30, i)) / max(float(binomial(15, i)), 1e-10)
                    for i in range(n_pts)])
a_deep = a_deep / a_deep.max()

seqs = [a1, a3, a_deep]
titles = ['Low Depth (k ≈ 1)\nGaussian envelope',
          'Medium Depth (k ≈ 3)\nBinomial C(20,i)',
          'High Depth (k ≈ d)\nUltra-log-concave']
colors_seq = ['#e74c3c', '#f39c12', '#2ecc71']

for idx, (a, title, color) in enumerate(zip(seqs, titles, colors_seq)):
    ax = axes[0, idx]
    ax.bar(range(len(a)), a, color=color, alpha=0.7, edgecolor='white', linewidth=0.5)
    ax.set_title(title, fontsize=10, fontweight='bold')
    ax.set_xlabel('Index n', fontsize=9)
    ax.set_ylabel('a(n)', fontsize=9)
    ax.grid(True, alpha=0.2, axis='y')

    # Annotate log-concavity check
    is_lc = check_log_concave(a)
    ax.text(0.02, 0.95, f'Log-concave: {"✓" if is_lc else "✗"}',
            transform=ax.transAxes, fontsize=8, verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

# ─── Row 2: Ratio sequences and the bridge ───

# Panel 4: Ratio sequences (should be monotone decreasing for log-concave)
ax = axes[1, 0]
for a, color, label in zip(seqs, colors_seq, ['Low', 'Medium', 'High']):
    r = ratio_seq(a)
    ax.plot(range(len(r)), r, 'o-', color=color, markersize=4,
            linewidth=1.5, label=f'{label} depth')

ax.set_xlabel('Index n', fontsize=9)
ax.set_ylabel('Ratio a(n+1)/a(n)', fontsize=9)
ax.set_title('Ratio Sequences\n(Monotone ⟹ Exchange Certificate)', fontsize=10, fontweight='bold')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Panel 5: Iterated ratio sequences for the deep case
ax = axes[1, 1]
r0 = a3.copy()
for level in range(4):
    r0_norm = r0 / r0.max() if r0.max() > 0 else r0
    ax.plot(range(len(r0_norm)), r0_norm, 'o-', markersize=3, linewidth=1.2,
            label=f'Level {level}', alpha=0.8)
    if len(r0) > 1:
        r0 = ratio_seq(r0)
        r0 = np.maximum(r0, 1e-15)
    else:
        break

ax.set_xlabel('Index', fontsize=9)
ax.set_ylabel('Normalized Value', fontsize=9)
ax.set_title('Iterated Ratios\n(All Log-Concave = Deep Certificate)', fontsize=10, fontweight='bold')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Panel 6: The bridge diagram (conceptual)
ax = axes[1, 2]
ax.set_xlim(0, 10)
ax.set_ylim(0, 10)
ax.axis('off')

# Draw the pipeline
boxes = [
    (1, 8, 'k-Fold\nLog-Concavity', '#3498db'),
    (1, 5.5, 'Ratio\nMonotonicity', '#2ecc71'),
    (1, 3, 'Exchange\nCertificate', '#f39c12'),
    (1, 0.5, 'Descent Bound\nO(d^{d-k}·D)', '#e74c3c'),
]

for x, y, text, color in boxes:
    rect = plt.Rectangle((x, y), 8, 1.8, facecolor=color, alpha=0.3,
                         edgecolor=color, linewidth=2, transform=ax.transData)
    ax.add_patch(rect)
    ax.text(5, y + 0.9, text, ha='center', va='center', fontsize=10,
            fontweight='bold', color=color)

# Arrows
for y_start, y_end in [(7.8, 7.5), (5.3, 5.0), (2.8, 2.5)]:
    ax.annotate('', xy=(5, y_end), xytext=(5, y_start),
                arrowprops=dict(arrowstyle='->', color='gray', lw=2))

ax.set_title('The Bridge:\nAnalysis → Algorithms', fontsize=11, fontweight='bold')

plt.tight_layout()
plt.savefig('viz_logconcavity_bridge.png', dpi=150, bbox_inches='tight')
print("Saved viz_logconcavity_bridge.png")
