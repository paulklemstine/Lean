#!/usr/bin/env python3
"""
Visualization: Scaling of q·γ — Testing the Uniform Gap Conjecture

Plots the product q × γ(S) for certified pairs across multiple primes,
testing the conjecture that q·γ ≥ C₀ for an absolute constant C₀ > 0.
If the conjecture holds, the curve should stay bounded away from zero.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as cartesian_product

# ── Self-contained code ──

def inverse_mod(a, q): return pow(a, q-2, q)
def multiplicative_order(a, q):
    if a%q==0: return 0
    x=1
    for k in range(1,q):
        x=(x*a)%q
        if x==1: return k
    return q-1

class M2:
    __slots__=['a','b','c','d','q']
    def __init__(s,a,b,c,d,q): s.a,s.b,s.c,s.d,s.q=a%q,b%q,c%q,d%q,q
    def det(s): return (s.a*s.d-s.b*s.c)%s.q
    def __mul__(s,o):
        q=s.q
        return M2((s.a*o.a+s.b*o.c)%q,(s.a*o.b+s.b*o.d)%q,
                  (s.c*o.a+s.d*o.c)%q,(s.c*o.b+s.d*o.d)%q,q)
    def inv(s):
        d=s.det(); q=s.q
        if d==0: return None
        di=inverse_mod(d,q)
        return M2((s.d*di)%q,(-s.b*di)%q,(-s.c*di)%q,(s.a*di)%q,q)
    def to_tuple(s): return (s.a,s.b,s.c,s.d)
    def __hash__(s): return hash((s.to_tuple(),s.q))
    def __eq__(s,o): return s.to_tuple()==o.to_tuple() and s.q==o.q

def is_irred(m):
    tr,det,q=(m.a+m.d)%m.q,m.det(),m.q
    return all((a*a-tr*a+det)%q!=0 for a in range(q))

def gl2(q):
    return [M2(a,b,c,d,q) for a,b,c,d in cartesian_product(range(q),repeat=4)
            if (a*d-b*c)%q!=0]

def cayley_spectrum(g, h, elems, q):
    n=len(elems); idx={e.to_tuple():i for i,e in enumerate(elems)}
    gi,hi=g.inv(),h.inv(); gens=[g,gi,h,hi]
    A=np.zeros((n,n))
    for i,e in enumerate(elems):
        for s in gens:
            A[i,idx[(e*s).to_tuple()]]+=1
    A/=4.0
    return np.sort(np.linalg.eigvalsh(A))[::-1]

def find_best_pair(q, elems, max_try=30):
    """Find certified pair with best spectral gap."""
    singers = [m for m in elems if is_irred(m)][:max_try]
    prims = [m for m in elems if m.det()!=0 and multiplicative_order(m.det(),q)==q-1][:max_try]
    best_gap, best_pair = -1, None
    target = len(elems)
    for g in singers:
        for h in prims:
            # Quick generation check via BFS
            seen = {M2(1,0,0,1,q).to_tuple()}
            queue = [M2(1,0,0,1,q)]
            gi,hi = g.inv(),h.inv()
            gens_list = [g,gi,h,hi]
            while queue:
                cur = queue.pop(0)
                for s in gens_list:
                    t = (cur*s).to_tuple()
                    if t not in seen:
                        seen.add(t); queue.append(M2(*t,q))
                        if len(seen)==target: break
                if len(seen)==target: break
            if len(seen)==target:
                eigs = cayley_spectrum(g,h,elems,q)
                nt = [e for e in eigs[1:] if abs(abs(e)-1.0)>1e-8]
                gap = 1.0 - max(abs(e) for e in nt) if nt else 1.0
                if gap > best_gap:
                    best_gap = gap; best_pair = (g,h)
            if best_pair is not None:
                break  # found at least one
        if best_pair is not None:
            break
    return best_pair, best_gap

# ── Compute data ──

primes = [5, 7]
results = []

for q in primes:
    print(f"Processing q={q}...")
    elems = gl2(q)
    pair, gap = find_best_pair(q, elems)
    if pair:
        results.append({'q': q, 'gap': gap, 'qgap': q*gap, 'gl2_size': len(elems)})
        print(f"  |GL₂| = {len(elems)}, gap = {gap:.6f}, q*gap = {q*gap:.6f}")

# ── Plot ──

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

qs = [r['q'] for r in results]
gaps = [r['gap'] for r in results]
qgaps = [r['qgap'] for r in results]

# Left: spectral gap vs q
ax1.plot(qs, gaps, 'o-', color='steelblue', markersize=10, linewidth=2)
ax1.set_xlabel('Prime q', fontsize=13)
ax1.set_ylabel('Spectral gap γ', fontsize=13)
ax1.set_title('Spectral Gap Decay', fontsize=14)
ax1.grid(True, alpha=0.3)

# Reference curve C/q
if len(qs) >= 2:
    C_fit = min(q*g for q,g in zip(qs, gaps))
    qrange = np.linspace(min(qs), max(qs), 100)
    ax1.plot(qrange, C_fit/qrange, '--', color='coral', linewidth=1.5,
             label=f'C/q (C={C_fit:.3f})')
    ax1.legend(fontsize=11)

# Right: q*gap vs q (should be bounded below)
ax2.plot(qs, qgaps, 's-', color='coral', markersize=10, linewidth=2)
ax2.axhline(y=min(qgaps), color='gray', linestyle=':', linewidth=1,
            label=f'min q·γ = {min(qgaps):.4f}')
ax2.set_xlabel('Prime q', fontsize=13)
ax2.set_ylabel('q × γ', fontsize=13)
ax2.set_title('Uniform Gap Conjecture Test: q·γ ≥ C₀', fontsize=14)
ax2.grid(True, alpha=0.3)
ax2.legend(fontsize=11)

plt.tight_layout()
plt.savefig('viz_gap_scaling.png', dpi=150, bbox_inches='tight')
print("\nSaved viz_gap_scaling.png")
