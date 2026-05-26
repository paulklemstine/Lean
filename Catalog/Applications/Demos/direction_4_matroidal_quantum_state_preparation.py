"""
Matroidal Quantum State Preparation — Applications

Demonstrates real-world applications of matroid-based quantum sampling:
1. Network reliability via spanning-tree sampling
2. Constrained random generation via partition matroids  
3. Determinantal point process connections

Application keywords: quantum sampling, spanning trees, network reliability,
constrained random generation, partition functions, statistical mechanics.
"""

from __future__ import annotations
import itertools
import math
import random
from typing import Dict, FrozenSet, List, Set, Tuple
from dataclasses import dataclass


# ===========================================================================
# Inline core (self-contained)
# ===========================================================================

@dataclass
class FiniteMatroid:
    ground_set: FrozenSet[int]
    bases: Set[FrozenSet[int]]

    @property
    def rank(self) -> int:
        return len(next(iter(self.bases)))


def basis_weight(B: FrozenSet[int], w: Dict[int, float]) -> float:
    return math.prod(w.get(e, 1.0) for e in B)


def partition_function(M: FiniteMatroid, w: Dict[int, float]) -> float:
    return sum(basis_weight(B, w) for B in M.bases)


def weighted_basis_probs(M: FiniteMatroid, w: Dict[int, float]) -> Dict[FrozenSet[int], float]:
    Z = partition_function(M, w)
    if Z == 0:
        return {}
    return {B: basis_weight(B, w) / Z for B in M.bases}


def graphic_matroid(n_verts: int, edges: List[Tuple[int, int]]) -> FiniteMatroid:
    n = n_verts

    def is_forest(es):
        parent = list(range(n))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        for idx in es:
            u, v = edges[idx]
            rx, ry = find(u), find(v)
            if rx == ry:
                return False
            parent[rx] = ry
        return True

    def spans(es):
        if n <= 1:
            return True
        adj = {i: set() for i in range(n)}
        for idx in es:
            u, v = edges[idx]
            adj[u].add(v)
            adj[v].add(u)
        visited = set()
        stack = [0]
        while stack:
            nd = stack.pop()
            if nd in visited:
                continue
            visited.add(nd)
            stack.extend(adj[nd] - visited)
        return len(visited) == n

    bases = set()
    for combo in itertools.combinations(range(len(edges)), n - 1):
        fs = frozenset(combo)
        if is_forest(fs) and spans(fs):
            bases.add(fs)
    return FiniteMatroid(frozenset(range(len(edges))), bases)


# ===========================================================================
# Application 1: Network Reliability Analysis
# ===========================================================================

def network_reliability_analysis():
    """
    Spanning-tree based network reliability analysis.
    
    For a communication network modeled as a graph, each edge has a
    reliability weight. The spanning-tree partition function measures
    the total 'connectivity strength', and the weighted basis distribution
    tells us which spanning trees are most likely under random failures.
    """
    print("=" * 70)
    print("  Application 1: Network Reliability Analysis")
    print("=" * 70)
    
    # Small network: 5 nodes connected in a specific topology
    edges = [
        (0, 1),  # link 0: high reliability
        (1, 2),  # link 1: medium reliability  
        (2, 3),  # link 2: high reliability
        (3, 4),  # link 3: medium reliability
        (0, 4),  # link 4: low reliability (backup link)
        (1, 3),  # link 5: high reliability (cross-link)
    ]
    
    # Reliability weights (higher = more reliable)
    reliability = {0: 0.95, 1: 0.80, 2: 0.90, 3: 0.75, 4: 0.50, 5: 0.85}
    
    M = graphic_matroid(5, edges)
    probs = weighted_basis_probs(M, reliability)
    Z = partition_function(M, reliability)
    
    print(f"\nNetwork: 5 nodes, {len(edges)} links")
    print(f"Link reliabilities: {reliability}")
    print(f"Number of spanning trees: {len(M.bases)}")
    print(f"Connectivity strength (partition function): {Z:.6f}")
    print()
    
    # Sort by probability
    sorted_trees = sorted(probs.items(), key=lambda x: -x[1])
    
    print("Top 5 most likely spanning trees under reliability model:")
    for i, (B, prob) in enumerate(sorted_trees[:5]):
        tree_edges = [edges[idx] for idx in sorted(B)]
        bw = basis_weight(B, reliability)
        print(f"  {i+1}. {tree_edges}: weight={bw:.6f}, prob={prob:.4f}")
    
    # Edge importance: how often each edge appears in high-probability trees
    print("\nEdge importance (weighted frequency in spanning trees):")
    for eidx in range(len(edges)):
        edge_prob = sum(p for B, p in probs.items() if eidx in B)
        print(f"  Edge {eidx} {edges[eidx]}: importance = {edge_prob:.4f}")
    
    # What if we upgrade the backup link?
    reliability_upgraded = dict(reliability)
    reliability_upgraded[4] = 0.90  # upgrade backup link
    Z_new = partition_function(M, reliability_upgraded)
    print(f"\nAfter upgrading backup link (0,4) to 0.90:")
    print(f"  Connectivity strength: {Z:.6f} → {Z_new:.6f} "
          f"(+{(Z_new/Z - 1)*100:.1f}%)")


