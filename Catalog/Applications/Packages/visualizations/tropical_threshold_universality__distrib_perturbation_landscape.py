"""
Visualization: Perturbation Landscape and Signal-Noise Boundary

This script visualizes the deterministic perturbation stability theorem:
    tropMargin(A + E) ≥ tropMargin(A) - 4‖E‖∞

It creates a heatmap showing tropMargin as a function of signal strength
and noise level, with the theoretical phase boundary overlaid.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def trop_margin(W):
    n = W.shape[0]
    if n < 2:
        return 0.0
    margin = float('inf')
    for i in range(n):
        for j in range(n):
            if i != j:
                s = 2.0 * W[i, j] - W[i, i] - W[j, j]
                if s < margin:
                    margin = s
    return margin


def mean_model(n, mu_diag, mu_off):
    M = np.full((n, n), mu_off)
    np.fill_diagonal(M, mu_diag)
    return M


# Parameters
n = 6
rng = np.random.default_rng(42)

signal_range = np.linspace(0, 8, 30)
noise_range = np.linspace(0, 4, 25)
num_trials = 50

# Compute empirical P(tropMargin ≥ 0) heatmap
prob_map = np.zeros((len(noise_range), len(signal_range)))
margin_map = np.zeros((len(noise_range), len(signal_range)))

for si, sig in enumerate(signal_range):
    for ni, noise_scale in enumerate(noise_range):
        count = 0
        total_margin = 0
        S = mean_model(n, 0.0, sig / 2.0)
        for _ in range(num_trials):
            N = noise_scale * rng.standard_normal((n, n))
            m = trop_margin(S + N)
            total_margin += m
            if m >= 0:
                count += 1
        prob_map[ni, si] = count / num_trials
        margin_map[ni, si] = total_margin / num_trials

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Panel 1: P(margin ≥ 0) heatmap
im1 = axes[0].imshow(prob_map, extent=[signal_range[0], signal_range[-1],
                                        noise_range[-1], noise_range[0]],
                      aspect='auto', cmap='RdYlGn', vmin=0, vmax=1)
# Theoretical boundary: signalGap = 4 * noise → signal = 4 * noise (for mean model)
# signalGap of mean model = 2*(mu_off - mu_diag) = 2*(sig/2) = sig
# So boundary: sig = 4 * noise_scale * expected_max
# For Gaussian n×n: E[‖N‖∞] ≈ noise_scale * √(2 log(n²))
expected_max_factor = np.sqrt(2 * np.log(n * n))
boundary_noise = signal_range / (4 * expected_max_factor)
axes[0].plot(signal_range, boundary_noise, 'w--', linewidth=2,
             label=f'Theoretical boundary\n(4·E[‖N‖∞] = signalGap)')
axes[0].set_xlabel('Signal strength (2·(μ_off − μ_diag))', fontsize=12)
axes[0].set_ylabel('Noise scale σ', fontsize=12)
axes[0].set_title('P(tropMargin ≥ 0)', fontsize=13, fontweight='bold')
axes[0].legend(fontsize=9, loc='upper left', facecolor='black', 
               labelcolor='white', framealpha=0.7)
plt.colorbar(im1, ax=axes[0], shrink=0.8)

# Panel 2: Average margin heatmap
im2 = axes[1].imshow(margin_map, extent=[signal_range[0], signal_range[-1],
                                          noise_range[-1], noise_range[0]],
                      aspect='auto', cmap='coolwarm', 
                      vmin=-np.max(np.abs(margin_map)), 
                      vmax=np.max(np.abs(margin_map)))
axes[1].contour(signal_range, noise_range, margin_map, levels=[0],
                colors='black', linewidths=2)
axes[1].set_xlabel('Signal strength', fontsize=12)
axes[1].set_ylabel('Noise scale σ', fontsize=12)
axes[1].set_title('E[tropMargin(S + σN)]', fontsize=13, fontweight='bold')
plt.colorbar(im2, ax=axes[1], shrink=0.8)

# Panel 3: Cross-section at fixed noise
noise_idx = len(noise_range) // 3  # moderate noise
axes[2].plot(signal_range, prob_map[noise_idx, :], 'b-o', 
             markersize=4, linewidth=2, label=f'σ = {noise_range[noise_idx]:.1f}')
noise_idx2 = 2 * len(noise_range) // 3  # high noise
axes[2].plot(signal_range, prob_map[noise_idx2, :], 'r-s',
             markersize=4, linewidth=2, label=f'σ = {noise_range[noise_idx2]:.1f}')
axes[2].set_xlabel('Signal strength', fontsize=12)
axes[2].set_ylabel('P(tropMargin ≥ 0)', fontsize=12)
axes[2].set_title('Phase Transition Curves', fontsize=13, fontweight='bold')
axes[2].legend(fontsize=11)
axes[2].grid(True, alpha=0.3)
axes[2].set_ylim(-0.05, 1.05)
axes[2].axhline(y=0.5, color='gray', linestyle='--', alpha=0.5)

plt.tight_layout()
plt.savefig('perturbation_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: perturbation_landscape.png")
