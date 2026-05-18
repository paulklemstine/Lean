#!/usr/bin/env python3
"""
Algorithms for Berggren Orbit Graph Analysis

Implements the core mathematical algorithms for studying Berggren dynamics
over finite fields, including orbit graph construction, spectral analysis,
and mixing time estimation.
"""

import numpy as np
from collections import defaultdict
from typing import List, Tuple, Dict, Set, Optional

# ============================================================
# Berggren Matrices
# ============================================================

# The three Berggren generators in O(2,1;Z)
BERG_A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=int)
BERG_B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=int)
BERG_C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=int)
BERGGREN_GENS = [BERG_A, BERG_B, BERG_C]

# Lorentz metric
Q_METRIC = np.diag([1, 1, -1])


def verify_lorentz_group_membership(M: np.ndarray) -> bool:
    """Verify M^T Q M = Q where Q = diag(1,1,-1).

    Args:
        M: 3x3 integer matrix

    Returns:
        True if M preserves the Lorentz form
    """
    return np.array_equal(M.T @ Q_METRIC @ M, Q_METRIC)


def projective_normalize(v: Tuple[int, ...], p: int) -> Optional[Tuple[int, ...]]:
    """Normalize a vector to projective coordinates mod p.

    The first nonzero coordinate is set to 1.

    Args:
        v: tuple of integers
        p: prime modulus

    Returns:
        Normalized tuple, or None if v is the zero vector
    """
    v_mod = tuple(x % p for x in v)
    for i in range(len(v_mod)):
        if v_mod[i] != 0:
            inv = pow(int(v_mod[i]), p - 2, p)
            return tuple((x * inv) % p for x in v_mod)
    return None


def lorentz_form_mod(v: Tuple[int, ...], p: int) -> int:
    """Compute Q(v) = v0^2 + v1^2 - v2^2 mod p.

    Args:
        v: 3-tuple of integers
        p: prime modulus

    Returns:
        Q(v) mod p
    """
    return (v[0]**2 + v[1]**2 - v[2]**2) % p


