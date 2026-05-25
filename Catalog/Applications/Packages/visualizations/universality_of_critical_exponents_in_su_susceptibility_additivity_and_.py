#!/usr/bin/env python3
"""
Visualization 3: Susceptibility Additivity and Convexity Preservation

Illustrates:
- Top: Second differences (susceptibility) add under function addition
- Bottom: Convexity preservation for product free energies
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib

matplotlib.rcParams.update({
    'font.size': 12,
    'axes.labelsize': 13,
    'axes.titlesize': 14,
    'legend.fontsize': 10,
    'figure.figsize': (14, 10),
})

fig, axes = plt.subplots(2, 2, figsize=(14, 10))


# ─── Top row: Susceptibility additivity ───────────────────────────────────────

def second_diff(f, t, h):
    return f(t + h) - 2 * f(t) + f(t - h)


# Define free energies
FG = lambda t: t**3 - 2*t + 1
FH = lambda t: np.sin(2*t) + t**2
FK = lambda t: FG(t) + FH(t)

t_vals = np.linspace(-2, 2, 200)
h = 0.05

# Panel 1: Free energies
ax = axes[0, 0]
ax.plot(t_vals, [FG(t) for t in t_vals], 'b-', linewidth=2, label='F_G(t)')
ax.plot(t_vals, [FH(t) for t in t_vals], 'r-', linewidth=2, label='F_H(t)')
ax.plot(t_vals, [FK(t) for t in t_vals], 'purple', linewidth=2, linestyle='--', label='F_K = F_G + F_H')
ax.set_xlabel('t')
ax.set_ylabel('Free energy F(t)')
ax.set_title('Free Energies of Component Systems')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 2: Susceptibilities (second differences)
ax = axes[0, 1]
chi_G = [second_diff(FG, t, h) for t in t_vals]
chi_H = [second_diff(FH, t, h) for t in t_vals]
chi_K = [second_diff(FK, t, h) for t in t_vals]
chi_sum = [g + hv for g, hv in zip(chi_G, chi_H)]

ax.plot(t_vals, chi_G, 'b-', linewidth=2, label='Δ² F_G')
ax.plot(t_vals, chi_H, 'r-', linewidth=2, label='Δ² F_H')
ax.plot(t_vals, chi_K, 'purple', linewidth=2.5, linestyle='-', label='Δ² F_K (computed)')
ax.plot(t_vals, chi_sum, 'k--', linewidth=1.5, alpha=0.7, label='Δ²F_G + Δ²F_H (sum)')
ax.set_xlabel('t')
ax.set_ylabel('Susceptibility Δ²F(t)')
ax.set_title('Susceptibility Additivity: Δ²(F+G) = Δ²F + Δ²G')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Highlight that purple and black dashed overlap perfectly
ax.annotate('Exact overlap\n(theorem verified)', xy=(0.5, chi_K[100]),
            xytext=(1.3, max(chi_K) * 0.7),
            fontsize=10, ha='center',
            arrowprops=dict(arrowstyle='->', color='green', lw=1.5),
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightgreen', alpha=0.8))


# ─── Bottom row: Convexity preservation ───────────────────────────────────────

# Convex free energies
FG_convex = lambda t: t**2 + 0.5
FH_convex = lambda t: 0.5 * (t - 1)**2 + np.abs(t) * 0.3
FK_convex = lambda t: FG_convex(t) + FH_convex(t)

t_vals2 = np.linspace(-3, 3, 500)

# Panel 3: Convex functions
ax = axes[1, 0]
ax.plot(t_vals2, [FG_convex(t) for t in t_vals2], 'b-', linewidth=2, label='F_G (convex)')
ax.plot(t_vals2, [FH_convex(t) for t in t_vals2], 'r-', linewidth=2, label='F_H (convex)')
ax.plot(t_vals2, [FK_convex(t) for t in t_vals2], 'purple', linewidth=2.5,
        linestyle='--', label='F_K = F_G + F_H')
ax.set_xlabel('t')
ax.set_ylabel('Free energy')
ax.set_title('Convex Free Energies & Their Sum')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 4: Second differences (non-negativity = convexity)
ax = axes[1, 1]
h_conv = 0.1
sd_G = [second_diff(FG_convex, t, h_conv) for t in t_vals2[10:-10]]
sd_H = [second_diff(FH_convex, t, h_conv) for t in t_vals2[10:-10]]
sd_K = [second_diff(FK_convex, t, h_conv) for t in t_vals2[10:-10]]
t_inner = t_vals2[10:-10]

ax.fill_between(t_inner, 0, sd_K, alpha=0.15, color='purple')
ax.plot(t_inner, sd_G, 'b-', linewidth=1.5, label='Δ² F_G ≥ 0')
ax.plot(t_inner, sd_H, 'r-', linewidth=1.5, label='Δ² F_H ≥ 0')
ax.plot(t_inner, sd_K, 'purple', linewidth=2.5, label='Δ² F_K ≥ 0')
ax.axhline(y=0, color='black', linewidth=1, linestyle='-')
ax.set_xlabel('t')
ax.set_ylabel('Second difference Δ²F')
ax.set_title('Convexity Verification: Δ²F ≥ 0')
ax.legend()
ax.grid(True, alpha=0.3)

# Annotate
min_sd = min(sd_K)
ax.annotate(f'min(Δ²F_K) = {min_sd:.4f} ≥ 0',
            xy=(t_inner[np.argmin(sd_K)], min_sd),
            xytext=(1.5, max(sd_K) * 0.6),
            fontsize=10,
            arrowprops=dict(arrowstyle='->', color='green', lw=1.5),
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightgreen', alpha=0.8))

plt.suptitle('Susceptibility Additivity & Convexity Preservation\n'
             'Bridging Group Theory and Thermodynamic Stability',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_susceptibility.png', dpi=150, bbox_inches='tight')
print("Saved viz_susceptibility.png")
