#!/usr/bin/env python3
import math
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def catalan(n): return math.comb(2*n, n) // (n+1)
def hankel_det(n):
    H = np.array([[catalan(i+j) for j in range(n+1)] for i in range(n+1)], dtype=float)
    return int(round(np.linalg.det(H)))

fig, (ax1, ax2, ax3) = plt.subplots(1, 3, figsize=(15, 5))
ns = list(range(16))
ax1.semilogy(ns, [catalan(n) for n in ns], 'bo-')
ax1.semilogy(ns, [4**n for n in ns], 'r--', alpha=0.5)
ax1.set_title('Catalan Growth')
ratios = [catalan(n+1)/catalan(n) for n in range(1,25)]
ax2.plot(range(1,25), ratios, 'bo-')
ax2.axhline(4, color='r', ls='--')
ax2.set_title('C(n+1)/C(n) -> 4')
ax3.bar(range(10), [hankel_det(n) for n in range(10)])
ax3.set_title('Hankel det = 1')
plt.tight_layout()
plt.savefig('viz_catalan.png', dpi=150)
