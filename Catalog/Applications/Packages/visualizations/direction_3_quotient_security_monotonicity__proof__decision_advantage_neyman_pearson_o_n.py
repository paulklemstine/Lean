#!/usr/bin/env python3
"""
Algorithms for computing distinguishing advantages and verifying
the data processing inequality on finite probability spaces.

Implements:
1. Exact computation of test advantage and decision advantage
2. Optimal distinguisher construction via Neyman-Pearson
3. Verification algorithm for the data processing inequality
4. Total variation distance computation
5. Fiber analysis for quotient maps

All algorithms are exact (up to floating point) for finite spaces.

Complexity:
- accept_prob: O(n)
- test_advantage: O(n)
- decision_advantage: O(n * 2^n)  [exhaustive over Boolean functions]
- decision_advantage_fast: O(n)   [via Neyman-Pearson / TVD]
- verify_dpi: O(n * 2^n + m * 2^m) where n = |domain|, m = |codomain|
"""

import numpy as np
from itertools import product
from typing import Callable, Dict, List, Tuple, Optional, Set


# ============================================================
# Core Probability Computations
# ============================================================

def make_pmf(weights: np.ndarray) -> np.ndarray:
    """
    Normalize a non-negative weight vector to a PMF.
    
    Args:
        weights: Non-negative array
    Returns:
        Normalized probability vector summing to 1
    
    Complexity: O(n)
    
    Example:
        >>> make_pmf(np.array([1, 2, 3]))
        array([0.16666667, 0.33333333, 0.5       ])
    """
    w = np.asarray(weights, dtype=float)
    return w / w.sum()


def accept_prob(mu: np.ndarray, D: np.ndarray) -> float:
    """
    Compute acceptance probability Pr_{x~mu}[D(x) = 1].
    
    Args:
        mu: PMF (probability vector)
        D: Boolean distinguisher (0/1 vector)
    Returns:
        float: The acceptance probability
    
    Complexity: O(n)
    
    Example:
        >>> accept_prob(np.array([0.25, 0.75]), np.array([1, 0]))
        0.25
    """
    return float(np.dot(mu, D))


def pushforward_pmf(mu: np.ndarray, f_table: List[int],
                    codomain_size: int) -> np.ndarray:
    """
    Compute pushforward f_*mu.
    
    Args:
        mu: PMF on {0, ..., n-1}
        f_table: List where f_table[i] = f(i)
        codomain_size: Size of codomain
    Returns:
        PMF on {0, ..., codomain_size - 1}
    
    Complexity: O(n)
    
    Example:
        >>> pushforward_pmf(np.array([0.3, 0.7]), [0, 0], 2)
        array([1. , 0. ])
    """
    result = np.zeros(codomain_size)
    for i, p in enumerate(mu):
        result[f_table[i]] += p
    return result


def test_advantage(mu: np.ndarray, nu: np.ndarray, D: np.ndarray) -> float:
    """
    Compute test advantage |Pr_mu[D] - Pr_nu[D]|.
    
    Args:
        mu, nu: PMFs
        D: Boolean distinguisher (0/1 vector)
    Returns:
        Non-negative float
    
    Complexity: O(n)
    """
    return abs(accept_prob(mu, D) - accept_prob(nu, D))


# ============================================================
# Decision Advantage Algorithms
# ============================================================

def decision_advantage_exhaustive(mu: np.ndarray, nu: np.ndarray) -> Tuple[float, np.ndarray]:
    """
    Compute decision advantage by exhaustive enumeration of all 2^n
    Boolean distinguishers.
    
    Args:
        mu, nu: PMFs of the same size
    Returns:
        (max_advantage, optimal_distinguisher)
    
    Complexity: O(n * 2^n)
    
    Pseudocode:
        best_adv ← 0
        best_D ← None
        for each D ∈ {0,1}^n:
            adv ← |∑_i D[i]*(mu[i] - nu[i])|
            if adv > best_adv:
                best_adv ← adv
                best_D ← D
        return (best_adv, best_D)
    """
    n = len(mu)
    best_adv = 0.0
    best_D = np.zeros(n)
    
    for bits in product([0, 1], repeat=n):
        D = np.array(bits, dtype=float)
        adv = test_advantage(mu, nu, D)
        if adv > best_adv:
            best_adv = adv
            best_D = D.copy()
    
    return best_adv, best_D


