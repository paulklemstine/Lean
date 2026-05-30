"""
Visualization 3: The Lorentzian-to-Coefficient Bridge

Visualizes how bivariate specialization transforms a Lorentzian polynomial
into a log-concave coefficient sequence, showing:
1. The coefficient sequences for various (α, β) parameters
2. How log-concavity ratios vary with specialization direction
3. The universal lower bound from the reversed Cauchy-Schwarz inequality
"""
import numpy as np
import matplotlib.pyplot as plt
import math


def bivariate_coeffs(d, alpha, beta):
    return [math.comb(d, m) * alpha**m * beta**(d - m) for m in range(d + 1)]


def lc_min_ratio(seq):
    d = len(seq) - 1
    ratios = []
    for m in range(1, d):
        if seq[m - 1] > 0 and seq[m + 1] > 0:
            ratios.append(seq[m]**2 / (seq[m - 1] * seq[m + 1]))
    return min(ratios) if ratios else float('inf')


d = 10

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Coefficient sequences for different α/β
ax1 = axes[0]
params = [(1, 1), (2, 1), (1, 2), (3, 1), (1, 3)]
colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(params)))

for (alpha, beta), color in zip(params, colors):
    coeffs = bivariate_coeffs(d, alpha, beta)
    # Normalize to max 1 for visual comparison
    mx = max(coeffs)
    normalized = [c / mx for c in coeffs]
    ax1.plot(range(d + 1), normalized, 'o-', color=color, markersize=5,
             label=f'α={alpha}, β={beta}', linewidth=2)

ax1.set_xlabel('Index m', fontsize=12)
ax1.set_ylabel('Normalized coefficient', fontsize=12)
ax1.set_title(f'Bivariate Specialization\nCoefficients of (αx + βy)^{d}', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(alpha=0.3)

# Panel 2: Log-concavity ratio as function of α/β
ax2 = axes[1]
ratios_by_ab = []
ab_values = np.linspace(0.1, 5.0, 50)

for ab in ab_values:
    coeffs = bivariate_coeffs(d, ab, 1.0)
    ratios_by_ab.append(lc_min_ratio(coeffs))

ax2.plot(ab_values, ratios_by_ab, 'b-', linewidth=2)
ax2.axhline(y=1.0, color='red', linestyle='--', alpha=0.7, label='LC threshold')
ax2.set_xlabel('α/β ratio', fontsize=12)
ax2.set_ylabel('Minimum LC ratio', fontsize=12)
ax2.set_title('Log-Concavity Strength\nvs. Specialization Direction', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(alpha=0.3)
ax2.set_ylim(0.9, 2.5)

# Panel 3: The reversed Cauchy-Schwarz surplus for different degrees
ax3 = axes[2]
for deg in [5, 10, 15, 20, 30]:
    ms = np.arange(1, deg)
    # The exact formula: ratio = (deg-m+1)(m+1) / (m*(deg-m))
    exact_ratios = [(deg - m + 1) * (m + 1) / (m * (deg - m)) for m in ms]
    ax3.plot(ms / deg, exact_ratios, '-', linewidth=2,
             label=f'd = {deg}', alpha=0.8)

ax3.axhline(y=1.0, color='red', linestyle='--', alpha=0.7)
ax3.set_xlabel('Normalized position m/d', fontsize=12)
ax3.set_ylabel('Reversed Cauchy-Schwarz ratio', fontsize=12)
ax3.set_title('Universal Lower Bound\nfrom Lorentzian Structure', fontsize=13)
ax3.legend(fontsize=9)
ax3.grid(alpha=0.3)
ax3.set_ylim(0.8, 4.0)

plt.suptitle('The Lorentzian-to-Coefficient Bridge',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_bridge_diagram.png', dpi=150, bbox_inches='tight')
print("Saved viz_bridge_diagram.png")
