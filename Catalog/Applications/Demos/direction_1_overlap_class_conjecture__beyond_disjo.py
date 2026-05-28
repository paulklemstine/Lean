"""
applications.py — Real-World Applications of Overlap Class Theory

Demonstrates how the overlap class framework applies to:
1. Network analysis (community detection via support overlap)
2. Coding theory (codeword support analysis)
3. Circuit design (signal path interaction analysis)
"""

from typing import List, Set, Tuple, Dict, FrozenSet
from itertools import combinations
from collections import defaultdict


# ─── Application 1: Network Community Detection ─────────────────────────

def network_community_detection(
    paths: List[Set[int]],
    verbose: bool = True
) -> Dict:
    """
    Use overlap classes to detect interaction communities in a network.

    Given a list of critical paths (each a set of nodes), two paths are
    in the same "interaction community" if they share infrastructure.
    This is exactly the overlap class decomposition.

    Args:
        paths: List of node sets representing critical paths.
        verbose: Print analysis.

    Returns:
        Dict with communities and interaction analysis.
    """
    supports = [frozenset(p) for p in paths]
    n = len(supports)

    # Build overlap graph
    parent = list(range(n))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        parent[find(x)] = find(y)

    edges = []
    for i, j in combinations(range(n), 2):
        shared = supports[i] & supports[j]
        if shared:
            union(i, j)
            edges.append((i, j, shared))

    # Extract communities
    communities = defaultdict(list)
    for i in range(n):
        communities[find(i)].append(i)
    communities = list(communities.values())

    # Analyze shared infrastructure
    shared_nodes = set()
    for s in supports:
        for t in supports:
            if s != t:
                shared_nodes |= (s & t)

    result = {
        'num_paths': n,
        'num_communities': len(communities),
        'communities': communities,
        'shared_infrastructure': shared_nodes,
        'interaction_edges': edges,
    }

    if verbose:
        print("Network Community Detection via Overlap Classes")
        print("-" * 50)
        print(f"Number of critical paths: {n}")
        print(f"Number of interaction communities: {len(communities)}")
        for i, comm in enumerate(communities):
            print(f"  Community {i}: paths {comm}")
            comm_nodes = set()
            for idx in comm:
                comm_nodes |= paths[idx]
            print(f"    Total infrastructure: {sorted(comm_nodes)}")
        print(f"Shared infrastructure nodes: {sorted(shared_nodes)}")
        if shared_nodes:
            print(f"  → These {len(shared_nodes)} nodes are single points of failure")
            print(f"    affecting multiple critical paths simultaneously.")
        else:
            print(f"  → No shared infrastructure: all paths are independent.")

    return result


# ─── Application 2: Coding Theory Analysis ──────────────────────────────

def codeword_support_analysis(
    codewords: List[List[int]],
    verbose: bool = True
) -> Dict:
    """
    Analyze the support overlap structure of a set of codewords.

    In coding theory, the support of a codeword is the set of positions
    where it is nonzero. Overlap classes of supports reveal which codewords
    "interact" (share nonzero positions).

    Args:
        codewords: List of codewords (integer vectors).
        verbose: Print analysis.

    Returns:
        Dict with overlap analysis of codeword supports.
    """
    supports = []
    for cw in codewords:
        supp = frozenset(i for i, x in enumerate(cw) if x != 0)
        supports.append(supp)

    n = len(supports)
    parent = list(range(n))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        parent[find(x)] = find(y)

    overlap_count = 0
    signature = []
    for i, j in combinations(range(n), 2):
        c = len(supports[i] & supports[j])
        if c > 0:
            overlap_count += 1
            signature.append(c)
            union(i, j)

    communities = defaultdict(list)
    for i in range(n):
        communities[find(i)].append(i)
    communities = list(communities.values())

    result = {
        'num_codewords': n,
        'supports': supports,
        'overlap_degree': overlap_count,
        'overlap_classes': communities,
        'num_classes': len(communities),
        'overlap_signature': sorted(signature),
    }

    if verbose:
        print("\nCodeword Support Analysis")
        print("-" * 50)
        for i, (cw, supp) in enumerate(zip(codewords, supports)):
            print(f"  Codeword {i}: {cw}  support = {set(supp)}")
        print(f"\nOverlap degree: {overlap_count}")
        print(f"Number of interaction classes: {len(communities)}")
        for i, cls in enumerate(communities):
            print(f"  Class {i}: codewords {cls}")
        print(f"Overlap signature: {sorted(signature)}")
        if overlap_count == 0:
            print("→ All codewords have disjoint supports (fully separated code).")
        else:
            print(f"→ {overlap_count} pairs of codewords share positions.")
            print("  Decoding performance may be affected by these interactions.")

    return result


