#!/usr/bin/env python3
"""
Visualization: Finite-Size Scaling and Universality

Demonstrates the conjecture that certification scores exhibit finite-size
collapse when plotted against the rescaled variable p/p*(L). Multiple
system sizes L are shown, with the transition sharpening as L grows.
This is the many-body analog of Tracy-Widom edge scaling.
"""

import numpy as np
import matplotlib.pyplot as plt

def make_gapped_system(n, gap, seed):
    rng = np.random.default_rng(seed)
    eigenvalues = np.zeros(n)
    ground_dim = max(1, n // 4)
    eigenvalues[ground_dim:] = np.linspace(gap, gap + 2, n - ground_dim)
    Q, _ = np.linalg.qr(rng.standard_normal((n, n)))
    H = Q @ np.diag(eigenvalues) @ Q.T
    H = (H + H.T) / 2
    A = rng.standard_normal((n, n))
    N = (A + A.T) / 2
    N = N / np.linalg.norm(N, ord=2)
    return H, N, ground_dim

fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# Panel 1: Certification score curves for different system sizes
ax1 = axes[0, 0]
L_values = [4, 8, 16, 32]
colors_L = ['#3498db', '#2ecc71', '#e74c3c', '#9b59b6']
gap = 2.0

for L, color in zip(L_values, colors_L):
    n = L
    H, N, gd = make_gapped_system(n, gap, seed=L * 7)
    sigma = np.linalg.norm(N, ord=2)
    p_star = gap / (2 * sigma)

    p_values = np.linspace(0, 2 * p_star, 80)
    scores = []
    for p in p_values:
        H_p = H + p * N
        eigs = np.sort(np.linalg.eigvalsh(H_p))
        actual_gap = eigs[gd] - eigs[gd - 1]
        scores.append(max(actual_gap, 0))

    scores = np.array(scores)
    if scores[0] > 0:
        scores_norm = scores / scores[0]
    else:
        scores_norm = scores

    ax1.plot(p_values / p_star, scores_norm, color=color, linewidth=2,
             label=f'n = {L}')

ax1.axvline(x=1.0, color='orange', linewidth=2, linestyle=':', alpha=0.7)
ax1.set_xlabel('p / p*', fontsize=13)
ax1.set_ylabel('Normalized gap Φ(p) / Φ(0)', fontsize=13)
ax1.set_title('Certification Score Collapse', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11)
ax1.set_xlim(0, 2)
ax1.set_ylim(-0.1, 1.5)
ax1.grid(True, alpha=0.3)

# Panel 2: Certified gap heatmap
ax2 = axes[0, 1]
delta_range = np.linspace(0.5, 5, 100)
sigma_range = np.linspace(0.1, 3, 100)
D, S = np.meshgrid(delta_range, sigma_range)
P_star = D / (2 * S)

im = ax2.pcolormesh(D, S, P_star, cmap='viridis', shading='auto',
                     vmin=0, vmax=5)
plt.colorbar(im, ax=ax2, label='Threshold p* = Δ/(2σ)')
ax2.set_xlabel('Spectral gap Δ', fontsize=13)
ax2.set_ylabel('Noise scale σ', fontsize=13)
ax2.set_title('Certification Threshold Landscape', fontsize=14, fontweight='bold')

# Contour lines
contours = ax2.contour(D, S, P_star, levels=[0.5, 1.0, 2.0, 3.0],
                        colors='white', linewidths=1.5)
ax2.clabel(contours, fmt='p*=%.1f', fontsize=10, colors='white')

# Panel 3: Multiple noise ensembles (universality test)
ax3 = axes[1, 0]
n = 20
gap = 2.0
rng = np.random.default_rng(42)

noise_types = {
    'Gaussian': lambda: (lambda A: (A + A.T) / 2)(rng.standard_normal((n, n))),
    'Sparse': lambda: (lambda A: (A + A.T) / 2)(
        rng.standard_normal((n, n)) * (rng.random((n, n)) < 0.3)),
    'Diagonal': lambda: np.diag(rng.standard_normal(n)),
}

H, _, gd = make_gapped_system(n, gap, seed=999)

for (name, gen), color in zip(noise_types.items(),
                               ['#3498db', '#e74c3c', '#2ecc71']):
    N = gen()
    N = N / np.linalg.norm(N, ord=2)
    sigma = np.linalg.norm(N, ord=2)
    p_star = gap / (2 * sigma)

    p_values = np.linspace(0, 2 * p_star, 80)
    gaps_actual = []
    for p in p_values:
        H_p = H + p * N
        eigs = np.sort(np.linalg.eigvalsh(H_p))
        gaps_actual.append(eigs[gd] - eigs[gd - 1])

    ax3.plot(p_values / p_star, gaps_actual, color=color, linewidth=2,
             label=f'{name}', alpha=0.8)

certified = [gap - 2 * p * 1.0 for p in np.linspace(0, 2, 80)]
ax3.plot(np.linspace(0, 2, 80), certified, 'k--', linewidth=1.5,
         label='Certified bound', alpha=0.5)
ax3.axhline(y=0, color='black', linewidth=0.5)
ax3.axvline(x=1.0, color='orange', linewidth=2, linestyle=':', alpha=0.7)

ax3.set_xlabel('p / p*', fontsize=13)
ax3.set_ylabel('Spectral gap', fontsize=13)
ax3.set_title('Universality: Different Noise Ensembles', fontsize=14,
              fontweight='bold')
ax3.legend(fontsize=11)
ax3.set_xlim(0, 2)
ax3.grid(True, alpha=0.3)

# Panel 4: Transition width vs system size
ax4 = axes[1, 1]
sizes = [4, 6, 8, 12, 16, 24, 32, 48, 64]
widths = []

for n_size in sizes:
    H, N, gd = make_gapped_system(n_size, gap, seed=n_size * 13)
    sigma = np.linalg.norm(N, ord=2)
    p_star = gap / (2 * sigma)

    p_values = np.linspace(0.5 * p_star, 1.5 * p_star, 200)
    gaps_norm = []
    for p in p_values:
        H_p = H + p * N
        eigs = np.sort(np.linalg.eigvalsh(H_p))
        g = eigs[gd] - eigs[gd - 1]
        gaps_norm.append(g)

    gaps_norm = np.array(gaps_norm)
    # Estimate transition width as interval where gap goes from 80% to 20% of max
    max_gap = np.max(gaps_norm)
    if max_gap > 0:
        above_80 = np.where(gaps_norm > 0.8 * max_gap)[0]
        below_20 = np.where(gaps_norm < 0.2 * max_gap)[0]
        if len(above_80) > 0 and len(below_20) > 0:
            p_80 = p_values[above_80[-1]] / p_star
            p_20 = p_values[below_20[0]] / p_star
            widths.append(p_20 - p_80)
        else:
            widths.append(1.0)
    else:
        widths.append(1.0)

ax4.loglog(sizes, widths, 'bo-', linewidth=2, markersize=8, label='Measured width')

# Fit power law
log_sizes = np.log(sizes)
log_widths = np.log(widths)
coeffs = np.polyfit(log_sizes, log_widths, 1)
fit_line = np.exp(coeffs[1]) * np.array(sizes) ** coeffs[0]
ax4.loglog(sizes, fit_line, 'r--', linewidth=2,
           label=f'Fit: n^{{{coeffs[0]:.2f}}}')

# Reference n^{-2/3} line
ref_line = widths[0] * (np.array(sizes) / sizes[0]) ** (-2/3)
ax4.loglog(sizes, ref_line, 'g:', linewidth=1.5,
           label=r'Reference: $n^{-2/3}$', alpha=0.7)

ax4.set_xlabel('System size n', fontsize=13)
ax4.set_ylabel('Transition width', fontsize=13)
ax4.set_title('Finite-Size Scaling of Transition Width', fontsize=14,
              fontweight='bold')
ax4.legend(fontsize=11)
ax4.grid(True, alpha=0.3, which='both')

plt.tight_layout()
plt.savefig('viz_finite_size_scaling.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_finite_size_scaling.png")
