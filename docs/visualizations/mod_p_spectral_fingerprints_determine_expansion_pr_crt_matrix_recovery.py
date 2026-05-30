"""
Algorithms for Mod-p Spectral Fingerprinting

Implements the core algorithms from the research paper:
1. CRT-based matrix recovery from mod-p data
2. Spectral gap computation
3. Prime selection for fingerprinting
4. Fingerprint comparison and matching

All algorithms include docstrings, type hints, complexity analysis,
and example usage.
"""

import numpy as np
from math import factorial, log, ceil
from typing import List, Tuple, Optional
from functools import reduce


def extended_gcd(a: int, b: int) -> Tuple[int, int, int]:
    """Extended Euclidean algorithm.

    Returns (g, x, y) such that a*x + b*y = g = gcd(a, b).

    Time complexity: O(log(min(a,b)))
    Space complexity: O(log(min(a,b))) due to recursion

    >>> extended_gcd(35, 15)
    (5, 1, -2)
    """
    if a == 0:
        return b, 0, 1
    g, x, y = extended_gcd(b % a, a)
    return g, y - (b // a) * x, x


def crt_recover(residues: List[int], moduli: List[int]) -> int:
    """Chinese Remainder Theorem recovery.

    Given residues r_i and pairwise coprime moduli m_i,
    finds the unique x in [-M/2, M/2) such that x ≡ r_i (mod m_i)
    where M = ∏ m_i.

    Args:
        residues: List of residues [r_1, ..., r_k]
        moduli: List of pairwise coprime moduli [m_1, ..., m_k]

    Returns:
        The unique integer x in the symmetric range [-M/2, M/2)

    Time complexity: O(k · log(M)) where k = len(moduli), M = ∏ m_i
    Space complexity: O(k)

    >>> crt_recover([2, 3, 2], [3, 5, 7])
    23
    """
    M = reduce(lambda a, b: a * b, moduli, 1)
    x = 0
    for r, m in zip(residues, moduli):
        Mi = M // m
        _, inv, _ = extended_gcd(Mi, m)
        x = (x + r * Mi * inv) % M
    if x > M // 2:
        x -= M
    return x


def matrix_mod_p(matrix: np.ndarray, p: int) -> np.ndarray:
    """Reduce an integer matrix modulo p.

    Args:
        matrix: Integer matrix (numpy array)
        p: Prime modulus

    Returns:
        Matrix with entries reduced to [0, p-1]

    Time complexity: O(n²)
    Space complexity: O(n²)
    """
    return matrix % p


def recover_matrix_from_modp(
    mod_matrices: List[Tuple[int, np.ndarray]],
    shape: Tuple[int, int]
) -> np.ndarray:
    """Recover an integer matrix from its mod-p reductions via CRT.

    Args:
        mod_matrices: List of (prime, reduced_matrix) pairs
        shape: Shape of the original matrix (n, m)

    Returns:
        Recovered integer matrix

    Time complexity: O(n² · k · log(M)) where k = number of primes
    Space complexity: O(n² · k)

    Example:
        >>> L = np.array([[2, -1], [-1, 2]])
        >>> mods = [(3, L % 3), (5, L % 5), (7, L % 7)]
        >>> recover_matrix_from_modp(mods, (2, 2))
        array([[ 2, -1],
               [-1,  2]])
    """
    primes = [p for p, _ in mod_matrices]
    n, m = shape
    result = np.zeros(shape, dtype=int)

    for i in range(n):
        for j in range(m):
            residues = [int(mat[i, j]) for _, mat in mod_matrices]
            result[i, j] = crt_recover(residues, primes)

    return result


def hadamard_coefficient_bound(n: int, D: int) -> int:
    """Hadamard-type bound on characteristic polynomial coefficients.

    For an n×n integer matrix with entries bounded by D in absolute value,
    the coefficients of the characteristic polynomial are bounded by n! · D^n.

    Args:
        n: Matrix dimension
        D: Maximum absolute value of entries

    Returns:
        Upper bound B such that all char poly coefficients satisfy |c_k| ≤ B

    Time complexity: O(n)
    Space complexity: O(1)
    """
    return factorial(n) * (D ** n)


def select_primes_for_recovery(bound: int, max_prime: Optional[int] = None) -> List[int]:
    """Select a minimal set of primes whose product exceeds 2·bound.

    This implements the prime selection step of the fingerprint algorithm.
    Uses consecutive primes starting from 2.

    Args:
        bound: The coefficient bound B
        max_prime: Optional upper limit on primes to use

    Returns:
        List of primes whose product > 2·bound

    Time complexity: O(p_k · log(p_k)) where p_k is the largest prime used
    Space complexity: O(k) where k is the number of primes selected
    """
    from sympy import isprime as is_prime

    primes = []
    product = 1
    target = 2 * bound
    p = 2
    while product <= target:
        if max_prime is not None and p > max_prime:
            break
        if is_prime(p):
            primes.append(p)
            product *= p
        p += 1
    return primes


def compute_spectral_gap(laplacian: np.ndarray) -> float:
    """Compute the spectral gap of a graph Laplacian.

    The spectral gap is the smallest nonzero eigenvalue of the Laplacian.
    For connected graphs, this equals the algebraic connectivity (Fiedler value).

    Args:
        laplacian: Symmetric Laplacian matrix

    Returns:
        Smallest nonzero eigenvalue (0 if no nonzero eigenvalues)

    Time complexity: O(n³) for eigenvalue decomposition
    Space complexity: O(n²)
    """
    eigenvalues = np.sort(np.linalg.eigvalsh(laplacian))
    threshold = 1e-10
    nonzero = [ev for ev in eigenvalues if ev > threshold]
    return float(nonzero[0]) if nonzero else 0.0


def graph_laplacian(adjacency: np.ndarray) -> np.ndarray:
    """Compute the combinatorial Laplacian L = D - A.

    Args:
        adjacency: Symmetric 0-1 adjacency matrix

    Returns:
        Laplacian matrix L = D - A where D is the degree matrix

    Time complexity: O(n²)
    Space complexity: O(n²)
    """
    D = np.diag(adjacency.sum(axis=1))
    return D - adjacency


def spectral_fingerprint(
    laplacian: np.ndarray,
    primes: List[int]
) -> dict:
    """Compute the mod-p spectral fingerprint of a graph Laplacian.

    The fingerprint is the collection of mod-p matrix reductions.

    Args:
        laplacian: Integer Laplacian matrix
        primes: List of primes to use

    Returns:
        Dictionary mapping prime -> reduced matrix

    Time complexity: O(k · n²) where k = len(primes)
    Space complexity: O(k · n²)
    """
    return {p: matrix_mod_p(laplacian, p) for p in primes}


def fingerprints_agree(fp1: dict, fp2: dict) -> bool:
    """Check if two spectral fingerprints agree on all shared primes.

    Args:
        fp1, fp2: Fingerprint dictionaries (prime -> matrix)

    Returns:
        True if all shared primes give the same reduced matrix
    """
    shared_primes = set(fp1.keys()) & set(fp2.keys())
    return all(np.array_equal(fp1[p], fp2[p]) for p in shared_primes)


def estimate_primes_needed(n: int, max_degree: int) -> Tuple[int, List[int]]:
    """Estimate how many primes are needed for spectral gap recovery.

    For an n-vertex graph with maximum degree D, the Laplacian entries
    are bounded by D, so the Hadamard bound gives B = n! · D^n.

    Args:
        n: Number of vertices
        max_degree: Maximum vertex degree

    Returns:
        Tuple of (number of primes needed, list of primes)
    """
    B = hadamard_coefficient_bound(n, max_degree)
    primes = select_primes_for_recovery(B)
    return len(primes), primes


# ============================================================
# Example Usage
# ============================================================
if __name__ == "__main__":
    print("Spectral Fingerprint Algorithm Demo")
    print("=" * 50)

    # Create a graph
    adj = np.array([
        [0, 1, 1, 0, 1],
        [1, 0, 1, 1, 0],
        [1, 1, 0, 1, 0],
        [0, 1, 1, 0, 1],
        [1, 0, 0, 1, 0],
    ], dtype=int)

    L = graph_laplacian(adj)
    n = L.shape[0]
    max_entry = int(np.max(np.abs(L)))

    print(f"\nGraph: {n} vertices, max degree {max_entry}")
    print(f"Laplacian:\n{L}")

    # Compute spectral gap
    gap = compute_spectral_gap(L)
    print(f"\nSpectral gap: {gap:.6f}")

    # Find sufficient primes
    num_primes, primes = estimate_primes_needed(n, max_entry)
    print(f"\nPrimes needed for exact recovery: {num_primes}")
    print(f"Primes: {primes}")

    # Compute fingerprint
    fp = spectral_fingerprint(L, primes)
    print(f"\nFingerprint computed for {len(fp)} primes")

    # Recover via CRT
    mod_data = [(p, fp[p]) for p in primes]
    L_recovered = recover_matrix_from_modp(mod_data, L.shape)
    print(f"\nRecovered Laplacian matches: {np.array_equal(L, L_recovered)}")

    # Verify spectral gap
    gap_recovered = compute_spectral_gap(L_recovered.astype(float))
    print(f"Recovered spectral gap: {gap_recovered:.6f}")
    print(f"Gap recovery error: {abs(gap - gap_recovered):.2e}")
