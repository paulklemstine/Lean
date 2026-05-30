"""
Algorithms for Prime-Sensitive Torsion Echoes in Random Flag Complexes

Implements:
1. TorsionEchoSignature computation
2. Sensitivity index analysis
3. Random flag complex generation and face counting
4. Smith normal form for integer homology computation
"""

from math import comb, gcd
from typing import List, Dict, Tuple, Set, Optional
from itertools import combinations
import random


# ============================================================
# Algorithm 1: p-adic Valuation and Torsion Profile
# ============================================================

def padic_val(p: int, n: int) -> int:
    """
    Compute the p-adic valuation v_p(n).

    Time complexity: O(log_p(n))
    Space complexity: O(1)

    >>> padic_val(2, 24)
    3
    >>> padic_val(3, 24)
    1
    >>> padic_val(5, 24)
    0
    """
    if n == 0 or p < 2:
        return 0
    k = 0
    while n % p == 0:
        n //= p
        k += 1
    return k


def padic_val_profile(n: int, primes: List[int]) -> Dict[int, int]:
    """
    Compute the full p-adic valuation profile of n.

    Time complexity: O(|primes| * log(n))
    Space complexity: O(|primes|)

    >>> padic_val_profile(360, [2, 3, 5])
    {2: 3, 3: 2, 5: 1}
    """
    return {p: padic_val(p, n) for p in primes}


# ============================================================
# Algorithm 2: Torsion Echo Signature
# ============================================================

class TorsionEchoSignature:
    """
    Encapsulates the torsion echo signature of a group order.

    Attributes:
        group_order: The order of the finite abelian group
        primes: Set of primes to analyze
        valuations: Dict mapping each prime to its valuation
    """

    def __init__(self, group_order: int, primes: List[int]):
        self.group_order = group_order
        self.primes = sorted(set(primes))
        self.valuations = {p: padic_val(p, group_order) for p in self.primes}

    def sensitivity_index(self) -> int:
        """
        Compute the sensitivity index: number of distinct valuations
        across all primes.

        Returns 1 for universal (prime-independent) behavior,
        >1 for prime-sensitive behavior.

        Time complexity: O(|primes|)
        Space complexity: O(|primes|)
        """
        return len(set(self.valuations.values()))

    def is_universal(self) -> bool:
        """Check if all primes give the same valuation."""
        return self.sensitivity_index() == 1

    def non_universal_pairs(self) -> List[Tuple[int, int]]:
        """Return all pairs of primes with different valuations."""
        pairs = []
        for i, p in enumerate(self.primes):
            for q in self.primes[i+1:]:
                if self.valuations[p] != self.valuations[q]:
                    pairs.append((p, q))
        return pairs

    def __repr__(self):
        vals_str = ", ".join(f"v_{p}={v}" for p, v in self.valuations.items())
        return (f"TorsionEchoSignature(n={self.group_order}, "
                f"SI={self.sensitivity_index()}, {vals_str})")


# ============================================================
# Algorithm 3: Random Flag Complex Generation
# ============================================================

