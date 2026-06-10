#!/usr/bin/env python3
"""
Algorithms for spectral arithmetic.

Implements the core algorithms underlying the spectral multiplicativity theorem:
1. Kronecker-structured eigenvalue computation (exploiting factorization)
2. Prime-power spectral decomposition
3. Spectral reconstruction from local factors

These algorithms exploit the tensor structure to achieve exponential speedups
over naive eigenvalue computation on the full Kronecker product.
"""

import numpy as np
from numpy.linalg import eig, eigvalsh
from typing import Dict, List, Tuple, Optional
from sympy import factorint
from itertools import product as iterproduct
import time


def kronecker_eigenvalues_fast(
    matrices: List[np.ndarray],
) -> np.ndarray:
    """
    Compute eigenvalues of the Kronecker product ⊗_i A_i
    WITHOUT forming the full Kronecker product.

    Instead of computing eigenvalues of the n₁·n₂·...·nₖ dimensional
    Kronecker product, we compute eigenvalues of each factor (O(n_i³))
    and form all products.

    Time complexity: O(∑ n_i³ + ∏ n_i)  vs  O((∏ n_i)³) for naive.
    Space complexity: O(∑ n_i² + ∏ n_i)  vs  O((∏ n_i)²) for naive.

    Parameters
    ----------
    matrices : list of ndarray
        List of square matrices [A₁, A₂, ..., Aₖ].

    Returns
    -------
    ndarray
        Sorted eigenvalues of ⊗_i A_i.
    """
    local_eigenvalues = [np.linalg.eigvals(M) for M in matrices]
    product_eigenvalues = np.array([
        np.prod(combo) for combo in iterproduct(*local_eigenvalues)
    ])
    return np.sort(product_eigenvalues)


