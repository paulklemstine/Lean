"""
Demo 6: Dimensional Resonance — Why N = 1, 2, 4, 8 Are Special
================================================================
Visualizes the special algebraic structures that exist only at
dimensions corresponding to the normed division algebras:
ℝ (N=1), ℂ (N=2), ℍ (N=4), 𝕆 (N=8).

The Counselor's insight: these dimensions create "resonance" where
stereographic projection, Pythagorean tuples, Hopf fibrations, and
the Möbius group all align simultaneously.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from math import gamma, pi, factorial, comb as math_comb

# ─── Mathematical Functions ──────────────────────────────────
def vol_sphere(n):
    """Volume of S^n (surface area of the n-sphere)."""
    return 2 * pi**((n+1)/2) / gamma((n+1)/2)

def mobius_dim(n):
    """Dimension of Möb(n) = SO(n+1,1)."""
    return (n+1)*(n+2)//2

def eigenvalue_multiplicity(l, n):
    """Multiplicity of eigenvalue -l(l+n-1) of Δ_{S^n}."""
    if l == 0:
        return 1
    return math_comb(n+l, n) - math_comb(n+l-2, n)

def sum_of_squares_representations(n, target):
    """Count ways to write target as sum of n squares (approximate for visualization)."""
    if n == 1:
        s = int(np.sqrt(target))
        return 1 if s*s == target else 0
    
    count = 0
    for i in range(int(np.sqrt(target)) + 1):
        count += sum_of_squares_representations(n-1, target - i*i)
    return count

# ─── Figure ──────────────────────────────────────────────────
fig = plt.figure(figsize=(20, 16), facecolor='#0a0a1a')
gs = gridspec.GridSpec(3, 4, hspace=0.4, wspace=0.35)

# ── Row 1: Sphere volumes and Möbius dimensions ─────────────

# Panel 1: Sphere volumes
ax1 = fig.add_subplot(gs[0, 0], facecolor='#0a0a1a')
dims = np.arange(0, 25)
vols = [vol_sphere(n) for n in dims]
colors = ['#ff6600' if n in [1,2,4,8] else '#00ddff' for n in dims]
bars = ax1.bar(dims, vols, color=colors, edgecolor='none', alpha=0.8)
ax1.set_xlabel('Dimension N', color='white', fontsize=10)
ax1.set_ylabel('Vol(S^N)', color='white', fontsize=10)
ax1.set_title('Sphere Volumes', color='#ff6600', fontsize=12, fontweight='bold')
ax1.tick_params(colors='white')
for spine in ax1.spines.values():
    spine.set_color('#333355')

# Panel 2: Möbius group dimensions
ax2 = fig.add_subplot(gs[0, 1], facecolor='#0a0a1a')
mob_dims = [mobius_dim(n) for n in range(1, 25)]
colors2 = ['#ff6600' if n in [1,2,4,8] else '#00ddff' for n in range(1, 25)]
ax2.bar(range(1, 25), mob_dims, color=colors2, edgecolor='none', alpha=0.8)
ax2.set_xlabel('Dimension N', color='white', fontsize=10)
ax2.set_ylabel('dim Möb(N)', color='white', fontsize=10)
ax2.set_title('Möbius Group Dimension\n(N+1)(N+2)/2', color='#ff6600', fontsize=12, fontweight='bold')
ax2.tick_params(colors='white')
for spine in ax2.spines.values():
    spine.set_color('#333355')

# Panel 3: Spectral multiplicity
ax3 = fig.add_subplot(gs[0, 2], facecolor='#0a0a1a')
for n in [1, 2, 4, 8]:
    l_vals = range(0, 10)
    mults = [eigenvalue_multiplicity(l, n) for l in l_vals]
    ax3.plot(l_vals, mults, 'o-', linewidth=2, markersize=6, label=f'N={n}')

ax3.set_xlabel('Degree l', color='white', fontsize=10)
ax3.set_ylabel('Multiplicity m(l,N)', color='white', fontsize=10)
ax3.set_title('Eigenvalue Multiplicities', color='#ff6600', fontsize=12, fontweight='bold')
ax3.legend(fontsize=9, facecolor='#1a1a2e', edgecolor='#333355', labelcolor='white')
ax3.set_yscale('log')
ax3.tick_params(colors='white')
for spine in ax3.spines.values():
    spine.set_color('#333355')

# Panel 4: The resonance table
ax4 = fig.add_subplot(gs[0, 3], facecolor='#0a0a1a')
ax4.axis('off')

table_data = [
    ['N', 'Algebra', 'Hopf', 'Pythagorean', 'Möb dim'],
    ['1', 'ℝ', '—', 'trivial', '3'],
    ['2', 'ℂ', 'S¹→S³→S²', 'Brahmagupta', '6'],
    ['4', 'ℍ', 'S³→S⁷→S⁴', 'Euler 4-sq', '15'],
    ['8', '𝕆', 'S⁷→S¹⁵→S⁸', 'Degen 8-sq', '45'],
]

for i, row in enumerate(table_data):
    for j, cell in enumerate(row):
        bg = '#1a1a3e' if i == 0 else '#0d0d1e'
        color = '#ff6600' if i == 0 else '#00ddff' if i in [1,2,3,4] else 'white'
        fontweight = 'bold' if i == 0 else 'normal'
        ax4.text(j/5 + 0.1, 1 - i/6 - 0.05, cell,
                color=color, fontsize=10, fontweight=fontweight,
                transform=ax4.transAxes, ha='center', va='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor=bg, edgecolor='#333355'))

ax4.set_title('The Resonance Table', color='#ff6600', fontsize=12, fontweight='bold')

# ── Row 2: Conformal factors and volume concentration ────────

# Panel 5: Conformal factor curves by dimension
ax5 = fig.add_subplot(gs[1, 0], facecolor='#0a0a1a')
r = np.linspace(0, 5, 500)
for N in [1, 2, 4, 8, 16]:
    lambda_N = (2/(1+r**2))**N
    ax5.plot(r, lambda_N, linewidth=2, label=f'N={N}')

ax5.set_xlabel('r = |y|', color='white', fontsize=10)
ax5.set_ylabel('λ^N = (2/(1+r²))^N', color='white', fontsize=10)
ax5.set_title('Volume Element by Dimension\n(measure concentration)', color='#ff6600', fontsize=12, fontweight='bold')
ax5.legend(fontsize=9, facecolor='#1a1a2e', edgecolor='#333355', labelcolor='white')
ax5.set_yscale('log')
ax5.set_ylim(1e-8, 10)
ax5.tick_params(colors='white')
for spine in ax5.spines.values():
    spine.set_color('#333355')

# Panel 6: Sum of squares representations (N=2 vs N=4)
ax6 = fig.add_subplot(gs[1, 1], facecolor='#0a0a1a')
targets = range(0, 30)
reps_2 = [sum_of_squares_representations(2, t) for t in targets]
# For N=4, use formula: r_4(n) = 8 Σ_{d|n, 4∤d} d
def r4(n):
    if n == 0:
        return 1
    s = 0
    for d in range(1, n+1):
        if n % d == 0 and d % 4 != 0:
            s += d
    return 8 * s

reps_4 = [r4(t) for t in targets]

ax6.bar(np.array(list(targets)) - 0.15, reps_2, width=0.3, color='#00ddff', alpha=0.8, label='N=2 (Gaussian)')
ax6.bar(np.array(list(targets)) + 0.15, [min(r, 300) for r in reps_4], width=0.3, color='#ff6600', alpha=0.8, label='N=4 (Jacobi)')

ax6.set_xlabel('n', color='white', fontsize=10)
ax6.set_ylabel('r_N(n) = # representations', color='white', fontsize=10)
ax6.set_title('Sum-of-Squares Representations\nr_N(n) = #{a: Σaᵢ²=n}', color='#ff6600', fontsize=12, fontweight='bold')
ax6.legend(fontsize=9, facecolor='#1a1a2e', edgecolor='#333355', labelcolor='white')
ax6.tick_params(colors='white')
for spine in ax6.spines.values():
    spine.set_color('#333355')

# Panel 7: Hopf fibration structure
ax7 = fig.add_subplot(gs[1, 2], facecolor='#0a0a1a')

# Visualize the Hopf map: circles in S³ projected to S²
# Use stereographic projection S³ → ℝ³, then project to 2D
theta = np.linspace(0, 2*np.pi, 200)
n_fibers = 20
phi_vals = np.linspace(0, np.pi, n_fibers)
psi_vals = np.linspace(0, 2*np.pi, n_fibers)

for k in range(n_fibers):
    phi = phi_vals[k % len(phi_vals)]
    psi = psi_vals[k % len(psi_vals)]
    
    # Hopf fiber parametrized by t
    z1 = np.cos(phi/2) * np.exp(1j * (psi + theta) / 2)
    z2 = np.sin(phi/2) * np.exp(1j * (theta - psi) / 2)
    
    # Points on S³
    x1 = z1.real
    x2 = z1.imag
    x3 = z2.real
    x4 = z2.imag
    
    # Stereographic S³ → ℝ³
    D = 1 - x4
    D = np.where(np.abs(D) < 0.01, 0.01, D)
    sx = x1 / D
    sy = x2 / D
    sz = x3 / D
    
    # Project to 2D for visualization
    proj_x = sx + 0.3 * sz
    proj_y = sy + 0.3 * sz
    
    ax7.plot(proj_x, proj_y, linewidth=0.5, alpha=0.6,
             color=plt.cm.hsv(phi / np.pi))

ax7.set_xlim(-4, 4)
ax7.set_ylim(-4, 4)
ax7.set_aspect('equal')
ax7.set_title('Hopf Fibers (S³→S² via stereo)', color='#ff6600', fontsize=12, fontweight='bold')
ax7.tick_params(colors='white')
for spine in ax7.spines.values():
    spine.set_color('#333355')

# Panel 8: Parallelize-ability
ax8 = fig.add_subplot(gs[1, 3], facecolor='#0a0a1a')

# The spheres S^0, S^1, S^3, S^7 are the only parallelizable spheres
# Visualize this by showing vector fields

# S¹ vector field (tangent field — always nonzero)
theta_s1 = np.linspace(0, 2*np.pi, 50)
cx, cy = np.cos(theta_s1), np.sin(theta_s1)
tx, ty = -np.sin(theta_s1), np.cos(theta_s1)
ax8.quiver(cx + 0, cy + 2.5, tx*0.2, ty*0.2, color='#00ddff', scale=5, width=0.005)
ax8.plot(np.cos(np.linspace(0, 2*np.pi, 100)), 
         np.sin(np.linspace(0, 2*np.pi, 100)) + 2.5,
         color='#ff6600', linewidth=2)
ax8.text(0, 2.5, 'S¹ ✓', color='#33ff99', fontsize=14, ha='center', fontweight='bold')

# S² — hairy ball theorem (NO nonvanishing vector field)
theta_s2 = np.linspace(0.2, np.pi - 0.2, 10)
phi_s2 = np.linspace(0, 2*np.pi, 20)
for t in theta_s2:
    for p in phi_s2:
        x = np.sin(t) * np.cos(p) * 0.8
        y = np.sin(t) * np.sin(p) * 0.8
        # Vector field with singularity (not parallelizable)
        vx = -np.sin(p) * 0.05
        vy = np.cos(p) * np.cos(t) * 0.05
        ax8.arrow(x - 2.5, y, vx, vy, head_width=0.02, head_length=0.01,
                 fc='#ff3333', ec='#ff3333', alpha=0.5)

ax8.plot(np.cos(np.linspace(0, 2*np.pi, 100)) * 0.8 - 2.5,
         np.sin(np.linspace(0, 2*np.pi, 100)) * 0.8,
         color='#ff6600', linewidth=2)
ax8.text(-2.5, 0, 'S² ✗', color='#ff3333', fontsize=14, ha='center', fontweight='bold')

# S³ label
ax8.text(2.5, 0, 'S³ ✓\n(quaternion\nstructure)', color='#33ff99', fontsize=12, 
         ha='center', fontweight='bold')
ax8.add_patch(plt.Circle((2.5, 0), 0.8, fill=False, color='#ff6600', linewidth=2))

# S⁷ label
ax8.text(0, -2.5, 'S⁷ ✓\n(octonion\nstructure)', color='#33ff99', fontsize=12,
         ha='center', fontweight='bold')
ax8.add_patch(plt.Circle((0, -2.5), 0.8, fill=False, color='#ff6600', linewidth=2))

ax8.set_xlim(-4, 4)
ax8.set_ylim(-4, 4)
ax8.set_aspect('equal')
ax8.set_title('Parallelizable Spheres\n(Adams 1962)', color='#ff6600', fontsize=12, fontweight='bold')
ax8.tick_params(colors='white')
for spine in ax8.spines.values():
    spine.set_color('#333355')

# ── Row 3: Cross-landscape connections ──────────────────────

# Panel 9: The "diamond" of normed division algebras
ax9 = fig.add_subplot(gs[2, 0:2], facecolor='#0a0a1a')
ax9.axis('off')

# Draw the hierarchy
positions = {
    'ℝ': (0.5, 0.1),
    'ℂ': (0.3, 0.4),
    'ℍ': (0.7, 0.4),
    '𝕆': (0.5, 0.7),
}

properties = {
    'ℝ': 'ordered, commutative\nassociative, alternative',
    'ℂ': 'commutative\nassociative, alternative',
    'ℍ': 'associative\nalternative',
    '𝕆': 'alternative\n(only)',
}

colors_alg = {'ℝ': '#00ddff', 'ℂ': '#33ff99', 'ℍ': '#ffaa00', '𝕆': '#ff3366'}

for name, (x, y) in positions.items():
    ax9.text(x, y, name, transform=ax9.transAxes, fontsize=36, fontweight='bold',
            color=colors_alg[name], ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='#0d0d2e', edgecolor=colors_alg[name], linewidth=2))
    ax9.text(x, y - 0.08, properties[name], transform=ax9.transAxes, fontsize=8,
            color='white', ha='center', va='top', alpha=0.7)

# Arrows showing loss of properties
arrow_style = dict(arrowstyle='->', color='#666688', lw=2)
ax9.annotate('', xy=(0.3, 0.35), xytext=(0.5, 0.15), xycoords='axes fraction',
            arrowprops=arrow_style)
ax9.annotate('', xy=(0.7, 0.35), xytext=(0.5, 0.15), xycoords='axes fraction',
            arrowprops=arrow_style)
ax9.annotate('', xy=(0.5, 0.63), xytext=(0.3, 0.45), xycoords='axes fraction',
            arrowprops=arrow_style)
ax9.annotate('', xy=(0.5, 0.63), xytext=(0.7, 0.45), xycoords='axes fraction',
            arrowprops=arrow_style)

ax9.text(0.25, 0.22, 'lose\nordering', transform=ax9.transAxes, fontsize=8, color='#888888', ha='center', style='italic')
ax9.text(0.75, 0.22, 'lose\nordering', transform=ax9.transAxes, fontsize=8, color='#888888', ha='center', style='italic')
ax9.text(0.32, 0.55, 'lose\ncommutativity', transform=ax9.transAxes, fontsize=8, color='#888888', ha='center', style='italic')
ax9.text(0.68, 0.55, 'lose\nassociativity', transform=ax9.transAxes, fontsize=8, color='#888888', ha='center', style='italic')

ax9.set_title('Cayley-Dickson Hierarchy of Normed Division Algebras', color='#ff6600', fontsize=13, fontweight='bold')

# Panel 10-11: Conformal factor comparison at resonant dimensions
ax10 = fig.add_subplot(gs[2, 2:4], facecolor='#0a0a1a')

# Show that at resonant dimensions, the stereographic energy integral
# has especially nice closed forms
dims_all = range(1, 20)
energies = []
for n in dims_all:
    # E(N) = N * Vol(S^N) = N * 2π^{(N+1)/2} / Γ((N+1)/2)
    e = n * vol_sphere(n)
    energies.append(e)

colors_bar = ['#ff6600' if n in [1,2,4,8] else '#333366' for n in dims_all]
ax10.bar(list(dims_all), energies, color=colors_bar, edgecolor='none', alpha=0.8)

# Annotate resonant dimensions
for n, e in zip(dims_all, energies):
    if n in [1, 2, 4, 8]:
        ax10.annotate(f'N={n}\nE={e:.2f}',
                     (n, e), textcoords="offset points", xytext=(0, 10),
                     ha='center', color='#ff6600', fontsize=9, fontweight='bold')

ax10.set_xlabel('Dimension N', color='white', fontsize=11)
ax10.set_ylabel('Dirichlet Energy E = N·Vol(S^N)', color='white', fontsize=11)
ax10.set_title('Energy at Resonant Dimensions\nOrange = normed division algebra dimensions',
              color='#ff6600', fontsize=12, fontweight='bold')
ax10.tick_params(colors='white')
for spine in ax10.spines.values():
    spine.set_color('#333355')

fig.suptitle('DIMENSIONAL RESONANCE: WHY N = 1, 2, 4, 8 ARE SPECIAL\n'
             'Normed division algebras create simultaneous alignment across all stereographic landscapes',
             color='white', fontsize=16, fontweight='bold', y=0.98)

plt.tight_layout(rect=[0, 0, 1, 0.93])
plt.savefig('/workspace/request-project/Stereographic/InverseNDim/demos/demo6_dimensional_resonance.png',
            dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
plt.close()
print("✅ Demo 6: Dimensional Resonance — saved!")
