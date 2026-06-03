"""
CSS Codes from Chain Complexes: Core Algorithms

Implements the HQECC construction: given a chain complex (boundary matrices
over GF(2)), compute the CSS code parameters [n, k, d].
"""

from typing import List, Tuple, Optional
import numpy as np


def gf2_rref(matrix: np.ndarray) -> Tuple[np.ndarray, List[int]]:
    """Compute reduced row echelon form over GF(2).

    Args:
        matrix: Binary matrix (entries in {0, 1}).

    Returns:
        Tuple of (rref matrix, list of pivot column indices).
    """
    M = matrix.copy() % 2
    rows, cols = M.shape
    pivots: List[int] = []
    row_idx = 0

    for col in range(cols):
        # Find pivot
        found = False
        for r in range(row_idx, rows):
            if M[r, col] == 1:
                found = True
                M[[row_idx, r]] = M[[r, row_idx]]
                break
        if not found:
            continue

        pivots.append(col)
        # Eliminate
        for r in range(rows):
            if r != row_idx and M[r, col] == 1:
                M[r] = (M[r] + M[row_idx]) % 2
        row_idx += 1

    return M, pivots


def gf2_rank(matrix: np.ndarray) -> int:
    """Compute the rank of a binary matrix over GF(2)."""
    if matrix.size == 0:
        return 0
    _, pivots = gf2_rref(matrix)
    return len(pivots)


def gf2_kernel(matrix: np.ndarray) -> np.ndarray:
    """Compute a basis for the kernel of a binary matrix over GF(2).

    Args:
        matrix: Binary matrix of shape (m, n).

    Returns:
        Matrix whose rows form a basis for ker(matrix) over GF(2).
    """
    m, n = matrix.shape
    # Augment with identity
    aug = np.hstack([matrix.T, np.eye(n, dtype=int)]) % 2
    rref, pivots = gf2_rref(aug)

    kernel_basis = []
    for i in range(n):
        if i not in pivots:
            # This row in the augmented system gives a kernel vector
            pass

    # Alternative: use null space construction
    rref_mat, pivots = gf2_rref(matrix)
    rank = len(pivots)
    free_cols = [j for j in range(n) if j not in pivots]

    kernel_vectors = []
    for fc in free_cols:
        vec = np.zeros(n, dtype=int)
        vec[fc] = 1
        for idx, pc in enumerate(pivots):
            vec[pc] = rref_mat[idx, fc]
        kernel_vectors.append(vec % 2)

    if kernel_vectors:
        return np.array(kernel_vectors, dtype=int)
    return np.zeros((0, n), dtype=int)


def hamming_weight(v: np.ndarray) -> int:
    """Compute the Hamming weight of a binary vector."""
    return int(np.sum(v != 0))


class CSSCode:
    """A CSS quantum error-correcting code over GF(2).

    Constructed from two classical codes satisfying C_Z <= C_X.

    Attributes:
        n: Block length (number of physical qubits).
        k: Number of logical qubits.
        H_X: X-stabilizer parity check matrix.
        H_Z: Z-stabilizer parity check matrix.
    """

    def __init__(self, H_X: np.ndarray, H_Z: np.ndarray):
        """Initialize CSS code from parity check matrices.

        Args:
            H_X: X-stabilizer parity check matrix (r_X × n over GF(2)).
            H_Z: Z-stabilizer parity check matrix (r_Z × n over GF(2)).
        """
        assert H_X.shape[1] == H_Z.shape[1], "Matrices must have same number of columns"
        # Verify orthogonality: H_X · H_Z^T = 0 mod 2
        product = (H_X @ H_Z.T) % 2
        assert np.all(product == 0), "CSS orthogonality condition H_X · H_Z^T = 0 failed"

        self.n: int = H_X.shape[1]
        self.H_X = H_X % 2
        self.H_Z = H_Z % 2
        self.k: int = self.n - gf2_rank(H_X) - gf2_rank(H_Z)

    def __repr__(self) -> str:
        return f"CSSCode[[{self.n}, {self.k}]]"

    def compute_distance(self, max_weight: Optional[int] = None) -> int:
        """Compute the code distance (minimum weight of a logical operator).

        This is NP-hard in general; only feasible for small codes.

        Args:
            max_weight: Maximum weight to search up to.

        Returns:
            The minimum distance, or -1 if not found within max_weight.
        """
        if max_weight is None:
            max_weight = self.n

        # X-distance: min weight of v in ker(H_Z) \ rowspan(H_X)
        ker_Z = gf2_kernel(self.H_Z)
        if ker_Z.shape[0] == 0:
            return 0

        # Check if each kernel vector is in rowspan of H_X
        # by checking if augmenting H_X with the vector increases rank
        rank_HX = gf2_rank(self.H_X)

        d_X = self.n + 1
        # Enumerate low-weight combinations
        for weight in range(1, max_weight + 1):
            found = False
            for combo in _weight_combinations(ker_Z, weight):
                v = combo % 2
                if hamming_weight(v) != weight:
                    continue
                aug = np.vstack([self.H_X, v.reshape(1, -1)])
                if gf2_rank(aug) > rank_HX:
                    d_X = weight
                    found = True
                    break
            if found:
                break

        # Z-distance: min weight of v in ker(H_X) \ rowspan(H_Z)
        ker_X = gf2_kernel(self.H_X)
        rank_HZ = gf2_rank(self.H_Z)

        d_Z = self.n + 1
        for weight in range(1, max_weight + 1):
            found = False
            for combo in _weight_combinations(ker_X, weight):
                v = combo % 2
                if hamming_weight(v) != weight:
                    continue
                aug = np.vstack([self.H_Z, v.reshape(1, -1)])
                if gf2_rank(aug) > rank_HZ:
                    d_Z = weight
                    found = True
                    break
            if found:
                break

        return min(d_X, d_Z)


