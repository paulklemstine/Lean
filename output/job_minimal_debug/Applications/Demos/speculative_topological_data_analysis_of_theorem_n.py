#!/usr/bin/env python3
"""
Citation Complex Demo: Topological Data Analysis of Theorem Networks

Demonstrates the construction of co-citation simplicial complexes and
computation of topological invariants (Betti numbers, Euler characteristic,
persistent homology) on example citation networks.
"""

import random
from algorithms import (
    CitationGraph,
    build_cocitation_complex,
    build_filtration,
    compute_betti_numbers,
    detect_communities,
    detect_paradigm_shifts,
    cyclomatic_complexity,
    verify_morse_inequalities,
)


def print_separator():
    print("=" * 60)


def demo_small_network():
    """Demo 1: Small hand-crafted citation network."""
    print_separator()
    print("DEMO 1: Small Citation Network")
    print_separator()
    print()

    # 6 theorems, two research communities
    # Community A: theorems 0, 1, 2 (connected via co-citations)
    # Community B: theorems 3, 4, 5 (connected via co-citations)
    # Theorem 6 bridges them (cites from both)
    n = 7
    edges = [
        # Theorem 0 cites 1 and 2
        (0, 1), (0, 2),
        # Theorem 1 cites 2
        (1, 2),
        # Theorem 3 cites 4 and 5
        (3, 4), (3, 5),
        # Theorem 4 cites 5
        (4, 5),
        # Bridge: theorem 6 cites from both communities
        (6, 1), (6, 4),
    ]

    G = CitationGraph(n, edges)
    K = build_cocitation_complex(G, threshold=1)

    f = K.f_vector()
    betti = compute_betti_numbers(K)
    chi = K.euler_characteristic()

    print(f"Number of theorems: {n}")
    print(f"Number of citations: {len(edges)}")
    print(f"f-vector (face counts): {f}")
    print(f"Betti numbers: {betti}")
    print(f"Euler characteristic: {chi}")
    print(f"Communities (β₀): {detect_communities(K)}")
    print(f"Independent loops (β₁): {cyclomatic_complexity(K)}")
    print(f"Morse inequalities verified: {verify_morse_inequalities(K)}")
    print()

    # Verify Euler-Poincaré
    euler_f = sum((-1)**k * fk for k, fk in enumerate(f))
    euler_b = sum((-1)**k * bk for k, bk in enumerate(betti))
    print(f"Euler char (faces): {euler_f}")
    print(f"Euler char (Betti): {euler_b}")
    print(f"Euler-Poincaré holds: {euler_f == euler_b}")
    print()


def demo_random_network():
    """Demo 2: Random citation network (Erdős-Rényi model)."""
    print_separator()
    print("DEMO 2: Random Citation Network (n=20, p=0.3)")
    print_separator()
    print()

    random.seed(42)
    n = 20
    p = 0.3
    edges = []
    for i in range(n):
        for j in range(n):
            if i != j and random.random() < p:
                edges.append((i, j))

    G = CitationGraph(n, edges)
    K = build_cocitation_complex(G, threshold=1)

    f = K.f_vector()
    betti = compute_betti_numbers(K)
    chi = K.euler_characteristic()

    print(f"Number of theorems: {n}")
    print(f"Number of citations: {len(edges)}")
    print(f"Dimension: {K.dimension()}")
    print(f"f-vector: {f}")
    print(f"Betti numbers: {betti}")
    print(f"Euler characteristic: {chi}")
    print(f"Communities (β₀): {detect_communities(K)}")
    print(f"Independent loops (β₁): {cyclomatic_complexity(K)}")
    print(f"Morse inequalities verified: {verify_morse_inequalities(K)}")
    print()

    # Verify weak Morse: β_k ≤ f_k
    print("Weak Morse inequalities:")
    for k in range(min(len(betti), len(f))):
        print(f"  β_{k} = {betti[k]} ≤ f_{k} = {f[k]}: {betti[k] <= f[k]}")
    print()


def demo_filtration():
    """Demo 3: Persistent homology via citation filtration."""
    print_separator()
    print("DEMO 3: Citation Filtration (Persistent Homology)")
    print_separator()
    print()

    random.seed(123)
    n = 15
    # Create a structured network with varying co-citation densities
    edges = []
    for i in range(n):
        for j in range(n):
            if i != j and random.random() < 0.4:
                edges.append((i, j))

    G = CitationGraph(n, edges)
    filtration = build_filtration(G, max_threshold=5)

    print(f"Number of theorems: {n}")
    print(f"Number of citations: {len(edges)}")
    print()
    print(f"{'Threshold':>10} {'f-vector':>30} {'Betti':>20} {'χ':>5}")
    print("-" * 70)

    for t in sorted(filtration.keys(), reverse=True):
        K = filtration[t]
        f = K.f_vector()
        betti = compute_betti_numbers(K)
        chi = K.euler_characteristic()
        print(f"{t:>10} {str(f):>30} {str(betti):>20} {chi:>5}")

    print()
    print("Note: As threshold decreases, the complex grows (monotonicity).")
    print("Paradigm shifts detected at:", detect_paradigm_shifts(filtration))
    print()