class FlagComplex:
    """
    Random flag complex on n vertices with edge probability p.

    A flag complex is the largest simplicial complex whose 1-skeleton
    is a given graph. Every clique in the graph becomes a simplex.

    Attributes:
        n: Number of vertices
        edges: Set of edges (as frozensets)
        max_dim: Maximum dimension of faces found
    """

    def __init__(self, n: int, edges: Optional[Set[frozenset]] = None):
        self.n = n
        self.edges = edges if edges is not None else set()
        self._faces_cache: Optional[Dict[int, List[frozenset]]] = None

    @classmethod
    def random(cls, n: int, p: float, seed: Optional[int] = None) -> 'FlagComplex':
        """
        Generate a random flag complex on n vertices with edge probability p.

        Time complexity: O(n^2) for edge generation + O(n^k) for k-clique enumeration
        """
        if seed is not None:
            random.seed(seed)
        edges = set()
        for i in range(n):
            for j in range(i + 1, n):
                if random.random() < p:
                    edges.add(frozenset({i, j}))
        return cls(n, edges)

    def _compute_faces(self, max_dim: int = 5) -> Dict[int, List[frozenset]]:
        """Enumerate all faces up to dimension max_dim using clique enumeration."""
        if self._faces_cache is not None:
            return self._faces_cache

        # Start with vertices and edges
        faces: Dict[int, List[frozenset]] = {}
        faces[0] = [frozenset({v}) for v in range(self.n)]
        faces[1] = [e for e in self.edges]

        # Build adjacency for fast neighbor lookup
        adj: Dict[int, Set[int]] = {v: set() for v in range(self.n)}
        for e in self.edges:
            u, v = list(e)
            adj[u].add(v)
            adj[v].add(u)

        # Enumerate higher-dimensional faces (cliques) by extension
        for dim in range(2, max_dim + 1):
            faces[dim] = []
            if dim - 1 not in faces or not faces[dim - 1]:
                break
            for face in faces[dim - 1]:
                face_list = sorted(face)
                max_v = face_list[-1]
                # Candidate extensions
                common_neighbors = set(range(max_v + 1, self.n))
                for v in face_list:
                    common_neighbors &= adj[v]
                for w in common_neighbors:
                    new_face = face | frozenset({w})
                    faces[dim].append(new_face)
            # Remove duplicates
            faces[dim] = list(set(faces[dim]))

        self._faces_cache = faces
        return faces

    def f_vector(self, max_dim: int = 5) -> List[int]:
        """
        Compute the f-vector: f_k = number of k-dimensional faces.

        Time complexity: O(n^(max_dim+1)) worst case
        """
        faces = self._compute_faces(max_dim)
        return [len(faces.get(k, [])) for k in range(max_dim + 1)]

    def euler_characteristic(self, max_dim: int = 5) -> int:
        """
        Compute the Euler characteristic χ = Σ (-1)^k f_k.

        Time complexity: O(f-vector computation)
        """
        fvec = self.f_vector(max_dim)
        return sum((-1)**k * fk for k, fk in enumerate(fvec))


# ============================================================
# Algorithm 4: Smith Normal Form (simplified for small matrices)
# ============================================================

def smith_normal_form(matrix: List[List[int]]) -> List[int]:
    """
    Compute the Smith normal form diagonal of an integer matrix.

    This is a simplified implementation for small matrices.
    Returns the list of diagonal invariant factors.

    Time complexity: O(min(m,n) * m * n) where m x n is the matrix size
    """
    if not matrix or not matrix[0]:
        return []

    m = len(matrix)
    n = len(matrix[0])
    # Work with a copy
    A = [row[:] for row in matrix]

    min_dim = min(m, n)
    diagonal = []

    for col in range(min_dim):
        # Find pivot
        pivot_row = None
        for i in range(col, m):
            for j in range(col, n):
                if A[i][j] != 0:
                    pivot_row = i
                    pivot_col = j
                    break
            if pivot_row is not None:
                break

        if pivot_row is None:
            diagonal.extend([0] * (min_dim - col))
            break

        # Swap rows and columns to bring pivot to (col, col)
        A[col], A[pivot_row] = A[pivot_row], A[col]
        if pivot_col != col:
            for i in range(m):
                A[i][col], A[i][pivot_col] = A[i][pivot_col], A[i][col]

        # Iterate elimination
        changed = True
        max_iter = 100
        iteration = 0
        while changed and iteration < max_iter:
            changed = False
            iteration += 1

            # Row elimination
            for i in range(col + 1, m):
                if A[i][col] != 0:
                    if A[col][col] == 0:
                        A[col], A[i] = A[i], A[col]
                        changed = True
                        continue
                    q = A[i][col] // A[col][col]
                    for j in range(n):
                        A[i][j] -= q * A[col][j]
                    if A[i][col] != 0:
                        # Need to use gcd-based approach
                        g = gcd(abs(A[col][col]), abs(A[i][col]))
                        s = A[col][col] // g
                        t = A[i][col] // g
                        for j in range(n):
                            old_col_j = A[col][j]
                            old_i_j = A[i][j]
                            A[col][j] = old_col_j  # simplified
                            A[i][j] = s * old_i_j - t * old_col_j
                        changed = True

            # Column elimination
            for j in range(col + 1, n):
                if A[col][j] != 0:
                    if A[col][col] == 0:
                        for i in range(m):
                            A[i][col], A[i][j] = A[i][j], A[i][col]
                        changed = True
                        continue
                    q = A[col][j] // A[col][col]
                    for i in range(m):
                        A[i][j] -= q * A[i][col]
                    if A[col][j] != 0:
                        changed = True

        diagonal.append(abs(A[col][col]) if col < m and col < n else 0)

    return diagonal


