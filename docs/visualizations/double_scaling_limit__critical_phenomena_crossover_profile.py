"""
Crossover Profile Visualization

Visualizes the conjectured crossover profile F(λ) where
Δ(k, λ·k^α) → F(λ) as k → ∞. Shows convergence of the
rescaled defect for increasing k, demonstrating the
finite-size scaling collapse expected from the double-scaling
limit theory.
"""

import numpy as np
import matplotlib.pyplot as plt


def wreath_defect(k, m):
    """Wreath defect Δ(k,m) = m/k for the perturbation model."""
    if k < 2 or m < 1:
        return 0.0
    return float(m) / float(k)


def rescaled_defect(k, m, alpha):
    """Rescaled defect R̃_α(k,m) = (k^α / m) · Δ(k,m)."""
    delta = wreath_defect(k, m)
    if m == 0:
        return 0.0
    return (k ** alpha / m) * delta


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Crossover profile for α = 1.0
ax = axes[0, 0]
alpha = 1.0
lambdas = np.linspace(0.01, 5.0, 200)
for k in [10, 20, 50, 100, 200]:
    profile = []
    for lam in lambdas:
        m = max(1, round(lam * k ** alpha))
        profile.append(rescaled_defect(k, m, alpha))
    ax.plot(lambdas, profile, '-', label=f'k={k}', linewidth=1.5)

ax.set_xlabel('λ = m / k^α', fontsize=12)
ax.set_ylabel('Rescaled defect R̃_α(k, m)', fontsize=12)
ax.set_title(f'Crossover Profile (α = {alpha})', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.axhline(y=1.0, color='gray', linestyle=':', alpha=0.5)

# Panel 2: Comparison of different α values
ax = axes[0, 1]
k_test = 100
for alpha in [0.5, 1.0, 1.5, 2.0]:
    profile = []
    lam_range = np.linspace(0.01, 5.0, 200)
    for lam in lam_range:
        m = max(1, round(lam * k_test ** alpha))
        profile.append(rescaled_defect(k_test, m, alpha))
    ax.plot(lam_range, profile, '-', label=f'α={alpha}', linewidth=2)

ax.set_xlabel('λ = m / k^α', fontsize=12)
ax.set_ylabel('Rescaled defect R̃_α', fontsize=12)
ax.set_title(f'Profile Comparison (k={k_test})', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Raw defect vs k for critical scaling m(k) = k
ax = axes[1, 0]
k_vals = np.arange(3, 201)
for m_label, m_func in [
    ('m=1 (constant)', lambda k: 1),
    ('m=⌊√k⌋', lambda k: max(1, int(k**0.5))),
    ('m=k', lambda k: k),
    ('m=k²', lambda k: k**2),
]:
    defects = [wreath_defect(k, m_func(k)) for k in k_vals]
    ax.plot(k_vals, defects, '-', label=m_label, linewidth=1.5)

ax.set_xlabel('k', fontsize=12)
ax.set_ylabel('Δ(k, m(k))', fontsize=12)
ax.set_title('Raw Wreath Defect vs k', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_yscale('log')

# Panel 4: Convergence of rescaled defect at λ=1
ax = axes[1, 1]
k_vals = np.arange(3, 301)
for alpha in [0.5, 1.0, 1.5, 2.0]:
    vals = []
    for k in k_vals:
        m = max(1, round(k ** alpha))
        vals.append(rescaled_defect(k, m, alpha))
    ax.plot(k_vals, vals, '-', label=f'α={alpha}', linewidth=1.5)

ax.set_xlabel('k', fontsize=12)
ax.set_ylabel('R̃_α(k, ⌊k^α⌋)', fontsize=12)
ax.set_title('Convergence at Critical Scaling (λ=1)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.axhline(y=1.0, color='gray', linestyle=':', alpha=0.5, label='Predicted limit')

plt.suptitle('Double Scaling Limit: Crossover Analysis', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('viz_crossover_profile.png', dpi=150, bbox_inches='tight')
print("Saved viz_crossover_profile.png")
