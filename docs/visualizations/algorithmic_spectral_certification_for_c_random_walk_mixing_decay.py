"""
Visualization: Random Walk Mixing on Certified Cayley Graphs

Shows how the random walk distribution converges to uniform on Cayley graphs
of GL₂(𝔽_q), with convergence rate controlled by the certified spectral gap.

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
    def t(self,m):
        return (int(m[0,0])%self.q,int(m[0,1])%self.q,
                int(m[1,0])%self.q,int(m[1,1])%self.q)
    def all(self):
        q=self.q;e=[]
        for a,b,c,d in iterproduct(range(q),repeat=4):
            m=self.mat(a,b,c,d)
            if self.det(m)!=0: e.append(m)
        return e


# ─── Generate mixing data ───────────────────────────────────────────────────

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

for qi, q in enumerate([3, 5]):
    gl = GL2(q)
    # Find primitive root
    prim = 2
    for r in range(2, q):
        if gl.f.order(r) == q-1: prim = r; break

    g = gl.mat(prim, 1, 0, 1)
    h = gl.mat(1, 0, 1, 1)

    elems = gl.all(); n = len(elems)
    idx = {gl.t(m): i for i, m in enumerate(elems)}

    gi = gl.inv_m(g); hi = gl.inv_m(h)
    gens = [g, gi, h, hi]

    # Build transition matrix
    P = np.zeros((n, n))
    for i, m in enumerate(elems):
        for gen in gens:
            prod = gl.mul_m(m, gen)
            j = idx[gl.t(prod)]
            P[i, j] += 0.25

    # Compute spectral gap
    eigs = sorted(np.linalg.eigvalsh(P), reverse=True)
    gap = 1.0 - eigs[1]
    alpha = eigs[1]

    # Simulate random walk from identity
    uniform = np.ones(n) / n
    dist = np.zeros(n)
    dist[0] = 1.0  # Start at identity

    T = 40
    tv_dist = []
    l2_dist = []

    for t in range(T):
        tv = 0.5 * np.sum(np.abs(dist - uniform))
        l2 = np.sqrt(np.sum((dist - uniform)**2))
        tv_dist.append(tv)
        l2_dist.append(l2)
        dist = dist @ P

    # Panel 1: TV distance decay
    ax = axes[0]
    ax.semilogy(range(T), tv_dist, linewidth=2, label=f'q={q}, gap={gap:.3f}')
    # Theoretical bound
    theory = [np.sqrt(n) * alpha**t for t in range(T)]
    ax.semilogy(range(T), theory, '--', linewidth=1.5, alpha=0.5,
                label=f'q={q} bound √n·α^t')

    # Panel 2: L² distance decay
    ax2 = axes[1]
    ax2.semilogy(range(T), l2_dist, linewidth=2, label=f'q={q}, gap={gap:.3f}')
    theory_l2 = [np.sqrt(n) * alpha**t for t in range(T)]
    ax2.semilogy(range(T), theory_l2, '--', linewidth=1.5, alpha=0.5,
                 label=f'q={q} bound')

axes[0].set_xlabel('Random Walk Steps', fontsize=12)
axes[0].set_ylabel('Total Variation Distance', fontsize=12)
axes[0].set_title('Mixing of Random Walk on Cay(GL₂(𝔽_q))\n(solid=empirical, dashed=spectral bound)', fontsize=11)
axes[0].legend(fontsize=9)
axes[0].grid(True, alpha=0.3)
axes[0].axhline(y=0.25, color='red', linestyle=':', alpha=0.4, label='TV = 0.25')

axes[1].set_xlabel('Random Walk Steps', fontsize=12)
axes[1].set_ylabel('L² Distance from Uniform', fontsize=12)
axes[1].set_title('L² Mixing Decay\n(certified: ‖T^t f‖₂ ≤ α^t ‖f‖₂)', fontsize=11)
axes[1].legend(fontsize=9)
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('mixing_decay.png', dpi=150, bbox_inches='tight')
print("Saved mixing_decay.png")
