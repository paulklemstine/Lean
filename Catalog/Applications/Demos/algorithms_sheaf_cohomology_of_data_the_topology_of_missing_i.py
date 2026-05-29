"""
Sheaf Cohomology of Data: Algorithms for Missing Data Analysis

This module implements the core algorithms for analyzing missing data
through the lens of sheaf cohomology on observation posets.

Core concepts:
- ObservationMask: Boolean matrix encoding observed/missing entries
- DataSheaf: Cochain complex on the observation poset
- Coboundary operator δ⁰: measures pairwise disagreement
- Coboundary norm: L² measure of total inconsistency
- Sheaf-theoretic imputation: minimize coboundary norm
"""

import numpy as np
from typing import Optional, Tuple, List, Dict
from dataclasses import dataclass


@dataclass
class ObservationMask:
    """Boolean matrix encoding which entries are observed.
    
    mask[i, j] = True means observation i has feature j observed.
    
    Attributes:
        mask: (m, n) boolean array
        m: number of observations
        n: number of features
    """
    mask: np.ndarray
    
    @property
    def m(self) -> int:
        return self.mask.shape[0]
    
    @property
    def n(self) -> int:
        return self.mask.shape[1]
    
    def observed_features(self, i: int) -> np.ndarray:
        """Indices of features observed for observation i."""
        return np.where(self.mask[i])[0]
    
    def shared_features(self, i: int, j: int) -> np.ndarray:
        """Indices of features observed by both observations i and j."""
        return np.where(self.mask[i] & self.mask[j])[0]
    
    def total_observed(self) -> int:
        """Total number of observed entries."""
        return int(np.sum(self.mask))
    
    def total_missing(self) -> int:
        """Total number of missing entries."""
        return self.m * self.n - self.total_observed()
    
    def missing_rate(self) -> float:
        """Fraction of entries that are missing."""
        return self.total_missing() / (self.m * self.n)
    
    def missingness_count(self, i: int) -> int:
        """Number of missing features for observation i."""
        return self.n - len(self.observed_features(i))
    
    def total_missingness_count(self) -> int:
        """Sum of missingness counts across all observations."""
        return sum(self.missingness_count(i) for i in range(self.m))
    
    @staticmethod
    def random(m: int, n: int, missing_rate: float, rng: Optional[np.random.Generator] = None) -> 'ObservationMask':
        """Generate a random mask with given missing rate.
        
        Args:
            m: number of observations
            n: number of features
            missing_rate: probability of each entry being missing
            rng: random number generator
        """
        if rng is None:
            rng = np.random.default_rng()
        mask = rng.random((m, n)) >= missing_rate
        return ObservationMask(mask=mask)
    
    @staticmethod
    def complete(m: int, n: int) -> 'ObservationMask':
        """Create a complete mask (no missing data)."""
        return ObservationMask(mask=np.ones((m, n), dtype=bool))


def coboundary_delta0(data: np.ndarray) -> np.ndarray:
    """Compute the 0th coboundary operator δ⁰.
    
    (δ⁰f)(i, j, k) = f(j, k) - f(i, k)
    
    Args:
        data: (m, n) array of data values
    
    Returns:
        (m, m, n) array of pairwise disagreements
    
    Time complexity: O(m² × n)
    Space complexity: O(m² × n)
    """
    m, n = data.shape
    # Broadcasting: data[None, :, :] - data[:, None, :]
    return data[None, :, :] - data[:, None, :]


def coboundary_delta1(g: np.ndarray) -> np.ndarray:
    """Compute the 1st coboundary operator δ¹.
    
    (δ¹g)(i, j, l, k) = g(j, l, k) - g(i, l, k) + g(i, j, k)
    
    Args:
        g: (m, m, n) array (1-cochain)
    
    Returns:
        (m, m, m, n) array (2-cochain)
    
    Time complexity: O(m³ × n)
    Space complexity: O(m³ × n)
    """
    m = g.shape[0]
    n = g.shape[2]
    result = np.zeros((m, m, m, n))
    for i in range(m):
        for j in range(m):
            for l in range(m):
                result[i, j, l, :] = g[j, l, :] - g[i, l, :] + g[i, j, :]
    return result


def coboundary_norm_sq(mask: ObservationMask, g: np.ndarray) -> float:
    """Compute the squared L² norm of a 1-cochain on shared features.
    
    ||g||² = Σ_i Σ_j Σ_{k ∈ shared(i,j)} g(i,j,k)²
    
    This measures total inconsistency in the data.
    
    Args:
        mask: observation mask
        g: (m, m, n) array (1-cochain)
    
    Returns:
        Non-negative real number
    
    Time complexity: O(m² × n)
    """
    total = 0.0
    for i in range(mask.m):
        for j in range(mask.m):
            shared = mask.shared_features(i, j)
            if len(shared) > 0:
                total += np.sum(g[i, j, shared] ** 2)
    return total


