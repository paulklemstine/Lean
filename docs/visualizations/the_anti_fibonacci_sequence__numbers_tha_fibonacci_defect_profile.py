#!/usr/bin/env python3
import matplotlib.pyplot as plt
import numpy as np

def defect(n): return n * (3 - n) / 2

N = 50
ns = list(range(N+1))
ds = [defect(n) for n in ns]
fig, ax = plt.subplots(figsize=(12,6))
colors = ['#2ecc71' if d>0 else '#f1c40f' if d==0 else '#e74c3c' for d in ds]
ax.bar(ns, ds, color=colors, alpha=0.8, edgecolor='black', lw=0.3)
x = np.linspace(0, N, 500); ax.plot(x, x*(3-x)/2, 'k--', lw=2, label='d(n)=n(3-n)/2')
coinc = [n for n in ns if ds[n]==0]
ax.scatter(coinc, [0]*len(coinc), color='gold', s=150, zorder=5, edgecolors='black', lw=2, label=f'Coincidences: n={coinc}')
ax.axhline(0, color='black', lw=0.8)
ax.set_xlabel('n'); ax.set_ylabel('Defect d(n)'); ax.set_title('Fibonacci Defect Profile', fontsize=15, fontweight='bold')
ax.legend(); ax.grid(alpha=0.3)
plt.tight_layout(); plt.savefig('defect_profile.png', dpi=150); plt.close()