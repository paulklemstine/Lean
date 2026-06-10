#!/usr/bin/env python3
"""
Tropical Factor Rank — Algorithms

Implements the core algorithms for computing and bounding tropical factor rank,
including constructive decomposition strategies and heuristic optimization.
"""

import numpy as np
from typing import List, Tuple, Optional

INF = float('inf')


def tropical_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)."""
    return min(a, b)


def tropical_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (with ⊤-absorption)."""
    if a == INF or b == INF:
        return INF
    return a + b


class TropicalMatrix:
    """A matrix over the min-plus (tropical) semiring WithTop ℤ."""

    def __init__(self, data: np.ndarray):
        self.data = data.astype(float)
        self.m, self.n = data.shape

    def __getitem__(self, idx):
        return self.data[idx]

    def __repr__(self):
        return f"TropicalMatrix({self.m}×{self.n})\n{self.data}"

    @staticmethod
    def rank_one(u: List[float], v: List[float]) -> 'TropicalMatrix':
        """Construct a rank-1 tropical matrix M[i,j] = u[i] + v[j].

        Complexity: O(m·n) time, O(m·n) space.
        """
        m, n = len(u), len(v)
        data = np.full((m, n), INF)
        for i in range(m):
            for j in range(n):
                data[i, j] = tropical_mul(u[i], v[j])
        return TropicalMatrix(data)

    def tropical_sum(self, other: 'TropicalMatrix') -> 'TropicalMatrix':
        """Tropical sum (entrywise min).

        Complexity: O(m·n) time.
        """
        return TropicalMatrix(np.minimum(self.data, other.data))


class TropicalDecomposition:
    """A tropical rank-r decomposition: M = ⨅_{k=0}^{r-1} (U_k ⊙ V_k^T).

    Attributes:
        Us: List of r row-vectors (each of length m)
        Vs: List of r column-vectors (each of length n)
        rank: The number of summands r
    """

    def __init__(self, Us: List[List[float]], Vs: List[List[float]]):
        assert len(Us) == len(Vs), "Must have equal number of U and V vectors"
        self.Us = Us
        self.Vs = Vs
        self.rank = len(Us)

    def reconstruct(self) -> TropicalMatrix:
        """Reconstruct the matrix from the decomposition.

        Algorithm:
            For each (i, j), compute min_k (U_k[i] + V_k[j]).

        Complexity: O(r·m·n) time, O(m·n) space.
        """
        if self.rank == 0:
            raise ValueError("Cannot reconstruct from rank-0 decomposition")
        m = len(self.Us[0])
        n = len(self.Vs[0])
        data = np.full((m, n), INF)
        for i in range(m):
            for j in range(n):
                val = INF
                for k in range(self.rank):
                    val = tropical_add(val, tropical_mul(self.Us[k][i], self.Vs[k][j]))
                data[i, j] = val
        return TropicalMatrix(data)

    def verify(self, M: TropicalMatrix) -> bool:
        """Verify this decomposition correctly represents M.

        Complexity: O(r·m·n) time.
        """
        reconstructed = self.reconstruct()
        return np.allclose(M.data, reconstructed.data, equal_nan=False) and \
               np.array_equal(np.isinf(M.data), np.isinf(reconstructed.data))

    def pad_to_rank(self, s: int) -> 'TropicalDecomposition':
        """Pad this decomposition to rank s ≥ self.rank.

        Uses the proof strategy from tropDecompOfRank_mono:
        copies of the 0-th summand are appended.

        Complexity: O(s·(m+n)) time.
        """
        assert s >= self.rank
        if self.rank == 0:
            m = 1  # dummy
            n = 1
            return TropicalDecomposition(
                [[INF] * m] * s,
                [[INF] * n] * s
            )
        new_Us = list(self.Us)
        new_Vs = list(self.Vs)
        for _ in range(s - self.rank):
            new_Us.append(list(self.Us[0]))
            new_Vs.append(list(self.Vs[0]))
        return TropicalDecomposition(new_Us, new_Vs)


