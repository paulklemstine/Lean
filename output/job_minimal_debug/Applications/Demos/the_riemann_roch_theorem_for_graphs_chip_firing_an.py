#!/usr/bin/env python3
"""
Demo: Chip-Firing and the Canonical Divisor on Graphs

Demonstrates the key concepts from the Riemann-Roch theorem for graphs:
- Divisors as chip configurations
- The canonical divisor K_G
- Chip-firing operations
- Genus computation
- Degree preservation under chip-firing
"""

import itertools
from typing import Dict, List, Tuple, Set

# ============================================================
# Core Types
# ============================================================

class Graph:
    """A simple undirected graph with integer vertex labels."""
    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        self.n = n
        self.vertices = list(range(n))
        self.adj: Dict[int, Set[int]] = {v: set() for v in self.vertices}
        for u, v in edges:
            if u != v:
                self.adj[u].add(v)
                self.adj[v].add(u)

    def degree(self, v: int) -> int:
        return len(self.adj[v])

    def num_edges(self) -> int:
        return sum(self.degree(v) for v in self.vertices) // 2

    def genus(self) -> int:
        """g = |E| - |V| + 1"""
        return self.num_edges() - self.n + 1

    @staticmethod
    def complete(n: int) -> 'Graph':
        """The complete graph K_n."""
        edges = [(i, j) for i in range(n) for j in range(i+1, n)]
        return Graph(n, edges)

    @staticmethod
    def cycle(n: int) -> 'Graph':
        """The cycle graph C_n."""
        edges = [(i, (i+1) % n) for i in range(n)]
        return Graph(n, edges)


class Divisor:
    """A divisor on a graph: an integer-valued function on vertices."""
    def __init__(self, values: Dict[int, int]):
        self.values = dict(values)

    def __getitem__(self, v: int) -> int:
        return self.values.get(v, 0)

    def degree(self) -> int:
        return sum(self.values.values())

    def is_effective(self) -> bool:
        return all(c >= 0 for c in self.values.values())

    def __add__(self, other: 'Divisor') -> 'Divisor':
        keys = set(self.values) | set(other.values)
        return Divisor({v: self[v] + other[v] for v in keys})

    def __sub__(self, other: 'Divisor') -> 'Divisor':
        keys = set(self.values) | set(other.values)
        return Divisor({v: self[v] - other[v] for v in keys})

    def __repr__(self) -> str:
        items = sorted(self.values.items())
        return "Div(" + ", ".join(f"v{v}:{c}" for v, c in items) + ")"


def canonical_divisor(G: Graph) -> Divisor:
    """K_G(v) = deg(v) - 2 for each vertex v."""
    return Divisor({v: G.degree(v) - 2 for v in G.vertices})


def chip_fire(G: Graph, D: Divisor, v: int) -> Divisor:
    """Fire vertex v: sends one chip along each incident edge."""
    new_vals = dict(D.values)
    new_vals[v] = D[v] - G.degree(v)
    for w in G.adj[v]:
        new_vals[w] = D[w] + 1
    return Divisor(new_vals)


def laplacian(G: Graph, f: Dict[int, int]) -> Divisor:
    """Compute the Laplacian Δf."""
    result = {}
    for v in G.vertices:
        result[v] = sum(f.get(v, 0) - f.get(w, 0) for w in G.adj[v])
    return Divisor(result)


# ============================================================
# Demonstrations
# ============================================================

def demo_canonical_divisor():
    """Demo 1: Canonical divisor and Gauss-Bonnet for complete graphs."""
    print("=" * 60)
    print("Demo 1: Canonical Divisor of Complete Graphs")
    print("=" * 60)

    for n in range(3, 8):
        G = Graph.complete(n)
        K = canonical_divisor(G)
        g = G.genus()

        print(f"\nK_{n}:")
        print(f"  Genus g = {g}")
        print(f"  Canonical divisor K = {K}")
        print(f"  deg(K) = {K.degree()}")
        print(f"  2g - 2 = {2*g - 2}")
        assert K.degree() == 2 * g - 2, "Gauss-Bonnet FAILED!"
        print(f"  ✓ Gauss-Bonnet verified: deg(K) = 2g - 2")

        # Verify K(v) = n - 3 for all v
        for v in G.vertices:
            assert K[v] == n - 3, f"K({v}) = {K[v]} ≠ {n-3}"
        print(f"  ✓ K(v) = {n-3} for all v (= n - 3)")


