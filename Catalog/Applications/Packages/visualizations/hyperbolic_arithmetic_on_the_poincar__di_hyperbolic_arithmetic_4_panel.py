#!/usr/bin/env python3
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def moebius_add(a, b):
    return (a + b) / (1 + a * b)

def moebius_iterate(a, n):
    if n == 0: return 0.0
    return math.tanh(n * math.atanh(a))

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Hyperbolic Arithmetic on the Poincaré Disk', fontsize=16)

ax1 = axes[0, 0]
for a in [0.1, 0.3, 0.5, 0.7, 0.9]:
    ns = list(range(21))
    vals = [moebius_iterate(a, n) for n in ns]
    ax1.plot(ns, vals, 'o-', markersize=3, label=f'a={a}')
ax1.axhline(y=1, color='red', linestyle='--', alpha=0.5)
ax1.set_xlabel('Step n'); ax1.set_ylabel('Iterate value')
ax1.set_title('Möbius Iteration Convergence'); ax1.legend(fontsize=8)

ax2 = axes[0, 1]
for a, b in [(0.2, 0.4), (0.3, 0.5)]:
    ns = list(range(1, 26))
    gaps = [moebius_iterate(b, n) - moebius_iterate(a, n) for n in ns]
    ax2.semilogy(ns, gaps, 'o-', markersize=3, label=f'a={a},b={b}')
ax2.set_xlabel('Step n'); ax2.set_ylabel('Gap (log)')
ax2.set_title('Orbit Separation'); ax2.legend(fontsize=8)

ax3 = axes[1, 0]
ns = list(range(1, 16))
ax3.semilogy(ns, [2**(n+1)-1 for n in ns], 'ro-', label='Hyperbolic')
ax3.semilogy(ns, [2*n+1 for n in ns], 'b^-', label='Euclidean Z')
ax3.set_xlabel('Radius n'); ax3.set_ylabel('Ball size')
ax3.set_title('Growth Rates'); ax3.legend(fontsize=8)

ax4 = axes[1, 1]
for r in [0.3, 0.5, 0.7]:
    ax4.semilogy(ns, [r**(-2*n) for n in ns], 'o-', markersize=3, label=f'r={r}')
ax4.semilogy(ns, [1/n**2 for n in ns], 'k^-', label='Classical')
ax4.set_xlabel('n'); ax4.set_ylabel('Summand')
ax4.set_title('Zeta Summand Reversal'); ax4.legend(fontsize=8)

plt.tight_layout()
plt.savefig('hyperbolic_arithmetic.png', dpi=150)
print('Saved to hyperbolic_arithmetic.png')