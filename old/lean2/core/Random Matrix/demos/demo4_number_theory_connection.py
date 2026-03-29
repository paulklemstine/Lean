#!/usr/bin/env python3
"""
Demo 4: The Montgomery-Odlyzko Law — Riemann Zeros Meet Random Matrices
=========================================================================
Demonstrates the astonishing connection between the zeros of the Riemann
zeta function and GUE eigenvalue statistics.

Run: python demo4_number_theory_connection.py
Outputs: number_theory_connection.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

np.random.seed(42)

# ─── GUE pair correlation function ───
def gue_pair_correlation(r):
    """
    R₂(r) = 1 - (sin(πr)/(πr))²
    The pair correlation function of GUE eigenvalues (sine kernel).
    """
    with np.errstate(divide='ignore', invalid='ignore'):
        sinc = np.where(np.abs(r) < 1e-12, 1.0, np.sin(np.pi * r) / (np.pi * r))
    return 1 - sinc**2

def gue_number_variance(L):
    """
    Σ²(L) = (2/π²)(log(2πL) + γ + 1) + O(1/L)
    Number variance for GUE (how many eigenvalues in an interval of length L).
    """
    gamma_euler = 0.5772156649
    return (2/np.pi**2) * (np.log(2*np.pi*L) + gamma_euler + 1)

# ─── Simulate GUE eigenvalues ───
def gue_pair_correlation_numerical(N, n_samples):
    """Compute pair correlation from GUE simulations."""
    all_spacings = []
    for _ in range(n_samples):
        A = (np.random.randn(N, N) + 1j * np.random.randn(N, N)) / np.sqrt(2)
        H = (A + A.conj().T) / np.sqrt(2)
        eigs = np.linalg.eigvalsh(H)
        # Unfold: use bulk eigenvalues
        n = len(eigs)
        bulk = eigs[n//4:3*n//4]
        # Local unfolding
        mean_spacing = np.mean(np.diff(bulk))
        if mean_spacing > 0:
            unfolded = bulk / mean_spacing
            for i in range(len(unfolded)):
                for j in range(i+1, min(i+10, len(unfolded))):
                    all_spacings.append(abs(unfolded[j] - unfolded[i]))
    return np.array(all_spacings)

# ─── Simulate Poisson (independent) spacings ───
def poisson_pair_correlation_numerical(n_points, n_samples):
    """Pair correlation for uniform random points (should be flat = 1)."""
    all_spacings = []
    for _ in range(n_samples):
        points = np.sort(np.random.uniform(0, n_points, n_points))
        for i in range(len(points)):
            for j in range(i+1, min(i+10, len(points))):
                all_spacings.append(abs(points[j] - points[i]))
    return np.array(all_spacings)

print("Computing GUE pair correlations...")
gue_spacings = gue_pair_correlation_numerical(100, 300)

print("Computing Poisson pair correlations...")
poisson_spacings = poisson_pair_correlation_numerical(100, 300)

# ─── Known Riemann zeta zeros (imaginary parts of first zeros) ───
# First 100 nontrivial zeros (imaginary parts), well-known values
riemann_zeros = np.array([
    14.134725, 21.022040, 25.010858, 30.424876, 32.935062,
    37.586178, 40.918719, 43.327073, 48.005151, 49.773832,
    52.970321, 56.446248, 59.347044, 60.831779, 65.112544,
    67.079811, 69.546402, 72.067158, 75.704691, 77.144840,
    79.337375, 82.910381, 84.735493, 87.425275, 88.809111,
    92.491899, 94.651344, 95.870634, 98.831194, 101.317851,
    103.725538, 105.446623, 107.168611, 111.029535, 111.874659,
    114.320220, 116.226680, 118.790783, 121.370125, 122.946829,
    124.256819, 127.516684, 129.578704, 131.087688, 133.497737,
    134.756510, 138.116042, 139.736209, 141.123707, 143.111846,
    146.000982, 147.422765, 150.053520, 150.925258, 153.024693,
    156.112909, 157.597592, 158.849988, 161.188964, 163.030709,
    165.537069, 167.184439, 169.094515, 169.911977, 173.411536,
    174.754191, 176.441434, 178.377407, 179.916484, 182.207078,
    184.874467, 185.598783, 187.228922, 189.416158, 192.026656,
    193.079727, 195.265396, 196.876482, 198.015310, 201.264751,
    202.493595, 204.189671, 205.394697, 207.906259, 209.576509,
    211.690862, 213.347919, 214.547044, 216.169538, 219.067596,
    220.714919, 221.430705, 224.007000, 224.983324, 227.421444,
    229.337413, 231.250189, 231.987235, 233.693404, 236.524230,
])

# Unfold the Riemann zeros
n_rz = len(riemann_zeros)
# Mean spacing ~ 2π/log(T/(2π)) for zeros near height T
# Simple unfolding: normalize spacings
rz_spacings = np.diff(riemann_zeros)
rz_mean_spacing = np.mean(rz_spacings)
rz_unfolded_spacings = rz_spacings / rz_mean_spacing

# ─── Wigner surmise for GUE ───
s = np.linspace(0, 4, 500)
wigner_gue = (32 * s**2 / np.pi**2) * np.exp(-4 * s**2 / np.pi)

# ─── Figure ───
fig = plt.figure(figsize=(18, 14))
fig.suptitle("The Montgomery-Odlyzko Law: Riemann Zeros ↔ Random Matrices\n"
             "\"The prime eigenvalues of the universe repel like GUE eigenvalues\"",
             fontsize=15, fontweight='bold', y=0.98)

gs = GridSpec(3, 3, hspace=0.45, wspace=0.35)

# Panel 1: Riemann zeros on the critical line
ax1 = fig.add_subplot(gs[0, 0])
ax1.scatter(np.zeros(50), riemann_zeros[:50], s=15, c='#e74c3c',
            edgecolors='black', linewidth=0.3, zorder=3)
ax1.set_xlim(-0.5, 0.5)
ax1.set_ylabel('Im(s)', fontsize=10)
ax1.set_title('Riemann Zeta Zeros\non the Critical Line Re(s)=½',
              fontsize=11, fontweight='bold')
ax1.set_xticks([0])
ax1.set_xticklabels(['Re(s) = ½'])
for y in riemann_zeros[:50]:
    ax1.plot([-0.15, 0.15], [y, y], color='#e74c3c', alpha=0.3, linewidth=1)

# Panel 2: Spacing distribution of Riemann zeros
ax2 = fig.add_subplot(gs[0, 1])
ax2.hist(rz_unfolded_spacings, bins=15, density=True, alpha=0.6,
         color='#e74c3c', edgecolor='white', linewidth=0.5,
         label='Riemann zeros (first 100)')
ax2.plot(s, wigner_gue, 'k-', linewidth=2.5, label='GUE Wigner surmise')
ax2.plot(s, np.exp(-s), '--', color='gray', linewidth=1.5, label='Poisson (independent)')
ax2.set_xlabel('Normalized spacing s', fontsize=10)
ax2.set_ylabel('P(s)', fontsize=10)
ax2.set_title('Spacing Distribution:\nZeta Zeros vs GUE Prediction',
              fontsize=11, fontweight='bold')
ax2.legend(fontsize=9)
ax2.set_xlim(0, 4)

# Panel 3: Pair correlation comparison
ax3 = fig.add_subplot(gs[0, 2])
r_theory = np.linspace(0.01, 3, 300)
ax3.plot(r_theory, gue_pair_correlation(r_theory), 'k-', linewidth=2.5,
         label='GUE: 1 − (sin πr / πr)²')
ax3.axhline(y=1, color='gray', linestyle='--', linewidth=1, label='Poisson: R₂ = 1')

# Numerical pair correlation from GUE
r_bins = np.linspace(0, 3, 40)
r_centers = (r_bins[:-1] + r_bins[1:]) / 2
gue_hist, _ = np.histogram(gue_spacings, bins=r_bins, density=True)
# Normalize to pair correlation
gue_pc = gue_hist * r_bins[-1] / len(r_bins)
# Simple rescaling for visualization
gue_pc = gue_hist / (gue_hist[-1] if gue_hist[-1] > 0 else 1)
ax3.bar(r_centers, gue_pc, width=r_bins[1]-r_bins[0], alpha=0.3,
        color='#3498db', label='GUE simulation')

ax3.set_xlabel('Normalized separation r', fontsize=10)
ax3.set_ylabel('Pair correlation R₂(r)', fontsize=10)
ax3.set_title('Pair Correlation Function\nThe "hole" at r=0 IS repulsion',
              fontsize=11, fontweight='bold')
ax3.legend(fontsize=9)
ax3.set_xlim(0, 3)
ax3.set_ylim(0, 1.5)
ax3.annotate('Correlation\nhole', xy=(0.3, 0.1), fontsize=10, color='red',
             fontweight='bold', ha='center')

# Panel 4: GUE eigenvalue scatter
ax4 = fig.add_subplot(gs[1, 0])
N_viz = 50
n_matrices = 30
for k in range(n_matrices):
    A = (np.random.randn(N_viz, N_viz) + 1j * np.random.randn(N_viz, N_viz)) / np.sqrt(2)
    H = (A + A.conj().T) / np.sqrt(2)
    eigs = np.linalg.eigvalsh(H)
    ax4.scatter(eigs, np.full_like(eigs, k), s=3, c='#3498db', alpha=0.5)
ax4.set_xlabel('Eigenvalue λ', fontsize=10)
ax4.set_ylabel('Matrix sample #', fontsize=10)
ax4.set_title(f'GUE Eigenvalues (N={N_viz})\nNote the regular spacing!',
              fontsize=11, fontweight='bold')

# Panel 5: Poisson eigenvalue scatter (for contrast)
ax5 = fig.add_subplot(gs[1, 1])
for k in range(n_matrices):
    points = np.sort(np.random.uniform(-2*np.sqrt(N_viz), 2*np.sqrt(N_viz), N_viz))
    ax5.scatter(points, np.full_like(points, k), s=3, c='gray', alpha=0.5)
ax5.set_xlabel('Position', fontsize=10)
ax5.set_ylabel('Sample #', fontsize=10)
ax5.set_title(f'Independent Random Points (N={N_viz})\nNote the clustering!',
              fontsize=11, fontweight='bold')

# Panel 6: Number variance
ax6 = fig.add_subplot(gs[1, 2])
L_range = np.linspace(0.1, 10, 200)
ax6.plot(L_range, gue_number_variance(L_range), 'b-', linewidth=2.5,
         label='GUE: Σ² ~ (2/π²) log L')
ax6.plot(L_range, L_range, 'r--', linewidth=2, label='Poisson: Σ² = L')
ax6.set_xlabel('Interval length L (in units of mean spacing)', fontsize=10)
ax6.set_ylabel('Number variance Σ²(L)', fontsize=10)
ax6.set_title('Number Variance:\nHow "rigid" is the eigenvalue sequence?',
              fontsize=11, fontweight='bold')
ax6.legend(fontsize=10)
ax6.set_xlim(0, 10)
ax6.set_ylim(0, 10)
ax6.fill_between(L_range, gue_number_variance(L_range), L_range,
                 alpha=0.1, color='blue')
ax6.text(6, 7, 'Gap = rigidity\ndue to repulsion',
         fontsize=10, color='blue', fontweight='bold',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# Panel 7: The deep connections web
ax7 = fig.add_subplot(gs[2, :])
ax7.axis('off')

connections = {
    'Random\nMatrices': (0.5, 0.75),
    'Riemann\nZeta Zeros': (0.15, 0.45),
    'Quantum\nChaos': (0.85, 0.45),
    'Free\nProbability': (0.15, 0.1),
    'Integrable\nSystems': (0.85, 0.1),
    'Coulomb\nGas': (0.5, 0.1),
}

# Draw nodes
for name, (x, y) in connections.items():
    color = '#3498db' if name == 'Random\nMatrices' else '#e74c3c' if name == 'Coulomb\nGas' else '#2ecc71'
    ax7.add_patch(plt.Circle((x, y), 0.08, transform=ax7.transAxes,
                              facecolor=color, alpha=0.2, edgecolor=color, linewidth=2))
    ax7.text(x, y, name, transform=ax7.transAxes, ha='center', va='center',
             fontsize=10, fontweight='bold')

# Draw edges
edges = [
    ('Random\nMatrices', 'Riemann\nZeta Zeros', 'Montgomery-\nOdlyzko'),
    ('Random\nMatrices', 'Quantum\nChaos', 'BGS\nconjecture'),
    ('Random\nMatrices', 'Coulomb\nGas', 'Vandermonde\n= Boltzmann'),
    ('Coulomb\nGas', 'Free\nProbability', 'Semicircle\nlaw'),
    ('Coulomb\nGas', 'Integrable\nSystems', 'Calogero-\nMoser'),
    ('Riemann\nZeta Zeros', 'Free\nProbability', 'L-functions'),
    ('Quantum\nChaos', 'Integrable\nSystems', 'Spectral\nstatistics'),
]

for n1, n2, label in edges:
    x1, y1 = connections[n1]
    x2, y2 = connections[n2]
    ax7.annotate('', xy=(x2, y2), xytext=(x1, y1),
                 xycoords='axes fraction', textcoords='axes fraction',
                 arrowprops=dict(arrowstyle='-', color='gray', linewidth=1.5, alpha=0.5))
    ax7.text((x1+x2)/2, (y1+y2)/2, label, transform=ax7.transAxes,
             ha='center', va='center', fontsize=7, color='gray', style='italic',
             bbox=dict(boxstyle='round,pad=0.2', facecolor='white', alpha=0.8))

ax7.set_title('The Web of Connections: How Eigenvalue Repulsion Unifies Mathematics',
              fontsize=13, fontweight='bold', pad=10)

fig.text(0.5, 0.01,
         "Montgomery (1973): \"The pair correlation of zeta zeros matches GUE.\"\n"
         "Odlyzko (1987): Numerical confirmation with 10⁸ zeros. The prime numbers know about random matrices.",
         ha='center', fontsize=11, style='italic',
         bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow', alpha=0.9))

plt.savefig('number_theory_connection.png', dpi=150, bbox_inches='tight')
print("Saved: number_theory_connection.png")
plt.close()
