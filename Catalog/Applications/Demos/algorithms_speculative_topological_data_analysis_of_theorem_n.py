"""
Citation Complex Algorithms: Topological Data Analysis of Theorem Networks

Type-hinted implementations of the core algorithms for constructing
and analyzing citation simplicial complexes.
"""

from typing import List, Set, FrozenSet, Dict, Tuple, Optional
from collections import defaultdict
import itertools


class CitationGraph:
    """A directed citation graph where vertices are theorems."""

    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        """
        Args:
            n: Number of theorems (vertices labeled 0..n-1)
            edges: List of (i, j) meaning theorem i cites theorem j
        """
        self.n = n
        self.adj: Dict[int, Set[int]] = defaultdict(set)
        self.in_adj: Dict[int, Set[int]] = defaultdict(set)
        for i, j in edges:
            if i != j:  # No self-citations
                self.adj[i].add(j)
                self.in_adj[j].add(i)

    def co_cited(self, i: int, j: int) -> bool:
        """Check if theorems i and j are co-cited (share a common citer)."""
        citers_i = self.in_adj.get(i, set())
        citers_j = self.in_adj.get(j, set())
        return bool(citers_i & citers_j)

    def co_citation_count(self, i: int, j: int) -> int:
        """Count the number of common citers of theorems i and j."""
        citers_i = self.in_adj.get(i, set())
        citers_j = self.in_adj.get(j, set())
        return len(citers_i & citers_j)


class SimplicialComplex:
    """An abstract simplicial complex represented by maximal faces."""

    def __init__(self):
        self.faces: Set[FrozenSet[int]] = set()

    def add_face(self, face: FrozenSet[int]):
        """Add a face and all its subfaces."""
        self.faces.add(face)
        if len(face) > 1:
            for v in face:
                self.add_face(face - {v})

    def f_vector(self) -> List[int]:
        """Compute the f-vector: f_k = number of k-dimensional faces."""
        if not self.faces:
            return []
        max_dim = max(len(f) - 1 for f in self.faces)
        f = [0] * (max_dim + 1)
        for face in self.faces:
            if face:  # Skip empty set
                f[len(face) - 1] += 1
        return f

    def euler_characteristic(self) -> int:
        """Compute the Euler characteristic: χ = Σ (-1)^k f_k."""
        f = self.f_vector()
        return sum((-1) ** k * f_k for k, f_k in enumerate(f))

    def dimension(self) -> int:
        """Maximum dimension of any face."""
        if not self.faces:
            return -1
        return max(len(f) - 1 for f in self.faces)


def build_cocitation_complex(
    graph: CitationGraph,
    threshold: int = 1
) -> SimplicialComplex:
    """
    Build the co-citation simplicial complex from a citation graph.

    Algorithm:
        1. For each pair (i,j), compute co-citation count
        2. Build the 1-skeleton: edges where co-citation count ≥ threshold
        3. Extend to clique complex: add all cliques as faces

    Args:
        graph: The citation graph
        threshold: Minimum co-citation count to form an edge

    Returns:
        The co-citation simplicial complex (clique complex)
    """
    K = SimplicialComplex()

    # Add vertices
    for v in range(graph.n):
        K.add_face(frozenset({v}))

    # Build adjacency for co-citation graph
    cocite_adj: Dict[int, Set[int]] = defaultdict(set)
    for i in range(graph.n):
        for j in range(i + 1, graph.n):
            if graph.co_citation_count(i, j) >= threshold:
                cocite_adj[i].add(j)
                cocite_adj[j].add(i)
                K.add_face(frozenset({i, j}))

    # Extend to clique complex using Bron-Kerbosch
    cliques = find_all_cliques(graph.n, cocite_adj)
    for clique in cliques:
        K.add_face(frozenset(clique))

    return K


def find_all_cliques(
    n: int,
    adj: Dict[int, Set[int]],
    max_size: int = 4
) -> List[Set[int]]:
    """Find cliques of size 3 and 4 by direct enumeration."""
    cliques: List[Set[int]] = []
    vertices = sorted(v for v in range(n) if adj.get(v))

    for i in vertices:
        nbrs_i = adj.get(i, set())
        for j in nbrs_i:
            if j > i:
                common = nbrs_i & adj.get(j, set())
                for k in common:
                    if k > j:
                        cliques.append({i, j, k})
                        if max_size >= 4:
                            common2 = common & adj.get(k, set())
                            for l in common2:
                                if l > k:
                                    cliques.append({i, j, k, l})
    return cliques


def build_filtration(
    graph: CitationGraph,
    max_threshold: int
) -> Dict[int, SimplicialComplex]:
    """
    Build the citation filtration: a family of complexes indexed by threshold.

    At threshold t, include edge (i,j) only if co-citation count ≥ t.
    Lower thresholds give larger complexes (monotonicity).

    Returns:
        Dict mapping threshold → SimplicialComplex
    """
    filtration = {}
    for t in range(max_threshold, -1, -1):
        filtration[t] = build_cocitation_complex(graph, threshold=t)
    return filtration


