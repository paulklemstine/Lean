"""
Demo 4: Spectral Geometry Through the Stereographic Lens
=========================================================
Visualizes spherical harmonics in stereographic coordinates,
revealing how the Laplacian eigenfunctions on S² become
rational functions in the plane.

Oracle Ω + Oracle Σ's discovery: the stereographic spectral
decomposition transforms spherical harmonics Y_l^m into
rational functions with denominator (1+|y|²)^l.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from scipy.special import lpmv

# ─── Helper Functions ────────────────────────────────────────
def stereo_to_sphere(u, v):
    """Inverse stereographic: (u,v) → (θ,φ) on S²."""
    r2 = u**2 + v**2
    D = 1 + r2
    x = 2*u/D
    y = 2*v/D
    z = (D - 2)/D
    
    theta = np.arccos(np.clip(z, -1, 1))
    phi = np.arctan2(y, x)
    return theta, phi

def real_spherical_harmonic(l, m, theta, phi):
    """Manual implementation of real spherical harmonics."""
    from scipy.special import lpmv
    from math import factorial
    # Normalization
    norm = np.sqrt((2*l+1)/(4*np.pi) * factorial(l-abs(m))/factorial(l+abs(m)))
    P = lpmv(abs(m), l, np.cos(theta))
    if m > 0:
        return norm * P * np.cos(m * phi) * np.sqrt(2)
    elif m < 0:
        return norm * P * np.sin(abs(m) * phi) * np.sqrt(2)
    else:
        return norm * P

def spherical_harmonic_stereo(l, m, u, v):
    """Evaluate Y_l^m in stereographic coordinates."""
    theta, phi = stereo_to_sphere(u, v)
    return real_spherical_harmonic(l, m, theta, phi)

def conformal_weight(u, v, l):
    """Conformal weight factor for degree l harmonic."""
    r2 = u**2 + v**2
    return (2 / (1 + r2))**l

# ─── Figure ──────────────────────────────────────────────────
fig = plt.figure(figsize=(20, 16), facecolor='#0a0a1a')

# Show Y_l^m for various (l,m) in stereographic coordinates
harmonics = [(0,0), (1,0), (1,1), (2,0), (2,1), (2,2),
             (3,0), (3,1), (3,2), (3,3), (4,0), (4,2)]

L = 4
res = 300
u = np.linspace(-L, L, res)
v = np.linspace(-L, L, res)
U, V = np.meshgrid(u, v)

for idx, (l, m) in enumerate(harmonics):
    ax = fig.add_subplot(3, 4, idx+1, facecolor='#0a0a1a')
    
    Y = spherical_harmonic_stereo(l, m, U, V)
    
    # Apply conformal weighting for visualization
    # (raw harmonics diverge near north pole in stereo coords)
    mask = U**2 + V**2 < L**2
    Y_display = Y * mask
    
    vmax = np.percentile(np.abs(Y_display[mask]), 95)
    if vmax < 1e-10:
        vmax = 1.0
    
    im = ax.imshow(Y_display, extent=[-L, L, -L, L], cmap='RdBu_r',
                   origin='lower', vmin=-vmax, vmax=vmax)
    
    # Draw unit circle
    theta_c = np.linspace(0, 2*np.pi, 200)
    ax.plot(np.cos(theta_c), np.sin(theta_c), color='#33ff99', linewidth=1, alpha=0.5)
    
    # Nodal lines (where Y = 0)
    ax.contour(U, V, Y, levels=[0], colors=['#ffffff'], linewidths=0.8, alpha=0.5)
    
    ax.set_xlim(-L, L)
    ax.set_ylim(-L, L)
    ax.set_aspect('equal')
    ax.set_title(f'Y_{l}^{m}  (λ = -{l*(l+1)})', color='#00ddff', fontsize=10, fontweight='bold')
    ax.tick_params(colors='white', labelsize=7)
    for spine in ax.spines.values():
        spine.set_color('#333355')

fig.suptitle('SPHERICAL HARMONICS IN STEREOGRAPHIC COORDINATES\n'
             'Eigenfunctions of Δ_{S²} become rational functions in the plane\n'
             'White lines = nodal curves; Green circle = equator',
             color='white', fontsize=15, fontweight='bold', y=0.98)

plt.tight_layout(rect=[0, 0, 1, 0.93])
plt.savefig('/workspace/request-project/Stereographic/InverseNDim/demos/demo4_spectral_harmonics.png',
            dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
plt.close()
print("✅ Demo 4: Spectral Harmonics — saved!")