class BerggrenOrbitGraph:
    """Represents the Berggren orbit graph on projective isotropic points mod p.

    The vertex set is the projective isotropic cone {[v] in P^2(F_p) : Q(v) = 0},
    which has exactly p+1 points for any odd prime p.

    Edges are directed: v -> M*v for each Berggren generator M in {A, B, C}.

    Attributes:
        p: the prime
        vertices: sorted list of projective isotropic points
        n: number of vertices (= p+1)
        out_edges: dict mapping each vertex to its forward neighbors
        in_edges: dict mapping each vertex to its backward neighbors
    """

    def __init__(self, p: int):
        """Build the Berggren orbit graph mod p.

        Args:
            p: an odd prime

        Time complexity: O(p^2) for finding isotropic points + O(p) for edges
        Space complexity: O(p)
        """
        self.p = p
        self.vertices = self._find_isotropic_points()
        self.n = len(self.vertices)
        self._vert_set = set(self.vertices)
        self.idx = {v: i for i, v in enumerate(self.vertices)}
        self.out_edges: Dict[Tuple, List[Tuple]] = defaultdict(list)
        self.in_edges: Dict[Tuple, List[Tuple]] = defaultdict(list)
        self._build_edges()

    def _find_isotropic_points(self) -> List[Tuple[int, ...]]:
        """Find all projective points on Q = 0 in P^2(F_p).

        Time: O(p^2) - iterate over all (a,b) and solve for c.
        """
        p = self.p
        points = set()
        for a in range(p):
            for b in range(p):
                # Need c^2 = a^2 + b^2 mod p
                target = (a*a + b*b) % p
                for c in range(p):
                    if (c*c) % p == target:
                        v = (a, b, c)
                        if any(x != 0 for x in v):
                            pt = projective_normalize(v, p)
                            if pt is not None:
                                points.add(pt)
        return sorted(points)

    def _build_edges(self):
        """Build directed edges from Berggren generators."""
        for v in self.vertices:
            for M in BERGGREN_GENS:
                w = self._apply_gen(M, v)
                if w is not None and w in self._vert_set:
                    self.out_edges[v].append(w)
                    self.in_edges[w].append(v)

    def _apply_gen(self, M: np.ndarray, v: Tuple[int, ...]) -> Optional[Tuple[int, ...]]:
        """Apply generator M to projective point v."""
        result = tuple(
            sum(int(M[i][j]) * v[j] for j in range(3)) % self.p
            for i in range(3)
        )
        return projective_normalize(result, self.p)

    def adjacency_matrix(self) -> np.ndarray:
        """Return the adjacency matrix A[i,j] = #{generators sending v_i to v_j}.

        Returns:
            n x n numpy array
        """
        A = np.zeros((self.n, self.n))
        for v in self.vertices:
            i = self.idx[v]
            for w in self.out_edges[v]:
                j = self.idx[w]
                A[i][j] += 1.0
        return A

    def markov_matrix(self) -> np.ndarray:
        """Return the row-stochastic (Markov) transition matrix.

        Each row sums to 1 (or 0 for isolated vertices).

        Returns:
            n x n numpy array
        """
        A = self.adjacency_matrix()
        row_sums = A.sum(axis=1)
        row_sums[row_sums == 0] = 1
        return A / row_sums[:, np.newaxis]

    def normalized_matrix(self, d: float = 3.0) -> np.ndarray:
        """Return adjacency matrix normalized by constant d.

        Args:
            d: normalization constant (default 3 for 3 generators)

        Returns:
            n x n numpy array A/d
        """
        return self.adjacency_matrix() / d

    def spectrum(self, matrix_type: str = 'markov') -> np.ndarray:
        """Compute eigenvalues of the specified matrix.

        Args:
            matrix_type: 'plain', 'markov', or 'norm3'

        Returns:
            sorted array of real parts of eigenvalues (descending)
        """
        if matrix_type == 'plain':
            M = self.adjacency_matrix()
        elif matrix_type == 'markov':
            M = self.markov_matrix()
        elif matrix_type == 'norm3':
            M = self.normalized_matrix(3.0)
        else:
            raise ValueError(f"Unknown matrix type: {matrix_type}")

        eigs = np.linalg.eigvals(M)
        return np.sort(np.real(eigs))[::-1]

    def spectral_gap(self, matrix_type: str = 'norm3') -> float:
        """Compute |lambda_2|, the second largest absolute eigenvalue.

        Args:
            matrix_type: type of normalization

        Returns:
            |lambda_2|
        """
        eigs = self.spectrum(matrix_type)
        abs_eigs = np.sort(np.abs(eigs))[::-1]
        return abs_eigs[1] if len(abs_eigs) > 1 else 0.0

    def out_degree_distribution(self) -> Dict[int, int]:
        """Return distribution of out-degrees (distinct targets)."""
        dist = defaultdict(int)
        for v in self.vertices:
            d = len(set(self.out_edges[v]))
            dist[d] += 1
        return dict(dist)

    def in_degree_distribution(self) -> Dict[int, int]:
        """Return distribution of in-degrees."""
        dist = defaultdict(int)
        for v in self.vertices:
            d = len(set(self.in_edges[v]))
            dist[d] += 1
        return dict(dist)

    def connected_components(self) -> List[List[Tuple]]:
        """Find connected components (undirected).

        Returns:
            List of components, each a list of vertices
        """
        visited = set()
        components = []
        for start in self.vertices:
            if start in visited:
                continue
            comp = []
            queue = [start]
            while queue:
                v = queue.pop()
                if v in visited:
                    continue
                visited.add(v)
                comp.append(v)
                for w in self.out_edges[v]:
                    if w not in visited:
                        queue.append(w)
                for u in self.in_edges[v]:
                    if u not in visited:
                        queue.append(u)
            components.append(sorted(comp))
        return components

    def is_bipartite(self) -> bool:
        """Check if the graph (undirected) is bipartite."""
        color = {}
        for start in self.vertices:
            if start in color:
                continue
            color[start] = 0
            queue = [start]
            while queue:
                v = queue.pop(0)
                for w in self.out_edges[v]:
                    if w not in color:
                        color[w] = 1 - color[v]
                        queue.append(w)
                    elif color[w] == color[v]:
                        return False
                for u in self.in_edges[v]:
                    if u not in color:
                        color[u] = 1 - color[v]
                        queue.append(u)
                    elif color[u] == color[v]:
                        return False
        return True

    def mixing_time_estimate(self, epsilon: float = 0.01) -> float:
        """Estimate mixing time of the Markov chain.

        For a reversible Markov chain with spectral gap (1 - lambda_2),
        the mixing time is approximately log(n/epsilon) / (1 - lambda_2).

        Args:
            epsilon: total variation distance threshold

        Returns:
            Estimated mixing time (number of steps)
        """
        lam2 = self.spectral_gap('markov')
        if lam2 >= 1.0:
            return float('inf')
        gap = 1.0 - lam2
        return np.log(self.n / epsilon) / gap