def column_decomposition(M: TropicalMatrix) -> TropicalDecomposition:
    """Compute the column-wise decomposition of rank n.

    Algorithm (from tropDecomp_columnWitness):
        For each column k, set:
            U_k[i] = M[i, k]
            V_k[j] = 0 if j == k, ⊤ otherwise

        Then min_k (U_k[i] + V_k[j]) = min_k (M[i,k] + δ_{jk})
             = M[i,j] + 0 = M[i,j]   (the k=j term dominates).

    Complexity: O(m·n) time, O(m·n) space.
    Produces decomposition of rank n.
    """
    m, n = M.m, M.n
    Us = []
    Vs = []
    for k in range(n):
        u = [M[i, k] for i in range(m)]
        v = [0.0 if j == k else INF for j in range(n)]
        Us.append(u)
        Vs.append(v)
    return TropicalDecomposition(Us, Vs)


def row_decomposition(M: TropicalMatrix) -> TropicalDecomposition:
    """Compute the row-wise decomposition of rank m.

    Algorithm (from tropDecomp_rowWitness):
        For each row k, set:
            U_k[i] = 0 if i == k, ⊤ otherwise
            V_k[j] = M[k, j]

    Complexity: O(m·n) time, O(m·n) space.
    Produces decomposition of rank m.
    """
    m, n = M.m, M.n
    Us = []
    Vs = []
    for k in range(m):
        u = [0.0 if i == k else INF for i in range(m)]
        v = [M[k, j] for j in range(n)]
        Us.append(u)
        Vs.append(v)
    return TropicalDecomposition(Us, Vs)


def concatenate_decompositions(
    d1: TropicalDecomposition,
    d2: TropicalDecomposition
) -> TropicalDecomposition:
    """Concatenate two decompositions for subadditivity.

    If d1 decomposes A with rank r and d2 decomposes B with rank s,
    then the concatenation decomposes min(A, B) with rank r + s.

    This implements the proof of tropDecomp_add.

    Complexity: O((r+s)·(m+n)) time.
    """
    return TropicalDecomposition(
        d1.Us + d2.Us,
        d1.Vs + d2.Vs
    )


def greedy_factor_rank(M: TropicalMatrix, max_rank: Optional[int] = None) -> Tuple[int, TropicalDecomposition]:
    """Heuristic greedy algorithm for approximate tropical factor rank.

    Algorithm:
        1. Use the column decomposition as a starting point (rank n).
        2. Try to find decompositions with fewer summands by searching
           for rank-1 matrices that cover many entries of M.
        3. The greedy strategy picks anchor pairs (i0, j0) and builds
           rank-1 candidates u[i] = M[i,j0], v[j] = M[i0,j] - M[i0,j0].

    Complexity: O(min(m,n) · m · n · (m + n)) time.

    Returns:
        (rank, decomposition): The achieved rank and its decomposition.
    """
    m, n = M.m, M.n
    if max_rank is None:
        max_rank = min(m, n)

    finite_mask = np.isfinite(M.data)
    if not finite_mask.any():
        return 0, TropicalDecomposition([], [])

    # Start with column decomposition (guaranteed correct)
    best_decomp = column_decomposition(M)
    best_rank = best_decomp.rank

    # Also try row decomposition
    row_d = row_decomposition(M)
    if row_d.rank < best_rank:
        best_decomp = row_d
        best_rank = row_d.rank

    # Try greedy: pick best rank-1 approximations and build up
    Us_greedy, Vs_greedy = [], []
    remaining = M.data.copy()

    for iteration in range(max_rank):
        # Try all anchor pairs to find best rank-1 approximation
        best_u, best_v = None, None
        best_error = INF

        for i0 in range(m):
            for j0 in range(n):
                if not np.isfinite(M.data[i0, j0]):
                    continue
                u = [M.data[i, j0] for i in range(m)]
                v = [M.data[i0, j] - M.data[i0, j0] if np.isfinite(M.data[i0, j]) else INF
                     for j in range(n)]

                # Compute how well min(current_decomp, this rank-1) matches M
                error = 0
                for i in range(m):
                    for j in range(n):
                        if np.isfinite(M.data[i, j]):
                            cur = remaining[i, j]
                            new_val = tropical_mul(u[i], v[j])
                            combined = min(cur, new_val) if np.isfinite(cur) else new_val
                            error += abs(combined - M.data[i, j])

                if error < best_error:
                    best_error = error
                    best_u, best_v = u, v

        if best_u is None:
            break

        Us_greedy.append(best_u)
        Vs_greedy.append(best_v)

        # Update remaining
        for i in range(m):
            for j in range(n):
                new_val = tropical_mul(best_u[i], best_v[j])
                remaining[i, j] = min(remaining[i, j], new_val)

        # Check if greedy decomposition matches M
        decomp = TropicalDecomposition(Us_greedy, Vs_greedy)
        if decomp.verify(M):
            if decomp.rank < best_rank:
                best_decomp = decomp
                best_rank = decomp.rank
            break

    return best_rank, best_decomp


