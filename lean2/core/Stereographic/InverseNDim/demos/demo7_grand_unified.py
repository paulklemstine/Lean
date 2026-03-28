"""
Demo 7: The Grand Unified Vista — All Landscapes Connected
=============================================================
A panoramic visualization connecting all mathematical landscapes
discovered through inverse N-dimensional stereographic projection.

13 landscapes unified by SO(N+1,1) and the single formula:
    σ⁻¹(y) = (2y/(1+|y|²), (|y|²-1)/(1+|y|²))

The Counselor's synthesis: "One map. Infinite worlds."
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch, Circle
from scipy.special import lpmv
from math import factorial

# ─── Helper Functions ────────────────────────────────────────
def inv_stereo(u, v):
    D = 1 + u**2 + v**2
    return 2*u/D, 2*v/D, (D-2)/D

def conformal_factor(u, v):
    return 2 / (1 + u**2 + v**2)

def radial_map(r):
    return 2*r / (1 + r**2)

# ─── Figure ──────────────────────────────────────────────────
fig = plt.figure(figsize=(24, 18), facecolor='#050510')
gs = gridspec.GridSpec(4, 4, hspace=0.4, wspace=0.35)

# ── Central Title Panel ──────────────────────────────────────
ax_title = fig.add_subplot(gs[0, 1:3], facecolor='#050510')
ax_title.axis('off')
ax_title.text(0.5, 0.7, 'THE GRAND UNIFIED VISTA', transform=ax_title.transAxes,
             fontsize=28, fontweight='bold', color='#ffd700', ha='center', va='center',
             fontfamily='serif')
ax_title.text(0.5, 0.4, r'$\sigma_N^{-1}(y) = \left(\frac{2y}{1+\|y\|^2},\;\frac{\|y\|^2 - 1}{1+\|y\|^2}\right)$',
             transform=ax_title.transAxes, fontsize=16, color='white', ha='center', va='center')
ax_title.text(0.5, 0.15, 'One formula connecting 13 mathematical landscapes\nUnified by SO(N+1,1) — the conformal group',
             transform=ax_title.transAxes, fontsize=11, color='#aaaacc', ha='center', va='center')

# ── L1: Conformal Structure ─────────────────────────────────
ax1 = fig.add_subplot(gs[0, 0], facecolor='#050510')
L = 3
x = np.linspace(-L, L, 200)
y = np.linspace(-L, L, 200)
X, Y = np.meshgrid(x, y)
lam = conformal_factor(X, Y)
ax1.imshow(lam, extent=[-L,L,-L,L], cmap='inferno', origin='lower')
ax1.contour(X, Y, lam, levels=6, colors='white', alpha=0.3, linewidths=0.5)
ax1.set_title('L1: Conformal\nλ = 2/(1+|y|²)', color='#ff6600', fontsize=10, fontweight='bold')
ax1.set_aspect('equal')
ax1.tick_params(colors='white', labelsize=6)
for s in ax1.spines.values(): s.set_color('#222244')

# ── L2: Möbius Group ─────────────────────────────────────────
ax2 = fig.add_subplot(gs[0, 3], facecolor='#050510')
# Circle inversion pattern
theta = np.linspace(0, 2*np.pi, 200)
for r in [0.3, 0.5, 0.8, 1.0, 1.3, 1.8, 2.5]:
    cx, cy = r*np.cos(theta), r*np.sin(theta)
    # Invert through unit circle
    r2 = cx**2 + cy**2 + 0.01
    ix, iy = cx/r2, cy/r2
    ax2.plot(cx, cy, color='#00ddff', alpha=0.3, linewidth=0.5)
    ax2.plot(ix, iy, color='#ff3366', alpha=0.3, linewidth=0.5)
ax2.plot(np.cos(theta), np.sin(theta), color='#ffaa00', linewidth=2)
ax2.set_xlim(-3, 3); ax2.set_ylim(-3, 3); ax2.set_aspect('equal')
ax2.set_title('L2: Möbius Group\nInversion duality', color='#00ddff', fontsize=10, fontweight='bold')
ax2.tick_params(colors='white', labelsize=6)
for s in ax2.spines.values(): s.set_color('#222244')

# ── L3: Number Theory ───────────────────────────────────────
ax3 = fig.add_subplot(gs[1, 0], facecolor='#050510')
# Pythagorean triples on the unit circle
for a in range(1, 30):
    for b in range(1, 30):
        c2 = a*a + b*b
        c = int(np.sqrt(c2))
        if c*c == c2 and c > 0:
            # Rational point (a/c, b/c) on circle
            ax3.plot(a/c, b/c, 'o', color='#33ff99', markersize=3, alpha=0.7)
            # Stereographic preimage
            y_stereo = a / (c - b) if c != b else None
            if y_stereo and abs(y_stereo) < 10:
                ax3.plot(y_stereo, 0, '|', color='#ff6600', markersize=5, alpha=0.5)

ax3.plot(np.cos(theta), np.sin(theta), color='#ffaa00', linewidth=1, alpha=0.5)
ax3.set_xlim(-0.1, 1.1); ax3.set_ylim(-0.1, 1.1); ax3.set_aspect('equal')
ax3.set_title('L3: Number Theory\nRational points on S¹', color='#33ff99', fontsize=10, fontweight='bold')
ax3.tick_params(colors='white', labelsize=6)
for s in ax3.spines.values(): s.set_color('#222244')

# ── L4: Hopf Fibration ──────────────────────────────────────
ax4 = fig.add_subplot(gs[1, 1], facecolor='#050510')
theta_h = np.linspace(0, 2*np.pi, 200)
for k in range(25):
    phi = k * np.pi / 12.5
    psi = k * 0.7
    z1 = np.cos(phi/2) * np.exp(1j * (psi + theta_h) / 2)
    z2 = np.sin(phi/2) * np.exp(1j * (theta_h - psi) / 2)
    D = 1 - z2.imag + 0.01
    sx, sy = z1.real / D, z1.imag / D
    ax4.plot(sx, sy, linewidth=0.4, alpha=0.6, color=plt.cm.hsv(phi / np.pi))
ax4.set_xlim(-3, 3); ax4.set_ylim(-3, 3); ax4.set_aspect('equal')
ax4.set_title('L4: Hopf Fibration\nS¹ → S³ → S²', color='#ff00ff', fontsize=10, fontweight='bold')
ax4.tick_params(colors='white', labelsize=6)
for s in ax4.spines.values(): s.set_color('#222244')

# ── L5: Lorentzian / CFT ────────────────────────────────────
ax5 = fig.add_subplot(gs[1, 2], facecolor='#050510')
# Light cone in stereographic coordinates
t = np.linspace(-3, 3, 200)
for v in np.linspace(-2, 2, 20):
    ax5.plot(t, t + v, color='#ff3333', alpha=0.15, linewidth=0.5)
    ax5.plot(t, -t + v, color='#3333ff', alpha=0.15, linewidth=0.5)
# Null cone
ax5.plot(t, t, color='#ff3333', linewidth=2, label='Future light')
ax5.plot(t, -t, color='#3333ff', linewidth=2, label='Past light')
ax5.plot(0, 0, 'o', color='#ffd700', markersize=10, zorder=5)
ax5.set_xlim(-3, 3); ax5.set_ylim(-3, 3); ax5.set_aspect('equal')
ax5.set_title('L5: Lorentzian\nNull cone / CFT', color='#ff3333', fontsize=10, fontweight='bold')
ax5.tick_params(colors='white', labelsize=6)
for s in ax5.spines.values(): s.set_color('#222244')

# ── L6: Apollonian Packing ──────────────────────────────────
ax6 = fig.add_subplot(gs[1, 3], facecolor='#050510')
# Simple Apollonian-like packing
def draw_apollonian(ax, x, y, r, depth=0, max_depth=5):
    if depth >= max_depth or r < 0.005:
        return
    circle = Circle((x, y), r, fill=False, color=plt.cm.plasma(depth/max_depth),
                    linewidth=max(0.3, 1.5 - depth*0.3), alpha=0.8)
    ax.add_patch(circle)
    # Three smaller tangent circles
    for angle in [0, 2*np.pi/3, 4*np.pi/3]:
        r_new = r * 0.42
        x_new = x + (r - r_new) * np.cos(angle + depth*0.3)
        y_new = y + (r - r_new) * np.sin(angle + depth*0.3)
        draw_apollonian(ax, x_new, y_new, r_new, depth+1, max_depth)

draw_apollonian(ax6, 0, 0, 1.5, max_depth=5)
ax6.set_xlim(-2, 2); ax6.set_ylim(-2, 2); ax6.set_aspect('equal')
ax6.set_title('L6: Apollonian\nDescartes packing', color='#ffaa00', fontsize=10, fontweight='bold')
ax6.tick_params(colors='white', labelsize=6)
for s in ax6.spines.values(): s.set_color('#222244')

# ── L7: Dynamics ─────────────────────────────────────────────
ax7 = fig.add_subplot(gs[2, 0], facecolor='#050510')
r = np.linspace(0, 4, 300)
fr = radial_map(r)
ax7.plot(r, r, '--', color='#444466', linewidth=1)
ax7.plot(r, fr, color='#00ddff', linewidth=2.5)
ax7.plot([1], [1], 'o', color='#ff6600', markersize=10)
ax7.set_title('L7: Dynamics\nf(r) = 2r/(1+r²)', color='#00ddff', fontsize=10, fontweight='bold')
ax7.tick_params(colors='white', labelsize=6)
for s in ax7.spines.values(): s.set_color('#222244')

# ── L8: Energy ───────────────────────────────────────────────
ax8 = fig.add_subplot(gs[2, 1], facecolor='#050510')
E = 4 * 2 / (1 + X**2 + Y**2)**2
ax8.imshow(E, extent=[-L,L,-L,L], cmap='magma', origin='lower')
ax8.set_title('L8: Energy\ne = 8/(1+|y|²)²', color='#ff6600', fontsize=10, fontweight='bold')
ax8.set_aspect('equal')
ax8.tick_params(colors='white', labelsize=6)
for s in ax8.spines.values(): s.set_color('#222244')

# ── L9: Information ──────────────────────────────────────────
ax9 = fig.add_subplot(gs[2, 2], facecolor='#050510')
G = 16 / (1 + X**2 + Y**2)**2
ax9.imshow(np.log10(G), extent=[-L,L,-L,L], cmap='viridis', origin='lower')
ax9.plot(np.cos(theta), np.sin(theta), color='#ff6600', linewidth=1.5)
ax9.set_title('L9: Fisher Info\ng = 16/(1+|y|²)²', color='#33ff99', fontsize=10, fontweight='bold')
ax9.set_aspect('equal')
ax9.tick_params(colors='white', labelsize=6)
for s in ax9.spines.values(): s.set_color('#222244')

# ── L10: Spectral ────────────────────────────────────────────
ax10 = fig.add_subplot(gs[2, 3], facecolor='#050510')
# Manual spherical harmonic Y_3^2
_theta_h = np.arccos(np.clip((X**2+Y**2-1)/(X**2+Y**2+1), -1, 1))
_phi_h = np.arctan2(Y, X)
_norm_h = np.sqrt(7/(4*np.pi) * factorial(1)/factorial(5))
Y_harm = _norm_h * lpmv(2, 3, np.cos(_theta_h)) * np.cos(2 * _phi_h) * np.sqrt(2)
mask = X**2 + Y**2 < L**2
ax10.imshow(Y_harm * mask, extent=[-L,L,-L,L], cmap='RdBu_r', origin='lower')
ax10.set_title('L10: Spectral\nY₃² in stereo coords', color='#ff00ff', fontsize=10, fontweight='bold')
ax10.set_aspect('equal')
ax10.tick_params(colors='white', labelsize=6)
for s in ax10.spines.values(): s.set_color('#222244')

# ── L11: Quantum ─────────────────────────────────────────────
ax11 = fig.add_subplot(gs[3, 0], facecolor='#050510')
# Husimi-like function
Z = X + 1j * Y
Q = np.abs(Z**3 + 1)**2 / (1 + np.abs(Z)**2)**6
ax11.imshow(Q, extent=[-L,L,-L,L], cmap='hot', origin='lower')
ax11.set_title('L11: Quantum\nHusimi Q(z)', color='#ffd700', fontsize=10, fontweight='bold')
ax11.set_aspect('equal')
ax11.tick_params(colors='white', labelsize=6)
for s in ax11.spines.values(): s.set_color('#222244')

# ── L12: Blowup ──────────────────────────────────────────────
ax12 = fig.add_subplot(gs[3, 1], facecolor='#050510')
# Blowup at origin visualization
R = np.sqrt(X**2 + Y**2) + 0.001
Theta = np.arctan2(Y, X)
# Exceptional divisor: project by angle
blowup = np.sin(5 * Theta) / (R + 0.1)
ax12.imshow(blowup, extent=[-L,L,-L,L], cmap='twilight', origin='lower')
ax12.plot(0, 0, '*', color='#ffd700', markersize=15, zorder=5)
ax12.set_title('L12: Blowup\nResolving ∞', color='#ff3366', fontsize=10, fontweight='bold')
ax12.set_aspect('equal')
ax12.tick_params(colors='white', labelsize=6)
for s in ax12.spines.values(): s.set_color('#222244')

# ── L13: Dimensional Resonance ──────────────────────────────
ax13 = fig.add_subplot(gs[3, 2], facecolor='#050510')
dims = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 16, 24]
properties = [3, 5, 2, 5, 2, 2, 2, 5, 2, 2, 2, 3]  # Number of special properties
colors_res = ['#ff6600' if d in [1,2,4,8] else '#00ddff' if d == 24 else '#333366' for d in dims]
ax13.bar(range(len(dims)), properties, color=colors_res, edgecolor='none')
ax13.set_xticks(range(len(dims)))
ax13.set_xticklabels([str(d) for d in dims], fontsize=7)
ax13.set_xlabel('Dimension', color='white', fontsize=8)
ax13.set_ylabel('# Special Properties', color='white', fontsize=8)
ax13.set_title('L13: Resonance\nSpecial dimensions', color='#ffd700', fontsize=10, fontweight='bold')
ax13.tick_params(colors='white', labelsize=6)
for s in ax13.spines.values(): s.set_color('#222244')

# ── Connection Map ───────────────────────────────────────────
ax_conn = fig.add_subplot(gs[3, 3], facecolor='#050510')
ax_conn.axis('off')

# Draw the unifying group at center
ax_conn.text(0.5, 0.5, 'SO(N+1,1)', fontsize=18, fontweight='bold',
            color='#ffd700', ha='center', va='center', transform=ax_conn.transAxes,
            bbox=dict(boxstyle='round,pad=0.5', facecolor='#0d0d2e', edgecolor='#ffd700', linewidth=2))

# Landscape labels around it
labels = ['Conformal', 'Möbius', 'Numbers', 'Hopf', 'Lorentz', 'Apollonian',
          'Dynamics', 'Energy', 'Fisher', 'Spectral', 'Quantum', 'Blowup', 'Resonance']
angles = np.linspace(0, 2*np.pi, len(labels), endpoint=False)
for i, (label, angle) in enumerate(zip(labels, angles)):
    x = 0.5 + 0.4 * np.cos(angle)
    y = 0.5 + 0.4 * np.sin(angle)
    ax_conn.text(x, y, label, fontsize=7, color='white', ha='center', va='center',
                transform=ax_conn.transAxes, alpha=0.8)
    ax_conn.annotate('', xy=(0.5 + 0.15*np.cos(angle), 0.5 + 0.15*np.sin(angle)),
                    xytext=(0.5 + 0.33*np.cos(angle), 0.5 + 0.33*np.sin(angle)),
                    xycoords='axes fraction',
                    arrowprops=dict(arrowstyle='->', color='#ffd700', lw=1, alpha=0.5))

ax_conn.set_title('The Unifying\nSymmetry', color='#ffd700', fontsize=10, fontweight='bold')

fig.suptitle('', fontsize=1)  # suppress default

plt.tight_layout(rect=[0, 0, 1, 0.99])
plt.savefig('/workspace/request-project/Stereographic/InverseNDim/demos/demo7_grand_unified.png',
            dpi=150, bbox_inches='tight', facecolor='#050510')
plt.close()
print("✅ Demo 7: Grand Unified Vista — saved!")