def verify_coboundary_sq_zero(data: np.ndarray, tol: float = 1e-10) -> bool:
    """Verify δ¹ ∘ δ⁰ = 0 numerically.
    
    This is the fundamental cochain complex property.
    
    Args:
        data: (m, n) data array
        tol: numerical tolerance
    
    Returns:
        True if ||δ¹(δ⁰(data))|| < tol
    """
    delta0 = coboundary_delta0(data)
    delta1 = coboundary_delta1(delta0)
    return np.max(np.abs(delta1)) < tol


def h1_dimension_estimate(mask: ObservationMask, data: np.ndarray) -> Dict[str, float]:
    """Estimate the dimension of H¹ for the data sheaf.
    
    H¹ = ker(δ¹) / im(δ⁰). We estimate this by:
    1. Computing the coboundary δ⁰ of the data
    2. Measuring the coboundary norm (how far from being a cocycle)
    3. Counting obstruction pairs (pairs with non-trivial shared features)
    
    Args:
        mask: observation mask
        data: (m, n) data array
    
    Returns:
        Dictionary with dimension estimates and related metrics
    
    Time complexity: O(m² × n)
    """
    delta0 = coboundary_delta0(data)
    norm_sq = coboundary_norm_sq(mask, delta0)
    
    # Count obstruction pairs
    obstruction_pairs = 0
    for i in range(mask.m):
        for j in range(i + 1, mask.m):
            shared = mask.shared_features(i, j)
            if len(shared) > 0 and np.any(np.abs(delta0[i, j, shared]) > 1e-10):
                obstruction_pairs += 1
    
    # Missing rate
    r = mask.missing_rate()
    n = mask.n
    
    # Theoretical prediction: r * n * r * log(1/r) if r > 0
    if r > 0:
        theoretical = r * n * r * np.log(1.0 / r)
    else:
        theoretical = 0.0
    
    return {
        'coboundary_norm_sq': norm_sq,
        'obstruction_pairs': obstruction_pairs,
        'total_pairs': mask.m * (mask.m - 1) // 2,
        'missing_rate': r,
        'total_missing': mask.total_missing(),
        'total_missingness_count': mask.total_missingness_count(),
        'theoretical_h1_bound': theoretical,
    }


def sheaf_imputation(mask: ObservationMask, data: np.ndarray,
                     max_iter: int = 100, tol: float = 1e-6) -> np.ndarray:
    """Sheaf-theoretic imputation: minimize the coboundary norm.
    
    Fill in missing values by finding values that minimize the total
    pairwise disagreement on shared features. This is equivalent to
    finding the section s in H⁰ that minimizes δ⁰(s) in the L² norm.
    
    Algorithm:
    1. Initialize missing values to the mean of observed values per feature
    2. Iteratively update each missing value to minimize local coboundary
    3. Converge when changes are below tolerance
    
    This is the maximum likelihood imputation under the assumption that
    the data is locally consistent (i.e., observations should agree on
    shared features).
    
    Args:
        mask: observation mask
        data: (m, n) data array (values at unobserved positions are ignored)
        max_iter: maximum iterations
        tol: convergence tolerance
    
    Returns:
        (m, n) array with missing values filled in
    
    Time complexity per iteration: O(m² × n)
    Space complexity: O(m × n)
    """
    imputed = data.copy()
    
    # Initialize missing values with feature means
    for j in range(mask.n):
        observed_vals = data[mask.mask[:, j], j]
        if len(observed_vals) > 0:
            mean_val = np.mean(observed_vals)
        else:
            mean_val = 0.0
        imputed[~mask.mask[:, j], j] = mean_val
    
    for iteration in range(max_iter):
        old_imputed = imputed.copy()
        
        for i in range(mask.m):
            for k in range(mask.n):
                if mask.mask[i, k]:
                    continue  # Skip observed values
                
                # Minimize coboundary: set to weighted average of
                # values from observations sharing feature k
                total_weight = 0.0
                weighted_sum = 0.0
                
                for j in range(mask.m):
                    if j == i:
                        continue
                    if mask.mask[j, k]:
                        # Weight by number of shared features
                        shared = mask.shared_features(i, j)
                        weight = len(shared) + 1  # +1 for feature k itself
                        weighted_sum += weight * imputed[j, k]
                        total_weight += weight
                
                if total_weight > 0:
                    imputed[i, k] = weighted_sum / total_weight
        
        # Check convergence
        change = np.max(np.abs(imputed - old_imputed))
        if change < tol:
            break
    
    return imputed


