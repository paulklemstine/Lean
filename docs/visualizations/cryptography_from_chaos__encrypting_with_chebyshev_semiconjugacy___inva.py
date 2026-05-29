"""
Visualization 2: Chebyshev Semiconjugacy and Invariant Measure

Shows the deep mathematical structure behind the logistic map:
- Left: The semiconjugacy sin²(θ) maps angle-doubling to the logistic map
- Right: The invariant (arcsine) measure μ(x) = 1/(π√(x(1-x)))

The semiconjugacy is the key insight: chaos in the logistic map is
just angle-doubling in disguise, viewed through the lens of sin².
"""

import numpy as np
import matplotlib.pyplot as plt

def logistic_map(x):
    return 4.0 * x * (1.0 - x)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Semiconjugacy diagram
ax = axes[0]

# Show how sin²(θ) transforms the circle map to the logistic map
theta = np.linspace(0, np.pi, 200)
x_vals = np.sin(theta)**2

# Plot sin²(θ) vs sin²(2θ) and logistic(sin²(θ))
theta_test = np.linspace(0.01, np.pi - 0.01, 100)
x_input = np.sin(theta_test)**2
logistic_output = logistic_map(x_input)
doubled_output = np.sin(2 * theta_test)**2

ax.scatter(x_input, logistic_output, c='blue', s=10, alpha=0.6,
           label='$f(\\sin^2\\theta)$')
ax.scatter(x_input, doubled_output, c='red', s=10, alpha=0.6,
           marker='x', label='$\\sin^2(2\\theta)$')

# They should be identical
ax.set_xlabel('$\\sin^2(\\theta)$', fontsize=14)
ax.set_ylabel('Output', fontsize=14)
ax.set_title('Chebyshev Semiconjugacy:\n$f(\\sin^2\\theta) = \\sin^2(2\\theta)$', fontsize=13)
ax.legend(fontsize=12)
ax.grid(True, alpha=0.3)

# Add text
max_err = np.max(np.abs(logistic_output - doubled_output))
ax.text(0.5, 0.15, f'Max error: {max_err:.2e}\n(Perfect overlap!)',
        transform=ax.transAxes, fontsize=11,
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8),
        ha='center')

# Right: Invariant measure (arcsine distribution)
ax2 = axes[1]

# Generate orbit histogram
x = 0.1234567890123
n_samples = 500000
orbit_data = np.zeros(n_samples)
for i in range(n_samples):
    x = logistic_map(x)
    orbit_data[i] = x

# Plot histogram
n_bins = 100
ax2.hist(orbit_data, bins=n_bins, density=True, alpha=0.6, color='steelblue',
         label='Orbit histogram')

# Overlay theoretical arcsine distribution
x_theory = np.linspace(0.001, 0.999, 500)
arcsine_pdf = 1.0 / (np.pi * np.sqrt(x_theory * (1.0 - x_theory)))
ax2.plot(x_theory, arcsine_pdf, 'r-', linewidth=2.5,
         label='$\\mu(x) = \\frac{1}{\\pi\\sqrt{x(1-x)}}$')

ax2.set_xlabel('$x$', fontsize=14)
ax2.set_ylabel('Density', fontsize=14)
ax2.set_title('Invariant Measure: The Arcsine Distribution', fontsize=13)
ax2.legend(fontsize=12)
ax2.set_xlim(0, 1)
ax2.set_ylim(0, 6)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_semiconjugacy_measure.png', dpi=150, bbox_inches='tight')
print("Saved viz_semiconjugacy_measure.png")
