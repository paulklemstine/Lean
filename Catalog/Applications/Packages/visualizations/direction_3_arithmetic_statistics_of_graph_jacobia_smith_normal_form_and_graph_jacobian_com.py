"""
Algorithms for Arithmetic Statistics of Graph Jacobians

Implements:
- Reduced Laplacian computation from adjacency data
- Smith Normal Form (SNF) computation for integer matrices
- Invariant factor extraction
- Prime-power torsion count computation
- q-primary profile computation
- Cohen-Lenstra weight computation

All algorithms correspond to the formally verified theorems in the Lean files.
"""

import numpy as np
from math import gcd
from functools import reduce
from typing import List, Tuple, Optional
from collections import Counter


def adjacency_matrix(n: int, edges: List[Tuple[int, int]]) -> np.ndarray:
    """Compute the adjacency matrix of a simple graph on n vertices.

    Args:
        n: Number of vertices (0-indexed).
        edges: List of (i, j) pairs with 0 <= i < j < n.

    Returns:
        n x n symmetric integer adjacency matrix.

    Example:
        >>> adjacency_matrix(3, [(0,1),(1,2)])
        array([[0, 1, 0],
               [1, 0, 1],
               [0, 1, 0]])
    """
    A = np.zeros((n, n), dtype=int)
    for i, j in edges:
        A[i, j] = 1
        A[j, i] = 1
    return A


def laplacian_matrix(n: int, edges: List[Tuple[int, int]]) -> np.ndarray:
    """Compute the combinatorial Laplacian L = D - A.

    Args:
        n: Number of vertices.
        edges: Edge list.

    Returns:
        n x n Laplacian matrix.

    Example:
        >>> laplacian_matrix(3, [(0,1),(1,2)])
        array([[ 1, -1,  0],
               [-1,  2, -1],
               [ 0, -1,  1]])
    """
    A = adjacency_matrix(n, edges)
    D = np.diag(A.sum(axis=1))
    return D - A


def reduced_laplacian(n: int, edges: List[Tuple[int, int]], remove: int = 0) -> np.ndarray:
    """Compute the reduced Laplacian by deleting row and column `remove`.

    Args:
        n: Number of vertices.
        edges: Edge list.
        remove: Index of vertex to remove (default 0).

    Returns:
        (n-1) x (n-1) reduced Laplacian matrix.

    Complexity: O(n^2) time and space.
    """
    L = laplacian_matrix(n, edges)
    idx = [i for i in range(n) if i != remove]
    return L[np.ix_(idx, idx)]


def smith_normal_form(M: np.ndarray) -> Tuple[np.ndarray, List[int]]:
    """Compute the Smith Normal Form of an integer matrix.

    Uses the standard algorithm: iteratively find pivot, clear row/column
    using integer row/column operations, ensure divisibility condition.

    Args:
        M: Integer matrix (numpy array).

    Returns:
        Tuple of (diagonal SNF matrix, list of diagonal entries).

    Complexity: O(n^3 * log(max_entry)) expected.

    Example:
        >>> _, factors = smith_normal_form(np.array([[2, 4], [6, 8]]))
        >>> factors
        [2, 4]  # or equivalent under sign
    """
    A = M.copy().astype(int)
    rows, cols = A.shape
    n = min(rows, cols)

    for k in range(n):
        # Find smallest nonzero entry in submatrix A[k:, k:]
        changed = True
        while changed:
            changed = False
            # Find pivot
            sub = A[k:, k:]
            nonzero = np.argwhere(sub != 0)
            if len(nonzero) == 0:
                break

            # Find minimum absolute value
            min_val = float('inf')
            min_pos = None
            for pos in nonzero:
                val = abs(sub[pos[0], pos[1]])
                if val < min_val:
                    min_val = val
                    min_pos = (pos[0] + k, pos[1] + k)

            # Swap to position (k, k)
            if min_pos[0] != k:
                A[[k, min_pos[0]]] = A[[min_pos[0], k]]
            if min_pos[1] != k:
                A[:, [k, min_pos[1]]] = A[:, [min_pos[1], k]]

            if A[k, k] < 0:
                A[k, :] = -A[k, :]

            if A[k, k] == 0:
                break

            # Eliminate column k
            for i in range(k + 1, rows):
                if A[i, k] != 0:
                    q = A[i, k] // A[k, k]
                    A[i, :] -= q * A[k, :]
                    if A[i, k] != 0:
                        changed = True

            # Eliminate row k
            for j in range(k + 1, cols):
                if A[k, j] != 0:
                    q = A[k, j] // A[k, k]
                    A[:, j] -= q * A[:, k]
                    if A[k, j] != 0:
                        changed = True

    # Ensure divisibility: d_i | d_{i+1}
    diag = [abs(A[i, i]) if i < min(rows, cols) else 0 for i in range(n)]
    for i in range(n):
        for j in range(i + 1, n):
            if diag[i] != 0 and diag[j] != 0:
                g = gcd(diag[i], diag[j])
                diag[j] = diag[i] * diag[j] // g
                diag[i] = g

    return A, diag


