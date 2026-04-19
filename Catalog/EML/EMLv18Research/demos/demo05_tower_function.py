"""
Demo 05: EML Tower Function — Iterated Exponentiation
=====================================================
The EML tower: T(0,x) = x, T(n+1,x) = exp(T(n,x)).
Verified in Lean: T(n,x) is strictly increasing in n for x ≥ 0.
"""

import numpy as np
import matplotlib.pyplot as plt

def eml_tower(n, x):
    """Compute the n-th EML tower at x."""
    result = x
    for _ in range(n):
        result = np.exp(result)
    return result

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: Tower values for small n
ax = axes[0]
x_vals = np.linspace(-1, 1.5, 300)
for n in range(5):
    y_vals = np.array([eml_tower(n, xi) for xi in x_vals])
    y_vals = np.clip(y_vals, -10, 100)
    ax.plot(x_vals, y_vals, linewidth=2, label=f'T({n}, x)')

ax.set_ylim(-2, 30)
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('T(n, x)', fontsize=12)
ax.set_title('EML Tower Functions', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 2: Tower orbit from x=0
ax = axes[1]
n_steps = 7
orbit = [0.0]
for i in range(n_steps):
    orbit.append(np.exp(orbit[-1]))

ax.semilogy(range(len(orbit)), orbit, 'bo-', markersize=8, linewidth=2)
for i, v in enumerate(orbit):
    if v < 1e10:
        ax.annotate(f'{v:.2f}', (i, v), textcoords="offset points",
                   xytext=(10, 5), fontsize=9)
ax.set_xlabel('n', fontsize=12)
ax.set_ylabel('T(n, 0)', fontsize=12)
ax.set_title('Tower Orbit from x = 0', fontsize=14)
ax.grid(True, alpha=0.3)

# Plot 3: Growth rate comparison
ax = axes[2]
n_vals = np.arange(0, 6)
x0_vals = [0, 0.5, 1]
for x0 in x0_vals:
    orbit = [x0]
    for _ in range(5):
        try:
            orbit.append(min(np.exp(orbit[-1]), 1e15))
        except OverflowError:
            orbit.append(1e15)
    ax.semilogy(n_vals, orbit, 'o-', markersize=6, linewidth=2, label=f'x₀ = {x0}')

ax.set_xlabel('Iteration n', fontsize=12)
ax.set_ylabel('T(n, x₀)', fontsize=12)
ax.set_title('Super-Exponential Growth', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('EML/EMLv18Research/demos/tower_function.png', dpi=150, bbox_inches='tight')
plt.close()
print("Demo 05 saved: tower_function.png")