def torsion_from_smith(diagonal: List[int]) -> List[int]:
    """
    Extract torsion invariant factors from Smith normal form diagonal.

    Returns the list of factors > 1 (the torsion part).
    """
    return [d for d in diagonal if d > 1]


# ============================================================
# Algorithm 5: Sensitivity Analysis across Random Complexes
# ============================================================

def analyze_torsion_sensitivity(
    n_vertices: int,
    edge_prob: float,
    n_samples: int,
    primes: List[int],
    seed: int = 42
) -> Dict:
    """
    Analyze torsion sensitivity across random flag complexes.

    For each sample, generates a random flag complex, computes the
    Euler characteristic (as a proxy for homological data), and
    analyzes the sensitivity of various torsion-related quantities.

    Args:
        n_vertices: Number of vertices in the complex
        edge_prob: Edge inclusion probability
        n_samples: Number of random samples
        primes: Primes to analyze
        seed: Random seed

    Returns:
        Dictionary with analysis results
    """
    random.seed(seed)
    results = {
        'euler_chars': [],
        'f_vectors': [],
        'sensitivity_indices': [],
        'edge_counts': [],
    }

    for i in range(n_samples):
        K = FlagComplex.random(n_vertices, edge_prob, seed=seed + i)
        fvec = K.f_vector(max_dim=3)
        chi = K.euler_characteristic(max_dim=3)

        # Use edge count as proxy for torsion order
        edge_count = fvec[1] if len(fvec) > 1 else 0
        if edge_count > 1:
            sig = TorsionEchoSignature(edge_count, primes)
            si = sig.sensitivity_index()
        else:
            si = 0

        results['euler_chars'].append(chi)
        results['f_vectors'].append(fvec)
        results['sensitivity_indices'].append(si)
        results['edge_counts'].append(edge_count)

    return results


# ============================================================
# Main: Run all algorithms with example data
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm Demonstrations")
    print("=" * 60)

    # Demo 1: Torsion Echo Signatures
    print("\n--- Torsion Echo Signatures ---")
    test_orders = [12, 30, 60, 120, 360, 2310]
    primes = [2, 3, 5, 7, 11]

    for n in test_orders:
        sig = TorsionEchoSignature(n, primes)
        print(f"  {sig}")
        if not sig.is_universal():
            pairs = sig.non_universal_pairs()
            print(f"    Non-universal pairs: {pairs[:5]}")

    # Demo 2: Random Flag Complex Analysis
    print("\n--- Random Flag Complex Analysis ---")
    for n in [8, 10, 12]:
        for p in [0.3, 0.5, 0.7]:
            results = analyze_torsion_sensitivity(n, p, 10, [2, 3, 5])
            avg_chi = sum(results['euler_chars']) / len(results['euler_chars'])
            avg_si = sum(results['sensitivity_indices']) / len(results['sensitivity_indices'])
            print(f"  n={n}, p={p:.1f}: avg_χ={avg_chi:.1f}, "
                  f"avg_SI={avg_si:.1f}, "
                  f"avg_edges={sum(results['edge_counts'])/len(results['edge_counts']):.1f}")

    # Demo 3: Smith Normal Form
    print("\n--- Smith Normal Form Examples ---")
    test_matrices = [
        [[2, 4], [6, 8]],
        [[1, 2, 3], [4, 5, 6]],
        [[6, 0, 0], [0, 12, 0], [0, 0, 30]],
    ]
    for mat in test_matrices:
        diag = smith_normal_form(mat)
        torsion = torsion_from_smith(diag)
        print(f"  Matrix {mat}")
        print(f"    SNF diagonal: {diag}, torsion factors: {torsion}")

    print("\nAll algorithm demonstrations complete.")