def demo_chip_firing_commutativity():
    """Demo 2: Chip-firing is commutative (Abelian sandpile property)."""
    print("\n" + "=" * 60)
    print("Demo 2: Chip-Firing Commutativity")
    print("=" * 60)

    G = Graph.complete(5)
    D = Divisor({0: 10, 1: 3, 2: 5, 3: 1, 4: 7})
    print(f"\nInitial divisor: {D}")
    print(f"  degree = {D.degree()}")

    # Fire vertex 0 then vertex 2
    D_02 = chip_fire(G, chip_fire(G, D, 0), 2)
    # Fire vertex 2 then vertex 0
    D_20 = chip_fire(G, chip_fire(G, D, 2), 0)

    print(f"\n  Fire v0 then v2: {D_02}")
    print(f"  Fire v2 then v0: {D_20}")

    # Check they're equal
    for v in G.vertices:
        assert D_02[v] == D_20[v], f"Mismatch at v{v}"
    print(f"  ✓ Commutativity verified!")

    # Also verify degree preservation
    print(f"\n  deg(original)    = {D.degree()}")
    print(f"  deg(after fires) = {D_02.degree()}")
    assert D.degree() == D_02.degree()
    print(f"  ✓ Degree preserved under chip-firing!")


def demo_canonical_involution():
    """Demo 3: The canonical involution D ↦ K - D."""
    print("\n" + "=" * 60)
    print("Demo 3: Canonical Involution (Serre Duality)")
    print("=" * 60)

    G = Graph.complete(5)
    K = canonical_divisor(G)
    g = G.genus()

    D = Divisor({0: 3, 1: -1, 2: 4, 3: 0, 4: 2})
    complement = K - D
    double_complement = K - complement

    print(f"\n  K_5 genus g = {g}")
    print(f"  Canonical K = {K}")
    print(f"  D = {D}, deg(D) = {D.degree()}")
    print(f"  K - D = {complement}, deg(K-D) = {complement.degree()}")
    print(f"  2g - 2 - deg(D) = {2*g - 2 - D.degree()}")
    assert complement.degree() == 2 * g - 2 - D.degree()
    print(f"  ✓ deg(K-D) = 2g - 2 - deg(D)")

    print(f"\n  K - (K - D) = {double_complement}")
    for v in G.vertices:
        assert double_complement[v] == D[v]
    print(f"  ✓ Involution verified: K - (K - D) = D")


def demo_genus_computation():
    """Demo 4: Genus computation for various graphs."""
    print("\n" + "=" * 60)
    print("Demo 4: Genus of Various Graphs")
    print("=" * 60)

    for n in range(3, 8):
        G_complete = Graph.complete(n)
        g_formula = (n - 1) * (n - 2) // 2
        print(f"\n  K_{n}: genus = {G_complete.genus()}, formula (n-1)(n-2)/2 = {g_formula}")
        assert G_complete.genus() == g_formula

    for n in range(3, 8):
        G_cycle = Graph.cycle(n)
        print(f"  C_{n}: genus = {G_cycle.genus()} (always 1 for cycles)")
        assert G_cycle.genus() == 1


def demo_firing_scripts():
    """Demo 5: Firing script algebra."""
    print("\n" + "=" * 60)
    print("Demo 5: Firing Script Algebra")
    print("=" * 60)

    G = Graph.complete(4)
    D = Divisor({0: 5, 1: 3, 2: 2, 3: 4})

    # Apply firing script f = {0: 2, 1: -1} (fire v0 twice, anti-fire v1 once)
    f = {0: 2, 1: -1, 2: 0, 3: 0}
    g = {0: 0, 1: 1, 2: -1, 3: 0}

    # Apply f then g
    Lf = laplacian(G, f)
    D_f = D + Lf
    Lg_after_f = laplacian(G, g)
    D_fg = D_f + Lg_after_f

    # Apply g then f
    Lg = laplacian(G, g)
    D_g = D + Lg
    Lf_after_g = laplacian(G, f)
    D_gf = D_g + Lf_after_g

    # Apply f + g
    fg_sum = {v: f.get(v, 0) + g.get(v, 0) for v in G.vertices}
    L_sum = laplacian(G, fg_sum)
    D_sum = D + L_sum

    print(f"\n  D = {D}")
    print(f"  f = {f}, g = {g}")
    print(f"  D + Δf + Δg = {D_fg}")
    print(f"  D + Δg + Δf = {D_gf}")
    print(f"  D + Δ(f+g)  = {D_sum}")

    for v in G.vertices:
        assert D_fg[v] == D_gf[v] == D_sum[v]
    print(f"  ✓ Firing action is commutative and composable!")

    print(f"\n  deg(D) = {D.degree()}, deg(D + Δf) = {D_f.degree()}")
    assert D.degree() == D_f.degree() == D_fg.degree()
    print(f"  ✓ Degree preserved through all firing operations!")


