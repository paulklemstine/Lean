"""
Visualization: Certification Density Heatmap

Heatmap showing which algebraic fingerprint combinations lead to successful
certification across different field sizes. Tests the Certification Density
Conjecture.

This script is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iterproduct


# ─── Inline classes ──────────────────────────────────────────────────────────

class FF:
    def __init__(self, q): self.q = q
    def inv(self, a): return pow(a, self.q-2, self.q)
    def order(self, a):
        if a%self.q==0: return 0
        v=1
        for k in range(1,self.q):
            v=(v*a)%self.q
            if v==1: return k
        return self.q-1

class GL2:
    def __init__(self, q):
        self.f=FF(q); self.q=q; self._o=(q*q-1)*(q*q-q)
    @property
    def go(self): return self._o
    def mat(self,a,b,c,d):
        return np.array([[a%self.q,b%self.q],[c%self.q,d%self.q]],dtype=int)
    def det(self,m):
        return (int(m[0,0])*int(m[1,1])-int(m[0,1])*int(m[1,0]))%self.q
    def is_inv(self,m): return self.det(m)!=0
    def mul_m(self,a,b):
        q=self.q;r=np.zeros((2,2),dtype=int)
        for i in range(2):
            for j in range(2):
                r[i,j]=(int(a[i,0])*int(b[0,j])+int(a[i,1])*int(b[1,j]))%q
        return r
    def inv_m(self,m):
        d=self.det(m);di=self.f.inv(d);q=self.q
        return np.array([[(int(m[1,1])*di)%q,((-int(m[0,1]))*di)%q],
                         [((-int(m[1,0]))*di)%q,(int(m[0,0])*di)%q]],dtype=int)
    def eye(self): return np.array([[1,0],[0,1]],dtype=int)
    def eq(self,a,b): return np.all(a%self.q==b%self.q)
    def t(self,m):
        return (int(m[0,0])%self.q,int(m[0,1])%self.q,
                int(m[1,0])%self.q,int(m[1,1])%self.q)
    def is_irred(self,m):
        tr=(int(m[0,0])+int(m[1,1]))%self.q; d=self.det(m)
        disc=(tr*tr-4*d)%self.q
        if disc==0: return False
        if self.q==2: return False
        return pow(disc,(self.q-1)//2,self.q)!=1
    def is_prim(self,m):
        d=self.det(m)
        if d%self.q==0: return False
        return self.f.order(d)==self.q-1
    def all(self):
        q=self.q;e=[]
        for a,b,c,d in iterproduct(range(q),repeat=4):
            m=self.mat(a,b,c,d)
            if self.is_inv(m): e.append(m)
        return e

def gen_check(gl, g, h):
    S=set();gi=gl.inv_m(g);hi=gl.inv_m(h)
    gens=[g,gi,h,hi]
    for gen in gens: S.add(gl.t(gen))
    for _ in range(gl.go+1):
        nf=[]
        for et in list(S):
            elem=gl.mat(et[0],et[1],et[2],et[3])
            for gen in gens:
                prod=gl.mul_m(elem,gen)
                tt=gl.t(prod)
                if tt not in S: S.add(tt); nf.append(prod)
        if not nf: break
    return len(S)==gl.go


# ─── Compute certification statistics ───────────────────────────────────────

primes = [3, 5, 7]
categories = ['Neither', 'Irred only', 'Prim only', 'Both']
n_samples = 80

data = np.zeros((len(primes), len(categories)))
gen_data = np.zeros((len(primes), len(categories)))

for qi, q in enumerate(primes):
    gl = GL2(q)
    elems = gl.all()
    rng = np.random.RandomState(2024 + q)

    counts = {cat: {'total': 0, 'gen': 0} for cat in categories}

    for _ in range(n_samples):
        i1, i2 = rng.randint(len(elems), size=2)
        g, h = elems[i1], elems[i2]
        if gl.eq(g, gl.eye()) or gl.eq(h, gl.eye()):
            continue

        irr = gl.is_irred(g) or gl.is_irred(h)
        prim = gl.is_prim(g) or gl.is_prim(h)

        if irr and prim:
            cat = 'Both'
        elif irr:
            cat = 'Irred only'
        elif prim:
            cat = 'Prim only'
        else:
            cat = 'Neither'

        counts[cat]['total'] += 1
        if gen_check(gl, g, h):
            counts[cat]['gen'] += 1

    for ci, cat in enumerate(categories):
        total = counts[cat]['total']
        gen_count = counts[cat]['gen']
        data[qi, ci] = total
        gen_data[qi, ci] = gen_count / total * 100 if total > 0 else 0


# ─── Plot ────────────────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Panel 1: Distribution of algebraic fingerprints
x = np.arange(len(primes))
width = 0.2
for ci, cat in enumerate(categories):
    axes[0].bar(x + ci * width, data[:, ci], width, label=cat, alpha=0.8)

axes[0].set_xlabel('Field Size q', fontsize=12)
axes[0].set_ylabel('Count (out of samples)', fontsize=12)
axes[0].set_title('Distribution of Algebraic Fingerprints\nin Random Pairs', fontsize=11)
axes[0].set_xticks(x + 1.5 * width)
axes[0].set_xticklabels([f'𝔽_{q}' for q in primes])
axes[0].legend(fontsize=9)
axes[0].grid(True, alpha=0.3, axis='y')

# Panel 2: Generation rate by category
colors = ['#d62728', '#ff7f0e', '#2ca02c', '#1f77b4']
bar_positions = np.arange(len(categories))
for qi, q in enumerate(primes):
    offset = (qi - 1) * 0.25
    bars = axes[1].bar(bar_positions + offset, gen_data[qi, :], 0.22,
                        label=f'q={q}', alpha=0.8)

axes[1].set_xlabel('Algebraic Certificate Category', fontsize=12)
axes[1].set_ylabel('Generation Rate (%)', fontsize=12)
axes[1].set_title('Probability of Generating GL₂(𝔽_q)\nby Certificate Category', fontsize=11)
axes[1].set_xticks(bar_positions)
axes[1].set_xticklabels(categories, fontsize=9)
axes[1].legend(fontsize=9)
axes[1].grid(True, alpha=0.3, axis='y')
axes[1].set_ylim(0, 105)

plt.tight_layout()
plt.savefig('certification_density.png', dpi=150, bbox_inches='tight')
print("Saved certification_density.png")