def demo_growth_bounds():
    """Demo 4: Betti number growth bounds (β_k ≤ C(n, k+1))."""
    print_separator()
    print("DEMO 4: Betti Number Growth Bounds")
    print_separator()
    print()

    from math import comb

    print(f"{'n':>5} {'k':>5} {'β_k':>8} {'C(n,k+1)':>10} {'β_k/C(n,k+1)':>15}")
    print("-" * 50)

    for n in [8, 12, 16, 20]:
        random.seed(n)
        edges = [(i, j) for i in range(n) for j in range(n)
                 if i != j and random.random() < 0.3]
        G = CitationGraph(n, edges)
        K = build_cocitation_complex(G, threshold=1)
        betti = compute_betti_numbers(K)

        for k in range(min(3, len(betti))):
            bound = comb(n, k + 1)
            ratio = betti[k] / bound if bound > 0 else 0
            print(f"{n:>5} {k:>5} {betti[k]:>8} {bound:>10} {ratio:>15.4f}")
        print()

    print("The ratio β_k / C(n, k+1) stays well below 1,")
    print("confirming the Betti growth bound β_k ≤ C(n, k+1).")
    print()


def demo_cyclomatic():
    """Demo 5: Cyclomatic complexity of citation networks."""
    print_separator()
    print("DEMO 5: Network Complexity (Cyclomatic Complexity = β₁)")
    print_separator()
    print()

    print("For a connected graph: β₁ = edges - vertices + 1")
    print()

    # Build increasingly complex networks
    for n in [5, 10, 15, 20]:
        random.seed(n * 7)
        edges = [(i, j) for i in range(n) for j in range(n)
                 if i != j and random.random() < 0.5]
        G = CitationGraph(n, edges)
        K = build_cocitation_complex(G, threshold=1)
        f = K.f_vector()
        betti = compute_betti_numbers(K)

        beta0 = betti[0] if betti else 0
        beta1 = betti[1] if len(betti) > 1 else 0
        vertices = f[0] if f else 0
        edge_count = f[1] if len(f) > 1 else 0

        # Verify β₁ = edges - vertices + components
        computed = edge_count - vertices + beta0
        print(f"n={n:>3}: V={vertices}, E={edge_count}, β₀={beta0}, β₁={beta1}, "
              f"E-V+β₀={computed}, match={beta1==computed}")

    print()


if __name__ == "__main__":
    demo_small_network()
    demo_random_network()
    demo_filtration()
    demo_growth_bounds()
    demo_cyclomatic()

    print_separator()
    print("All demos completed successfully!")
    print_separator()


#!/usr/bin/env python3
"""
Visualization: Citation Complex Topology

Generates plots showing:
1. Betti number growth as function of network size
2. Filtration persistence diagram
3. Euler characteristic evolution
"""

import random
from collections import defaultdict
from typing import List, Set, FrozenSet, Dict, Tuple

# ---- Inline algorithm functions (no local imports) ----

class CitationGraph:
    def __init__(self, n, edges):
        self.n = n
        self.adj = defaultdict(set)
        self.in_adj = defaultdict(set)
        for i, j in edges:
            if i != j:
                self.adj[i].add(j)
                self.in_adj[j].add(i)

    def co_citation_count(self, i, j):
        return len(self.in_adj.get(i, set()) & self.in_adj.get(j, set()))


class SimplicialComplex:
    def __init__(self):
        self.faces = set()

    def add_face(self, face):
        self.faces.add(face)
        if len(face) > 1:
            for v in face:
                self.add_face(face - {v})

    def f_vector(self):
        if not self.faces:
            return []
        max_dim = max(len(f) - 1 for f in self.faces)
        f = [0] * (max_dim + 1)
        for face in self.faces:
            if face:
                f[len(face) - 1] += 1
        return f

    def euler_characteristic(self):
        f = self.f_vector()
        return sum((-1) ** k * fk for k, fk in enumerate(f))


def build_complex(graph, threshold=1):
    K = SimplicialComplex()
    for v in range(graph.n):
        K.add_face(frozenset({v}))
    cocite_adj = defaultdict(set)
    for i in range(graph.n):
        for j in range(i + 1, graph.n):
            if graph.co_citation_count(i, j) >= threshold:
                cocite_adj[i].add(j)
                cocite_adj[j].add(i)
                K.add_face(frozenset({i, j}))
    # Find triangles
    vertices = sorted(v for v in range(graph.n) if cocite_adj.get(v))
    for i in vertices:
        for j in cocite_adj.get(i, set()):
            if j > i:
                common = cocite_adj.get(i, set()) & cocite_adj.get(j, set())
                for k in common:
                    if k > j:
                        K.add_face(frozenset({i, j, k}))
    return K