if __name__ == "__main__":
    demo_canonical_divisor()
    demo_chip_firing_commutativity()
    demo_canonical_involution()
    demo_genus_computation()
    demo_firing_scripts()
    print("\n" + "=" * 60)
    print("All demonstrations passed! ✓")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Chip-Firing on Complete Graphs

Generates plots showing:
1. Canonical divisor values vs. graph size
2. Genus growth for complete graphs
3. Gauss-Bonnet verification
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def compute_genus(n):
    """Genus of K_n."""
    return (n - 1) * (n - 2) // 2

def canonical_value(n):
    """K_{K_n}(v) = n - 3 for all v."""
    return n - 3

def canonical_degree(n):
    """deg(K_{K_n}) = n(n-3)."""
    return n * (n - 3)

# Data
ns = list(range(2, 15))
genera = [compute_genus(n) for n in ns]
can_vals = [canonical_value(n) for n in ns]
can_degs = [canonical_degree(n) for n in ns]
gauss_bonnet = [2 * compute_genus(n) - 2 for n in ns]

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: Genus growth
ax1 = axes[0]
ax1.plot(ns, genera, 'bo-', linewidth=2, markersize=8)
ax1.set_xlabel('n (vertices)', fontsize=12)
ax1.set_ylabel('Genus g(K_n)', fontsize=12)
ax1.set_title('Genus of Complete Graph K_n\ng = (n-1)(n-2)/2', fontsize=13)
ax1.grid(True, alpha=0.3)

# Plot 2: Canonical divisor value
ax2 = axes[1]
ax2.plot(ns, can_vals, 'rs-', linewidth=2, markersize=8)
ax2.axhline(y=0, color='k', linewidth=0.5)
ax2.set_xlabel('n (vertices)', fontsize=12)
ax2.set_ylabel('K(v) = n - 3', fontsize=12)
ax2.set_title('Canonical Divisor Value on K_n\nK(v) = deg(v) - 2 = n - 3', fontsize=13)
ax2.grid(True, alpha=0.3)

# Plot 3: Gauss-Bonnet verification
ax3 = axes[2]
ax3.plot(ns, can_degs, 'g^-', linewidth=2, markersize=8, label='deg(K_G) = n(n-3)')
ax3.plot(ns, gauss_bonnet, 'ko--', linewidth=1.5, markersize=6, label='2g - 2')
ax3.set_xlabel('n (vertices)', fontsize=12)
ax3.set_ylabel('Degree', fontsize=12)
ax3.set_title('Gauss-Bonnet Theorem\ndeg(K_G) = 2g - 2', fontsize=13)
ax3.legend(fontsize=11)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('chip_firing_canonical.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved chip_firing_canonical.png")

# Second figure: Chip-firing simulation
fig2, ax = plt.subplots(figsize=(10, 6))

n = 5
# Simulate chip-firing on K_5
D = [10, 3, 5, 1, 7]
history = [list(D)]
labels = ['Initial']

# Fire each vertex 0..4
for v in range(n):
    new_D = list(D)
    new_D[v] -= (n - 1)  # degree = n-1
    for w in range(n):
        if w != v:
            new_D[w] += 1
    D = new_D
    history.append(list(D))
    labels.append(f'Fire v{v}')

history = np.array(history)
x = np.arange(len(labels))

for v in range(n):
    ax.plot(x, history[:, v], 'o-', linewidth=2, markersize=8, label=f'v{v}')

ax.set_xticks(x)
ax.set_xticklabels(labels, rotation=45, ha='right')
ax.set_ylabel('Chips', fontsize=12)
ax.set_title('Chip-Firing Sequence on K₅\n(Total chips preserved at each step)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Add degree annotations
for i, h in enumerate(history):
    ax.annotate(f'Σ={sum(h)}', (i, max(h) + 0.5), ha='center', fontsize=8, color='gray')

plt.tight_layout()
plt.savefig('chip_firing_simulation.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved chip_firing_simulation.png")
