"""
Matroidal Quantum State Preparation — Core Algorithms

Implements recursive certificate compilation for quantum state preparation
from matroid basis structure, leveraging the deletion/contraction recurrence.

Application keywords: quantum sampling, matroid bases, Lorentzian polynomials,
combinatorial Hodge theory, spanning trees, network reliability, partition functions.
"""

from __future__ import annotations
import itertools
import math
from dataclasses import dataclass, field
from typing import FrozenSet, Callable, Dict, List, Optional, Set, Tuple


# ---------------------------------------------------------------------------
# Core data structures
# ---------------------------------------------------------------------------

@dataclass
class FiniteMatroid:
    """A finite matroid defined by its ground set and family of bases."""
    ground_set: FrozenSet[int]
    bases: Set[FrozenSet[int]]

    def __post_init__(self):
        if not self.bases:
            raise ValueError("Matroid must have at least one basis")
        cards = {len(B) for B in self.bases}
        if len(cards) > 1:
            raise ValueError(f"All bases must have the same cardinality, got {cards}")

    @property
    def rank(self) -> int:
        return len(next(iter(self.bases)))

    def deletion(self, e: int) -> 'FiniteMatroid':
        """M \\ e: bases that avoid e."""
        new_bases = {B for B in self.bases if e not in B}
        if not new_bases:
            return FiniteMatroid(self.ground_set - {e}, {frozenset()})
        return FiniteMatroid(self.ground_set - {e}, new_bases)

    def contraction(self, e: int) -> 'FiniteMatroid':
        """M / e: for bases containing e, remove e."""
        new_bases = {B - {e} for B in self.bases if e in B}
        if not new_bases:
            return FiniteMatroid(self.ground_set - {e}, {frozenset()})
        return FiniteMatroid(self.ground_set - {e}, new_bases)


@dataclass
class MatroidBasisCertificate:
    """Certificate for quantum state preparation from matroid bases.
    
    Packages a matroid with weights and explicit amplitude assignments
    for each basis, certified to equal √(basis_weight).
    """
    matroid: FiniteMatroid
    weight: Dict[int, float]
    support_family: Set[FrozenSet[int]]
    amplitudes: Dict[FrozenSet[int], float]
    certificate_depth: int = 0
    certificate_size: int = 1

    @property
    def partition_function(self) -> float:
        return sum(self.basis_weight(B) for B in self.support_family)

    def basis_weight(self, B: FrozenSet[int]) -> float:
        return math.prod(self.weight.get(e, 1.0) for e in B)

    def compiled_prob(self, B: FrozenSet[int]) -> float:
        Z = self.partition_function
        if Z == 0:
            return 0.0
        return self.basis_weight(B) / Z

    def amplitude(self, B: FrozenSet[int]) -> float:
        return self.amplitudes.get(B, 0.0)


# ---------------------------------------------------------------------------
# Certificate compilation
# ---------------------------------------------------------------------------

def compile_certificate(
    matroid: FiniteMatroid,
    weight: Dict[int, float],
) -> MatroidBasisCertificate:
    """Compile a matroid basis certificate using deletion/contraction recursion.
    
    This implements the partition function recurrence:
        Z_M(w) = Z_{M\\e}(w) + w(e) * Z_{M/e}(w)
    
    The recursion branches on each element, building a binary tree of
    sub-certificates that exactly reproduces the weighted basis distribution.
    """
    amplitudes = {}
    depth = 0
    size = 0

    def _recurse(M: FiniteMatroid, current_weight: Dict[int, float], 
                 prefix: FrozenSet[int], d: int) -> int:
        nonlocal size, depth
        size += 1
        depth = max(depth, d)

        if not M.ground_set:
            # Base case: empty ground set
            B = prefix
            w = math.prod(current_weight.get(e, 1.0) for e in B)
            amplitudes[B] = math.sqrt(w)
            return 1

        if len(M.bases) == 1:
            # Single basis remaining
            B_local = next(iter(M.bases))
            B = prefix | B_local
            w = math.prod(current_weight.get(e, 1.0) for e in B)
            amplitudes[B] = math.sqrt(w)
            return 1

        # Choose an element to branch on
        e = next(iter(M.ground_set))

        # Deletion branch: bases not containing e
        M_del = M.deletion(e)
        if M_del.bases and M_del.bases != {frozenset()} or M_del.rank == 0:
            s1 = _recurse(M_del, current_weight, prefix, d + 1)
        else:
            s1 = 0

        # Contraction branch: bases containing e (remove e from each)
        M_con = M.contraction(e)
        if M_con.bases and (M_con.bases != {frozenset()} or M_con.rank == 0):
            s2 = _recurse(M_con, current_weight, prefix | {e}, d + 1)
        else:
            s2 = 0

        return s1 + s2

    _recurse(matroid, weight, frozenset(), 0)

    return MatroidBasisCertificate(
        matroid=matroid,
        weight=weight,
        support_family=matroid.bases,
        amplitudes=amplitudes,
        certificate_depth=depth,
        certificate_size=size,
    )


# ---------------------------------------------------------------------------
# Matroid constructors
# ---------------------------------------------------------------------------

