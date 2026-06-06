#!/usr/bin/env python3
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math

def tower(b, n):
    if n == 0: return 1
    prev = tower(b, n - 1)
    if prev > 100: return float('inf')
    return b ** prev

def counting_lb(r, k):
    if r > k: return k
    ckr = math.comb(k, r)
    if ckr > 60: return float('inf')
    threshold = 2 ** ckr
    n = k
    while 2 * math.comb(n, k) < threshold and n < 10**6: n += 1
    return n - 1

fig, axes = plt.subplots(1, 3, figsize=(18, 5))
ns = list(range(0, 6))
tower_vals = [tower(2, n) for n in ns]
exp_vals = [2**n for n in ns]
ax = axes[0]
vt = [(n, v) for n, v in zip(ns, tower_vals) if v < float('inf')]
ve = [(n, v) for n, v in zip(ns, exp_vals) if v < float('inf')]
ax.semilogy([x[0] for x in vt], [x[1] for x in vt], 'ro-', lw=2, ms=8, label='tower(2,n)')
ax.semilogy([x[0] for x in ve], [x[1] for x in ve], 'bs--', lw=2, ms=8, label='2^n')
ax.set_xlabel('Height n'); ax.set_ylabel('Value (log)')
ax.set_title('Tower vs Exponential'); ax.legend(); ax.grid(alpha=0.3)
ax = axes[1]
for r in [2, 3, 4]:
    lbs, vks = [], []
    for k in range(r+1, 12):
        lb = counting_lb(r, k)
        if lb < float('inf') and lb < 10**6: lbs.append(lb); vks.append(k)
    if vks: ax.semilogy(vks, lbs, 'o-', lw=2, ms=6, label=f'r={r}')
ax.set_xlabel('k'); ax.set_ylabel('Lower bound'); ax.set_title('Counting Lower Bounds'); ax.legend(); ax.grid(alpha=0.3)
ax = axes[2]
k_t = np.linspace(3, 10, 100)
ax.plot(k_t, k_t/2, 'r-', lw=2, label='k/2 (graphs)')
ax.plot(k_t, k_t**2/6, 'b-', lw=2, label='k²/6 (3-uniform)')
ax.plot(k_t, k_t**3/120, 'g-', lw=2, label='k³/120 (4-uniform)')
ax.set_xlabel('k'); ax.set_ylabel('Exponent growth'); ax.set_title('Growth Rate Comparison'); ax.legend(); ax.grid(alpha=0.3)
plt.tight_layout(); plt.savefig('ramsey_spectrum.png', dpi=150)
print('Saved ramsey_spectrum.png')