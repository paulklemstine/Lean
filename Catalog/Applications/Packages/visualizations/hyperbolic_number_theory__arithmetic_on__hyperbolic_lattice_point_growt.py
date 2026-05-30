"""
Visualization 3: Hyperbolic Lattice Point Growth
==================================================

Tests the Hyperbolic Prime Number Theorem conjecture:
the number of lattice points with |z|² ≤ 1 - 1/R² grows
like C·R² for the PSL(2,Z) orbit on the Poincaré disk.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def normSq(z):
    return z.real**2 + z.imag**2


def cayley_transform(z):
    return (z - 1j) / (z + 1j)


def generate_psl2z_orbit(max_depth=8):
    visited = set()
    orbit = []
    
    def add_point(z_uhp):
        if z_uhp.imag <= 0:
            return
        w = cayley_transform(z_uhp)
        key = (round(w.real, 10), round(w.imag, 10))
        if key not in visited:
            visited.add(key)
            orbit.append(w)
    
    current = {1j}
    add_point(1j)
    
    for _ in range(max_depth):
        next_level = set()
        for z in current:
            if abs(z) > 1e-15:
                s_z = -1.0 / z
                if s_z.imag > 1e-10:
                    add_point(s_z)
                    next_level.add(s_z)
            t_z = z + 1
            if t_z.imag > 1e-10:
                add_point(t_z)
                next_level.add(t_z)
            ti_z = z - 1
            if ti_z.imag > 1e-10:
                add_point(ti_z)
                next_level.add(ti_z)
        current = next_level
    
    return orbit


# Generate orbit
print("Generating PSL(2,Z) orbit...")
orbit = generate_psl2z_orbit(max_depth=9)
print(f"Generated {len(orbit)} orbit points")

# Compute normSq for all points
norms = sorted([normSq(p) for p in orbit])

# Test growth: N(R) = #{points with normSq ≤ 1 - 1/R²}
R_values = np.linspace(1.5, 20, 100)
counts = []
for R in R_values:
    threshold = 1 - 1/R**2
    count = sum(1 for ns in norms if ns <= threshold)
    counts.append(count)

counts = np.array(counts)
R_sq = R_values**2

# Fit C for N(R) ≈ C·R²
# Use least squares on the last half of data
mid = len(R_values) // 2
C_fit = np.mean(counts[mid:] / R_sq[mid:])

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: N(R) vs R
axes[0].plot(R_values, counts, 'b-', linewidth=2, label='$N(R)$ (observed)')
axes[0].plot(R_values, C_fit * R_sq, 'r--', linewidth=1.5, 
             label=f'$C \\cdot R^2$ (C ≈ {C_fit:.3f})')
axes[0].set_xlabel('R', fontsize=12)
axes[0].set_ylabel('N(R)', fontsize=12)
axes[0].set_title('Lattice Point Count N(R)', fontsize=13)
axes[0].legend(fontsize=11)
axes[0].grid(True, alpha=0.3)

# Plot 2: N(R)/R² — should approach a constant
ratio = counts / R_sq
axes[1].plot(R_values, ratio, 'g-', linewidth=2)
axes[1].axhline(y=C_fit, color='r', linestyle='--', linewidth=1.5, 
                label=f'C ≈ {C_fit:.3f}')
# Theoretical value for PSL(2,Z): 3/π ≈ 0.955
theoretical_C = 3.0 / math.pi
axes[1].axhline(y=theoretical_C, color='orange', linestyle=':', linewidth=1.5,
                label=f'3/π ≈ {theoretical_C:.3f} (theoretical)')
axes[1].set_xlabel('R', fontsize=12)
axes[1].set_ylabel('N(R) / R²', fontsize=12)
axes[1].set_title('Growth Rate N(R)/R²', fontsize=13)
axes[1].legend(fontsize=11)
axes[1].grid(True, alpha=0.3)

# Plot 3: Log-log plot
log_R = np.log(R_values)
log_N = np.log(np.maximum(counts, 1))
axes[2].plot(log_R, log_N, 'b-', linewidth=2, label='log N(R) vs log R')
# Fit slope
valid = counts > 0
slope, intercept = np.polyfit(log_R[valid], log_N[valid], 1)
axes[2].plot(log_R, slope * log_R + intercept, 'r--', linewidth=1.5,
             label=f'Slope ≈ {slope:.2f} (expect 2)')
axes[2].set_xlabel('log R', fontsize=12)
axes[2].set_ylabel('log N(R)', fontsize=12)
axes[2].set_title(f'Log-Log Plot (slope ≈ {slope:.2f})', fontsize=13)
axes[2].legend(fontsize=11)
axes[2].grid(True, alpha=0.3)

plt.suptitle('Testing the Hyperbolic Prime Number Theorem Conjecture\n'
             'PSL(2,ℤ) orbit on the Poincaré disk',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_lattice_growth.png', dpi=150, bbox_inches='tight')
print(f"Saved lattice growth visualization")
print(f"Fitted C = {C_fit:.4f}, log-log slope = {slope:.3f}")
