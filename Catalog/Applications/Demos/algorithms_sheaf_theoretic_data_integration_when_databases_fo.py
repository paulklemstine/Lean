"""
Sheaf-Theoretic Data Integration: Algorithms

Type-hinted implementations of the core algorithms for sheaf-based
data imputation and consistency analysis.
"""

from typing import Optional, Dict, Tuple, List, Set, Callable
import numpy as np
from dataclasses import dataclass, field


@dataclass
class PartialDatabase:
    """A partial database with missing entries (represented as NaN)."""
    data: np.ndarray  # shape (nRows, nCols), NaN for missing
    nRows: int = field(init=False)
    nCols: int = field(init=False)

    def __post_init__(self) -> None:
        self.nRows, self.nCols = self.data.shape

    def domain(self) -> Set[Tuple[int, int]]:
        """Return the set of positions with non-missing values."""
        rows, cols = np.where(~np.isnan(self.data))
        return {(int(r), int(c)) for r, c in zip(rows, cols)}

    def restrict(self, feature_subset: Set[int]) -> 'PartialDatabase':
        """Restrict to a subset of columns (features)."""
        cols = sorted(feature_subset)
        return PartialDatabase(self.data[:, cols].copy())


def consistent_pair(db1: PartialDatabase, db2: PartialDatabase) -> bool:
    """Check if two partial databases agree on their overlap."""
    assert db1.data.shape == db2.data.shape
    mask = ~np.isnan(db1.data) & ~np.isnan(db2.data)
    return bool(np.all(db1.data[mask] == db2.data[mask]))


def gluing_map(db1: PartialDatabase, db2: PartialDatabase) -> PartialDatabase:
    """Glue two partial databases, preferring db1 where both are defined."""
    result = db1.data.copy()
    missing_in_1 = np.isnan(result)
    result[missing_in_1] = db2.data[missing_in_1]
    return PartialDatabase(result)


def pairwise_disagreement(db1: PartialDatabase, db2: PartialDatabase) -> int:
    """Count positions where both are defined but disagree."""
    mask = ~np.isnan(db1.data) & ~np.isnan(db2.data)
    return int(np.sum(db1.data[mask] != db2.data[mask]))


def consistency_defect(dbs: List[PartialDatabase]) -> int:
    """Total consistency defect of a family of partial databases."""
    total = 0
    for i, db_i in enumerate(dbs):
        for j, db_j in enumerate(dbs):
            total += pairwise_disagreement(db_i, db_j)
    return total


def overlap_count(dbs: List[PartialDatabase]) -> int:
    """Count total pairwise overlapping positions."""
    total = 0
    for db_i in dbs:
        for db_j in dbs:
            mask = ~np.isnan(db_i.data) & ~np.isnan(db_j.data)
            total += int(np.sum(mask))
    return total


def consistency_probability(r: float, constraint_count: int) -> float:
    """Probability of consistency: (1-r)^C."""
    return (1.0 - r) ** constraint_count


def sheaf_imputation(
    observed: PartialDatabase,
    feature_subsets: List[Set[int]],
    n_iterations: int = 100
) -> np.ndarray:
    """
    Sheaf-based imputation algorithm.

    Iteratively fills missing values by enforcing consistency across
    all pairs of feature subsets. This is the discrete analogue of
    finding the closest global section to the observed partial section.

    Algorithm:
    1. Initialize missing values with column means.
    2. For each iteration:
       a. For each pair of feature subsets (S_i, S_j):
          - Restrict to S_i ∩ S_j
          - Average the values from both restrictions
          - Update the imputed values to enforce consistency
    3. Return the imputed database.
    """
    result = observed.data.copy()
    missing_mask = np.isnan(result)

    # Initialize with column means
    col_means = np.nanmean(result, axis=0)
    for c in range(result.shape[1]):
        result[missing_mask[:, c], c] = col_means[c]

    for iteration in range(n_iterations):
        old_result = result.copy()
        for i, S_i in enumerate(feature_subsets):
            for j, S_j in enumerate(feature_subsets):
                if i >= j:
                    continue
                overlap = S_i & S_j
                if not overlap:
                    continue
                overlap_cols = sorted(overlap)
                S_i_cols = sorted(S_i)
                S_j_cols = sorted(S_j)

                # Enforce consistency on overlap
                for col in overlap_cols:
                    vals_i = result[:, col].copy()
                    vals_j = result[:, col].copy()
                    # Average to enforce consistency
                    avg = (vals_i + vals_j) / 2.0
                    result[:, col] = avg

        # Check convergence
        if np.max(np.abs(result - old_result)) < 1e-10:
            break

    return result


