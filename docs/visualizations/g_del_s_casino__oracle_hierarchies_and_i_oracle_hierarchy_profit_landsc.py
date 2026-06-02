#!/usr/bin/env python3
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def generate_layered_casino(n=200, layers=8, seed=42):
    rng = np.random.RandomState(seed)
    dec = np.zeros((layers, n), dtype=bool)
    for k in range(layers):
        if k == 0:
            idx = rng.choice(n, size=int(0.2*n), replace=False)
            dec[0, idx] = True
        else:
            dec[k] = dec[k-1].copy()
            rem = np.where(~dec[k])[0]
            new = min(int(0.15*n), len(rem))
            if new > 0:
                dec[k, rng.choice(rem, size=new, replace=False)] = True
    return dec

dec = generate_layered_casino()
fig, ax = plt.subplots(figsize=(8, 5))
ax.bar(range(8), dec.sum(axis=1), color='#2ecc71')
ax.set_xlabel('Oracle Layer')
ax.set_ylabel('Profit')
ax.set_title('Layer Profit Monotonicity')
plt.tight_layout()
plt.savefig('oracle_hierarchy.png', dpi=150)
print('Saved oracle_hierarchy.png')