# ===========================================================================
# Application 2: Fair Team Selection (Partition Matroid)
# ===========================================================================

def fair_team_selection():
    """
    Partition matroid for fair constrained selection.
    
    Select one candidate from each department for a committee,
    where each candidate has a competence score. The weighted basis
    distribution gives the exact probability of each committee
    composition under score-proportional random selection.
    """
    print("\n" + "=" * 70)
    print("  Application 2: Fair Team Selection via Partition Matroid")
    print("=" * 70)
    
    departments = {
        "Engineering": [0, 1, 2],
        "Design": [3, 4],
        "Marketing": [5, 6, 7],
    }
    
    competence = {
        0: 8.5,  1: 7.2,  2: 9.1,   # Engineering
        3: 8.8,  4: 7.5,              # Design
        5: 6.9,  6: 8.0,  7: 7.7,    # Marketing
    }
    
    blocks = list(departments.values())
    all_elems = [e for block in blocks for e in block]
    ground = frozenset(all_elems)
    
    # Generate all committees (one from each department)
    choices = [list(itertools.combinations(b, 1)) for b in blocks]
    bases = set()
    for combo in itertools.product(*choices):
        B = frozenset(e for grp in combo for e in grp)
        bases.add(B)
    
    M = FiniteMatroid(ground, bases)
    probs = weighted_basis_probs(M, competence)
    Z = partition_function(M, competence)
    
    dept_names = list(departments.keys())
    person_dept = {}
    for dept, members in departments.items():
        for m in members:
            person_dept[m] = dept
    
    print(f"\nDepartments and competence scores:")
    for dept, members in departments.items():
        scores = [f"#{m}({competence[m]})" for m in members]
        print(f"  {dept}: {', '.join(scores)}")
    
    print(f"\nTotal committees: {len(M.bases)}")
    print(f"Partition function: {Z:.2f}")
    print()
    
    # Verify factorization
    Z_factored = 1.0
    for block in blocks:
        Z_factored *= sum(competence[e] for e in block)
    print(f"Factorization check: Z = {Z:.2f}, product of block sums = {Z_factored:.2f}")
    
    print("\nAll committee compositions (sorted by probability):")
    for B, prob in sorted(probs.items(), key=lambda x: -x[1]):
        members = [f"#{e}({person_dept[e]})" for e in sorted(B)]
        print(f"  {', '.join(members)}: prob = {prob:.4f}")
    
    # Individual selection probabilities
    print("\nIndividual selection probabilities:")
    for e in sorted(competence.keys()):
        ind_prob = sum(p for B, p in probs.items() if e in B)
        dept = person_dept[e]
        dept_total = sum(competence[m] for m in departments[dept])
        expected = competence[e] / dept_total
        print(f"  #{e} ({dept}): prob = {ind_prob:.4f} "
              f"(expected from block: {expected:.4f})")


# ===========================================================================
# Application 3: Spanning-Tree Entropy and Network Robustness
# ===========================================================================

def spanning_tree_entropy():
    """
    Compute the entropy of the weighted spanning-tree distribution
    as a measure of network robustness.
    
    Higher entropy = more uniform spanning tree distribution = more
    structurally redundant network.
    """
    print("\n" + "=" * 70)
    print("  Application 3: Spanning-Tree Entropy & Network Robustness")
    print("=" * 70)
    
    networks = {
        "Star (K_{1,4})": (5, [(0,1),(0,2),(0,3),(0,4)]),
        "Cycle C₅": (5, [(0,1),(1,2),(2,3),(3,4),(4,0)]),
        "K₅ complete": (5, [(i,j) for i in range(5) for j in range(i+1,5)]),
        "Petersen-like": (5, [(0,1),(1,2),(2,3),(3,4),(4,0),(0,2),(1,3),(2,4),(3,0),(4,1)]),
    }
    
    print(f"\n{'Network':<20} | {'#Trees':>7} | {'Entropy':>8} | {'Max Entropy':>10} | {'Ratio':>6}")
    print("-" * 65)
    
    for name, (n, edges) in networks.items():
        M = graphic_matroid(n, edges)
        # Uniform weights
        w = {i: 1.0 for i in range(len(edges))}
        probs = weighted_basis_probs(M, w)
        
        entropy = -sum(p * math.log2(p) for p in probs.values() if p > 0)
        max_entropy = math.log2(len(M.bases)) if len(M.bases) > 0 else 0
        ratio = entropy / max_entropy if max_entropy > 0 else 0
        
        print(f"{name:<20} | {len(M.bases):7d} | {entropy:8.4f} | {max_entropy:10.4f} | {ratio:6.4f}")
    
    print("\n(Ratio close to 1.0 = uniform distribution over spanning trees = max robustness)")