def decision_advantage_fast(mu: np.ndarray, nu: np.ndarray) -> Tuple[float, np.ndarray]:
    """
    Compute decision advantage in O(n) using the Neyman-Pearson / TVD
    characterization.
    
    The optimal distinguisher accepts exactly those elements where
    mu[i] > nu[i]. The decision advantage equals the total variation
    distance: TV(mu, nu) = (1/2) * sum_i |mu[i] - nu[i]|.
    
    But more precisely, the decision advantage = max_D |sum_i D[i]*(mu[i]-nu[i])|
    = sum_{i: mu[i]>nu[i]} (mu[i]-nu[i]) = TV(mu, nu).
    
    Args:
        mu, nu: PMFs
    Returns:
        (decision_advantage, optimal_distinguisher)
    
    Complexity: O(n)
    
    Pseudocode:
        diff ← mu - nu
        D ← [1 if diff[i] > 0 else 0 for i in range(n)]
        advantage ← sum(diff[i] for i where diff[i] > 0)
        return (advantage, D)
    """
    diff = mu - nu
    D_pos = (diff > 0).astype(float)
    D_neg = (diff < 0).astype(float)
    
    adv_pos = float(np.dot(diff, D_pos))
    adv_neg = float(-np.dot(diff, D_neg))
    
    if adv_pos >= adv_neg:
        return adv_pos, D_pos
    else:
        return adv_neg, D_neg


def total_variation_distance(mu: np.ndarray, nu: np.ndarray) -> float:
    """
    Compute total variation distance TV(mu, nu) = (1/2) * sum |mu[i] - nu[i]|.
    
    Equals the decision advantage.
    
    Complexity: O(n)
    """
    return 0.5 * float(np.sum(np.abs(mu - nu)))


# ============================================================
# Data Processing Inequality Verification
# ============================================================

def verify_dpi(mu: np.ndarray, nu: np.ndarray,
               f_table: List[int], codomain_size: int,
               method: str = "fast") -> Dict:
    """
    Verify the data processing inequality for a specific instance.
    
    Checks: decisionAdvantage(f_*mu, f_*nu) <= decisionAdvantage(mu, nu)
    
    Args:
        mu, nu: PMFs on domain
        f_table: Map as list
        codomain_size: Size of codomain
        method: "fast" (O(n)) or "exhaustive" (O(n*2^n))
    Returns:
        Dictionary with pre/post advantages, ratio, and verification status
    
    Complexity: O(n) for fast, O(n*2^n + m*2^m) for exhaustive
    """
    compute = decision_advantage_fast if method == "fast" else decision_advantage_exhaustive
    
    mu_push = pushforward_pmf(mu, f_table, codomain_size)
    nu_push = pushforward_pmf(nu, f_table, codomain_size)
    
    pre_adv, pre_D = compute(mu, nu)
    post_adv, post_D = compute(mu_push, nu_push)
    
    return {
        "pre_advantage": pre_adv,
        "post_advantage": post_adv,
        "ratio": post_adv / max(pre_adv, 1e-15),
        "contraction": pre_adv - post_adv,
        "monotone": post_adv <= pre_adv + 1e-12,
        "strict_contraction": post_adv < pre_adv - 1e-12,
        "optimal_pre_D": pre_D.tolist(),
        "optimal_post_D": post_D.tolist(),
    }


def verify_dpi_exhaustive_maps(domain_size: int, codomain_size: int,
                               n_distributions: int = 50,
                               seed: int = 42) -> Dict:
    """
    Exhaustively verify the DPI over all maps and sampled distributions.
    
    Args:
        domain_size: |M|
        codomain_size: |N|
        n_distributions: Number of random distribution pairs to test
        seed: Random seed
    Returns:
        Summary statistics
    
    Complexity: O(n_distributions * codomain_size^domain_size * (n + m))
    """
    np.random.seed(seed)
    
    total_tests = 0
    violations = 0
    min_ratio = float('inf')
    max_ratio = 0.0
    
    # Generate all maps (if feasible)
    n_maps = codomain_size ** domain_size
    if n_maps > 1000:
        # Sample maps instead
        maps = [list(np.random.randint(0, codomain_size, domain_size))
                for _ in range(100)]
    else:
        maps = [list(t) for t in product(range(codomain_size), repeat=domain_size)]
    
    for _ in range(n_distributions):
        mu = make_pmf(np.random.dirichlet(np.ones(domain_size)))
        nu = make_pmf(np.random.dirichlet(np.ones(domain_size)))
        
        for f_table in maps:
            result = verify_dpi(mu, nu, f_table, codomain_size, method="fast")
            total_tests += 1
            
            if not result["monotone"]:
                violations += 1
            
            if result["pre_advantage"] > 1e-10:
                r = result["ratio"]
                min_ratio = min(min_ratio, r)
                max_ratio = max(max_ratio, r)
    
    return {
        "domain_size": domain_size,
        "codomain_size": codomain_size,
        "total_tests": total_tests,
        "violations": violations,
        "min_ratio": min_ratio,
        "max_ratio": max_ratio,
        "all_pass": violations == 0,
    }


# ============================================================
# Fiber Analysis
# ============================================================