# ─── Application 3: Signal Path Analysis ────────────────────────────────

def signal_path_analysis(
    circuit_paths: List[Set[str]],
    verbose: bool = True
) -> Dict:
    """
    Analyze signal path interactions in a circuit.

    Each signal path uses a set of circuit components. Paths sharing
    components may interfere. Overlap classes identify independent
    sectors of the circuit.

    Args:
        circuit_paths: List of component sets for each signal path.
        verbose: Print analysis.

    Returns:
        Dict with interaction analysis.
    """
    supports = [frozenset(p) for p in circuit_paths]
    n = len(supports)

    parent = list(range(n))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        parent[find(x)] = find(y)

    for i, j in combinations(range(n), 2):
        if supports[i] & supports[j]:
            union(i, j)

    sectors = defaultdict(list)
    for i in range(n):
        sectors[find(i)].append(i)
    sectors = list(sectors.values())

    result = {
        'num_paths': n,
        'num_independent_sectors': len(sectors),
        'sectors': sectors,
    }

    if verbose:
        print("\nSignal Path Interaction Analysis")
        print("-" * 50)
        for i, path in enumerate(circuit_paths):
            print(f"  Path {i}: components {sorted(path)}")
        print(f"\nIndependent sectors: {len(sectors)}")
        for i, sector in enumerate(sectors):
            print(f"  Sector {i}: paths {sector}")
            shared = set()
            for a, b in combinations(sector, 2):
                shared |= (supports[a] & supports[b])
            if shared:
                print(f"    Shared components: {sorted(shared)}")
                print(f"    → These components may cause cross-talk.")
        if len(sectors) == n:
            print("→ All signal paths are independent. No cross-talk possible.")

    return result


# ─── Main ────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    print("=" * 60)
    print("Applications of Overlap Class Theory")
    print("=" * 60)

    # Application 1: Network routing
    print("\n" + "=" * 60)
    print("APPLICATION 1: Network Infrastructure Analysis")
    print("=" * 60)
    paths = [
        {1, 2, 3, 4},      # Path A: uses nodes 1-4
        {3, 4, 5, 6},      # Path B: shares nodes 3,4 with A
        {7, 8, 9},          # Path C: independent
        {9, 10, 11},        # Path D: shares node 9 with C
        {20, 21, 22},       # Path E: completely independent
    ]
    network_community_detection(paths)

    # Application 2: Coding theory
    print("\n" + "=" * 60)
    print("APPLICATION 2: Error-Correcting Code Analysis")
    print("=" * 60)
    codewords = [
        [1, 1, 0, 0, 0, 0, 0],  # support = {0,1}
        [0, 0, 1, 1, 0, 0, 0],  # support = {2,3}
        [0, 1, 1, 0, 0, 0, 0],  # support = {1,2} — overlaps both!
        [0, 0, 0, 0, 1, 1, 1],  # support = {4,5,6}
    ]
    codeword_support_analysis(codewords)

    # Application 3: Circuit analysis
    print("\n" + "=" * 60)
    print("APPLICATION 3: Circuit Signal Path Analysis")
    print("=" * 60)
    circuit_paths = [
        {'R1', 'C1', 'Op1'},           # Audio path
        {'C1', 'R2', 'Op2'},           # Filter path (shares C1)
        {'R3', 'L1', 'C2'},            # Power path
        {'C2', 'R4', 'Op3'},           # Feedback (shares C2)
        {'R5', 'D1', 'LED1'},          # Indicator (independent)
    ]
    signal_path_analysis(circuit_paths)


"""
demo.py — Interactive Demonstration of Overlap Class Rigidity

This script demonstrates the core mathematical concepts:
1. Support overlap graphs and their connected components (overlap classes)
2. Overlap degree as a measure of interaction complexity
3. The bridge between disjoint-support uniqueness and the overlap regime
4. Computational testing of the overlap class conjecture on small graphs

Usage:
    python demo.py                  # Run all demonstrations
    python demo.py --search N       # Search for counterexamples up to N vertices
    python demo.py --graph K4       # Analyze a specific named graph
"""

import sys
from itertools import combinations
from collections import defaultdict
from typing import List, Set, Tuple, Dict, FrozenSet, Optional


# ─── Core Data Structures ───────────────────────────────────────────────

