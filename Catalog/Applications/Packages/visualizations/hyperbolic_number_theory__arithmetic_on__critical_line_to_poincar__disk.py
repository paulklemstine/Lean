#!/usr/bin/env python3
"""
Visualization: Critical Line → Poincaré Disk Mapping

Shows how the Cayley-type transform s ↦ (s-1)/(s+1) maps the critical line
Re(s) = 1/2 into the Poincaré disk. This is the geometric content of
the theorem critical_line_to_disk: ‖(ρ-1)/(ρ+1)‖ ≤ 1 for Re(ρ) = 1/2.

The first 20 non-trivial zeros of the Riemann zeta function are mapped
to show that they all land inside the unit disk.
"""

import numpy as np
import matplotlib.pyplot as plt


# First 20 non-trivial zeros of ζ(s) (imaginary parts)
zeta_zeros = [
    14.134725, 21.022040, 25.010858, 30.424876, 32.935062,
    37.586178, 40.918719, 43.327073, 48.005151, 49.773832,
    52.970321, 56.446248, 59.347044, 60.831779, 65.112544,
    67.079811, 69.546402, 72.067158, 75.704691, 77.144840
]


def cayley_map(s: complex) -> complex:
    """Cayley-type transform: s ↦ (s-1)/(s+1)."""
    return (s - 1) / (s + 1)


fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left: Critical line in the s-plane
ax1 = axes[0]

# Draw critical strip
ax1.axvspan(0, 1, alpha=0.1, color='blue', label='Critical strip')
ax1.axvline(x=0.5, color='red', linewidth=2, label='Critical line Re(s)=1/2')

# Plot zeros
for t in zeta_zeros:
    ax1.plot(0.5, t, 'ko', markersize=6)
    ax1.plot(0.5, -t, 'ko', markersize=6)

# Annotations
ax1.set_xlabel('Re(s)', fontsize=12)
ax1.set_ylabel('Im(s)', fontsize=12)
ax1.set_title('Riemann Zeta Zeros\nin the s-plane', fontsize=13, fontweight='bold')
ax1.set_xlim(-1, 2)
ax1.set_ylim(-85, 85)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Right: Poincaré disk
ax2 = axes[1]

# Draw unit circle
theta = np.linspace(0, 2*np.pi, 200)
ax2.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)

# Draw the image of the critical line
t_range = np.linspace(-100, 100, 2000)
critical_line_image = [cayley_map(complex(0.5, t)) for t in t_range]
cl_x = [w.real for w in critical_line_image]
cl_y = [w.imag for w in critical_line_image]
ax2.plot(cl_x, cl_y, 'r-', linewidth=1.5, alpha=0.5, label='Image of critical line')

# Draw images of other vertical lines for context
for sigma in [0.0, 0.25, 0.75, 1.0]:
    line_image = [cayley_map(complex(sigma, t)) for t in t_range]
    lx = [w.real for w in line_image]
    ly = [w.imag for w in line_image]
    ax2.plot(lx, ly, 'b-', linewidth=0.5, alpha=0.3)

# Map zeta zeros to disk
zero_disk = []
for t in zeta_zeros:
    rho = complex(0.5, t)
    w = cayley_map(rho)
    zero_disk.append(w)
    ax2.plot(w.real, w.imag, 'ko', markersize=5)
    # Also plot conjugate
    w_conj = cayley_map(complex(0.5, -t))
    ax2.plot(w_conj.real, w_conj.imag, 'ko', markersize=5)

# Verify all are in disk
norms = [abs(w) for w in zero_disk]
max_norm = max(norms)

ax2.set_xlim(-1.15, 1.15)
ax2.set_ylim(-1.15, 1.15)
ax2.set_aspect('equal')
ax2.set_title('Zeta Zeros Mapped to\nPoincaré Disk via Cayley Transform',
              fontsize=13, fontweight='bold')
ax2.set_xlabel('Re(w)', fontsize=12)
ax2.set_ylabel('Im(w)', fontsize=12)
ax2.legend(fontsize=10, loc='upper right')

# Add text about the theorem
ax2.text(0.02, -1.08,
         f'All {len(zeta_zeros)} zeros inside disk (max |w| = {max_norm:.6f})',
         fontsize=10, style='italic', color='gray')

# Arrow connecting the two plots
fig.text(0.48, 0.5, '→', fontsize=30, ha='center', va='center',
         fontweight='bold', color='darkgreen')
fig.text(0.48, 0.44, '(s-1)/(s+1)', fontsize=10, ha='center', va='center',
         color='darkgreen', style='italic')

plt.tight_layout()
plt.savefig('viz_critical_line.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_critical_line.png")
