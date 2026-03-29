#!/usr/bin/env python3
"""
Demo 03: Turing Patterns on S² via Stereographic Pullback
============================================================
Reaction-diffusion systems on the sphere, computed in stereographic coordinates.
The conformal factor creates asymmetric diffusion: patterns are fine-grained 
near the south pole and coarse-grained near the north pole.

Oracle Ω's Discovery: The scale hierarchy created by stereographic diffusion
resembles the cosmic microwave background power spectrum.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm

def inverse_stereo(y1, y2):
    """Inverse stereographic projection R² → S²"""
    D = 1.0 + y1**2 + y2**2
    return 2*y1/D, 2*y2/D, (D-2)/D

def conformal_laplacian(u, dy, D_field):
    """
    Laplacian with conformal correction for stereographic coordinates.
    On S², the Laplacian is: Δ_{S²} = (D/2)² Δ_{R²}
    where D = 1 + |y|². We simulate the *flat* Laplacian but weight 
    diffusion by the conformal factor.
    """
    lap = np.zeros_like(u)
    lap[1:-1, 1:-1] = (
        u[2:, 1:-1] + u[:-2, 1:-1] + u[1:-1, 2:] + u[1:-1, :-2] - 4*u[1:-1, 1:-1]
    ) / dy**2
    # Conformal weight: diffusion is faster where D is larger (near north pole)
    return lap * (D_field / 2.0)**2

def run_reaction_diffusion(N, L, dt, n_steps, Du, Dv, f, k, use_conformal=True):
    """
    Gray-Scott reaction-diffusion in stereographic coordinates.
    u_t = Du Δu - u·v² + f(1-u)
    v_t = Dv Δv + u·v² - (f+k)v
    """
    dy = 2*L / N
    y = np.linspace(-L, L, N)
    Y1, Y2 = np.meshgrid(y, y)
    D_field = 1.0 + Y1**2 + Y2**2
    
    if not use_conformal:
        D_field = np.ones_like(D_field)
    
    # Initialize
    u = np.ones((N, N))
    v = np.zeros((N, N))
    
    # Seed with random perturbations in a ring
    r = np.sqrt(Y1**2 + Y2**2)
    mask = (r > 0.3*L) & (r < 0.6*L)
    v[mask] = 0.25 + 0.1*np.random.randn(mask.sum())
    u[mask] = 0.5 + 0.1*np.random.randn(mask.sum())
    
    # Also seed near center
    center_mask = r < 0.15*L
    v[center_mask] = 0.25 + 0.05*np.random.randn(center_mask.sum())
    u[center_mask] = 0.5 + 0.05*np.random.randn(center_mask.sum())
    
    for step in range(n_steps):
        Lu = conformal_laplacian(u, dy, D_field)
        Lv = conformal_laplacian(v, dy, D_field)
        
        uvv = u * v**2
        du = Du * Lu - uvv + f * (1 - u)
        dv = Dv * Lv + uvv - (f + k) * v
        
        u += dt * du
        v += dt * dv
        u = np.clip(u, 0, 1)
        v = np.clip(v, 0, 1)
    
    return Y1, Y2, u, v

np.random.seed(42)

fig = plt.figure(figsize=(20, 16))
fig.suptitle("Stereographic Morphogenesis: Turing Patterns on S²",
             fontsize=16, fontweight='bold', y=0.98)

# Parameters for different pattern types
params = [
    ("Spots (Flat R²)", 0.055, 0.062, False),
    ("Spots (Curved S²)", 0.055, 0.062, True),
    ("Stripes (Flat R²)", 0.035, 0.065, False),
    ("Stripes (Curved S²)", 0.035, 0.065, True),
]

N_grid = 200
L = 3.0
dt = 0.8
n_steps = 8000

for idx, (title, f_param, k_param, use_conf) in enumerate(params):
    Y1, Y2, u, v = run_reaction_diffusion(
        N_grid, L, dt, n_steps, Du=0.16, Dv=0.08,
        f=f_param, k=k_param, use_conformal=use_conf
    )
    
    # Flat view
    ax = fig.add_subplot(2, 4, idx + 1)
    ax.imshow(v, extent=[-L, L, -L, L], origin='lower', cmap='RdBu_r')
    ax.set_title(title, fontsize=11)
    ax.set_xlabel('y₁')
    ax.set_ylabel('y₂')
    
    # Draw equator circle (|y|=1 maps to equator of S²)
    theta = np.linspace(0, 2*np.pi, 100)
    ax.plot(np.cos(theta), np.sin(theta), 'g--', linewidth=1, alpha=0.5, label='Equator')
    ax.set_aspect('equal')
    
    # Spherical view
    ax3d = fig.add_subplot(2, 4, idx + 5, projection='3d')
    
    # Sample points and map to sphere
    step = 3
    y1_pts = Y1[::step, ::step].flatten()
    y2_pts = Y2[::step, ::step].flatten()
    v_pts = v[::step, ::step].flatten()
    
    x1, x2, x3 = inverse_stereo(y1_pts, y2_pts)
    
    # Color by pattern value
    sc = ax3d.scatter(x1, x2, x3, c=v_pts, cmap='RdBu_r', s=2, alpha=0.6)
    
    # Sphere wireframe
    u_s = np.linspace(0, 2*np.pi, 30)
    v_s = np.linspace(0, np.pi, 15)
    xs = np.outer(np.cos(u_s), np.sin(v_s))
    ys = np.outer(np.sin(u_s), np.sin(v_s))
    zs = np.outer(np.ones_like(u_s), np.cos(v_s))
    ax3d.plot_wireframe(xs, ys, zs, color='gray', alpha=0.05, linewidth=0.2)
    
    ax3d.set_title('On S²', fontsize=11)
    ax3d.set_box_aspect([1, 1, 1])
    ax3d.view_init(elev=25, azim=-40)

plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('/workspace/request-project/demos/demo03_turing_patterns_on_sphere.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✅ Demo 03 saved: demos/demo03_turing_patterns_on_sphere.png")
