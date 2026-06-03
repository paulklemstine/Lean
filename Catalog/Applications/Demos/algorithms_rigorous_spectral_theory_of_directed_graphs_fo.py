"""
Tropical Spectral Graph Theory: Algorithms

Type-hinted implementations of min-plus matrix operations and
tropical spectral moment computation for directed graphs.
"""

from typing import List, Optional, Tuple
import math

# Type aliases
Inf = float('inf')
Weight = float  # float('inf') represents ⊤
Matrix = List[List[Weight]]


def min_plus_mul(A: Matrix, B: Matrix) -> Matrix:
    """Min-plus matrix multiplication: (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj}).

    Args:
        A: n×n matrix with entries in ℝ≥0 ∪ {∞}
        B: n×n matrix with entries in ℝ≥0 ∪ {∞}

    Returns:
        The min-plus product A ⊗ B

    Time complexity: O(n³)
    """
    n = len(A)
    C: Matrix = [[Inf] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                val = A[i][k] + B[k][j]
                if val < C[i][j]:
                    C[i][j] = val
    return C


def min_plus_id(n: int) -> Matrix:
    """Min-plus identity matrix: 0 on diagonal, ∞ off diagonal.

    Args:
        n: Matrix dimension

    Returns:
        n×n min-plus identity matrix
    """
    return [[0.0 if i == j else Inf for j in range(n)] for i in range(n)]


def min_plus_pow(A: Matrix, k: int) -> Matrix:
    """Compute A^⊗k (k-th min-plus power).

    Uses naive repeated multiplication. For large k, use
    min_plus_pow_fast which uses repeated squaring.

    Args:
        A: n×n weight matrix
        k: Power (non-negative integer)

    Returns:
        A^⊗k

    Time complexity: O(k · n³)
    """
    n = len(A)
    result = min_plus_id(n)
    for _ in range(k):
        result = min_plus_mul(result, A)
    return result


def min_plus_pow_fast(A: Matrix, k: int) -> Matrix:
    """Compute A^⊗k using repeated squaring.

    Exploits the walk composition theorem: A^⊗(k+l) = A^⊗k ⊗ A^⊗l.

    Args:
        A: n×n weight matrix
        k: Power (non-negative integer)

    Returns:
        A^⊗k

    Time complexity: O(n³ · log k)
    """
    n = len(A)
    if k == 0:
        return min_plus_id(n)

    result = min_plus_id(n)
    base = [row[:] for row in A]

    while k > 0:
        if k % 2 == 1:
            result = min_plus_mul(result, base)
        base = min_plus_mul(base, base)
        k //= 2

    return result


def tropical_trace(M: Matrix) -> Weight:
    """Tropical trace: min of diagonal entries.

    Args:
        M: n×n matrix

    Returns:
        min_i M_{ii}
    """
    return min(M[i][i] for i in range(len(M)))


def tropical_moment(A: Matrix, k: int) -> Weight:
    """Compute the k-th tropical spectral moment.

    μ_k = tr⊕(A^⊗k) = min_i (A^⊗k)_{ii}

    This equals the minimum weight of any closed walk of exactly k edges.

    Args:
        A: n×n weight matrix (with ∞ on diagonal for no self-loops)
        k: Moment order

    Returns:
        The k-th tropical spectral moment
    """
    return tropical_trace(min_plus_pow_fast(A, k))


def tropical_spectrum(A: Matrix, max_k: int) -> List[Weight]:
    """Compute tropical spectral moments μ_0, μ_1, ..., μ_{max_k}.

    Efficiently computes all moments up to max_k by accumulating
    min-plus powers.

    Args:
        A: n×n weight matrix
        max_k: Maximum moment order

    Returns:
        List of moments [μ_0, μ_1, ..., μ_{max_k}]
    """
    n = len(A)
    moments: List[Weight] = []
    current = min_plus_id(n)
    moments.append(tropical_trace(current))  # μ_0

    for k in range(1, max_k + 1):
        current = min_plus_mul(current, A)
        moments.append(tropical_trace(current))

    return moments


def minimum_cycle_mean(A: Matrix) -> Weight:
    """Compute the minimum cycle mean (tropical eigenvalue).

    Uses Karp's algorithm: λ* = min_j min_{0≤k<n} (D_n(j) - D_k(j)) / (n - k)
    where D_k(j) = min-plus distance from fixed source to j using exactly k edges.

    Args:
        A: n×n weight matrix

    Returns:
        The minimum cycle mean, or ∞ if the graph is a DAG
    """
    n = len(A)
    if n == 0:
        return Inf

    # Compute distances from each source
    best = Inf

    for s in range(n):
        # D[k][j] = min weight of k-edge walk from s to j
        D: List[List[Weight]] = [[Inf] * n for _ in range(n + 1)]
        D[0][s] = 0.0

        for k in range(n):
            for j in range(n):
                if D[k][j] < Inf:
                    for i in range(n):
                        if A[j][i] < Inf:
                            val = D[k][j] + A[j][i]
                            if val < D[k + 1][i]:
                                D[k + 1][i] = val

        # Karp's formula
        for j in range(n):
            if D[n][j] < Inf:
                max_ratio = -Inf
                valid = False
                for k in range(n):
                    if D[k][j] < Inf:
                        ratio = (D[n][j] - D[k][j]) / (n - k)
                        if ratio > max_ratio:
                            max_ratio = ratio
                        valid = True
                if valid and max_ratio < best:
                    best = max_ratio

    return best


def is_dag(A: Matrix) -> bool:
    """Check if the graph is a DAG using topological sort.

    Args:
        A: n×n weight matrix (∞ = no edge)

    Returns:
        True if the graph is a DAG
    """
    n = len(A)
    # Compute in-degrees
    in_deg = [0] * n
    for j in range(n):
        for i in range(n):
            if A[i][j] < Inf:
                in_deg[j] += 1

    # Kahn's algorithm
    queue = [i for i in range(n) if in_deg[i] == 0]
    count = 0
    while queue:
        v = queue.pop()
        count += 1
        for j in range(n):
            if A[v][j] < Inf:
                in_deg[j] -= 1
                if in_deg[j] == 0:
                    queue.append(j)

    return count == n


def out_degrees(A: Matrix) -> List[int]:
    """Compute out-degree sequence.

    Args:
        A: n×n weight matrix

    Returns:
        List of out-degrees
    """
    n = len(A)
    return [sum(1 for j in range(n) if A[i][j] < Inf) for i in range(n)]


def degree_variance(A: Matrix) -> float:
    """Compute the variance of the out-degree sequence.

    Args:
        A: n×n weight matrix

    Returns:
        Population variance of out-degrees
    """
    degs = out_degrees(A)
    n = len(degs)
    if n == 0:
        return 0.0
    mean = sum(degs) / n
    return sum((d - mean) ** 2 for d in degs) / n
