"""
Demo 08: EML Complement Law and Involution
==========================================
Verified in Lean:
  eml(0, exp(t)) + t = 1  (complement law)
  eml(x, y) + eml(0, exp(eml(x, y))) = 1  (value complement)

The map t ↦ eml(0, exp(t)) = 1 - t is an affine involution.
Composing twice: eml(0, exp(eml(0, exp(t)))) = t (already V17).
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: The complement map
ax = axes[0]
t = np.linspace(-3, 4, 300)
complement = 1 - t  # eml(0, exp(t)) = 1 - t

ax.plot(t, complement, 'b-', linewidth=2.5, label=r'$\mathrm{eml}(0, e^t) = 1 - t$')
ax.plot(t, t, 'k--', alpha=0.5, label='Identity')
ax.plot(t, -t, 'r:', alpha=0.5, label='Negation')
ax.plot(0.5, 0.5, 'ro', markersize=10, label='Fixed point (1/2, 1/2)')
ax.set_xlabel('t', fontsize=12)
ax.set_ylabel('eml(0, exp(t))', fontsize=12)
ax.set_title('EML Complement: Affine Involution', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_aspect('equal')

# Plot 2: Value complement for eml(x, y)
ax = axes[1]
n_tests = 5000
x_test = np.random.uniform(-3, 3, n_tests)
y_test = np.random.uniform(0.01, 10, n_tests)
eml_vals = np.exp(x_test) - np.log(y_test)
complement_vals = 1 - eml_vals  # eml(0, exp(t)) = 1 - t
total = eml_vals + complement_vals

ax.hist(total, bins=1, color='green', alpha=0.7, edgecolor='black')
ax.axvline(x=1, color='r', linewidth=2, label='Sum = 1 (exact)')
ax.set_xlabel('eml(x,y) + eml(0, exp(eml(x,y)))', fontsize=11)
ax.set_ylabel('Count', fontsize=12)
ax.set_title(f'Value Complement Law (all sums = 1 exactly)', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 3: EML component decomposition
ax = axes[2]
x_range = np.linspace(-2, 3, 300)
y_fixed = 2.0

eml_full = np.exp(x_range) - np.log(y_fixed)
eml_x = np.exp(x_range)  # eml(x, 1) = exp(x)
eml_y = 1 - np.log(y_fixed)  # eml(0, y) = 1 - ln(y)

ax.plot(x_range, eml_full, 'b-', linewidth=2.5, label=r'$\mathrm{eml}(x, y)$')
ax.plot(x_range, eml_x, 'r--', linewidth=1.5, label=r'$\mathrm{eml}(x, 1) = e^x$')
ax.axhline(y=eml_y, color='g', linestyle='--', linewidth=1.5,
           label=f'eml(0, {y_fixed}) = {eml_y:.3f}')
ax.axhline(y=-1, color='purple', linestyle=':', alpha=0.5,
           label='Shift: eml(x,y) = eml(x,1) + eml(0,y) - 1')

# Verify: eml_full = eml_x + eml_y - 1
reconstruction = eml_x + eml_y - 1
ax.plot(x_range, reconstruction, 'k:', linewidth=3, alpha=0.3, label='Reconstructed')

ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('EML value', fontsize=12)
ax.set_title(f'Component Decomposition (y = {y_fixed})', fontsize=14)
ax.legend(fontsize=9, loc='upper left')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('EML/EMLv18Research/demos/complement_law.png', dpi=150, bbox_inches='tight')
plt.close()
print("Demo 08 saved: complement_law.png")