# ===========================================================================
# Main
# ===========================================================================

if __name__ == "__main__":
    network_reliability_analysis()
    fair_team_selection()
    spanning_tree_entropy()


"""
Matroidal Quantum State Preparation — Interactive Demo

Demonstrates the matroid basis certificate compilation pipeline for
quantum state preparation, verifying exact correspondence between
compiled amplitudes and weighted basis distributions.

Application keywords: quantum sampling, matroid bases, Lorentzian polynomials,
combinatorial Hodge theory, spanning trees, network reliability, partition functions,
negative dependence, basis exchange walk, graphic matroids, partition matroids.
"""

from __future__ import annotations
import itertools
import math
from dataclasses import dataclass
from typing import FrozenSet, Dict, List, Set, Tuple


# ===========================================================================
# Inline core implementations (self-contained)
# ===========================================================================

@dataclass
class FiniteMatroid:
    ground_set: FrozenSet[int]
    bases: Set[FrozenSet[int]]

    @property
    def rank(self) -> int:
        return len(next(iter(self.bases)))

    def deletion(self, e: int) -> 'FiniteMatroid':
        new_bases = {B for B in self.bases if e not in B}
        if not new_bases:
            return FiniteMatroid(self.ground_set - {e}, {frozenset()})
        return FiniteMatroid(self.ground_set - {e}, new_bases)

    def contraction(self, e: int) -> 'FiniteMatroid':
        new_bases = {B - {e} for B in self.bases if e in B}
        if not new_bases:
            return FiniteMatroid(self.ground_set - {e}, {frozenset()})
        return FiniteMatroid(self.ground_set - {e}, new_bases)


def basis_weight(B: FrozenSet[int], w: Dict[int, float]) -> float:
    return math.prod(w.get(e, 1.0) for e in B)


def partition_function(M: FiniteMatroid, w: Dict[int, float]) -> float:
    return sum(basis_weight(B, w) for B in M.bases)


def compile_certificate(M: FiniteMatroid, w: Dict[int, float]):
    """Recursive deletion/contraction certificate compilation."""
    amplitudes = {}
    depth = [0]
    size = [0]

    def _recurse(M_sub, prefix, d):
        size[0] += 1
        depth[0] = max(depth[0], d)

        if not M_sub.ground_set or len(M_sub.bases) <= 1:
            for B_local in M_sub.bases:
                B = prefix | B_local
                bw = basis_weight(B, w)
                amplitudes[B] = math.sqrt(bw)
            return

        e = min(M_sub.ground_set)

        # Deletion: bases not containing e
        del_bases = {B for B in M_sub.bases if e not in B}
        if del_bases:
            M_del = FiniteMatroid(M_sub.ground_set - {e}, del_bases)
            _recurse(M_del, prefix, d + 1)

        # Contraction: bases containing e, remove e
        con_bases = {B - {e} for B in M_sub.bases if e in B}
        if con_bases:
            M_con = FiniteMatroid(M_sub.ground_set - {e}, con_bases)
            _recurse(M_con, prefix | {e}, d + 1)

    _recurse(M, frozenset(), 0)
    return amplitudes, depth[0], size[0]


def total_variation(M, w, amplitudes):
    Z_exact = partition_function(M, w)
    Z_compiled = sum(a ** 2 for a in amplitudes.values())
    if Z_exact == 0 or Z_compiled == 0:
        return 1.0
    tv = sum(
        abs(amplitudes.get(B, 0) ** 2 / Z_compiled - basis_weight(B, w) / Z_exact)
        for B in M.bases
    )
    return tv / 2


def max_amp_error(M, w, amplitudes):
    return max(
        abs(amplitudes.get(B, 0) - math.sqrt(basis_weight(B, w)))
        for B in M.bases
    )


# ===========================================================================
# Matroid constructors
# ===========================================================================

def uniform_matroid(n, k):
    ground = frozenset(range(n))
    bases = {frozenset(S) for S in itertools.combinations(range(n), k)}
    return FiniteMatroid(ground, bases)


def graphic_matroid_from_edges(n_vertices, edges):
    """Build graphic matroid. Elements = edge indices."""
    n = n_vertices

    def is_forest(edge_set):
        parent = list(range(n))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        for idx in edge_set:
            u, v = edges[idx]
            rx, ry = find(u), find(v)
            if rx == ry:
                return False
            parent[rx] = ry
        return True

    def spans(edge_set):
        if n <= 1:
            return True
        adj = {i: set() for i in range(n)}
        for idx in edge_set:
            u, v = edges[idx]
            adj[u].add(v)
            adj[v].add(u)
        visited = set()
        stack = [0]
        while stack:
            node = stack.pop()
            if node in visited:
                continue
            visited.add(node)
            stack.extend(adj[node] - visited)
        return len(visited) == n

    # Spanning trees have n-1 edges
    bases = set()
    for combo in itertools.combinations(range(len(edges)), n - 1):
        fs = frozenset(combo)
        if is_forest(fs) and spans(fs):
            bases.add(fs)
    return FiniteMatroid(frozenset(range(len(edges))), bases)