def count_isotropic_points_formula(p: int) -> int:
    """The number of projective isotropic points for Q = x^2 + y^2 - z^2 over F_p.

    For any odd prime p, the projective conic Q = 0 in P^2(F_p) has exactly p+1 points.
    This is because Q is a non-degenerate quadratic form of rank 3, and
    |{Q=0 in P^2}| = q+1 for any non-degenerate conic over F_q.

    Args:
        p: an odd prime

    Returns:
        p + 1
    """
    return p + 1


def ramanujan_bound_biregular(d1: int, d2: int) -> float:
    """The Alon-Boppana bound for (d1,d2)-biregular bipartite graphs.

    For a (d1,d2)-biregular bipartite graph, the nontrivial eigenvalues
    of the normalized adjacency operator satisfy:
        |lambda| >= sqrt(d1-1) + sqrt(d2-1) / sqrt(d1*d2)

    The Ramanujan bound is: |lambda| <= sqrt(d1-1)*sqrt(d2-1) / sqrt(d1*d2)
    For (3,2)-biregular: 1/sqrt(3) * sqrt(2) = sqrt(2/3)
    For normalized adjacency: sqrt((d1-1)(d2-1)) / sqrt(d1*d2)

    Args:
        d1, d2: degrees of the two sides

    Returns:
        The Ramanujan bound
    """
    return np.sqrt((d1 - 1) * (d2 - 1)) / np.sqrt(d1 * d2)


if __name__ == "__main__":
    print("Berggren Orbit Graph Analysis")
    print("=" * 50)

    # Verify generator properties
    print("\nGenerator verification:")
    for M, name in zip(BERGGREN_GENS, ['A', 'B', 'C']):
        print(f"  {name}: det = {int(round(np.linalg.det(M)))}, "
              f"preserves Q: {verify_lorentz_group_membership(M)}")

    print(f"\nRamanujan bound for (3,2)-biregular: {ramanujan_bound_biregular(3, 2):.6f}")
    print(f"1/sqrt(3) = {1/np.sqrt(3):.6f}")

    # Build and analyze graphs
    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73]
    print(f"\n{'p':>4} {'p%8':>4} {'n':>5} {'λ₂':>10} {'1/√3':>10} {'ratio':>10} {'mix_t':>10}")
    print("-" * 60)

    for p in primes:
        G = BerggrenOrbitGraph(p)
        lam2 = G.spectral_gap('norm3')
        mt = G.mixing_time_estimate()
        target = 1.0 / np.sqrt(3)
        print(f"{p:4d} {p%8:4d} {G.n:5d} {lam2:10.6f} {target:10.6f} "
              f"{lam2/target:10.6f} {mt:10.1f}")