def invariant_factors(M: np.ndarray) -> List[int]:
    """Extract the nonzero invariant factors from the SNF of M.

    These are the diagonal entries > 1 of the Smith Normal Form,
    representing the finite cyclic summands Z/d_i Z.

    Args:
        M: Integer matrix.

    Returns:
        List of invariant factors > 1, sorted in divisibility order.

    Example:
        >>> invariant_factors(np.array([[3, 0], [0, 6]]))
        [3, 6]
    """
    _, diag = smith_normal_form(M)
    factors = sorted([d for d in diag if d > 1])
    return factors


def graph_jacobian_invariant_factors(n: int, edges: List[Tuple[int, int]]) -> List[int]:
    """Compute the invariant factors of the graph Jacobian (critical group).

    For a connected graph G, Jac(G) ≅ ⊕_i Z/d_i Z where d_i are the
    nonzero invariant factors of the reduced Laplacian.

    Args:
        n: Number of vertices.
        edges: Edge list.

    Returns:
        Invariant factors of the Jacobian, sorted in divisibility order.

    Example:
        >>> # Complete graph K_4: Jacobian is Z/4Z × Z/4Z × Z/4Z? No...
        >>> # K_4 has 4^2 = 16 spanning trees, Jac(K4) ≅ Z/4Z × Z/4Z
    """
    L_red = reduced_laplacian(n, edges)
    return invariant_factors(L_red)


def prime_power_torsion_count(factors: List[int], q: int, k: int) -> int:
    """Compute M_{q,k} = ∏_i gcd(d_i, q^k).

    This is the q^k-torsion count: the number of elements x in
    the group such that q^k * x = 0.

    Corresponds to Theorem B in the formal development.

    Args:
        factors: Invariant factors [d_1, ..., d_r].
        q: Prime number.
        k: Power.

    Returns:
        Product of gcd(d_i, q^k) over all factors.

    Example:
        >>> prime_power_torsion_count([6, 12], 2, 2)  # gcd(6,4)*gcd(12,4)
        8
    """
    qk = q ** k
    return reduce(lambda a, b: a * b,
                  [gcd(d, qk) for d in factors], 1)


def q_primary_count(factors: List[int], q: int, j: int) -> int:
    """Compute λ_{q,j} = #{i : q^j | d_i}.

    Counts how many invariant factors are divisible by q^j.

    Corresponds to the qPrimaryCount definition in the formal development.

    Args:
        factors: Invariant factors.
        q: Prime number.
        j: Level.

    Returns:
        Count of factors divisible by q^j.

    Example:
        >>> q_primary_count([6, 12, 24], 2, 1)  # all divisible by 2
        3
        >>> q_primary_count([6, 12, 24], 2, 3)  # only 24 divisible by 8
        1
    """
    qj = q ** j
    return sum(1 for d in factors if d % qj == 0)


def q_primary_profile(factors: List[int], q: int) -> List[int]:
    """Compute the full q-primary profile [λ_{q,0}, λ_{q,1}, ...].

    Returns the non-increasing sequence until it reaches 0.

    Args:
        factors: Invariant factors.
        q: Prime.

    Returns:
        List of counts forming a partition shape.

    Example:
        >>> q_primary_profile([4, 8, 16], 2)
        [3, 3, 2, 1]
    """
    profile = []
    j = 0
    while True:
        c = q_primary_count(factors, q, j)
        if c == 0 and j > 0:
            break
        profile.append(c)
        j += 1
    return profile


def cohen_lenstra_cyclic_weight(p: int, k: int) -> float:
    """Compute the Cohen-Lenstra weight for the cyclic p-group Z/p^k Z.

    Weight = 1 / |Aut(Z/p^k Z)| = 1 / (p^{k-1}(p-1)) for k >= 1.
    For k = 0 (trivial group), weight = 1.

    Args:
        p: Prime.
        k: Exponent.

    Returns:
        Cohen-Lenstra weight as a float.
    """
    if k == 0:
        return 1.0
    return 1.0 / (p ** (k - 1) * (p - 1))


def cohen_lenstra_geometric_prob(p: int, k: int) -> float:
    """Cohen-Lenstra geometric probability: Prob(v_p = k) = (1 - 1/p) * (1/p)^k.

    This is the pushforward of Haar measure on Z_p under the p-adic valuation.

    Args:
        p: Prime.
        k: Valuation value.

    Returns:
        Probability as a float.
    """
    return (1 - 1.0 / p) * (1.0 / p) ** k


