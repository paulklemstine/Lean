#!/usr/bin/env python3
"""
Visualization 2: Wreath Defect Scaling Across Regimes

Shows the wreath defect Delta(k, m(k)) as a function of k for three
different scaling laws m(k), demonstrating subcritical vanishing,
critical persistence, and supercritical growth.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def model_defect(k, m, C=0.5, a=1, b=2):
    """Wreath defect: Delta(k,m) = C * m^a / k^b"""
    return C * (m ** a) / (k ** b)


k_vals = np.arange(3, 101)

# Three scaling regimes
m_sub = np.floor(np.sqrt(k_vals)).astype(int)   # m ~ k^0.5 (subcritical)
m_crit = (k_vals ** 2).astype(int)               # m ~ k^2 (critical)
m_super = (k_vals ** 3).astype(int)               # m ~ k^3 (supercritical)

delta_sub = np.array([model_defect(k, m) for k, m in zip(k_vals, m_sub)])
delta_crit = np.array([model_defect(k, m) for k, m in zip(k_vals, m_crit)])
delta_super = np.array([model_defect(k, m) for k, m in zip(k_vals, m_super)])

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Absolute defect
ax = axes[0]
ax.semilogy(k_vals, delta_sub, 'b-', linewidth=2, label=r'$m = \lfloor\sqrt{k}\rfloor$ (sub)')
ax.semilogy(k_vals, delta_crit, 'r-', linewidth=2, label=r'$m = k^2$ (critical)')
ax.semilogy(k_vals, delta_super, 'g-', linewidth=2, label=r'$m = k^3$ (super)')
ax.set_xlabel('k', fontsize=13)
ax.set_ylabel(r'$|\Delta(k, m(k))|$', fontsize=13)
ax.set_title('Wreath Defect vs k', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(1e-4, 1e6)

# Plot 2: Per-copy correction (Delta / m)
ax = axes[1]
percopy_sub = delta_sub / np.maximum(m_sub, 1)
percopy_crit = delta_crit / np.maximum(m_crit, 1)
percopy_super = delta_super / np.maximum(m_super, 1)

ax.semilogy(k_vals, percopy_sub, 'b-', linewidth=2, label=r'$m = \lfloor\sqrt{k}\rfloor$')
ax.semilogy(k_vals, percopy_crit, 'r-', linewidth=2, label=r'$m = k^2$')
ax.semilogy(k_vals, percopy_super, 'g-', linewidth=2, label=r'$m = k^3$')
ax.axhline(y=0, color='k', linestyle=':', alpha=0.5)
ax.set_xlabel('k', fontsize=13)
ax.set_ylabel(r'$\Delta(k,m(k)) / m(k)$', fontsize=13)
ax.set_title('Per-Copy Correction', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 3: Rescaled defect at critical exponent
ax = axes[2]
alpha_c = 2.0
R_sub = k_vals**alpha_c / np.maximum(m_sub, 1) * delta_sub
R_crit = k_vals**alpha_c / np.maximum(m_crit, 1) * delta_crit
R_super = k_vals**alpha_c / np.maximum(m_super, 1) * delta_super

ax.plot(k_vals, R_sub, 'b-', linewidth=2, label=r'$m = \lfloor\sqrt{k}\rfloor$')
ax.plot(k_vals, R_crit, 'r-', linewidth=2, label=r'$m = k^2$')
ax.plot(k_vals, R_super, 'g-', linewidth=2, label=r'$m = k^3$')
ax.set_xlabel('k', fontsize=13)
ax.set_ylabel(r'$R_{\alpha_c}(k, m(k))$', fontsize=13)
ax.set_title(r'Rescaled Defect at $\alpha_c = 2$', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle('Three Scaling Regimes of Wreath-Product Subgroup Pressure',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('defect_scaling.png', dpi=150, bbox_inches='tight')
print("Saved defect_scaling.png")
