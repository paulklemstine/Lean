"""
Hypothesis Testing Reduction Visualization

Visualizes the recognizer-to-tester reduction: how a Lorentzian
signature recognizer induces a hypothesis test for planted signals.
Shows the spectral gap distributions under null (pure noise) and
planted (signal + noise) hypotheses, with the decision threshold
at the GOE edge constant 2σ.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def generate_goe_matrix(n, sigma=1.0):
    """Generate an n×n GOE matrix."""
    M = np.random.randn(n, n) * sigma / np.sqrt(n)
    return (M + M.T) / 2


def spectral_gap(A):
    """Compute eigenvalue gap: λ₁ - λ₂."""
    eigs = np.sort(np.linalg.eigvalsh(A))[::-1]
    if len(eigs) < 2:
        return eigs[0] if len(eigs) > 0 else 0.0
    return eigs[0] - eigs[1]


np.random.seed(42)
n = 50
sigma = 1.0
n_trials = 500

fig, axes = plt.subplots(2, 2, figsize=(16, 14))

# ─── Panel 1: Gap distributions for null vs planted ───
ax = axes[0, 0]
signal_strengths = [0, 1.5, 2.5, 4.0]
colors = ['#95a5a6', '#e74c3c', '#f39c12', '#2ecc71']
labels = ['Null (no signal)', 'Planted (gap=1.5σ)', 'Planted (gap=2.5σ)',
          'Planted (gap=4σ)']

for strength, color, label in zip(signal_strengths, colors, labels):
    gaps = []
    for _ in range(n_trials):
        if strength == 0:
            M = generate_goe_matrix(n, sigma)
        else:
            D = np.diag([-strength * sigma] * n)
            D[0, 0] = strength * sigma
            Q, _ = np.linalg.qr(np.random.randn(n, n))
            signal = Q @ D @ Q.T
            M = signal + generate_goe_matrix(n, sigma)
        gaps.append(spectral_gap(M))

    ax.hist(gaps, bins=40, alpha=0.5, color=color, label=label, density=True)

ax.axvline(x=2*sigma, color='black', linestyle='--', linewidth=2,
           label='Threshold = 2σ')
ax.set_xlabel('Spectral Gap', fontsize=13)
ax.set_ylabel('Density', fontsize=13)
ax.set_title('Gap Distributions: Null vs Planted', fontsize=15,
             fontweight='bold')
ax.legend(fontsize=10, loc='upper right')
ax.grid(True, alpha=0.3)

# ─── Panel 2: ROC curves ───
ax = axes[0, 1]
thresholds = np.linspace(0, 8, 200)

for strength, color, label in [(1.5, '#e74c3c', 'gap=1.5σ'),
                                 (2.5, '#f39c12', 'gap=2.5σ'),
                                 (4.0, '#2ecc71', 'gap=4.0σ')]:
    null_gaps = []
    planted_gaps = []
    for _ in range(n_trials):
        null_gaps.append(spectral_gap(generate_goe_matrix(n, sigma)))

        D = np.diag([-strength * sigma] * n)
        D[0, 0] = strength * sigma
        Q, _ = np.linalg.qr(np.random.randn(n, n))
        signal = Q @ D @ Q.T
        planted_gaps.append(spectral_gap(signal + generate_goe_matrix(n, sigma)))

    null_gaps = np.array(null_gaps)
    planted_gaps = np.array(planted_gaps)

    fpr = [np.mean(null_gaps > t) for t in thresholds]
    tpr = [np.mean(planted_gaps > t) for t in thresholds]

    ax.plot(fpr, tpr, '-', linewidth=2, color=color, label=label)

ax.plot([0, 1], [0, 1], 'k--', linewidth=1, alpha=0.5)
ax.set_xlabel('False Positive Rate', fontsize=13)
ax.set_ylabel('True Positive Rate', fontsize=13)
ax.set_title('ROC Curves: Spectral Gap Test', fontsize=15, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_xlim(-0.02, 1.02)
ax.set_ylim(-0.02, 1.02)

# ─── Panel 3: Detection advantage vs signal strength ───
ax = axes[1, 0]
strengths = np.linspace(0, 5, 30)
advantages = []
threshold = 2 * sigma

null_gaps = np.array([spectral_gap(generate_goe_matrix(n, sigma))
                      for _ in range(n_trials)])
fp_rate = np.mean(null_gaps > threshold)

for s in strengths:
    planted_gaps_list = []
    for _ in range(200):
        D = np.diag([-s * sigma] * n)
        D[0, 0] = s * sigma
        Q, _ = np.linalg.qr(np.random.randn(n, n))
        signal = Q @ D @ Q.T
        planted_gaps_list.append(spectral_gap(signal + generate_goe_matrix(n, sigma)))

    tp_rate = np.mean(np.array(planted_gaps_list) > threshold)
    advantages.append(tp_rate - fp_rate)

ax.plot(strengths, advantages, 'b-', linewidth=2.5)
ax.axvline(x=2.0, color='r', linestyle='--', linewidth=2, alpha=0.7,
           label='Edge constant = 2')
ax.axhline(y=0, color='k', linestyle='-', linewidth=0.8)
ax.fill_between(strengths, 0, advantages,
                where=[a > 0 for a in advantages], alpha=0.15, color='green')
ax.set_xlabel('Signal strength / σ', fontsize=13)
ax.set_ylabel('Test advantage (TPR − FPR)', fontsize=13)
ax.set_title('Statistical Advantage of Spectral Test', fontsize=15,
             fontweight='bold')
ax.legend(fontsize=12)
ax.grid(True, alpha=0.3)

# ─── Panel 4: Margin duality illustration ───
ax = axes[1, 1]
g_vals = np.linspace(0.5, 4.0, 100)
planted_margin = g_vals - 2 * sigma  # SpectralGapProxy(g, 2σ, 1)
null_margin = 2 * sigma - g_vals     # SpectralGapProxy(2σ, g, 1)

ax.plot(g_vals, planted_margin, 'g-', linewidth=2.5, label='Planted margin')
ax.plot(g_vals, null_margin, 'r-', linewidth=2.5, label='Null margin')
ax.fill_between(g_vals, planted_margin, null_margin,
                where=planted_margin > null_margin, alpha=0.1, color='green')
ax.axhline(y=0, color='k', linestyle='-', linewidth=0.8)
ax.axvline(x=2.0, color='k', linestyle='--', linewidth=1.5, alpha=0.5)
ax.set_xlabel('Signal gap (g)', fontsize=13)
ax.set_ylabel('Margin', fontsize=13)
ax.set_title('Margin Duality: Planted vs Null', fontsize=15,
             fontweight='bold')
ax.legend(fontsize=12)
ax.grid(True, alpha=0.3)
ax.annotate('Separation\nregion', xy=(3.0, 0.5), fontsize=12,
            ha='center', color='#27ae60', fontweight='bold')

plt.tight_layout(pad=2.0)
plt.savefig('viz_hypothesis_testing.png', dpi=150, bbox_inches='tight')
print("Saved viz_hypothesis_testing.png")
