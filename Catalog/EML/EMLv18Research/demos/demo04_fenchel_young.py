"""
Demo 04: Fenchel-Young Inequality and Conjugate Duality
======================================================
Verified in Lean: x·s ≤ exp(x) + s·log(s) - s for s > 0.
This is the Fenchel-Young inequality for the convex conjugate pair (exp, s·log s - s).
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: Fenchel conjugate of exp
ax = axes[0]
s = np.linspace(0.01, 8, 500)
conj = s * np.log(s) - s  # exp*(s) = s*ln(s) - s

ax.plot(s, conj, 'b-', linewidth=2, label=r"$\exp^*(s) = s \ln s - s$")
ax.plot(s, s - 1, 'r--', alpha=0.5, label=r'$s - 1$ (tangent at $s=1$)')
ax.axhline(y=-1, color='g', linestyle=':', alpha=0.5, label=r'Min $= -1$ at $s=1$')
ax.plot(1, -1, 'ko', markersize=8)
ax.set_xlabel('s', fontsize=12)
ax.set_ylabel(r'$\exp^*(s)$', fontsize=12)
ax.set_title('Fenchel Conjugate of exp', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 2: Fenchel-Young inequality verification
ax = axes[1]
n_tests = 5000
x_test = np.random.uniform(-3, 3, n_tests)
s_test = np.random.uniform(0.01, 5, n_tests)
lhs = x_test * s_test
rhs = np.exp(x_test) + s_test * np.log(s_test) - s_test
gap = rhs - lhs

ax.hist(gap, bins=50, color='blue', alpha=0.7, edgecolor='black')
ax.axvline(x=0, color='r', linewidth=2, label='Gap ≥ 0 (verified)')
ax.set_xlabel('Fenchel-Young Gap', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title(f'x·s ≤ exp(x) + s·log(s) - s ({np.sum(gap < -1e-10)} violations / {n_tests})', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 3: Fenchel-Young as EML bound
ax = axes[2]
x_vals = np.linspace(-2, 3, 200)
for s_val in [0.5, 1, 2, 3]:
    bound = x_vals * s_val
    actual = np.exp(x_vals) + s_val * np.log(s_val) - s_val
    ax.plot(x_vals, actual - bound, linewidth=1.5, label=f's = {s_val}')

ax.axhline(y=0, color='k', linewidth=0.5)
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('Gap = exp(x) + s·log(s) - s - x·s', fontsize=11)
ax.set_title('Fenchel-Young Gap by s', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('EML/EMLv18Research/demos/fenchel_young.png', dpi=150, bbox_inches='tight')
plt.close()
print("Demo 04 saved: fenchel_young.png")
