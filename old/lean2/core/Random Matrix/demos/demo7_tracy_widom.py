#!/usr/bin/env python3
"""
Demo 7: Tracy-Widom Distribution — The Edge of the Coulomb Gas
================================================================
Explores the fluctuations of the largest eigenvalue and how
repulsion shapes the edge statistics.

Run: python demo7_tracy_widom.py
Outputs: tracy_widom.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

np.random.seed(42)

def sample_largest_eigenvalue(ensemble, N, n_samples):
    """Sample the largest eigenvalue from the specified ensemble."""
    largest = np.zeros(n_samples)
    for k in range(n_samples):
        if ensemble == 'GOE':
            A = np.random.randn(N, N)
            H = (A + A.T) / np.sqrt(2)
        elif ensemble == 'GUE':
            A = (np.random.randn(N, N) + 1j * np.random.randn(N, N)) / np.sqrt(2)
            H = (A + A.conj().T) / np.sqrt(2)
        eigs = np.linalg.eigvalsh(H)
        largest[k] = np.max(eigs)
    return largest

def tracy_widom_scaling(largest_eigs, N):
    """
    Scale largest eigenvalue to Tracy-Widom variable:
    χ = (λ_max - 2√N) · N^{1/6}
    """
    return (largest_eigs - 2 * np.sqrt(N)) * N**(1.0/6)

# ─── Generate data ───
N_values = [10, 50, 100]
n_samples = 500

print("Sampling largest eigenvalues...")
data = {}
for ens in ['GOE', 'GUE']:
    for N in N_values:
        key = f'{ens}_N{N}'
        print(f"  {key}...")
        largest = sample_largest_eigenvalue(ens, N, n_samples)
        scaled = tracy_widom_scaling(largest, N)
        data[key] = scaled

# ─── Approximate Tracy-Widom PDF (using numerical simulation of large N) ───
# Use N=500 GUE as reference for TW₂
print("  Reference TW₂ (N=500 GUE)...")
tw2_ref = tracy_widom_scaling(sample_largest_eigenvalue('GUE', 100, 2000), 100)
print("  Reference TW₁ (N=100 GOE)...")
tw1_ref = tracy_widom_scaling(sample_largest_eigenvalue('GOE', 100, 2000), 100)

# ─── Figure ───
fig = plt.figure(figsize=(18, 14))
fig.suptitle("Tracy-Widom Distribution: Universal Fluctuations at the Edge\n"
             "How eigenvalue repulsion shapes the statistics of the largest eigenvalue",
             fontsize=15, fontweight='bold', y=0.98)

gs = GridSpec(3, 3, hspace=0.45, wspace=0.35)

# ═══ Row 1: Convergence of λ_max distribution ═══
for idx, N in enumerate(N_values):
    ax = fig.add_subplot(gs[0, idx])
    
    goe_data = data[f'GOE_N{N}']
    gue_data = data[f'GUE_N{N}']
    
    bins = np.linspace(-6, 4, 80)
    ax.hist(goe_data, bins=bins, density=True, alpha=0.5, color='#e74c3c',
            edgecolor='white', linewidth=0.3, label='GOE (β=1)')
    ax.hist(gue_data, bins=bins, density=True, alpha=0.5, color='#3498db',
            edgecolor='white', linewidth=0.3, label='GUE (β=2)')
    
    # Reference curves
    tw1_bins = np.linspace(-6, 4, 200)
    tw1_hist, tw1_edges = np.histogram(tw1_ref, bins=tw1_bins, density=True)
    tw1_centers = (tw1_edges[:-1] + tw1_edges[1:]) / 2
    tw2_hist, tw2_edges = np.histogram(tw2_ref, bins=tw1_bins, density=True)
    tw2_centers = (tw2_edges[:-1] + tw2_edges[1:]) / 2
    
    ax.plot(tw1_centers, tw1_hist, 'r-', linewidth=1.5, alpha=0.5)
    ax.plot(tw2_centers, tw2_hist, 'b-', linewidth=1.5, alpha=0.5)
    
    # Gaussian for comparison
    from scipy.stats import norm
    x_gauss = np.linspace(-6, 4, 200)
    gauss_std = np.std(gue_data)
    gauss_mean = np.mean(gue_data)
    ax.plot(x_gauss, norm.pdf(x_gauss, gauss_mean, gauss_std), 'k--',
            linewidth=1, alpha=0.3, label='Gaussian fit')
    
    ax.set_xlabel('χ = (λ_max − 2√N) · N^{1/6}', fontsize=9)
    ax.set_ylabel('Density', fontsize=10)
    ax.set_title(f'N = {N}', fontsize=12, fontweight='bold')
    ax.legend(fontsize=8)
    ax.set_xlim(-6, 4)

# ═══ Panel 4: Tracy-Widom vs Gaussian comparison ═══
ax4 = fig.add_subplot(gs[1, 0])
bins = np.linspace(-6, 4, 100)
tw2_hist, tw2_edges = np.histogram(tw2_ref, bins=bins, density=True)
tw2_centers = (tw2_edges[:-1] + tw2_edges[1:]) / 2

ax4.fill_between(tw2_centers, tw2_hist, alpha=0.4, color='#3498db', label='Tracy-Widom β=2')

# Gaussian with same mean and variance
mu_tw = np.mean(tw2_ref)
sig_tw = np.std(tw2_ref)
gauss = norm.pdf(tw2_centers, mu_tw, sig_tw)
ax4.plot(tw2_centers, gauss, 'k--', linewidth=2, label=f'Gaussian (μ={mu_tw:.2f}, σ={sig_tw:.2f})')

ax4.set_xlabel('χ', fontsize=10)
ax4.set_ylabel('Density', fontsize=10)
ax4.set_title('Tracy-Widom vs Gaussian\n(Note the asymmetric left tail)',
              fontsize=11, fontweight='bold')
ax4.legend(fontsize=9)
ax4.set_xlim(-6, 4)
ax4.annotate('Heavy left tail\n(repulsion pushes\nλ_max inward)', xy=(-3.5, 0.02),
             fontsize=9, color='red', fontweight='bold', ha='center')

# ═══ Panel 5: Log-scale comparison ═══
ax5 = fig.add_subplot(gs[1, 1])
ax5.semilogy(tw2_centers, np.maximum(tw2_hist, 1e-5), 'b-', linewidth=2,
             label='Tracy-Widom β=2')
ax5.semilogy(tw2_centers, np.maximum(gauss, 1e-5), 'k--', linewidth=2,
             label='Gaussian')
ax5.set_xlabel('χ', fontsize=10)
ax5.set_ylabel('log Density', fontsize=10)
ax5.set_title('Log-Scale: TW Has Heavier Left Tail\n'
              'Eigenvalue repulsion suppresses upward fluctuations',
              fontsize=11, fontweight='bold')
ax5.legend(fontsize=9)
ax5.set_xlim(-6, 4)
ax5.set_ylim(1e-4, 1)

# ═══ Panel 6: N-dependence of λ_max statistics ═══
ax6 = fig.add_subplot(gs[1, 2])
N_range = [5, 10, 20, 50, 100]
means = []
stds = []
skews = []
for N in N_range:
    largest = sample_largest_eigenvalue('GUE', N, 500)
    scaled = tracy_widom_scaling(largest, N)
    means.append(np.mean(scaled))
    stds.append(np.std(scaled))
    skews.append(float(np.mean(((scaled - np.mean(scaled))/np.std(scaled))**3)))

ax6_twin = ax6.twinx()
ax6.plot(N_range, means, 'bo-', linewidth=2, markersize=8, label='Mean')
ax6.plot(N_range, stds, 'rs-', linewidth=2, markersize=8, label='Std Dev')
ax6_twin.plot(N_range, skews, 'g^-', linewidth=2, markersize=8, label='Skewness')
ax6.set_xlabel('Matrix size N', fontsize=10)
ax6.set_ylabel('Mean / Std Dev', fontsize=10, color='blue')
ax6_twin.set_ylabel('Skewness', fontsize=10, color='green')
ax6.set_title('Convergence to Tracy-Widom\nas N → ∞',
              fontsize=11, fontweight='bold')
ax6.legend(loc='upper left', fontsize=9)
ax6_twin.legend(loc='upper right', fontsize=9)
ax6.set_xscale('log')

# ═══ Row 3: Eigenvalue cloud visualization ═══
ax7 = fig.add_subplot(gs[2, 0])
N_cloud = 100
n_cloud = 50
for k in range(n_cloud):
    A = (np.random.randn(N_cloud, N_cloud) + 1j * np.random.randn(N_cloud, N_cloud)) / np.sqrt(2)
    H = (A + A.conj().T) / np.sqrt(2)
    eigs = np.linalg.eigvalsh(H) / np.sqrt(N_cloud)
    ax7.scatter(eigs, np.full_like(eigs, k), s=1, c='#3498db', alpha=0.3)

# Mark the edge
ax7.axvline(x=2, color='red', linewidth=2, linestyle='--', label='Edge: λ = 2√N/√N = 2')
ax7.axvline(x=-2, color='red', linewidth=2, linestyle='--')
ax7.set_xlabel('Normalized eigenvalue λ/√N', fontsize=10)
ax7.set_ylabel('Sample #', fontsize=10)
ax7.set_title(f'Eigenvalue Cloud (N={N_cloud})\nEdge fluctuations → Tracy-Widom',
              fontsize=11, fontweight='bold')
ax7.legend(fontsize=9, loc='upper left')

# ═══ Panel 8: Edge zoom ═══
ax8 = fig.add_subplot(gs[2, 1])
for k in range(n_cloud):
    A = (np.random.randn(N_cloud, N_cloud) + 1j * np.random.randn(N_cloud, N_cloud)) / np.sqrt(2)
    H = (A + A.conj().T) / np.sqrt(2)
    eigs = np.linalg.eigvalsh(H) / np.sqrt(N_cloud)
    # Show only top 10 eigenvalues
    top_eigs = eigs[-10:]
    ax8.scatter(top_eigs, np.full_like(top_eigs, k), s=8, c='#e74c3c', alpha=0.5)

ax8.axvline(x=2, color='black', linewidth=2, linestyle='--', alpha=0.5)
ax8.set_xlabel('Normalized eigenvalue λ/√N', fontsize=10)
ax8.set_ylabel('Sample #', fontsize=10)
ax8.set_title('Edge Zoom: Largest Eigenvalues\nRepulsion visible at microscopic scale',
              fontsize=11, fontweight='bold')
ax8.set_xlim(1.4, 2.6)

# ═══ Panel 9: Applications ═══
ax9 = fig.add_subplot(gs[2, 2])
ax9.axis('off')
apps_text = (
    "TRACY-WIDOM UNIVERSALITY\n"
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
    "The Tracy-Widom distribution\n"
    "appears far beyond random matrices:\n\n"
    "• Longest increasing subsequence\n"
    "  of a random permutation\n\n"
    "• Growth of interfaces (KPZ)\n"
    "  in statistical mechanics\n\n"
    "• Directed polymers in\n"
    "  random environments\n\n"
    "• Bus arrival times in\n"
    "  Cuernavaca, Mexico (!)\n\n"
    "• Fluctuations of the\n"
    "  Amazon River water level\n\n"
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    "Tracy-Widom is to extreme values\n"
    "what the Gaussian is to sums:\n"
    "a universal limit law shaped by\n"
    "eigenvalue repulsion."
)
ax9.text(0.5, 0.5, apps_text, transform=ax9.transAxes,
         fontsize=9.5, ha='center', va='center',
         fontfamily='monospace',
         bbox=dict(boxstyle='round,pad=0.8', facecolor='#f5f0ff',
                   edgecolor='#9b59b6', linewidth=2, alpha=0.95))

fig.text(0.5, 0.01,
         "The largest eigenvalue fluctuates on scale N^{−2/3} around 2√N — "
         "this is the Tracy-Widom law (1994).\n"
         "Repulsion compresses the right tail: λ_max is unlikely to be large because "
         "other eigenvalues push it inward.",
         ha='center', fontsize=11, style='italic',
         bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow', alpha=0.9))

plt.savefig('tracy_widom.png', dpi=150, bbox_inches='tight')
print("Saved: tracy_widom.png")
plt.close()
