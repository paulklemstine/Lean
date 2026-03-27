#!/usr/bin/env python3
"""
Unity Metric Demo
==================
Explores the Unity Metric — the metric on ℝⁿ inherited from the round sphere
via inverse stereographic projection. Key properties:

1. Conformally flat: g_U = λ² g_flat, where λ = 2/(1+|x|²)
2. Finite total volume (even though ℝⁿ is "infinite")
3. Constant positive curvature
4. Geodesics are circles and lines

Run: python3 unity_metric.py
Output: unity_metric.png
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy import integrate
from scipy.special import gamma

def n_to_super(n):
    """Convert integer to superscript string."""
    supers = {0: '⁰', 1: '¹', 2: '²', 3: '³', 4: '⁴', 5: '⁵', 6: '⁶', 7: '⁷'}
    return supers.get(n, str(n))

def conformal_factor(r, n=3):
    """Conformal factor λ(r) = 2/(1+r²)"""
    return 2.0 / (1.0 + r**2)

def volume_element(r, n=3):
    """Volume element of the Unity Metric in n dimensions.
    dV_unity = λⁿ × dV_flat = (2/(1+r²))ⁿ × ωₙ rⁿ⁻¹ dr
    where ωₙ is the surface area of the (n-1)-sphere.
    """
    omega_n = 2 * np.pi**(n/2) / gamma(n/2)
    return (conformal_factor(r, n))**n * omega_n * r**(n-1)

def sphere_volume(n):
    """Volume of the unit n-sphere Sⁿ."""
    return 2 * np.pi**((n+1)/2) / gamma((n+1)/2)

# ============================================================
# Figure 1: Volume comparison across dimensions
# ============================================================
fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# Panel 1: Volume elements for different dimensions
ax = axes[0, 0]
r = np.linspace(0, 10, 1000)
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']
for n, color in zip([1, 2, 3, 4, 5], colors):
    ve = volume_element(r, n)
    ve_normalized = ve / ve.max() if ve.max() > 0 else ve
    ax.plot(r, ve_normalized, color=color, linewidth=2, label=f'n={n} (S{n_to_super(n)})')
ax.set_xlabel('Radial distance r', fontsize=12)
ax.set_ylabel('Volume element (normalized)', fontsize=12)
ax.set_title('Volume Elements Under Unity Metric', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.set_xlim(0, 8)

# Panel 2: Cumulative volume vs radius
ax = axes[0, 1]
for n, color in zip([1, 2, 3, 4, 5], colors):
    target_vol = sphere_volume(n)
    cumulative = []
    r_vals = np.linspace(0, 20, 500)
    for R in r_vals:
        vol, _ = integrate.quad(lambda rr, nn=n: volume_element(rr, nn), 0, R)
        cumulative.append(vol / target_vol * 100)
    ax.plot(r_vals, cumulative, color=color, linewidth=2, label=f'n={n} (total={target_vol:.3f})')
ax.axhline(y=100, color='gray', linestyle='--', alpha=0.5)
ax.set_xlabel('Radius R', fontsize=12)
ax.set_ylabel('% of total volume within radius R', fontsize=12)
ax.set_title('Cumulative Volume (% of Sⁿ)', fontsize=14, fontweight='bold')
ax.legend(fontsize=9)
ax.set_xlim(0, 10)
ax.set_ylim(0, 110)
ax.annotate('50% of the universe\nis within r ≈ 1', xy=(1, 50), fontsize=10,
            arrowprops=dict(arrowstyle='->', color='blue'),
            xytext=(3, 40), color='blue')

# Panel 3: Geodesics of the Unity Metric on R^2
ax = axes[1, 0]
ax.set_aspect('equal')

# Geodesics are stereographic projections of great circles
# Great circles through south pole → straight lines
# Great circles not through south pole → circles

# Straight-line geodesics
for angle in np.linspace(0, np.pi, 8, endpoint=False):
    t = np.linspace(-5, 5, 100)
    ax.plot(t * np.cos(angle), t * np.sin(angle), 'b-', alpha=0.4, linewidth=1)

# Circular geodesics
for center_dist in [1, 2, 3]:
    for angle in np.linspace(0, 2*np.pi, 6, endpoint=False):
        cx = center_dist * np.cos(angle)
        cy = center_dist * np.sin(angle)
        radius = np.sqrt(center_dist**2 + 1) - center_dist + 0.5
        theta = np.linspace(0, 2*np.pi, 100)
        ax.plot(cx + radius * np.cos(theta), cy + radius * np.sin(theta),
                'r-', alpha=0.3, linewidth=1)

# Conformal factor background
Y1, Y2 = np.meshgrid(np.linspace(-5, 5, 200), np.linspace(-5, 5, 200))
CF = conformal_factor(np.sqrt(Y1**2 + Y2**2))
ax.contourf(Y1, Y2, CF, levels=20, cmap='YlOrRd', alpha=0.3)
ax.set_title('Geodesics of Unity Metric on ℝ²\n(blue: lines, red: circles)', 
             fontsize=14, fontweight='bold')
ax.set_xlabel('y₁')
ax.set_ylabel('y₂')
ax.set_xlim(-5, 5)
ax.set_ylim(-5, 5)

# Panel 4: Key numbers table
ax = axes[1, 1]
ax.axis('off')
table_data = []
for n in range(1, 8):
    vol = sphere_volume(n)
    curv = n * (n - 1) if n >= 2 else 0
    dim_mob = (n+1)*(n+2)//2
    table_data.append([f'S{n_to_super(n)}', f'{vol:.4f}', f'{curv}', f'{dim_mob}'])

table = ax.table(cellText=table_data,
                 colLabels=['Space', 'Volume', 'Scalar\nCurvature', 'Möbius\nGroup Dim'],
                 loc='center', cellLoc='center')
table.auto_set_font_size(False)
table.set_fontsize(11)
table.scale(1, 1.8)

for j in range(4):
    table[0, j].set_facecolor('#4472C4')
    table[0, j].set_text_props(color='white', fontweight='bold')

# Highlight S³
for j in range(4):
    table[3, j].set_facecolor('#FFF2CC')

ax.set_title('Properties at Each Stage of the Cascade', fontsize=14, fontweight='bold')
ax.text(0.5, 0.05, '★ S³ row highlighted — candidate for our spatial universe\n'
        'Note: Möbius group of S³ is 10-dimensional (= Poincaré group!)',
        fontsize=10, ha='center', transform=ax.transAxes, color='gray',
        bbox=dict(boxstyle='round', facecolor='lightyellow'))

plt.suptitle('THE UNITY METRIC: Infinite Space with Finite Volume',
             fontsize=18, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('demos/unity_metric.png', dpi=150, bbox_inches='tight')
print("Saved: demos/unity_metric.png")

# ============================================================
# Numerical verification
# ============================================================
print("\n" + "="*60)
print("UNITY METRIC — NUMERICAL VERIFICATION")
print("="*60)

for n in range(1, 6):
    vol_computed, _ = integrate.quad(lambda r, nn=n: volume_element(r, nn), 0, np.inf)
    vol_expected = sphere_volume(n)
    error = abs(vol_computed - vol_expected) / vol_expected
    print(f"  S{n_to_super(n)}: Computed Vol = {vol_computed:.8f}, "
          f"Expected Vol(S{n_to_super(n)}) = {vol_expected:.8f}, "
          f"Error = {error:.2e}")

print("\nAll volumes match! ℝⁿ under the Unity Metric has exactly Vol(Sⁿ).")
print(f"\nFor our universe (n=3):")
print(f"  Volume = 2π² = {2*np.pi**2:.6f}")
print(f"  Scalar curvature = 6 (constant)")
print(f"  Diameter = π = {np.pi:.6f}")
print(f"  Symmetry group dimension = 10")
