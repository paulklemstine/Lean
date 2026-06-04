import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import comb, log2

def tower(b, k):
    if k == 0: return 1
    return b ** tower(b, k-1)

def prob_lower(k):
    t = 2**comb(k,3)
    n = k
    while 2*comb(n,k) < t: n += 1
    return n-1

ks = range(3,12)
pb = [prob_lower(k) for k in ks]
se = [k**2/6 for k in ks]
fig, ax = plt.subplots(figsize=(10,6))
ax.plot(list(ks), [log2(max(b,1)) for b in pb], 'bo-', label='Prob bound (log2)', lw=2)
ax.plot(list(ks), se, 'r--', label='k^2/6 reference', lw=2)
ax.set_xlabel('k'); ax.set_ylabel('log2(bound)'); ax.set_title('Probabilistic Lower Bounds for R_3(k,k)')
ax.legend(); ax.grid(True, alpha=0.3)
plt.savefig('prob_bounds.png', dpi=150); plt.close()
print('Saved prob_bounds.png')