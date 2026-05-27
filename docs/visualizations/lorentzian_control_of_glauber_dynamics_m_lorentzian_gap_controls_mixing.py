#!/usr/bin/env python3
"""
Visualization: Lorentzian Gap Controls Mixing Time

This script visualizes the core mathematical relationship:
Lorentzian curvature of the coupling matrix controls the mixing
time of Glauber dynamics. Three panels show:
1. The Lorentzian gap spectrum for different coupling strengths
2. Mixing time vs n·log(n)/ε scaling
3. Perturbation stability of the gap
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def compute_gap(J):
    eigenvalues = np.linalg.eigvalsh(J)
    sorted_eigs = np.sort(eigenvalues)[::-1]
    return abs(sorted_eigs[1]) if len(sorted_eigs) > 1 else 0


def estimate_mixing(J, h, beta=1.0, n_runs=8, max_steps=1500):
    n = len(h)
    autocorr_times = []
    for _ in range(n_runs):
        config = np.random.randint(2, size=n)
        mags = []
        for t in range(max_steps):
            site = np.random.randint(n)
            spins = 2 * config.astype(float) - 1
            local_field = beta * (J[site] @ spins - J[site, site] * spins[site] + h[site])
            prob_plus = 1.0 / (1.0 + np.exp(-2 * local_field))
            config[site] = int(np.random.random() < prob_plus)
            mags.append(np.mean(2 * config.astype(float) - 1))
        
        mags = np.array(mags[max_steps//4:])
        centered = mags - np.mean(mags)
        var = np.var(centered)
        if var < 1e-12:
            autocorr_times.append(1)
            continue
        tau = 1
        for lag in range(1, len(centered) // 4):
            c = np.mean(centered[:-lag] * centered[lag:]) / var
            if c < 0.1:
                tau = lag
                break
            tau = lag
        autocorr_times.append(tau)
    return np.median(autocorr_times)


np.random.seed(42)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Eigenvalue spectrum
ax1 = axes[0]
strengths = [0.1, 0.3, 0.5, 0.7, 0.9]
n = 16
colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(strengths)))
for idx, strength in enumerate(strengths):
    J = strength * (np.ones((n, n)) - np.eye(n)) / n
    eigenvalues = np.sort(np.linalg.eigvalsh(J))[::-1]
    ax1.plot(range(1, n+1), eigenvalues, 'o-', color=colors[idx],
             label=f'β={strength}', markersize=4, linewidth=1.5)

ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax1.set_xlabel('Eigenvalue index', fontsize=12)
ax1.set_ylabel('Eigenvalue', fontsize=12)
ax1.set_title('Lorentzian Spectrum\n(one positive, rest negative)', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Panel 2: Mixing time scaling
ax2 = axes[1]
sizes = [6, 8, 10, 12, 14, 16]
gaps_list = []
tmix_list = []
nlogn_list = []

for n_val in sizes:
    J = 0.4 * (np.ones((n_val, n_val)) - np.eye(n_val)) / n_val
    h = np.zeros(n_val)
    gap = compute_gap(J)
    tmix = estimate_mixing(J, h, beta=1.0, n_runs=5, max_steps=1000)
    
    gaps_list.append(gap)
    tmix_list.append(tmix)
    nlogn_list.append(n_val * np.log(n_val) / gap if gap > 0 else 0)

ax2.scatter(nlogn_list, tmix_list, s=80, c='royalblue', zorder=5, edgecolors='navy')
# Fit line
nlogn_arr = np.array(nlogn_list)
tmix_arr = np.array(tmix_list)
if len(nlogn_arr) > 1:
    slope = np.polyfit(nlogn_arr, tmix_arr, 1)
    x_fit = np.linspace(min(nlogn_arr), max(nlogn_arr), 100)
    ax2.plot(x_fit, np.polyval(slope, x_fit), '--', color='crimson',
             linewidth=2, label=f'Linear fit')

for i, n_val in enumerate(sizes):
    ax2.annotate(f'n={n_val}', (nlogn_list[i], tmix_list[i]),
                textcoords="offset points", xytext=(5, 5), fontsize=8)

ax2.set_xlabel('n·log(n)/ε (predicted)', fontsize=12)
ax2.set_ylabel('Empirical mixing time', fontsize=12)
ax2.set_title('Mixing Time Scales as\nn·log(n)/ε', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Panel 3: Perturbation stability
ax3 = axes[2]
n = 12
J_base = 0.5 * (np.ones((n, n)) - np.eye(n)) / n
gap_base = compute_gap(J_base)
delta_fracs = np.linspace(0, 0.5, 30)
gap_ratios = []
gap_ratios_std = []

for df in delta_fracs:
    delta = df * gap_base / (2 * n**2)
    ratios_trial = []
    for _ in range(20):
        E = np.random.uniform(-delta, delta, (n, n))
        E = (E + E.T) / 2
        gap_pert = compute_gap(J_base + E)
        ratios_trial.append(gap_pert / gap_base)
    gap_ratios.append(np.mean(ratios_trial))
    gap_ratios_std.append(np.std(ratios_trial))

gap_ratios = np.array(gap_ratios)
gap_ratios_std = np.array(gap_ratios_std)
ax3.fill_between(delta_fracs, gap_ratios - gap_ratios_std,
                 gap_ratios + gap_ratios_std, alpha=0.2, color='steelblue')
ax3.plot(delta_fracs, gap_ratios, '-', color='steelblue', linewidth=2,
         label='Empirical gap ratio')
ax3.axhline(y=0.5, color='crimson', linestyle='--', linewidth=1.5,
            label='Theorem bound (ε/2)')
ax3.axhline(y=1.0, color='gray', linestyle=':', alpha=0.5)
ax3.set_xlabel('Perturbation fraction (δ·2n²/ε)', fontsize=12)
ax3.set_ylabel('Gap ratio (ε\'/ε)', fontsize=12)
ax3.set_title('Perturbation Stability\nof Lorentzian Gap', fontsize=13)
ax3.legend(fontsize=10)
ax3.set_ylim(0, 1.15)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('lorentzian_mixing_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: lorentzian_mixing_visualization.png")
