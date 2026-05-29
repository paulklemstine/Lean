"""
Visualization 1: Logistic Map Cobweb Diagram and Orbit at r=4

Shows the chaotic dynamics of f(x) = 4x(1-x) via:
- The parabola y = 4x(1-x) and the diagonal y = x
- A cobweb diagram tracing the orbit from x₀ = 0.1
- Fixed points at x=0 and x=3/4 marked

This visualizes why the logistic map is chaotic: the parabola's
steep slopes cause orbits to bounce wildly across [0,1].
"""

import numpy as np
import matplotlib.pyplot as plt

def logistic_map(x, r=4.0):
    return r * x * (1.0 - x)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Cobweb diagram
ax = axes[0]
x_range = np.linspace(0, 1, 500)
ax.plot(x_range, logistic_map(x_range), 'b-', linewidth=2, label='$f(x) = 4x(1-x)$')
ax.plot(x_range, x_range, 'k--', linewidth=1, label='$y = x$')

# Cobweb from x0 = 0.1
x0 = 0.1
x = x0
n_steps = 30
cobweb_x, cobweb_y = [x], [0]
for _ in range(n_steps):
    y = logistic_map(x)
    cobweb_x.extend([x, y])
    cobweb_y.extend([y, y])
    x = y

ax.plot(cobweb_x, cobweb_y, 'r-', linewidth=0.8, alpha=0.7)
ax.plot(0, 0, 'go', markersize=10, zorder=5, label='Fixed point $x=0$')
ax.plot(0.75, 0.75, 'ms', markersize=10, zorder=5, label='Fixed point $x=3/4$')
ax.plot(x0, 0, 'r^', markersize=10, zorder=5, label=f'$x_0={x0}$')

ax.set_xlabel('$x$', fontsize=14)
ax.set_ylabel('$f(x)$', fontsize=14)
ax.set_title('Cobweb Diagram: Chaotic Orbit of $f(x) = 4x(1-x)$', fontsize=13)
ax.legend(fontsize=10, loc='upper left')
ax.set_xlim(-0.02, 1.02)
ax.set_ylim(-0.02, 1.1)
ax.grid(True, alpha=0.3)

# Right panel: Time series showing sensitivity
ax2 = axes[1]
n_iter = 80
x1, x2 = 0.3, 0.3 + 1e-10
orbit1, orbit2 = [x1], [x2]
for _ in range(n_iter):
    x1 = logistic_map(x1)
    x2 = logistic_map(x2)
    orbit1.append(x1)
    orbit2.append(x2)

ax2.plot(range(n_iter+1), orbit1, 'b-', linewidth=1, label='$x_0 = 0.3$', alpha=0.8)
ax2.plot(range(n_iter+1), orbit2, 'r-', linewidth=1, label='$x_0 = 0.3 + 10^{-10}$', alpha=0.8)

ax2.set_xlabel('Iteration $n$', fontsize=14)
ax2.set_ylabel('$f^n(x_0)$', fontsize=14)
ax2.set_title('Sensitivity: Two Orbits Diverge Exponentially', fontsize=13)
ax2.legend(fontsize=11)
ax2.set_xlim(0, n_iter)
ax2.set_ylim(-0.02, 1.02)
ax2.grid(True, alpha=0.3)

# Add annotation showing divergence point
for i in range(len(orbit1)):
    if abs(orbit1[i] - orbit2[i]) > 0.1:
        ax2.axvline(x=i, color='gray', linestyle=':', alpha=0.5)
        ax2.annotate(f'Diverge at $n={i}$', xy=(i, 0.5),
                    fontsize=10, color='gray', ha='center')
        break

plt.tight_layout()
plt.savefig('viz_cobweb_sensitivity.png', dpi=150, bbox_inches='tight')
print("Saved viz_cobweb_sensitivity.png")