class SimpleGraph:
    """A simple undirected graph."""
    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        self.n = n
        self.adj = {i: set() for i in range(n)}
        self.edges = []
        for u, v in edges:
            if u != v and v not in self.adj[u]:
                self.adj[u].add(v)
                self.adj[v].add(u)
                self.edges.append((min(u,v), max(u,v)))

    def is_connected(self) -> bool:
        if self.n == 0:
            return True
        visited = set()
        stack = [0]
        while stack:
            v = stack.pop()
            if v in visited:
                continue
            visited.add(v)
            stack.extend(w for w in self.adj[v] if w not in visited)
        return len(visited) == self.n

    def __repr__(self):
        return f"Graph(n={self.n}, edges={self.edges})"


# ─── Overlap Computation ────────────────────────────────────────────────

def compute_overlap_graph(supports: List[FrozenSet]) -> Dict[int, Set[int]]:
    """Build the support overlap graph."""
    n = len(supports)
    adj = {i: set() for i in range(n)}
    for i, j in combinations(range(n), 2):
        if supports[i] & supports[j]:
            adj[i].add(j)
            adj[j].add(i)
    return adj


def compute_overlap_classes(supports: List[FrozenSet]) -> List[Set[int]]:
    """Compute connected components of the overlap graph."""
    n = len(supports)
    if n == 0:
        return []
    parent = list(range(n))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        parent[find(x)] = find(y)

    for i, j in combinations(range(n), 2):
        if supports[i] & supports[j]:
            union(i, j)

    components = defaultdict(set)
    for i in range(n):
        components[find(i)].add(i)
    return list(components.values())


def overlap_degree(supports: List[FrozenSet]) -> int:
    """Count overlapping pairs."""
    return sum(1 for i, j in combinations(range(len(supports)), 2)
               if supports[i] & supports[j])


def overlap_signature(supports: List[FrozenSet]) -> List[int]:
    """Sorted list of intersection sizes for overlapping pairs."""
    sigs = []
    for i, j in combinations(range(len(supports)), 2):
        c = len(supports[i] & supports[j])
        if c > 0:
            sigs.append(c)
    sigs.sort()
    return sigs


def interaction_vertices(supports: List[FrozenSet]) -> Set:
    """Vertices appearing in 2+ supports."""
    count = defaultdict(int)
    for s in supports:
        for v in s:
            count[v] += 1
    return {v for v, c in count.items() if c >= 2}


# ─── Cycle Support Computation ──────────────────────────────────────────

def find_cycle_supports(G: SimpleGraph, S: Set[int]) -> List[FrozenSet[int]]:
    """Find fundamental cycle supports in G[S] using DFS."""
    vertices = sorted(S)
    adj_local = {v: set() for v in vertices}
    for v in vertices:
        for w in G.adj.get(v, set()):
            if w in S:
                adj_local[v].add(w)

    visited = set()
    parent = {}
    cycles = []

    def dfs(v, p):
        visited.add(v)
        parent[v] = p
        for w in adj_local[v]:
            if w == p:
                continue
            if w in visited:
                cycle = {w}
                u = v
                while u != w:
                    cycle.add(u)
                    u = parent[u]
                cycles.append(frozenset(cycle))
            elif w not in visited:
                dfs(w, v)

    for v in vertices:
        if v not in visited:
            dfs(v, None)

    return cycles


# ─── Named Graphs ───────────────────────────────────────────────────────

NAMED_GRAPHS = {
    'K3': SimpleGraph(3, [(0,1),(1,2),(0,2)]),
    'K4': SimpleGraph(4, [(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)]),
    'C4': SimpleGraph(4, [(0,1),(1,2),(2,3),(3,0)]),
    'C5': SimpleGraph(5, [(0,1),(1,2),(2,3),(3,4),(4,0)]),
    'K33': SimpleGraph(6, [(0,3),(0,4),(0,5),(1,3),(1,4),(1,5),(2,3),(2,4),(2,5)]),
    'petersen': SimpleGraph(10, [
        (0,1),(1,2),(2,3),(3,4),(4,0),
        (5,7),(7,9),(9,6),(6,8),(8,5),
        (0,5),(1,6),(2,7),(3,8),(4,9)
    ]),
    'diamond': SimpleGraph(4, [(0,1),(1,2),(2,3),(0,2)]),
    'theta': SimpleGraph(5, [(0,1),(1,2),(2,3),(3,0),(0,4),(4,2)]),
}


# ─── Demonstration Functions ────────────────────────────────────────────

