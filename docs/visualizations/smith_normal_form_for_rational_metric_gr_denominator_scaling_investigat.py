"""
Visualization: Denominator Scaling and Invariant Factor Behavior

Investigates the denominator-independence conjecture by plotting how
SNF invariant factors transform under different choices of the
clearing denominator D. Shows the scaling pattern D^(n-1) in the
determinant and the divisibility structure of invariant factors.

This directly tests the conjecture: after normalizing out the
D-scaling artifact, do the invariant factors encode a
denominator-independent arithmetic Jacobian?
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from fractions import Fraction
from math import gcd, log10
from functools import reduce

# ─── Inlined algorithms ──────────────────────────────────────────────────

def lcm(a, b): return abs(a*b)//gcd(a,b) if a and b else 0
def common_denom(fracs): return reduce(lcm, [f.denominator for f in fracs]) if fracs else 1

def weighted_laplacian_Q(n, adj, lengths):
    L = [[Fraction(0)]*n for _ in range(n)]
    for (i,j) in adj:
        c = Fraction(1)/lengths[(i,j)]
        L[i][j] -= c; L[j][i] -= c; L[i][i] += c; L[j][j] += c
    return L

def reduced_lap(L, base=0):
    n = len(L); idx = [i for i in range(n) if i != base]
    return [[L[i][j] for j in idx] for i in idx]

def scale_int(M):
    entries = [M[i][j] for i in range(len(M)) for j in range(len(M[0]))]
    D = common_denom(entries)
    return D, [[int(D*M[i][j]) for j in range(len(M[0]))] for i in range(len(M))]

def det_frac(M):
    n = len(M); A = [[Fraction(M[i][j]) for j in range(n)] for i in range(n)]
    d = Fraction(1)
    for c in range(n):
        p = next((r for r in range(c,n) if A[r][c] != 0), None)
        if p is None: return 0
        if p != c: A[c], A[p] = A[p], A[c]; d = -d
        d *= A[c][c]
        for r in range(c+1,n):
            f = A[r][c]/A[c][c]
            for j in range(c,n): A[r][j] -= f*A[c][j]
    return int(d)

def snf(M):
    m = len(M); n = len(M[0]) if m else 0
    A = [row[:] for row in M]
    def arm(t,s,f):
        for j in range(len(A[0])): A[t][j]+=f*A[s][j]
    def acm(t,s,f):
        for row in A: row[t]+=f*row[s]
    for k in range(min(m,n)):
        found = False
        for i in range(k,m):
            for j in range(k,n):
                if A[i][j] != 0:
                    if not found or abs(A[i][j]) < abs(A[k][k]):
                        if i!=k: A[k],A[i]=A[i],A[k]
                        if j!=k:
                            for row in A: row[k],row[j]=row[j],row[k]
                        found = True
        if not found: break
        ch = True
        while ch:
            ch = False
            for i in range(k+1,m):
                if A[i][k]!=0:
                    q=A[i][k]//A[k][k]; arm(i,k,-q)
                    if A[i][k]!=0: A[k],A[i]=A[i],A[k]; ch=True; break
            if ch: continue
            for j in range(k+1,n):
                if A[k][j]!=0:
                    q=A[k][j]//A[k][k]; acm(j,k,-q)
                    if A[k][j]!=0:
                        for row in A: row[k],row[j]=row[j],row[k]
                        ch=True; break
        if A[k][k]<0:
            for j in range(n): A[k][j]=-A[k][j]
    diag = [A[i][i] for i in range(min(m,n))]
    ch = True
    while ch:
        ch = False
        for i in range(len(diag)-1):
            if diag[i] and diag[i+1] and diag[i+1]%diag[i]:
                g = gcd(diag[i],diag[i+1])
                diag[i],diag[i+1] = g, abs(diag[i]*diag[i+1])//g
                ch = True
    return diag

# ─── Compute data ────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle('Denominator Scaling: How D Affects SNF Invariant Factors',
             fontsize=14, fontweight='bold')

# Graph: C₄ with rational lengths
n = 4
lengths = [Fraction(1,2), Fraction(2,3), Fraction(3,5), Fraction(4,7)]
adj = [(i, (i+1)%n) for i in range(n)]
ld = {e: lengths[i] for i, e in enumerate(adj)}
L = weighted_laplacian_Q(n, adj, ld)
Lr = reduced_lap(L)
D0, _ = scale_int(Lr)

multiples = list(range(1, 21))
all_diags = []
all_dets = []
all_Ds = []

for mult in multiples:
    D = D0 * mult
    M = [[int(D * Lr[i][j]) for j in range(n-1)] for i in range(n-1)]
    diag = snf(M)
    det_val = det_frac(M)
    all_diags.append(diag)
    all_dets.append(abs(det_val))
    all_Ds.append(D)

# Panel 1: Determinant vs D (should be D^(n-1) scaling)
ax = axes[0]
ax.plot(multiples, all_dets, 'bo-', markersize=5, linewidth=1.5, label='|det(M)|')
# Expected: D^(n-1) * det(L_red)
det_base = all_dets[0]
expected = [det_base * m**(n-1) for m in multiples]
ax.plot(multiples, expected, 'r--', linewidth=1.5, alpha=0.7, label=f'D₀^3 · m^{n-1} · τ')
ax.set_xlabel('Multiplier m (D = m · D₀)')
ax.set_ylabel('|det(D · L_red)|')
ax.set_title(f'Determinant Growth\nD₀ = {D0}')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 2: Largest invariant factor vs D
ax = axes[1]
colors = ['steelblue', 'coral', 'forestgreen']
for factor_idx in range(n-1):
    vals = [d[factor_idx] if factor_idx < len(d) else 0 for d in all_diags]
    ax.plot(multiples, vals, 'o-', color=colors[factor_idx % len(colors)],
           markersize=4, linewidth=1.5, label=f'd_{factor_idx+1}', alpha=0.8)
ax.set_xlabel('Multiplier m (D = m · D₀)')
ax.set_ylabel('Invariant factor value')
ax.set_title('Individual Invariant Factors')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 3: Normalized factors (divide by D)
ax = axes[2]
for factor_idx in range(n-1):
    vals = []
    for m_idx, mult in enumerate(multiples):
        D = all_Ds[m_idx]
        d_val = all_diags[m_idx][factor_idx] if factor_idx < len(all_diags[m_idx]) else 0
        # Normalize: divide by gcd(d, D)
        if d_val > 0 and D > 0:
            g = gcd(d_val, D)
            vals.append(d_val // g)
        else:
            vals.append(0)
    ax.plot(multiples, vals, 'o-', color=colors[factor_idx % len(colors)],
           markersize=4, linewidth=1.5, label=f'd_{factor_idx+1}/gcd(d_{factor_idx+1},D)',
           alpha=0.8)
ax.set_xlabel('Multiplier m (D = m · D₀)')
ax.set_ylabel('Normalized factor')
ax.set_title('Normalized Invariant Factors\n(testing denominator independence)')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_denominator_scaling.png', dpi=150, bbox_inches='tight')
print("Saved viz_denominator_scaling.png")
