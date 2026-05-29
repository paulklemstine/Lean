#!/usr/bin/env python3
"""
Visualization 1: OAM Spectral Density on the Unit Circle

Visualizes the spectral density |Δ_K(e^{2πiθ})|² for different knots,
showing how the Alexander polynomial creates distinct "fingerprints"
on the unit circle. Roots of the polynomial appear as dips to zero
in the spectral density, corresponding to OAM modes of knotted light.
"""
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


def alexander_eval(coeffs, t):
    """Evaluate polynomial with given coefficients at complex point t."""
    result = complex(0, 0)
    for i, c in enumerate(coeffs):
        result += c * t**i
    return result


def spectral_density(coeffs, n_points=1000):
    """Compute |Δ_K(e^{2πiθ})|² on the unit circle."""
    thetas = np.linspace(0, 1, n_points, endpoint=False)
    density = np.array([
        abs(alexander_eval(coeffs, np.exp(2j * np.pi * theta)))**2
        for theta in thetas
    ])
    return thetas, density


# Knot data
knots = {
    'Unknot\n(Δ = 1)': [1],
    'Trefoil\n(Δ = t² − t + 1)': [1, -1, 1],
    'Figure-Eight\n(Δ = −t² + 3t − 1)': [-1, 3, -1],
    'Cinquefoil\n(Δ = t⁴ − t³ + t² − t + 1)': [1, -1, 1, -1, 1],
}

colors = ['#2196F3', '#E91E63', '#FF9800', '#4CAF50']

fig = plt.figure(figsize=(14, 10))
gs = gridspec.GridSpec(2, 2, hspace=0.35, wspace=0.3)

for idx, ((name, coeffs), color) in enumerate(zip(knots.items(), colors)):
    ax = fig.add_subplot(gs[idx])

    thetas, density = spectral_density(coeffs)

    ax.fill_between(thetas * 360, 0, density, alpha=0.3, color=color)
    ax.plot(thetas * 360, density, color=color, linewidth=2)

    # Mark roots (where density ≈ 0)
    root_indices = np.where(density < 1e-6)[0]
    if len(root_indices) > 0:
        for ri in root_indices[::max(1, len(root_indices)//10)]:
            ax.axvline(x=thetas[ri]*360, color='red', linestyle='--',
                      alpha=0.5, linewidth=1)
            ax.annotate(f'OAM\nmode',
                       xy=(thetas[ri]*360, 0), fontsize=7,
                       ha='center', va='bottom', color='red')

    ax.set_xlabel('θ (degrees)', fontsize=11)
    ax.set_ylabel('|Δ_K(e^{2πiθ})|²', fontsize=11)
    ax.set_title(name, fontsize=12, fontweight='bold')
    ax.set_xlim(0, 360)
    ax.set_ylim(bottom=0)
    ax.grid(True, alpha=0.3)

fig.suptitle('OAM Spectral Density of Knotted Light Beams',
            fontsize=16, fontweight='bold', y=0.98)
plt.savefig('viz_oam_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved viz_oam_spectrum.png")