def demo_basic_concepts():
    """Demonstrate the basic overlap class concepts."""
    print("=" * 60)
    print("DEMO 1: Basic Overlap Class Concepts")
    print("=" * 60)

    # Disjoint case
    print("\n--- Pairwise Disjoint Supports ---")
    supports = [frozenset({0,1}), frozenset({2,3}), frozenset({4,5})]
    print(f"Supports: {[set(s) for s in supports]}")
    print(f"Overlap degree: {overlap_degree(supports)}")
    classes = compute_overlap_classes(supports)
    print(f"Overlap classes: {len(classes)} classes")
    for i, cls in enumerate(classes):
        print(f"  Class {i}: indices {cls} → supports {[set(supports[j]) for j in cls]}")
    print(f"Interaction vertices: {interaction_vertices(supports)}")
    print(f"→ This is the disjoint regime: each support is its own class.")

    # Overlapping case
    print("\n--- Overlapping Supports ---")
    supports = [frozenset({0,1,2}), frozenset({1,2,3}), frozenset({4,5})]
    print(f"Supports: {[set(s) for s in supports]}")
    print(f"Overlap degree: {overlap_degree(supports)}")
    classes = compute_overlap_classes(supports)
    print(f"Overlap classes: {len(classes)} classes")
    for i, cls in enumerate(classes):
        print(f"  Class {i}: indices {cls} → supports {[set(supports[j]) for j in cls]}")
    print(f"Overlap signature: {overlap_signature(supports)}")
    print(f"Interaction vertices: {interaction_vertices(supports)}")
    print(f"→ Supports 0 and 1 share vertices {{1,2}}, forming one overlap class.")
    print(f"  Support 2 is isolated — it forms its own class.")

    # Chain overlap
    print("\n--- Chain Overlap (Transitive Closure) ---")
    supports = [frozenset({0,1}), frozenset({1,2}), frozenset({2,3}), frozenset({5,6})]
    print(f"Supports: {[set(s) for s in supports]}")
    print(f"Overlap degree: {overlap_degree(supports)}")
    classes = compute_overlap_classes(supports)
    print(f"Overlap classes: {len(classes)} classes")
    for i, cls in enumerate(classes):
        print(f"  Class {i}: indices {cls}")
    print(f"→ Supports 0,1,2 form a chain: 0∩1≠∅, 1∩2≠∅ → all three in one class.")
    print(f"  Even though 0∩2=∅! This is the transitive closure at work.")


def demo_graph_analysis(name: str = 'K4'):
    """Analyze overlap structure of a specific graph."""
    print("\n" + "=" * 60)
    print(f"DEMO 2: Graph Analysis — {name}")
    print("=" * 60)

    G = NAMED_GRAPHS.get(name)
    if G is None:
        print(f"Unknown graph: {name}")
        print(f"Available: {', '.join(NAMED_GRAPHS.keys())}")
        return

    print(f"\nGraph: {G.n} vertices, {len(G.edges)} edges")
    print(f"Edges: {G.edges}")

    for q in range(min(G.n, 3)):
        S = set(range(G.n)) - {q}
        print(f"\n--- Basepoint q={q}, S={S} ---")
        cycle_supports = find_cycle_supports(G, S)
        print(f"Cycle supports in G[S]: {[set(s) for s in cycle_supports]}")

        if cycle_supports:
            od = overlap_degree(cycle_supports)
            classes = compute_overlap_classes(cycle_supports)
            sig = overlap_signature(cycle_supports)
            iv = interaction_vertices(cycle_supports)

            print(f"Overlap degree: {od}")
            print(f"Overlap classes: {len(classes)}")
            print(f"Overlap signature: {sig}")
            print(f"Interaction vertices: {iv}")
            print(f"Pairwise disjoint: {od == 0}")
        else:
            print("No cycles (G[S] is a forest).")


def demo_conjecture_search(max_n: int = 6):
    """Search for overlap patterns across small graphs."""
    print("\n" + "=" * 60)
    print(f"DEMO 3: Conjecture Search (n ≤ {max_n})")
    print("=" * 60)

    total = 0
    disjoint = 0
    overlapping = 0
    max_od = 0
    max_classes = 0
    interesting = []

    for n in range(3, max_n + 1):
        # Generate connected graphs
        all_edges = list(combinations(range(n), 2))
        m = len(all_edges)
        count_n = 0

        for mask in range(1, min(1 << m, 2**15)):  # cap for efficiency
            edges = [all_edges[i] for i in range(m) if mask & (1 << i)]
            G = SimpleGraph(n, edges)
            if not G.is_connected():
                continue
            count_n += 1

            for q in range(n):
                S = set(range(n)) - {q}
                cs = find_cycle_supports(G, S)
                if not cs:
                    continue

                total += 1
                od = overlap_degree(cs)
                classes = compute_overlap_classes(cs)
                nc = len(classes)

                if od == 0:
                    disjoint += 1
                else:
                    overlapping += 1

                max_od = max(max_od, od)
                max_classes = max(max_classes, nc)

                if od > 0 and len(interesting) < 5:
                    interesting.append({
                        'n': n, 'q': q, 'edges': G.edges,
                        'supports': [set(s) for s in cs],
                        'overlap_deg': od,
                        'classes': nc,
                        'signature': overlap_signature(cs),
                    })

        print(f"  n={n}: tested {count_n} connected graphs")

    print(f"\nSummary:")
    print(f"  Total (G,q,S) triples with cycles: {total}")
    print(f"  Disjoint cases (overlap degree 0): {disjoint}")
    print(f"  Overlapping cases: {overlapping}")
    print(f"  Max overlap degree seen: {max_od}")
    print(f"  Max overlap classes seen: {max_classes}")

    if interesting:
        print(f"\nInteresting overlapping examples:")
        for ex in interesting:
            print(f"  n={ex['n']}, q={ex['q']}, edges={ex['edges']}")
            print(f"    supports={ex['supports']}")
            print(f"    overlap_deg={ex['overlap_deg']}, classes={ex['classes']}")
            print(f"    signature={ex['signature']}")