def kronecker_eigenpairs_fast(
    matrices: List[np.ndarray],
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Compute eigenvalues AND eigenvectors of ⊗_i A_i via tensor factoring.

    Each eigenvector of the Kronecker product is the Kronecker product
    of the individual eigenvectors.

    Parameters
    ----------
    matrices : list of ndarray
        List of square matrices.

    Returns
    -------
    eigenvalues : ndarray
        Array of eigenvalues.
    eigenvectors : ndarray
        Matrix whose columns are eigenvectors (in Kronecker product space).
    """
    local_pairs = [eig(M) for M in matrices]
    local_vals = [vals for vals, _ in local_pairs]
    local_vecs = [vecs for _, vecs in local_pairs]

    dims = [M.shape[0] for M in matrices]
    total_dim = int(np.prod(dims))
    n_factors = len(matrices)

    # Generate all index combinations
    index_ranges = [range(d) for d in dims]
    all_indices = list(iterproduct(*index_ranges))

    eigenvalues = np.zeros(total_dim, dtype=complex)
    eigenvectors = np.zeros((total_dim, total_dim), dtype=complex)

    for idx, combo in enumerate(all_indices):
        # Eigenvalue is product
        eigenvalues[idx] = np.prod([local_vals[k][combo[k]] for k in range(n_factors)])
        # Eigenvector is Kronecker product
        vec = local_vecs[0][:, combo[0]]
        for k in range(1, n_factors):
            vec = np.kron(vec, local_vecs[k][:, combo[k]])
        eigenvectors[:, idx] = vec

    return eigenvalues, eigenvectors


def arithmetic_spectral_decomposition(
    T: Dict[int, np.ndarray],
    n: int,
) -> Dict[str, object]:
    """
    Given an arithmetic operator family T indexed by prime powers,
    compute the spectral decomposition of T(n) via prime factorization.

    Parameters
    ----------
    T : dict mapping int -> ndarray
        Maps prime powers p^a to their matrix representations.
    n : int
        The index whose spectral decomposition is desired.

    Returns
    -------
    dict with keys:
        'factorization': prime factorization of n
        'prime_powers': list of p^a values
        'local_eigenvalues': eigenvalues of each T(p^a)
        'global_eigenvalues': eigenvalues of T(n) = ⊗ T(p^a)
        'speedup': ratio of naive to fast computation cost
    """
    factors = factorint(n)
    prime_powers = [p ** a for p, a in factors.items()]

    # Get the matrices for each prime power
    matrices = []
    for pp in prime_powers:
        if pp not in T:
            raise ValueError(f"T({pp}) not provided")
        matrices.append(T[pp])

    local_eigenvalues = {pp: np.linalg.eigvals(T[pp]) for pp in prime_powers}
    global_eigenvalues = kronecker_eigenvalues_fast(matrices)

    # Compute speedup
    dims = [M.shape[0] for M in matrices]
    naive_cost = int(np.prod(dims)) ** 3
    fast_cost = sum(d ** 3 for d in dims) + int(np.prod(dims))

    return {
        'factorization': factors,
        'prime_powers': prime_powers,
        'local_eigenvalues': local_eigenvalues,
        'global_eigenvalues': global_eigenvalues,
        'total_dimension': int(np.prod(dims)),
        'speedup': naive_cost / max(fast_cost, 1),
    }


def benchmark_speedup(dims: List[int], num_trials: int = 3) -> Dict[str, float]:
    """
    Benchmark the speedup of factored eigenvalue computation vs naive.

    Parameters
    ----------
    dims : list of int
        Dimensions of each factor matrix.
    num_trials : int
        Number of trials for timing.

    Returns
    -------
    dict with timing results.
    """
    matrices = [np.random.randn(d, d) + 1j * np.random.randn(d, d) for d in dims]

    # Naive: form full Kronecker product and compute eigenvalues
    total_dim = int(np.prod(dims))
    if total_dim <= 500:
        full = matrices[0]
        for M in matrices[1:]:
            full = np.kron(full, M)
        t0 = time.perf_counter()
        for _ in range(num_trials):
            np.linalg.eigvals(full)
        naive_time = (time.perf_counter() - t0) / num_trials
    else:
        naive_time = float('inf')

    # Fast: factor
    t0 = time.perf_counter()
    for _ in range(num_trials):
        kronecker_eigenvalues_fast(matrices)
    fast_time = (time.perf_counter() - t0) / num_trials

    return {
        'dims': dims,
        'total_dim': total_dim,
        'naive_time': naive_time,
        'fast_time': fast_time,
        'speedup': naive_time / max(fast_time, 1e-10),
    }


if __name__ == "__main__":
    print("=" * 70)
    print("ALGORITHM BENCHMARKS: Spectral Arithmetic")
    print("=" * 70)

    # Test correctness
    print("\n--- Correctness Test ---")
    matrices = [
        np.array([[1, 2], [3, 4]], dtype=complex),
        np.array([[5, 6], [7, 8]], dtype=complex),
        np.array([[1, 0], [0, 2]], dtype=complex),
    ]
    fast_eigs = kronecker_eigenvalues_fast(matrices)
    full = matrices[0]
    for M in matrices[1:]:
        full = np.kron(full, M)
    naive_eigs = np.sort(np.linalg.eigvals(full))
    print(f"  Fast eigenvalues:  {fast_eigs}")
    print(f"  Naive eigenvalues: {naive_eigs}")
    print(f"  Match: {np.allclose(fast_eigs, naive_eigs)}")

    # Benchmark
    print("\n--- Speedup Benchmarks ---")
    test_cases = [
        [4, 4],
        [4, 4, 4],
        [8, 8],
        [8, 8, 8],
        [4, 4, 4, 4],
    ]
    for dims in test_cases:
        result = benchmark_speedup(dims)
        print(f"  dims={dims}, total={result['total_dim']}: "
              f"naive={result['naive_time']:.4f}s, "
              f"fast={result['fast_time']:.6f}s, "
              f"speedup={result['speedup']:.1f}x")

    # Arithmetic decomposition example
    print("\n--- Arithmetic Spectral Decomposition ---")
    T = {
        4: np.array([[1, 2], [0, 3]], dtype=complex),
        3: np.array([[2, 1], [1, 2]], dtype=complex),
        5: np.array([[1, 0, 1], [0, 2, 0], [1, 0, 3]], dtype=complex),
    }
    result = arithmetic_spectral_decomposition(T, 60)  # 60 = 2^2 * 3 * 5
    print(f"  n = 60 = {result['factorization']}")
    print(f"  Total dimension: {result['total_dimension']}")
    for pp, ev in result['local_eigenvalues'].items():
        print(f"  T({pp}) eigenvalues: {np.sort(ev)}")
    print(f"  T(60) eigenvalues: {result['global_eigenvalues']}")
    print(f"  Speedup: {result['speedup']:.1f}x")