def _weight_combinations(basis: np.ndarray, max_terms: int):
    """Generate GF(2) combinations of basis vectors using up to max_terms vectors."""
    n_basis = basis.shape[0]
    if max_terms == 0:
        return
    for i in range(n_basis):
        yield basis[i]
    if max_terms >= 2:
        for i in range(n_basis):
            for j in range(i + 1, n_basis):
                yield (basis[i] + basis[j]) % 2
    if max_terms >= 3:
        for i in range(n_basis):
            for j in range(i + 1, n_basis):
                for l in range(j + 1, n_basis):
                    yield (basis[i] + basis[j] + basis[l]) % 2


class ChainComplex3:
    """A 3-term chain complex V_2 ->[d2] V_1 ->[d1] V_0 over GF(2).

    The chain condition d1 @ d2 = 0 (mod 2) must hold.
    """

    def __init__(self, d2: np.ndarray, d1: np.ndarray):
        """Initialize chain complex.

        Args:
            d2: Boundary matrix from V_2 to V_1 (n × m matrix).
            d1: Boundary matrix from V_1 to V_0 (p × n matrix).
        """
        assert d1.shape[1] == d2.shape[0], "Matrix dimensions incompatible"
        chain_prod = (d1 @ d2) % 2
        assert np.all(chain_prod == 0), "Chain condition d1 ∘ d2 = 0 failed"

        self.d2 = d2 % 2
        self.d1 = d1 % 2
        self.n: int = d2.shape[0]  # dim V_1
        self.m: int = d2.shape[1]  # dim V_2
        self.p: int = d1.shape[0]  # dim V_0

    def cycles_dim(self) -> int:
        """Dimension of Z_1 = ker(d1)."""
        return self.n - gf2_rank(self.d1)

    def boundaries_dim(self) -> int:
        """Dimension of B_1 = im(d2)."""
        return gf2_rank(self.d2)

    def betti1(self) -> int:
        """First Betti number β_1 = dim(H_1) = dim(Z_1) - dim(B_1)."""
        return self.cycles_dim() - self.boundaries_dim()

    def to_css_code(self) -> CSSCode:
        """Construct CSS code: H_X = d1, H_Z = d2^T."""
        return CSSCode(H_X=self.d1, H_Z=self.d2.T)


def hypercube_chain_complex(n: int) -> ChainComplex3:
    """Construct the chain complex of the n-dimensional hypercube graph Q_n.

    Vertices: {0,1}^n (2^n vertices).
    Edges: pairs differing in exactly one coordinate (n * 2^(n-1) edges).

    Returns:
        ChainComplex3 for Q_n with d1 = incidence matrix, d2 = face-edge matrix.
    """
    num_vertices = 2 ** n
    edges: List[Tuple[int, int]] = []
    edge_index = {}

    for v in range(num_vertices):
        for bit in range(n):
            w = v ^ (1 << bit)
            if v < w:
                edge_index[(v, w)] = len(edges)
                edges.append((v, w))

    num_edges = len(edges)

    # d1: incidence matrix (num_vertices × num_edges)
    d1 = np.zeros((num_vertices, num_edges), dtype=int)
    for idx, (v, w) in enumerate(edges):
        d1[v, idx] = 1
        d1[w, idx] = 1  # Over GF(2), +1 = -1

    # d2: 2-faces (squares) to edges
    # Squares: for each vertex v and each pair of bit positions (i, j) with i < j,
    # the four vertices v, v^(1<<i), v^(1<<j), v^(1<<i)^(1<<j) form a square.
    # We only count each square once (by requiring v to have 0 in both positions i, j).
    faces: List[Tuple[int, int, int, int]] = []

    for v in range(num_vertices):
        for i in range(n):
            if v & (1 << i):
                continue
            for j in range(i + 1, n):
                if v & (1 << j):
                    continue
                # Square with corners v, v^(1<<i), v^(1<<j), v^(1<<i)^(1<<j)
                faces.append((v, i, j, len(faces)))

    num_faces = len(faces)
    d2 = np.zeros((num_edges, num_faces), dtype=int)

    for face_idx, (v, i, j, _) in enumerate(faces):
        v_i = v ^ (1 << i)
        v_j = v ^ (1 << j)
        v_ij = v ^ (1 << i) ^ (1 << j)

        # Four edges of the square
        e1 = edge_index[tuple(sorted((v, v_i)))]
        e2 = edge_index[tuple(sorted((v, v_j)))]
        e3 = edge_index[tuple(sorted((v_i, v_ij)))]
        e4 = edge_index[tuple(sorted((v_j, v_ij)))]

        d2[e1, face_idx] = 1
        d2[e2, face_idx] = 1
        d2[e3, face_idx] = 1
        d2[e4, face_idx] = 1

    # Over GF(2), d1 @ d2 = 0 because each edge of a square contributes
    # to exactly two vertices of that square.
    return ChainComplex3(d2=d2, d1=d1)