def compute_fibers(f_table: List[int], codomain_size: int) -> Dict[int, List[int]]:
    """
    Compute the fibers (preimages) of a map.
    
    Args:
        f_table: Map as list
        codomain_size: Size of codomain
    Returns:
        Dictionary mapping codomain elements to their preimage lists
    
    Complexity: O(n)
    """
    fibers: Dict[int, List[int]] = {b: [] for b in range(codomain_size)}
    for i, b in enumerate(f_table):
        fibers[b].append(i)
    return fibers


def is_surjective(f_table: List[int], codomain_size: int) -> bool:
    """Check if the map is surjective."""
    return len(set(f_table)) == codomain_size


def is_fiber_constant(D: np.ndarray, f_table: List[int],
                      codomain_size: int) -> bool:
    """
    Check if distinguisher D is constant on fibers of f.
    
    A distinguisher D : M → Bool is fiber-constant if D(m) = D(m')
    whenever f(m) = f(m').
    
    Complexity: O(n)
    """
    fibers = compute_fibers(f_table, codomain_size)
    for b, fiber in fibers.items():
        if len(fiber) > 1:
            vals = set(D[i] for i in fiber)
            if len(vals) > 1:
                return False
    return True


def optimal_distinguisher_is_fiber_constant(
        mu: np.ndarray, nu: np.ndarray,
        f_table: List[int], codomain_size: int) -> Tuple[bool, float, float]:
    """
    Check whether the optimal distinguisher for (mu, nu) is fiber-constant
    along f. Returns whether equality holds in the DPI.
    
    Returns:
        (is_fiber_constant, pre_adv, post_adv)
    """
    _, opt_D = decision_advantage_fast(mu, nu)
    fc = is_fiber_constant(opt_D, f_table, codomain_size)
    
    pre_adv = total_variation_distance(mu, nu)
    mu_push = pushforward_pmf(mu, f_table, codomain_size)
    nu_push = pushforward_pmf(nu, f_table, codomain_size)
    post_adv = total_variation_distance(mu_push, nu_push)
    
    return fc, pre_adv, post_adv


# ============================================================
# Linear Map Construction
# ============================================================

def linear_map_zmod(coeffs: List[int], q: int, n: int) -> List[int]:
    """
    Construct the map f(x) = sum(coeffs[i] * x[i]) mod q
    for x in (Z/qZ)^n.
    
    Args:
        coeffs: Coefficient vector in (Z/qZ)^n
        q: Modulus
        n: Dimension
    Returns:
        f_table: Map as list indexed by tuple encoding
    
    Complexity: O(q^n * n)
    """
    elements = list(product(range(q), repeat=n))
    f_table = []
    for x in elements:
        val = sum(c * xi for c, xi in zip(coeffs, x)) % q
        f_table.append(val)
    return f_table


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")
    
    # 1. Basic computation
    mu = make_pmf(np.array([3, 1, 1, 5]))
    nu = make_pmf(np.array([1, 1, 1, 1]))
    
    adv_ex, D_ex = decision_advantage_exhaustive(mu, nu)
    adv_fast, D_fast = decision_advantage_fast(mu, nu)
    tvd = total_variation_distance(mu, nu)
    
    print(f"mu = {mu}")
    print(f"nu = {nu}")
    print(f"Decision advantage (exhaustive): {adv_ex:.6f}, D = {D_ex}")
    print(f"Decision advantage (fast/NP):    {adv_fast:.6f}, D = {D_fast}")
    print(f"Total variation distance:        {tvd:.6f}")
    print(f"Agree: {abs(adv_ex - adv_fast) < 1e-10}")
    print()
    
    # 2. DPI verification
    f_table = [0, 0, 1, 1]  # Parity-like map
    result = verify_dpi(mu, nu, f_table, 2)
    print(f"DPI verification (f = {f_table}):")
    for k, v in result.items():
        if isinstance(v, float):
            print(f"  {k}: {v:.6f}")
        else:
            print(f"  {k}: {v}")
    print()
    
    # 3. Exhaustive verification
    print("Exhaustive verification over small instances:")
    for n, m in [(3, 2), (4, 2), (4, 3)]:
        summary = verify_dpi_exhaustive_maps(n, m, n_distributions=20)
        print(f"  |M|={n}, |N|={m}: {summary['total_tests']} tests, "
              f"all pass: {summary['all_pass']}, "
              f"ratio range: [{summary['min_ratio']:.4f}, {summary['max_ratio']:.4f}]")
    print()
    
    # 4. Linear maps
    print("Linear maps over Z/5Z, n=2:")
    for coeffs in [[1, 0], [1, 1], [2, 3]]:
        f_table = linear_map_zmod(coeffs, 5, 2)
        mu_rand = make_pmf(np.random.dirichlet(np.ones(25)))
        nu_rand = make_pmf(np.ones(25))
        result = verify_dpi(mu_rand, nu_rand, f_table, 5)
        print(f"  coeffs={coeffs}: ratio={result['ratio']:.4f}, surjective={is_surjective(f_table, 5)}")