def partition_matroid_from_blocks(blocks, caps):
    all_elems = []
    for block in blocks:
        all_elems.extend(block)
    ground = frozenset(all_elems)

    choices = [list(itertools.combinations(b, c)) for b, c in zip(blocks, caps)]
    bases = set()
    for combo in itertools.product(*choices):
        B = frozenset(e for grp in combo for e in grp)
        bases.add(B)
    return FiniteMatroid(ground, bases)


# ===========================================================================
# Verification of partition function recurrence
# ===========================================================================

def verify_recurrence(M, w, e):
    """Verify Z_M(w) = Z_{M\\e}(w) + w(e)*Z_{M/e}(w)."""
    Z_M = partition_function(M, w)

    # Deletion: bases avoiding e
    del_bases = {B for B in M.bases if e not in B}
    Z_del = sum(basis_weight(B, w) for B in del_bases) if del_bases else 0.0

    # Contraction: bases containing e, remove e
    con_bases = {B - {e} for B in M.bases if e in B}
    Z_con = sum(basis_weight(B, w) for B in con_bases) if con_bases else 0.0

    Z_recurrence = Z_del + w.get(e, 1.0) * Z_con
    return Z_M, Z_recurrence, abs(Z_M - Z_recurrence)


# ===========================================================================
# DEMO
# ===========================================================================

def separator(title):
    print("\n" + "=" * 70)
    print(f"  {title}")
    print("=" * 70)


