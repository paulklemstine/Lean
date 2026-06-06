#!/usr/bin/env python3
"""
Visualization: Tropical Mandelbrot Dynamics

Shows the tropical (max-plus) analog of the Mandelbrot iteration:
z ↦ max(2z, c), and its connection to the classical Mandelbrot set.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def tropical_iterate(c, z, n):
    for _ in range(n):
        z = max(2 * z, c)
    return z


def mandelbrot_escape_time(c, max_iter=100):
    z = 0 + 0j
    for n in range(max_iter):
        z = z * z + c
        if abs(z) > 2:
            return n
    return max_iter


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Tropical orbits for various c
ax = axes[0, 0]
cs = [-2, -1, -0.5, 0, 0.5, 1, 2]
colors_list = plt.cm.coolwarm(np.linspace(0, 1, len(cs)))
steps = list(range(8))
for c_val, color in zip(cs, colors_list):
    orbit = [tropical_iterate(c_val, 0, n) for n in steps]
    ax.plot(steps, orbit, 'o-', color=color, label=f'c={c_val}', markersize=5)
ax.axhline(y=0, color='black', linewidth=0.5, linestyle='--')
ax.set_xlabel('Step n')
ax.set_ylabel('Tropical iterate')
ax.set_title('Tropical Mandelbrot Orbits: z ↦ max(2z, c)')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Plot 2: Tropical Mandelbrot set boundary
ax = axes[0, 1]
c_range = np.linspace(-3, 3, 1000)
bounded = []
for c in c_range:
    z = 0
    escaped = False
    for _ in range(50):
        z = max(2 * z, c)
        if z > 1e10:
            escaped = True
            break
    bounded.append(0 if escaped else 1)
ax.fill_between(c_range, 0, bounded, alpha=0.4, color='steelblue',
                label='Tropical M (bounded)')
ax.axvline(x=0, color='red', linestyle='--', linewidth=1.5,
           label='Boundary: c = 0')
ax.set_xlabel('c')
ax.set_ylabel('Bounded (1) / Escaping (0)')
ax.set_title('Tropical Mandelbrot Set = {c ≤ 0}')
ax.legend()
ax.set_ylim(-0.1, 1.1)
ax.grid(True, alpha=0.3)

# Plot 3: Escape theorem verification
ax = axes[1, 0]
z0 = 3.0
c_val = 1.0
steps_long = list(range(10))
actual = [tropical_iterate(c_val, z0, n) for n in steps_long]
predicted = [2**n * z0 for n in steps_long]
ax.semilogy(steps_long, actual, 'bo-', label='Actual orbit', markersize=6)
ax.semilogy(steps_long, predicted, 'r--', label='2^n · z₀', markersize=4)
ax.set_xlabel('Step n')
ax.set_ylabel('Value (log scale)')
ax.set_title(f'Tropical Escape: z₀={z0}, c={c_val} (c < 2z₀)')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 4: Classical vs Tropical — side by side on real line
ax = axes[1, 1]
c_range_fine = np.linspace(-2.5, 0.5, 500)
classical_bounded = []
tropical_bounded_vals = []
for c in c_range_fine:
    # Classical
    z = 0
    classical_esc = False
    for _ in range(100):
        z = z * z + c
        if abs(z) > 2:
            classical_esc = True
            break
    classical_bounded.append(0 if classical_esc else 1)
    # Tropical
    tropical_bounded_vals.append(1 if c <= 0 else 0)

ax.fill_between(c_range_fine, 0, classical_bounded, alpha=0.4,
                color='blue', label='Classical M ∩ ℝ')
ax.fill_between(c_range_fine, 0, [t * 0.5 for t in tropical_bounded_vals],
                alpha=0.4, color='red', label='Tropical M (scaled)')
ax.set_xlabel('c (real axis)')
ax.set_ylabel('Bounded')
ax.set_title('Classical vs Tropical Mandelbrot on ℝ')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/Applications/tropical_mandelbrot.png', dpi=150)
plt.close()
print("Saved tropical_mandelbrot.png")
