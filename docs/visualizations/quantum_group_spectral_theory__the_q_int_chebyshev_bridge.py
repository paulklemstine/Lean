"""
Visualization: The Chebyshev Bridge — q-integers as Chebyshev polynomials

Shows the exact equality [n+1]_q = U_n(x) for several n values,
plotted as functions of x.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def q_integer(x: float, n: int) -> float:
    if n == 0:
        return 0.0
    if n == 1:
        return 1.0
    a, b = 0.0, 1.0
    for _ in range(2, n + 1):
        a, b = b, 2 * x * b - a
    return b


def chebyshev_U(x: float, n: int) -> float:
    if n == 0:
        return 1.0
    if n == 1:
        return 2 * x
    a, b = 1.0, 2 * x
    for _ in range(2, n + 1):
        a, b = b, 2 * x * b - a
    return b


xs = np.linspace(-1.0, 1.0, 500)

fig, axes = plt.subplots(2, 3, figsize=(15, 8))
fig.suptitle('The Chebyshev Bridge: [n+1]_q = U_n(x)\n'
             'q-integers (blue dots) ≡ Chebyshev polynomials of the 2nd kind (red line)',
             fontsize=13, fontweight='bold')

for idx, n in enumerate([0, 1, 2, 3, 4, 5]):
    ax = axes[idx // 3, idx % 3]

    # Chebyshev U_n as continuous curve
    ys_cheby = [chebyshev_U(x, n) for x in xs]
    ax.plot(xs, ys_cheby, 'r-', linewidth=2, label=f'U_{n}(x)')

    # q-integer [n+1] at sample points
    xs_sample = np.linspace(-1.0, 1.0, 30)
    ys_qint = [q_integer(x, n + 1) for x in xs_sample]
    ax.plot(xs_sample, ys_qint, 'b.', markersize=8, label=f'[{n+1}]_q')

    ax.set_title(f'[{n+1}]_q = U_{n}(x)', fontsize=11)
    ax.set_xlabel('x = cos(θ)')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=0, color='k', linewidth=0.5)

plt.tight_layout()
plt.savefig('chebyshev_bridge.png', dpi=150, bbox_inches='tight')
print("Saved chebyshev_bridge.png")
