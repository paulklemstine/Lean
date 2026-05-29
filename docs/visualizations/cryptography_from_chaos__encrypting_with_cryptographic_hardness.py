"""
Visualization 3: Cryptographic Hardness — Polynomial Degree Growth

Shows why the logistic cipher is computationally hard to break:
- Left: Exponential growth of polynomial degree 2^n vs polynomial bounds n³
- Right: The iterate polynomials f^1, f^2, f^3 showing rapid complexity growth

This is the core cryptographic insight: inverting f^n(x) = y requires
solving a polynomial of degree 2^n, which is exponentially hard.
"""

import numpy as np
import matplotlib.pyplot as plt


def logistic_map(x):
    return 4.0 * x * (1.0 - x)


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Degree growth comparison
ax = axes[0]
n_range = np.arange(1, 26)
degree_2n = 2.0**n_range
cubic = n_range**3.0
quartic = n_range**4.0

ax.semilogy(n_range, degree_2n, 'b-o', linewidth=2, markersize=5,
            label='$\\deg(f^n) = 2^n$ (actual)')
ax.semilogy(n_range, cubic, 'r--', linewidth=2, label='$n^3$ (polynomial)')
ax.semilogy(n_range, quartic, 'g-.', linewidth=1.5, label='$n^4$')

# Mark the crossover point
for n in n_range:
    if 2**n > n**3:
        ax.axvline(x=n, color='orange', linestyle=':', alpha=0.5)
        ax.annotate(f'$2^n > n^3$ at $n={n}$',
                   xy=(n, 2**n), xytext=(n+2, 2**(n-2)),
                   fontsize=10, arrowprops=dict(arrowstyle='->', color='orange'),
                   color='orange')
        break

ax.fill_between(n_range, cubic, degree_2n, alpha=0.1, color='blue',
                where=degree_2n > cubic)

ax.set_xlabel('Number of iterations $n$', fontsize=14)
ax.set_ylabel('Polynomial degree / Complexity', fontsize=14)
ax.set_title('Cryptographic Hardness:\nExponential Degree Growth', fontsize=13)
ax.legend(fontsize=12, loc='upper left')
ax.grid(True, alpha=0.3)
ax.set_ylim(1, 1e8)

# Right: The iterate functions f, f², f³, f⁴
ax2 = axes[1]
x_range = np.linspace(0, 1, 1000)

colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd']
for n, color in zip([1, 2, 3, 4, 5], colors):
    y = x_range.copy()
    for _ in range(n):
        y = 4.0 * y * (1.0 - y)
    ax2.plot(x_range, y, color=color, linewidth=1.5,
             label=f'$f^{n}(x)$, deg $= 2^{n} = {2**n}$',
             alpha=0.8)

ax2.plot(x_range, x_range, 'k--', linewidth=0.5, alpha=0.5, label='$y=x$')

ax2.set_xlabel('$x$', fontsize=14)
ax2.set_ylabel('$f^n(x)$', fontsize=14)
ax2.set_title('Iterate Polynomials: Growing Complexity', fontsize=13)
ax2.legend(fontsize=10, loc='lower center', ncol=2)
ax2.set_xlim(0, 1)
ax2.set_ylim(-0.02, 1.02)
ax2.grid(True, alpha=0.3)

# Add annotation about oscillation count
ax2.text(0.5, -0.15, 'Each iterate has $2^n$ oscillations — exponentially more complex to invert',
         transform=ax2.transAxes, fontsize=10, ha='center', style='italic',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_crypto_hardness.png', dpi=150, bbox_inches='tight')
print("Saved viz_crypto_hardness.png")