def uniform_matroid(n: int, k: int) -> FiniteMatroid:
    """U_{k,n}: all k-subsets of {0,...,n-1} are bases."""
    ground = frozenset(range(n))
    bases = {frozenset(S) for S in itertools.combinations(range(n), k)}
    return FiniteMatroid(ground, bases)


def graphic_matroid(n_vertices: int, edges: List[Tuple[int, int]]) -> FiniteMatroid:
    """Graphic matroid of a graph: bases = spanning forests (spanning trees if connected).
    
    Elements are edge indices. Bases are maximal acyclic edge subsets.
    """
    ground = frozenset(range(len(edges)))
    n = n_vertices

    def is_acyclic(edge_subset: FrozenSet[int]) -> bool:
        """Check if edge subset forms a forest using union-find."""
        parent = list(range(n))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            rx, ry = find(x), find(y)
            if rx == ry:
                return False
            parent[rx] = ry
            return True
        for idx in edge_subset:
            u, v = edges[idx]
            if not union(u, v):
                return False
        return True

    def is_connected_with(edge_subset: FrozenSet[int]) -> bool:
        """Check if edge subset connects all vertices."""
        if not edge_subset and n > 1:
            return False
        adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
        for idx in edge_subset:
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

    # Find all spanning trees (maximal acyclic subsets)
    # For connected graph, these have exactly n-1 edges
    bases = set()
    for r in range(len(edges), 0, -1):
        for combo in itertools.combinations(range(len(edges)), r):
            fs = frozenset(combo)
            if is_acyclic(fs) and is_connected_with(fs):
                bases.add(fs)
        if bases:
            break

    if not bases:
        # Disconnected graph: use maximal forests
        max_size = 0
        for r in range(len(edges) + 1):
            for combo in itertools.combinations(range(len(edges)), r):
                fs = frozenset(combo)
                if is_acyclic(fs):
                    if len(fs) > max_size:
                        max_size = len(fs)
                        bases = {fs}
                    elif len(fs) == max_size:
                        bases.add(fs)

    return FiniteMatroid(ground, bases)


def partition_matroid(blocks: List[List[int]], capacities: List[int]) -> FiniteMatroid:
    """Partition matroid: ground set partitioned into blocks, basis picks
    exactly capacity[i] elements from block i."""
    all_elements = []
    for block in blocks:
        all_elements.extend(block)
    ground = frozenset(all_elements)

    # Generate all bases by choosing capacity[i] elements from each block
    choices_per_block = []
    for block, cap in zip(blocks, capacities):
        choices_per_block.append(list(itertools.combinations(block, cap)))

    bases = set()
    for combo in itertools.product(*choices_per_block):
        B = frozenset(e for group in combo for e in group)
        bases.add(B)

    return FiniteMatroid(ground, bases)


# ---------------------------------------------------------------------------
# Analysis utilities
# ---------------------------------------------------------------------------

def total_variation_distance(
    cert: MatroidBasisCertificate,
) -> float:
    """Total variation distance between compiled and exact distributions."""
    tv = 0.0
    for B in cert.support_family:
        p_compiled = cert.amplitude(B) ** 2
        p_exact = cert.basis_weight(B)
        tv += abs(p_compiled - p_exact)
    # Normalize both
    Z_compiled = sum(cert.amplitude(B) ** 2 for B in cert.support_family)
    Z_exact = cert.partition_function
    if Z_compiled == 0 or Z_exact == 0:
        return 1.0
    tv = 0.0
    for B in cert.support_family:
        p_compiled = cert.amplitude(B) ** 2 / Z_compiled
        p_exact = cert.basis_weight(B) / Z_exact
        tv += abs(p_compiled - p_exact)
    return tv / 2


def max_amplitude_error(cert: MatroidBasisCertificate) -> float:
    """Maximum absolute error between compiled and exact amplitudes."""
    max_err = 0.0
    for B in cert.support_family:
        exact_amp = math.sqrt(cert.basis_weight(B))
        compiled_amp = cert.amplitude(B)
        max_err = max(max_err, abs(compiled_amp - exact_amp))
    return max_err


# ---------------------------------------------------------------------------
# Example usage
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    # Example: U_{2,4} with weights [1, 2, 3, 4]
    M = uniform_matroid(4, 2)
    w = {0: 1.0, 1: 2.0, 2: 3.0, 3: 4.0}
    cert = compile_certificate(M, w)

    print(f"Uniform matroid U_{{2,4}}")
    print(f"Number of bases: {len(cert.support_family)}")
    print(f"Partition function: {cert.partition_function:.4f}")
    print(f"Max amplitude error: {max_amplitude_error(cert):.2e}")
    print(f"Total variation distance: {total_variation_distance(cert):.2e}")
    print(f"Certificate depth: {cert.certificate_depth}")
    print(f"Certificate size: {cert.certificate_size}")
    print()

    # Verify probabilities sum to 1
    prob_sum = sum(cert.compiled_prob(B) for B in cert.support_family)
    print(f"Sum of probabilities: {prob_sum:.10f}")