def compute_betti(K):
    import numpy as np
    f = K.f_vector()
    if not f:
        return []
    d = len(f)
    faces_by_dim = defaultdict(list)
    for face in K.faces:
        if face:
            faces_by_dim[len(face) - 1].append(face)
    for dim in faces_by_dim:
        faces_by_dim[dim].sort(key=lambda x: sorted(x))
    betti = []
    prev_rank = 0
    for k in range(d):
        if k + 1 < d and faces_by_dim[k + 1]:
            n_rows = len(faces_by_dim[k])
            n_cols = len(faces_by_dim[k + 1])
            boundary = np.zeros((n_rows, n_cols), dtype=int)
            face_to_idx = {f: i for i, f in enumerate(faces_by_dim[k])}
            for j, sigma in enumerate(faces_by_dim[k + 1]):
                sorted_sigma = sorted(sigma)
                for idx, v in enumerate(sorted_sigma):
                    face = frozenset(sorted_sigma[:idx] + sorted_sigma[idx + 1:])
                    if face in face_to_idx:
                        boundary[face_to_idx[face], j] = (-1) ** idx
            cur_rank = int(np.linalg.matrix_rank(boundary))
        else:
            cur_rank = 0
        cycle_dim = f[k] - prev_rank
        betti_k = cycle_dim - cur_rank
        betti.append(max(0, betti_k))
        prev_rank = cur_rank
    return betti

# ---- Visualization ----

def main():
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    from math import comb

    # Figure 1: Betti growth bounds
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    ns = list(range(5, 22, 2))
    beta0s, beta1s = [], []
    bound0s, bound1s = [], []

    for n in ns:
        random.seed(n * 31)
        edges = [(i, j) for i in range(n) for j in range(n)
                 if i != j and random.random() < 0.3]
        G = CitationGraph(n, edges)
        K = build_complex(G)
        betti = compute_betti(K)
        beta0s.append(betti[0] if betti else 0)
        beta1s.append(betti[1] if len(betti) > 1 else 0)
        bound0s.append(comb(n, 1))
        bound1s.append(comb(n, 2))

    axes[0].plot(ns, beta0s, 'bo-', label='β₀ (communities)', linewidth=2)
    axes[0].plot(ns, bound0s, 'r--', label='C(n,1) bound', linewidth=1)
    axes[0].set_xlabel('Network size n')
    axes[0].set_ylabel('β₀')
    axes[0].set_title('β₀ Growth (Communities)')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    axes[1].plot(ns, beta1s, 'go-', label='β₁ (loops)', linewidth=2)
    axes[1].plot(ns, bound1s, 'r--', label='C(n,2) bound', linewidth=1)
    axes[1].set_xlabel('Network size n')
    axes[1].set_ylabel('β₁')
    axes[1].set_title('β₁ Growth (Research Loops)')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)

    # Euler characteristic
    chis = []
    for n in ns:
        random.seed(n * 31)
        edges = [(i, j) for i in range(n) for j in range(n)
                 if i != j and random.random() < 0.3]
        G = CitationGraph(n, edges)
        K = build_complex(G)
        chis.append(K.euler_characteristic())

    axes[2].plot(ns, chis, 'ms-', label='χ (Euler char)', linewidth=2)
    axes[2].axhline(y=0, color='k', linestyle='-', linewidth=0.5)
    axes[2].set_xlabel('Network size n')
    axes[2].set_ylabel('χ')
    axes[2].set_title('Euler Characteristic')
    axes[2].legend()
    axes[2].grid(True, alpha=0.3)

    plt.suptitle('Citation Complex Topological Invariants', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('betti_growth.png', dpi=150, bbox_inches='tight')
    print("Saved betti_growth.png")

    # Figure 2: Filtration diagram
    fig, ax = plt.subplots(figsize=(10, 6))

    random.seed(42)
    n = 12
    edges = [(i, j) for i in range(n) for j in range(n)
             if i != j and random.random() < 0.4]
    G = CitationGraph(n, edges)

    thresholds = list(range(6, -1, -1))
    f0s, f1s, f2s = [], [], []
    b0s, b1s = [], []

    for t in thresholds:
        K = build_complex(G, threshold=t)
        f = K.f_vector()
        betti = compute_betti(K)
        f0s.append(f[0] if len(f) > 0 else 0)
        f1s.append(f[1] if len(f) > 1 else 0)
        f2s.append(f[2] if len(f) > 2 else 0)
        b0s.append(betti[0] if betti else 0)
        b1s.append(betti[1] if len(betti) > 1 else 0)

    ax.plot(thresholds, f0s, 'bo-', label='f₀ (vertices)', linewidth=2)
    ax.plot(thresholds, f1s, 'g^-', label='f₁ (edges)', linewidth=2)
    ax.plot(thresholds, f2s, 'rs-', label='f₂ (triangles)', linewidth=2)
    ax.plot(thresholds, b0s, 'c*-', label='β₀ (components)', linewidth=2, markersize=10)
    ax.plot(thresholds, b1s, 'mD-', label='β₁ (loops)', linewidth=2)
    ax.set_xlabel('Co-citation threshold (decreasing →)', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Citation Filtration: Face Counts and Betti Numbers', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.invert_xaxis()

    plt.tight_layout()
    plt.savefig('filtration.png', dpi=150, bbox_inches='tight')
    print("Saved filtration.png")


if __name__ == "__main__":
    main()
