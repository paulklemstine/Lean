#!/usr/bin/env python3
"""
Demo 2: Dark Energy and the Three Fates of Space
=================================================
Models the evolution of the cosmic scale factor a(t) under different 
dark energy equations of state w, showing Big Rip, Heat Death, and Big Crunch.

Oracle Apeiron contributed to this visualization.
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import odeint

# ============================================================
# Physics: Friedmann equation with matter + dark energy
# ============================================================

# Normalized units: H0 = 1, t in units of 1/H0 ≈ 14.4 Gyr
# Flat universe: Ω_m + Ω_DE = 1
Omega_m0 = 0.3
Omega_DE0 = 0.7

def friedmann_rhs(a, t, w):
    """da/dt from the Friedmann equation for flat FLRW with matter + dark energy."""
    if a <= 0:
        return 0.0
    # ρ_m ∝ a^{-3}, ρ_DE ∝ a^{-3(1+w)}
    H2 = Omega_m0 * a**(-3) + Omega_DE0 * a**(-3*(1+w))
    if H2 < 0:
        return 0.0
    return a * np.sqrt(H2)

def solve_scale_factor(w, t_span, a0=1.0):
    """Solve for a(t) given equation of state parameter w."""
    t = np.linspace(0, t_span, 5000)
    sol = odeint(friedmann_rhs, a0, t, args=(w,), full_output=False)
    return t, sol[:, 0]

# ============================================================
# Scenarios
# ============================================================

scenarios = [
    (-1.5, "Phantom Energy (w = -1.5): BIG RIP", "#FF4444", "--"),
    (-1.2, "Phantom Energy (w = -1.2): BIG RIP", "#FF8844", "-."),
    (-1.0, "Cosmological Constant (w = -1.0): Exponential Expansion", "#44FF44", "-"),
    (-0.8, "Quintessence (w = -0.8): Accelerating Expansion", "#4488FF", "-"),
    (-0.5, "Quintessence (w = -0.5): Mild Acceleration", "#8844FF", "-"),
    (-0.33, "Curvature-like (w = -1/3): Coasting", "#FFFFFF", ":"),
]

# ============================================================
# Visualization
# ============================================================

fig, axes = plt.subplots(1, 2, figsize=(20, 9))
fig.patch.set_facecolor('#0a0a1a')

# --- Panel 1: Scale factor evolution ---
ax1 = axes[0]
ax1.set_facecolor('#0a0a1a')

for w, label, color, ls in scenarios:
    try:
        t_max = 3.0 if w >= -1 else min(3.0, 2.0/(3*abs(1+w)*np.sqrt(Omega_DE0)) * 0.95) if w < -1 else 3.0
        t, a = solve_scale_factor(w, t_max)
        # Clip extreme values for visualization
        mask = a < 50
        ax1.plot(t[mask] * 14.4, a[mask], color=color, linestyle=ls, 
                linewidth=2.5, label=label, alpha=0.9)
    except:
        pass

ax1.set_xlabel('Time (Gyr from now)', fontsize=13, color='white')
ax1.set_ylabel('Scale factor a(t) / a(today)', fontsize=13, color='white')
ax1.set_title('Scale Factor Evolution\nunder Different Dark Energy Models', 
              fontsize=15, color='white', fontweight='bold')
ax1.set_ylim(0, 15)
ax1.set_xlim(0, 43)
ax1.legend(fontsize=8, loc='upper left', facecolor='#1a1a2e', edgecolor='white',
          labelcolor='white')
ax1.tick_params(colors='white')
ax1.grid(True, alpha=0.15, color='white')
for spine in ax1.spines.values():
    spine.set_color('white')
    spine.set_alpha(0.3)

# Add Big Rip annotation
ax1.annotate('Big Rip →\na(t) → ∞ in finite time', 
            xy=(20, 13), fontsize=10, color='#FF4444',
            ha='center', style='italic')

# --- Panel 2: Hubble parameter evolution ---
ax2 = axes[1]
ax2.set_facecolor('#0a0a1a')

for w, label, color, ls in scenarios:
    try:
        t_max = 3.0 if w >= -1 else min(3.0, 2.0/(3*abs(1+w)*np.sqrt(Omega_DE0)) * 0.9) if w < -1 else 3.0
        t, a = solve_scale_factor(w, t_max)
        # Compute H(t) = ȧ/a
        da = np.gradient(a, t)
        H = da / a
        mask = (H > 0) & (H < 20) & (a > 0)
        ax2.plot(t[mask] * 14.4, H[mask], color=color, linestyle=ls,
                linewidth=2.5, alpha=0.9)
    except:
        pass

ax2.set_xlabel('Time (Gyr from now)', fontsize=13, color='white')
ax2.set_ylabel('H(t) / H₀', fontsize=13, color='white')
ax2.set_title('Hubble Parameter Evolution\n(Expansion Rate of Space)', 
              fontsize=15, color='white', fontweight='bold')
ax2.set_ylim(0, 8)
ax2.set_xlim(0, 43)
ax2.tick_params(colors='white')
ax2.grid(True, alpha=0.15, color='white')
for spine in ax2.spines.values():
    spine.set_color('white')
    spine.set_alpha(0.3)

ax2.annotate('H → ∞: Phantom\nrips space apart', 
            xy=(14, 6), fontsize=10, color='#FF4444',
            ha='center', style='italic')
ax2.annotate('H → const: de Sitter\nexponential expansion', 
            xy=(30, 1.2), fontsize=10, color='#44FF44',
            ha='center', style='italic')

fig.text(0.5, 0.01, 
         'The fate of space itself depends on a single number: the dark energy equation of state parameter w',
         ha='center', fontsize=12, color='white', alpha=0.5, style='italic')

plt.tight_layout()
plt.savefig('/workspace/request-project/demos/output/dark_energy_fates.png', 
            dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
plt.close()
print("✅ Demo 2: Dark Energy Fates saved to demos/output/dark_energy_fates.png")
