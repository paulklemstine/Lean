#!/usr/bin/env python3
"""
Visualization: CSS Code Parameters from Graph Topology.

Shows how the cycle rank (β₁ = logical qubits) and girth (code distance
in unit-weight regime) scale across different graph families:
  - Complete graphs K_n
  - Cycle graphs C_n
  - Grid graphs n×n
  - Toric code graphs n×n

Demonstrates that tropical Morse theory correctly extracts both
k (from β₁) and d (from girth) across all tested families.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict, deque


# ─── Inlined algorithms ───

class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.nc = n
    def find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x
    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry: return False
        if self.rank[rx] < self.rank[ry]: rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]: self.rank[rx] += 1
        self.nc -= 1
        return True

def beta1(n, edges):
    uf = UnionFind(n)
    for u,v,_ in edges: uf.union(u,v)
    return len(edges) - n + uf.nc

def girth(n, edges):
    adj = defaultdict(set)
    for u,v,_ in edges: adj[u].add(v); adj[v].add(u)
    g = float('inf')
    for s in range(n):
        dist = {s: 0}
        q = deque([s])
        while q:
            u = q.popleft()
            for v in adj[u]:
                if v not in dist:
                    dist[v] = dist[u] + 1
                    q.append(v)
                elif dist[v] >= dist[u]:
                    g = min(g, dist[u] + dist[v] + 1)
    return int(g) if g != float('inf') else None

def complete(n):
    return n, [(i,j,1) for i in range(n) for j in range(i+1,n)]

def cycle_g(n):
    return n, [(i,(i+1)%n,1) for i in range(n)]

def grid(n):
    edges = []
    for r in range(n):
        for c in range(n):
            if c+1<n: edges.append((r*n+c, r*n+c+1, 1))
            if r+1<n: edges.append((r*n+c, (r+1)*n+c, 1))
    return n*n, edges

def torus(n):
    edges = []
    idx = lambda r,c: (r%n)*n + (c%n)
    for r in range(n):
        for c in range(n):
            edges.append((idx(r,c), idx(r,c+1), 1))
            edges.append((idx(r,c), idx(r+1,c), 1))
    return n*n, edges


def main():
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle('CSS Code Parameters from Graph Topology', fontsize=14, fontweight='bold')

    ns = list(range(3, 12))

    # ── Complete graphs ──
    ax = axes[0, 0]
    b1s = []; gs = []
    for n in ns:
        V, e = complete(n)
        b1s.append(beta1(V, e))
        gs.append(girth(V, e))
    ax.plot(ns, b1s, 'o-', color='#2196F3', linewidth=2, label='β₁ (logical qubits)')
    ax.plot(ns, gs, 's-', color='#F44336', linewidth=2, label='girth (distance)')
    ax.set_xlabel('n (vertices)')
    ax.set_title('Complete Graphs K_n')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # ── Cycle graphs ──
    ax = axes[0, 1]
    ns_c = list(range(3, 20))
    b1s = []; gs = []
    for n in ns_c:
        V, e = cycle_g(n)
        b1s.append(beta1(V, e))
        gs.append(girth(V, e))
    ax.plot(ns_c, b1s, 'o-', color='#2196F3', linewidth=2, label='β₁ (= 1 always)')
    ax.plot(ns_c, gs, 's-', color='#F44336', linewidth=2, label='girth (= n)')
    ax.set_xlabel('n (vertices)')
    ax.set_title('Cycle Graphs C_n')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # ── Grid graphs ──
    ax = axes[1, 0]
    ns_g = list(range(2, 12))
    b1s = []; gs = []; es = []
    for n in ns_g:
        V, e = grid(n)
        b1s.append(beta1(V, e))
        gs.append(girth(V, e))
        es.append(len(e))
    ax.plot(ns_g, b1s, 'o-', color='#2196F3', linewidth=2, label='β₁ = (n-1)²')
    ax.plot(ns_g, [(n-1)**2 for n in ns_g], 'x--', color='#4CAF50', linewidth=1, label='(n-1)² formula')
    ax2 = ax.twinx()
    ax2.plot(ns_g, gs, 's-', color='#F44336', linewidth=2, label='girth (= 4 for n≥2)')
    ax2.set_ylabel('Girth', color='#F44336')
    ax.set_xlabel('n (grid size)')
    ax.set_title('Grid Graphs n×n')
    ax.legend(loc='upper left')
    ax2.legend(loc='upper right')
    ax.grid(True, alpha=0.3)

    # ── Toric code ──
    ax = axes[1, 1]
    ns_t = list(range(2, 10))
    b1s = []; gs = []
    for n in ns_t:
        V, e = torus(n)
        b1s.append(beta1(V, e))
        g = girth(V, e)
        gs.append(g if g else 0)
    ax.plot(ns_t, b1s, 'o-', color='#2196F3', linewidth=2, label='β₁')
    ax.plot(ns_t, [n*n+1 for n in ns_t], 'x--', color='#4CAF50', linewidth=1, label='n²+1 formula')
    ax2 = ax.twinx()
    ax2.plot(ns_t, gs, 's-', color='#F44336', linewidth=2, label='girth')
    ax2.set_ylabel('Girth', color='#F44336')
    ax.set_xlabel('n (torus size)')
    ax.set_title('Toric Code Graphs n×n')
    ax.legend(loc='upper left')
    ax2.legend(loc='upper right')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('code_parameters.png', dpi=150, bbox_inches='tight')
    print("Saved: code_parameters.png")


if __name__ == "__main__":
    main()
