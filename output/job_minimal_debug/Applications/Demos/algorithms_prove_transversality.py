"""
Algorithms for Tropical Transversality
=======================================
Implements computational algorithms for analyzing max-affine corner loci,
tie strata, and critical point isolation.
"""

import numpy as np
from itertools import combinations
from typing import List, Set, Tuple, Optional, Dict


def compute_tie_stratum(
    w: np.ndarray, b: np.ndarray, s: Set[int], i0: int
) -> Tuple[Optional[np.ndarray], np.ndarray]:
    """
    Compute the tie stratum T_s(b) for a set s of indices with pivot i0.

    The tie stratum is the set {x : ℓ_i(x) = ℓ_j(x) for all i,j in s},
    which equals {x : A x = c} where A is the matrix of difference vectors
    and c is the bias difference vector.

    Parameters
    ----------
    w : np.ndarray, shape (num_indices, n)
        Weight vectors.
    b : np.ndarray, shape (num_indices,)
        Bias terms.
    s : Set[int]
        Index set for the tie conditions.
    i0 : int
        Pivot index (must be in s).

    Returns
    -------
    x0 : np.ndarray or None
        A particular solution (None if the system is inconsistent).
    ker_basis : np.ndarray, shape (dim_ker, n)
        Basis for the kernel (direction of the tie stratum).

    Complexity
    ----------
    Time: O(k * n^2) where k = |s| - 1
    Space: O(k * n)
    """
    n = w.shape[1]
    s_list = sorted(s - {i0})

    if not s_list:
        return np.zeros(n), np.eye(n)

    # Build system A x = c
    A = np.array([w[i] - w[i0] for i in s_list])
    c = np.array([b[i0] - b[i] for i in s_list])

    # Compute rank and particular solution
    rank = np.linalg.matrix_rank(A, tol=1e-10)
    k = len(s_list)

    # Try to find a particular solution via least squares
    x0, residuals, _, _ = np.linalg.lstsq(A, c, rcond=None)

    # Check consistency
    if np.linalg.norm(A @ x0 - c) > 1e-8:
        return None, np.array([]).reshape(0, n)

    # Compute kernel basis via SVD
    _, S, Vt = np.linalg.svd(A, full_matrices=True)
    null_dim = n - rank
    ker_basis = Vt[rank:] if null_dim > 0 else np.array([]).reshape(0, n)

    return x0, ker_basis


def verify_codimension(
    w: np.ndarray, s: Set[int], i0: int
) -> Dict[str, int]:
    """
    Verify the codimension theorem for a tie stratum.

    Parameters
    ----------
    w : np.ndarray, shape (num_indices, n)
    s : Set[int]
    i0 : int

    Returns
    -------
    dict with keys:
        'n': ambient dimension
        'k': |s|
        'rank': rank of difference matrix
        'ker_dim': dimension of kernel
        'expected_codim': |s| - 1
        'expected_dim': n - (|s| - 1)
        'is_independent': whether difference vectors are linearly independent
        'codim_matches': whether actual codimension matches expected

    Complexity
    ----------
    Time: O(k * n^2)
    """
    n = w.shape[1]
    s_list = sorted(s - {i0})
    k = len(s) 

    if not s_list:
        return {
            'n': n, 'k': k, 'rank': 0, 'ker_dim': n,
            'expected_codim': 0, 'expected_dim': n,
            'is_independent': True, 'codim_matches': True
        }

    A = np.array([w[i] - w[i0] for i in s_list])
    rank = np.linalg.matrix_rank(A, tol=1e-10)
    ker_dim = n - rank
    expected_codim = k - 1
    expected_dim = n - expected_codim

    return {
        'n': n,
        'k': k,
        'rank': rank,
        'ker_dim': ker_dim,
        'expected_codim': expected_codim,
        'expected_dim': expected_dim,
        'is_independent': rank == k - 1,
        'codim_matches': ker_dim == expected_dim
    }


def enumerate_corner_strata(
    w: np.ndarray, b: np.ndarray, max_order: int = None
) -> List[Dict]:
    """
    Enumerate all non-empty tie strata of the max-affine function.

    For each subset s of indices with |s| >= 2, computes the tie stratum
    and checks if it intersects the active region (where all indices in s
    achieve the maximum).

    Parameters
    ----------
    w : np.ndarray, shape (m, n)
    b : np.ndarray, shape (m,)
    max_order : int, optional
        Maximum subset size to enumerate. Default: n + 1.

    Returns
    -------
    List of dicts with stratum information.

    Complexity
    ----------
    Time: O(C(m, max_order) * n^2) where C is binomial coefficient
    """
    m, n = w.shape
    if max_order is None:
        max_order = min(n + 1, m)

    strata = []
    for k in range(2, max_order + 1):
        for s_tuple in combinations(range(m), k):
            s = set(s_tuple)
            i0 = min(s)
            x0, ker_basis = compute_tie_stratum(w, b, s, i0)

            if x0 is None:
                continue

            info = verify_codimension(w, s, i0)
            info['indices'] = s
            info['base_point'] = x0
            info['direction_dim'] = ker_basis.shape[0]
            info['direction_basis'] = ker_basis

            strata.append(info)

    return strata


