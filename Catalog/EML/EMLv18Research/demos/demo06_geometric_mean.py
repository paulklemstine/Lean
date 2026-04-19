"""
Demo 06: EML Geometric Mean Identity
====================================
Verified in Lean: eml(x, √(ab)) = (eml(x,a) + eml(x,b))/2.
The geometric mean in the second argument gives the arithmetic mean of EML values!
This connects EML to the AM-GM inequality structure.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: Identity verification
ax = axes[0]
n_tests = 10000
x_test = np.random.uniform(-2, 3, n_tests)
a_test = np.random.uniform(0.01, 5, n_tests)
b_test = np.random.uniform(0.01, 5, n_tests)

eml_geom = np.exp(x_test) - np.log(np.sqrt(a_test * b_test))
eml_avg = (np.exp(x_test) - np.log(a_test) + np.exp(x_test) - np.log(b_test)) / 2
error = np.abs(eml_geom - eml_avg)

ax.hist(np.log10(error + 1e-20), bins=50, color='blue', alpha=0.7, edgecolor='black')
ax.set_xlabel('log₁₀(|error|)', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title(f'Identity Error (max = {error.max():.2e})', fontsize=14)
ax.grid(True, alpha=0.3)

# Plot 2: Visualization for fixed x
ax = axes[1]
x_fixed = 1.0
a_range = np.linspace(0.1, 5, 100)
b_fixed = 2.0

eml_a = np.exp(x_fixed) - np.log(a_range)
eml_b = np.exp(x_fixed) - np.log(b_fixed)
eml_geom_vals = np.exp(x_fixed) - np.log(np.sqrt(a_range * b_fixed))
eml_avg_vals = (eml_a + eml_b) / 2

ax.plot(a_range, eml_geom_vals, 'b-', linewidth=2.5, label=r'$\mathrm{eml}(x, \sqrt{ab})$')
ax.plot(a_range, eml_avg_vals, 'r--', linewidth=2, label=r'$\frac{1}{2}[\mathrm{eml}(x,a) + \mathrm{eml}(x,b)]$')
ax.set_xlabel('a', fontsize=12)
ax.set_ylabel('EML value', fontsize=12)
ax.set_title(f'x = {x_fixed}, b = {b_fixed}: Perfect Agreement', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 3: The AM-GM connection
ax = axes[2]
a_range = np.linspace(0.1, 10, 200)
b_range = np.linspace(0.1, 10, 200)
A, B = np.meshgrid(a_range, b_range)
geom_mean = np.sqrt(A * B)
arith_mean = (A + B) / 2
ratio = geom_mean / arith_mean  # Always ≤ 1 by AM-GM

c = ax.contourf(A, B, ratio, levels=20, cmap='RdYlGn')
plt.colorbar(c, ax=ax, label=r'$\sqrt{ab} / \frac{a+b}{2}$')
ax.plot([0.1, 10], [0.1, 10], 'k--', label='a = b (ratio = 1)')
ax.set_xlabel('a', fontsize=12)
ax.set_ylabel('b', fontsize=12)
ax.set_title('Geometric/Arithmetic Mean Ratio', fontsize=14)
ax.legend(fontsize=10)

plt.tight_layout()
plt.savefig('EML/EMLv18Research/demos/geometric_mean.png', dpi=150, bbox_inches='tight')
plt.close()
print("Demo 06 saved: geometric_mean.png")
