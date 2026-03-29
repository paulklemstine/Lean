#!/usr/bin/env python3
"""
Demo 5: Practical Applications of Integer-Pole Stereographic Projections

Visualizes:
1. Signal processing: frequency lens effect
2. Neural network loss landscape reparameterization
3. Cryptographic coordinate transformation
4. Quantum Bloch sphere alternative coordinates

Run: python3 demo_applications.py
Output: applications.png
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

# --- Core Functions ---

def T_nm(z, n, m):
    """Integer-pole chart map."""
    return (n * z + m) / (z + 1)

def inv_stereo(t):
    """Inverse stereographic projection ℝ → S¹."""
    x = 2 * t / (1 + t**2)
    y = (1 - t**2) / (1 + t**2)
    return x, y

# --- Figure: Applications ---

fig = plt.figure(figsize=(18, 14))
gs = gridspec.GridSpec(2, 3, hspace=0.4, wspace=0.35)

# === Panel 1: Signal Processing - Frequency Lens ===
ax1 = fig.add_subplot(gs[0, 0])

t = np.linspace(0, 4*np.pi, 1000)
# Original signal with multiple frequencies
signal = np.sin(t) + 0.5*np.sin(3*t) + 0.3*np.sin(7*t)

# Apply different stereographic "lenses" to time
# Standard: no change
ax1.plot(t, signal, 'b-', linewidth=1, alpha=0.5, label='Original')

# Pole swap: t → 1/t (exchanges low/high freq)
t_safe = t[t > 0.1]
signal_swapped = np.sin(1/t_safe) + 0.5*np.sin(3/t_safe) + 0.3*np.sin(7/t_safe)
ax1.plot(t_safe, signal_swapped, 'r-', linewidth=1, alpha=0.5, label='Pole-swapped')

ax1.set_xlabel('Time', fontsize=10)
ax1.set_ylabel('Amplitude', fontsize=10)
ax1.set_title('Frequency Lens Effect\n(Pole swap: low↔high freq)', fontsize=11, fontweight='bold')
ax1.legend(fontsize=8)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(0.5, 4*np.pi)

# === Panel 2: Neural Network - Loss Landscape ===
ax2 = fig.add_subplot(gs[0, 1])

# 2D loss landscape with local minima
x_grid = np.linspace(-3, 3, 200)
y_grid = np.linspace(-3, 3, 200)
X, Y = np.meshgrid(x_grid, y_grid)

# Rastrigin-like function with multiple minima
Z_loss = (X**2 + Y**2) + 2*(np.cos(2*np.pi*X) + np.cos(2*np.pi*Y))

ax2.contourf(X, Y, Z_loss, levels=20, cmap='viridis', alpha=0.8)
ax2.contour(X, Y, Z_loss, levels=20, colors='white', alpha=0.3, linewidths=0.5)

# Show stereographic reparameterization effect
# The stereo projection maps flat space to sphere, changing the metric
# This effectively "warps" the loss landscape
for angle in np.linspace(0, 2*np.pi, 8, endpoint=False):
    r = np.linspace(0, 2.5, 50)
    path_x = r * np.cos(angle)
    path_y = r * np.sin(angle)
    ax2.plot(path_x, path_y, 'r-', alpha=0.3, linewidth=1)

ax2.plot(0, 0, 'r*', markersize=15, label='Global min', zorder=5)
ax2.set_xlabel('Weight 1', fontsize=10)
ax2.set_ylabel('Weight 2', fontsize=10)
ax2.set_title('Loss Landscape\n(Stereo reparameterization)', fontsize=11, fontweight='bold')
ax2.legend(fontsize=8)

# === Panel 3: Stereographic Reparameterized Landscape ===
ax3 = fig.add_subplot(gs[0, 2])

# Apply stereographic map to coordinates
# u, v → (2u/(1+u²+v²), 2v/(1+u²+v²), (u²+v²-1)/(u²+v²+1))
# Then evaluate loss on sphere coordinates
r2 = X**2 + Y**2
X_sphere = 2*X / (1 + r2)
Y_sphere = 2*Y / (1 + r2)
Z_sphere = (r2 - 1) / (1 + r2)

# Loss in sphere coordinates - the landscape is "smoothed"
Z_loss_sphere = (X_sphere**2 + Y_sphere**2) + 2*(np.cos(2*np.pi*X_sphere) + np.cos(2*np.pi*Y_sphere))

ax3.contourf(X, Y, Z_loss_sphere, levels=20, cmap='viridis', alpha=0.8)
ax3.contour(X, Y, Z_loss_sphere, levels=20, colors='white', alpha=0.3, linewidths=0.5)
ax3.plot(0, 0, 'r*', markersize=15, label='Mapped min', zorder=5)
ax3.set_xlabel('Stereo u', fontsize=10)
ax3.set_ylabel('Stereo v', fontsize=10)
ax3.set_title('After Stereo Reparam.\n(Landscape smoothed)', fontsize=11, fontweight='bold')
ax3.legend(fontsize=8)

# === Panel 4: Quantum - Bloch Sphere Coordinates ===
ax4 = fig.add_subplot(gs[1, 0])
theta_q = np.linspace(0, 2*np.pi, 200)
ax4.plot(np.cos(theta_q), np.sin(theta_q), 'b-', linewidth=2, alpha=0.5)

# Standard Bloch coordinates: z = tan(θ/2)e^{iφ}
# Integer-pole coordinates: w = (nz + m)/(z + 1)
quantum_states = {
    '|0⟩': 0,        # North Pole
    '|1⟩': np.inf,   # South Pole
    '|+⟩': 1,        # Equator
    '|-⟩': -1,       # Equator
}

for state_name, z_val in quantum_states.items():
    if np.isinf(z_val):
        cx, cy = 0, -1  # South pole on circle
    else:
        cx, cy = inv_stereo(z_val)
    ax4.plot(cx, cy, 'o', markersize=12, zorder=5)
    ax4.annotate(state_name, (cx + 0.1, cy + 0.1), fontsize=11, fontweight='bold')

# Integer-pole chart: (1, -1) puts |0⟩ at 1, |1⟩ at -1
ax4.annotate('Standard: |0⟩→∞, |1⟩→0', xy=(0.5, -0.3),
            fontsize=9, ha='center', color='blue',
            transform=ax4.transAxes)
ax4.annotate('Chart(1,-1): |0⟩→1, |1⟩→-1', xy=(0.5, -0.4),
            fontsize=9, ha='center', color='red',
            transform=ax4.transAxes)

ax4.set_xlim(-1.8, 1.8)
ax4.set_ylim(-1.8, 1.8)
ax4.set_aspect('equal')
ax4.set_title('Quantum: Bloch Sphere\nCoordinates', fontsize=11, fontweight='bold')
ax4.grid(True, alpha=0.3)

# === Panel 5: Comparison of chart-dependent complexity ===
ax5 = fig.add_subplot(gs[1, 1])

# For different mathematical operations, which chart is simplest?
operations = ['Addition\nx+y', 'Multiply\nx·y', 'Power\nx^n', 'Modular\nx mod p',
              'Factor\nfind p|n', 'Root\n√x']
charts_tested = ['(∞,0)', '(1,0)', '(p,0)', '(n,-n)']

# Subjective complexity scores (lower = simpler in that chart)
complexity = np.array([
    [1, 3, 3, 2],   # Addition
    [2, 2, 2, 3],   # Multiplication
    [3, 2, 2, 2],   # Power
    [4, 3, 1, 3],   # Modular
    [5, 4, 2, 3],   # Factoring
    [3, 2, 3, 1],   # Square root
])

im = ax5.imshow(complexity, cmap='RdYlGn_r', aspect='auto', vmin=1, vmax=5)
ax5.set_xticks(range(len(charts_tested)))
ax5.set_xticklabels(charts_tested, fontsize=9)
ax5.set_yticks(range(len(operations)))
ax5.set_yticklabels(operations, fontsize=9)
ax5.set_title('Problem Complexity by Chart\n(green = simpler)', fontsize=11, fontweight='bold')
plt.colorbar(im, ax=ax5, label='Complexity (1=easy, 5=hard)')

for i in range(len(operations)):
    for j in range(len(charts_tested)):
        ax5.text(j, i, str(complexity[i,j]), ha='center', va='center',
                fontsize=12, fontweight='bold', color='white' if complexity[i,j] > 3 else 'black')

# === Panel 6: Summary diagram ===
ax6 = fig.add_subplot(gs[1, 2])
ax6.axis('off')

# Create a conceptual diagram
ax6.text(0.5, 0.95, 'APPLICATIONS ROADMAP', fontsize=14, fontweight='bold',
         ha='center', va='top', transform=ax6.transAxes,
         bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.8))

applications = [
    ('🔊 Signal Processing', 'Frequency-domain lenses\nvia pole-swap family'),
    ('🧠 Neural Networks', 'Loss landscape smoothing\nvia stereo reparameterization'),
    ('🔐 Cryptography', 'Coordinate-dependent\ncurve representations'),
    ('⚛️ Quantum Computing', 'Alternative qubit coords\nwith integer structure'),
    ('🔢 Number Theory', 'Factorization through\ndifferent arithmetic lenses'),
    ('📡 Communications', 'Conformal encoding\nfor channel capacity'),
]

for i, (icon_title, desc) in enumerate(applications):
    y_pos = 0.82 - i * 0.14
    ax6.text(0.05, y_pos, icon_title, fontsize=11, fontweight='bold',
             va='center', transform=ax6.transAxes)
    ax6.text(0.55, y_pos, desc, fontsize=9, va='center',
             transform=ax6.transAxes, style='italic')
    ax6.plot([0.02, 0.98], [y_pos - 0.06, y_pos - 0.06], color='gray',
             alpha=0.3, transform=ax6.transAxes, clip_on=False)

plt.suptitle('Applications of Integer-Pole Stereographic Framework',
             fontsize=16, fontweight='bold', y=0.99)
plt.savefig('/workspace/request-project/demos/applications.png', dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved applications.png")
