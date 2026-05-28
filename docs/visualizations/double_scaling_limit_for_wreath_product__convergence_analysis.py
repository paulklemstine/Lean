#!/usr/bin/env python3
"""
Visualization: Convergence Rates in the Double Scaling Limit

Shows how the wreath defect converges to zero in the subcritical regime
at a rate determined by the scaling exponent, and persists in the
supercritical regime. Illustrates Theorems 1 and 3 from the paper.
"""

import numpy as np
import matplotlib.pyplot as plt
import math


def compute_defect(k, m, C=1.0, p=1.0, q=2.0):
    """Wreath defect Δ(k,m) = C · m^p / k^q."""
    if k <= 0:
        return 0.0
    return C * (m ** p) / (k ** q)


def compute_per_copy_deviation(k, m, C=1.0, p=1.0, q=2.0):
    """Per-copy deviation: Δ(k,m)/m."""
    delta = compute_defect(k, m, C, p, q)
    return delta / m if m > 0 else 0.0


# Parameters
C, p, q = 1.0, 1.0, 2.0
alpha_c = q / p

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# ── Panel 1: Defect convergence for various m(k) ──
ax = axes[0, 0]
k_vals = np.arange(3, 200)

m_schedules = [
    ('m = √k (subcritical)', lambda k: max(1, int(k**0.5)), '#2166ac'),
    ('m = k (subcritical)', lambda k: max(1, int(k**1.0)), '#4393c3'),
    ('m = k^1.5 (subcritical)', lambda k: max(1, int(k**1.5)), '#92c5de'),
    ('m = k² (critical)', lambda k: max(1, int(k**2.0)), '#f4a582'),
    ('m = k³ (supercritical)', lambda k: max(1, int(k**3.0)), '#d6604d'),
]

for label, m_fn, color in m_schedules:
    defects = [compute_defect(int(k), m_fn(int(k))) for k in k_vals]
    ax.semilogy(k_vals, defects, '-', color=color, linewidth=2, label=label)

ax.set_xlabel('k', fontsize=12)
ax.set_ylabel('|Δ(k, m(k))|', fontsize=12)
ax.set_title('Theorem 1: Defect Convergence', fontsize=13, fontweight='bold')
ax.legend(fontsize=9, loc='upper right')
ax.grid(True, alpha=0.3)
ax.axhline(y=0, color='black', linewidth=0.5)

# ── Panel 2: Per-copy pressure deviation ──
ax = axes[0, 1]

for label, m_fn, color in m_schedules[:4]:
    devs = [compute_per_copy_deviation(int(k), m_fn(int(k))) for k in k_vals]
    ax.plot(k_vals, devs, '-', color=color, linewidth=2, label=label)

ax.set_xlabel('k', fontsize=12)
ax.set_ylabel('Δ(k, m(k)) / m(k)', fontsize=12)
ax.set_title('Theorem 2: Per-Copy Stability', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# ── Panel 3: Obstruction theorem illustration ──
ax = axes[1, 0]

# At critical scaling m = k^2, defect = C (constant)
k_vals_obs = np.arange(3, 200)
defect_critical = [compute_defect(int(k), max(1, int(k**2))) for k in k_vals_obs]

ax.plot(k_vals_obs, defect_critical, '-', color='#d62728', linewidth=2,
        label='|Δ(k, k²)| = C = 1.0')
ax.axhline(y=C, color='black', linestyle='--', linewidth=1, alpha=0.7,
           label=f'Lower bound c = {C}')
ax.fill_between(k_vals_obs, 0, C * 0.5, alpha=0.1, color='green',
                label='Region where Δ→0 would need to enter')
ax.axhline(y=0, color='green', linestyle=':', linewidth=1, alpha=0.5)

ax.set_xlabel('k', fontsize=12)
ax.set_ylabel('|Δ(k, k²)|', fontsize=12)
ax.set_title('Theorem 3: Obstruction to Convergence', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_ylim([-0.2, 2.0])

# ── Panel 4: Convergence rate comparison ──
ax = axes[1, 1]

exponents = [0.5, 1.0, 1.5, 1.8, 1.95]
colors_exp = plt.cm.viridis(np.linspace(0.1, 0.9, len(exponents)))

for beta, color in zip(exponents, colors_exp):
    # Decay rate: k^{p*beta - q} = k^{beta - 2}
    decay = [compute_defect(int(k), max(1, int(k**beta))) for k in k_vals]
    effective_rate = p * beta - q
    ax.loglog(k_vals, decay, '-', color=color, linewidth=2,
              label=f'm ~ k^{{{beta:.1f}}}, rate ~ k^{{{effective_rate:.1f}}}')

ax.set_xlabel('k', fontsize=12)
ax.set_ylabel('|Δ(k, m(k))|', fontsize=12)
ax.set_title('Convergence Rate vs. Scaling Exponent', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.suptitle('Double Scaling Limit: Convergence Analysis\n'
             f'Model: |Δ| ≤ C·m^{p}/k^{q}, α_c = {alpha_c}',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('convergence_analysis.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved convergence_analysis.png")
