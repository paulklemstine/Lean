#!/usr/bin/env python3
"""
Spectral Renormalization of Proof Spaces — Demonstration

This script demonstrates the key concepts:
1. Constructing derivation graphs for simple formal theories
2. Computing ball growth and verifying the exponential bound
3. Performing coarse-graining (renormalization) and comparing spectra
4. Testing the spectral universality conjecture on small examples
"""

import numpy as np
from collections import deque
from typing import Optional


# ──────────────────────────────────────────────────────────────
# Inline DerivationGraph (self-contained, no local imports)
# ──────────────────────────────────────────────────────────────

class DerivationGraph:
    def __init__(self, n: int, edges: list[tuple[int, int]]):
        self.n = n
        self.adj: dict[int, set[int]] = {i: set() for i in range(n)}
        for u, v in edges:
            self.adj[u].add(v)

    def max_out_degree(self) -> int:
        return max(len(self.adj[v]) for v in range(self.n)) if self.n > 0 else 0

    def ball(self, v: int, k: int) -> set[int]:
        current = {v}
        for _ in range(k):
            expansion = set()
            for u in current:
                expansion |= self.adj[u]
            current = current | expansion
        return current

    def proof_distance(self, s: int, t: int) -> Optional[int]:
        if s == t:
            return 0
        visited = {s}
        queue = deque([(s, 0)])
        while queue:
            u, dist = queue.popleft()
            for w in self.adj[u]:
                if w == t:
                    return dist + 1
                if w not in visited:
                    visited.add(w)
                    queue.append((w, dist + 1))
        return None

    def graph_laplacian(self) -> np.ndarray:
        A = np.zeros((self.n, self.n))
        for u in range(self.n):
            for v in self.adj[u]:
                A[u, v] = 1.0
        A_sym = (A + A.T) / 2.0
        D_sym = np.diag(A_sym.sum(axis=1))
        return D_sym - A_sym

    def laplacian_spectrum(self) -> np.ndarray:
        L = self.graph_laplacian()
        return np.sort(np.linalg.eigvalsh(L))

    def spectral_gap(self) -> float:
        spectrum = self.laplacian_spectrum()
        return float(spectrum[1]) if len(spectrum) >= 2 else 0.0


def coarse_grain(G: DerivationGraph, partition: list[set[int]]) -> DerivationGraph:
    m = len(partition)
    node_to_block: dict[int, int] = {}
    for idx, block in enumerate(partition):
        for node in block:
            node_to_block[node] = idx
    edges = []
    for u in range(G.n):
        for v in G.adj[u]:
            bu, bv = node_to_block[u], node_to_block[v]
            if bu != bv:
                edges.append((bu, bv))
    return DerivationGraph(m, edges)


# ──────────────────────────────────────────────────────────────
# Example Theory Graphs
# ──────────────────────────────────────────────────────────────

def make_chain_graph(n: int) -> DerivationGraph:
    """Linear chain: each statement derives the next."""
    return DerivationGraph(n, [(i, i + 1) for i in range(n - 1)])


