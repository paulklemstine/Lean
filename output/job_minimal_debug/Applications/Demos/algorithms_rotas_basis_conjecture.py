"""
Algorithms for Rota's Basis Conjecture

Implements the greedy deficiency-reduction algorithm and related utilities
for finding valid basis arrangements.
"""

from typing import List, Tuple, Optional
import numpy as np
from itertools import permutations


def compute_rank(vectors: np.ndarray) -> int:
    """Compute the rank of a matrix (set of row vectors).

    Args:
        vectors: An m x n numpy array where each row is a vector.

    Returns:
        The rank of the matrix.
    """
    return int(np.linalg.matrix_rank(vectors, tol=1e-10))


def independence_deficiency(vectors: np.ndarray, n: int) -> int:
    """Compute the independence deficiency: n minus the rank.

    Args:
        vectors: An m x n numpy array of vectors.
        n: The ambient dimension.

    Returns:
        n - rank(vectors). Zero means the vectors span the full space.
    """
    return n - compute_rank(vectors)


def build_column(bases: List[np.ndarray], perms: List[List[int]], col: int) -> np.ndarray:
    """Extract column j from the arrangement grid.

    Args:
        bases: List of n bases, each an n x n array.
        perms: List of n permutations (as lists of indices).
        col: Column index.

    Returns:
        An n x n array where row i is bases[i][perms[i][col]].
    """
    n = len(bases)
    return np.array([bases[i][perms[i][col]] for i in range(n)])


def total_deficiency(bases: List[np.ndarray], perms: List[List[int]]) -> int:
    """Compute the total deficiency across all columns.

    Args:
        bases: List of n bases, each an n x n array.
        perms: List of n permutations (as lists of indices).

    Returns:
        Sum of independence deficiencies across all columns.
    """
    n = len(bases)
    return sum(
        independence_deficiency(build_column(bases, perms, j), n)
        for j in range(n)
    )


def greedy_rota_solve(bases: List[np.ndarray], max_iter: int = 10000) -> Optional[List[List[int]]]:
    """Greedy algorithm for finding a valid Rota arrangement.

    Starts with identity permutations and repeatedly applies deficiency-reducing
    swaps until total deficiency reaches zero.

    Args:
        bases: List of n bases, each an n x n array.
        max_iter: Maximum number of swap iterations.

    Returns:
        List of permutations if successful, None if stuck.
    """
    n = len(bases)
    perms = [list(range(n)) for _ in range(n)]

    for iteration in range(max_iter):
        current_def = total_deficiency(bases, perms)
        if current_def == 0:
            return perms

        improved = False
        for i in range(n):
            for a in range(n):
                for b in range(a + 1, n):
                    # Try swapping positions a and b in row i
                    perms[i][a], perms[i][b] = perms[i][b], perms[i][a]
                    new_def = total_deficiency(bases, perms)
                    if new_def < current_def:
                        improved = True
                        break
                    else:
                        # Undo swap
                        perms[i][a], perms[i][b] = perms[i][b], perms[i][a]
                if improved:
                    break
            if improved:
                break

        if not improved:
            return None  # Greedy stuck — potential counterexample!

    return None


def brute_force_rota(bases: List[np.ndarray]) -> Optional[List[Tuple[int, ...]]]:
    """Brute force search for a valid Rota arrangement.

    Tries all possible permutation combinations. Only feasible for small n.

    Args:
        bases: List of n bases, each an n x n array.

    Returns:
        List of permutation tuples if found, None otherwise.
    """
    n = len(bases)
    all_perms = list(permutations(range(n)))

    # Fix first permutation to identity (WLOG)
    for combo in _perm_combos(all_perms, n - 1):
        perms_list = [list(range(n))] + [list(p) for p in combo]
        if total_deficiency(bases, perms_list) == 0:
            return [tuple(p) for p in perms_list]

    return None


def _perm_combos(all_perms: list, k: int):
    """Generate all k-tuples of permutations."""
    if k == 0:
        yield ()
        return
    for p in all_perms:
        for rest in _perm_combos(all_perms, k - 1):
            yield (p,) + rest


def random_basis(n: int, rng: Optional[np.random.Generator] = None) -> np.ndarray:
    """Generate a random basis of R^n.

    Args:
        n: Dimension.
        rng: Random number generator (optional).

    Returns:
        An n x n invertible matrix (each row is a basis vector).
    """
    if rng is None:
        rng = np.random.default_rng()

    while True:
        M = rng.standard_normal((n, n))
        if abs(np.linalg.det(M)) > 1e-6:
            return M


def verify_arrangement(bases: List[np.ndarray], perms: List[List[int]]) -> bool:
    """Verify that an arrangement satisfies Rota's property.

    Args:
        bases: List of n bases, each an n x n array.
        perms: List of n permutations.

    Returns:
        True if every column is linearly independent.
    """
    n = len(bases)
    for j in range(n):
        col = build_column(bases, perms, j)
        if compute_rank(col) < n:
            return False
    return True


def count_valid_arrangements(bases: List[np.ndarray]) -> Tuple[int, int]:
    """Count valid Rota arrangements (brute force).

    Args:
        bases: List of n bases.

    Returns:
        (count of valid arrangements, total arrangements checked)
    """
    n = len(bases)
    all_perms = list(permutations(range(n)))
    valid = 0
    total = 0

    for combo in _perm_combos(all_perms, n):
        perms_list = [list(p) for p in combo]
        total += 1
        if total_deficiency(bases, perms_list) == 0:
            valid += 1

    return valid, total
