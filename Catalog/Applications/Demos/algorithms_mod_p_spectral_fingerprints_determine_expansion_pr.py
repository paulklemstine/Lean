"""
Algorithms for Mod-p Spectral Fingerprints

Implements the core algorithms from the research paper:
1. Mod-p Gaussian elimination (O(n^3) per prime)
2. Spectral fingerprint computation
3. Determinant recovery from fingerprint
4. Edge boundary computation for expansion analysis
"""

from typing import List, Dict, Tuple, Optional
import math


def sieve_primes(N: int) -> List[int]:
    """
    Sieve of Eratosthenes.

    Time: O(N log log N)
    Space: O(N)

    Args:
        N: Upper bound for prime search

    Returns:
        List of all primes up to N

    >>> sieve_primes(20)
    [2, 3, 5, 7, 11, 13, 17, 19]
    """
    if N < 2:
        return []
    sieve = [True] * (N + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(N**0.5) + 1):
        if sieve[i]:
            for j in range(i * i, N + 1, i):
                sieve[j] = False
    return [i for i in range(2, N + 1) if sieve[i]]


def mod_p_gaussian_elimination(M: List[List[int]], p: int) -> int:
    """
    Gaussian elimination over F_p to compute rank.

    Time: O(n^2 * min(n, m))
    Space: O(n * m)

    Args:
        M: Integer matrix as list of lists
        p: Prime modulus

    Returns:
        Rank of M mod p

    >>> mod_p_gaussian_elimination([[1, 2], [3, 4]], 5)
    2
    >>> mod_p_gaussian_elimination([[2, 4], [1, 2]], 3)
    1
    """
    n = len(M)
    if n == 0:
        return 0
    m = len(M[0])

    # Copy and reduce mod p
    A = [[M[i][j] % p for j in range(m)] for i in range(n)]

    rank = 0
    for col in range(m):
        # Find pivot in current column
        pivot_row = None
        for row in range(rank, n):
            if A[row][col] % p != 0:
                pivot_row = row
                break

        if pivot_row is None:
            continue

        # Swap pivot row to current rank position
        A[rank], A[pivot_row] = A[pivot_row], A[rank]

        # Compute modular inverse of pivot using Fermat's little theorem
        inv = pow(A[rank][col], p - 2, p)

        # Eliminate all other rows
        for row in range(n):
            if row != rank and A[row][col] % p != 0:
                factor = (A[row][col] * inv) % p
                for c in range(m):
                    A[row][c] = (A[row][c] - factor * A[rank][c]) % p

        rank += 1

    return rank


def spectral_fingerprint(M: List[List[int]], primes: List[int]) -> Dict[int, int]:
    """
    Compute the spectral fingerprint of an integer matrix.

    The spectral fingerprint maps each prime p to rank(M mod p).

    Time: O(|primes| * n^3)
    Space: O(n^2)

    Args:
        M: Square integer matrix
        primes: List of primes to evaluate

    Returns:
        Dictionary mapping p -> rank(M mod p)

    >>> M = [[6, 2], [4, 10]]
    >>> fp = spectral_fingerprint(M, [2, 3, 5, 7, 13, 26])
    >>> fp[2]  # det = 52 = 4 * 13, so rank drops at p=2 and p=13
    1
    """
    return {p: mod_p_gaussian_elimination(M, p) for p in primes}


def detect_bad_primes(M: List[List[int]], prime_bound: int) -> List[int]:
    """
    Detect all primes up to prime_bound where the rank drops.

    By the rank stability theorem, these are exactly the primes
    dividing det(M) (when det(M) != 0).

    Time: O(prime_bound * n^3 / log(prime_bound))
    Space: O(n^2 + prime_bound)

    Args:
        M: Square integer matrix with nonzero determinant
        prime_bound: Search for bad primes up to this bound

    Returns:
        List of bad primes (primes where rank drops below n)

    >>> detect_bad_primes([[6, 1], [0, 10]], 50)
    [2, 3, 5]
    """
    n = len(M)
    primes = sieve_primes(prime_bound)
    return [p for p in primes if mod_p_gaussian_elimination(M, p) < n]


def determinant_mod_p(M: List[List[int]], p: int) -> int:
    """
    Compute det(M) mod p via Gaussian elimination.

    Time: O(n^3)
    Space: O(n^2)

    Args:
        M: Square integer matrix
        p: Prime modulus

    Returns:
        det(M) mod p
    """
    n = len(M)
    A = [[M[i][j] % p for j in range(n)] for i in range(n)]
    det = 1
    sign = 1

    for col in range(n):
        pivot_row = None
        for row in range(col, n):
            if A[row][col] % p != 0:
                pivot_row = row
                break
        if pivot_row is None:
            return 0

        if pivot_row != col:
            A[col], A[pivot_row] = A[pivot_row], A[col]
            sign *= -1

        det = (det * A[col][col]) % p
        inv = pow(A[col][col], p - 2, p)

        for row in range(col + 1, n):
            if A[row][col] % p != 0:
                factor = (A[row][col] * inv) % p
                for c in range(n):
                    A[row][c] = (A[row][c] - factor * A[col][c]) % p

    return (sign * det) % p


