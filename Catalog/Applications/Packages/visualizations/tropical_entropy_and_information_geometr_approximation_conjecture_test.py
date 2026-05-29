"""
Visualization 3: Tropical Entropy Approximation Conjecture Test
================================================================

Tests the conjecture that for area-law spectra (entropy ≤ C·√m),
the relative error |S - S_trop|/S scales as O(1/m).

This produces a log-log plot of relative error vs. system size m,
with 1/m reference line for comparison.
"""

import numpy as np
import matplotlib.pyplot as plt


def binary_entropy(x):
    if x <= 0 or x >= 1:
        return 0.0
    return -x * np.log(x) - (1 - x) * np.log(1 - x)


def trop_min_entropy(x):
    return 2 * min(x, 1 - x) * np.log(2)


def generate_area_law_spectrum(m, rng, boundary_fraction=0.1):
    """Generate a spectrum satisfying area-law scaling.

    Most eigenvalues near 0, a few (√m) near 1/2.
    """
    n_bulk = max(1, int(np.sqrt(m)))
    n_boundary = m - n_bulk
    spectrum = np.concatenate([
        rng.uniform(0, boundary_fraction, n_boundary),
        rng.uniform(0.3, 0.7, n_bulk),
    ])
    rng.shuffle(spectrum)
    return spectrum


def generate_random_spectrum(m, rng):
    """Generate a uniformly random spectrum."""
    return rng.uniform(0, 1, m)


# Run experiment
rng = np.random.RandomState(42)
sizes = [5, 8, 10, 15, 20, 30, 50, 75, 100, 150, 200]
n_trials = 200

area_law_errors = {m: [] for m in sizes}
random_errors = {m: [] for m in sizes}

for m in sizes:
    for _ in range(n_trials):
        # Area-law spectrum
        spec_al = generate_area_law_spectrum(m, rng)
        s_al = sum(binary_entropy(mu) for mu in spec_al)
        st_al = sum(trop_min_entropy(mu) for mu in spec_al)
        if s_al > 0.01:
            area_law_errors[m].append((s_al - st_al) / s_al)

        # Random spectrum
        spec_rand = generate_random_spectrum(m, rng)
        s_rand = sum(binary_entropy(mu) for mu in spec_rand)
        st_rand = sum(trop_min_entropy(mu) for mu in spec_rand)
        if s_rand > 0.01:
            random_errors[m].append((s_rand - st_rand) / s_rand)

# Compute statistics
al_means = [np.mean(area_law_errors[m]) for m in sizes]
al_stds = [np.std(area_law_errors[m]) for m in sizes]
rand_means = [np.mean(random_errors[m]) for m in sizes]
rand_stds = [np.std(random_errors[m]) for m in sizes]

# Fit power law to area-law data
log_m = np.log(np.array(sizes))
log_err_al = np.log(np.array(al_means))
mask = np.isfinite(log_err_al)
if mask.sum() > 2:
    coeffs_al = np.polyfit(log_m[mask], log_err_al[mask], 1)
    al_exponent = coeffs_al[0]
else:
    al_exponent = -1.0

log_err_rand = np.log(np.array(rand_means))
mask_rand = np.isfinite(log_err_rand)
if mask_rand.sum() > 2:
    coeffs_rand = np.polyfit(log_m[mask_rand], log_err_rand[mask_rand], 1)
    rand_exponent = coeffs_rand[0]
else:
    rand_exponent = 0.0

# Create figure
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: Log-log plot
ax1.errorbar(sizes, al_means, yerr=al_stds, fmt='bo-', linewidth=2,
             capsize=4, markersize=7, label=f'Area-law (slope={al_exponent:.2f})')
ax1.errorbar(sizes, rand_means, yerr=rand_stds, fmt='rs--', linewidth=2,
             capsize=4, markersize=7, label=f'Random (slope={rand_exponent:.2f})')

# Reference lines
ref_1m = [1.0 / m for m in sizes]
ax1.plot(sizes, ref_1m, 'k:', linewidth=2, alpha=0.5, label='$O(1/m)$ reference')

ax1.set_xscale('log')
ax1.set_yscale('log')
ax1.set_xlabel('System size $m$', fontsize=14)
ax1.set_ylabel('Relative error $(S - S_{\\mathrm{trop}})/S$', fontsize=14)
ax1.set_title('Conjecture Test: Approximation Scaling', fontsize=15, fontweight='bold')
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3, which='both')

# Annotate conjecture result
if abs(al_exponent + 1) < 0.3:
    verdict = "CONSISTENT with $O(1/m)$"
    color = 'green'
else:
    verdict = f"Scaling ~ $O(m^{{{al_exponent:.2f}}})$"
    color = 'orange'
ax1.annotate(verdict, xy=(0.05, 0.05), xycoords='axes fraction',
             fontsize=12, fontweight='bold', color=color,
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

# Right: Error distribution at m=100
ax2_data_al = area_law_errors.get(100, [])
ax2_data_rand = random_errors.get(100, [])

if ax2_data_al and ax2_data_rand:
    ax2.hist(ax2_data_al, bins=30, alpha=0.6, color='blue', density=True,
             label='Area-law spectra')
    ax2.hist(ax2_data_rand, bins=30, alpha=0.6, color='red', density=True,
             label='Random spectra')
    ax2.axvline(x=np.mean(ax2_data_al), color='blue', linestyle='--', linewidth=2)
    ax2.axvline(x=np.mean(ax2_data_rand), color='red', linestyle='--', linewidth=2)

ax2.set_xlabel('Relative error $(S - S_{\\mathrm{trop}})/S$', fontsize=14)
ax2.set_ylabel('Density', fontsize=14)
ax2.set_title('Error Distribution at $m = 100$', fontsize=15, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.suptitle('Testing the Tropical Entropy Approximation Conjecture',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_conjecture_test.png', dpi=150, bbox_inches='tight')
print("Saved viz_conjecture_test.png")
