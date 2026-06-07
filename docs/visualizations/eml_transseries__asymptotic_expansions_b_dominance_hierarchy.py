#!/usr/bin/env python3
"""Visualization: The Exponential Dominance Hierarchy

Shows how iterated exponentials, polynomials, and logarithms compare
on a log-log scale, illustrating the strict hierarchy that makes
transseries necessary.
"""
import numpy as np
import matplotlib.pyplot as plt
import matplotlib

matplotlib.rcParams['font.size'] = 12

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: exp vs polynomials
ax = axes[0]
x = np.linspace(1, 8, 200)
ax.semilogy(x, np.exp(x), 'r-', linewidth=2, label='exp(x)')
for n in [1, 2, 3, 5]:
    ax.semilogy(x, x**n, '--', linewidth=1.5, label=f'x^{n}')
ax.set_xlabel('x')
ax.set_ylabel('f(x) [log scale]')
ax.set_title('Exponential Dominates All Polynomials')
ax.legend(fontsize=10)
ax.set_ylim(1, 1e4)
ax.grid(True, alpha=0.3)

# Panel 2: log subordinate to powers
ax = axes[1]
x = np.linspace(2, 1000, 500)
for eps in [0.01, 0.05, 0.1, 0.5, 1.0]:
    ratio = np.log(x) / x**eps
    ax.plot(x, ratio, linewidth=1.5, label=f'log(x)/x^{eps}')
ax.axhline(y=0, color='k', linestyle='-', linewidth=0.5)
ax.set_xlabel('x')
ax.set_ylabel('log(x) / x^ε')
ax.set_title('Log Subordinate to Any Positive Power')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 3: EML diagonal asymptotic to exp
ax = axes[2]
z = np.linspace(0.1, 6, 200)
exp_z = np.exp(z)
eml_diag = exp_z - np.log(z)
ax.semilogy(z, exp_z, 'r-', linewidth=2, label='exp(z)')
ax.semilogy(z, eml_diag, 'b--', linewidth=2, label='emlDiag(z) = exp(z) - log(z)')
ax.semilogy(z, np.abs(np.log(z)), 'g:', linewidth=1.5, label='|log(z)|')
ax.set_xlabel('z')
ax.set_ylabel('f(z) [log scale]')
ax.set_title('EML Diagonal ~ exp(z)')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('dominance_hierarchy.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: dominance_hierarchy.png")
