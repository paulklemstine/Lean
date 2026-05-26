#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Subgroup Pressure Concentration

Implements the core computational methods from the research paper:
1. Subgroup pressure computation for arbitrary finite groups
2. Influence calculation and bounded-difference verification
3. Variance estimation via Monte Carlo and analytic bounds
4. Moment generating function computation
5. Concentration exponent estimation

All algorithms operate on the SubgroupPressureModel abstraction.
"""

import numpy as np
from typing import List, Tuple, Callable, Optional
from dataclasses import dataclass
from math import factorial, log, exp, sqrt


@dataclass
class SubgroupPressureModel:
    """
    A finite subgroup ensemble with pair interaction weight.
    
    Attributes:
        indices: List of subgroup indices [G : H_i] for each subgroup in the support.
        weight_matrix: 2D array W[i,j] = w(H_i, H_j), the pair interaction weight.
        labels: Optional names for each subgroup.
    """
    indices: np.ndarray
    weight_matrix: np.ndarray
    labels: Optional[List[str]] = None
    
    @property
    def size(self) -> int:
        """Number of subgroups in the support."""
        return len(self.indices)
    
    def validate(self) -> bool:
        """Check that the model is well-formed."""
        n = self.size
        assert self.weight_matrix.shape == (n, n), \
            f"Weight matrix shape {self.weight_matrix.shape} != ({n}, {n})"
        assert np.all(self.indices > 0), "All indices must be positive"
        return True


def inverse_index_kernel(indices: np.ndarray, alpha: float = 2.0, C: float = 1.0) -> np.ndarray:
    """
    Construct the inverse-index decay kernel.
    
    w(H, K) = C / (index(H)^alpha * index(K)^alpha)
    
    Args:
        indices: Array of subgroup indices.
        alpha: Decay exponent (default 2.0).
        C: Amplitude constant.
    
    Returns:
        Weight matrix W[i,j].
    
    Complexity: O(n^2) where n = len(indices).
    """
    inv = C / (indices.astype(float) ** alpha)
    return np.outer(inv, inv)


def compute_pressure(model: SubgroupPressureModel, chi: np.ndarray) -> float:
    """
    Compute pressure Π(χ) = Σ_{H,K} χ(H) χ(K) w(H,K).
    
    Args:
        model: The pressure model.
        chi: Boolean indicator array.
    
    Returns:
        The pressure value.
    
    Complexity: O(n^2) where n = model.size.
    """
    mask = chi.astype(float)
    return float(mask @ model.weight_matrix @ mask)


def compute_influence(model: SubgroupPressureModel, h0: int) -> float:
    """
    Compute the coordinate influence of subgroup h0.
    
    influence(H_0) = Σ_K |w(H_0, K)| + Σ_K |w(K, H_0)|
    
    Args:
        model: The pressure model.
        h0: Index of the subgroup to toggle.
    
    Returns:
        The influence value.
    
    Complexity: O(n) where n = model.size.
    """
    row_sum = np.sum(np.abs(model.weight_matrix[h0, :]))
    col_sum = np.sum(np.abs(model.weight_matrix[:, h0]))
    return float(row_sum + col_sum)


def compute_all_influences(model: SubgroupPressureModel) -> np.ndarray:
    """
    Compute influences for all subgroups.
    
    Returns:
        Array of influence values.
    
    Complexity: O(n^2).
    """
    row_sums = np.sum(np.abs(model.weight_matrix), axis=1)
    col_sums = np.sum(np.abs(model.weight_matrix), axis=0)
    return row_sums + col_sums


def variance_bound(model: SubgroupPressureModel, p: float = 0.5) -> float:
    """
    Compute the analytic variance upper bound.
    
    VarBound = p(1-p) * Σ_H influence(H)^2
    
    This follows from the Efron-Stein inequality combined with
    the toggle/Lipschitz bound (Theorem 1).
    
    Args:
        model: The pressure model.
        p: Bernoulli inclusion probability.
    
    Returns:
        Upper bound on variance.
    
    Complexity: O(n^2).
    """
    influences = compute_all_influences(model)
    return p * (1 - p) * float(np.sum(influences ** 2))


def expected_pressure(model: SubgroupPressureModel, p: float = 0.5) -> float:
    """
    Compute expected pressure E[Π] = p^2 * Σ_{H,K} w(H,K).
    
    For independent Bernoulli(p) indicators, E[χ(H)χ(K)] = p^2.
    
    Args:
        model: The pressure model.
        p: Bernoulli inclusion probability.
    
    Returns:
        Expected pressure.
    
    Complexity: O(n^2).
    """
    return p ** 2 * float(np.sum(model.weight_matrix))


def empirical_statistics(model: SubgroupPressureModel, p: float = 0.5,
                         num_samples: int = 10000,
                         seed: Optional[int] = None) -> dict:
    """
    Estimate statistics of random pressure by Monte Carlo sampling.
    
    Args:
        model: The pressure model.
        p: Bernoulli inclusion probability.
        num_samples: Number of Monte Carlo samples.
        seed: Random seed for reproducibility.
    
    Returns:
        Dictionary with keys: mean, variance, std, skewness, kurtosis,
        samples (raw pressure values).
    
    Complexity: O(num_samples * n^2).
    """
    if seed is not None:
        rng = np.random.RandomState(seed)
    else:
        rng = np.random.RandomState()
    
    n = model.size
    pressures = np.zeros(num_samples)
    
    for i in range(num_samples):
        chi = (rng.random(n) < p).astype(float)
        pressures[i] = chi @ model.weight_matrix @ chi
    
    mean = np.mean(pressures)
    var = np.var(pressures)
    std = np.std(pressures)
    
    if std > 1e-15:
        centered = pressures - mean
        skewness = float(np.mean(centered ** 3) / std ** 3)
        kurtosis = float(np.mean(centered ** 4) / std ** 4 - 3)
    else:
        skewness = 0.0
        kurtosis = 0.0
    
    return {
        'mean': float(mean),
        'variance': float(var),
        'std': float(std),
        'skewness': skewness,
        'kurtosis': kurtosis,
        'samples': pressures
    }


def concentration_exponent(model: SubgroupPressureModel, p: float = 0.5) -> float:
    """
    Estimate the concentration exponent from the influence bound.
    
    The McDiarmid bound gives:
        P(|Π - E[Π]| ≥ t) ≤ 2 exp(-2t² / Σ c_H²)
    
    The concentration exponent is 2 / Σ c_H².
    
    Complexity: O(n^2).
    """
    influences = compute_all_influences(model)
    sum_sq = float(np.sum(influences ** 2))
    if sum_sq < 1e-30:
        return float('inf')
    return 2.0 / sum_sq


def log_mgf(model: SubgroupPressureModel, beta: float, p: float = 0.5,
            num_samples: int = 50000) -> float:
    """
    Estimate log moment generating function by Monte Carlo.
    
    log MGF(β) = log E[exp(β * (Π - E[Π]))]
    
    Uses log-sum-exp trick for numerical stability.
    
    Complexity: O(num_samples * n^2).
    """
    n = model.size
    ep = expected_pressure(model, p)
    
    rng = np.random.RandomState(42)
    log_vals = np.zeros(num_samples)
    
    for i in range(num_samples):
        chi = (rng.random(n) < p).astype(float)
        pres = chi @ model.weight_matrix @ chi
        log_vals[i] = beta * (pres - ep)
    
    # Log-sum-exp trick
    max_val = np.max(log_vals)
    result = max_val + np.log(np.mean(np.exp(log_vals - max_val)))
    return float(result)


def build_point_stabilizer_model(n: int, alpha: float = 2.0) -> SubgroupPressureModel:
    """
    Build a pressure model for point stabilizers of S_n.
    
    There are n point stabilizers, each isomorphic to S_{n-1},
    with index [S_n : S_{n-1}] = n.
    
    Args:
        n: Degree of the symmetric group.
        alpha: Decay exponent for the kernel.
    
    Returns:
        SubgroupPressureModel for point stabilizers.
    """
    indices = np.full(n, n, dtype=float)
    W = inverse_index_kernel(indices, alpha=alpha)
    labels = [f"Stab({i})" for i in range(n)]
    return SubgroupPressureModel(indices=indices, weight_matrix=W, labels=labels)


def build_young_subgroup_model(n: int, max_parts: int = 2,
                                alpha: float = 2.0) -> SubgroupPressureModel:
    """
    Build a pressure model for Young subgroups of S_n.
    
    Young subgroups S_{a1} × S_{a2} × ... with a1 + a2 + ... = n
    have index n! / (a1! * a2! * ...).
    
    Args:
        n: Degree of the symmetric group.
        max_parts: Maximum number of parts in the composition.
        alpha: Decay exponent for the kernel.
    
    Returns:
        SubgroupPressureModel for Young subgroups.
    """
    index_list = []
    label_list = []
    
    def gen_compositions(remaining, max_p, current):
        if max_p == 1:
            if remaining >= 1:
                parts = current + [remaining]
                denom = 1
                for a in parts:
                    denom *= factorial(a)
                idx = factorial(n) // denom
                if idx > 1:
                    index_list.append(idx)
                    label_list.append(f"S_{'×S_'.join(str(a) for a in parts)}")
            return
        for a in range(1, remaining):
            gen_compositions(remaining - a, max_p - 1, current + [a])
        parts = current + [remaining]
        denom = 1
        for a in parts:
            denom *= factorial(a)
        idx = factorial(n) // denom
        if idx > 1:
            index_list.append(idx)
            label_list.append(f"S_{'×S_'.join(str(a) for a in parts)}")
    
    gen_compositions(n, max_parts, [])
    
    indices = np.array(index_list, dtype=float)
    W = inverse_index_kernel(indices, alpha=alpha)
    return SubgroupPressureModel(indices=indices, weight_matrix=W, labels=label_list)


def fit_power_law(ns: List[int], values: List[float]) -> Tuple[float, float]:
    """
    Fit a power law y = C * n^(-alpha) to data.
    
    Returns:
        (alpha, C) - the exponent and coefficient.
    """
    mask = np.array(values) > 1e-30
    if mask.sum() < 2:
        return 0.0, 0.0
    log_ns = np.log(np.array(ns, dtype=float)[mask])
    log_vals = np.log(np.array(values, dtype=float)[mask])
    coeffs = np.polyfit(log_ns, log_vals, 1)
    return -coeffs[0], np.exp(coeffs[1])


# ─── Example usage ─────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== SubgroupPressureModel Example ===\n")
    
    for n in [5, 8, 12]:
        model = build_point_stabilizer_model(n)
        model.validate()
        
        stats = empirical_statistics(model, p=0.5, num_samples=10000, seed=42)
        vb = variance_bound(model, p=0.5)
        ep = expected_pressure(model, p=0.5)
        ce = concentration_exponent(model, p=0.5)
        
        print(f"S_{n}, Point Stabilizers:")
        print(f"  |Support| = {model.size}")
        print(f"  E[Π] (analytic) = {ep:.8f}")
        print(f"  E[Π] (empirical) = {stats['mean']:.8f}")
        print(f"  Var(Π) (empirical) = {stats['variance']:.2e}")
        print(f"  Var bound (analytic) = {vb:.2e}")
        print(f"  Concentration exponent = {ce:.2e}")
        print(f"  Skewness = {stats['skewness']:.3f}")
        print(f"  Excess kurtosis = {stats['kurtosis']:.3f}")
        print()