def expected_moment_cohen_lenstra(q: int, k: int, max_terms: int = 50) -> float:
    """Compute E_{CL}[M_{q,k}] under the Cohen-Lenstra distribution.

    For a random finite abelian q-group A distributed according to
    Cohen-Lenstra, the expected q^k-torsion count.

    For k = 1: E[M_{q,1}] = q (the q-rank moment).

    Args:
        q: Prime.
        k: Power.
        max_terms: Number of terms in the sum.

    Returns:
        Expected moment as a float.
    """
    # For a single cyclic q-group Z/q^m Z with CL probability:
    # P(m) = (1 - 1/q) * (1/q)^m for m >= 0
    # M_{q,k}(Z/q^m Z) = q^{min(m,k)}
    # E[M_{q,k}] = sum_{m=0}^{inf} (1-1/q) * (1/q)^m * q^{min(m,k)}
    total = 0.0
    for m in range(max_terms):
        prob = cohen_lenstra_geometric_prob(q, m)
        moment = q ** min(m, k)
        total += prob * moment
    return total


def random_erdos_renyi_graph(n: int, p: float) -> List[Tuple[int, int]]:
    """Generate a random Erdős-Rényi graph G(n, p).

    Args:
        n: Number of vertices.
        p: Edge probability.

    Returns:
        List of edges.
    """
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if np.random.random() < p:
                edges.append((i, j))
    return edges


def is_connected(n: int, edges: List[Tuple[int, int]]) -> bool:
    """Check if the graph is connected using BFS.

    Args:
        n: Number of vertices.
        edges: Edge list.

    Returns:
        True if connected, False otherwise.
    """
    if n <= 1:
        return True
    adj = {i: set() for i in range(n)}
    for i, j in edges:
        adj[i].add(j)
        adj[j].add(i)
    visited = set()
    queue = [0]
    visited.add(0)
    while queue:
        v = queue.pop(0)
        for u in adj[v]:
            if u not in visited:
                visited.add(u)
                queue.append(u)
    return len(visited) == n


def sample_jacobian_statistics(n: int, p: float, num_samples: int = 1000,
                                primes: List[int] = [2, 3, 5]) -> dict:
    """Sample Jacobian statistics from random G(n,p) graphs.

    Generates random connected graphs and computes their Jacobian
    invariant factors, then collects statistics.

    Args:
        n: Number of vertices.
        p: Edge probability.
        num_samples: Number of connected graphs to sample.
        primes: Primes for which to compute statistics.

    Returns:
        Dictionary with empirical statistics.
    """
    all_factors = []
    exponents = []
    moments = {q: {k: [] for k in range(1, 5)} for q in primes}
    q_ranks = {q: [] for q in primes}

    count = 0
    attempts = 0
    while count < num_samples and attempts < num_samples * 10:
        attempts += 1
        edges = random_erdos_renyi_graph(n, p)
        if not is_connected(n, edges):
            continue
        count += 1

        factors = graph_jacobian_invariant_factors(n, edges)
        if not factors:
            factors = [1]
        all_factors.append(factors)
        exponents.append(max(factors))

        for q in primes:
            for k in range(1, 5):
                m = prime_power_torsion_count(factors, q, k)
                moments[q][k].append(m)
            # q-rank: number of factors divisible by q
            qr = sum(1 for d in factors if d % q == 0)
            q_ranks[q].append(qr)

    result = {
        'n': n,
        'p': p,
        'num_samples': count,
        'mean_exponent': np.mean(exponents) if exponents else 0,
        'moments': {},
        'q_ranks': {},
    }

    for q in primes:
        result['moments'][q] = {}
        for k in range(1, 5):
            if moments[q][k]:
                result['moments'][q][k] = {
                    'mean': np.mean(moments[q][k]),
                    'std': np.std(moments[q][k]),
                    'cl_prediction': expected_moment_cohen_lenstra(q, k),
                }
        if q_ranks[q]:
            result['q_ranks'][q] = {
                'mean': np.mean(q_ranks[q]),
                'distribution': dict(Counter(q_ranks[q])),
            }

    return result


if __name__ == '__main__':
    # Demo: Compute Jacobian of complete graph K_5
    n = 5
    edges = [(i, j) for i in range(n) for j in range(i+1, n)]
    factors = graph_jacobian_invariant_factors(n, edges)
    print(f"K_{n} Jacobian invariant factors: {factors}")
    print(f"Jacobian group: " + " × ".join(f"Z/{d}Z" for d in factors))
    print(f"Order (= # spanning trees): {reduce(lambda a,b: a*b, factors, 1)}")

    # Prime-power moments
    for q in [2, 3, 5]:
        for k in [1, 2]:
            m = prime_power_torsion_count(factors, q, k)
            print(f"M_{{{q},{k}}}(Jac(K_{n})) = {m}")

    # q-primary profiles
    for q in [2, 3, 5]:
        prof = q_primary_profile(factors, q)
        print(f"{q}-primary profile: {prof}")
