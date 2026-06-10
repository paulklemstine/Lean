"""
Sheaf Cohomology of Missing Data: Algorithms

Type-hinted implementations of the core algorithms for computing
cohomological invariants of datasets with missing values.
"""

from typing import List, Tuple, Optional
import numpy as np
from numpy.typing import NDArray


def observation_mask(data: NDArray[np.float64]) -> NDArray[np.bool_]:
    """Create an observation mask from a dataset (NaN = missing)."""
    return ~np.isnan(data)


def shared_features(mask: NDArray[np.bool_], i: int, j: int) -> NDArray[np.bool_]:
    """Compute features shared between observations i and j."""
    return mask[i] & mask[j]


def overlap_weight(mask: NDArray[np.bool_], i: int, j: int) -> int:
    """Number of features shared between observations i and j."""
    return int(np.sum(shared_features(mask, i, j)))


def overlap_matrix(mask: NDArray[np.bool_]) -> NDArray[np.int64]:
    """Compute the full overlap matrix L[i,j] = |shared(i,j)|."""
    m = mask.shape[0]
    L = np.zeros((m, m), dtype=np.int64)
    for i in range(m):
        for j in range(m):
            L[i, j] = overlap_weight(mask, i, j)
    return L


def cohomological_defect(mask: NDArray[np.bool_]) -> int:
    """Compute the cohomological defect of a data mask.

    The defect counts total asymmetric observations:
    sum_{i,j} |obs(i) \\ obs(j)|
    """
    m = mask.shape[0]
    defect = 0
    for i in range(m):
        for j in range(m):
            # obs(i) \ obs(j) = features in i but not in j
            defect += int(np.sum(mask[i] & ~mask[j]))
    return defect


def coboundary_operator(data: NDArray[np.float64]) -> NDArray[np.float64]:
    """Compute the coboundary δ⁰(data)[i,j,k] = data[j,k] - data[i,k].

    Args:
        data: m × n array of values (NaN for unobserved)
    Returns:
        m × m × n array of pairwise differences
    """
    m, n = data.shape
    delta = np.zeros((m, m, n))
    for i in range(m):
        for j in range(m):
            delta[i, j, :] = data[j, :] - data[i, :]
    return delta


def masked_norm_sq(mask: NDArray[np.bool_], delta: NDArray[np.float64]) -> float:
    """Compute the squared coboundary norm restricted to shared features.

    Only sums over features that are observed by both observations.
    """
    m = mask.shape[0]
    n = mask.shape[1]
    total = 0.0
    for i in range(m):
        for j in range(m):
            shared = mask[i] & mask[j]
            for k in range(n):
                if shared[k]:
                    total += delta[i, j, k] ** 2
    return total


def feature_norm_decomposition(
    mask: NDArray[np.bool_], delta: NDArray[np.float64]
) -> NDArray[np.float64]:
    """Decompose the coboundary norm by feature.

    Returns an array of per-feature contributions to the total norm.
    """
    m = mask.shape[0]
    n = mask.shape[1]
    per_feature = np.zeros(n)
    for k in range(n):
        for i in range(m):
            for j in range(m):
                if mask[i, k] and mask[j, k]:
                    per_feature[k] += delta[i, j, k] ** 2
    return per_feature


def sheaf_imputation(
    data: NDArray[np.float64],
    mask: NDArray[np.bool_],
    max_iter: int = 100,
    tol: float = 1e-6,
) -> NDArray[np.float64]:
    """Sheaf-theoretic imputation: minimize coboundary norm.

    Iteratively updates missing values to minimize the total
    inconsistency (coboundary norm) on shared features.

    This is equivalent to finding the section s in H⁰ that minimizes
    ||δ⁰(s)||² — the maximum likelihood imputation under local consistency.

    Args:
        data: m × n array with NaN for missing values
        mask: m × n boolean array (True = observed)
        max_iter: maximum iterations
        tol: convergence tolerance
    Returns:
        Imputed m × n array with no NaN values
    """
    m, n = data.shape
    imputed = data.copy()

    # Initialize missing values with column means
    for k in range(n):
        col = data[:, k]
        observed = col[mask[:, k]]
        if len(observed) > 0:
            imputed[~mask[:, k], k] = np.mean(observed)
        else:
            imputed[~mask[:, k], k] = 0.0

    for iteration in range(max_iter):
        old_imputed = imputed.copy()

        # For each missing entry (i, k), set it to the weighted average
        # of values from observations that share feature k with observation i
        for i in range(m):
            for k in range(n):
                if not mask[i, k]:
                    # Find observations that observe feature k
                    observers = np.where(mask[:, k])[0]
                    if len(observers) > 0:
                        # Weight by number of shared features
                        weights = np.array(
                            [overlap_weight(mask, i, j) for j in observers],
                            dtype=np.float64,
                        )
                        if weights.sum() > 0:
                            weights /= weights.sum()
                            imputed[i, k] = np.dot(
                                weights, imputed[observers, k]
                            )

        # Check convergence
        change = np.max(np.abs(imputed - old_imputed))
        if change < tol:
            break

    return imputed


def imputation_quality(
    imputed: NDArray[np.float64], mask: NDArray[np.bool_]
) -> float:
    """Compute the imputation quality (coboundary norm of imputed data)."""
    delta = coboundary_operator(imputed)
    return masked_norm_sq(mask, delta)


def entropy_of_missingness(mask: NDArray[np.bool_]) -> float:
    """Compute the entropy of the missing pattern.

    H = -sum_i (p_i * log(p_i) + (1-p_i) * log(1-p_i))
    where p_i is the observation rate for feature i.
    """
    n = mask.shape[1]
    entropy = 0.0
    for k in range(n):
        p = np.mean(mask[:, k])
        if 0 < p < 1:
            entropy -= p * np.log(p) + (1 - p) * np.log(1 - p)
    return entropy
