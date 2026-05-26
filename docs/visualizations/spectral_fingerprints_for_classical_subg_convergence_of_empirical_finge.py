#!/usr/bin/env python3
"""
Visualization 3: Convergence of Empirical Spectral Fingerprint

This visualization demonstrates how the empirical irreducible rate converges
to the theoretical prediction as the sample size increases. This is the
practical foundation for the group recognition algorithm: with sufficiently
many samples, the spectral fingerprint reliably identifies the group family.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def enumerate_group_charpolys(p, group_type="GL"):
    """Get all characteristic polynomials for elements of the specified group."""
    charpolys = []
    for a in range(p):
        for b in range(p):
            for c in range(p):
                for d in range(p):
                    det = (a * d - b * c) % p
                    if group_type == "GL" and det == 0:
                        continue
                    if group_type == "SL" and det != 1:
                        continue
                    trace = (a + d) % p
                    const_term = det
                    linear_coeff = (-trace) % p
                    disc = (linear_coeff * linear_coeff - 4 * const_term) % p
                    is_irred = disc != 0 and pow(disc, (p - 1) // 2, p) != 1
                    charpolys.append(1 if is_irred else 0)
    return charpolys

def simulate_convergence(charpolys, n_trials=50, max_samples=None):
    """Simulate convergence of empirical irreducible rate."""
    if max_samples is None:
        max_samples = len(charpolys)

    rng = np.random.RandomState(42)
    sample_sizes = np.unique(np.logspace(0, np.log10(max_samples), 100).astype(int))
    sample_sizes = sample_sizes[sample_sizes <= max_samples]

    means = []
    stds = []

    for n in sample_sizes:
        rates = []
        for _ in range(n_trials):
            idx = rng.choice(len(charpolys), size=min(n, len(charpolys)), replace=True)
            sample = [charpolys[i] for i in idx]
            rates.append(np.mean(sample))
        means.append(np.mean(rates))
        stds.append(np.std(rates))

    return sample_sizes, np.array(means), np.array(stds)

# Parameters
p = 7

# Get all charpolys
gl2_charpolys = enumerate_group_charpolys(p, "GL")
sl2_charpolys = enumerate_group_charpolys(p, "SL")

# Theoretical rates
gl2_theory = p / (2 * (p + 1))
sl2_theory = (p - 1) / (2 * p)

# Simulate convergence
gl2_sizes, gl2_means, gl2_stds = simulate_convergence(gl2_charpolys)
sl2_sizes, sl2_means, sl2_stds = simulate_convergence(sl2_charpolys)

# Create figure
fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: Convergence curves
ax = axes[0]
ax.fill_between(gl2_sizes, gl2_means - 2*gl2_stds, gl2_means + 2*gl2_stds,
                alpha=0.2, color='blue')
ax.plot(gl2_sizes, gl2_means, 'b-', linewidth=2, label='GL₂ empirical')
ax.axhline(y=gl2_theory, color='blue', linestyle='--', alpha=0.7,
           label=f'GL₂ theory = {gl2_theory:.4f}')

ax.fill_between(sl2_sizes, sl2_means - 2*sl2_stds, sl2_means + 2*sl2_stds,
                alpha=0.2, color='red')
ax.plot(sl2_sizes, sl2_means, 'r-', linewidth=2, label='SL₂ empirical')
ax.axhline(y=sl2_theory, color='red', linestyle='--', alpha=0.7,
           label=f'SL₂ theory = {sl2_theory:.4f}')

ax.set_xscale('log')
ax.set_xlabel('Sample size', fontsize=12)
ax.set_ylabel('Irreducible rate', fontsize=12)
ax.set_title(f'Convergence to Theory (F₇)', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Plot 2: Error vs sample size
ax = axes[1]
gl2_errors = np.abs(gl2_means - gl2_theory)
sl2_errors = np.abs(sl2_means - sl2_theory)
theoretical_error = 0.5 / np.sqrt(gl2_sizes)  # ~ 1/sqrt(n) scaling

ax.loglog(gl2_sizes, gl2_errors + 1e-10, 'b.-', alpha=0.7, label='GL₂ error')
ax.loglog(sl2_sizes, sl2_errors + 1e-10, 'r.-', alpha=0.7, label='SL₂ error')
ax.loglog(gl2_sizes, theoretical_error, 'k--', alpha=0.5,
          label=r'$O(1/\sqrt{n})$ reference')

ax.set_xlabel('Sample size', fontsize=12)
ax.set_ylabel('|Empirical - Theory|', fontsize=12)
ax.set_title('Error Convergence Rate', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 3: Distinguishing power
ax = axes[2]
# Probability of correct classification vs sample size
n_classify_trials = 200
sample_sizes_classify = [5, 10, 20, 50, 100, 200, 500]

rng = np.random.RandomState(123)
gl2_correct = []
sl2_correct = []

for n in sample_sizes_classify:
    gl2_c = 0
    sl2_c = 0
    for _ in range(n_classify_trials):
        # Sample from GL_2
        idx = rng.choice(len(gl2_charpolys), size=n, replace=True)
        rate = np.mean([gl2_charpolys[i] for i in idx])
        if abs(rate - gl2_theory) < abs(rate - sl2_theory):
            gl2_c += 1

        # Sample from SL_2
        idx = rng.choice(len(sl2_charpolys), size=n, replace=True)
        rate = np.mean([sl2_charpolys[i] for i in idx])
        if abs(rate - sl2_theory) < abs(rate - gl2_theory):
            sl2_c += 1

    gl2_correct.append(gl2_c / n_classify_trials)
    sl2_correct.append(sl2_c / n_classify_trials)

ax.plot(sample_sizes_classify, gl2_correct, 'bo-', linewidth=2,
        markersize=8, label='GL₂ correct ID')
ax.plot(sample_sizes_classify, sl2_correct, 'rs-', linewidth=2,
        markersize=8, label='SL₂ correct ID')
ax.axhline(y=0.5, color='gray', linestyle=':', alpha=0.5, label='Random guess')
ax.axhline(y=0.95, color='green', linestyle='--', alpha=0.5, label='95% threshold')

ax.set_xlabel('Sample size', fontsize=12)
ax.set_ylabel('Classification accuracy', fontsize=12)
ax.set_title('Group Recognition Power', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.set_ylim(0.3, 1.05)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('convergence_fingerprint.png', dpi=150, bbox_inches='tight')
print("Saved convergence_fingerprint.png")
