"""
Demo 4: Parametric EML Family eml_α(x, y) = exp(αx) - α·log(y)

V19 introduces the α-parametric family of EML operators.
Key properties:
- eml_1 = eml (standard)
- eml_0 ≡ 1 (constant)
- eml_α + eml_{-α} = 2·cosh(αx) (symmetric sum)
- Each eml_α is convex in x
"""

import numpy as np
import matplotlib.pyplot as plt

def eml_alpha(alpha, x, y):
    return np.exp(alpha * x) - alpha * np.log(y)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: Family curves for different α
ax = axes[0]
x = np.linspace(-2, 2, 200)
y_fixed = 2
for alpha in [0, 0.5, 1, 1.5, 2]:
    ax.plot(x, eml_alpha(alpha, x, y_fixed), label=f'α = {alpha}')
ax.set_xlabel('x')
ax.set_ylabel(f'eml_α(x, {y_fixed})')
ax.set_title('Parametric Family: Varying α')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 2: α-sum identity: eml_α + eml_{-α} = 2·cosh(αx)
ax = axes[1]
for alpha in [0.5, 1, 2]:
    lhs = eml_alpha(alpha, x, 2) + eml_alpha(-alpha, x, 2)
    rhs = 2 * np.cosh(alpha * x)
    ax.plot(x, lhs, '-', label=f'sum (α={alpha})')
    ax.plot(x, rhs, '--', alpha=0.5)

ax.set_xlabel('x')
ax.set_ylabel('eml_α + eml_{-α}')
ax.set_title('Sum = 2·cosh(αx) (y cancels)')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 3: α as a continuous parameter (heat map)
ax = axes[2]
alpha_range = np.linspace(-2, 2, 100)
x_range = np.linspace(-2, 2, 100)
A, X = np.meshgrid(alpha_range, x_range)
Z = eml_alpha(A, X, np.e)
c = ax.contourf(A, X, Z, levels=20, cmap='RdBu_r')
plt.colorbar(c, ax=ax)
ax.set_xlabel('α')
ax.set_ylabel('x')
ax.set_title('eml_α(x, e) as α varies')

plt.suptitle('V19: Parametric EML Family', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('demo4_parametric_family.png', dpi=150, bbox_inches='tight')
plt.close()
print("Demo 4 saved: demo4_parametric_family.png")