def complete_graph_laplacian(n: int) -> List[List[int]]:
    """
    Construct the Laplacian of the complete graph K_n.

    L = nI - J where J is the all-ones matrix.

    Time: O(n^2)
    Space: O(n^2)

    >>> complete_graph_laplacian(3)
    [[3, -1, -1], [-1, 3, -1], [-1, -1, 3]]
    """
    return [[(n if i == j else 0) - 1 for j in range(n)] for i in range(n)]


def path_graph_laplacian(n: int) -> List[List[int]]:
    """
    Construct the Laplacian of the path graph P_n.

    Time: O(n^2)
    Space: O(n^2)

    >>> path_graph_laplacian(4)
    [[1, -1, 0, 0], [-1, 2, -1, 0], [0, -1, 2, -1], [0, 0, -1, 1]]
    """
    L = [[0] * n for _ in range(n)]
    for i in range(n):
        if i == 0 or i == n - 1:
            L[i][i] = 1
        else:
            L[i][i] = 2
        if i > 0:
            L[i][i-1] = -1
        if i < n - 1:
            L[i][i+1] = -1
    return L


def cycle_graph_laplacian(n: int) -> List[List[int]]:
    """
    Construct the Laplacian of the cycle graph C_n.

    Time: O(n^2)
    Space: O(n^2)

    >>> cycle_graph_laplacian(4)
    [[2, -1, 0, -1], [-1, 2, -1, 0], [0, -1, 2, -1], [-1, 0, -1, 2]]
    """
    L = [[0] * n for _ in range(n)]
    for i in range(n):
        L[i][i] = 2
        L[i][(i+1) % n] = -1
        L[(i+1) % n][i] = -1
    return L


def edge_boundary(L: List[List[int]], S: List[int]) -> int:
    """
    Compute the edge boundary of subset S in graph with Laplacian L.

    The edge boundary is ∑_{i∈S, j∈Sᶜ} (-L_{ij}).

    Time: O(|S| * n)
    Space: O(n)

    Args:
        L: Laplacian matrix (symmetric, zero row sums, nonpos off-diagonal)
        S: Subset of vertices

    Returns:
        Total weight of edges crossing from S to its complement (always >= 0)

    >>> L = path_graph_laplacian(5)
    >>> edge_boundary(L, [0, 1])
    1
    """
    n = len(L)
    S_set = set(S)
    Sc = [j for j in range(n) if j not in S_set]
    return sum(-L[i][j] for i in S for j in Sc)


def expansion_ratio(L: List[List[int]], S: List[int]) -> float:
    """
    Compute the edge expansion ratio h(S) = |∂S| / |S|.

    Args:
        L: Laplacian matrix
        S: Nonempty subset of vertices with |S| <= n/2

    Returns:
        Expansion ratio

    >>> L = complete_graph_laplacian(4)
    >>> expansion_ratio(L, [0])
    3.0
    """
    if not S:
        return 0.0
    return edge_boundary(L, S) / len(S)


def recover_det_magnitude_from_fingerprint(
    fp: Dict[int, int], n: int, prime_bound: int
) -> Tuple[List[int], int]:
    """
    Recover information about |det(M)| from the spectral fingerprint.

    The bad primes (where rank drops) are exactly the prime divisors of det(M).
    This gives partial information about the determinant.

    Args:
        fp: Spectral fingerprint (p -> rank)
        n: Matrix dimension
        prime_bound: Maximum prime checked

    Returns:
        Tuple of (bad_primes, lower_bound_on_det) where lower_bound is
        the product of all detected bad primes

    >>> M = [[6, 1], [0, 10]]  # det = 60 = 2^2 * 3 * 5
    >>> fp = spectral_fingerprint(M, sieve_primes(20))
    >>> bad, lb = recover_det_magnitude_from_fingerprint(fp, 2, 20)
    >>> sorted(bad)
    [2, 3, 5]
    """
    bad_primes = [p for p, r in fp.items() if r < n]
    lower_bound = 1
    for p in bad_primes:
        lower_bound *= p
    return bad_primes, lower_bound


if __name__ == "__main__":
    import doctest
    doctest.testmod(verbose=True)
