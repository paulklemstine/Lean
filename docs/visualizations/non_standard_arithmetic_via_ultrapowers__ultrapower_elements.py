import matplotlib.pyplot as plt
import numpy as np
import math

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Non-Standard Arithmetic: Ultrapower Elements', fontsize=16)
N = 50
idx = np.arange(N)

ax = axes[0,0]
ax.plot(idx, np.full(N, 5), 'b-', lw=2, label='std(5)')
ax.plot(idx, idx, 'r-', lw=2, label='ω')
ax.plot(idx, idx**2, 'g--', lw=1.5, label='ω²')
ax.set_xlabel('Index i'); ax.set_ylabel('Value')
ax.set_title('Standard vs Non-Standard'); ax.legend(); ax.set_ylim(-5, 100); ax.grid(True, alpha=0.3)

ax = axes[0,1]
f = idx**2 + 7; g = idx + 1
q = np.array([f[i]//g[i] for i in range(N)])
r = np.array([f[i]%g[i] for i in range(N)])
ax.plot(idx, q, 'b-', lw=1.5, label='q=f÷g')
ax.plot(idx, r, 'r-', lw=1.5, label='r=f%g')
ax.set_title('Division Algorithm Transfer'); ax.legend(); ax.grid(True, alpha=0.3)

ax = axes[1,0]
f = 6*idx+12; g = 4*idx+8
d = np.array([math.gcd(int(f[i]),int(g[i])) for i in range(N)])
ax.plot(idx, f, 'b-', lw=1.5, label='6i+12')
ax.plot(idx, g, 'r-', lw=1.5, label='4i+8')
ax.plot(idx, d, 'k-', lw=2, label='gcd')
ax.set_title('GCD Transfer'); ax.legend(); ax.grid(True, alpha=0.3)

ax = axes[1,1]
for n in [5,15,30,50]:
    ax.fill_between(idx, 0, (idx>n).astype(float)*0.8, alpha=0.15, label=f'P(·,{n})')
ax.plot(idx, np.maximum(idx-1,0)/N, 'k-', lw=2, label='overspill f')
ax.set_title('Overspill Principle'); ax.legend(fontsize=8); ax.grid(True, alpha=0.3)

plt.tight_layout(); plt.savefig('ultrapower_elements.png', dpi=150); plt.close()