#!/usr/bin/env python3
"""
Visualization: Doubling Ratios of Definable Families over Finite Fields

Visualizes how the doubling ratio |A²|/|A| behaves for three families of
polynomially definable subsets of GL(2, F_p) as p grows. The bounded
behavior supports the pseudofinite transfer conjecture: if doubling is
bounded for ultrafilter-many primes, the pseudofinite limit inherits
bounded growth.
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
    AA = {x*y for x in A for y in A}
    return len(AA)/len(A)


def fam_unip(p):
    seen = set(); r = []
    for t in range(p):
        t2=(t*t)%p; k=(1,t2,0,1)
        if k not in seen: seen.add(k); r.append(M2(1,t2,0,1,p))
    return r

def fam_borel(p):
    r = []
    for a in range(p):
        d=(1-a)%p
        if (a*d)%p==0: continue
        for b in range(p):
            r.append(M2(a,b,0,d,p))
    return r

def fam_scalar(p):
    seen=set(); r=[]
    for t in range(1,p):
        a=(t*t)%p
        for b in range(p):
            ab=(a*b)%p; k=(a,ab,0,a)
            if k not in seen: seen.add(k); r.append(M2(a,ab,0,a,p))
    return r


primes = [p for p in range(3, 30) if is_prime(p)]

data = {}
for name, fn in [("Unipotent [[1,t²],[0,1]]", fam_unip),
                 ("Borel trace=1", fam_borel),
                 ("Scalar-unipotent [[t²,t²b],[0,t²]]", fam_scalar)]:
    ds = []
    sizes = []
    for p in primes:
        A = fn(p)
        ds.append(doubling(A))
        sizes.append(len(A))
    data[name] = {"doubling": ds, "sizes": sizes}

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Doubling ratios
ax = axes[0]
for name, d in data.items():
    ax.plot(primes, d["doubling"], 'o-', label=name, markersize=5)
ax.set_xlabel("Prime p", fontsize=12)
ax.set_ylabel("|A²| / |A|", fontsize=12)
ax.set_title("Doubling Ratios vs Field Size", fontsize=13)
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)
ax.axhline(y=2, color='gray', linestyle='--', alpha=0.5, label='K=2')

# Plot 2: Set sizes
ax = axes[1]
for name, d in data.items():
    ax.plot(primes, d["sizes"], 's-', label=name, markersize=5)
ax.set_xlabel("Prime p", fontsize=12)
ax.set_ylabel("|A_p|", fontsize=12)
ax.set_title("Definable Set Sizes", fontsize=13)
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)
ax.set_yscale('log')

# Plot 3: Ratio of |A²| to |GL(2,F_p)|
ax = axes[2]
for name, d in data.items():
    gl2_sizes = [p*(p*p-1)*(p-1) for p in primes]
    product_sizes = [d["doubling"][i] * d["sizes"][i] for i in range(len(primes))]
    ratios = [ps/gs for ps, gs in zip(product_sizes, gl2_sizes)]
    ax.plot(primes, ratios, '^-', label=name, markersize=5)
ax.set_xlabel("Prime p", fontsize=12)
ax.set_ylabel("|A²| / |GL(2, F_p)|", fontsize=12)
ax.set_title("Product Set as Fraction of GL(2)", fontsize=13)
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)
ax.set_yscale('log')

plt.suptitle("Pseudofinite Transfer: Definable Growth in GL(2, F_p)",
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("doubling_ratios.png", dpi=150, bbox_inches='tight')
print("Saved doubling_ratios.png")
