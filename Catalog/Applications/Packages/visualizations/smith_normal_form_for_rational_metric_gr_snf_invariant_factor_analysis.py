"""
Visualization: Smith Normal Form Invariant Factors

Compares SNF invariant factor distributions across different cycle graph
families. Shows how the invariant factors grow with graph size and how
the product-of-invariants identity det(M) = ∏ dᵢ holds exactly.

This visualization demonstrates the arithmetic bridge: rational metric
data → integer matrix → SNF decomposition → finite group classification.
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
fig.suptitle('Smith Normal Form Invariant Factors of Cycle Graph Laplacians',
             fontsize=14, fontweight='bold')

# Panel 1: Unit-weight cycles — invariant factors vs n
sizes = list(range(3, 12))
all_factors = []
all_dets = []
for n in sizes:
    lengths = [Fraction(1)] * n
    adj = [(i, (i+1)%n) for i in range(n)]
    ld = {e: lengths[i] for i, e in enumerate(adj)}
    L = weighted_laplacian_Q(n, adj, ld)
    Lr = reduced_lap(L)
    D, M = scale_int(Lr)
    diag = snf(M)
    det_val = det_frac(M)
    all_factors.append(diag)
    all_dets.append(abs(det_val))

ax = axes[0]
for idx, n in enumerate(sizes):
    factors = [d for d in all_factors[idx] if d > 0]
    ax.scatter([n]*len(factors), [log10(max(f, 1)) for f in factors],
              c='steelblue', alpha=0.7, s=40)
ax.plot(sizes, [log10(max(d, 1)) for d in all_dets], 'r-o', label='log₁₀|det|',
       markersize=5, linewidth=2)
ax.set_xlabel('Number of vertices n')
ax.set_ylabel('log₁₀(value)')
ax.set_title('Unit-weight Cₙ')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 2: Prime-reciprocal cycles — determinant growth
primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
sizes2 = list(range(3, 9))
dets_prime = []
for n in sizes2:
    lengths = [Fraction(1, primes[i]) for i in range(n)]
    adj = [(i, (i+1)%n) for i in range(n)]
    ld = {e: lengths[i] for i, e in enumerate(adj)}
    L = weighted_laplacian_Q(n, adj, ld)
    Lr = reduced_lap(L)
    D, M = scale_int(Lr)
    det_val = det_frac(M)
    dets_prime.append(abs(det_val))
    diag = snf(M)
    print(f"C_{n} prime-reciprocal: D={D}, diag={diag}, det={det_val}")

ax = axes[1]
ax.bar(sizes2, [log10(max(d, 1)) for d in dets_prime],
       color='coral', alpha=0.8, edgecolor='darkred')
ax.set_xlabel('Number of vertices n')
ax.set_ylabel('log₁₀|det(M)|')
ax.set_title('Prime-reciprocal lengths Cₙ\nℓᵢ = 1/pᵢ')
ax.grid(True, alpha=0.3, axis='y')

# Panel 3: Product identity verification
ax = axes[2]
# For several random graphs, plot ∏dᵢ vs |det|
import random
random.seed(2025)
products = []
dets_rand = []
for _ in range(30):
    n = random.randint(3, 7)
    lengths = [Fraction(random.randint(1, 10), random.randint(1, 10)) for _ in range(n)]
    adj = [(i, (i+1)%n) for i in range(n)]
    ld = {e: lengths[i] for i, e in enumerate(adj)}
    L = weighted_laplacian_Q(n, adj, ld)
    Lr = reduced_lap(L)
    D, M = scale_int(Lr)
    diag = snf(M)
    det_val = det_frac(M)
    prod_d = 1
    for d in diag: prod_d *= d
    products.append(abs(prod_d))
    dets_rand.append(abs(det_val))

max_val = max(max(products), max(dets_rand))
ax.scatter(dets_rand, products, c='forestgreen', alpha=0.7, s=50, zorder=5)
ax.plot([0, max_val*1.1], [0, max_val*1.1], 'k--', alpha=0.5, label='y = x')
ax.set_xlabel('|det(M)|')
ax.set_ylabel('∏ dᵢ (SNF invariants)')
ax.set_title('Product Identity Verification\n∏ dᵢ = |det(M)| for random graphs')
ax.legend()
ax.grid(True, alpha=0.3)
ax.set_aspect('equal')

plt.tight_layout()
plt.savefig('viz_snf_invariants.png', dpi=150, bbox_inches='tight')
print("Saved viz_snf_invariants.png")