def demo_invariance():
    """Demonstrate that overlap classes are invariant under permutation."""
    print("\n" + "=" * 60)
    print("DEMO 4: Overlap Class Invariance Under Permutation")
    print("=" * 60)

    supports = [frozenset({0,1,2}), frozenset({2,3}), frozenset({3,4,5})]
    print(f"\nOriginal supports: {[set(s) for s in supports]}")

    classes_orig = compute_overlap_classes(supports)
    sig_orig = overlap_signature(supports)
    print(f"Overlap classes: {classes_orig}")
    print(f"Overlap signature: {sig_orig}")

    # Apply a permutation to the index set
    perm = [2, 0, 1]  # σ: 0↦2, 1↦0, 2↦1
    permuted = [supports[perm[i]] for i in range(len(supports))]
    print(f"\nPermuted supports (σ=[2,0,1]): {[set(s) for s in permuted]}")

    classes_perm = compute_overlap_classes(permuted)
    sig_perm = overlap_signature(permuted)
    print(f"Overlap classes: {classes_perm}")
    print(f"Overlap signature: {sig_perm}")

    print(f"\nSignatures match: {sig_orig == sig_perm}")
    print(f"Class counts match: {len(classes_orig) == len(classes_perm)}")
    print(f"→ Overlap structure is invariant under reindexing (Theorem B)")


def main():
    args = sys.argv[1:]

    if '--search' in args:
        idx = args.index('--search')
        max_n = int(args[idx + 1]) if idx + 1 < len(args) else 6
        demo_conjecture_search(max_n)
    elif '--graph' in args:
        idx = args.index('--graph')
        name = args[idx + 1] if idx + 1 < len(args) else 'K4'
        demo_graph_analysis(name)
    else:
        demo_basic_concepts()
        demo_graph_analysis('K4')
        demo_graph_analysis('diamond')
        demo_invariance()
        demo_conjecture_search(5)


if __name__ == '__main__':
    main()


