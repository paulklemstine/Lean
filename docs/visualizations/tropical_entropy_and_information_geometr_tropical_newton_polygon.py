"""
Visualization 2: Tropical Newton Polygon
=========================================

Shows how Newton's inequality for elementary symmetric polynomials
translates into tropical concavity of the log-coefficient sequence,
forming the tropical Newton polygon of the DPP generating polynomial.

The concave envelope (Newton polygon) is the key tropical-geometric
structure that encodes entanglement information.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def elementary_symmetric_all(spectrum):
    """Compute all elementary symmetric polynomials."""
    m = len(spectrum)
    dp = np.zeros(m + 1)
    dp[0] = 1.0
    for mu in spectrum:
        for j in range(m, 0, -1):
            dp[j] += mu * dp[j - 1]
    return dp


def binary_entropy(x):
    if x <= 0 or x >= 1:
        return 0.0
    return -x * np.log(x) - (1 - x) * np.log(1 - x)


def trop_min_entropy(x):
    return 2 * min(x, 1 - x) * np.log(2)


# Three different spectra representing different entanglement regimes
spectra = {
    'Area-law\n(mostly 0 or 1)': np.array([0.98, 0.95, 0.92, 0.08, 0.05, 0.02]),
    'Intermediate': np.array([0.8, 0.6, 0.5, 0.4, 0.3, 0.1]),
    'Volume-law\n(near uniform)': np.array([0.55, 0.52, 0.50, 0.48, 0.45, 0.42]),
}

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

for idx, (name, spec) in enumerate(spectra.items()):
    m = len(spec)
    coeffs = elementary_symmetric_all(spec)

    # Log-coefficients
    log_coeffs = np.array([np.log(c) if c > 0 else -np.inf for c in coeffs])
    ks = np.arange(m + 1)

    # Slopes
    slopes = np.diff(log_coeffs)
    slopes_finite = slopes[np.isfinite(slopes)]

    # Compute entropies
    s_exact = sum(binary_entropy(mu) for mu in spec)
    s_trop = sum(trop_min_entropy(mu) for mu in spec)

    # Top row: Newton polygon
    ax = axes[0, idx]
    ax.plot(ks, log_coeffs, 'bo-', markersize=8, linewidth=2, label='$\\log(e_k)$')

    # Linear interpolation (chord)
    if np.isfinite(log_coeffs[0]) and np.isfinite(log_coeffs[-1]):
        chord = log_coeffs[0] + (log_coeffs[-1] - log_coeffs[0]) * ks / m
        ax.plot(ks, chord, 'r--', linewidth=1.5, alpha=0.7, label='Chord')
        ax.fill_between(ks, chord, log_coeffs,
                        where=np.isfinite(log_coeffs),
                        alpha=0.2, color='green', label='Concavity surplus')

    ax.set_xlabel('$k$', fontsize=12)
    ax.set_ylabel('$\\log(e_k)$', fontsize=12)
    ax.set_title(f'{name}\n$S={s_exact:.3f}$, $S_{{\\mathrm{{trop}}}}={s_trop:.3f}$',
                 fontsize=12, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Bottom row: slopes (tropical roots)
    ax2 = axes[1, idx]
    slope_ks = np.arange(len(slopes))
    colors = ['green' if s >= 0 else 'red' for s in slopes]
    ax2.bar(slope_ks, slopes, color=colors, alpha=0.7, edgecolor='black')
    ax2.axhline(y=0, color='black', linewidth=0.5)
    ax2.set_xlabel('$k$', fontsize=12)
    ax2.set_ylabel('Slope $\\log(e_{k+1}) - \\log(e_k)$', fontsize=12)
    ax2.set_title('Tropical Roots (negated slopes)', fontsize=12)
    ax2.grid(True, alpha=0.3)

    # Verify non-increasing slopes
    is_antitone = all(slopes[i] >= slopes[i+1] - 1e-10
                      for i in range(len(slopes)-1)
                      if np.isfinite(slopes[i]) and np.isfinite(slopes[i+1]))
    ax2.annotate(f'Slopes antitone: {"✓" if is_antitone else "✗"}',
                 xy=(0.95, 0.95), xycoords='axes fraction',
                 ha='right', va='top', fontsize=10,
                 bbox=dict(boxstyle='round,pad=0.3',
                          facecolor='lightgreen' if is_antitone else 'lightsalmon'))

plt.suptitle('Tropical Newton Polygons: From Newton Inequality to Tropical Concavity',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_newton_polygon.png', dpi=150, bbox_inches='tight')
print("Saved viz_newton_polygon.png")
