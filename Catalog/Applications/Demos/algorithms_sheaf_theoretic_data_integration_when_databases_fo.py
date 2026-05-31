"""
Sheaf-Theoretic Data Integration: Algorithms

Type-hinted implementations of core algorithms for sheaf-based database
consistency checking and imputation.
"""

from typing import Optional, Dict, Tuple, List, Set
import numpy as np


# Type aliases
Position = Tuple[int, int]
Value = float
PartialDB = Dict[Position, Optional[Value]]


def consistency_check(db1: PartialDB, db2: PartialDB) -> bool:
    """Check if two partial databases are consistent (agree on overlap).

    Two partial databases are consistent if for every position where both
    have defined values, those values are equal. This is the discrete
    sheaf overlap condition.

    Args:
        db1: First partial database
        db2: Second partial database

    Returns:
        True if the databases are consistent
    """
    for pos in set(db1.keys()) & set(db2.keys()):
        v1 = db1[pos]
        v2 = db2[pos]
        if v1 is not None and v2 is not None and v1 != v2:
            return False
    return True


def sheaf_condition(dbs: List[PartialDB]) -> bool:
    """Check if a family of partial databases satisfies the sheaf condition.

    The sheaf condition requires pairwise consistency: every pair of
    partial databases must agree on their overlap.

    Args:
        dbs: List of partial databases

    Returns:
        True if all pairs are consistent
    """
    for i in range(len(dbs)):
        for j in range(i + 1, len(dbs)):
            if not consistency_check(dbs[i], dbs[j]):
                return False
    return True


def gluing_map(db1: PartialDB, db2: PartialDB) -> PartialDB:
    """Glue two partial databases, preferring db1 where both are defined.

    When the databases are consistent, the choice of preference doesn't
    matter. The result extends both databases.

    Args:
        db1: First partial database (preferred)
        db2: Second partial database

    Returns:
        The glued partial database
    """
    result: PartialDB = dict(db1)
    for pos, val in db2.items():
        if pos not in result or result[pos] is None:
            result[pos] = val
    return result


def coboundary_norm(dbs: List[PartialDB], n_rows: int, n_cols: int) -> int:
    """Compute the coboundary norm: total disagreements across all pairs.

    This is the discrete Čech coboundary operator norm. Zero coboundary
    norm is equivalent to the sheaf condition.

    Args:
        dbs: Family of partial databases
        n_rows: Number of rows
        n_cols: Number of columns

    Returns:
        Total number of disagreements
    """
    total = 0
    for i in range(len(dbs)):
        for j in range(len(dbs)):
            for r in range(n_rows):
                for c in range(n_cols):
                    pos = (r, c)
                    v1 = dbs[i].get(pos)
                    v2 = dbs[j].get(pos)
                    if v1 is not None and v2 is not None and v1 != v2:
                        total += 1
    return total


def consistency_probability(r: float, constraint_count: int) -> float:
    """Compute the consistency probability: (1-r)^C.

    Args:
        r: Per-constraint disagreement rate (0 ≤ r ≤ 1)
        constraint_count: Number of overlap constraints

    Returns:
        Probability that all constraints are satisfied
    """
    return (1.0 - r) ** constraint_count


def overlap_constraint_count(n: int, n_rows: int, n_cols: int) -> int:
    """Count the number of overlap constraints for n databases.

    Args:
        n: Number of partial databases
        n_rows: Number of rows
        n_cols: Number of columns

    Returns:
        Total number of constraints: n*(n-1)/2 * n_rows * n_cols
    """
    return n * (n - 1) // 2 * (n_rows * n_cols)