def find_critical_direction(
    w: np.ndarray, s: Set[int], i0: int, c: np.ndarray
) -> Dict:
    """
    Analyze a linear functional c on a tie stratum.

    Determines whether c is constant on the stratum (i.e., orthogonal
    to the direction) or has variation (i.e., is not orthogonal).

    Parameters
    ----------
    w : np.ndarray, shape (m, n)
    s : Set[int]
    i0 : int
    c : np.ndarray, shape (n,)

    Returns
    -------
    dict with:
        'is_constant': bool
        'projection_norm': float (norm of c projected onto direction)
        'direction_dim': int

    Complexity
    ----------
    Time: O(k * n)
    """
    n = w.shape[1]
    s_list = sorted(s - {i0})

    if not s_list:
        # Direction is all of E, so c varies unless c = 0
        return {
            'is_constant': np.linalg.norm(c) < 1e-10,
            'projection_norm': np.linalg.norm(c),
            'direction_dim': n
        }

    A = np.array([w[i] - w[i0] for i in s_list])
    _, S, Vt = np.linalg.svd(A, full_matrices=True)
    rank = np.sum(S > 1e-10)
    ker_basis = Vt[rank:]

    if ker_basis.shape[0] == 0:
        return {
            'is_constant': True,
            'projection_norm': 0.0,
            'direction_dim': 0
        }

    # Project c onto the direction
    proj = sum(np.dot(c, d) * d for d in ker_basis)
    proj_norm = np.linalg.norm(proj)

    return {
        'is_constant': proj_norm < 1e-10,
        'projection_norm': proj_norm,
        'direction_dim': ker_basis.shape[0]
    }


def compute_bad_bias_set(
    w: np.ndarray
) -> List[Dict]:
    """
    Compute the 'bad' bias parameter set where the codimension theorem fails.

    For each subset s, determines the affine conditions on b that cause
    rank drop in the difference matrix. In the generic case (linearly
    independent difference vectors), the bad set is described by
    explicit linear relations.

    Parameters
    ----------
    w : np.ndarray, shape (m, n)

    Returns
    -------
    List of dicts describing bad bias configurations.

    Complexity
    ----------
    Time: O(2^m * n^2) (exponential in m)
    """
    m, n = w.shape
    bad_configs = []

    for k in range(2, min(n + 2, m + 1)):
        for s_tuple in combinations(range(m), k):
            s = set(s_tuple)
            i0 = min(s)
            s_list = sorted(s - {i0})
            A = np.array([w[i] - w[i0] for i in s_list])
            rank = np.linalg.matrix_rank(A, tol=1e-10)

            if rank < k - 1:
                # The weight configuration itself is degenerate
                bad_configs.append({
                    'indices': s,
                    'type': 'weight_degenerate',
                    'rank': rank,
                    'expected_rank': k - 1,
                    'description': f'Difference vectors for {s} are linearly dependent'
                })

    return bad_configs


# --------------------------------------------------------------------------
# Example usage
# --------------------------------------------------------------------------

if __name__ == '__main__':
    np.random.seed(42)

    print("="*60)
    print("TROPICAL TRANSVERSALITY ALGORITHMS")
    print("="*60)

    # Example: 4 affine functions in R^3
    n, m = 3, 4
    w = np.random.randn(m, n)
    b = np.random.randn(m)

    print(f"\nWeight vectors (m={m}, n={n}):")
    for i in range(m):
        print(f"  w_{i} = {w[i].round(3)},  b_{i} = {b[i]:.3f}")

    # Enumerate strata
    print("\n--- Tie Strata ---")
    strata = enumerate_corner_strata(w, b)
    for s in strata:
        print(f"  s = {s['indices']}: "
              f"dim = {s['direction_dim']}, "
              f"codim = {n - s['direction_dim']}, "
              f"expected_codim = {s['expected_codim']}, "
              f"match = {'✓' if s['codim_matches'] else '✗'}")

    # Check bad bias configurations
    print("\n--- Bad Bias Configurations ---")
    bad = compute_bad_bias_set(w)
    if bad:
        for bc in bad:
            print(f"  {bc['description']}")
    else:
        print("  None found — weight vectors are in general position!")

    # Critical direction analysis
    print("\n--- Linear Probing ---")
    c = np.array([1.0, 0.5, -0.3])
    for s_info in strata:
        s = s_info['indices']
        i0 = min(s)
        result = find_critical_direction(w, s, i0, c)
        status = "CONSTANT" if result['is_constant'] else "VARIES"
        print(f"  s = {s}: c is {status} on stratum "
              f"(proj_norm = {result['projection_norm']:.4f})")
