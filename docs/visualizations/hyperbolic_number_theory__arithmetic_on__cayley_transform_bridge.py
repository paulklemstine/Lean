"""
Visualization 3: The Cayley Transform Bridge
==============================================
Visualizes the cross-domain bridge between the Riemann zeta function's
critical line (Re(s) = 1/2) and the Poincaré disk via the Cayley transform.
Also shows the Hilbert-tropical connection.
"""

import numpy as np
import matplotlib.pyplot as plt


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Cayley transform mapping
ax = axes[0]
ax.set_title("Cayley Transform\n$w = (s-1)/(s+1)$", fontsize=13)

# Draw unit circle (target)
theta = np.linspace(0, 2 * np.pi, 200)
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2, alpha=0.3)
ax.fill(np.cos(theta), np.sin(theta), alpha=0.05, color='blue')

# Map critical line Re(s) = 1/2
y_vals = np.linspace(-10, 10, 500)
for sigma, color, label in [(0.5, '#E91E63', 'Re(s)=1/2 (critical)'),
                             (1.0, '#4CAF50', 'Re(s)=1'),
                             (0.0, '#2196F3', 'Re(s)=0')]:
    ws = [(complex(sigma, y) - 1) / (complex(sigma, y) + 1) for y in y_vals]
    ax.plot([w.real for w in ws], [w.imag for w in ws],
            '-', color=color, linewidth=2, label=label, alpha=0.8)

# Mark specific points
for y in [-2, -1, 0, 1, 2]:
    s = complex(0.5, y)
    w = (s - 1) / (s + 1)
    ax.plot(w.real, w.imag, 'ro', markersize=6)
    if abs(y) <= 2:
        ax.annotate(f'y={y}', (w.real, w.imag), textcoords="offset points",
                    xytext=(10, 5), fontsize=8)

ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.5)
ax.set_aspect('equal')
ax.legend(fontsize=9, loc='lower left')
ax.grid(True, alpha=0.2)
ax.set_xlabel('Re(w)')
ax.set_ylabel('Im(w)')

# Panel 2: Critical line image in disk
ax = axes[1]
ax.set_title("Critical Line Image\nin the Poincaré Disk", fontsize=13)

# Unit circle
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
ax.fill(np.cos(theta), np.sin(theta), alpha=0.05, color='blue')

# Map many points on the critical line
y_dense = np.linspace(-20, 20, 2000)
ws = [(complex(0.5, y) - 1) / (complex(0.5, y) + 1) for y in y_dense]
norms = [abs(w) for w in ws]

ax.plot([w.real for w in ws], [w.imag for w in ws],
        '-', color='#E91E63', linewidth=2, label='Critical line image')

# Show that all points have |w| ≤ 1
ax.text(0.3, -0.8, f"max |w| = {max(norms):.6f}",
        fontsize=11, color='#E91E63', fontweight='bold',
        bbox=dict(boxstyle='round,pad=0.3', facecolor='white', edgecolor='#E91E63'))

# The image is a circle centered at (-1/3, 0) with radius 2/3
circle_center = -1/3
circle_radius = 2/3
circle_theta = np.linspace(0, 2 * np.pi, 200)
ax.plot(circle_center + circle_radius * np.cos(circle_theta),
        circle_radius * np.sin(circle_theta),
        '--', color='orange', linewidth=1.5, alpha=0.7, label='Containing circle')

ax.set_xlim(-1.3, 1.3)
ax.set_ylim(-1.3, 1.3)
ax.set_aspect('equal')
ax.legend(fontsize=10)

# Panel 3: Hilbert-Tropical bridge
ax = axes[2]
ax.set_title("Hilbert ↔ Tropical Bridge\nLog coordinates linearize hyperbolic metric", fontsize=13)

# Plot the Hilbert metric on (0, ∞) vs tropical distance
x_vals = np.linspace(0.1, 5, 200)
ref = 1.0

# Hilbert metric in log coords = |log(x) - log(ref)| = |log(x)|
hilbert_dists = np.abs(np.log(x_vals) - np.log(ref))
# Tropical distance in log coords
log_x = np.log(x_vals)
log_ref = np.log(ref)
tropical_dists = np.abs(log_x - log_ref)

ax.plot(x_vals, hilbert_dists, '-', color='#2196F3', linewidth=3,
        label='Hilbert metric: |log(x/y)|')
ax.plot(x_vals, tropical_dists, '--', color='#E91E63', linewidth=2,
        label='Tropical distance: |log x − log y|')

# They're identical!
ax.fill_between(x_vals, hilbert_dists, tropical_dists, alpha=0.1, color='green')

ax.axvline(x=1, color='gray', linestyle=':', alpha=0.5, label='Reference point y=1')
ax.set_xlabel('x')
ax.set_ylabel('Distance from y=1')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_ylim(0, 4)

# Annotation
ax.annotate("Hilbert = Tropical\nin log coordinates!",
            xy=(3, 1.1), fontsize=12, color='#4CAF50',
            fontweight='bold', ha='center',
            bbox=dict(boxstyle='round,pad=0.4', facecolor='white',
                      edgecolor='#4CAF50', alpha=0.9))

plt.tight_layout()
plt.savefig('viz_cayley_bridge.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_cayley_bridge.png")