"""
Visualization: Support Overlap Graph and Overlap Classes

This script visualizes the support overlap graph for a family of finite sets.
It shows how supports are connected via shared elements and colors the
connected components (overlap classes) distinctly.

What it visualizes:
- Each node represents a support set in the family
- Edges connect supports with nonempty intersection
- Colors indicate overlap classes (connected components)
- Node labels show the support elements
- Edge labels show shared elements
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations
from collections import defaultdict


def compute_overlap_classes(supports):
    """Compute overlap classes using union-find."""
    n = len(supports)
    parent = list(range(n))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        parent[find(x)] = find(y)

    edges = []
    for i, j in combinations(range(n), 2):
        shared = supports[i] & supports[j]
        if shared:
            union(i, j)
            edges.append((i, j, shared))

    components = defaultdict(list)
    for i in range(n):
        components[find(i)].append(i)

    return list(components.values()), edges


def layout_circular(n, radius=2.0):
    """Compute circular layout positions."""
    positions = {}
    for i in range(n):
        angle = 2 * np.pi * i / n - np.pi / 2
        positions[i] = (radius * np.cos(angle), radius * np.sin(angle))
    return positions


def draw_overlap_graph(supports, title="Support Overlap Graph", ax=None):
    """Draw the support overlap graph with colored overlap classes."""
    if ax is None:
        fig, ax = plt.subplots(1, 1, figsize=(10, 8))
    else:
        fig = ax.figure

    n = len(supports)
    classes, edges = compute_overlap_classes(supports)
    positions = layout_circular(n)

    # Color palette for classes
    colors = plt.cm.Set2(np.linspace(0, 1, max(len(classes), 1)))

    # Map index to class color
    idx_to_color = {}
    for ci, cls in enumerate(classes):
        for idx in cls:
            idx_to_color[idx] = colors[ci]

    # Draw edges
    for i, j, shared in edges:
        x = [positions[i][0], positions[j][0]]
        y = [positions[i][1], positions[j][1]]
        ax.plot(x, y, 'k-', alpha=0.4, linewidth=2)
        # Label edge with shared elements
        mx, my = (x[0]+x[1])/2, (y[0]+y[1])/2
        ax.annotate(f"∩={set(shared)}", (mx, my),
                   fontsize=7, ha='center', va='center',
                   bbox=dict(boxstyle='round,pad=0.2', facecolor='lightyellow', alpha=0.8))

    # Draw nodes
    for i in range(n):
        x, y = positions[i]
        circle = plt.Circle((x, y), 0.4, color=idx_to_color[i],
                           ec='black', linewidth=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, f"S{i}\n{set(supports[i])}", ha='center', va='center',
               fontsize=8, fontweight='bold', zorder=6)

    # Legend
    legend_patches = []
    for ci, cls in enumerate(classes):
        patch = mpatches.Patch(color=colors[ci],
                              label=f"Class {ci}: indices {cls}")
        legend_patches.append(patch)
    ax.legend(handles=legend_patches, loc='upper left', fontsize=9)

    ax.set_xlim(-3.5, 3.5)
    ax.set_ylim(-3.5, 3.5)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=14, fontweight='bold')
    ax.axis('off')

    return fig, ax


# Create the visualization
fig, axes = plt.subplots(2, 2, figsize=(16, 14))
fig.suptitle("Support Overlap Graphs and Overlap Classes", fontsize=16, fontweight='bold')

# Example 1: Fully disjoint
supports1 = [
    frozenset({0, 1}),
    frozenset({2, 3}),
    frozenset({4, 5}),
    frozenset({6, 7}),
]
draw_overlap_graph(supports1, "Pairwise Disjoint\n(4 classes, 0 edges)", axes[0, 0])

# Example 2: Single overlap
supports2 = [
    frozenset({0, 1, 2}),
    frozenset({2, 3, 4}),
    frozenset({5, 6}),
    frozenset({7, 8}),
]
draw_overlap_graph(supports2, "Single Overlap\n(3 classes, 1 edge)", axes[0, 1])

# Example 3: Chain overlap
supports3 = [
    frozenset({0, 1}),
    frozenset({1, 2}),
    frozenset({2, 3}),
    frozenset({5, 6}),
]
draw_overlap_graph(supports3, "Chain Overlap\n(2 classes, 2 edges)", axes[1, 0])

# Example 4: Dense overlap
supports4 = [
    frozenset({0, 1, 2}),
    frozenset({1, 2, 3}),
    frozenset({2, 3, 4}),
    frozenset({0, 4}),
]
draw_overlap_graph(supports4, "Dense Overlap\n(1 class, 5 edges)", axes[1, 1])

plt.tight_layout()
plt.savefig('overlap_graph_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved overlap_graph_visualization.png")


"""
Visualization: Cross-Overlap Count Heatmap

This script creates a heatmap showing the pairwise intersection sizes
between supports in a family. The heatmap makes the overlap pattern
immediately visible: disjoint pairs appear as zeros (white), while
overlapping pairs show the intersection cardinality (colored).

What it visualizes:
- Pairwise intersection cardinalities between all supports
- Darker colors indicate larger intersections
- Block-diagonal structure reveals overlap classes
- Annotations show exact intersection sizes
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from collections import defaultdict


def compute_cross_overlap_matrix(supports):
    """Compute the matrix of pairwise intersection sizes."""
    n = len(supports)
    matrix = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(n):
            matrix[i, j] = len(supports[i] & supports[j])
    return matrix


def compute_overlap_classes(supports):
    """Compute overlap classes using union-find."""
    n = len(supports)
    parent = list(range(n))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        parent[find(x)] = find(y)

    for i, j in combinations(range(n), 2):
        if supports[i] & supports[j]:
            union(i, j)

    components = defaultdict(list)
    for i in range(n):
        components[find(i)].append(i)
    return list(components.values())


def reorder_by_classes(supports, classes):
    """Reorder indices so that overlap classes are contiguous."""
    order = []
    for cls in classes:
        order.extend(sorted(cls))
    return order


