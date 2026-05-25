#!/usr/bin/env python3
"""
Visualization 2: Free Energy Extensivity and Exponent Rigidity

Illustrates freeEnergy_directPower and logSlopeSimple_of_power:
- Left: Free energy F(m,t) = m·F(1,t) for direct powers
- Right: Log-slope exponent β_eff(m) = m·β_eff(1) (rigidity)
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib

matplotlib.rcParams.update({
    'font.size': 12,
    'axes.labelsize': 14,
    'axes.titlesize': 15,
    'legend.fontsize': 11,
    'figure.figsize': (14, 6),
})

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Extensivity
ax = axes[0]
t = np.linspace(-3, 3, 500)
F1 = np.log(1 + t**2)

colors = plt.cm.viridis(np.linspace(0.2, 0.9, 6))
for i, m in enumerate([1, 2, 3, 5, 8, 12]):
    Fm = m * F1
    ax.plot(t, Fm, color=colors[i], linewidth=2, label=f'm = {m}')

ax.set_xlabel('t (parameter)')
ax.set_ylabel('F(m, t)')
ax.set_title('Free Energy Extensivity: F(m,t) = m·F(1,t)')
ax.legend(loc='upper center')
ax.grid(True, alpha=0.3)
ax.set_ylim(0, 30)

# Add annotation
ax.annotate('Linear in m\n(thermodynamic extensivity)',
            xy=(0, 0), xytext=(1.5, 20),
            fontsize=11, ha='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))

# Panel 2: Exponent rigidity
ax = axes[1]
beta = 2.0
tc = 0.0
h = 0.001

ms = list(range(1, 16))
beta_effs = []
for m in ms:
    # For f(x) = |x|^β, f^m(x) = |x|^{mβ}
    # log|f^m(tc+h)| / log|h| = mβ·log|h|/log|h| = mβ
    val = abs(h) ** (m * beta)
    beta_eff = np.log(val) / np.log(abs(h))
    beta_effs.append(beta_eff)

expected = [m * beta for m in ms]

ax.plot(ms, beta_effs, 'bo-', markersize=8, linewidth=2, label='Computed β_eff(m)')
ax.plot(ms, expected, 'r--', linewidth=2, label=f'Predicted: m·β = {beta}m')
ax.set_xlabel('m (number of copies)')
ax.set_ylabel('Effective exponent β_eff(m)')
ax.set_title(f'Exponent Rigidity: β_eff(m) = m·β, β = {beta}')
ax.legend(loc='upper left')
ax.grid(True, alpha=0.3)

# Add residual inset
inset = ax.inset_axes([0.55, 0.15, 0.4, 0.35])
residuals = [abs(b - e) for b, e in zip(beta_effs, expected)]
inset.semilogy(ms, [r if r > 0 else 1e-16 for r in residuals], 'go-', markersize=4)
inset.set_xlabel('m', fontsize=9)
inset.set_ylabel('|error|', fontsize=9)
inset.set_title('Residuals', fontsize=10)
inset.grid(True, alpha=0.3)

plt.suptitle('Direct-Power Universality: Extensivity & Exponent Rigidity',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_extensivity.png', dpi=150, bbox_inches='tight')
print("Saved viz_extensivity.png")
