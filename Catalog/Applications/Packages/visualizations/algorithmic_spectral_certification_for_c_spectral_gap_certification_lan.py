"""
Visualization: Spectral Gap Certification Landscape

Visualizes the relationship between certified gap bounds and true spectral gaps
for generating pairs in GL₂(𝔽_q). Shows that certified bounds are conservative
but correctly identify good expanders.

This script is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iterproduct


# ─── Inline all needed functions ─────────────────────────────────────────────

class FiniteField:
    def __init__(self, q): self.q = q
    def mul(self, a, b): return (a*b)%self.q
    def inv(self, a): return pow(a, self.q-2, self.q)
    def order(self, a):
        if a%self.q==0: return 0
        v=1
        for k in range(1,self.q):
            v=(v*a)%self.q
            if v==1: return k
        return self.q-1

class GL2Fq:
    def __init__(self, q):
        self.f=FiniteField(q); self.q=q
        self._ord=(q*q-1)*(q*q-q)
    @property
    def group_order(self): return self._ord
    def mat(self,a,b,c,d):
        return np.array([[a%self.q,b%self.q],[c%self.q,d%self.q]],dtype=int)
    def det(self,m):
        return (int(m[0,0])*int(m[1,1])-int(m[0,1])*int(m[1,0]))%self.q
    def is_inv(self,m): return self.det(m)!=0
    def mul_mat(self,a,b):
        q=self.q;r=np.zeros((2,2),dtype=int)
        for i in range(2):
            for j in range(2):
                r[i,j]=(int(a[i,0])*int(b[0,j])+int(a[i,1])*int(b[1,j]))%q
        return r
    def inv_mat(self,m):
        d=self.det(m);di=self.f.inv(d);q=self.q
        return np.array([[(int(m[1,1])*di)%q,((-int(m[0,1]))*di)%q],
                         [((-int(m[1,0]))*di)%q,(int(m[0,0])*di)%q]],dtype=int)
    def identity(self): return np.array([[1,0],[0,1]],dtype=int)
    def mat_eq(self,a,b): return np.all(a%self.q==b%self.q)
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

def generates(gl, g, h):
    S=set();gi=gl.inv_mat(g);hi=gl.inv_mat(h)
    gens=[g,gi,h,hi]
    for gen in gens: S.add(gl.t(gen))
    for _ in range(gl.group_order+1):
        nf=[]
        for et in list(S):
            elem=gl.mat(et[0],et[1],et[2],et[3])
            for gen in gens:
                prod=gl.mul_mat(elem,gen)
                tt=gl.t(prod)
                if tt not in S: S.add(tt); nf.append(prod)
        if not nf: break
    return len(S)==gl.group_order

def spectral_gap(gl, g, h):
    elems=gl.all(); n=len(elems)
    idx={gl.t(m):i for i,m in enumerate(elems)}
    gi=gl.inv_mat(g);hi=gl.inv_mat(h)
    gens=[g,gi,h,hi]
    adj=np.zeros((n,n))
    for i,m in enumerate(elems):
        for gen in gens:
            prod=gl.mul_mat(m,gen)
            j=idx[gl.t(prod)]
            adj[i,j]+=0.25
    eigs=sorted(np.linalg.eigvalsh(adj),reverse=True)
    return 1.0-eigs[1] if len(eigs)>=2 else 0.0


# ─── Generate Data ───────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Certified bound vs true gap for q=3,5
for qi, q in enumerate([3, 5]):
    gl = GL2Fq(q)
    elems = gl.all()
    rng = np.random.RandomState(42 + q)

    true_gaps = []
    cert_bounds = []
    colors = []

    n_samples = 40
    for _ in range(n_samples):
        i1, i2 = rng.randint(len(elems), size=2)
        g, h = elems[i1], elems[i2]
        if gl.mat_eq(g, gl.identity()) or gl.mat_eq(h, gl.identity()):
            continue
        gen = generates(gl, g, h)
        if not gen:
            continue

        tg = spectral_gap(gl, g, h)
        irr = gl.is_irred(g) or gl.is_irred(h)
        prim = gl.is_prim(g) or gl.is_prim(h)

        if irr and prim:
            cb = 2.0 / (q * (q + 1))
        else:
            cb = 1.0 / gl.group_order

        true_gaps.append(tg)
        cert_bounds.append(cb)
        colors.append('tab:blue' if irr and prim else 'tab:orange')

    ax = axes[0]
    if q == 3:
        marker = 'o'
    else:
        marker = 's'
    for tg, cb, c in zip(true_gaps, cert_bounds, colors):
        ax.scatter(tg, cb, c=c, marker=marker, s=40, alpha=0.7,
                   edgecolors='black', linewidths=0.5)

# Diagonal line
axes[0].plot([0, 1], [0, 1], 'k--', alpha=0.3, label='y = x')
axes[0].set_xlabel('True Spectral Gap', fontsize=12)
axes[0].set_ylabel('Certified Lower Bound', fontsize=12)
axes[0].set_title('Certified Bound vs True Gap\n(●=𝔽₃, ■=𝔽₅, blue=Irr+Prim)', fontsize=11)
axes[0].legend(fontsize=10)
axes[0].set_xlim(-0.02, 0.5)
axes[0].set_ylim(-0.02, 0.5)
axes[0].grid(True, alpha=0.3)

# Panel 2: Eigenvalue spectrum comparison
for qi, q in enumerate([3, 5]):
    gl = GL2Fq(q)
    # Use a known generating pair
    prim = 2
    for r in range(2, q):
        if gl.f.order(r) == q - 1:
            prim = r; break
    g = gl.mat(prim, 1, 0, 1)
    h = gl.mat(1, 0, 1, 1)

    elems = gl.all(); n = len(elems)
    idx = {gl.t(m): i for i, m in enumerate(elems)}
    gi = gl.inv_mat(g); hi = gl.inv_mat(h)
    gens = [g, gi, h, hi]
    adj = np.zeros((n, n))
    for i, m in enumerate(elems):
        for gen in gens:
            prod = gl.mul_mat(m, gen)
            j = idx[gl.t(prod)]
            adj[i, j] += 0.25
    eigs = sorted(np.linalg.eigvalsh(adj), reverse=True)

    ax = axes[1]
    ax.plot(range(len(eigs)), eigs, label=f'q={q} (n={n})',
            linewidth=1.5, alpha=0.8)
    # Mark spectral gap
    gap = 1.0 - eigs[1]
    ax.axhline(y=eigs[1], color='gray', linestyle=':', alpha=0.5)

axes[1].set_xlabel('Eigenvalue Index', fontsize=12)
axes[1].set_ylabel('Eigenvalue', fontsize=12)
axes[1].set_title('Eigenvalue Spectrum of Certified\nCayley Graphs', fontsize=11)
axes[1].legend(fontsize=10)
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('spectral_gap_certification.png', dpi=150, bbox_inches='tight')
print("Saved spectral_gap_certification.png")
