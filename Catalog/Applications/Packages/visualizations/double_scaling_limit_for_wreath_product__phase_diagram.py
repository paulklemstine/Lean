#!/usr/bin/env python3
"""
Visualization: Phase Diagram of Wreath Product Scaling Regimes

Visualizes the three perturbation regimes (irrelevant, marginal, relevant)
in the (k, m) plane, with the critical boundary m = k^{α_c} separating them.
This is the finite-group analog of the phase diagram in statistical mechanics.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import math


def compute_defect(k, m, C=1.0, p=1.0, q=2.0):
    """Wreath defect Δ(k,m) = C · m^p / k^q."""
    if k <= 0:
        return 0.0
    return C * (m ** p) / (k ** q)


def compute_relevance(k, m, alpha_c):
    """Scaling variable m / k^{α_c}."""
    if k <= 0:
        return 0.0
    return m / (k ** alpha_c)


# Parameters
C, p, q = 1.0, 1.0, 2.0
alpha_c = q / p  # = 2.0

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# ── Panel 1: Phase diagram in (k, m) plane ──
ax = axes[0]
k_range = np.linspace(2, 50, 200)
m_range = np.linspace(1, 2500, 200)
K, M = np.meshgrid(k_range, m_range)

# Scaling variable
Lambda = M / K**alpha_c

# Color by regime
colors = np.zeros((*Lambda.shape, 3))
# Irrelevant: blue (λ < 0.1)
# Marginal: yellow (0.1 ≤ λ ≤ 10)
# Relevant: red (λ > 10)
colors[Lambda < 0.1] = [0.2, 0.4, 0.8]   # blue
colors[(Lambda >= 0.1) & (Lambda <= 10)] = [0.9, 0.8, 0.2]  # yellow
colors[Lambda > 10] = [0.8, 0.2, 0.2]     # red

ax.imshow(colors, extent=[2, 50, 1, 2500], origin='lower', aspect='auto')
k_line = np.linspace(2, 50, 100)
ax.plot(k_line, k_line**alpha_c, 'k-', linewidth=2, label=f'm = k^{{{alpha_c:.0f}}}')
ax.plot(k_line, 0.1 * k_line**alpha_c, 'k--', linewidth=1, alpha=0.5)
ax.plot(k_line, 10 * k_line**alpha_c, 'k--', linewidth=1, alpha=0.5)
ax.set_xlabel('k (symmetric group rank)', fontsize=12)
ax.set_ylabel('m (multiplicity)', fontsize=12)
ax.set_title('Phase Diagram: (k, m) Plane', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)

# Add regime labels
ax.text(30, 200, 'IRRELEVANT', color='white', fontsize=11, fontweight='bold',
        ha='center', va='center')
ax.text(15, 1200, 'MARGINAL', color='black', fontsize=11, fontweight='bold',
        ha='center', va='center')
ax.text(8, 2200, 'RELEVANT', color='white', fontsize=11, fontweight='bold',
        ha='center', va='center')

# ── Panel 2: Defect decay in each regime ──
ax = axes[1]
k_values = np.arange(3, 101)

regimes = {
    'Irrelevant (m=k)': (1.0, '#3366cc'),
    'Marginal (m=k²)': (2.0, '#cc9900'),
    'Relevant (m=k³)': (3.0, '#cc3333'),
}

for label, (exp, color) in regimes.items():
    m_vals = np.maximum(1, np.floor(k_values ** exp)).astype(int)
    defects = [compute_defect(int(k), int(m), C, p, q) for k, m in zip(k_values, m_vals)]
    ax.semilogy(k_values, defects, '-', color=color, linewidth=2, label=label)

ax.set_xlabel('k', fontsize=12)
ax.set_ylabel('|Δ(k, m(k))|', fontsize=12)
ax.set_title('Defect Scaling by Regime', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# ── Panel 3: Data collapse at critical exponent ──
ax = axes[2]

alpha_test = alpha_c  # True critical exponent
k_test_values = [10, 20, 50, 100]
colors_k = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728']
lambda_range = np.linspace(0.01, 5.0, 100)

for k, color in zip(k_test_values, colors_k):
    lambdas = []
    rescaled = []
    for lam in lambda_range:
        m = max(1, int(lam * k ** alpha_test))
        delta = compute_defect(k, m, C, p, q)
        R = (k ** alpha_test / m) * delta if m > 0 else 0
        actual_lam = m / k ** alpha_test
        lambdas.append(actual_lam)
        rescaled.append(R)
    ax.plot(lambdas, rescaled, '-', color=color, linewidth=2, label=f'k={k}', alpha=0.8)

# Theoretical curve F(λ) = C for this model
ax.axhline(y=C, color='black', linestyle=':', linewidth=1.5, alpha=0.7, label=f'F(λ) = {C}')

ax.set_xlabel('λ = m / k^{α_c}', fontsize=12)
ax.set_ylabel('R_α(k, m) = k^α/m · Δ', fontsize=12)
ax.set_title(f'Data Collapse (α = α_c = {alpha_c:.1f})', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_xlim([0, 5])

plt.tight_layout()
plt.savefig('phase_diagram.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved phase_diagram.png")
