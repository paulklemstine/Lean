"""
Visualization: Expansion Properties of Cayley-Based Tanner Codes

Plots the expansion ratio |N(S)|/|S| and unique neighbor ratio |U(S)|/|S|
as functions of set size |S| for Tanner graphs built from GL₂(𝔽_p) Cayley graphs.
Shows the formally verified lower bound |U(S)| ≥ 2|N(S)| - d|S|.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product
from collections import defaultdict

# ---- Inline all needed functions ----

def gf_mul(a, b, p):
    return (a * b) % p

def gf_inv(a, p):
    return pow(a, p - 2, p)

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
        self.p = p
        self.elements = []
        self.element_to_idx = {}
        idx = 0
        for a, b, c, d in product(range(p), repeat=4):
            det = (a * d - b * c) % p
            if det != 0:
                M = np.array([[a, b], [c, d]], dtype=int)
                self.elements.append(M)
                self.element_to_idx[(a, b, c, d)] = idx
                idx += 1

    def order(self):
        return len(self.elements)

    def mat_to_idx(self, M):
        key = (int(M[0, 0]) % self.p, int(M[0, 1]) % self.p,
               int(M[1, 0]) % self.p, int(M[1, 1]) % self.p)
        return self.element_to_idx[key]

    def multiply(self, i, j):
        prod = mat_mul_2x2(self.elements[i], self.elements[j], self.p)
        return self.mat_to_idx(prod)

def _primitive_root(p):
    if p == 2:
        return 1
    for g in range(2, p):
        order = p - 1
        temp = order
        factors = set()
        d = 2
        while d * d <= temp:
            while temp % d == 0:
                factors.add(d)
                temp //= d
            d += 1
        if temp > 1:
            factors.add(temp)
        ok = True
        for q in factors:
            if pow(g, order // q, p) == 1:
                ok = False
                break
        if ok:
            return g
    return 2

def standard_generators_gl2(p):
    g = _primitive_root(p)
    gens = [
        np.array([[1, 1], [0, 1]], dtype=int),
        np.array([[1, 0], [1, 1]], dtype=int),
        np.array([[g, 0], [0, 1]], dtype=int),
    ]
    inv_gens = []
    for M in gens:
        det = mat_det_2x2(M, p)
        det_inv = gf_inv(det, p)
        M_inv = np.array([
            [gf_mul(int(M[1, 1]), det_inv, p), gf_mul((-int(M[0, 1])) % p, det_inv, p)],
            [gf_mul((-int(M[1, 0])) % p, det_inv, p), gf_mul(int(M[0, 0]), det_inv, p)]
        ], dtype=int)
        inv_gens.append(M_inv)
    all_gens = gens + inv_gens
    seen = set()
    unique = []
    for M in all_gens:
        key = tuple(M.flatten() % p)
        if key not in seen:
            seen.add(key)
            unique.append(M % p)
    return unique

def build_cayley_graph(group, generators):
    gen_indices = [group.mat_to_idx(g) for g in generators]
    adj = defaultdict(set)
    for v in range(group.order()):
        for s_idx in gen_indices:
            adj[v].add(group.multiply(v, s_idx))
    return dict(adj)

class TannerGraph:
    def __init__(self, cayley_adj, n_vertices):
        self.n_left = n_vertices
        self.n_right = n_vertices
        self.left_neighbors = {}
        self.right_neighbors = defaultdict(set)
        for v in range(n_vertices):
            neighbors = cayley_adj.get(v, set())
            self.left_neighbors[v] = set(neighbors)
            for u in neighbors:
                self.right_neighbors[u].add(v)
        self.degree = len(next(iter(self.left_neighbors.values()))) if n_vertices > 0 else 0

    def neighborhood(self, S):
        result = set()
        for v in S:
            result.update(self.left_neighbors.get(v, set()))
        return result

    def unique_neighbors(self, S):
        right_count = defaultdict(int)
        for v in S:
            for r in self.left_neighbors.get(v, set()):
                right_count[r] += 1
        return {r for r, count in right_count.items() if count == 1}

# ---- Build graphs and measure ----

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

for idx, p in enumerate([3, 5, 7]):
    G = GL2Fp(p)
    gens = standard_generators_gl2(p)
    cayley = build_cayley_graph(G, gens)
    tanner = TannerGraph(cayley, G.order())
    d = tanner.degree
    n = tanner.n_left

    rng = np.random.RandomState(42)
    max_s = min(25, n // 4)
    sizes = list(range(1, max_s + 1))
    exp_ratios = []
    uniq_ratios = []
    bound_ratios = []

    for s in sizes:
        ers = []
        urs = []
        for _ in range(500):
            S = set(rng.choice(n, size=s, replace=False))
            N = tanner.neighborhood(S)
            U = tanner.unique_neighbors(S)
            ers.append(len(N) / s)
            urs.append(len(U) / s)
        avg_e = np.mean(ers)
        avg_u = np.mean(urs)
        exp_ratios.append(avg_e)
        uniq_ratios.append(avg_u)
        bound_ratios.append(max(0, 2 * avg_e - d))

    ax = axes[idx]
    ax.plot(sizes, exp_ratios, 'b-o', markersize=3, label='|N(S)|/|S| (expansion)')
    ax.plot(sizes, uniq_ratios, 'r-s', markersize=3, label='|U(S)|/|S| (unique)')
    ax.plot(sizes, bound_ratios, 'g--', linewidth=2, label='2|N|/|S| - d (bound)')
    ax.axhline(y=d, color='gray', linestyle=':', alpha=0.5, label=f'd = {d}')
    ax.set_xlabel('Set size |S|')
    ax.set_ylabel('Ratio')
    ax.set_title(f'GL₂(𝔽_{p}), n={n}')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

plt.suptitle('Expansion and Unique Neighbor Properties of Cayley-Based Tanner Codes',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('expansion_properties.png', dpi=150, bbox_inches='tight')
print("Saved expansion_properties.png")