def draw_heatmap(supports, title, ax):
    """Draw the cross-overlap heatmap."""
    classes = compute_overlap_classes(supports)
    order = reorder_by_classes(supports, classes)
    n = len(supports)

    reordered = [supports[i] for i in order]
    matrix = compute_cross_overlap_matrix(reordered)

    # Zero out diagonal for cleaner visualization
    np.fill_diagonal(matrix, 0)

    im = ax.imshow(matrix, cmap='YlOrRd', aspect='equal', vmin=0)

    # Add text annotations
    for i in range(n):
        for j in range(n):
            val = matrix[i, j]
            color = 'white' if val > 2 else 'black'
            ax.text(j, i, str(val), ha='center', va='center',
                   fontsize=10, fontweight='bold', color=color)

    # Labels
    labels = [f"S{order[i]}" for i in range(n)]
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels(labels, fontsize=9)
    ax.set_yticklabels(labels, fontsize=9)

    # Draw class boundaries
    pos = 0
    for cls in classes:
        size = len(cls)
        if pos > 0:
            ax.axhline(y=pos - 0.5, color='blue', linewidth=2, linestyle='--')
            ax.axvline(x=pos - 0.5, color='blue', linewidth=2, linestyle='--')
        pos += size

    ax.set_title(title, fontsize=12, fontweight='bold')
    return im


# Create the visualization
fig, axes = plt.subplots(2, 2, figsize=(14, 12))
fig.suptitle("Cross-Overlap Count Heatmaps\n(Blue dashed lines separate overlap classes)",
             fontsize=14, fontweight='bold')

# Example 1: Fully disjoint (6 supports)
supports1 = [
    frozenset({0, 1}), frozenset({2, 3}), frozenset({4, 5}),
    frozenset({6, 7}), frozenset({8, 9}), frozenset({10, 11}),
]
draw_heatmap(supports1, "Disjoint: 6 classes", axes[0, 0])

# Example 2: Two clusters
supports2 = [
    frozenset({0, 1, 2}), frozenset({1, 2, 3}), frozenset({2, 3, 4}),
    frozenset({10, 11}), frozenset({11, 12}), frozenset({20, 21}),
]
draw_heatmap(supports2, "Two clusters + isolated", axes[0, 1])

# Example 3: Chain
supports3 = [
    frozenset({0, 1}), frozenset({1, 2}), frozenset({2, 3}),
    frozenset({3, 4}), frozenset({4, 5}), frozenset({10, 11}),
]
draw_heatmap(supports3, "Chain + isolated", axes[1, 0])

# Example 4: Star
supports4 = [
    frozenset({0, 1, 2, 3}),
    frozenset({0, 4, 5}),
    frozenset({0, 6, 7}),
    frozenset({0, 8, 9}),
    frozenset({0, 10, 11}),
    frozenset({20, 21}),
]
draw_heatmap(supports4, "Star pattern + isolated", axes[1, 1])

