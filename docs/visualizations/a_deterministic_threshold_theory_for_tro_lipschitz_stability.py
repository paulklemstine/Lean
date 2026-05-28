"""
Visualization 3: Lipschitz Stability of the Tropical Margin

Demonstrates the Lipschitz bound |tropMargin(W) - tropMargin(W')| ≤ 4·‖W-W'‖∞
by generating random perturbations and plotting actual margin differences
vs the 4·‖perturbation‖∞ bound. All points should lie below the diagonal,
confirming the formally verified Lipschitz constant of 4.

Also shows the signal/noise decomposition theorem: the margin of the
perturbed matrix is bounded below by signal minus 4·noise.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def trop_margin(W):
    n = W.shape[0]
    min_val = float('inf')
    for i in range(n):
        for j in range(n):
            if i != j:
                val = 2 * W[i, j] - W[i, i] - W[j, j]
                if val < min_val:
                    min_val = val
    return min_val


def entry_sup_norm(W):
    return float(np.max(np.abs(W)))


def mean_model(n, mu_diag, mu_off):
    M = np.full((n, n), mu_off, dtype=float)
    np.fill_diagonal(M, mu_diag)
    return M


rng = np.random.default_rng(42)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# ── Left: Lipschitz bound verification ──

n = 8
num_trials = 300
perturbation_norms = []
margin_diffs = []
bounds = []

W_base = rng.normal(0, 1, (n, n))
W_base = (W_base + W_base.T) / 2
margin_base = trop_margin(W_base)

for _ in range(num_trials):
    scale = rng.uniform(0, 2)
    delta = rng.normal(0, scale, (n, n))
    delta = (delta + delta.T) / 2

    W_pert = W_base + delta
    margin_pert = trop_margin(W_pert)

    pert_norm = entry_sup_norm(delta)
    margin_diff = abs(margin_base - margin_pert)

    perturbation_norms.append(pert_norm)
    margin_diffs.append(margin_diff)
    bounds.append(4 * pert_norm)

ax1.scatter(perturbation_norms, margin_diffs, s=8, alpha=0.5,
            color='#1976D2', label='Actual |Δ margin|')
max_x = max(perturbation_norms) * 1.05
ax1.plot([0, max_x], [0, 4 * max_x], 'r-', linewidth=2,
         label='4·‖ΔW‖∞ bound', alpha=0.8)
ax1.set_xlabel('‖W − W\'‖∞', fontsize=13)
ax1.set_ylabel('|tropMargin(W) − tropMargin(W\')|', fontsize=13)
ax1.set_title('Lipschitz Bound Verification\n(All points below red line)', fontsize=13)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.25)

# ── Right: Signal/noise decomposition ──

n = 10
mu_off_vals = [2.0, 3.0, 4.0]
noise_scales = np.linspace(0, 3, 25)

for mu_off in mu_off_vals:
    signal = 2 * mu_off  # tropMargin of meanModel(n, 0, mu_off)
    actual_margins = []
    certified_lbs = []

    for sigma in noise_scales:
        margins_sample = []
        for _ in range(200):
            noise = rng.normal(0, sigma, (n, n))
            noise = (noise + noise.T) / np.sqrt(2)
            W = mean_model(n, 0, mu_off) + noise
            margins_sample.append(trop_margin(W))

        actual_margins.append(np.mean(margins_sample))
        # Certified: signal - 4 * expected_noise_supnorm
        # E[sup_norm] ≈ sigma * sqrt(2 * log(n^2))
        expected_noise = sigma * np.sqrt(2 * np.log(n * n + 1))
        certified_lbs.append(signal - 4 * expected_noise)

    ax2.plot(noise_scales, actual_margins, '-', linewidth=2,
             label=f'MC mean (μ_off={mu_off})')
    ax2.plot(noise_scales, certified_lbs, '--', linewidth=1.5, alpha=0.7,
             label=f'Certified (μ_off={mu_off})')

ax2.axhline(y=0, color='black', linestyle=':', alpha=0.5)
ax2.set_xlabel('Noise scale σ', fontsize=13)
ax2.set_ylabel('tropMargin', fontsize=13)
ax2.set_title('Signal/Noise Decomposition\n(Solid: MC, Dashed: Certified lower bound)', fontsize=13)
ax2.legend(fontsize=9, ncol=2)
ax2.grid(True, alpha=0.25)

plt.tight_layout()
plt.savefig('viz_lipschitz_stability.png', dpi=150, bbox_inches='tight')
print("Saved: viz_lipschitz_stability.png")
