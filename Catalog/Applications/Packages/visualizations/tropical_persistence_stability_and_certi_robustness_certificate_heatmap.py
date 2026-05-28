"""
Visualization: Robustness Certificate Heatmap

Creates a heatmap showing the robustness margin for different
combinations of target bar length and perturbation magnitude.

Green regions: topological feature is certifiably robust.
Red regions: robustness cannot be guaranteed.
The boundary shows the critical margin curve L + 2δ = diameter.
"""

import numpy as np
import matplotlib.pyplot as plt


rng = np.random.default_rng(42)

# Generate graph weights
n = 15
m = n * (n - 1) // 2
w = rng.uniform(0, 1, m)
diameter = float(np.max(w) - np.min(w))

# Parameter grid
bar_lengths = np.linspace(0, diameter * 1.2, 100)
perturbations = np.linspace(0, diameter / 2, 80)

# Compute margin matrix: margin = diameter - L - 2δ
L_grid, delta_grid = np.meshgrid(bar_lengths, perturbations)
margin_grid = diameter - L_grid - 2 * delta_grid

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: margin heatmap
ax = axes[0]
im = ax.pcolormesh(bar_lengths, perturbations, margin_grid,
                   cmap='RdYlGn', vmin=-0.5, vmax=0.5, shading='auto')
ax.contour(bar_lengths, perturbations, margin_grid, levels=[0],
           colors='black', linewidths=2)
cb = plt.colorbar(im, ax=ax)
cb.set_label('Robustness margin (d - L - 2δ)', fontsize=11)
ax.set_xlabel('Target bar length L', fontsize=12)
ax.set_ylabel('Perturbation bound δ', fontsize=12)
ax.set_title('Robustness Certificate Map', fontsize=13, fontweight='bold')

# Add annotation
ax.annotate('CERTIFIED\nROBUST', xy=(0.15 * diameter, 0.05 * diameter),
            fontsize=12, fontweight='bold', color='darkgreen',
            ha='center')
ax.annotate('NOT\nCERTIFIED', xy=(0.85 * diameter, 0.35 * diameter),
            fontsize=12, fontweight='bold', color='darkred',
            ha='center')

# Right: Monte Carlo verification
ax = axes[1]

# Sample points and check if certification matches reality
n_samples = 500
L_samples = rng.uniform(0, diameter * 1.1, n_samples)
delta_samples = rng.uniform(0, diameter / 2.5, n_samples)

certified = []
actually_holds = []

for L_s, d_s in zip(L_samples, delta_samples):
    cert = (diameter - L_s - 2 * d_s) >= 0
    certified.append(cert)

    # Check empirically
    holds = True
    for _ in range(50):
        wp = w + rng.uniform(-d_s, d_s, m)
        if float(np.max(wp) - np.min(wp)) < L_s:
            holds = False
            break
    actually_holds.append(holds)

certified = np.array(certified)
actually_holds = np.array(actually_holds)

# Color: green=both agree robust, blue=certified but checked,
# orange=not certified but holds, red=correctly not certified
colors = []
labels_used = set()
for c, a in zip(certified, actually_holds):
    if c and a:
        colors.append('green')
    elif c and not a:
        colors.append('red')  # Should never happen!
    elif not c and a:
        colors.append('orange')
    else:
        colors.append('lightcoral')

ax.scatter(L_samples[certified & actually_holds],
           delta_samples[certified & actually_holds],
           c='green', alpha=0.5, s=15, label='Certified & verified')
ax.scatter(L_samples[~certified & actually_holds],
           delta_samples[~certified & actually_holds],
           c='orange', alpha=0.5, s=15, label='Holds but not certified')
ax.scatter(L_samples[~certified & ~actually_holds],
           delta_samples[~certified & ~actually_holds],
           c='lightcoral', alpha=0.5, s=15, label='Correctly not certified')

# Check for false certifications (should be zero)
false_certs = np.sum(certified & ~actually_holds)
ax.set_xlabel('Target bar length L', fontsize=12)
ax.set_ylabel('Perturbation bound δ', fontsize=12)
ax.set_title(f'Monte Carlo Verification (false certs: {false_certs})',
             fontsize=13, fontweight='bold')
ax.legend(fontsize=9, loc='upper right')

# Draw theoretical boundary
L_boundary = np.linspace(0, diameter, 100)
delta_boundary = (diameter - L_boundary) / 2
ax.plot(L_boundary, delta_boundary, 'k-', linewidth=2, label='Critical boundary')

fig.suptitle(f'Certified Robustness Map (diameter = {diameter:.3f})',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_robustness_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: viz_robustness_heatmap.png")