plt.tight_layout()
plt.savefig('overlap_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved overlap_heatmap.png")


"""
Visualization: Overlap Degree Statistics Across Small Graphs

This script generates statistics about overlap patterns across all
connected graphs on n vertices, showing how overlap degree distributes
and how the number of overlap classes varies with graph structure.

What it visualizes:
- Distribution of overlap degrees across small graphs
- Relationship between graph density and overlap degree
- Number of overlap classes vs number of cycle supports
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from collections import defaultdict


def find_cycle_supports_local(n_vertices, edges, S):
    """Find cycle supports in the induced subgraph."""
    vertices = sorted(S)
    adj = {v: set() for v in vertices}
    for u, v in edges:
        if u in S and v in S:
            adj[u].add(v)
            adj[v].add(u)

    visited = set()
    parent = {}
    cycles = []

    def dfs(v, p):
        visited.add(v)
        parent[v] = p
        for w in adj[v]:
            if w == p:
                continue
            if w in visited:
                cycle = {w}
                u = v
                while u != w:
                    cycle.add(u)
                    u = parent[u]
                cycles.append(frozenset(cycle))
            elif w not in visited:
                dfs(w, v)

    for v in vertices:
        if v not in visited:
            dfs(v, None)
    return cycles


def overlap_degree_local(supports):
    """Count overlapping pairs."""
    return sum(1 for i, j in combinations(range(len(supports)), 2)
               if supports[i] & supports[j])


def overlap_classes_local(supports):
    """Count overlap classes."""
    n = len(supports)
    if n == 0:
        return 0
    parent = list(range(n))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        parent[find(x)] = find(y)
    for i, j in combinations(range(n), 2):
        if supports[i] & supports[j]:
            union(i, j)
    return len(set(find(i) for i in range(n)))


def is_connected(n, edges):
    """Check if graph is connected."""
    if n <= 1:
        return True
    adj = {i: set() for i in range(n)}
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)
    visited = set()
    stack = [0]
    while stack:
        v = stack.pop()
        if v in visited:
            continue
        visited.add(v)
        stack.extend(w for w in adj[v] if w not in visited)
    return len(visited) == n


# Collect statistics
print("Computing overlap statistics for small graphs...")

overlap_degrees = []
class_counts = []
support_counts = []
graph_densities = []

for n in range(3, 7):
    all_edges = list(combinations(range(n), 2))
    max_edges = len(all_edges)

    for mask in range(1, min(1 << max_edges, 2**13)):
        edges = [all_edges[i] for i in range(max_edges) if mask & (1 << i)]
        if not is_connected(n, edges):
            continue

        density = len(edges) / max_edges

        for q in range(n):
            S = set(range(n)) - {q}
            cs = find_cycle_supports_local(n, edges, S)
            if not cs:
                continue

            od = overlap_degree_local(cs)
            nc = overlap_classes_local(cs)

            overlap_degrees.append(od)
            class_counts.append(nc)
            support_counts.append(len(cs))
            graph_densities.append(density)

print(f"Collected {len(overlap_degrees)} data points")

# Create the visualization
fig, axes = plt.subplots(2, 2, figsize=(14, 11))
fig.suptitle("Overlap Structure Statistics Across Small Graphs (n ≤ 6)",
             fontsize=14, fontweight='bold')

# Plot 1: Distribution of overlap degrees
ax = axes[0, 0]
max_od = max(overlap_degrees) if overlap_degrees else 0
bins = range(0, max_od + 2)
ax.hist(overlap_degrees, bins=bins, color='steelblue', edgecolor='black', alpha=0.8, align='left')
ax.set_xlabel('Overlap Degree', fontsize=11)
ax.set_ylabel('Frequency', fontsize=11)
ax.set_title('Distribution of Overlap Degrees', fontsize=12, fontweight='bold')
ax.axvline(x=0, color='red', linestyle='--', alpha=0.5, label='Disjoint regime')
ax.legend(fontsize=9)

# Plot 2: Overlap degree vs graph density
ax = axes[0, 1]
ax.scatter(graph_densities, overlap_degrees, alpha=0.15, s=10, c='steelblue')
ax.set_xlabel('Graph Density (|E|/max|E|)', fontsize=11)
ax.set_ylabel('Overlap Degree', fontsize=11)
ax.set_title('Overlap Degree vs Graph Density', fontsize=12, fontweight='bold')

# Add trend line
if graph_densities:
    z = np.polyfit(graph_densities, overlap_degrees, 2)
    p = np.poly1d(z)
    xs = np.linspace(min(graph_densities), max(graph_densities), 100)
    ax.plot(xs, p(xs), 'r-', linewidth=2, alpha=0.7, label='Quadratic fit')
    ax.legend(fontsize=9)

# Plot 3: Number of overlap classes vs number of supports
ax = axes[1, 0]
ax.scatter(support_counts, class_counts, alpha=0.2, s=15, c='green')
# Add y = x line
max_sc = max(support_counts) if support_counts else 1
ax.plot([0, max_sc], [0, max_sc], 'r--', alpha=0.5, label='Classes = Supports (all disjoint)')
ax.set_xlabel('Number of Cycle Supports', fontsize=11)
ax.set_ylabel('Number of Overlap Classes', fontsize=11)
ax.set_title('Overlap Classes vs Cycle Supports', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)

# Plot 4: Fraction of overlapping cases by n
ax = axes[1, 1]
fracs = {}
for n in range(3, 7):
    all_edges = list(combinations(range(n), 2))
    max_edges = len(all_edges)
    total = 0
    overlapping = 0
    for mask in range(1, min(1 << max_edges, 2**13)):
        edges = [all_edges[i] for i in range(max_edges) if mask & (1 << i)]
        if not is_connected(n, edges):
            continue
        for q in range(n):
            S = set(range(n)) - {q}
            cs = find_cycle_supports_local(n, edges, S)
            if cs:
                total += 1
                if overlap_degree_local(cs) > 0:
                    overlapping += 1
    if total > 0:
        fracs[n] = overlapping / total

ns = sorted(fracs.keys())
vals = [fracs[n] for n in ns]
ax.bar(ns, vals, color='coral', edgecolor='black', alpha=0.8)
ax.set_xlabel('Number of Vertices (n)', fontsize=11)
ax.set_ylabel('Fraction with Overlap', fontsize=11)
ax.set_title('Fraction of Overlapping Instances by n', fontsize=12, fontweight='bold')
for i, (n, v) in enumerate(zip(ns, vals)):
    ax.text(n, v + 0.01, f'{v:.2%}', ha='center', fontsize=10)

plt.tight_layout()
plt.savefig('overlap_statistics.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved overlap_statistics.png")
