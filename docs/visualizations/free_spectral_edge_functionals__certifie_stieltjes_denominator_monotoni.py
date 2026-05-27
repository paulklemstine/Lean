"""
Visualization 2: Stieltjes Denominator and Edge Equation

Illustrates the strict monotonicity of f_μ(x) and how the free edge
is determined by the intersection f_μ(x) = 1/σ².
"""

import numpy as np
import matplotlib.pyplot as plt


def stieltjes_denom(locs, weights, x):
    """Compute f_μ(x) = Σ wᵢ/(x - aᵢ)²."""
    return sum(w / (x - a)**2 for a, w in zip(locs, weights))


# Setup: 3-atom law
locs = [-1.0, 0.5, 2.0]
weights = [0.3, 0.3, 0.4]
max_loc = max(locs)

# Compute f_μ on x > max_loc
x_vals = np.linspace(max_loc + 0.05, max_loc + 5, 500)
f_vals = [stieltjes_denom(locs, weights, x) for x in x_vals]

fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

# Left: f_μ(x) with threshold lines
ax = axes[0]
ax.plot(x_vals, f_vals, 'b-', linewidth=2.5, label=r'$f_\mu(x) = \sum w_i/(x-a_i)^2$')

sigmas = [0.5, 1.0, 2.0]
colors = ['red', 'orange', 'green']
for sigma, color in zip(sigmas, colors):
    target = 1.0 / sigma**2
    ax.axhline(y=target, color=color, linestyle='--', linewidth=1.5,
               label=f'1/σ² (σ={sigma})', alpha=0.8)

    # Find intersection
    for i in range(len(x_vals)-1):
        if f_vals[i] >= target >= f_vals[i+1]:
            frac = (target - f_vals[i+1]) / (f_vals[i] - f_vals[i+1])
            x_edge = x_vals[i+1] + frac * (x_vals[i] - x_vals[i+1])
            ax.plot(x_edge, target, 'o', color=color, markersize=10, zorder=5)
            ax.annotate(f'R={x_edge:.2f}', (x_edge, target),
                       textcoords="offset points", xytext=(10, 10),
                       fontsize=10, color=color)
            break

ax.set_xlabel('x', fontsize=13)
ax.set_ylabel(r'$f_\mu(x)$', fontsize=13)
ax.set_title('Stieltjes Denominator (Strictly Decreasing)', fontsize=13)
ax.set_ylim(0, 10)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Vertical lines for atom locations
for a, w in zip(locs, weights):
    ax.axvline(x=a, color='gray', linestyle=':', alpha=0.5)

# Right: Noise monotonicity
ax = axes[1]
sigmas_range = np.linspace(0.2, 3.0, 100)
edges = []
for sigma in sigmas_range:
    target = 1.0 / sigma**2
    # Bisection
    left, right = max_loc + 1e-6, max_loc + 20
    for _ in range(200):
        mid = (left + right) / 2
        if stieltjes_denom(locs, weights, mid) > target:
            left = mid
        else:
            right = mid
    edges.append((left + right) / 2)

ax.plot(sigmas_range, edges, 'b-', linewidth=2.5, label='Free edge R(μ,σ)')
ax.plot(sigmas_range, 2*sigmas_range, 'r--', linewidth=2, label='Classical 2σ')
ax.plot(sigmas_range, [max_loc]*len(sigmas_range), 'k:', linewidth=1.5,
        alpha=0.5, label=f'Max atom loc = {max_loc}')

ax.set_xlabel('Noise strength σ', fontsize=13)
ax.set_ylabel('Edge location', fontsize=13)
ax.set_title('Free Edge Monotonicity in Noise (Theorem 7)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_stieltjes_monotonicity.png', dpi=150, bbox_inches='tight')
print("Saved viz_stieltjes_monotonicity.png")
