"""
Demo 7: EML Generating Function G(t) = eml(t, exp(-t)) = exp(t) + t

V19 proves the surprising identity: eml(t, exp(-t)) = exp(t) + t.
This "generating function" is strictly convex and surjective.
It connects EML to moment generating functions.

Also demonstrates:
- Exponential tilting: eml(x+θ, y) = e^θ · eml(x,y) + (e^θ-1)·log(y)
- EML shifted ODE: d/dx eml(x,C) = eml(x,C) + log(C)
"""

import numpy as np
import matplotlib.pyplot as plt

def eml(x, y):
    return np.exp(x) - np.log(y)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: Generating function G(t) = exp(t) + t
ax = axes[0]
t = np.linspace(-3, 3, 300)
G = np.exp(t) + t
eml_gen = eml(t, np.exp(-t))
ax.plot(t, G, 'b-', linewidth=2, label='G(t) = exp(t) + t')
ax.plot(t, eml_gen, 'r--', linewidth=1, label='eml(t, e⁻ᵗ)')
ax.plot(t, np.exp(t), 'g:', alpha=0.5, label='exp(t)')
ax.plot(t, t, 'k:', alpha=0.5, label='t')
ax.set_xlabel('t')
ax.set_ylabel('G(t)')
ax.set_title('EML Generating Function')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 2: Exponential tilting
ax = axes[1]
x = np.linspace(-2, 2, 200)
y_fixed = 2
base = eml(x, y_fixed)
for theta in [0, 0.5, 1, 1.5]:
    tilted = eml(x + theta, y_fixed)
    formula = np.exp(theta) * base + (np.exp(theta) - 1) * np.log(y_fixed)
    ax.plot(x, tilted, '-', linewidth=2, label=f'eml(x+{theta}, 2)')
    ax.plot(x, formula, ':', alpha=0.5)  # Should match
ax.set_xlabel('x')
ax.set_ylabel('eml(x+θ, 2)')
ax.set_title('Exponential Tilting')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 3: EML ODE - the function and its derivative
ax = axes[2]
x = np.linspace(-2, 2, 200)
for C in [0.5, 1, 2, np.e]:
    f = eml(x, C)
    f_prime = np.exp(x)  # derivative of eml(x, C) w.r.t. x
    f_plus_logC = f + np.log(C)
    ax.plot(x, f_prime, '-', linewidth=2, label=f'f\'(x), C={C:.1f}')
    ax.plot(x, f_plus_logC, ':', alpha=0.5)  # Should match f'
ax.set_xlabel('x')
ax.set_ylabel("f'(x) = f(x) + log(C)")
ax.set_title('EML Shifted ODE: f\' = f + log(C)')
ax.legend()
ax.grid(True, alpha=0.3)

plt.suptitle('V19: EML Generating Function & Tilting', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('demo7_generating_function.png', dpi=150, bbox_inches='tight')
plt.close()
print("Demo 7 saved: demo7_generating_function.png")
