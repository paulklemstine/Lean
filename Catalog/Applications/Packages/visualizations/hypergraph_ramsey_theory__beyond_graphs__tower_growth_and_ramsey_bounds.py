import matplotlib.pyplot as plt
import numpy as np
from math import comb

def tower(k, n):
    if k == 0: return n
    prev = tower(k-1, n)
    if prev > 1000: return float('inf')
    return 2 ** prev

def prob_lower_bound(k, r):
    if k < r: return k
    ckr = comb(k, r)
    if ckr > 60: return 2**(ckr//k)
    threshold = 2**ckr
    lo, hi = k, min(threshold, 10**15)
    while lo < hi:
        mid = (lo+hi+1)//2
        try:
            if 2*comb(mid,k) < threshold: lo = mid
            else: hi = mid-1
        except: hi = mid-1
    return lo

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Hypergraph Ramsey Theory: Growth Rates', fontsize=14, fontweight='bold')
ax1 = axes[0,0]
ns = list(range(1,8))
for k in range(4):
    vals = []
    for n in ns:
        v = tower(k, n)
        if v == float('inf'): break
        vals.append(np.log2(max(v, 1)))
    ax1.plot(ns[:len(vals)], vals, 'o-', label=f'tower({k},n)', linewidth=2)
ax1.set_xlabel('n'); ax1.set_ylabel('log2(tower(k,n))'); ax1.set_title('Tower Function'); ax1.legend(); ax1.grid(True, alpha=0.3)
ax2 = axes[0,1]
ks = list(range(3,12))
for r, color, marker in [(2,'blue','s'), (3,'red','D'), (4,'green','^')]:
    bounds, valid_ks = [], []
    for k in ks:
        if k >= r:
            lb = prob_lower_bound(k, r)
            if lb < 10**12: bounds.append(np.log2(max(lb,1))); valid_ks.append(k)
    ax2.plot(valid_ks, bounds, f'{marker}-', color=color, label=f'R_{r}(k,k)', linewidth=2)
ax2.set_xlabel('k'); ax2.set_ylabel('log2(bound)'); ax2.set_title('Probabilistic Lower Bounds'); ax2.legend(); ax2.grid(True, alpha=0.3)
ax3 = axes[1,0]
for r in [2,3,4,5]:
    vals = [comb(k,r) if k>=r else 0 for k in ks]
    ax3.plot(ks, vals, 'o-', label=f'C(k,{r})', linewidth=2)
ax3.set_xlabel('k'); ax3.set_ylabel('C(k,r)'); ax3.set_title('Hyperedge Count'); ax3.legend(); ax3.grid(True, alpha=0.3); ax3.set_yscale('log')
ax4 = axes[1,1]
ks2 = np.arange(3,10)
ax4.semilogy(ks2, 2.0**(ks2/2), 'bs-', label='r=2: 2^{k/2}', linewidth=2)
ax4.semilogy(ks2, 2.0**(ks2**2/6), 'rD-', label='r=3: 2^{k²/6}', linewidth=2)
ax4.set_xlabel('k'); ax4.set_ylabel('bound'); ax4.set_title('Growth Hierarchy'); ax4.legend(fontsize=8); ax4.grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig('hypergraph_ramsey_growth.png', dpi=150, bbox_inches='tight'); plt.close()
print('Saved: hypergraph_ramsey_growth.png')