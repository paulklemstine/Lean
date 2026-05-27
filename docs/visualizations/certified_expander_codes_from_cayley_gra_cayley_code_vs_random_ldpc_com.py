"""
Visualization: Cayley Code vs Random LDPC Performance Comparison

Plots block error rate curves for Cayley-based Tanner codes and random LDPC
codes under BSC, directly testing the Cayley-vs-random conjecture.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product
from collections import defaultdict

# ---- Inline all needed functions ----

def gf_mul(a, b, p): return (a * b) % p
def gf_inv(a, p): return pow(a, p - 2, p)

def mat_mul_2x2(A, B, p):
    C = np.zeros((2, 2), dtype=int)
    for i in range(2):
        for j in range(2):
            C[i, j] = sum(gf_mul(int(A[i, k]), int(B[k, j]), p) for k in range(2)) % p
    return C

def mat_det_2x2(M, p):
    return (gf_mul(int(M[0, 0]), int(M[1, 1]), p) - gf_mul(int(M[0, 1]), int(M[1, 0]), p)) % p

class GL2Fp:
    def __init__(self, p):
        self.p = p; self.elements = []; self.element_to_idx = {}; idx = 0
        for a, b, c, d in product(range(p), repeat=4):
            if (a * d - b * c) % p != 0:
                self.elements.append(np.array([[a, b], [c, d]], dtype=int))
                self.element_to_idx[(a, b, c, d)] = idx; idx += 1
    def order(self): return len(self.elements)
    def mat_to_idx(self, M):
        return self.element_to_idx[(int(M[0,0])%self.p, int(M[0,1])%self.p, int(M[1,0])%self.p, int(M[1,1])%self.p)]
    def multiply(self, i, j):
        return self.mat_to_idx(mat_mul_2x2(self.elements[i], self.elements[j], self.p))

def _primitive_root(p):
    if p == 2: return 1
    for g in range(2, p):
        order = p - 1; temp = order; factors = set(); d = 2
        while d * d <= temp:
            while temp % d == 0: factors.add(d); temp //= d
            d += 1
        if temp > 1: factors.add(temp)
        if all(pow(g, order // q, p) != 1 for q in factors): return g
    return 2

def standard_generators_gl2(p):
    g = _primitive_root(p)
    gens = [np.array([[1,1],[0,1]],dtype=int), np.array([[1,0],[1,1]],dtype=int), np.array([[g,0],[0,1]],dtype=int)]
    inv_gens = []
    for M in gens:
        det = mat_det_2x2(M, p); di = gf_inv(det, p)
        inv_gens.append(np.array([[gf_mul(int(M[1,1]),di,p), gf_mul((-int(M[0,1]))%p,di,p)],
                                   [gf_mul((-int(M[1,0]))%p,di,p), gf_mul(int(M[0,0]),di,p)]],dtype=int))
    all_g = gens + inv_gens; seen = set(); unique = []
    for M in all_g:
        k = tuple(M.flatten() % p)
        if k not in seen: seen.add(k); unique.append(M % p)
    return unique

def build_cayley_graph(group, generators):
    gi = [group.mat_to_idx(g) for g in generators]
    adj = defaultdict(set)
    for v in range(group.order()):
        for s in gi: adj[v].add(group.multiply(v, s))
    return dict(adj)

class TannerGraph:
    def __init__(self, ca, nv):
        self.n_left = nv; self.left_neighbors = {}; self.right_neighbors = defaultdict(set)
        for v in range(nv):
            nb = ca.get(v, set()); self.left_neighbors[v] = set(nb)
            for u in nb: self.right_neighbors[u].add(v)
        self.degree = len(next(iter(self.left_neighbors.values()))) if nv > 0 else 0
    def unique_neighbors(self, S):
        rc = defaultdict(int)
        for v in S:
            for r in self.left_neighbors.get(v, set()): rc[r] += 1
        return {r for r, c in rc.items() if c == 1}
    def correctable(self, E):
        u = self.unique_neighbors(E); result = set()
        for r in u:
            for v in self.right_neighbors[r]:
                if v in E: result.add(v); break
        return result

class RandomLDPC:
    def __init__(self, n, dv, dc, seed=42):
        self.n_var = n; self.n_check = n * dv // dc; self.d_v = dv; self.d_c = dc
        rng = np.random.RandomState(seed)
        vs = np.repeat(np.arange(n), dv)
        cs = np.repeat(np.arange(self.n_check), dc)
        if len(cs) < len(vs): cs = np.concatenate([cs, rng.choice(self.n_check, len(vs)-len(cs))])
        elif len(cs) > len(vs): cs = cs[:len(vs)]
        rng.shuffle(cs)
        self.var_neighbors = defaultdict(set); self.check_neighbors = defaultdict(set)
        for v, c in zip(vs, cs):
            self.var_neighbors[v].add(c); self.check_neighbors[c].add(v)
    def unique_neighbors(self, S):
        cc = defaultdict(int)
        for v in S:
            for c in self.var_neighbors[v]: cc[c] += 1
        return {c for c, cnt in cc.items() if cnt == 1}
    def correctable(self, E):
        u = self.unique_neighbors(E); r = set()
        for c in u:
            for v in self.check_neighbors[c]:
                if v in E: r.add(v); break
        return r

def peel_decode_tanner(tanner, error):
    current = set(error); history = [len(current)]
    for _ in range(len(error) + 1):
        if not current: break
        corr = tanner.correctable(current); new = current - corr
        history.append(len(new))
        if len(new) == len(current): break
        current = new
    return current, history

def peel_decode_ldpc(ldpc, error):
    current = set(error); history = [len(current)]
    for _ in range(len(error) + 1):
        if not current: break
        corr = ldpc.correctable(current); new = current - corr
        history.append(len(new))
        if len(new) == len(current): break
        current = new
    return current, history

# ---- Generate comparison data ----

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
error_rates = np.linspace(0.01, 0.15, 12)
n_trials = 300

for idx, p in enumerate([3, 5, 7]):
    G = GL2Fp(p)
    gens = standard_generators_gl2(p)
    cayley = build_cayley_graph(G, gens)
    tanner = TannerGraph(cayley, G.order())
    n = tanner.n_left; d = tanner.degree

    ldpc = RandomLDPC(n, d, d, seed=42)

    rng = np.random.RandomState(42)
    cayley_ber = []
    ldpc_ber = []

    for eta in error_rates:
        cf = 0; lf = 0
        for _ in range(n_trials):
            ec = set(np.where(rng.random(n) < eta)[0])
            el = set(np.where(rng.random(n) < eta)[0])
            rc, _ = peel_decode_tanner(tanner, ec)
            rl, _ = peel_decode_ldpc(ldpc, el)
            if rc: cf += 1
            if rl: lf += 1
        cayley_ber.append(cf / n_trials)
        ldpc_ber.append(lf / n_trials)

    ax = axes[idx]
    ax.plot(error_rates, cayley_ber, 'b-o', markersize=4, label='Cayley Code', linewidth=2)
    ax.plot(error_rates, ldpc_ber, 'r-s', markersize=4, label='Random LDPC', linewidth=2)
    ax.set_xlabel('BSC Error Rate η')
    ax.set_ylabel('Block Error Rate')
    ax.set_title(f'GL₂(𝔽_{p}), n={n}, d={d}')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.05, 1.05)

plt.suptitle('Cayley Code vs Random LDPC: Block Error Rate Comparison',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('code_comparison.png', dpi=150, bbox_inches='tight')
print("Saved code_comparison.png")