def run_demo():
    # ------------------------------------------------------------------
    # Demo 1: Uniform Matroid U_{2,4}
    # ------------------------------------------------------------------
    separator("Demo 1: Uniform Matroid U_{2,4}")
    M = uniform_matroid(4, 2)
    w = {0: 1.0, 1: 2.0, 2: 3.0, 3: 4.0}

    amps, depth, size = compile_certificate(M, w)
    Z = partition_function(M, w)

    print(f"Ground set: {set(M.ground_set)}")
    print(f"Number of bases: {len(M.bases)}")
    print(f"Rank: {M.rank}")
    print(f"Partition function Z_M(w): {Z:.4f}")
    print(f"Certificate depth: {depth}")
    print(f"Certificate size: {size}")
    print(f"Max amplitude error: {max_amp_error(M, w, amps):.2e}")
    print(f"Total variation distance: {total_variation(M, w, amps):.2e}")
    print()

    print("Basis | Weight  | Amplitude | Exact Amp | Prob")
    print("-" * 60)
    for B in sorted(M.bases, key=lambda x: sorted(x)):
        bw = basis_weight(B, w)
        amp = amps.get(B, 0)
        exact_amp = math.sqrt(bw)
        prob = bw / Z
        print(f"  {str(sorted(B)):<12} | {bw:7.2f} | {amp:9.4f} | {exact_amp:9.4f} | {prob:.4f}")

    prob_sum = sum(basis_weight(B, w) / Z for B in M.bases)
    print(f"\nSum of probabilities: {prob_sum:.10f}")

    # Verify recurrence
    for e in sorted(M.ground_set):
        Z_M, Z_rec, err = verify_recurrence(M, w, e)
        print(f"Recurrence check (e={e}): Z_M={Z_M:.4f}, Z_rec={Z_rec:.4f}, error={err:.2e}")

    # ------------------------------------------------------------------
    # Demo 2: Graphic Matroid (K4)
    # ------------------------------------------------------------------
    separator("Demo 2: Graphic Matroid of K₄ (Complete Graph on 4 vertices)")
    edges = [(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)]
    M = graphic_matroid_from_edges(4, edges)
    w = {i: float(i + 1) for i in range(len(edges))}

    amps, depth, size = compile_certificate(M, w)
    Z = partition_function(M, w)

    print(f"Edges: {edges}")
    print(f"Number of spanning trees: {len(M.bases)}")
    print(f"Rank: {M.rank}")
    print(f"Partition function (spanning tree polynomial): {Z:.4f}")
    print(f"Certificate depth: {depth}")
    print(f"Certificate size: {size}")
    print(f"Max amplitude error: {max_amp_error(M, w, amps):.2e}")
    print(f"Total variation distance: {total_variation(M, w, amps):.2e}")
    print()

    print("Spanning Tree | Weight | Prob")
    print("-" * 50)
    for B in sorted(M.bases, key=lambda x: sorted(x)):
        bw = basis_weight(B, w)
        prob = bw / Z
        edges_str = [edges[i] for i in sorted(B)]
        print(f"  {edges_str} | {bw:6.1f} | {prob:.4f}")

    # ------------------------------------------------------------------
    # Demo 3: Partition Matroid
    # ------------------------------------------------------------------
    separator("Demo 3: Partition Matroid (3 blocks, pick 1 each)")
    blocks = [[0, 1], [2, 3, 4], [5, 6]]
    caps = [1, 1, 1]
    M = partition_matroid_from_blocks(blocks, caps)
    w = {i: float(i + 1) for i in range(7)}

    amps, depth, size = compile_certificate(M, w)
    Z = partition_function(M, w)

    print(f"Blocks: {blocks}")
    print(f"Capacities: {caps}")
    print(f"Number of bases: {len(M.bases)}")
    print(f"Partition function: {Z:.4f}")
    print(f"Certificate depth: {depth}")
    print(f"Certificate size: {size}")
    print(f"Max amplitude error: {max_amp_error(M, w, amps):.2e}")
    print(f"Total variation distance: {total_variation(M, w, amps):.2e}")
    print()

    # Verify factorization for partition matroids
    # Z = (∑ w(e) for e in block1) * (∑ w(e) for e in block2) * ...
    Z_factored = 1.0
    for block in blocks:
        Z_factored *= sum(w[e] for e in block)
    print(f"Partition function (direct): {Z:.4f}")
    print(f"Partition function (factored): {Z_factored:.4f}")
    print(f"Factorization error: {abs(Z - Z_factored):.2e}")

    # ------------------------------------------------------------------
    # Demo 4: Scaling test — graphic matroids of increasing size
    # ------------------------------------------------------------------
    separator("Demo 4: Scaling — Path Graphs P_n (n = 3..12)")
    print(f"{'n':>4} | {'|E|':>4} | {'#bases':>7} | {'depth':>5} | {'size':>6} | {'TV dist':>10} | {'max err':>10}")
    print("-" * 70)
    for n in range(3, 13):
        edges = [(i, i + 1) for i in range(n - 1)]
        M = graphic_matroid_from_edges(n, edges)
        w = {i: 1.0 + 0.1 * i for i in range(len(edges))}

        amps, depth, size = compile_certificate(M, w)
        tv = total_variation(M, w, amps)
        me = max_amp_error(M, w, amps)

        print(f"{n:4d} | {len(edges):4d} | {len(M.bases):7d} | {depth:5d} | {size:6d} | {tv:10.2e} | {me:10.2e}")

    # ------------------------------------------------------------------
    # Demo 5: Scaling test — complete graphs
    # ------------------------------------------------------------------
    separator("Demo 5: Scaling — Complete Graphs K_n (n = 3..8)")
    print(f"{'n':>4} | {'|E|':>4} | {'#trees':>7} | {'depth':>5} | {'size':>6} | {'TV dist':>10} | {'Z':>12}")
    print("-" * 75)
    for n in range(3, 9):
        edges = [(i, j) for i in range(n) for j in range(i + 1, n)]
        M = graphic_matroid_from_edges(n, edges)
        w = {i: 1.0 for i in range(len(edges))}  # uniform weights

        amps, depth, size = compile_certificate(M, w)
        Z = partition_function(M, w)
        tv = total_variation(M, w, amps)

        # Cayley's formula: number of spanning trees = n^(n-2)
        cayley = n ** (n - 2)
        print(f"{n:4d} | {len(edges):4d} | {len(M.bases):7d} | {depth:5d} | {size:6d} | {tv:10.2e} | Z={Z:8.0f} (Cayley={cayley})")

    # ------------------------------------------------------------------
    # Demo 6: Verify deletion/contraction recurrence
    # ------------------------------------------------------------------
    separator("Demo 6: Deletion/Contraction Recurrence Verification")
    edges = [(0,1), (0,2), (1,2), (1,3), (2,3)]
    M = graphic_matroid_from_edges(4, edges)
    w = {0: 2.0, 1: 3.0, 2: 5.0, 3: 7.0, 4: 11.0}

    print(f"Graph: 4 vertices, edges = {edges}")
    print(f"Weights: {w}")
    print(f"Z_M(w) = {partition_function(M, w):.4f}")
    print()

    for e in sorted(M.ground_set):
        Z_M, Z_rec, err = verify_recurrence(M, w, e)
        status = "✓" if err < 1e-10 else "✗"
        print(f"  e={e} (edge {edges[e]}): Z_M={Z_M:.4f}, "
              f"Z_del + w(e)*Z_con = {Z_rec:.4f}, "
              f"error = {err:.2e} {status}")

    # ------------------------------------------------------------------
    # Demo 7: Quantum state vector
    # ------------------------------------------------------------------
    separator("Demo 7: Quantum State Vector for K₃ Graphic Matroid")
    edges = [(0,1), (0,2), (1,2)]
    M = graphic_matroid_from_edges(3, edges)
    w = {0: 1.0, 1: 4.0, 2: 9.0}

    amps, _, _ = compile_certificate(M, w)
    Z = partition_function(M, w)

    print(f"Graph K₃: edges = {edges}")
    print(f"Weights: w = {w}")
    print(f"Partition function: Z = {Z}")
    print()
    print("Quantum state |ψ_M(w)⟩ ∝ Σ_B √(w(B)) |B⟩:")
    print()
    norm = math.sqrt(sum(a ** 2 for a in amps.values()))
    for B in sorted(M.bases, key=lambda x: sorted(x)):
        edges_in_B = [edges[i] for i in sorted(B)]
        amp = amps[B]
        normalized = amp / norm if norm > 0 else 0
        prob = normalized ** 2
        print(f"  |{edges_in_B}⟩: amplitude = {normalized:.4f}, "
              f"probability = {prob:.4f}")

    print(f"\n  Sum of probabilities: {sum((amps[B]/norm)**2 for B in M.bases):.10f}")


