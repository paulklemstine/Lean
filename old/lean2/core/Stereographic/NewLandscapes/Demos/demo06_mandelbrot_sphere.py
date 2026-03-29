#!/usr/bin/env python3
"""
Demo 06: The Mandelbrot Sphere — Fractals on S²

Maps the Mandelbrot and Julia sets onto S² via inverse stereographic projection.
On the sphere, the point at infinity becomes visible, and the fractal structure
wraps around into beautiful closed patterns.

Oracle Ϻ's Revelation: "On the sphere, the Mandelbrot set has no escape — 
    it is bounded by geometry itself."
"""
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.cm as cm

def inv_stereo(u, v):
    D = 1 + u**2 + v**2
    x = 2*u / D
    y = 2*v / D
    z = (D - 2) / D
    return x, y, z

def mandelbrot_escape(c, max_iter=100):
    z = 0
    for i in range(max_iter):
        if abs(z) > 2:
            return i + 1 - np.log(np.log(abs(z))) / np.log(2)
        z = z*z + c
    return max_iter

def julia_escape(z, c, max_iter=100):
    for i in range(max_iter):
        if abs(z) > 2:
            return i + 1 - np.log(np.log(abs(z)+1e-10)) / np.log(2)
        z = z*z + c
    return max_iter

fig = plt.figure(figsize=(20, 20))
fig.suptitle("The Mandelbrot Sphere: Fractals on S²\n"
             "Oracle Ϻ — \"On the sphere, the fractal has no escape\"",
             fontsize=16, fontweight='bold', y=0.98)

# --- Panel 1: Classical Mandelbrot in the plane ---
ax1 = fig.add_subplot(2, 2, 1)
res = 500
re = np.linspace(-2.5, 1.5, res)
im = np.linspace(-1.5, 1.5, res)
RE, IM = np.meshgrid(re, im)
C = RE + 1j * IM
escape = np.zeros_like(RE)
for i in range(res):
    for j in range(res):
        escape[i, j] = mandelbrot_escape(C[i, j], max_iter=80)

ax1.pcolormesh(RE, IM, escape, cmap='inferno', shading='auto')
ax1.set_title("Classical Mandelbrot Set\n(ℝ² plane)", fontsize=12)
ax1.set_xlabel('Re(c)')
ax1.set_ylabel('Im(c)')
ax1.set_aspect('equal')

# --- Panel 2: Mandelbrot on S² ---
ax2 = fig.add_subplot(2, 2, 2, projection='3d')

# Sample points on S² and compute Mandelbrot in stereographic coords
n_pts = 150
phi = np.linspace(0, 2*np.pi, n_pts*2)
theta = np.linspace(0.05, np.pi-0.05, n_pts)
PHI, THETA = np.meshgrid(phi, theta)

# Spherical to stereographic
# u + iv = tan(θ/2) * e^{iφ} (using south-pole convention)
r_stereo = np.tan(THETA / 2)
U_s = r_stereo * np.cos(PHI)
V_s = r_stereo * np.sin(PHI)
C_s = U_s + 1j * V_s

# Compute Mandelbrot escape
escape_sphere = np.zeros_like(U_s)
for i in range(escape_sphere.shape[0]):
    for j in range(escape_sphere.shape[1]):
        escape_sphere[i, j] = mandelbrot_escape(C_s[i, j], max_iter=60)

# Spherical coordinates to Cartesian
X_s = np.sin(THETA) * np.cos(PHI)
Y_s = np.sin(THETA) * np.sin(PHI)
Z_s = np.cos(THETA)

# Plot colored surface
norm = plt.Normalize(vmin=0, vmax=60)
colors = cm.inferno(norm(escape_sphere))
ax2.plot_surface(X_s, Y_s, Z_s, facecolors=colors, shade=False, alpha=0.9)
ax2.scatter([0], [0], [1], color='white', s=50, marker='*', label='∞ (N. Pole)')
ax2.scatter([0], [0], [-1], color='cyan', s=50, marker='o', label='0 (S. Pole)')

ax2.set_title("Mandelbrot Set on S²\n(Stereographic Sphere)", fontsize=12)
ax2.set_xlim([-1.1, 1.1]); ax2.set_ylim([-1.1, 1.1]); ax2.set_zlim([-1.1, 1.1])
ax2.legend(fontsize=8)
ax2.view_init(elev=20, azim=45)

# --- Panel 3: Julia set on S² (Douady Rabbit) ---
ax3 = fig.add_subplot(2, 2, 3, projection='3d')
c_julia = -0.12 + 0.74j

escape_julia = np.zeros_like(U_s)
for i in range(escape_julia.shape[0]):
    for j in range(escape_julia.shape[1]):
        escape_julia[i, j] = julia_escape(C_s[i, j], c_julia, max_iter=60)

colors_j = cm.magma(norm(escape_julia))
ax3.plot_surface(X_s, Y_s, Z_s, facecolors=colors_j, shade=False, alpha=0.9)
ax3.scatter([0], [0], [1], color='white', s=50, marker='*')
ax3.scatter([0], [0], [-1], color='cyan', s=50, marker='o')

ax3.set_title(f"Julia Set on S²\nc = {c_julia} (Douady Rabbit)", fontsize=12)
ax3.set_xlim([-1.1, 1.1]); ax3.set_ylim([-1.1, 1.1]); ax3.set_zlim([-1.1, 1.1])
ax3.view_init(elev=20, azim=-30)

# --- Panel 4: Julia c=0 (equator) and c=-1 (basilica) ---
ax4 = fig.add_subplot(2, 2, 4, projection='3d')
c_basilica = -1 + 0j

escape_bas = np.zeros_like(U_s)
for i in range(escape_bas.shape[0]):
    for j in range(escape_bas.shape[1]):
        escape_bas[i, j] = julia_escape(C_s[i, j], c_basilica, max_iter=60)

colors_b = cm.twilight(norm(escape_bas))
ax4.plot_surface(X_s, Y_s, Z_s, facecolors=colors_b, shade=False, alpha=0.9)

# Draw equator (Julia set of z² is |z|=1)
eq_t = np.linspace(0, 2*np.pi, 200)
ax4.plot(np.cos(eq_t), np.sin(eq_t), np.zeros_like(eq_t),
         'r-', linewidth=2, label='Equator = J(z²)')
ax4.scatter([0], [0], [1], color='white', s=50, marker='*')
ax4.scatter([0], [0], [-1], color='cyan', s=50, marker='o')

ax4.set_title("Julia Set on S²\nc = -1 (Basilica)", fontsize=12)
ax4.set_xlim([-1.1, 1.1]); ax4.set_ylim([-1.1, 1.1]); ax4.set_zlim([-1.1, 1.1])
ax4.legend(fontsize=8)
ax4.view_init(elev=30, azim=60)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('/workspace/request-project/Stereographic/NewLandscapes/Demos/demo06_mandelbrot_sphere.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✅ Demo 06: Mandelbrot Sphere saved.")