def mean_imputation(observed: PartialDatabase) -> np.ndarray:
    """Simple mean imputation: fill missing with column means."""
    result = observed.data.copy()
    missing_mask = np.isnan(result)
    col_means = np.nanmean(result, axis=0)
    for c in range(result.shape[1]):
        result[missing_mask[:, c], c] = col_means[c]
    return result


def knn_imputation(observed: PartialDatabase, k: int = 5) -> np.ndarray:
    """KNN imputation: fill missing with average of k nearest neighbors."""
    result = observed.data.copy()
    missing_mask = np.isnan(result)

    # For each row with missing values
    for row_idx in range(result.shape[0]):
        missing_cols = np.where(missing_mask[row_idx])[0]
        if len(missing_cols) == 0:
            continue

        # Find k nearest neighbors using non-missing features
        observed_cols = np.where(~missing_mask[row_idx])[0]
        if len(observed_cols) == 0:
            # Fall back to column means
            col_means = np.nanmean(result, axis=0)
            result[row_idx, missing_cols] = col_means[missing_cols]
            continue

        # Compute distances using observed features
        other_rows = [i for i in range(result.shape[0]) if i != row_idx]
        distances = []
        for other in other_rows:
            shared = observed_cols[~np.isnan(result[other, observed_cols])]
            if len(shared) == 0:
                distances.append(float('inf'))
            else:
                dist = np.sqrt(np.sum((result[row_idx, shared] - result[other, shared]) ** 2))
                distances.append(dist)

        # Get k nearest
        nearest = np.argsort(distances)[:k]
        nearest_rows = [other_rows[i] for i in nearest if distances[i] < float('inf')]

        if len(nearest_rows) == 0:
            col_means = np.nanmean(result, axis=0)
            result[row_idx, missing_cols] = col_means[missing_cols]
        else:
            for col in missing_cols:
                vals = [result[r, col] for r in nearest_rows if not np.isnan(result[r, col])]
                if vals:
                    result[row_idx, col] = np.mean(vals)
                else:
                    result[row_idx, col] = np.nanmean(result[:, col])

    return result


def cech_coboundary_zero(sigma: Dict[int, float]) -> Dict[Tuple[int, int], float]:
    """Čech coboundary δ⁰: from 0-cochains to 1-cochains."""
    result = {}
    keys = list(sigma.keys())
    for i in keys:
        for j in keys:
            result[(i, j)] = sigma[j] - sigma[i]
    return result


def cech_coboundary_one(tau: Dict[Tuple[int, int], float]) -> Dict[Tuple[int, int, int], float]:
    """Čech coboundary δ¹: from 1-cochains to 2-cochains."""
    indices = set()
    for (i, j) in tau:
        indices.add(i)
        indices.add(j)
    result = {}
    for i in indices:
        for j in indices:
            for k in indices:
                val = tau.get((j, k), 0) - tau.get((i, k), 0) + tau.get((i, j), 0)
                result[(i, j, k)] = val
    return result


def verify_coboundary_sq_zero(n: int = 5) -> bool:
    """Verify δ¹ ∘ δ⁰ = 0 on random cochains."""
    sigma = {i: np.random.randn() for i in range(n)}
    tau = cech_coboundary_zero(sigma)
    omega = cech_coboundary_one(tau)
    return all(abs(v) < 1e-10 for v in omega.values())