if __name__ == "__main__":
    run_demo()


"""
Visualization: Weighted Basis Distribution Heatmap

Visualizes the probability distribution over matroid bases for the graphic
matroid of K₄ (complete graph on 4 vertices) under different weight functions.
Shows how the Lorentzian structure of the basis polynomial manifests as a
smooth, log-concave distribution over spanning trees.
"""

import itertools
import math
import matplotlib.pyplot as plt
import matplotlib
import numpy as np

matplotlib.rcParams['font.size'] = 11

# --- Inline matroid construction ---
def graphic_matroid_k4():
    edges = [(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)]
    n = 4
    def is_forest(es):
        parent = list(range(n))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        for idx in es:
            u, v = edges[idx]
            rx, ry = find(u), find(v)
            if rx == ry: return False
            parent[rx] = ry
        return True
    def spans(es):
        adj = {i: set() for i in range(n)}
        for idx in es:
            u, v = edges[idx]
            adj[u].add(v); adj[v].add(u)
        visited = set(); stack = [0]
        while stack:
            nd = stack.pop()
            if nd in visited: continue
            visited.add(nd); stack.extend(adj[nd] - visited)
        return len(visited) == n
    bases = []
    for combo in itertools.combinations(range(6), 3):
        fs = frozenset(combo)
        if is_forest(fs) and spans(fs):
            bases.append(sorted(combo))
    return edges, bases

edges, bases = graphic_matroid_k4()
n_bases = len(bases)

# Three different weight scenarios
scenarios = {
    "Uniform w=1": {i: 1.0 for i in range(6)},
    "Linear w=i+1": {i: float(i+1) for i in range(6)},
    "Exponential w=2^i": {i: 2.0**i for i in range(6)},
}

fig, axes = plt.subplots(1, 3, figsize=(16, 6))

for ax, (title, w) in zip(axes, scenarios.items()):
    probs = []
    labels = []
    for B in bases:
        bw = math.prod(w[e] for e in B)
        probs.append(bw)
        edge_strs = [f"e{e}" for e in B]
        labels.append("\n".join(edge_strs))
    
    Z = sum(probs)
    probs = [p/Z for p in probs]
    
    colors = plt.cm.YlOrRd(np.array(probs) / max(probs))
    
    bars = ax.bar(range(n_bases), probs, color=colors, edgecolor='black', linewidth=0.5)
    ax.set_title(title, fontsize=13, fontweight='bold')
    ax.set_xlabel("Spanning Tree Index")
    ax.set_ylabel("Probability")
    ax.set_xticks(range(n_bases))
    ax.set_xticklabels([str(i) for i in range(n_bases)], fontsize=8)
    ax.set_ylim(0, max(probs) * 1.15)
    
    # Annotate top 3
    sorted_idx = sorted(range(n_bases), key=lambda i: -probs[i])
    for rank, idx in enumerate(sorted_idx[:3]):
        tree_edges = [edges[e] for e in bases[idx]]
        ax.annotate(f"{probs[idx]:.3f}", (idx, probs[idx]),
                   ha='center', va='bottom', fontsize=8,
                   fontweight='bold' if rank == 0 else 'normal')