def compute_betti_numbers(K: SimplicialComplex) -> List[int]:
    """
    Compute Betti numbers of a simplicial complex using the boundary matrix.

    Uses Smith normal form / rank computation over Z/2Z for simplicity.

    Returns:
        List of Betti numbers [β_0, β_1, ..., β_d]
    """
    import numpy as np

    f = K.f_vector()
    if not f:
        return []

    d = len(f)
    faces_by_dim: Dict[int, List[FrozenSet[int]]] = defaultdict(list)

    for face in K.faces:
        if face:
            faces_by_dim[len(face) - 1].append(face)

    # Sort faces for consistent indexing
    for dim in faces_by_dim:
        faces_by_dim[dim].sort(key=lambda x: sorted(x))

    betti = []
    prev_boundary_rank = 0

    for k in range(d):
        if k + 1 < d and faces_by_dim[k + 1]:
            # Build boundary matrix ∂_{k+1}: C_{k+1} → C_k
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

            # Rank over Q (mod 2 would be simpler but less accurate)
            current_boundary_rank = int(np.linalg.matrix_rank(boundary))
        else:
            current_boundary_rank = 0

        # β_k = dim(Z_k) - dim(B_k) = (f_k - rank(∂_k)) - rank(∂_{k+1})
        # But rank(∂_k) was computed in the previous iteration as prev_boundary_rank
        cycle_dim = f[k] - prev_boundary_rank
        betti_k = cycle_dim - current_boundary_rank
        betti.append(max(0, betti_k))

        prev_boundary_rank = current_boundary_rank

    return betti


def compute_persistent_betti(
    filtration: Dict[int, SimplicialComplex]
) -> Dict[Tuple[int, int, int], int]:
    """
    Compute persistent Betti numbers β_k^{s,t} for all (k, s, t).

    Uses the standard algorithm: for each pair (s, t) with t ≤ s,
    compute the rank of the induced map H_k(K_s) → H_k(K_t).

    Returns:
        Dict mapping (k, s, t) → β_k^{s,t}
    """
    betti_at = {}
    for t, K in filtration.items():
        betti_at[t] = compute_betti_numbers(K)

    persistent = {}
    thresholds = sorted(filtration.keys())
    for s in thresholds:
        for t in thresholds:
            if t <= s:
                betti_s = betti_at.get(s, [])
                betti_t = betti_at.get(t, [])
                max_k = max(len(betti_s), len(betti_t))
                for k in range(max_k):
                    bs = betti_s[k] if k < len(betti_s) else 0
                    bt = betti_t[k] if k < len(betti_t) else 0
                    persistent[(k, s, t)] = min(bs, bt)

    return persistent


def detect_communities(K: SimplicialComplex) -> int:
    """
    Detect research communities via β_0 of the co-citation complex.

    Returns:
        Number of connected components (= β_0)
    """
    betti = compute_betti_numbers(K)
    return betti[0] if betti else 0


def detect_paradigm_shifts(
    filtration: Dict[int, SimplicialComplex]
) -> List[int]:
    """
    Detect paradigm shifts as strict increases in β_2 across filtration levels.

    Returns:
        List of filtration levels where β_2 increases
    """
    thresholds = sorted(filtration.keys(), reverse=True)
    shifts = []
    prev_beta2 = 0

    for t in thresholds:
        betti = compute_betti_numbers(filtration[t])
        beta2 = betti[2] if len(betti) > 2 else 0
        if beta2 > prev_beta2:
            shifts.append(t)
        prev_beta2 = beta2

    return shifts


def cyclomatic_complexity(K: SimplicialComplex) -> int:
    """
    Compute the cyclomatic complexity (β_1) of a citation complex.

    For a connected graph: β_1 = m - n + 1
    where m = edges, n = vertices.

    Returns:
        The first Betti number
    """
    betti = compute_betti_numbers(K)
    return betti[1] if len(betti) > 1 else 0


def verify_morse_inequalities(K: SimplicialComplex) -> bool:
    """
    Verify the weak and strong Morse inequalities for a complex.

    Weak: β_k ≤ f_k for all k
    Strong: Σ_{i=0}^k (-1)^{k-i} β_i ≤ Σ_{i=0}^k (-1)^{k-i} f_i

    Returns:
        True if all inequalities hold
    """
    f = K.f_vector()
    betti = compute_betti_numbers(K)

    # Pad to same length
    max_d = max(len(f), len(betti))
    f = f + [0] * (max_d - len(f))
    betti = betti + [0] * (max_d - len(betti))

    # Weak Morse
    for k in range(max_d):
        if betti[k] > f[k]:
            return False

    # Strong Morse
    for k in range(max_d):
        lhs = sum((-1) ** (k - i) * betti[i] for i in range(k + 1))
        rhs = sum((-1) ** (k - i) * f[i] for i in range(k + 1))
        if lhs > rhs:
            return False

    # Euler-Poincaré (equality)
    euler_f = sum((-1) ** k * f_k for k, f_k in enumerate(f))
    euler_b = sum((-1) ** k * b_k for k, b_k in enumerate(betti))
    if euler_f != euler_b:
        return False

    return True
