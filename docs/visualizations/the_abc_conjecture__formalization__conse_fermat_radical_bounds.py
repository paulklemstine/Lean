#!/usr/bin/env python3
"""
Visualization 3: Fermat Radical Bounds and the ABC-FLT Connection

Visualizes the key inequality rad(x^n * y^n * z^n) ≤ xyz that connects
the ABC conjecture to Fermat's Last Theorem. Shows how the radical
'collapses' exponential growth, creating a tension that (assuming ABC)
makes Fermat-type equations impossible for large exponents.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import prod, log


def factorize(n):
    if n <= 1:
        return {}
    factors = {}
    d = 2
    temp = abs(n)
    while d * d <= temp:
        while temp % d == 0:
            factors[d] = factors.get(d, 0) + 1
            temp //= d
        d += 1
    if temp > 1:
        factors[temp] = 1
    return factors


def radical(n):
    if n <= 1:
        return 1
    f = factorize(n)
    return prod(f.keys()) if f else 1


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: rad(x^n * y^n) vs xy for fixed x,y, varying n
ax1 = axes[0]
pairs = [(2, 3), (3, 5), (5, 7), (6, 7)]
ns = list(range(1, 16))

for x, y in pairs:
    rads = [radical(x**n * y**n) for n in ns]
    xy_bound = x * y
    ax1.plot(ns, rads, 'o-', markersize=4, label=f'rad({x}^n·{y}^n)')
    ax1.axhline(y=xy_bound, linestyle='--', alpha=0.4)

ax1.set_xlabel('Exponent n', fontsize=11)
ax1.set_ylabel('rad(x^n · y^n)', fontsize=11)
ax1.set_title('Radical Collapse of Powers', fontsize=12)
ax1.legend(fontsize=8)

# Panel 2: The ABC tension — log(z^n) vs log(rad(x^n y^n z^n)) for near-Fermat
ax2 = axes[1]
# For x^n + y^n, compute z^n (not exact Fermat, but z ≈ (x^n+y^n)^(1/n))
x_vals = [2, 3, 4, 5]
for x in x_vals:
    y = x + 1
    n_range = list(range(2, 12))
    log_zn = []
    log_rad = []
    for n in n_range:
        zn = x**n + y**n
        r = radical(x**n * y**n * zn)
        log_zn.append(log(zn))
        log_rad.append(log(r))

    ax2.plot(n_range, [lz / lr if lr > 0 else 0 for lz, lr in zip(log_zn, log_rad)],
             'o-', markersize=4, label=f'x={x}, y={y}')

ax2.axhline(y=1.0, color='red', linestyle='--', linewidth=2, alpha=0.7,
            label='Quality = 1 (ABC barrier)')
ax2.set_xlabel('Exponent n', fontsize=11)
ax2.set_ylabel('log(x^n+y^n) / log(rad(x^n·y^n·(x^n+y^n)))', fontsize=11)
ax2.set_title('ABC Quality Growth with Exponent', fontsize=12)
ax2.legend(fontsize=8)

# Panel 3: Heatmap of rad(x^n * y^n) / (xy) for various x, y at n=3
ax3 = axes[2]
size = 15
data = np.zeros((size, size))
for i in range(size):
    for j in range(size):
        x = i + 2
        y = j + 2
        n = 3
        r = radical(x**n * y**n)
        data[i, j] = r / (x * y)

im = ax3.imshow(data, cmap='RdYlGn_r', aspect='auto',
                origin='lower', vmin=0, vmax=1.1)
ax3.set_xlabel('y (offset by 2)', fontsize=11)
ax3.set_ylabel('x (offset by 2)', fontsize=11)
ax3.set_title('rad(x³·y³) / (x·y) — Always ≤ 1', fontsize=12)
plt.colorbar(im, ax=ax3, label='Ratio')

plt.tight_layout()
plt.savefig('fermat_radical_bounds.png', dpi=150, bbox_inches='tight')
print("Saved fermat_radical_bounds.png")
