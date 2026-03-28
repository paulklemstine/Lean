"""
Demo 3: Gap-Matter Duality — Light is Rare, Matter is Everywhere

Visualizes:
1. Photon addresses (ℕ) vs matter gaps (ℝ \ ℕ) on the number line
2. The parabolic mass profile m(t) = 4t(1-t) between addresses
3. Stokes vector mixing: null + null → timelike (light + light → mass)
4. Information capacity: countable vs uncountable
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

fig = plt.figure(figsize=(16, 14))
gs = GridSpec(3, 2, figure=fig, hspace=0.4, wspace=0.3)

# ── Panel 1: Number Line with Photon Addresses and Gaps ──
ax1 = fig.add_subplot(gs[0, :])

# Number line
ax1.axhline(y=0, color='black', linewidth=1)

# Photon addresses (integers)
for n in range(0, 15):
    ax1.plot(n, 0, 'o', color='gold', markersize=15, markeredgecolor='darkorange',
             markeredgewidth=2, zorder=5)
    ax1.annotate(f'{n}', (n, 0.15), ha='center', fontsize=10, fontweight='bold', color='darkorange')

# Gap regions (shaded)
for n in range(0, 14):
    ax1.fill_between([n + 0.1, n + 0.9], -0.08, 0.08, color='purple', alpha=0.3)
    ax1.annotate('∞', (n + 0.5, -0.2), ha='center', fontsize=9, color='purple', alpha=0.7)

# Mass profile in one gap
t = np.linspace(0, 1, 100)
mass = 4 * t * (1 - t)
for n in [3, 7, 11]:
    ax1.fill_between(n + t, 0, mass * 0.15, color='red', alpha=0.3)
    ax1.plot(n + t, mass * 0.15, 'r-', linewidth=1.5, alpha=0.6)

ax1.set_xlim(-0.5, 14.5)
ax1.set_ylim(-0.35, 0.8)
ax1.set_xlabel('Real Number Line', fontsize=12)
ax1.set_title('Photon Addresses (●) vs Matter Gaps (shaded)\n'
              'ℕ has measure zero — light occupies nothing. '
              'ℝ\\ℕ has full measure — matter fills everything.',
              fontsize=13, fontweight='bold')
ax1.legend(['Photon address (null/massless)', 'Gap (massive)',
            'Mass profile m(t) = 4t(1−t)'],
           loc='upper left', fontsize=10,
           handler_map={})

# Custom legend
from matplotlib.patches import Patch
from matplotlib.lines import Line2D
legend_elements = [
    Line2D([0], [0], marker='o', color='w', markerfacecolor='gold',
           markeredgecolor='darkorange', markersize=12, label='Photon address (null)'),
    Patch(facecolor='purple', alpha=0.3, label='Gap region (|ℝ\\ℕ| = 𝔠, uncountable)'),
    Line2D([0], [0], color='red', linewidth=2, label='Mass profile m(t) = 4t(1−t)')
]
ax1.legend(handles=legend_elements, loc='upper right', fontsize=10)
ax1.set_yticks([])

# ── Panel 2: Parabolic Mass Profile ──
ax2 = fig.add_subplot(gs[1, 0])

t = np.linspace(0, 1, 500)
mass = 4 * t * (1 - t)

ax2.fill_between(t, 0, mass, color='red', alpha=0.2)
ax2.plot(t, mass, 'r-', linewidth=3, label='m(t) = 4t(1−t)')
ax2.axvline(x=0.5, color='blue', linestyle='--', alpha=0.5, label='Midpoint (max mass)')
ax2.plot(0.5, 1.0, 'b*', markersize=15, zorder=5)
ax2.plot(0, 0, 'go', markersize=12, label='Address n (null)', zorder=5)
ax2.plot(1, 0, 'go', markersize=12, zorder=5)

ax2.set_xlabel('Interpolation parameter t ∈ (0, 1)', fontsize=12)
ax2.set_ylabel('Mass m(t)', fontsize=12)
ax2.set_title('Parabolic Mass Profile Between Photon Addresses\n'
              'Mass peaks at midpoint, vanishes at endpoints', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

ax2.annotate('m(1/2) = 1\nMaximum mass\nat midpoint',
             xy=(0.5, 1.0), xytext=(0.7, 0.8),
             fontsize=11, color='blue',
             arrowprops=dict(arrowstyle='->', color='blue'))

# ── Panel 3: Stokes Vector Mixing ──
ax3 = fig.add_subplot(gs[1, 1])

# Two null Stokes vectors S₁ = (1, 1, 0, 0) and S₂ = (1, -1, 0, 0)
# Their convex combination: S(t) = (1, 1-2t, 0, 0)
# Mass² = S₀² - S₁² - S₂² - S₃² = 1 - (1-2t)² = 4t(1-t)

t = np.linspace(0, 1, 500)
S0 = np.ones_like(t)
S1 = 1 - 2 * t
S2 = np.zeros_like(t)
S3 = np.zeros_like(t)

mass_sq = S0**2 - S1**2 - S2**2 - S3**2  # = 4t(1-t)
degree_pol = np.sqrt(S1**2 + S2**2 + S3**2) / S0  # = |1 - 2t|

ax3.plot(t, mass_sq, 'r-', linewidth=3, label='Mass² = S₀² - |S⃗|²')
ax3.plot(t, degree_pol, 'b-', linewidth=2, label='Degree of polarization')
ax3.fill_between(t, 0, mass_sq, color='red', alpha=0.1)

# Mark fully polarized endpoints
ax3.plot(0, 0, 'go', markersize=12, label='Fully polarized (null)', zorder=5)
ax3.plot(1, 0, 'go', markersize=12, zorder=5)
ax3.plot(0.5, 1.0, 'r*', markersize=15, label='Unpolarized (max mass)', zorder=5)

ax3.set_xlabel('Mixing parameter t', fontsize=12)
ax3.set_ylabel('Value', fontsize=12)
ax3.set_title('Mixing Light Creates Mass\n'
              'Convex combination of null Stokes vectors → timelike', fontsize=13)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

# ── Panel 4: Information Capacity ──
ax4 = fig.add_subplot(gs[2, 0])

categories = ['Photon\nAddresses\n(ℕ)', 'Gap\nRegions\n(ℝ \\ ℕ)']
# Use log scale to represent relative sizes
# ℵ₀ vs 𝔠 = 2^ℵ₀
heights = [1, 10]  # Symbolic: countable vs uncountable
colors_bars = ['gold', 'purple']

bars = ax4.bar(categories, heights, color=colors_bars, edgecolor='black', linewidth=2, alpha=0.7)
ax4.set_ylabel('Relative Information Capacity (symbolic)', fontsize=12)
ax4.set_title('Information Capacity: Light vs Matter\n'
              '|ℕ| = ℵ₀ (countable) vs |ℝ\\ℕ| = 𝔠 (uncountable)', fontsize=13)

ax4.annotate('ℵ₀\n(countable)', xy=(0, 1), xytext=(0, 2.5),
             ha='center', fontsize=14, fontweight='bold', color='darkorange')
ax4.annotate('𝔠 = 2^ℵ₀\n(uncountable)', xy=(1, 10), xytext=(1, 12),
             ha='center', fontsize=14, fontweight='bold', color='purple')

ax4.set_ylim(0, 15)

# ── Panel 5: Measure Theory ──
ax5 = fig.add_subplot(gs[2, 1])

# Visualize Lebesgue measure
x = np.linspace(0, 10, 10000)

# Cover ℕ ∩ [0,10] with intervals of total measure ε
epsilon = 0.3
y_cover = np.zeros_like(x)
for n in range(11):
    mask = np.abs(x - n) < epsilon / (2 ** (n + 2))
    y_cover[mask] = 1

ax5.fill_between(x, 0, 1 - y_cover, color='purple', alpha=0.3, label='ℝ \\ ℕ (measure = ∞)')
ax5.fill_between(x, 0, y_cover * 0.5, color='gold', alpha=0.7, label=f'ℕ cover (measure < ε)')

for n in range(11):
    ax5.axvline(x=n, color='darkorange', linewidth=0.5, alpha=0.3)
    ax5.plot(n, 0, 'o', color='gold', markersize=8, markeredgecolor='darkorange', zorder=5)

ax5.set_xlabel('x', fontsize=12)
ax5.set_title('Lebesgue Measure: ℕ has measure 0\n'
              'For any ε > 0, ℕ can be covered by intervals of total length < ε',
              fontsize=13)
ax5.legend(fontsize=10, loc='upper right')
ax5.set_ylim(-0.1, 1.1)
ax5.set_yticks([])

plt.savefig('/workspace/request-project/research_output/demos/fig5_gap_matter.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: fig5_gap_matter.png")

print("\n✅ Demo 3 complete: Gap-Matter Duality visualized")
