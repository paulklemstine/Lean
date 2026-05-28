"""
Phase Diagram Visualization for Wreath-Product Scaling Regimes

Visualizes the three perturbation regimes (irrelevant, marginal, relevant)
in the (k, m) plane, with the critical boundary m = k^{α_c} highlighted.
This is the finite-group analog of the phase diagram near an upper critical
dimension in statistical mechanics.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def beta_symm_approx(k):
    """Approximate β(S_k)."""
    k = np.asarray(k, dtype=float)
    result = np.where(k >= 2, k * np.log(k) - k + 0.5 * np.log(2 * np.pi * k), 0.0)
    return result


def wreath_defect(k, m):
    """Wreath defect Δ(k,m) = m/k for the perturbation model."""
    k = np.asarray(k, dtype=float)
    m = np.asarray(m, dtype=float)
    return np.where(k >= 2, m / k, 0.0)


def relevance_ratio(k, m, alpha):
    """Relevance ratio Φ_α(k,m) = |Δ(k,m)| / (m / k^α)."""
    k = np.asarray(k, dtype=float)
    m = np.asarray(m, dtype=float)
    delta = wreath_defect(k, m)
    denom = m / np.power(k, alpha)
    with np.errstate(divide='ignore', invalid='ignore'):
        ratio = np.abs(delta) / denom
    ratio = np.where(np.isfinite(ratio), ratio, 0.0)
    return ratio


# Set up figure with two panels
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Phase diagram in (k, m) plane
k_range = np.linspace(2, 50, 300)
m_range = np.linspace(1, 2500, 300)
K, M = np.meshgrid(k_range, m_range)

alpha_c = 1.0  # Critical exponent

# Compute the scaling ratio m / k^α
ratio = M / np.power(K, alpha_c)

# Color by log of ratio
log_ratio = np.log10(ratio + 1e-10)

# Phase regions
irrelevant = ratio < 0.1
marginal = (ratio >= 0.1) & (ratio <= 10)
relevant = ratio > 10

# Create custom colormap
colors_phase = np.zeros((*ratio.shape, 4))
colors_phase[irrelevant] = [0.2, 0.4, 0.8, 0.6]   # Blue: irrelevant
colors_phase[marginal] = [0.9, 0.7, 0.1, 0.7]      # Gold: marginal
colors_phase[relevant] = [0.8, 0.2, 0.2, 0.6]       # Red: relevant

ax1.imshow(colors_phase, extent=[2, 50, 1, 2500], aspect='auto', origin='lower')

# Critical boundary: m = k^α_c
k_crit = np.linspace(2, 50, 200)
m_crit = k_crit ** alpha_c
ax1.plot(k_crit, m_crit, 'k-', linewidth=2.5, label=f'm = k^{{{alpha_c}}} (critical)')
ax1.plot(k_crit, 0.1 * k_crit ** alpha_c, 'k--', linewidth=1, alpha=0.5, label='Lower boundary')
ax1.plot(k_crit, 10 * k_crit ** alpha_c, 'k--', linewidth=1, alpha=0.5, label='Upper boundary')

ax1.set_xlabel('Base degree k', fontsize=13)
ax1.set_ylabel('Copies m', fontsize=13)
ax1.set_title('Perturbation Phase Diagram\n(S_k ≀ S_m)', fontsize=14)
ax1.legend(loc='upper left', fontsize=10)

# Add regime labels
ax1.text(35, 200, 'IRRELEVANT\n(m ≪ k^α)', fontsize=11,
         ha='center', va='center', color='white', fontweight='bold',
         bbox=dict(boxstyle='round', facecolor='blue', alpha=0.7))
ax1.text(15, 1500, 'MARGINAL\n(m ~ k^α)', fontsize=11,
         ha='center', va='center', color='black', fontweight='bold',
         bbox=dict(boxstyle='round', facecolor='gold', alpha=0.7))
ax1.text(8, 2200, 'RELEVANT\n(m ≫ k^α)', fontsize=11,
         ha='center', va='center', color='white', fontweight='bold',
         bbox=dict(boxstyle='round', facecolor='red', alpha=0.7))

# Panel 2: Wreath defect as function of k for different scaling choices
ax2_colors = ['#2166ac', '#67a9cf', '#d6604d', '#b2182b']
k_vals = np.arange(3, 101)

scaling_labels = [
    ('Subcritical: m=√k', lambda k: max(1, int(k**0.5))),
    ('Critical: m=k', lambda k: k),
    ('Supercritical: m=k²', lambda k: k**2),
    ('Ultra: m=k³', lambda k: k**3),
]

for idx, (label, m_func) in enumerate(scaling_labels):
    defects = [wreath_defect(k, m_func(k)) for k in k_vals]
    ax2.semilogy(k_vals, defects, '-', color=ax2_colors[idx],
                 linewidth=2, label=label)

ax2.set_xlabel('Base degree k', fontsize=13)
ax2.set_ylabel('Wreath defect |Δ(k, m(k))|', fontsize=13)
ax2.set_title('Defect Growth by Scaling Regime', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xlim([3, 100])

plt.tight_layout()
plt.savefig('viz_phase_diagram.png', dpi=150, bbox_inches='tight')
print("Saved viz_phase_diagram.png")