def mean_imputation(mask: ObservationMask, data: np.ndarray) -> np.ndarray:
    """Simple mean imputation baseline.
    
    Fill missing values with the column mean of observed values.
    
    Args:
        mask: observation mask
        data: (m, n) data array
    
    Returns:
        (m, n) array with missing values filled in
    """
    imputed = data.copy()
    for j in range(mask.n):
        observed_vals = data[mask.mask[:, j], j]
        if len(observed_vals) > 0:
            imputed[~mask.mask[:, j], j] = np.mean(observed_vals)
        else:
            imputed[~mask.mask[:, j], j] = 0.0
    return imputed


def knn_imputation(mask: ObservationMask, data: np.ndarray, k: int = 5) -> np.ndarray:
    """K-nearest neighbors imputation.
    
    For each missing value, find k nearest observations (based on shared
    observed features) and average their values.
    
    Args:
        mask: observation mask
        data: (m, n) data array
        k: number of neighbors
    
    Returns:
        (m, n) array with missing values filled in
    """
    imputed = data.copy()
    
    # First pass: mean impute for distance computation
    mean_imp = mean_imputation(mask, data)
    
    for i in range(mask.m):
        for feat in range(mask.n):
            if mask.mask[i, feat]:
                continue
            
            # Find distances using observed features of observation i
            obs_feats = mask.observed_features(i)
            if len(obs_feats) == 0:
                imputed[i, feat] = np.mean(mean_imp[:, feat])
                continue
            
            distances = np.sum((mean_imp[:, obs_feats] - data[i, obs_feats]) ** 2, axis=1)
            distances[i] = np.inf  # Exclude self
            
            # Find k nearest with feature observed
            candidates = np.where(mask.mask[:, feat])[0]
            if len(candidates) == 0:
                imputed[i, feat] = 0.0
                continue
            
            cand_dist = distances[candidates]
            k_actual = min(k, len(candidates))
            nearest_idx = candidates[np.argsort(cand_dist)[:k_actual]]
            imputed[i, feat] = np.mean(data[nearest_idx, feat])
    
    return imputed


def compare_imputations(ground_truth: np.ndarray, mask: ObservationMask,
                        methods: Optional[Dict] = None) -> Dict[str, Dict[str, float]]:
    """Compare imputation methods on data with known ground truth.
    
    Args:
        ground_truth: (m, n) complete data array
        mask: observation mask (entries to treat as missing)
        methods: dict of method_name -> imputation_function
    
    Returns:
        Dictionary of method_name -> metrics (RMSE, MAE, coboundary_norm)
    """
    if methods is None:
        methods = {
            'mean': lambda m, d: mean_imputation(m, d),
            'knn': lambda m, d: knn_imputation(m, d),
            'sheaf': lambda m, d: sheaf_imputation(m, d),
        }
    
    # Create observed data
    observed_data = ground_truth.copy()
    
    results = {}
    for name, method in methods.items():
        imputed = method(mask, observed_data)
        
        # Compute error only on missing entries
        missing_mask = ~mask.mask
        if np.any(missing_mask):
            errors = imputed[missing_mask] - ground_truth[missing_mask]
            rmse = np.sqrt(np.mean(errors ** 2))
            mae = np.mean(np.abs(errors))
        else:
            rmse = 0.0
            mae = 0.0
        
        # Coboundary norm
        delta0 = coboundary_delta0(imputed)
        cb_norm = coboundary_norm_sq(mask, delta0)
        
        results[name] = {
            'rmse': rmse,
            'mae': mae,
            'coboundary_norm_sq': cb_norm,
        }
    
    return results


if __name__ == '__main__':
    # Quick demonstration
    rng = np.random.default_rng(42)
    
    # Generate synthetic data
    m, n = 20, 5
    ground_truth = rng.standard_normal((m, n))
    
    # Create mask with 30% missing
    mask = ObservationMask.random(m, n, missing_rate=0.3, rng=rng)
    
    print(f"Dataset: {m} observations × {n} features")
    print(f"Missing rate: {mask.missing_rate():.2%}")
    print(f"Total missing: {mask.total_missing()}")
    print(f"Missingness count: {mask.total_missingness_count()}")
    
    # Verify δ¹ ∘ δ⁰ = 0
    print(f"\nδ¹ ∘ δ⁰ = 0 verified: {verify_coboundary_sq_zero(ground_truth)}")
    
    # H¹ analysis
    h1_info = h1_dimension_estimate(mask, ground_truth)
    print(f"\nH¹ Analysis:")
    for key, val in h1_info.items():
        print(f"  {key}: {val:.4f}" if isinstance(val, float) else f"  {key}: {val}")
    
    # Compare imputation methods
    print(f"\nImputation Comparison:")
    results = compare_imputations(ground_truth, mask)
    for method, metrics in results.items():
        print(f"  {method}:")
        for key, val in metrics.items():
            print(f"    {key}: {val:.6f}")