def cycle_graph_chain_complex(m: int) -> ChainComplex3:
    """Chain complex of the cycle graph C_m.

    m vertices, m edges forming a cycle.
    """
    # d1: incidence matrix (m × m)
    d1 = np.zeros((m, m), dtype=int)
    edges = []
    for i in range(m):
        j = (i + 1) % m
        d1[i, len(edges)] = 1
        d1[j, len(edges)] = 1
        edges.append((i, j))

    # d2: no 2-faces
    d2 = np.zeros((m, 0), dtype=int)

    return ChainComplex3(d2=d2, d1=d1)


def torus_chain_complex(L: int) -> ChainComplex3:
    """Chain complex of the L×L torus (square lattice with periodic BC).

    Vertices: L^2, Edges: 2*L^2, Faces: L^2.
    Expected: β_1 = 2.
    """
    n_vert = L * L

    def vid(x: int, y: int) -> int:
        return (x % L) * L + (y % L)

    # Horizontal and vertical edges
    edges = []
    edge_map = {}
    for x in range(L):
        for y in range(L):
            # Horizontal edge (x,y) -> (x, y+1)
            v1, v2 = vid(x, y), vid(x, y + 1)
            key = (min(v1, v2), max(v1, v2))
            if key not in edge_map:
                edge_map[key] = len(edges)
                edges.append(key)
            # Vertical edge (x,y) -> (x+1, y)
            v1, v2 = vid(x, y), vid(x + 1, y)
            key = (min(v1, v2), max(v1, v2))
            if key not in edge_map:
                edge_map[key] = len(edges)
                edges.append(key)

    n_edges = len(edges)

    # d1: incidence matrix
    d1 = np.zeros((n_vert, n_edges), dtype=int)
    for idx, (v1, v2) in enumerate(edges):
        d1[v1, idx] = 1
        d1[v2, idx] = 1

    # Faces: each unit square (x, y) with corners
    # (x,y), (x,y+1), (x+1,y), (x+1,y+1)
    n_faces = L * L
    d2 = np.zeros((n_edges, n_faces), dtype=int)
    for x in range(L):
        for y in range(L):
            face_idx = x * L + y
            corners = [
                (vid(x, y), vid(x, y + 1)),
                (vid(x, y), vid(x + 1, y)),
                (vid(x, y + 1), vid(x + 1, y + 1)),
                (vid(x + 1, y), vid(x + 1, y + 1)),
            ]
            for v1, v2 in corners:
                key = (min(v1, v2), max(v1, v2))
                if key in edge_map:
                    d2[edge_map[key], face_idx] = (d2[edge_map[key], face_idx] + 1) % 2

    return ChainComplex3(d2=d2, d1=d1)


if __name__ == "__main__":
    print("=== CSS Codes from Chain Complexes ===\n")

    # Example 1: Cycle graph C_5
    print("--- Cycle graph C_5 ---")
    K = cycle_graph_chain_complex(5)
    print(f"  n (edges) = {K.n}")
    print(f"  dim(Z_1) = {K.cycles_dim()}")
    print(f"  dim(B_1) = {K.boundaries_dim()}")
    print(f"  β_1 = {K.betti1()}")

    # Example 2: Hypercubes
    for dim in [2, 3, 4, 5]:
        print(f"\n--- Hypercube Q_{dim} ---")
        K = hypercube_chain_complex(dim)
        print(f"  Vertices = {2**dim}, Edges = {K.n}")
        print(f"  dim(Z_1) = {K.cycles_dim()}")
        print(f"  dim(B_1) = {K.boundaries_dim()}")
        print(f"  β_1 = {K.betti1()}")
        print(f"  Formula: n*2^(n-1) - 2^n + 1 = {dim * 2**(dim-1) - 2**dim + 1}")

    # Example 3: Torus
    for L in [3, 4, 5]:
        print(f"\n--- Torus {L}×{L} ---")
        K = torus_chain_complex(L)
        print(f"  Edges = {K.n}, Faces = {K.d2.shape[1]}")
        print(f"  β_1 = {K.betti1()}")
