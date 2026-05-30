"""
Visualization 1: The Hat Spectrum - Inflation Factor and Spectral Gap

Visualizes the one-parameter family of aperiodic monotiles discovered by
Smith et al. (2023). The hat spectrum is parameterized by t ∈ [0,1], where
t=0 gives the hat, t=1 gives the turtle, and intermediate values give
intermediate aperiodic monotiles.

Two key quantities are plotted:
- The area inflation factor σ(t): always > 1, measuring hierarchical scaling
- The spectral gap Δ(t)^{1/2}: minimized at t=1/2, measuring eigenvalue separation

The spectral gap minimum at t=1/2 is formally proved (Theorem: spectralGap_minimized_at_half).
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib

matplotlib.rcParams.update({
    'font.size': 12,
    'axes.labelsize': 14,
    'axes.titlesize': 15,
    'figure.figsize': (12, 5),
})

# Compute spectrum properties
t = np.linspace(0, 1, 500)
c_t = 4 - 2 * t * (1 - t)
delta_t = c_t**2 - 4
sigma_t = (c_t + np.sqrt(delta_t)) / 2
gap_t = np.sqrt(delta_t)
entropy_t = np.log(sigma_t)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: Inflation factor
ax1 = axes[0]
ax1.plot(t, sigma_t, 'b-', linewidth=2.5)
ax1.axhline(y=1, color='gray', linestyle='--', alpha=0.5, label='σ = 1')
ax1.set_xlabel('Parameter t')
ax1.set_ylabel('Area Inflation Factor σ(t)')
ax1.set_title('Inflation Factor Across\nthe Hat Spectrum')
ax1.fill_between(t, 1, sigma_t, alpha=0.15, color='blue')
ax1.scatter([0, 1], [sigma_t[0], sigma_t[-1]], color='red', s=80, zorder=5,
            label='Hat (t=0) & Turtle (t=1)')
ax1.scatter([0.5], [(c_t[250] + np.sqrt(delta_t[250])) / 2], color='green',
            s=80, zorder=5, marker='D', label='Midpoint (t=½)')
ax1.legend(fontsize=9)
ax1.set_ylim(2.8, 4.0)
ax1.grid(True, alpha=0.3)

# Plot 2: Spectral gap
ax2 = axes[1]
ax2.plot(t, gap_t, 'r-', linewidth=2.5)
ax2.scatter([0.5], [gap_t[250]], color='green', s=100, zorder=5, marker='v',
            label=f'Minimum: Δ(½) = {gap_t[250]:.3f}')
ax2.scatter([0, 1], [gap_t[0], gap_t[-1]], color='blue', s=80, zorder=5,
            label=f'Maximum: Δ(0) = {gap_t[0]:.3f}')
ax2.fill_between(t, gap_t, alpha=0.15, color='red')
ax2.set_xlabel('Parameter t')
ax2.set_ylabel('Spectral Gap √(c(t)² − 4)')
ax2.set_title('Spectral Gap:\nMinimized at t = ½ (Proved)')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Plot 3: Topological entropy
ax3 = axes[2]
ax3.plot(t, entropy_t, 'g-', linewidth=2.5)
ax3.fill_between(t, entropy_t, alpha=0.15, color='green')
ax3.set_xlabel('Parameter t')
ax3.set_ylabel('Topological Entropy h(t) = log σ(t)')
ax3.set_title('Topological Entropy:\nBridge to Tropical Geometry')
ax3.scatter([0, 1], [entropy_t[0], entropy_t[-1]], color='red', s=80, zorder=5)
ax3.scatter([0.5], [entropy_t[250]], color='purple', s=80, zorder=5, marker='D',
            label=f'Min entropy: {entropy_t[250]:.3f}')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

plt.suptitle('The Hat Spectrum: A Continuous Family of Aperiodic Monotiles',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectrum.png")