def factor_rank_upper_bound(M: TropicalMatrix) -> int:
    """Compute the tight dimension upper bound on factor rank.

    Returns min(m, n), which is guaranteed to be an upper bound
    by tropFactorRank_le_min.

    Complexity: O(1) time.
    """
    return min(M.m, M.n)


def is_rank_one(M: TropicalMatrix) -> Tuple[bool, Optional[Tuple[List[float], List[float]]]]:
    """Check if a matrix is tropical rank-1.

    Algorithm:
        A matrix M is rank-1 iff M[i,j] = u[i] + v[j] for some u, v.
        This requires M[i,j] + M[i',j'] = M[i,j'] + M[i',j] for all i,i',j,j'.
        (The "Monge property" / "anti-Monge" depending on convention.)

        If rank-1, extract u[i] = M[i, 0] and v[j] = M[0, j] - M[0, 0].

    Complexity: O(m·n) time for verification.

    Returns:
        (is_rank_one, (u, v) or None)
    """
    m, n = M.m, M.n
    if m == 0 or n == 0:
        return True, ([], [])

    # Check for all-⊤ matrix
    if not np.isfinite(M.data).any():
        return True, ([INF] * m, [0.0] * n)

    # Find a finite entry to anchor
    anchor = None
    for i in range(m):
        for j in range(n):
            if np.isfinite(M[i, j]):
                anchor = (i, j)
                break
        if anchor:
            break

    i0, j0 = anchor
    u = [M[i, j0] for i in range(m)]
    v = [M[i0, j] - M[i0, j0] if np.isfinite(M[i0, j]) else INF for j in range(n)]

    # Verify
    for i in range(m):
        for j in range(n):
            expected = tropical_mul(u[i], v[j])
            if abs(M[i, j] - expected) > 1e-9 if np.isfinite(M[i,j]) and np.isfinite(expected) else (np.isfinite(M[i,j]) != np.isfinite(expected)):
                return False, None

    return True, (u, v)


# ─── Example usage ───

if __name__ == "__main__":
    print("Tropical Factor Rank Algorithms")
    print("=" * 50)

    # Example 1: Rank-1 matrix
    M1 = TropicalMatrix(np.array([[3, 1, 5],
                                    [5, 3, 7],
                                    [2, 0, 4]], dtype=float))
    print("\nMatrix M1:")
    print(M1.data)
    is_r1, witness = is_rank_one(M1)
    print(f"Is rank-1? {is_r1}")
    if witness:
        print(f"  u = {witness[0]}, v = {witness[1]}")

    # Example 2: Non rank-1 matrix
    M2 = TropicalMatrix(np.array([[0, 1],
                                    [1, 0]], dtype=float))
    print(f"\nMatrix M2:\n{M2.data}")
    is_r1, _ = is_rank_one(M2)
    print(f"Is rank-1? {is_r1}")

    # Column decomposition
    decomp = column_decomposition(M2)
    print(f"Column decomposition rank: {decomp.rank}")
    print(f"Verification: {decomp.verify(M2)}")

    # Greedy factor rank
    rank, decomp = greedy_factor_rank(M2)
    print(f"Greedy factor rank: {rank}")
    print(f"Verification: {decomp.verify(M2)}")

    # Example 3: Larger matrix
    np.random.seed(42)
    M3 = TropicalMatrix(np.random.randint(-5, 6, size=(5, 4)).astype(float))
    print(f"\nRandom 5×4 matrix:\n{M3.data}")
    print(f"Upper bound: min(5,4) = {factor_rank_upper_bound(M3)}")
    rank, decomp = greedy_factor_rank(M3)
    print(f"Greedy factor rank: {rank}")
    print(f"Verification: {decomp.verify(M3)}")
