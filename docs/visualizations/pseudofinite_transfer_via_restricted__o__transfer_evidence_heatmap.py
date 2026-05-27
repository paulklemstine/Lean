#!/usr/bin/env python3
"""
Visualization: Transfer Evidence Heatmap

Shows a heatmap of doubling ratios across different definable families
and field sizes, illustrating the pattern of bounded growth that the
transfer principle predicts should persist to the pseudofinite limit.
"""

import itertools
from dataclasses import dataclass

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i+2) == 0: return False
        i += 6
    return True


@dataclass(frozen=True)
class M2:
    a: int; b: int; c: int; d: int; p: int
    def __mul__(self, o):
        p = self.p
        return M2((self.a*o.a+self.b*o.c)%p,(self.a*o.b+self.b*o.d)%p,
                   (self.c*o.a+self.d*o.c)%p,(self.c*o.b+self.d*o.d)%p,p)


def doubling(A):
    if not A: return 0
    return len({x*y for x in A for y in A})/len(A)


# Define 6 families
def f1(p):  # Unipotent squares
    seen=set(); r=[]
    for t in range(p):
        t2=(t*t)%p; k=(1,t2,0,1)
        if k not in seen: seen.add(k); r.append(M2(1,t2,0,1,p))
    return r

def f2(p):  # Borel trace=1
    r=[]
    for a in range(p):
        d=(1-a)%p
        if (a*d)%p==0: continue
        for b in range(p): r.append(M2(a,b,0,d,p))
    return r

def f3(p):  # Scalar-unipotent
    seen=set(); r=[]
    for t in range(1,p):
        a=(t*t)%p
        for b in range(p):
            ab=(a*b)%p; k=(a,ab,0,a)
            if k not in seen: seen.add(k); r.append(M2(a,ab,0,a,p))
    return r

def f4(p):  # Unipotent (full)
    return [M2(1,b,0,1,p) for b in range(p)]

def f5(p):  # Diagonal (torus)
    return [M2(a,0,0,d,p) for a in range(1,p) for d in range(1,p)]

def f6(p):  # Unipotent cubes
    seen=set(); r=[]
    for t in range(p):
        t3=(t*t*t)%p; k=(1,t3,0,1)
        if k not in seen: seen.add(k); r.append(M2(1,t3,0,1,p))
    return r


families = [
    ("Unipotent t²", f1),
    ("Borel tr=1", f2),
    ("Scalar-unip", f3),
    ("Unipotent", f4),
    ("Torus", f5),
    ("Unipotent t³", f6),
]

primes = [p for p in range(3, 24) if is_prime(p)]

# Compute heatmap data
heatmap = np.zeros((len(families), len(primes)))
for i, (name, fn) in enumerate(families):
    for j, p in enumerate(primes):
        A = fn(p)
        heatmap[i, j] = doubling(A) if A else 0

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

# Heatmap of doubling ratios
im = ax1.imshow(heatmap, aspect='auto', cmap='YlOrRd', vmin=1, vmax=12)
ax1.set_xticks(range(len(primes)))
ax1.set_xticklabels(primes)
ax1.set_yticks(range(len(families)))
ax1.set_yticklabels([n for n, _ in families], fontsize=9)
ax1.set_xlabel("Prime p", fontsize=12)
ax1.set_title("Doubling Ratios |A²|/|A|", fontsize=13)
plt.colorbar(im, ax=ax1, label="Doubling ratio")

# Annotate cells
for i in range(len(families)):
    for j in range(len(primes)):
        val = heatmap[i, j]
        color = 'white' if val > 6 else 'black'
        ax1.text(j, i, f"{val:.1f}", ha='center', va='center',
                fontsize=7, color=color)

# Bar chart: max doubling ratio per family
max_ratios = [max(heatmap[i, :]) for i in range(len(families))]
colors = ['green' if r < 3 else 'orange' if r < 8 else 'red' for r in max_ratios]
bars = ax2.barh(range(len(families)), max_ratios, color=colors, alpha=0.7)
ax2.set_yticks(range(len(families)))
ax2.set_yticklabels([n for n, _ in families], fontsize=9)
ax2.set_xlabel("Max Doubling Ratio", fontsize=12)
ax2.set_title("Worst-Case Growth by Family", fontsize=13)
ax2.axvline(x=2, color='green', linestyle='--', alpha=0.5, label='K=2')
ax2.axvline(x=5, color='orange', linestyle='--', alpha=0.5, label='K=5')
ax2.legend(fontsize=9)

for i, v in enumerate(max_ratios):
    ax2.text(v + 0.1, i, f"{v:.1f}", va='center', fontsize=9)

plt.suptitle("Pseudofinite Transfer: Growth Evidence Across Definable Families",
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig("transfer_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved transfer_heatmap.png")