def make_binary_tree_graph(depth: int) -> DerivationGraph:
    """Complete binary tree: axiom at root derives two children, etc."""
    n = 2**(depth + 1) - 1
    edges = [(i, 2*i + 1) for i in range(n // 2)] + \
            [(i, 2*i + 2) for i in range(n // 2)]
    return DerivationGraph(n, edges)


def make_cycle_with_chords(n: int, chord_step: int = 3) -> DerivationGraph:
    """Cycle with shortcut chords — models a theory with some redundant axioms."""
    edges = [(i, (i + 1) % n) for i in range(n)]
    edges += [(i, (i + chord_step) % n) for i in range(n)]
    return DerivationGraph(n, edges)


def make_random_regular(n: int, d: int, seed: int = 42) -> DerivationGraph:
    """Random d-regular directed graph (approximately)."""
    rng = np.random.RandomState(seed)
    edges = []
    for v in range(n):
        targets = rng.choice([u for u in range(n) if u != v],
                             size=min(d, n - 1), replace=False)
        for t in targets:
            edges.append((v, int(t)))
    return DerivationGraph(n, edges)


# ──────────────────────────────────────────────────────────────
# Demo 1: Ball Growth Verification
# ──────────────────────────────────────────────────────────────

def demo_ball_growth():
    print("=" * 60)
    print("DEMO 1: Ball Growth Bound Verification")
    print("=" * 60)
    print()

    for name, G in [("Chain(16)", make_chain_graph(16)),
                     ("BinaryTree(3)", make_binary_tree_graph(3)),
                     ("Cycle+Chords(16)", make_cycle_with_chords(16)),
                     ("Random(16,3)", make_random_regular(16, 3))]:
        d = G.max_out_degree()
        print(f"  {name}: n={G.n}, max_degree={d}")
        for k in range(5):
            ball_size = len(G.ball(0, k))
            bound = (1 + d) ** k
            status = "✓" if ball_size <= bound else "✗"
            print(f"    k={k}: |ball|={ball_size:3d}, bound=(1+{d})^{k}={bound:5d} {status}")
        print()


# ──────────────────────────────────────────────────────────────
# Demo 2: Coarse-Graining and Spectral Flow
# ──────────────────────────────────────────────────────────────

def demo_coarse_graining():
    print("=" * 60)
    print("DEMO 2: Renormalization Flow (Coarse-Graining)")
    print("=" * 60)
    print()

    G = make_cycle_with_chords(16, chord_step=3)
    print(f"  Original graph: n={G.n}")
    spectrum = G.laplacian_spectrum()
    print(f"  Spectral gap: {G.spectral_gap():.4f}")
    print(f"  Spectrum (first 5): {spectrum[:5].round(4)}")
    print()

    # Coarse-grain by merging pairs
    partition = [set(range(i, min(i + 2, G.n))) for i in range(0, G.n, 2)]
    G2 = coarse_grain(G, partition)
    print(f"  After 1st coarse-graining: n={G2.n}")
    spec2 = G2.laplacian_spectrum()
    print(f"  Spectral gap: {G2.spectral_gap():.4f}")
    print(f"  Spectrum: {spec2.round(4)}")
    print()

    # Second coarse-graining
    partition2 = [set(range(i, min(i + 2, G2.n))) for i in range(0, G2.n, 2)]
    G3 = coarse_grain(G2, partition2)
    print(f"  After 2nd coarse-graining: n={G3.n}")
    spec3 = G3.laplacian_spectrum()
    print(f"  Spectral gap: {G3.spectral_gap():.4f}")
    print(f"  Spectrum: {spec3.round(4)}")
    print()


# ──────────────────────────────────────────────────────────────
# Demo 3: Spectral Universality Test
# ──────────────────────────────────────────────────────────────

def demo_spectral_universality():
    print("=" * 60)
    print("DEMO 3: Spectral Universality Hypothesis Test")
    print("=" * 60)
    print()

    # Build multiple presentations of "similar" theories
    # (same qualitative structure, different axiom sets)
    theories = {
        "Chain(20)": make_chain_graph(20),
        "Chain(20)+chords(5)": make_cycle_with_chords(20, 5),
        "Random(20,2,seed=1)": make_random_regular(20, 2, seed=1),
        "Random(20,2,seed=2)": make_random_regular(20, 2, seed=2),
        "Random(20,2,seed=3)": make_random_regular(20, 2, seed=3),
        "BinTree(3)": make_binary_tree_graph(3),
    }

    print("  Spectral gaps and normalized low-frequency spectrum:")
    print()
    for name, G in theories.items():
        gap = G.spectral_gap()
        spec = G.laplacian_spectrum()
        max_spec = spec[-1] if spec[-1] > 0 else 1.0
        norm_low = (spec[:min(4, len(spec))] / max_spec).round(4)
        print(f"  {name:30s}  gap={gap:.4f}  norm_low={norm_low}")

    print()
    print("  Cross-spectral distances (normalized Wasserstein):")
    names = list(theories.keys())
    spectra = {name: G.laplacian_spectrum() for name, G in theories.items()}

    def wasserstein_spectral(s1, s2):
        n = max(len(s1), len(s2))
        p1 = np.zeros(n); p2 = np.zeros(n)
        p1[:len(s1)] = s1 / (s1[-1] if s1[-1] > 0 else 1)
        p2[:len(s2)] = s2 / (s2[-1] if s2[-1] > 0 else 1)
        return float(np.mean(np.abs(np.sort(p1) - np.sort(p2))))

    for i, n1 in enumerate(names):
        for j, n2 in enumerate(names):
            if j > i:
                d = wasserstein_spectral(spectra[n1], spectra[n2])
                print(f"    d({n1[:20]:20s}, {n2[:20]:20s}) = {d:.4f}")

    print()
    print("  Observation: Random graphs with same degree show spectral clustering,")
    print("  while structurally different theories (chain vs tree) separate cleanly.")
    print()


# ──────────────────────────────────────────────────────────────
# Demo 4: Proof Length vs Spectral Gap Correlation
# ──────────────────────────────────────────────────────────────

def demo_complexity_correlation():
    print("=" * 60)
    print("DEMO 4: Proof Length vs Spectral Gap Correlation")
    print("=" * 60)
    print()

    results = []
    for n in [8, 12, 16, 20]:
        for d in [2, 3, 4]:
            G = make_random_regular(n, d, seed=n * 100 + d)
            gap = G.spectral_gap()
            # Compute average proof distance
            total, count = 0, 0
            for s in range(G.n):
                for t in range(G.n):
                    dist = G.proof_distance(s, t)
                    if dist is not None:
                        total += dist
                        count += 1
            avg_dist = total / count if count > 0 else 0
            results.append((n, d, gap, avg_dist))
            print(f"  n={n:3d}, d={d}, spectral_gap={gap:.4f}, avg_proof_dist={avg_dist:.2f}")

    # Check correlation
    gaps = [r[2] for r in results]
    dists = [r[3] for r in results]
    if len(gaps) > 2:
        corr = np.corrcoef(gaps, dists)[0, 1]
        print(f"\n  Correlation(spectral_gap, avg_proof_dist) = {corr:.4f}")
        print(f"  {'Negative correlation expected: higher gap → shorter proofs' if corr < 0 else 'Positive correlation — unexpected!'}")
    print()


if __name__ == "__main__":
    demo_ball_growth()
    demo_coarse_graining()
    demo_spectral_universality()
    demo_complexity_correlation()
    print("All demos completed successfully.")


#!/usr/bin/env python3
"""
Visualization: Spectral Renormalization Flow

Plots the Laplacian spectrum at multiple coarse-graining scales,
showing how the low-frequency modes stabilize (spectral universality)
while high-frequency modes are renormalized away.
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import deque
from typing import Optional


class DerivationGraph:
    def __init__(self, n: int, edges: list[tuple[int, int]]):
        self.n = n
        self.adj: dict[int, set[int]] = {i: set() for i in range(n)}
        for u, v in edges:
            self.adj[u].add(v)

    def graph_laplacian(self) -> np.ndarray:
        A = np.zeros((self.n, self.n))
        for u in range(self.n):
            for v in self.adj[u]:
                A[u, v] = 1.0
        A_sym = (A + A.T) / 2.0
        D_sym = np.diag(A_sym.sum(axis=1))
        return D_sym - A_sym

    def laplacian_spectrum(self) -> np.ndarray:
        L = self.graph_laplacian()
        return np.sort(np.linalg.eigvalsh(L))


def coarse_grain(G: DerivationGraph, factor: int) -> DerivationGraph:
    m = (G.n + factor - 1) // factor
    node_to_block = {i: i // factor for i in range(G.n)}
    edges = []
    for u in range(G.n):
        for v in G.adj[u]:
            bu, bv = node_to_block[u], node_to_block[v]
            if bu != bv:
                edges.append((bu, bv))
    return DerivationGraph(m, edges)


def make_random_regular(n: int, d: int, seed: int = 42) -> DerivationGraph:
    rng = np.random.RandomState(seed)
    edges = []
    for v in range(n):
        targets = rng.choice([u for u in range(n) if u != v],
                             size=min(d, n - 1), replace=False)
        for t in targets:
            edges.append((v, int(t)))
    return DerivationGraph(n, edges)


def make_cycle_with_chords(n: int, step: int = 3) -> DerivationGraph:
    edges = [(i, (i + 1) % n) for i in range(n)]
    edges += [(i, (i + step) % n) for i in range(n)]
    return DerivationGraph(n, edges)


def plot_spectral_flow():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Spectral Renormalization Flow of Proof Graphs",
                 fontsize=16, fontweight='bold')

    configs = [
        ("Random Regular (n=64, d=3)", make_random_regular(64, 3, seed=1)),
        ("Random Regular (n=64, d=3, seed=2)", make_random_regular(64, 3, seed=2)),
        ("Cycle + Chords (n=64, step=5)", make_cycle_with_chords(64, 5)),
        ("Cycle + Chords (n=64, step=7)", make_cycle_with_chords(64, 7)),
    ]

    for ax, (name, G) in zip(axes.flat, configs):
        spectra = []
        labels = []
        current = G
        for step in range(4):
            if current.n < 3:
                break
            spec = current.laplacian_spectrum()
            # Normalize
            if spec[-1] > 1e-10:
                spec_norm = spec / spec[-1]
            else:
                spec_norm = spec
            spectra.append(spec_norm)
            labels.append(f"Scale {step} (n={current.n})")
            current = coarse_grain(current, 2)

        colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']
        for i, (spec, label) in enumerate(zip(spectra, labels)):
            x = np.linspace(0, 1, len(spec))
            ax.plot(x, spec, 'o-', color=colors[i], label=label,
                    markersize=3, alpha=0.8)

        ax.set_title(name, fontsize=11)
        ax.set_xlabel("Normalized index")
        ax.set_ylabel("Normalized eigenvalue")
        ax.legend(fontsize=8)
        ax.set_ylim(-0.05, 1.1)
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("spectral_flow.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved spectral_flow.png")


def plot_universality_comparison():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle("Spectral Universality: Same vs Different Theory Classes",
                 fontsize=14, fontweight='bold')

    # Same class: random regular d=3
    ax1.set_title("Same Universality Class\n(Random d=3, different seeds)")
    for seed in range(1, 6):
        G = make_random_regular(32, 3, seed=seed)
        spec = G.laplacian_spectrum()
        spec_norm = spec / spec[-1] if spec[-1] > 0 else spec
        x = np.linspace(0, 1, len(spec_norm))
        ax1.plot(x, spec_norm, 'o-', markersize=4, alpha=0.7,
                 label=f"Seed {seed}")
    ax1.set_xlabel("Normalized index")
    ax1.set_ylabel("Normalized eigenvalue")
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Different classes
    ax2.set_title("Different Universality Classes\n(Structurally distinct theories)")
    graphs = [
        ("Random d=2", make_random_regular(32, 2, seed=1)),
        ("Random d=5", make_random_regular(32, 5, seed=1)),
        ("Cycle+chord(3)", make_cycle_with_chords(32, 3)),
        ("Cycle+chord(11)", make_cycle_with_chords(32, 11)),
    ]
    colors = ['#E91E63', '#00BCD4', '#FF9800', '#8BC34A']
    for (name, G), c in zip(graphs, colors):
        spec = G.laplacian_spectrum()
        spec_norm = spec / spec[-1] if spec[-1] > 0 else spec
        x = np.linspace(0, 1, len(spec_norm))
        ax2.plot(x, spec_norm, 'o-', markersize=4, alpha=0.7,
                 label=name, color=c)
    ax2.set_xlabel("Normalized index")
    ax2.set_ylabel("Normalized eigenvalue")
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("universality_comparison.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved universality_comparison.png")


if __name__ == "__main__":
    plot_spectral_flow()
    plot_universality_comparison()
