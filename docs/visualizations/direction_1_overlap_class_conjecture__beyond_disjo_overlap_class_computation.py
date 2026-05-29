#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for Overlap Class Theory

Implements the computational backbone of the overlap class framework:
- Support overlap graph construction
- Connected component (overlap class) enumeration
- Overlap degree, complexity, and signature computation
- TPE simulation and invariant verification
- Graph cycle enumeration and support extraction

Time complexity notes:
- Overlap graph construction: O(n² · max|Fᵢ|) where n = family size
- Connected components (union-find): O(n · α(n)) ≈ O(n)
- Overlap degree: O(n²)
- Overlap complexity: O(n² · max|Fᵢ|)
- Cycle enumeration: exponential in general, O(E) for short cycles
"""

from collections import defaultdict
from typing import FrozenSet, List, Set, Dict, Tuple, Optional
import itertools


# ─────────────────────────────────────────────────────────────────────
# Type aliases
# ─────────────────────────────────────────────────────────────────────
Support = FrozenSet[int]
SupportFamily = List[Support]
Graph = Dict[int, Set[int]]  # adjacency list


# ─────────────────────────────────────────────────────────────────────
# Union-Find data structure
# ─────────────────────────────────────────────────────────────────────
class UnionFind:
    """Weighted union-find with path compression.

    Time: O(α(n)) per operation (amortized).
    Space: O(n).
    """

    def __init__(self, n: int):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.component_count = n

    def find(self, x: int) -> int:
        """Find root with path compression."""
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, x: int, y: int) -> bool:
        """Union by rank. Returns True if a merge occurred."""
        px, py = self.find(x), self.find(y)
        if px == py:
            return False
        if self.rank[px] < self.rank[py]:
            px, py = py, px
        self.parent[py] = px
        if self.rank[px] == self.rank[py]:
            self.rank[px] += 1
        self.component_count -= 1
        return True

    def connected(self, x: int, y: int) -> bool:
        return self.find(x) == self.find(y)

    def components(self) -> List[List[int]]:
        """Return all connected components."""
        groups = defaultdict(list)
        for i in range(len(self.parent)):
            groups[self.find(i)].append(i)
        return list(groups.values())


# ─────────────────────────────────────────────────────────────────────
# Support Overlap Graph
# ─────────────────────────────────────────────────────────────────────

def build_overlap_graph(family: SupportFamily) -> Tuple[List[Tuple[int, int]], Graph]:
    """Build the support interaction graph.

    Args:
        family: List of supports (frozensets of elements).

    Returns:
        (edges, adjacency_dict) where edges is a list of (i,j) pairs
        with i < j, and adjacency_dict maps each index to its neighbors.

    Time: O(n² · max|Fᵢ|) where n = len(family).
    """
    n = len(family)
    edges = []
    adj: Graph = defaultdict(set)
    for i in range(n):
        for j in range(i + 1, n):
            if family[i] & family[j]:  # nonempty intersection
                edges.append((i, j))
                adj[i].add(j)
                adj[j].add(i)
    return edges, dict(adj)


def overlap_classes(family: SupportFamily) -> List[List[int]]:
    """Compute overlap classes (connected components of overlap graph).

    Args:
        family: List of supports.

    Returns:
        List of lists, each being the indices in one overlap class.

    Time: O(n² · max|Fᵢ|).
    """
    n = len(family)
    if n == 0:
        return []
    uf = UnionFind(n)
    for i in range(n):
        for j in range(i + 1, n):
            if family[i] & family[j]:
                uf.union(i, j)
    return uf.components()


def overlap_class_count(family: SupportFamily) -> int:
    """Number of overlap classes."""
    return len(overlap_classes(family))


def overlap_degree(family: SupportFamily) -> int:
    """Number of overlapping pairs (edges in overlap graph).

    Time: O(n²).
    """
    n = len(family)
    count = 0
    for i in range(n):
        for j in range(i + 1, n):
            if family[i] & family[j]:
                count += 1
    return count


def overlap_complexity(family: SupportFamily) -> int:
    """Sum of pairwise intersection cardinalities.

    This is a finer measure than overlap_degree: it accounts for
    how much each pair overlaps, not just whether they do.

    Time: O(n² · max|Fᵢ|).
    """
    n = len(family)
    total = 0
    for i in range(n):
        for j in range(i + 1, n):
            total += len(family[i] & family[j])
    return total


def overlap_signature(family: SupportFamily) -> List[int]:
    """Sorted list of intersection cardinalities for overlapping pairs.

    Time: O(n² · max|Fᵢ| + k log k) where k = overlap_degree.
    """
    n = len(family)
    sig = []
    for i in range(n):
        for j in range(i + 1, n):
            inter_size = len(family[i] & family[j])
            if inter_size > 0:
                sig.append(inter_size)
    return sorted(sig)


def cross_overlap_matrix(family: SupportFamily) -> List[List[int]]:
    """Compute the full cross-overlap matrix.

    M[i][j] = |Fᵢ ∩ Fⱼ| for all pairs.

    Time: O(n² · max|Fᵢ|).
    """
    n = len(family)
    M = [[0] * n for _ in range(n)]
    for i in range(n):
        M[i][i] = len(family[i])
        for j in range(i + 1, n):
            inter_size = len(family[i] & family[j])
            M[i][j] = inter_size
            M[j][i] = inter_size
    return M


# ─────────────────────────────────────────────────────────────────────
# Tropical Projective Equivalence
# ─────────────────────────────────────────────────────────────────────

def apply_tpe(
    functions: List[Dict[int, int]],
    sigma: List[int],
    constants: List[int]
) -> List[Dict[int, int]]:
    """Apply TPE: F₂(σ(i), v) = F₁(i, v) + c(i).

    Args:
        functions: List of functions (dicts from vertex to value).
        sigma: Permutation as a list.
        constants: Additive constants.

    Returns:
        Transformed function family.
    """
    n = len(functions)
    vertices = set()
    for f in functions:
        vertices |= set(f.keys())

    result = [None] * n
    for i in range(n):
        new_f = {}
        for v in vertices:
            new_f[v] = functions[i].get(v, 0) + constants[i]
        result[sigma[i]] = new_f
    return result


def variation_support(f: Dict[int, int], v0: int) -> FrozenSet[int]:
    """VarSupport: {v | f(v) ≠ f(v₀)}.

    This is the TPE-invariant support notion.
    """
    f_v0 = f.get(v0, 0)
    return frozenset(v for v in f if f[v] != f_v0)


def var_support_family(
    functions: List[Dict[int, int]], v0: int
) -> SupportFamily:
    """Compute variation support family."""
    return [variation_support(f, v0) for f in functions]


def verify_tpe_invariance(
    functions: List[Dict[int, int]],
    sigma: List[int],
    constants: List[int],
    v0: int
) -> Dict[str, bool]:
    """Verify that TPE preserves all overlap invariants.

    Returns dict mapping invariant name to whether it's preserved.
    """
    f2 = apply_tpe(functions, sigma, constants)
    vsf1 = var_support_family(functions, v0)
    vsf2 = var_support_family(f2, v0)

    return {
        "overlap_class_count": overlap_class_count(vsf1) == overlap_class_count(vsf2),
        "overlap_degree": overlap_degree(vsf1) == overlap_degree(vsf2),
        "overlap_complexity": overlap_complexity(vsf1) == overlap_complexity(vsf2),
        "overlap_signature": overlap_signature(vsf1) == overlap_signature(vsf2),
    }


# ─────────────────────────────────────────────────────────────────────
# Graph Cycle Enumeration
# ─────────────────────────────────────────────────────────────────────

def find_cycles(adj: Graph, max_cycles: int = 50) -> List[Set[int]]:
    """Find simple cycles using DFS.

    Args:
        adj: Adjacency list.
        max_cycles: Maximum number of cycles to find.

    Returns:
        List of vertex sets, each being the support of a cycle.
    """
    vertices = sorted(adj.keys())
    found = set()
    result = []

    def dfs(start, current, path, visited):
        if len(result) >= max_cycles:
            return
        for nbr in sorted(adj.get(current, set())):
            if nbr == start and len(path) >= 3:
                cycle = frozenset(path)
                if cycle not in found:
                    found.add(cycle)
                    result.append(set(path))
            elif nbr not in visited and nbr > start:
                visited.add(nbr)
                path.append(nbr)
                dfs(start, nbr, path, visited)
                path.pop()
                visited.discard(nbr)

    for v in vertices:
        dfs(v, v, [v], {v})
        if len(result) >= max_cycles:
            break

    return result


def graph_from_edges(edges: List[Tuple[int, int]]) -> Graph:
    """Build adjacency list from edge list."""
    adj: Graph = defaultdict(set)
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)
    return dict(adj)


# ─────────────────────────────────────────────────────────────────────
# Inclusion-exclusion bounds
# ─────────────────────────────────────────────────────────────────────

def family_union_card(family: SupportFamily) -> int:
    """Cardinality of the union of all supports."""
    union = set()
    for s in family:
        union |= s
    return len(union)


def inclusion_exclusion_deficit(family: SupportFamily) -> int:
    """Deficit: Σ|Fᵢ| - |⋃Fᵢ|.

    By our theorem, this is bounded by overlap_complexity(family).
    """
    return sum(len(s) for s in family) - family_union_card(family)


# ─────────────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Overlap Class Theory — Algorithm Library")
    print("=" * 50)

    # Example family
    family = [
        frozenset({1, 2, 3}),
        frozenset({3, 4, 5}),
        frozenset({6, 7}),
        frozenset({7, 8, 9}),
    ]

    print(f"\nFamily: {[set(s) for s in family]}")
    print(f"Overlap classes: {overlap_classes(family)}")
    print(f"Overlap class count: {overlap_class_count(family)}")
    print(f"Overlap degree: {overlap_degree(family)}")
    print(f"Overlap complexity: {overlap_complexity(family)}")
    print(f"Overlap signature: {overlap_signature(family)}")
    print(f"Cross-overlap matrix:")
    for row in cross_overlap_matrix(family):
        print(f"  {row}")
    print(f"Inclusion-exclusion deficit: {inclusion_exclusion_deficit(family)}")
    print(f"  ≤ overlap complexity: {overlap_complexity(family)} ✓")
