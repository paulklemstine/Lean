"""
Visualization 2: Hyperbolic Counting Function and Density
==========================================================
Visualizes how orbit points distribute in the Poincaré disk
and the growth of the counting function N(r).
"""

import numpy as np
import matplotlib.pyplot as plt


def mobius_map(a, theta, z):
    """Möbius disk automorphism."""
    phase = np.exp(1j * theta)
    return phase * (z - a) / (1 - np.conj(a) * z)


def generate_orbit(a, theta, n):
    """Generate orbit points."""
    pts = [0j]
    for _ in range(n - 1):
        pts.append(mobius_map(a, theta, pts[-1]))
    return np.array(pts)


def counting_function(points, r_values):
    """Compute counting function for array of radii."""
    norms = np.abs(points)
    return np.array([np.sum(norms <= r) for r in r_values])


fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# Generate orbit data for different generators
configs = [
    (0.5 + 0j, np.pi / 3, 'a=0.5, θ=π/3'),
    (0.3 + 0.3j, np.pi / 4, 'a=0.3+0.3i, θ=π/4'),
    (0.7 + 0j, np.pi / 7, 'a=0.7, θ=π/7'),
    (0.2 + 0.1j, np.pi / 2, 'a=0.2+0.1i, θ=π/2'),
]

# Panel 1: Radial distribution histograms
ax = axes[0, 0]
for a, theta, label in configs:
    orbit = generate_orbit(a, theta, 500)
    norms = np.abs(orbit)
    ax.hist(norms, bins=30, alpha=0.4, label=label, density=True)
ax.set_xlabel('|z| (Euclidean distance from origin)', fontsize=11)
ax.set_ylabel('Density', fontsize=11)
ax.set_title('Radial Distribution of Orbit Points', fontsize=12)
ax.legend(fontsize=9)
ax.set_xlim(0, 1)
ax.grid(True, alpha=0.3)

# Panel 2: Counting functions N(r)
ax = axes[0, 1]
r_vals = np.linspace(0, 0.999, 200)
for a, theta, label in configs:
    orbit = generate_orbit(a, theta, 500)
    N_r = counting_function(orbit, r_vals)
    ax.plot(r_vals, N_r, linewidth=2, label=label)

# Add theoretical bound N ≤ total
ax.axhline(y=500, color='gray', linestyle='--', alpha=0.5, label='N=500 (total)')
ax.set_xlabel('Radius r', fontsize=11)
ax.set_ylabel('N(r) = #{orbit points with |z| ≤ r}', fontsize=11)
ax.set_title('Counting Function N(r)', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 3: Log-scale counting vs 1/(1-r)²
ax = axes[1, 0]
r_vals_log = np.linspace(0.1, 0.99, 100)
for a, theta, label in configs[:2]:
    orbit = generate_orbit(a, theta, 1000)
    N_r = counting_function(orbit, r_vals_log)
    one_minus_r_inv_sq = 1 / (1 - r_vals_log) ** 2
    ax.plot(one_minus_r_inv_sq, N_r, linewidth=2, label=label)

# Reference line y = x (the conjecture bound)
x_ref = np.logspace(0, 3, 100)
ax.plot(x_ref, x_ref, 'k--', alpha=0.5, label='N(r) = 1/(1-r)²')
ax.set_xlabel('1/(1-r)²', fontsize=11)
ax.set_ylabel('N(r)', fontsize=11)
ax.set_title('Counting vs. Conjectured Bound', fontsize=12)
ax.set_xscale('log')
ax.set_yscale('log')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 4: Hyperbolic distance proxy distribution
ax = axes[1, 1]
a, theta = 0.5 + 0j, np.pi / 3
orbit = generate_orbit(a, theta, 500)
norms = np.abs(orbit)
hyp_dists = norms ** 2 / (1 - norms ** 2 + 1e-15)
hyp_dists_finite = hyp_dists[hyp_dists < 100]

ax.hist(hyp_dists_finite, bins=40, color='coral', alpha=0.7, edgecolor='darkred')
ax.set_xlabel('Hyperbolic distance proxy |z|²/(1-|z|²)', fontsize=11)
ax.set_ylabel('Count', fontsize=11)
ax.set_title('Hyperbolic Distance Distribution\n(a=0.5, θ=π/3)', fontsize=12)
ax.grid(True, alpha=0.3)

plt.suptitle('Hyperbolic Counting Function Analysis',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('counting_function_analysis.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: counting_function_analysis.png")