fig.suptitle("Weighted Basis Distribution: Spanning Trees of K₄",
            fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("viz_basis_distribution.png", dpi=150, bbox_inches='tight')
print("Saved viz_basis_distribution.png")


"""
Visualization: Certificate Scaling Analysis

Plots how certificate size and depth scale with graph complexity for
graphic matroids, comparing complete graphs, cycle graphs, and grid graphs.
Demonstrates the conjecture that treewidth controls certificate complexity.
"""

import itertools
import math
import matplotlib.pyplot as plt
import numpy as np

# --- Inline matroid construction ---
def build_graphic_matroid(n_verts, edges):
    n = n_verts
    def is_forest(es):
        parent = list(range(n))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        for idx in es:
            u, v = edges[idx]
            rx, ry = find(u), find(v)
            if rx == ry: return False
            parent[rx] = ry
        return True
    def spans(es):
        if n <= 1: return True
        adj = {i: set() for i in range(n)}
        for idx in es:
            u, v = edges[idx]
            adj[u].add(v); adj[v].add(u)
        visited = set(); stack = [0]
        while stack:
            nd = stack.pop()
            if nd in visited: continue
            visited.add(nd); stack.extend(adj[nd] - visited)
        return len(visited) == n
    bases = set()
    for combo in itertools.combinations(range(len(edges)), n - 1):
        fs = frozenset(combo)
        if is_forest(fs) and spans(fs):
            bases.add(fs)
    return bases

def compile_stats(bases, n_edges):
    """Get certificate depth and size via deletion/contraction recursion."""
    depth = [0]; size = [0]
    def _recurse(current_bases, ground, d):
        size[0] += 1; depth[0] = max(depth[0], d)
        if not ground or len(current_bases) <= 1:
            return
        e = min(ground)
        new_ground = ground - {e}
        del_bases = {B for B in current_bases if e not in B}
        con_bases = {frozenset(x for x in B if x != e) for B in current_bases if e in B}
        if del_bases: _recurse(del_bases, new_ground, d+1)
        if con_bases: _recurse(con_bases, new_ground, d+1)
    _recurse(bases, set(range(n_edges)), 0)
    return depth[0], size[0]

# Build data
results = {"Complete K_n": [], "Cycle C_n": [], "Wheel W_n": []}

for n in range(3, 9):
    # Complete graph K_n
    edges = [(i,j) for i in range(n) for j in range(i+1,n)]
    bases = build_graphic_matroid(n, edges)
    d, s = compile_stats(bases, len(edges))
    results["Complete K_n"].append((n, len(edges), len(bases), d, s))

for n in range(3, 16):
    # Cycle C_n
    edges = [(i, (i+1) % n) for i in range(n)]
    bases = build_graphic_matroid(n, edges)
    d, s = compile_stats(bases, len(edges))
    results["Cycle C_n"].append((n, len(edges), len(bases), d, s))

for n in range(4, 10):
    # Wheel W_n (hub + cycle)
    edges = [(i, (i+1) % (n-1)) for i in range(n-1)]  # outer cycle
    edges += [(n-1, i) for i in range(n-1)]  # hub to all
    bases = build_graphic_matroid(n, edges)
    d, s = compile_stats(bases, len(edges))
    results["Wheel W_n"].append((n, len(edges), len(bases), d, s))

# Plot
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

colors = {'Complete K_n': '#E53935', 'Cycle C_n': '#1E88E5', 'Wheel W_n': '#43A047'}
markers = {'Complete K_n': 'o', 'Cycle C_n': 's', 'Wheel W_n': '^'}

# Plot 1: Number of bases
ax = axes[0]
for name, data in results.items():
    ns = [d[0] for d in data]
    n_bases = [d[2] for d in data]
    ax.semilogy(ns, n_bases, '-'+markers[name], color=colors[name], 
                label=name, markersize=7, linewidth=2)
ax.set_xlabel("Number of vertices n")
ax.set_ylabel("Number of bases (log scale)")
ax.set_title("Basis Count vs. Graph Size", fontweight='bold')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 2: Certificate size
ax = axes[1]
for name, data in results.items():
    ns = [d[0] for d in data]
    sizes = [d[4] for d in data]
    ax.semilogy(ns, sizes, '-'+markers[name], color=colors[name],
                label=name, markersize=7, linewidth=2)
ax.set_xlabel("Number of vertices n")
ax.set_ylabel("Certificate size (log scale)")
ax.set_title("Certificate Size vs. Graph Size", fontweight='bold')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 3: Certificate depth
ax = axes[2]
for name, data in results.items():
    ns = [d[0] for d in data]
    depths = [d[3] for d in data]
    ax.plot(ns, depths, '-'+markers[name], color=colors[name],
            label=name, markersize=7, linewidth=2)
ax.set_xlabel("Number of vertices n")
ax.set_ylabel("Certificate depth")
ax.set_title("Certificate Depth vs. Graph Size", fontweight='bold')
ax.legend()
ax.grid(True, alpha=0.3)

fig.suptitle("Certificate Compilation Scaling for Graphic Matroids",
            fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("viz_certificate_scaling.png", dpi=150, bbox_inches='tight')
print("Saved viz_certificate_scaling.png")


"""
Visualization: Deletion/Contraction Recurrence Tree

Visualizes the recursive certificate compilation process for a small
graphic matroid, showing how the partition function decomposes through
the deletion/contraction recurrence Z_M(w) = Z_{M\\e}(w) + w(e)·Z_{M/e}(w).
"""

import itertools
import math
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# --- Inline matroid ---
def graphic_matroid_triangle():
    """K₃ graphic matroid: 3 edges, 3 spanning trees."""
    edges = [(0,1),(0,2),(1,2)]
    bases = [sorted(c) for c in itertools.combinations(range(3), 2)]
    return edges, bases

edges, bases = graphic_matroid_triangle()
w = {0: 2.0, 1: 3.0, 2: 5.0}

# Compute partition functions for deletion/contraction tree
def Z(basis_list, weights):
    return sum(math.prod(weights.get(e, 1.0) for e in B) for B in basis_list)

# Level 0: Full matroid
Z_full = Z(bases, w)

# Branch on e=0
# Deletion: bases not containing 0 → {1,2}
del_0 = [B for B in bases if 0 not in B]  # [{1,2}]
Z_del_0 = Z(del_0, w)

# Contraction: bases containing 0, remove 0 → {1}, {2}  
con_0 = [[e for e in B if e != 0] for B in bases if 0 in B]  # [{1}, {2}]
Z_con_0 = Z(con_0, w)

# Verify: Z = Z_del + w(0) * Z_con
Z_check = Z_del_0 + w[0] * Z_con_0

fig, ax = plt.subplots(1, 1, figsize=(14, 8))
ax.set_xlim(-1, 11)
ax.set_ylim(-1, 9)
ax.set_aspect('equal')
ax.axis('off')

def draw_box(ax, x, y, width, height, text, color='lightyellow', fontsize=9):
    rect = mpatches.FancyBboxPatch((x, y), width, height,
                                    boxstyle="round,pad=0.1",
                                    facecolor=color, edgecolor='black', linewidth=1.5)
    ax.add_patch(rect)
    ax.text(x + width/2, y + height/2, text, ha='center', va='center',
            fontsize=fontsize, family='monospace')

def draw_arrow(ax, x1, y1, x2, y2, label="", color='black'):
    ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                arrowprops=dict(arrowstyle='->', color=color, lw=2))
    if label:
        mx, my = (x1+x2)/2, (y1+y2)/2
        ax.text(mx, my + 0.25, label, ha='center', va='bottom',
                fontsize=9, color=color, fontweight='bold')

# Root node
draw_box(ax, 2.5, 7, 5, 1.2,
         f"M = graphic(K₃)\n"
         f"Bases: {{01, 02, 12}}\n"
         f"Z = {Z_full:.1f}",
         color='#E8F4FD', fontsize=10)

# Deletion branch
draw_arrow(ax, 3.5, 7, 1.5, 5.7, "M \\ e₀", color='#2196F3')
draw_box(ax, 0, 4.5, 3.5, 1.2,
         f"M \\ e₀\n"
         f"Bases: {{12}}\n"
         f"Z_del = {Z_del_0:.1f}",
         color='#C8E6C9')

# Contraction branch  
draw_arrow(ax, 6.5, 7, 8.5, 5.7, f"w(e₀)={w[0]:.0f} × M / e₀", color='#F44336')
draw_box(ax, 6.5, 4.5, 3.5, 1.2,
         f"M / e₀\n"
         f"Bases: {{1}}, {{2}}\n"
         f"Z_con = {Z_con_0:.1f}",
         color='#FFECB3')

# Further decomposition of contraction
draw_arrow(ax, 7.5, 4.5, 6, 3.2, "M/e₀ \\ e₁", color='#2196F3')
draw_box(ax, 4.5, 2, 3, 1,
         f"Basis: {{2}}\n"
         f"w = {w[2]:.1f}",
         color='#C8E6C9')

draw_arrow(ax, 9, 4.5, 9.5, 3.2, f"w(e₁)={w[1]:.0f} × M/e₀/e₁", color='#F44336')
draw_box(ax, 8, 2, 3, 1,
         f"Basis: {{∅}}\n"
         f"w = 1.0",
         color='#C8E6C9')

# Verification equation
eq_text = (f"Z_M = Z_del + w(e₀) · Z_con\n"
           f"   {Z_full:.1f} = {Z_del_0:.1f} + {w[0]:.0f} × {Z_con_0:.1f} = {Z_check:.1f} ✓")
ax.text(5, 0.5, eq_text, ha='center', va='center',
        fontsize=12, fontweight='bold',
        bbox=dict(boxstyle='round,pad=0.3', facecolor='#FFF9C4', edgecolor='black'))

# Title
ax.text(5, 8.8, "Deletion/Contraction Recurrence Tree",
        ha='center', va='center', fontsize=16, fontweight='bold')
ax.text(5, 8.3, "Recursive certificate compilation for K₃ graphic matroid",
        ha='center', va='center', fontsize=11, style='italic', color='gray')

# Legend
legend_elements = [
    mpatches.Patch(facecolor='#C8E6C9', edgecolor='black', label='Leaf (basis found)'),
    mpatches.Patch(facecolor='#E8F4FD', edgecolor='black', label='Internal node'),
    mpatches.Patch(facecolor='#FFECB3', edgecolor='black', label='Contraction result'),
]
ax.legend(handles=legend_elements, loc='lower left', fontsize=9)

plt.tight_layout()
plt.savefig("viz_recurrence_tree.png", dpi=150, bbox_inches='tight')
print("Saved viz_recurrence_tree.png")