def sheaf_imputation(
    observed: np.ndarray,
    mask: np.ndarray,
    max_iter: int = 100,
    tol: float = 1e-6,
) -> np.ndarray:
    """Sheaf-based data imputation via iterative projection.

    Fill in missing values by finding the closest global section that
    satisfies the sheaf condition on all overlapping column pairs.

    Algorithm:
    1. Initialize missing values with column means
    2. For each pair of columns, project onto the consistency constraint
    3. Repeat until convergence

    Args:
        observed: Data matrix (n_rows × n_cols) with NaN for missing
        mask: Boolean matrix, True where observed
        max_iter: Maximum iterations
        tol: Convergence tolerance

    Returns:
        Imputed data matrix
    """
    n_rows, n_cols = observed.shape
    result = observed.copy()

    # Initialize missing values with column means
    for c in range(n_cols):
        col = observed[:, c]
        col_mean = np.nanmean(col) if np.any(mask[:, c]) else 0.0
        result[~mask[:, c], c] = col_mean

    for iteration in range(max_iter):
        prev = result.copy()

        # Project onto pairwise consistency constraints
        for c1 in range(n_cols):
            for c2 in range(c1 + 1, n_cols):
                # Find rows where both columns are observed
                both_obs = mask[:, c1] & mask[:, c2]
                if not np.any(both_obs):
                    continue

                # Compute correlation on observed pairs
                x = result[both_obs, c1]
                y = result[both_obs, c2]
                if np.std(x) < 1e-10 or np.std(y) < 1e-10:
                    continue

                # Linear regression: y = a*x + b
                a = np.corrcoef(x, y)[0, 1] * np.std(y) / np.std(x)
                b = np.mean(y) - a * np.mean(x)

                # Fill missing c2 using observed c1
                miss_c2_obs_c1 = ~mask[:, c2] & mask[:, c1]
                result[miss_c2_obs_c1, c2] = (
                    0.5 * result[miss_c2_obs_c1, c2]
                    + 0.5 * (a * result[miss_c2_obs_c1, c1] + b)
                )

                # Fill missing c1 using observed c2
                miss_c1_obs_c2 = ~mask[:, c1] & mask[:, c2]
                if np.abs(a) > 1e-10:
                    result[miss_c1_obs_c2, c1] = (
                        0.5 * result[miss_c1_obs_c2, c1]
                        + 0.5 * (result[miss_c1_obs_c2, c2] - b) / a
                    )

        # Check convergence
        diff = np.max(np.abs(result - prev))
        if diff < tol:
            break

    return result


def mean_imputation(observed: np.ndarray, mask: np.ndarray) -> np.ndarray:
    """Baseline: fill missing values with column means.

    Args:
        observed: Data matrix with NaN for missing
        mask: Boolean matrix, True where observed

    Returns:
        Imputed data matrix
    """
    result = observed.copy()
    for c in range(observed.shape[1]):
        col_mean = np.nanmean(observed[:, c]) if np.any(mask[:, c]) else 0.0
        result[~mask[:, c], c] = col_mean
    return result


def knn_imputation(
    observed: np.ndarray, mask: np.ndarray, k: int = 5
) -> np.ndarray:
    """Baseline: KNN imputation using observed values.

    Args:
        observed: Data matrix with NaN for missing
        mask: Boolean matrix, True where observed
        k: Number of neighbors

    Returns:
        Imputed data matrix
    """
    result = observed.copy()
    n_rows, n_cols = observed.shape

    for r in range(n_rows):
        for c in range(n_cols):
            if mask[r, c]:
                continue

            # Find rows with this column observed
            candidates = np.where(mask[:, c])[0]
            if len(candidates) == 0:
                result[r, c] = 0.0
                continue

            # Compute distances using shared observed columns
            shared = mask[r, :] & mask[candidates, :]
            distances = []
            for cand in candidates:
                shared_cols = np.where(mask[r, :] & mask[cand, :])[0]
                if len(shared_cols) == 0:
                    distances.append(float("inf"))
                else:
                    d = np.sqrt(
                        np.mean((result[r, shared_cols] - result[cand, shared_cols]) ** 2)
                    )
                    distances.append(d)

            distances = np.array(distances)
            nearest = candidates[np.argsort(distances)[:k]]
            result[r, c] = np.mean(observed[nearest, c])

    return result
